{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
-------------------------------------------------------------------------------}
{
  SynEditXOpt - Extended Options for SynEdit
  ==========================================
  Extended input options for SynEdit component:

  1. KEYBOARD LAYOUT - Auto switch keyboard layout on editor Enter/Exit
  2. CHARACTER FILTER - Allow only specified characters + case conversion
  3. INPUT LIMITS - Max line length (chars/bytes) and max lines
}
unit SynEditXOpt;

{$I SynEdit.inc}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes;

{$HPPEMIT '#include <winuser.h>'}
{$NODEFINE cKLF_SETFORPROCESS}

const
  cKLF_SETFORPROCESS = $00000100;

type
  { Case conversion mode }
  TSynXOptCharCase = (
    ccMixed,      // No conversion - as typed
    ccUpperCase,  // Convert all to UPPER CASE
    ccLowerCase   // Convert all to lower case
  );

  { Input mode presets }
  TSynXOptInputMode = (
    imAny,        // Any characters allowed
    imNumeric,    // Only 0-9 and - . ,
    imHex,        // Only 0-9 A-F a-f
    imAlpha,      // Only letters A-Z a-z
    imAlphaNum,   // Letters and numbers
    imCustom      // Use AllowedChars
  );

  { Length count mode }
  TSynXOptLengthMode = (
    lmChars,      // Count characters (Unicode-aware)
    lmBytes       // Count bytes (UTF-8 encoded length)
  );

  TSynXOptChangeEvent = procedure(Sender: TObject) of object;

  { Menu items }
  TSynXOptMenuItem = (
    smiUndo,         // Undo
    smiRedo,         // Redo
    smiSep1,         // Separator 1
    smiCut,          // Cut
    smiCopy,         // Copy
    smiPaste,        // Paste
    smiDelete,       // Delete
    smiSep2,         // Separator 2
    smiSelectAll,    // Select All
    smiSelectWord,   // Select Word
    smiSep3,         // Separator 3
    smiDeleteLine,   // Delete Line
    smiSep4,         // Separator 4
    smiIndent,       // Indent
    smiUnindent,     // Unindent
    smiSep5,         // Separator 5
    smiUppercase,    // UPPERCASE
    smiLowercase,    // lowercase
    smiSep6,         // Separator 6
    smiGotoLine,     // Go to Line
    smiSep7,         // Separator 7
    smiFind,         // Find
    smiReplace       // Replace
  );
  TSynXOptMenuItems = set of TSynXOptMenuItem;

const
  DefaultMenuItems = [smiUndo, smiRedo, smiSep1, smiCut, smiCopy, smiPaste,
                      smiDelete, smiSep2, smiSelectAll];

