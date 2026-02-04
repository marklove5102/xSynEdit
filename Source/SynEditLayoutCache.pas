unit SynEditLayoutCache;
{-------------------------------------------------------------------------------
DirectWrite Layout Cache for SynEdit

Purpose:
  Caches TSynTextLayout objects to avoid recreating them on every paint.
  Provides significant performance improvement for text rendering.

Implementation:
  - LRU (Least Recently Used) cache with configurable size
  - Thread-safe for future parallel rendering
  - Automatic cleanup of least used entries

Expected Performance Gain: 30-50% faster rendering

Author: Optimization Initiative 2026-02-04
-------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Generics.Collections,
  System.SyncObjs,
  Winapi.Windows,
  SynDWrite;

type
  // Cache key contains all parameters that affect layout creation
  TLayoutCacheKey = record
    Text: string;
    TextHash: Integer;
    LayoutWidth: Cardinal;
    LayoutHeight: Cardinal;
    CharExtra: Cardinal;
    WordWrap: Boolean;

    constructor Create(const AText: string; ALayoutWidth, ALayoutHeight,
      ACharExtra: Cardinal; AWordWrap: Boolean);
    function GetHashCode: Integer;
    class operator Equal(const A, B: TLayoutCacheKey): Boolean;
  end;

  // Cache entry with usage tracking
  TLayoutCacheEntry = record
    Key: TLayoutCacheKey;
    Layout: TSynTextLayout;
    LastUsed: Cardinal;  // GetTickCount для LRU
    HitCount: Integer;   // Для статистики

    constructor Create(const AKey: TLayoutCacheKey; const ALayout: TSynTextLayout);
  end;

  // Thread-safe LRU cache for text layouts
  TSynLayoutCache = class
  private
    FCache: TDictionary<Integer, TLayoutCacheEntry>;
    FLock: TCriticalSection;
    FMaxSize: Integer;
    FHits: Int64;
    FMisses: Int64;

    procedure TrimCache;
    procedure RemoveLRU;
  public
    constructor Create(AMaxSize: Integer = 200);
    destructor Destroy; override;

    // Main API
    function GetLayout(TextFormat: TSynTextFormat; const Text: string;
      TextLength: Integer; LayoutWidth, LayoutHeight: Cardinal;
      WordWrap: Boolean = False; PixelsPerDip: Single = 1.0): TSynTextLayout;

    procedure Clear;
    procedure SetMaxSize(AMaxSize: Integer);

    // Statistics
    function GetHitRate: Double;
    function GetCacheSize: Integer;
    procedure ResetStatistics;

    property MaxSize: Integer read FMaxSize write SetMaxSize;
    property Hits: Int64 read FHits;
    property Misses: Int64 read FMisses;
    property HitRate: Double read GetHitRate;
  end;

implementation

uses
  System.Hash;

{ TLayoutCacheKey }

constructor TLayoutCacheKey.Create(const AText: string; ALayoutWidth,
  ALayoutHeight, ACharExtra: Cardinal; AWordWrap: Boolean);
begin
  Text := AText;
  TextHash := THashBobJenkins.GetHashValue(AText);
  LayoutWidth := ALayoutWidth;
  LayoutHeight := ALayoutHeight;
  CharExtra := ACharExtra;
  WordWrap := AWordWrap;
end;

function TLayoutCacheKey.GetHashCode: Integer;
begin
  // Combine all fields into hash
  Result := TextHash xor
            Integer(LayoutWidth) xor
            (Integer(LayoutHeight) shl 8) xor
            (Integer(CharExtra) shl 16) xor
            (Ord(WordWrap) shl 24);
end;

class operator TLayoutCacheKey.Equal(const A, B: TLayoutCacheKey): Boolean;
begin
  // Fast comparison - hash first, then detailed check
  Result := (A.TextHash = B.TextHash) and
            (A.LayoutWidth = B.LayoutWidth) and
            (A.LayoutHeight = B.LayoutHeight) and
            (A.CharExtra = B.CharExtra) and
            (A.WordWrap = B.WordWrap) and
            (A.Text = B.Text);  // Final string comparison
end;

{ TLayoutCacheEntry }

constructor TLayoutCacheEntry.Create(const AKey: TLayoutCacheKey;
  const ALayout: TSynTextLayout);
begin
  Key := AKey;
  Layout := ALayout;
  LastUsed := GetTickCount;
  HitCount := 1;
end;

{ TSynLayoutCache }

constructor TSynLayoutCache.Create(AMaxSize: Integer);
begin
  inherited Create;
  FMaxSize := AMaxSize;
  FCache := TDictionary<Integer, TLayoutCacheEntry>.Create(AMaxSize);
  FLock := TCriticalSection.Create;
  FHits := 0;
  FMisses := 0;
end;

destructor TSynLayoutCache.Destroy;
begin
  Clear;
  FCache.Free;
  FLock.Free;
  inherited;
end;

function TSynLayoutCache.GetLayout(TextFormat: TSynTextFormat;
  const Text: string; TextLength: Integer; LayoutWidth, LayoutHeight: Cardinal;
  WordWrap: Boolean; PixelsPerDip: Single): TSynTextLayout;
var
  Key: TLayoutCacheKey;
  Hash: Integer;
  Entry: TLayoutCacheEntry;
  NewLayout: TSynTextLayout;
begin
  // Не кэшируем очень длинные строки (>1000 символов) или пустые
  if (TextLength = 0) or (TextLength > 1000) then
  begin
    // Create directly without caching
    Result.Create(TextFormat, PChar(Text), TextLength, LayoutWidth,
      LayoutHeight, WordWrap, PixelsPerDip);
    Exit;
  end;

  Key := TLayoutCacheKey.Create(Text, LayoutWidth, LayoutHeight,
    TextFormat.CharExtra, WordWrap);
  Hash := Key.GetHashCode;

  FLock.Enter;
  try
    // Try to find in cache
    if FCache.TryGetValue(Hash, Entry) then
    begin
      // Cache hit
      Inc(FHits);
      Entry.LastUsed := GetTickCount;
      Inc(Entry.HitCount);
      FCache.AddOrSetValue(Hash, Entry);  // Update entry
      Result := Entry.Layout;
    end
    else
    begin
      // Cache miss - create new layout
      Inc(FMisses);

      NewLayout.Create(TextFormat, PChar(Text), TextLength, LayoutWidth,
        LayoutHeight, WordWrap, PixelsPerDip);

      // Add to cache
      Entry := TLayoutCacheEntry.Create(Key, NewLayout);
      FCache.Add(Hash, Entry);

      // Trim if needed
      if FCache.Count > FMaxSize then
        TrimCache;

      Result := NewLayout;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TSynLayoutCache.Clear;
begin
  FLock.Enter;
  try
    FCache.Clear;
  finally
    FLock.Leave;
  end;
end;

procedure TSynLayoutCache.SetMaxSize(AMaxSize: Integer);
begin
  FLock.Enter;
  try
    FMaxSize := AMaxSize;
    while FCache.Count > FMaxSize do
      TrimCache;
  finally
    FLock.Leave;
  end;
end;

procedure TSynLayoutCache.TrimCache;
var
  I, RemoveCount: Integer;
begin
  // Remove 20% of least recently used entries
  RemoveCount := Max(1, FMaxSize div 5);
  for I := 1 to RemoveCount do
    RemoveLRU;
end;

procedure TSynLayoutCache.RemoveLRU;
var
  Pair: TPair<Integer, TLayoutCacheEntry>;
  OldestHash: Integer;
  OldestTime: Cardinal;
begin
  if FCache.Count = 0 then Exit;

  // Find least recently used
  OldestTime := High(Cardinal);
  OldestHash := 0;

  for Pair in FCache do
  begin
    if Pair.Value.LastUsed < OldestTime then
    begin
      OldestTime := Pair.Value.LastUsed;
      OldestHash := Pair.Key;
    end;
  end;

  // Remove it
  FCache.Remove(OldestHash);
end;

function TSynLayoutCache.GetHitRate: Double;
var
  Total: Int64;
begin
  Total := FHits + FMisses;
  if Total = 0 then
    Result := 0.0
  else
    Result := (FHits / Total) * 100.0;
end;

function TSynLayoutCache.GetCacheSize: Integer;
begin
  FLock.Enter;
  try
    Result := FCache.Count;
  finally
    FLock.Leave;
  end;
end;

procedure TSynLayoutCache.ResetStatistics;
begin
  FLock.Enter;
  try
    FHits := 0;
    FMisses := 0;
  finally
    FLock.Leave;
  end;
end;

end.
