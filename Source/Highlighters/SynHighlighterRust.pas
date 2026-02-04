{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynHighlighterRust.pas, created 2026-02-04.
The Initial Author of this file is Claude (Anthropic).
All Rights Reserved.

Contributors to the SynEdit projects are listed in the Contributors.txt file.

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net
-------------------------------------------------------------------------------}
{
@abstract(Provides a Rust language highlighter for SynEdit with Code Folding)
@author(Claude, Anthropic)
@created(2026-02-04)
@lastmod(2026-02-04)
Supports Rust 2021 Edition with full syntax:
- Keywords (fn, let, mut, impl, trait, async, await, etc.)
- Lifetimes ('a, 'static, etc.)
- Macros (println!, vec!, macro_rules!, etc.)
- Attributes (#[derive(...)], #![allow(...)], etc.)
- Raw strings (r"...", r#"..."#, etc.)
- Char literals (single chars, escape sequences, unicode)
- Number literals (42, 0x2A, 0b101, 3.14, 1_000_000)
- Comments (// and /* */)
- Code Folding for fn, impl, struct, enum, mod, if, match, loop blocks
}

unit SynHighlighterRust;

{$I SynEdit.inc}

interface

uses
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  SynEditCodeFolding,
  SynUnicode,
  SysUtils,
  Classes;

type
  TtkTokenKind = (
    tkComment,
    tkIdentifier,
    tkKey,
    tkLifetime,
    tkMacro,
    tkAttribute,
    tkNull,
    tkNumber,
    tkSpace,
    tkString,
    tkChar,
    tkSymbol,
    tkType,
    tkUnknown
  );

  TRangeState = (rsUnknown, rsMultilineComment, rsString, rsRawString, rsAttribute);

type
  TSynRustSyn = class(TSynCustomCodeFoldingHighlighter)
  private
    fRange: TRangeState;
    fRawStringHashes: Integer;  // Count of # for raw strings
    FTokenID: TtkTokenKind;
    fCommentAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fLifetimeAttri: TSynHighlighterAttributes;
    fMacroAttri: TSynHighlighterAttributes;
    fAttributeAttri: TSynHighlighterAttributes;
    fNumberAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fCharAttri: TSynHighlighterAttributes;
    fSymbolAttri: TSynHighlighterAttributes;
    fTypeAttri: TSynHighlighterAttributes;
    fKeywords: TStringList;
    fTypes: TStringList;
    procedure NullProc;
    procedure SpaceProc;
    procedure CRProc;
    procedure LFProc;
    procedure IdentProc;
    procedure NumberProc;
    procedure StringProc;
    procedure RawStringProc;
    procedure CharProc;
    procedure SlashProc;
    procedure MultilineCommentProc;
    procedure LifetimeProc;
    procedure HashProc;
    procedure SymbolProc;
    function IsRustKeyword(const AToken: string): Boolean;
    function IsRustType(const AToken: string): Boolean;
  protected
    function GetSampleSource: string; override;
    function IsFilterStored: Boolean; override;
  public
    class function GetLanguageName: string; override;
    class function GetFriendlyLanguageName: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetRange: Pointer; override;
    procedure ResetRange; override;
    procedure SetRange(Value: Pointer); override;
    function GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: Integer; override;
    procedure Next; override;
    // Code Folding
    procedure ScanForFoldRanges(FoldRanges: TSynFoldRanges;
      LinesToScan: TStrings; FromLine: Integer; ToLine: Integer); override;
  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property LifetimeAttri: TSynHighlighterAttributes read fLifetimeAttri write fLifetimeAttri;
    property MacroAttri: TSynHighlighterAttributes read fMacroAttri write fMacroAttri;
    property AttributeAttri: TSynHighlighterAttributes read fAttributeAttri write fAttributeAttri;
    property NumberAttri: TSynHighlighterAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri write fStringAttri;
    property CharAttri: TSynHighlighterAttributes read fCharAttri write fCharAttri;
    property SymbolAttri: TSynHighlighterAttributes read fSymbolAttri write fSymbolAttri;
    property TypeAttri: TSynHighlighterAttributes read fTypeAttri write fTypeAttri;
  end;

implementation

uses
  SynEditStrConst;

const
  // Rust 2021 Edition keywords
  RustKeywords: array[0..51] of string = (
    'as', 'async', 'await', 'break', 'const', 'continue', 'crate',
    'dyn', 'else', 'enum', 'extern', 'false', 'fn', 'for', 'if', 'impl',
    'in', 'let', 'loop', 'match', 'mod', 'move', 'mut', 'pub', 'ref',
    'return', 'self', 'Self', 'static', 'struct', 'super', 'trait',
    'true', 'type', 'unsafe', 'use', 'where', 'while',
    // Rust 2018+ additions
    'try', 'macro_rules', 'union', 'yield',
    // Reserved for future use
    'abstract', 'become', 'box', 'do', 'final', 'macro', 'override', 'priv', 'typeof', 'virtual'
  );

  // Common Rust types
  RustTypes: array[0..35] of string = (
    // Primitive types
    'i8', 'i16', 'i32', 'i64', 'i128', 'isize',
    'u8', 'u16', 'u32', 'u64', 'u128', 'usize',
    'f32', 'f64', 'bool', 'char', 'str',
    // Common standard library types
    'String', 'Vec', 'Option', 'Result', 'Box', 'Rc', 'Arc',
    'Cell', 'RefCell', 'Mutex', 'RwLock',
    'HashMap', 'HashSet', 'BTreeMap', 'BTreeSet',
    'Path', 'PathBuf', 'OsString', 'CString'
  );

  RustFoldRegionType = 1;
  RustMultilineCommentFoldType = 2;

constructor TSynRustSyn.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AOwner);

  fCaseSensitive := True;

  // Build keyword list
  fKeywords := TStringList.Create;
  fKeywords.Sorted := True;
  fKeywords.CaseSensitive := True;
  for I := Low(RustKeywords) to High(RustKeywords) do
    fKeywords.Add(RustKeywords[I]);

  // Build type list
  fTypes := TStringList.Create;
  fTypes.Sorted := True;
  fTypes.CaseSensitive := True;
  for I := Low(RustTypes) to High(RustTypes) do
    fTypes.Add(RustTypes[I]);

  fCommentAttri := TSynHighlighterAttributes.Create(SYNS_AttrComment, SYNS_FriendlyAttrComment);
  fCommentAttri.Foreground := clGreen;
  fCommentAttri.Style := [fsItalic];
  AddAttribute(fCommentAttri);

  fIdentifierAttri := TSynHighlighterAttributes.Create(SYNS_AttrIdentifier, SYNS_FriendlyAttrIdentifier);
  AddAttribute(fIdentifierAttri);

  fKeyAttri := TSynHighlighterAttributes.Create(SYNS_AttrReservedWord, SYNS_FriendlyAttrReservedWord);
  fKeyAttri.Foreground := clBlue;
  fKeyAttri.Style := [fsBold];
  AddAttribute(fKeyAttri);

  fLifetimeAttri := TSynHighlighterAttributes.Create('Lifetime', 'Lifetime');
  fLifetimeAttri.Foreground := clPurple;
  AddAttribute(fLifetimeAttri);

  fMacroAttri := TSynHighlighterAttributes.Create('Macro', 'Macro');
  fMacroAttri.Foreground := clMaroon;
  fMacroAttri.Style := [fsBold];
  AddAttribute(fMacroAttri);

  fAttributeAttri := TSynHighlighterAttributes.Create('Attribute', 'Attribute');
  fAttributeAttri.Foreground := clOlive;
  AddAttribute(fAttributeAttri);

  fNumberAttri := TSynHighlighterAttributes.Create(SYNS_AttrNumber, SYNS_FriendlyAttrNumber);
  fNumberAttri.Foreground := clNavy;
  AddAttribute(fNumberAttri);

  fSpaceAttri := TSynHighlighterAttributes.Create(SYNS_AttrSpace, SYNS_FriendlyAttrSpace);
  AddAttribute(fSpaceAttri);

  fStringAttri := TSynHighlighterAttributes.Create(SYNS_AttrString, SYNS_FriendlyAttrString);
  fStringAttri.Foreground := clTeal;
  AddAttribute(fStringAttri);

  fCharAttri := TSynHighlighterAttributes.Create(SYNS_AttrCharacter, SYNS_FriendlyAttrCharacter);
  fCharAttri.Foreground := clTeal;
  AddAttribute(fCharAttri);

  fSymbolAttri := TSynHighlighterAttributes.Create(SYNS_AttrSymbol, SYNS_FriendlyAttrSymbol);
  AddAttribute(fSymbolAttri);

  fTypeAttri := TSynHighlighterAttributes.Create('Type', 'Type');
  fTypeAttri.Foreground := clNavy;
  fTypeAttri.Style := [fsBold];
  AddAttribute(fTypeAttri);

  SetAttributesOnChange(DefHighlightChange);
  fDefaultFilter := 'Rust files (*.rs)|*.rs';
  fRange := rsUnknown;
  fRawStringHashes := 0;
end;

destructor TSynRustSyn.Destroy;
begin
  fKeywords.Free;
  fTypes.Free;
  inherited;
end;

function TSynRustSyn.IsRustKeyword(const AToken: string): Boolean;
begin
  Result := fKeywords.IndexOf(AToken) >= 0;
end;

function TSynRustSyn.IsRustType(const AToken: string): Boolean;
begin
  Result := fTypes.IndexOf(AToken) >= 0;
end;

procedure TSynRustSyn.SpaceProc;
begin
  FTokenID := tkSpace;
  repeat
    Inc(Run);
  until (fLine[Run] > #32) or IsLineEnd(Run);
end;

procedure TSynRustSyn.NullProc;
begin
  FTokenID := tkNull;
  Inc(Run);
end;

procedure TSynRustSyn.CRProc;
begin
  FTokenID := tkSpace;
  Inc(Run);
  if fLine[Run] = #10 then
    Inc(Run);
end;

procedure TSynRustSyn.LFProc;
begin
  FTokenID := tkSpace;
  Inc(Run);
end;

procedure TSynRustSyn.IdentProc;
var
  TokenStart: Integer;
  S: string;
begin
  TokenStart := Run;

  // Read identifier (alphanumeric + underscore)
  while IsIdentChar(fLine[Run]) or (fLine[Run] = '_') do
    Inc(Run);

  SetString(S, fLine + TokenStart, Run - TokenStart);

  // Check for macro call (followed by !)
  if fLine[Run] = '!' then
  begin
    Inc(Run);
    FTokenID := tkMacro;
  end
  // Check if keyword
  else if IsRustKeyword(S) then
    FTokenID := tkKey
  // Check if type
  else if IsRustType(S) then
    FTokenID := tkType
  else
    FTokenID := tkIdentifier;
end;

procedure TSynRustSyn.NumberProc;
begin
  FTokenID := tkNumber;
  Inc(Run);

  // Binary: 0b10101
  if (fLine[Run - 1] = '0') and CharInSet(fLine[Run], ['b', 'B']) then
  begin
    Inc(Run);
    while CharInSet(fLine[Run], ['0', '1', '_']) do
      Inc(Run);
    Exit;
  end;

  // Octal: 0o755
  if (fLine[Run - 1] = '0') and CharInSet(fLine[Run], ['o', 'O']) then
  begin
    Inc(Run);
    while CharInSet(fLine[Run], ['0'..'7', '_']) do
      Inc(Run);
    Exit;
  end;

  // Hex: 0xDEADBEEF
  if (fLine[Run - 1] = '0') and CharInSet(fLine[Run], ['x', 'X']) then
  begin
    Inc(Run);
    while CharInSet(fLine[Run], ['0'..'9', 'a'..'f', 'A'..'F', '_']) do
      Inc(Run);
    Exit;
  end;

  // Regular number (with underscores, floats, exponents)
  while CharInSet(fLine[Run], ['0'..'9', '_', '.', 'e', 'E', '+', '-']) do
  begin
    if (fLine[Run] = '.') and (fLine[Run + 1] = '.') then
      Break;  // Range operator ..
    if CharInSet(fLine[Run], ['+', '-']) and not CharInSet(fLine[Run - 1], ['e', 'E']) then
      Break;
    Inc(Run);
  end;

  // Type suffix: i32, u64, f32, etc.
  if CharInSet(fLine[Run], ['i', 'u', 'f']) then
  begin
    Inc(Run);
    while CharInSet(fLine[Run], ['0'..'9']) do
      Inc(Run);
  end;
end;

procedure TSynRustSyn.StringProc;
begin
  FTokenID := tkString;
  Inc(Run);  // Skip opening "

  while not IsLineEnd(Run) do
  begin
    if fLine[Run] = '\' then
    begin
      Inc(Run);
      if not IsLineEnd(Run) then
        Inc(Run);
    end
    else if fLine[Run] = '"' then
    begin
      Inc(Run);
      Exit;
    end
    else
      Inc(Run);
  end;
end;

procedure TSynRustSyn.RawStringProc;
var
  HashCount: Integer;
  ClosingHashes: Integer;
begin
  FTokenID := tkString;
  Inc(Run);  // Skip 'r'

  // Count opening hashes
  HashCount := 0;
  while fLine[Run] = '#' do
  begin
    Inc(HashCount);
    Inc(Run);
  end;

  if fLine[Run] <> '"' then
  begin
    // Not a valid raw string, treat as identifier
    FTokenID := tkIdentifier;
    Exit;
  end;

  Inc(Run);  // Skip opening "
  fRawStringHashes := HashCount;
  fRange := rsRawString;

  // Find closing pattern
  while not IsLineEnd(Run) do
  begin
    if fLine[Run] = '"' then
    begin
      Inc(Run);
      ClosingHashes := 0;
      while (fLine[Run] = '#') and (ClosingHashes < HashCount) do
      begin
        Inc(ClosingHashes);
        Inc(Run);
      end;

      if ClosingHashes = HashCount then
      begin
        fRange := rsUnknown;
        fRawStringHashes := 0;
        Exit;
      end;
    end
    else
      Inc(Run);
  end;
end;

procedure TSynRustSyn.CharProc;
begin
  FTokenID := tkChar;
  Inc(Run);  // Skip opening '

  // Handle escape sequences
  if fLine[Run] = '\' then
  begin
    Inc(Run);
    // \x, \u{}, \n, \t, etc.
    if fLine[Run] = 'u' then
    begin
      Inc(Run);
      if fLine[Run] = '{' then
      begin
        Inc(Run);
        while CharInSet(fLine[Run], ['0'..'9', 'a'..'f', 'A'..'F']) do
          Inc(Run);
        if fLine[Run] = '}' then
          Inc(Run);
      end;
    end
    else if CharInSet(fLine[Run], ['x', 'n', 'r', 't', '\', '''', '"', '0']) then
      Inc(Run);
  end
  else if not IsLineEnd(Run) and (fLine[Run] <> '''') then
    Inc(Run);

  // Skip closing '
  if fLine[Run] = '''' then
    Inc(Run);
end;

procedure TSynRustSyn.SlashProc;
begin
  Inc(Run);

  // Single-line comment //
  if fLine[Run] = '/' then
  begin
    FTokenID := tkComment;
    Inc(Run);
    while not IsLineEnd(Run) do
      Inc(Run);
  end
  // Multi-line comment /*
  else if fLine[Run] = '*' then
  begin
    FTokenID := tkComment;
    Inc(Run);
    fRange := rsMultilineComment;
    MultilineCommentProc;
  end
  else
    FTokenID := tkSymbol;
end;

procedure TSynRustSyn.MultilineCommentProc;
begin
  FTokenID := tkComment;

  while not IsLineEnd(Run) do
  begin
    if (fLine[Run] = '*') and (fLine[Run + 1] = '/') then
    begin
      Inc(Run, 2);
      fRange := rsUnknown;
      Exit;
    end;
    Inc(Run);
  end;
end;

procedure TSynRustSyn.LifetimeProc;
begin
  Inc(Run);  // Skip '

  if not IsIdentChar(fLine[Run]) and (fLine[Run] <> '_') then
  begin
    // Not a lifetime, treat as char literal
    Dec(Run);
    CharProc;
    Exit;
  end;

  FTokenID := tkLifetime;
  while IsIdentChar(fLine[Run]) or (fLine[Run] = '_') do
    Inc(Run);
end;

procedure TSynRustSyn.HashProc;
var
  IsAttribute: Boolean;
begin
  Inc(Run);

  IsAttribute := False;

  // Outer attribute #[...]
  if fLine[Run] = '[' then
    IsAttribute := True
  // Inner attribute #![...]
  else if (fLine[Run] = '!') and (fLine[Run + 1] = '[') then
    IsAttribute := True;

  if IsAttribute then
  begin
    FTokenID := tkAttribute;
    while not IsLineEnd(Run) do
    begin
      if fLine[Run] = ']' then
      begin
        Inc(Run);
        Exit;
      end;
      Inc(Run);
    end;
  end
  else
    FTokenID := tkSymbol;
end;

procedure TSynRustSyn.SymbolProc;
begin
  Inc(Run);
  FTokenID := tkSymbol;
end;

procedure TSynRustSyn.Next;
begin
  fTokenPos := Run;

  case fRange of
    rsMultilineComment:
      MultilineCommentProc;
    rsRawString:
      begin
        // Continue raw string
        FTokenID := tkString;
        while not IsLineEnd(Run) do
        begin
          if fLine[Run] = '"' then
          begin
            Inc(Run);
            // Check for closing hashes
            var ClosingHashes := 0;
            while (fLine[Run] = '#') and (ClosingHashes < fRawStringHashes) do
            begin
              Inc(ClosingHashes);
              Inc(Run);
            end;
            if ClosingHashes = fRawStringHashes then
            begin
              fRange := rsUnknown;
              fRawStringHashes := 0;
              Exit;
            end;
          end
          else
            Inc(Run);
        end;
      end;
  else
    case fLine[Run] of
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
      #1..#9, #11, #12, #14..#32: SpaceProc;
      'A'..'Z', 'a'..'q', 's'..'z', '_': IdentProc;
      '0'..'9': NumberProc;
      '"': StringProc;
      '''': LifetimeProc;
      '/': SlashProc;
      '#': HashProc;
      'r':
        begin
          if fLine[Run + 1] = '#' then
            RawStringProc
          else if fLine[Run + 1] = '"' then
            RawStringProc
          else
            IdentProc;
        end;
      '{', '}', '[', ']', '(', ')', ',', ';', ':', '.', '+', '-', '*', '%',
      '&', '|', '^', '!', '=', '<', '>', '?', '@', '$', '~':
        SymbolProc;
    else
      begin
        Inc(Run);
        FTokenID := tkUnknown;
      end;
    end;
  end;
  inherited;
end;

procedure TSynRustSyn.ScanForFoldRanges(FoldRanges: TSynFoldRanges;
  LinesToScan: TStrings; FromLine, ToLine: Integer);
var
  Line: string;
  LineIndex, I, Len: Integer;
  InString: Boolean;
  InComment: Boolean;
  InBlockComment: Boolean;
  Ch: Char;

  function IsWordAt(const S: string; Pos: Integer; const Word: string): Boolean;
  var
    WordLen: Integer;
  begin
    WordLen := Length(Word);
    Result := (Pos + WordLen - 1 <= Length(S)) and
              (Copy(S, Pos, WordLen) = Word) and
              ((Pos = 1) or not CharInSet(S[Pos - 1], ['a'..'z', 'A'..'Z', '_', '0'..'9'])) and
              ((Pos + WordLen > Length(S)) or not CharInSet(S[Pos + WordLen], ['a'..'z', 'A'..'Z', '_', '0'..'9']));
  end;

begin
  InBlockComment := False;

  for LineIndex := FromLine to ToLine do
  begin
    if LineIndex >= LinesToScan.Count then
      Break;

    Line := LinesToScan[LineIndex];
    Len := Length(Line);
    I := 1;
    InString := False;
    InComment := False;

    // Continue block comment
    if InBlockComment then
    begin
      while I <= Len do
      begin
        if (Line[I] = '*') and (I < Len) and (Line[I + 1] = '/') then
        begin
          FoldRanges.StopFoldRange(LineIndex + 1, RustMultilineCommentFoldType);
          InBlockComment := False;
          Inc(I, 2);
          Break;
        end
        else
          Inc(I);
      end;
      if InBlockComment then
      begin
        FoldRanges.NoFoldInfo(LineIndex + 1);
        Continue;
      end;
    end;

    // Scan line
    while I <= Len do
    begin
      Ch := Line[I];

      // Skip strings
      if not InComment and not InString and (Ch = '"') then
      begin
        Inc(I);
        while (I <= Len) and (Line[I] <> '"') do
        begin
          if Line[I] = '\' then
            Inc(I);
          Inc(I);
        end;
        if I <= Len then
          Inc(I);
        Continue;
      end;

      // Skip line comments
      if not InComment and not InString and (Ch = '/') and (I < Len) and (Line[I + 1] = '/') then
      begin
        Break;
      end;

      // Block comments
      if not InComment and not InString and (Ch = '/') and (I < Len) and (Line[I + 1] = '*') then
      begin
        FoldRanges.StartFoldRange(LineIndex + 1, RustMultilineCommentFoldType);
        InBlockComment := True;
        Inc(I, 2);
        Continue;
      end;

      // Check for block openers
      if not InComment and not InString then
      begin
        // Braces for blocks
        if Ch = '{' then
        begin
          FoldRanges.StartFoldRange(LineIndex + 1, RustFoldRegionType);
          Inc(I);
          Continue;
        end
        else if Ch = '}' then
        begin
          FoldRanges.StopFoldRange(LineIndex + 1, RustFoldRegionType);
          Inc(I);
          Continue;
        end;
      end;

      Inc(I);
    end;
  end;
end;

function TSynRustSyn.GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT: Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD: Result := fKeyAttri;
    SYN_ATTR_STRING: Result := fStringAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
    SYN_ATTR_SYMBOL: Result := fSymbolAttri;
  else
    Result := nil;
  end;
end;

function TSynRustSyn.GetEol: Boolean;
begin
  Result := Run = fLineLen + 1;
end;

function TSynRustSyn.GetTokenID: TtkTokenKind;
begin
  Result := FTokenID;
end;

function TSynRustSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case GetTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkLifetime: Result := fLifetimeAttri;
    tkMacro: Result := fMacroAttri;
    tkAttribute: Result := fAttributeAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkChar: Result := fCharAttri;
    tkSymbol: Result := fSymbolAttri;
    tkType: Result := fTypeAttri;
    tkUnknown: Result := fIdentifierAttri;
  else
    Result := nil;
  end;
end;

function TSynRustSyn.GetTokenKind: Integer;
begin
  Result := Ord(FTokenID);
end;

procedure TSynRustSyn.ResetRange;
begin
  fRange := rsUnknown;
  fRawStringHashes := 0;
end;

procedure TSynRustSyn.SetRange(Value: Pointer);
var
  RangeValue: NativeUInt;
begin
  RangeValue := NativeUInt(Value);
  fRange := TRangeState(RangeValue and $FF);
  fRawStringHashes := (RangeValue shr 8) and $FF;
end;

function TSynRustSyn.GetRange: Pointer;
begin
  Result := Pointer(NativeUInt(Ord(fRange)) or (NativeUInt(fRawStringHashes) shl 8));
end;

function TSynRustSyn.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> 'Rust files (*.rs)|*.rs';
end;

class function TSynRustSyn.GetLanguageName: string;
begin
  Result := 'Rust';
end;

class function TSynRustSyn.GetFriendlyLanguageName: string;
begin
  Result := 'Rust';
end;

function TSynRustSyn.GetSampleSource: string;
begin
  Result :=
    '// Rust 2021 Edition sample code'#13#10 +
    '#[derive(Debug, Clone)]'#13#10 +
    'struct Point<T> {'#13#10 +
    '    x: T,'#13#10 +
    '    y: T,'#13#10 +
    '}'#13#10 +
    #13#10 +
    'impl<T> Point<T> {'#13#10 +
    '    fn new(x: T, y: T) -> Self {'#13#10 +
    '        Self { x, y }'#13#10 +
    '    }'#13#10 +
    '}'#13#10 +
    #13#10 +
    '// Lifetimes example'#13#10 +
    'fn longest<''a>(x: &''a str, y: &''a str) -> &''a str {'#13#10 +
    '    if x.len() > y.len() { x } else { y }'#13#10 +
    '}'#13#10 +
    #13#10 +
    'fn main() {'#13#10 +
    '    let point = Point::new(3, 4);'#13#10 +
    '    '#13#10 +
    '    // Macros'#13#10 +
    '    println!("Point: {:?}", point);'#13#10 +
    '    '#13#10 +
    '    // Raw strings'#13#10 +
    '    let path = r"C:\Windows\System32";'#13#10 +
    '    '#13#10 +
    '    // Pattern matching'#13#10 +
    '    match point.x {'#13#10 +
    '        0 => println!("Origin"),'#13#10 +
    '        _ => println!("Not origin"),'#13#10 +
    '    }'#13#10 +
    '    '#13#10 +
    '    // Async/await'#13#10 +
    '    async fn fetch() -> Result<String, Error> {'#13#10 +
    '        Ok("data".to_string())'#13#10 +
    '    }'#13#10 +
    '}';
end;

initialization
  RegisterPlaceableHighlighter(TSynRustSyn);
end.