type
  TSynXOptMenuEvent = procedure(Sender: TObject) of object;

  { TSynXOptMenu - System context menu options }
  TSynXOptMenu = class(TPersistent)
  private
    FUseSystemMenu: Boolean;
    FVisibleItems: TSynXOptMenuItems;
    FOnChange: TSynXOptChangeEvent;
    FOnFind: TSynXOptMenuEvent;
    FOnReplace: TSynXOptMenuEvent;
    FOnGotoLine: TSynXOptMenuEvent;
    procedure SetUseSystemMenu(const Value: Boolean);
    procedure SetVisibleItems(const Value: TSynXOptMenuItems);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TSynXOptChangeEvent read FOnChange write FOnChange;
    property OnFind: TSynXOptMenuEvent read FOnFind write FOnFind;
    property OnReplace: TSynXOptMenuEvent read FOnReplace write FOnReplace;
    property OnGotoLine: TSynXOptMenuEvent read FOnGotoLine write FOnGotoLine;
  published
    { Enable system context menu (only when PopupMenu property is nil) }
    property UseSystemMenu: Boolean read FUseSystemMenu write SetUseSystemMenu default True;
    { Visible menu items }
    property VisibleItems: TSynXOptMenuItems read FVisibleItems write SetVisibleItems;
  end;

  { TSynXOptKeyboard - Keyboard layout options }
  TSynXOptKeyboard = class(TPersistent)
  private
    FEnabled: Boolean;
    FLang: string;
    FPrevLayoutHandle: HKL;
    FHasPrevLayout: Boolean;
    FOnChange: TSynXOptChangeEvent;
    procedure SetEnabled(const Value: Boolean);
    procedure SetLang(const Value: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure HandleEnter;
    procedure HandleExit;
    property OnChange: TSynXOptChangeEvent read FOnChange write FOnChange;
  published
    { Enable auto keyboard layout switching }
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    { Target language/keyboard layout (e.g., '00000409' for English US, '00000419' for Russian) }
    property Lang: string read FLang write SetLang;
  end;

  { TSynXOptCharFilter - Character filtering options }
  TSynXOptCharFilter = class(TPersistent)
  private
    FEnabled: Boolean;
    FInputMode: TSynXOptInputMode;
    FAllowedChars: string;
    FCharCase: TSynXOptCharCase;
    FOnChange: TSynXOptChangeEvent;
    procedure SetEnabled(const Value: Boolean);
    procedure SetInputMode(const Value: TSynXOptInputMode);
    procedure SetAllowedChars(const Value: string);
    procedure SetCharCase(const Value: TSynXOptCharCase);
    function GetEffectiveAllowedChars: string;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    function ProcessChar(AChar: WideChar): WideChar;
    property OnChange: TSynXOptChangeEvent read FOnChange write FOnChange;
  published
    { Enable character filtering }
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    { Predefined input mode }
    property InputMode: TSynXOptInputMode read FInputMode write SetInputMode default imAny;
    { Custom allowed characters (used when InputMode = imCustom) }
    property AllowedChars: string read FAllowedChars write SetAllowedChars;
    { Character case conversion }
    property CharCase: TSynXOptCharCase read FCharCase write SetCharCase default ccMixed;
  end;

  { TSynXOptLimits - Input limits }
  TSynXOptLimits = class(TPersistent)
  private
    FEnabled: Boolean;
    FMaxLineLength: Integer;
    FMaxLines: Integer;
    FLengthMode: TSynXOptLengthMode;
    FOnChange: TSynXOptChangeEvent;
    procedure SetEnabled(const Value: Boolean);
    procedure SetMaxLineLength(const Value: Integer);
    procedure SetMaxLines(const Value: Integer);
    procedure SetLengthMode(const Value: TSynXOptLengthMode);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    { Check if can add char to line }
    function CanAddChar(const CurrentLine: string): Boolean;
    { Check if can add more lines }
    function CanAddLine(CurrentLineCount: Integer): Boolean;
    { Get current line length based on LengthMode }
    function GetLineLength(const Line: string): Integer;
    property OnChange: TSynXOptChangeEvent read FOnChange write FOnChange;
  published
    { Enable limits checking (auto-enabled by default for safety) }
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    { Maximum characters/bytes per line (65535 = safe default, 0 = unlimited at user's risk) }
    property MaxLineLength: Integer read FMaxLineLength write SetMaxLineLength default 65535;
    { Maximum number of lines (2000000 = safe for any scenario, 0 = unlimited at user's risk) }
    property MaxLines: Integer read FMaxLines write SetMaxLines default 2000000;
    { How to count length: characters or bytes }
    property LengthMode: TSynXOptLengthMode read FLengthMode write SetLengthMode default lmChars;
  end;

  { TSynXOpt - Main extended options class }
  TSynXOpt = class(TPersistent)
  private
    FMenu: TSynXOptMenu;
    FKeyboard: TSynXOptKeyboard;
    FCharFilter: TSynXOptCharFilter;
    FLimits: TSynXOptLimits;
    FOnChange: TSynXOptChangeEvent;
    procedure SetMenu(const Value: TSynXOptMenu);
    procedure SetKeyboard(const Value: TSynXOptKeyboard);
    procedure SetCharFilter(const Value: TSynXOptCharFilter);
    procedure SetLimits(const Value: TSynXOptLimits);
    procedure SubItemChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure HandleEditorEnter;
    procedure HandleEditorExit;
    function ProcessChar(AChar: WideChar): WideChar;
    function CanAddChar(const CurrentLine: string): Boolean;
    function CanAddLine(CurrentLineCount: Integer): Boolean;
    class procedure GetInstalledLayouts(AList: TStrings);
    property OnChange: TSynXOptChangeEvent read FOnChange write FOnChange;
  published
    property Menu: TSynXOptMenu read FMenu write SetMenu;
    property Keyboard: TSynXOptKeyboard read FKeyboard write SetKeyboard;
    property CharFilter: TSynXOptCharFilter read FCharFilter write SetCharFilter;
    property Limits: TSynXOptLimits read FLimits write SetLimits;
  end;

implementation

const
  MAX_LOCALE_NAME = 85;
  CHARS_NUMERIC   = '0123456789-.,';
  CHARS_HEX       = '0123456789ABCDEFabcdef';
  CHARS_ALPHA     = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  CHARS_ALPHANUM  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

function CharToUpper(C: WideChar): WideChar; inline;
begin
  Result := C;
  if (C >= 'a') and (C <= 'z') then
    Result := WideChar(Ord(C) - 32);
end;

function CharToLower(C: WideChar): WideChar; inline;
begin
  Result := C;
  if (C >= 'A') and (C <= 'Z') then
    Result := WideChar(Ord(C) + 32);
end;

{ TSynXOptMenu }

constructor TSynXOptMenu.Create;
begin
  inherited Create;
  FUseSystemMenu := True;
  FVisibleItems := DefaultMenuItems;
end;

procedure TSynXOptMenu.Assign(Source: TPersistent);
begin
  if Source is TSynXOptMenu then
  begin
    FUseSystemMenu := TSynXOptMenu(Source).FUseSystemMenu;
    FVisibleItems := TSynXOptMenu(Source).FVisibleItems;
    if Assigned(FOnChange) then FOnChange(Self);
  end
  else
    inherited Assign(Source);
end;

procedure TSynXOptMenu.SetUseSystemMenu(const Value: Boolean);
begin
  if FUseSystemMenu <> Value then
  begin
    FUseSystemMenu := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptMenu.SetVisibleItems(const Value: TSynXOptMenuItems);
begin
  if FVisibleItems <> Value then
  begin
    FVisibleItems := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

{ TSynXOptKeyboard }

constructor TSynXOptKeyboard.Create;
begin
  inherited Create;
  FEnabled := False;
  FLang := '';
  FPrevLayoutHandle := 0;
  FHasPrevLayout := False;
end;

procedure TSynXOptKeyboard.Assign(Source: TPersistent);
begin
  if Source is TSynXOptKeyboard then
  begin
    FEnabled := TSynXOptKeyboard(Source).FEnabled;
    FLang := TSynXOptKeyboard(Source).FLang;
    if Assigned(FOnChange) then FOnChange(Self);
  end
  else
    inherited Assign(Source);
end;

procedure TSynXOptKeyboard.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptKeyboard.SetLang(const Value: string);
begin
  if FLang <> Value then
  begin
    FLang := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptKeyboard.HandleEnter;
var
  CurrentLayout, TargetLayout: HKL;
begin
  if not FEnabled or (FLang = '') then
    Exit;

  CurrentLayout := GetKeyboardLayout(0);
  FPrevLayoutHandle := CurrentLayout;
  FHasPrevLayout := True;

  TargetLayout := LoadKeyboardLayout(PChar(FLang), KLF_NOTELLSHELL or KLF_SUBSTITUTE_OK);
  if TargetLayout <> 0 then
    ActivateKeyboardLayout(TargetLayout, cKLF_SETFORPROCESS);
end;

procedure TSynXOptKeyboard.HandleExit;
begin
  if not FEnabled then
    Exit;

  if FHasPrevLayout and (FPrevLayoutHandle <> 0) then
    ActivateKeyboardLayout(FPrevLayoutHandle, cKLF_SETFORPROCESS);
  FHasPrevLayout := False;
end;

{ TSynXOptCharFilter }

constructor TSynXOptCharFilter.Create;
begin
  inherited Create;
  FEnabled := False;
  FInputMode := imAny;
  FAllowedChars := '';
  FCharCase := ccMixed;
end;

procedure TSynXOptCharFilter.Assign(Source: TPersistent);
begin
  if Source is TSynXOptCharFilter then
  begin
    FEnabled := TSynXOptCharFilter(Source).FEnabled;
    FInputMode := TSynXOptCharFilter(Source).FInputMode;
    FAllowedChars := TSynXOptCharFilter(Source).FAllowedChars;
    FCharCase := TSynXOptCharFilter(Source).FCharCase;
    if Assigned(FOnChange) then FOnChange(Self);
  end
  else
    inherited Assign(Source);
end;

procedure TSynXOptCharFilter.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptCharFilter.SetInputMode(const Value: TSynXOptInputMode);
begin
  if FInputMode <> Value then
  begin
    FInputMode := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptCharFilter.SetAllowedChars(const Value: string);
begin
  if FAllowedChars <> Value then
  begin
    FAllowedChars := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptCharFilter.SetCharCase(const Value: TSynXOptCharCase);
begin
  if FCharCase <> Value then
  begin
    FCharCase := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

function TSynXOptCharFilter.GetEffectiveAllowedChars: string;
begin
  // If AllowedChars is set, use it regardless of InputMode
  if FAllowedChars <> '' then
  begin
    Result := FAllowedChars;
    Exit;
  end;

  // Otherwise use predefined mode
  case FInputMode of
    imNumeric:  Result := CHARS_NUMERIC;
    imHex:      Result := CHARS_HEX;
    imAlpha:    Result := CHARS_ALPHA;
    imAlphaNum: Result := CHARS_ALPHANUM;
    imCustom:   Result := '';  // Custom without chars = no filtering
  else
    Result := '';  // imAny = no filtering
  end;
end;

function TSynXOptCharFilter.ProcessChar(AChar: WideChar): WideChar;
var
  AllowedSet: string;
begin
  Result := AChar;

  // Apply case conversion first (always, even if filter disabled)
  case FCharCase of
    ccUpperCase: Result := CharToUpper(Result);
    ccLowerCase: Result := CharToLower(Result);
  end;

  // Check filter if enabled
  if not FEnabled then
    Exit;

  // Get allowed character set based on mode
  AllowedSet := GetEffectiveAllowedChars;

  // If AllowedSet is empty (imAny or imCustom with no chars), allow everything
  if AllowedSet = '' then
    Exit;

  // Check if character is in allowed set
  if Pos(Result, AllowedSet) = 0 then
  begin
    // For hex mode, also check uppercase version
    if (FInputMode = imHex) and (Pos(CharToUpper(Result), AllowedSet) > 0) then
      Exit;

    // Character not allowed
    Result := #0;
  end;
end;

{ TSynXOptLimits }

constructor TSynXOptLimits.Create;
begin
  inherited Create;
  FEnabled := True;              // Auto-enabled for safety
  FMaxLineLength := 1000000;       // Max line length (safe limit)
  FMaxLines := 2000000;          // 2 million lines (safe for any scenario)
  FLengthMode := lmChars;
end;

procedure TSynXOptLimits.Assign(Source: TPersistent);
begin
  if Source is TSynXOptLimits then
  begin
    FEnabled := TSynXOptLimits(Source).FEnabled;
    FMaxLineLength := TSynXOptLimits(Source).FMaxLineLength;
    FMaxLines := TSynXOptLimits(Source).FMaxLines;
    FLengthMode := TSynXOptLimits(Source).FLengthMode;
    if Assigned(FOnChange) then FOnChange(Self);
  end
  else
    inherited Assign(Source);
end;

procedure TSynXOptLimits.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptLimits.SetMaxLineLength(const Value: Integer);
begin
  if FMaxLineLength <> Value then
  begin
    if Value < 0 then
      FMaxLineLength := 0
    else
      FMaxLineLength := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptLimits.SetMaxLines(const Value: Integer);
begin
  if FMaxLines <> Value then
  begin
    if Value < 0 then
      FMaxLines := 0
    else
      FMaxLines := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSynXOptLimits.SetLengthMode(const Value: TSynXOptLengthMode);
begin
  if FLengthMode <> Value then
  begin
    FLengthMode := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

function TSynXOptLimits.GetLineLength(const Line: string): Integer;
begin
  case FLengthMode of
    lmChars:
      Result := Length(Line);
    lmBytes:
      Result := TEncoding.UTF8.GetByteCount(Line);
  else
    Result := Length(Line);
  end;
end;

function TSynXOptLimits.CanAddChar(const CurrentLine: string): Boolean;
begin
  if not FEnabled or (FMaxLineLength = 0) then
    Result := True
  else
    Result := GetLineLength(CurrentLine) < FMaxLineLength;
end;

function TSynXOptLimits.CanAddLine(CurrentLineCount: Integer): Boolean;
begin
  if not FEnabled or (FMaxLines = 0) then
    Result := True
  else
    Result := CurrentLineCount < FMaxLines;
end;

{ TSynXOpt }

constructor TSynXOpt.Create;
begin
  inherited Create;
  FMenu := TSynXOptMenu.Create;
  FMenu.OnChange := SubItemChanged;
  FKeyboard := TSynXOptKeyboard.Create;
  FKeyboard.OnChange := SubItemChanged;
  FCharFilter := TSynXOptCharFilter.Create;
  FCharFilter.OnChange := SubItemChanged;
  FLimits := TSynXOptLimits.Create;
  FLimits.OnChange := SubItemChanged;
end;

destructor TSynXOpt.Destroy;
begin
  FMenu.Free;
  FKeyboard.Free;
  FCharFilter.Free;
  FLimits.Free;
  inherited Destroy;
end;

procedure TSynXOpt.Assign(Source: TPersistent);
begin
  if Source is TSynXOpt then
  begin
    FMenu.Assign(TSynXOpt(Source).FMenu);
    FKeyboard.Assign(TSynXOpt(Source).FKeyboard);
    FCharFilter.Assign(TSynXOpt(Source).FCharFilter);
    FLimits.Assign(TSynXOpt(Source).FLimits);
  end
  else
    inherited Assign(Source);
end;

procedure TSynXOpt.SubItemChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TSynXOpt.SetMenu(const Value: TSynXOptMenu);
begin
  FMenu.Assign(Value);
end;

procedure TSynXOpt.SetKeyboard(const Value: TSynXOptKeyboard);
begin
  FKeyboard.Assign(Value);
end;

procedure TSynXOpt.SetCharFilter(const Value: TSynXOptCharFilter);
begin
  FCharFilter.Assign(Value);
end;

procedure TSynXOpt.SetLimits(const Value: TSynXOptLimits);
begin
  FLimits.Assign(Value);
end;

procedure TSynXOpt.HandleEditorEnter;
begin
  FKeyboard.HandleEnter;
end;

procedure TSynXOpt.HandleEditorExit;
begin
  FKeyboard.HandleExit;
end;

function TSynXOpt.ProcessChar(AChar: WideChar): WideChar;
begin
  Result := FCharFilter.ProcessChar(AChar);
end;

function TSynXOpt.CanAddChar(const CurrentLine: string): Boolean;
begin
  Result := FLimits.CanAddChar(CurrentLine);
end;

function TSynXOpt.CanAddLine(CurrentLineCount: Integer): Boolean;
begin
  Result := FLimits.CanAddLine(CurrentLineCount);
end;

class procedure TSynXOpt.GetInstalledLayouts(AList: TStrings);
var
  LayoutList: array[0..63] of HKL;
  LayoutCount, I: Integer;
  NativeName: array[0..MAX_LOCALE_NAME] of Char;
  LangId: Word;
  DisplayName, LayoutIdStr: string;
begin
  AList.Clear;
  LayoutCount := GetKeyboardLayoutList(Length(LayoutList), LayoutList);

  for I := 0 to LayoutCount - 1 do
  begin
    LangId := LoWord(NativeUInt(LayoutList[I]));
    LayoutIdStr := Format('%.8x', [NativeUInt(LayoutList[I]) and $0000FFFF]);

    // Get native language name (how language writes itself)
    if GetLocaleInfo(LangId, LOCALE_SNATIVELANGNAME, NativeName, Length(NativeName)) > 0 then
      DisplayName := string(NativeName)
    else
      DisplayName := Format('Layout %d', [I]);

    // Format: "English (00000409)" or "Русский (00000419)"
    AList.AddObject(Format('%s (%s)=%s', [DisplayName, LayoutIdStr, LayoutIdStr]), TObject(NativeInt(LayoutList[I])));
  end;
end;

end.
