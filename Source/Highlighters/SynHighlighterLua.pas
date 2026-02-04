{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynHighlighterLua.pas, the Initial Author of this file
is Zhou Kan. Adapted for modern Lua 5.4/LuaJIT and Delphi Unicode with
Code Folding support.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net
-------------------------------------------------------------------------------}
{
@abstract(Provides a Lua Script highlighter for SynEdit with Code Folding)
@author(Zhou Kan, updated for Lua 5.4/LuaJIT with Code Folding)
@created(June 2004)
@lastmod(2026-02-04)
Supports Lua 5.1-5.4 and LuaJIT syntax including goto, labels, bitwise operators.
Code Folding for: function, if, for, while, repeat, do blocks and multiline comments.
Includes: Full stdlib, LuaJIT FFI/bit/jit libraries, metamethods, UTF-8 support.
}

unit SynHighlighterLua;

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
    tkFunction,
    tkIdentifier,
    tkKey,
    tkLabel,
    tkNull,
    tkNumber,
    tkOperator,
    tkSpace,
    tkString,
    tkSymbol,
    tkUnknown);

  TRangeState = (rsUnknown, rsMultilineString, rsMultilineComment);

type
  TSynLuaSyn = class(TSynCustomCodeFoldingHighlighter)
  private
    fRange: TRangeState;
    fBracketLevel: Integer;
    FTokenID: TtkTokenKind;
    fCommentAttri: TSynHighlighterAttributes;
    fFunctionAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fLabelAttri: TSynHighlighterAttributes;
    fNumberAttri: TSynHighlighterAttributes;
    fOperatorAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fSymbolAttri: TSynHighlighterAttributes;
    fKeywords: TStringList;
    fFunctions: TStringList;
    procedure NullProc;
    procedure SpaceProc;
    procedure CRProc;
    procedure LFProc;
    procedure IdentProc;
    procedure NumberProc;
    procedure StringProc;
    procedure QuoteStringProc;
    procedure MinusProc;
    procedure SquareOpenProc;
    procedure ColonProc;
    procedure SymbolProc;
    procedure MultilineStringProc;
    procedure MultilineCommentProc;
    function IsLuaKeyword(const AToken: string): Boolean;
    function IsLuaFunction(const AToken: string): Boolean;
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
    property FunctionAttri: TSynHighlighterAttributes read fFunctionAttri write fFunctionAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property LabelAttri: TSynHighlighterAttributes read fLabelAttri write fLabelAttri;
    property NumberAttri: TSynHighlighterAttributes read fNumberAttri write fNumberAttri;
    property OperatorAttri: TSynHighlighterAttributes read fOperatorAttri write fOperatorAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TSynHighlighterAttributes read fSymbolAttri write fSymbolAttri;
  end;

implementation

uses
  SynEditStrConst;

const
  // Lua 5.1-5.4 + LuaJIT keywords
  LuaKeywords: array[0..21] of string = (
    'and', 'break', 'do', 'else', 'elseif', 'end',
    'false', 'for', 'function', 'goto', 'if', 'in',
    'local', 'nil', 'not', 'or', 'repeat', 'return',
    'then', 'true', 'until', 'while'
  );

  // Standard library functions (Lua 5.4 + LuaJIT + Metamethods)
  LuaFunctions: array[0..222] of string = (
    // Basic functions (25)
    'assert', 'collectgarbage', 'dofile', 'error', 'getmetatable',
    'ipairs', 'load', 'loadfile', 'next', 'pairs', 'pcall',
    'print', 'rawequal', 'rawget', 'rawlen', 'rawset', 'require',
    'select', 'setmetatable', 'tonumber', 'tostring', 'type', 'xpcall',
    '_G', '_VERSION',
    // Coroutine (8)
    'coroutine', 'create', 'resume', 'running', 'status', 'wrap', 'yield', 'isyieldable',
    // String (19)
    'string', 'byte', 'char', 'dump', 'find', 'format', 'gmatch',
    'gsub', 'len', 'lower', 'match', 'pack', 'packsize', 'rep', 'reverse',
    'sub', 'unpack', 'upper', 'split',
    // Table (9)
    'table', 'concat', 'insert', 'move', 'pack', 'remove', 'sort', 'unpack', 'foreach',
    // Math (25)
    'math', 'abs', 'acos', 'asin', 'atan', 'atan2', 'ceil', 'cos', 'cosh', 'deg',
    'exp', 'floor', 'fmod', 'frexp', 'huge', 'ldexp', 'log', 'log10', 'max', 'min',
    'modf', 'pi', 'pow', 'rad', 'random', 'randomseed', 'sin', 'sinh', 'sqrt', 'tan', 'tanh',
    // I/O (12)
    'io', 'stdin', 'stdout', 'stderr', 'open', 'close', 'flush', 'input', 'lines',
    'output', 'popen', 'read', 'tmpfile', 'type', 'write',
    // OS (11)
    'os', 'clock', 'date', 'difftime', 'execute', 'exit', 'getenv', 'remove',
    'rename', 'setlocale', 'time', 'tmpname',
    // UTF-8 (Lua 5.3+) (7)
    'utf8', 'char', 'charpattern', 'codes', 'codepoint', 'len', 'offset',
    // Debug library (14)
    'debug', 'debug', 'gethook', 'getinfo', 'getlocal', 'getmetatable', 'getregistry',
    'getupvalue', 'getuservalue', 'sethook', 'setlocal', 'setmetatable', 'setupvalue', 'setuservalue', 'traceback', 'upvalueid', 'upvaluejoin',
    // Package (6)
    'package', 'config', 'cpath', 'loaded', 'path', 'preload', 'searchers',
    // LuaJIT core (5)
    'jit', 'arch', 'flush', 'off', 'on', 'opt', 'os', 'status', 'version', 'version_num',
    // LuaJIT bit library (14)
    'bit', 'arshift', 'band', 'bnot', 'bor', 'bswap', 'bxor', 'lshift', 'rol', 'ror',
    'rshift', 'tobit', 'tohex',
    // LuaJIT FFI library (18)
    'ffi', 'abi', 'alignof', 'arch', 'C', 'cast', 'cdef', 'copy', 'errno', 'fill',
    'gc', 'istype', 'load', 'metatype', 'new', 'offsetof', 'os', 'sizeof', 'string', 'typeof',
    // Metamethods (17)
    '__add', '__sub', '__mul', '__div', '__mod', '__pow', '__unm', '__idiv',
    '__band', '__bor', '__bxor', '__bnot', '__shl', '__shr',
    '__concat', '__len', '__eq', '__lt', '__le',
    '__index', '__newindex', '__call', '__tostring', '__pairs', '__ipairs',
    '__gc', '__close', '__mode', '__name', '__metatable'
  );

  // Fold region types
  LuaFoldRegionType = 1;
  LuaMultilineCommentFoldType = 2;

constructor TSynLuaSyn.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AOwner);

  fCaseSensitive := True;

  // Build keyword list
  fKeywords := TStringList.Create;
  fKeywords.Sorted := True;
  fKeywords.CaseSensitive := True;
  for I := Low(LuaKeywords) to High(LuaKeywords) do
    fKeywords.Add(LuaKeywords[I]);

  // Build function list
  fFunctions := TStringList.Create;
  fFunctions.Sorted := True;
  fFunctions.CaseSensitive := True;
  for I := Low(LuaFunctions) to High(LuaFunctions) do
    fFunctions.Add(LuaFunctions[I]);

  fCommentAttri := TSynHighlighterAttributes.Create(SYNS_AttrComment, SYNS_FriendlyAttrComment);
  fCommentAttri.Foreground := clGreen;
  fCommentAttri.Style := [fsItalic];
  AddAttribute(fCommentAttri);

  fFunctionAttri := TSynHighlighterAttributes.Create(SYNS_AttrFunction, SYNS_FriendlyAttrFunction);
  fFunctionAttri.Foreground := clNavy;
  AddAttribute(fFunctionAttri);

  fIdentifierAttri := TSynHighlighterAttributes.Create(SYNS_AttrIdentifier, SYNS_FriendlyAttrIdentifier);
  AddAttribute(fIdentifierAttri);

  fKeyAttri := TSynHighlighterAttributes.Create(SYNS_AttrReservedWord, SYNS_FriendlyAttrReservedWord);
  fKeyAttri.Foreground := clBlue;
  fKeyAttri.Style := [fsBold];
  AddAttribute(fKeyAttri);

  fLabelAttri := TSynHighlighterAttributes.Create(SYNS_AttrLabel, SYNS_FriendlyAttrLabel);
  fLabelAttri.Foreground := clPurple;
  AddAttribute(fLabelAttri);

  fNumberAttri := TSynHighlighterAttributes.Create(SYNS_AttrNumber, SYNS_FriendlyAttrNumber);
  fNumberAttri.Foreground := clBlue;
  AddAttribute(fNumberAttri);

  fOperatorAttri := TSynHighlighterAttributes.Create(SYNS_AttrOperator, SYNS_FriendlyAttrOperator);
  fOperatorAttri.Foreground := clMaroon;
  AddAttribute(fOperatorAttri);

  fSpaceAttri := TSynHighlighterAttributes.Create(SYNS_AttrSpace, SYNS_FriendlyAttrSpace);
  AddAttribute(fSpaceAttri);

  fStringAttri := TSynHighlighterAttributes.Create(SYNS_AttrString, SYNS_FriendlyAttrString);
  fStringAttri.Foreground := clTeal;
  AddAttribute(fStringAttri);

  fSymbolAttri := TSynHighlighterAttributes.Create(SYNS_AttrSymbol, SYNS_FriendlyAttrSymbol);
  AddAttribute(fSymbolAttri);

  SetAttributesOnChange(DefHighlightChange);
  fDefaultFilter := SYNS_FilterLua;
  fRange := rsUnknown;
  fBracketLevel := 0;
end;

destructor TSynLuaSyn.Destroy;
begin
  fKeywords.Free;
  fFunctions.Free;
  inherited;
end;

function TSynLuaSyn.IsLuaKeyword(const AToken: string): Boolean;
begin
  Result := fKeywords.IndexOf(AToken) >= 0;
end;

function TSynLuaSyn.IsLuaFunction(const AToken: string): Boolean;
begin
  Result := fFunctions.IndexOf(AToken) >= 0;
end;

procedure TSynLuaSyn.SpaceProc;
begin
  FTokenID := tkSpace;
  repeat
    Inc(Run);
  until (fLine[Run] > #32) or IsLineEnd(Run);
end;

procedure TSynLuaSyn.NullProc;
begin
  FTokenID := tkNull;
  Inc(Run);
end;

procedure TSynLuaSyn.CRProc;
begin
  FTokenID := tkSpace;
  Inc(Run);
  if fLine[Run] = #10 then
    Inc(Run);
end;

procedure TSynLuaSyn.LFProc;
begin
  FTokenID := tkSpace;
  Inc(Run);
end;

procedure TSynLuaSyn.IdentProc;
var
  TokenStart: Integer;
  S: string;
begin
  TokenStart := Run;
  while IsIdentChar(fLine[Run]) do
    Inc(Run);

  SetString(S, fLine + TokenStart, Run - TokenStart);

  if IsLuaKeyword(S) then
    FTokenID := tkKey
  else if IsLuaFunction(S) then
    FTokenID := tkFunction
  else
    FTokenID := tkIdentifier;
end;

procedure TSynLuaSyn.NumberProc;
begin
  FTokenID := tkNumber;
  Inc(Run);

  // Check for hex (0x/0X)
  if (fLine[Run - 1] = '0') and CharInSet(fLine[Run], ['x', 'X']) then
  begin
    Inc(Run);
    while CharInSet(fLine[Run], ['0'..'9', 'a'..'f', 'A'..'F', '_', '.', 'p', 'P', '+', '-']) do
      Inc(Run);
    Exit;
  end;

  // Regular number (including floats and exponents)
  while CharInSet(fLine[Run], ['0'..'9', '.', 'e', 'E', '+', '-', '_']) do
  begin
    if (fLine[Run] = '.') and (fLine[Run + 1] = '.') then
      Break;
    if CharInSet(fLine[Run], ['+', '-']) and not CharInSet(fLine[Run - 1], ['e', 'E']) then
      Break;
    Inc(Run);
  end;

  // LL/ULL suffix for LuaJIT
  if CharInSet(fLine[Run], ['L', 'U', 'l', 'u']) then
  begin
    Inc(Run);
    if CharInSet(fLine[Run], ['L', 'l']) then
      Inc(Run);
  end;
end;

procedure TSynLuaSyn.MinusProc;
var
  Level: Integer;
begin
  Inc(Run);
  if fLine[Run] = '-' then
  begin
    Inc(Run);
    // Check for --[=*[ multiline comment
    if fLine[Run] = '[' then
    begin
      Level := 0;
      Inc(Run);
      while fLine[Run] = '=' do
      begin
        Inc(Level);
        Inc(Run);
      end;
      if fLine[Run] = '[' then
      begin
        Inc(Run);
        fBracketLevel := Level;
        fRange := rsMultilineComment;
        FTokenID := tkComment;
        MultilineCommentProc;
        Exit;
      end;
    end;
    // Single line comment
    FTokenID := tkComment;
    while not IsLineEnd(Run) do
      Inc(Run);
  end
  else
    FTokenID := tkOperator;
end;

procedure TSynLuaSyn.MultilineCommentProc;
var
  ClosingLevel: Integer;
begin
  FTokenID := tkComment;
  while not IsLineEnd(Run) do
  begin
    if fLine[Run] = ']' then
    begin
      ClosingLevel := 0;
      Inc(Run);
      while fLine[Run] = '=' do
      begin
        Inc(ClosingLevel);
        Inc(Run);
      end;
      if (fLine[Run] = ']') and (ClosingLevel = fBracketLevel) then
      begin
        Inc(Run);
        fRange := rsUnknown;
        fBracketLevel := 0;
        Exit;
      end;
    end
    else
      Inc(Run);
  end;
end;

procedure TSynLuaSyn.StringProc;
begin
  FTokenID := tkString;
  Inc(Run);
  while not IsLineEnd(Run) do
  begin
    if fLine[Run] = '\' then
    begin
      Inc(Run);
      if not IsLineEnd(Run) then
        Inc(Run);
    end
    else if fLine[Run] = #39 then
    begin
      Inc(Run);
      Exit;
    end
    else
      Inc(Run);
  end;
end;

procedure TSynLuaSyn.QuoteStringProc;
begin
  FTokenID := tkString;
  Inc(Run);
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

procedure TSynLuaSyn.SquareOpenProc;
var
  Level: Integer;
begin
  // Check for [=*[ multiline string
  if fLine[Run + 1] = '[' then
  begin
    Inc(Run, 2);
    fBracketLevel := 0;
    fRange := rsMultilineString;
    FTokenID := tkString;
    MultilineStringProc;
  end
  else if fLine[Run + 1] = '=' then
  begin
    Level := 0;
    Inc(Run);
    while fLine[Run] = '=' do
    begin
      Inc(Level);
      Inc(Run);
    end;
    if fLine[Run] = '[' then
    begin
      Inc(Run);
      fBracketLevel := Level;
      fRange := rsMultilineString;
      FTokenID := tkString;
      MultilineStringProc;
    end
    else
      FTokenID := tkSymbol;
  end
  else
  begin
    Inc(Run);
    FTokenID := tkSymbol;
  end;
end;

procedure TSynLuaSyn.MultilineStringProc;
var
  ClosingLevel: Integer;
begin
  FTokenID := tkString;
  while not IsLineEnd(Run) do
  begin
    if fLine[Run] = ']' then
    begin
      ClosingLevel := 0;
      Inc(Run);
      while fLine[Run] = '=' do
      begin
        Inc(ClosingLevel);
        Inc(Run);
      end;
      if (fLine[Run] = ']') and (ClosingLevel = fBracketLevel) then
      begin
        Inc(Run);
        fRange := rsUnknown;
        fBracketLevel := 0;
        Exit;
      end;
    end
    else
      Inc(Run);
  end;
end;

procedure TSynLuaSyn.ColonProc;
begin
  Inc(Run);
  // Check for ::label::
  if fLine[Run] = ':' then
  begin
    Inc(Run);
    FTokenID := tkLabel;
    while IsIdentChar(fLine[Run]) do
      Inc(Run);
    if (fLine[Run] = ':') and (fLine[Run + 1] = ':') then
      Inc(Run, 2);
  end
  else
    FTokenID := tkSymbol;
end;

procedure TSynLuaSyn.SymbolProc;
begin
  Inc(Run);
  case fLine[Run - 1] of
    '+', '*', '/', '%', '^', '#', '&', '|':
      FTokenID := tkOperator;
    '~':
      begin
        FTokenID := tkOperator;
        if fLine[Run] = '=' then
          Inc(Run);
      end;
    '<', '>':
      begin
        FTokenID := tkOperator;
        if CharInSet(fLine[Run], ['<', '>', '=']) then
          Inc(Run);
      end;
    '=':
      begin
        FTokenID := tkOperator;
        if fLine[Run] = '=' then
          Inc(Run);
      end;
    '.':
      begin
        if fLine[Run] = '.' then
        begin
          Inc(Run);
          if fLine[Run] = '.' then
            Inc(Run);
          FTokenID := tkOperator;
        end
        else
          FTokenID := tkSymbol;
      end;
  else
    FTokenID := tkSymbol;
  end;
end;

procedure TSynLuaSyn.Next;
begin
  fTokenPos := Run;
  case fRange of
    rsMultilineString:
      MultilineStringProc;
    rsMultilineComment:
      MultilineCommentProc;
  else
    case fLine[Run] of
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
      #1..#9, #11, #12, #14..#32: SpaceProc;
      'A'..'Z', 'a'..'z', '_': IdentProc;
      '0'..'9': NumberProc;
      #39: StringProc;
      '"': QuoteStringProc;
      '-': MinusProc;
      '[': SquareOpenProc;
      ':': ColonProc;
      '+', '*', '/', '%', '^', '#', '&', '|', '~', '<', '>', '=', '.':
        SymbolProc;
      '}', '{', ')', '(', ']', ',', ';':
        begin
          Inc(Run);
          FTokenID := tkSymbol;
        end;
    else
      begin
        Inc(Run);
        FTokenID := tkUnknown;
      end;
    end;
  end;
  inherited;
end;

// Code Folding implementation
procedure TSynLuaSyn.ScanForFoldRanges(FoldRanges: TSynFoldRanges;
  LinesToScan: TStrings; FromLine, ToLine: Integer);
var
  Line: string;
  LineIndex: Integer;
  I, Len: Integer;
  InString: Boolean;
  InComment: Boolean;
  InMultilineComment: Boolean;
  InMultilineString: Boolean;
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

  procedure CheckFoldStart(const Keyword: string);
  begin
    if IsWordAt(Line, I, Keyword) then
    begin
      FoldRanges.StartFoldRange(LineIndex + 1, LuaFoldRegionType);
      Inc(I, Length(Keyword));
    end;
  end;

begin
  InMultilineComment := False;
  InMultilineString := False;

  for LineIndex := FromLine to ToLine do
  begin
    if LineIndex >= LinesToScan.Count then
      Break;

    Line := LinesToScan[LineIndex];
    Len := Length(Line);
    I := 1;
    InString := False;
    InComment := False;

    // Continue multiline comment
    if InMultilineComment then
    begin
      while I <= Len do
      begin
        if (Line[I] = ']') then
        begin
          Inc(I);
          while (I <= Len) and (Line[I] = '=') do
            Inc(I);
          if (I <= Len) and (Line[I] = ']') then
          begin
            FoldRanges.StopFoldRange(LineIndex + 1, LuaMultilineCommentFoldType);
            InMultilineComment := False;
            Inc(I);
            Break;
          end;
        end
        else
          Inc(I);
      end;
      if InMultilineComment then
      begin
        FoldRanges.NoFoldInfo(LineIndex + 1);
        Continue;
      end;
    end;

    // Continue multiline string
    if InMultilineString then
    begin
      while I <= Len do
      begin
        if (Line[I] = ']') then
        begin
          Inc(I);
          while (I <= Len) and (Line[I] = '=') do
            Inc(I);
          if (I <= Len) and (Line[I] = ']') then
          begin
            InMultilineString := False;
            Inc(I);
            Break;
          end;
        end
        else
          Inc(I);
      end;
      if InMultilineString then
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
      if not InComment and not InString and ((Ch = '"') or (Ch = #39)) then
      begin
        Inc(I);
        while (I <= Len) and (Line[I] <> Ch) do
        begin
          if Line[I] = '\' then
            Inc(I);
          Inc(I);
        end;
        if I <= Len then
          Inc(I);
        Continue;
      end;

      // Check for multiline string [[ or [=[
      if not InComment and (Ch = '[') and (I < Len) then
      begin
        if Line[I + 1] = '[' then
        begin
          InMultilineString := True;
          Inc(I, 2);
          Continue;
        end
        else if Line[I + 1] = '=' then
        begin
          Inc(I, 2);
          while (I <= Len) and (Line[I] = '=') do
            Inc(I);
          if (I <= Len) and (Line[I] = '[') then
          begin
            InMultilineString := True;
            Inc(I);
            Continue;
          end;
        end;
      end;

      // Check for comment
      if not InComment and (Ch = '-') and (I < Len) and (Line[I + 1] = '-') then
      begin
        // Check for multiline comment --[[ or --[=[
        if (I + 2 <= Len) and (Line[I + 2] = '[') then
        begin
          if (I + 3 <= Len) and (Line[I + 3] = '[') then
          begin
            FoldRanges.StartFoldRange(LineIndex + 1, LuaMultilineCommentFoldType);
            InMultilineComment := True;
            Inc(I, 4);
            Continue;
          end
          else if (I + 3 <= Len) and (Line[I + 3] = '=') then
          begin
            FoldRanges.StartFoldRange(LineIndex + 1, LuaMultilineCommentFoldType);
            InMultilineComment := True;
            Inc(I, 4);
            while (I <= Len) and (Line[I] = '=') do
              Inc(I);
            if (I <= Len) and (Line[I] = '[') then
              Inc(I);
            Continue;
          end;
        end;
        // Single line comment - skip rest of line
        Break;
      end;

      // Check for fold keywords
      if CharInSet(Ch, ['a'..'z']) then
      begin
        // Block openers: function, if, for, while, repeat, do
        if IsWordAt(Line, I, 'function') then
        begin
          FoldRanges.StartFoldRange(LineIndex + 1, LuaFoldRegionType);
          Inc(I, 8);
          Continue;
        end
        else if IsWordAt(Line, I, 'if') then
        begin
          // Check it's not "elseif"
          if (I = 1) or not CharInSet(Line[I - 1], ['a'..'z', 'A'..'Z', '_']) then
          begin
            FoldRanges.StartFoldRange(LineIndex + 1, LuaFoldRegionType);
            Inc(I, 2);
            Continue;
          end;
        end
        else if IsWordAt(Line, I, 'for') then
        begin
          FoldRanges.StartFoldRange(LineIndex + 1, LuaFoldRegionType);
          Inc(I, 3);
          Continue;
        end
        else if IsWordAt(Line, I, 'while') then
        begin
          FoldRanges.StartFoldRange(LineIndex + 1, LuaFoldRegionType);
          Inc(I, 5);
          Continue;
        end
        else if IsWordAt(Line, I, 'repeat') then
        begin
          FoldRanges.StartFoldRange(LineIndex + 1, LuaFoldRegionType);
          Inc(I, 6);
          Continue;
        end
        else if IsWordAt(Line, I, 'do') then
        begin
          // Standalone do block (not part of for/while)
          FoldRanges.StartFoldRange(LineIndex + 1, LuaFoldRegionType);
          Inc(I, 2);
          Continue;
        end
        // Block closers: end, until
        else if IsWordAt(Line, I, 'end') then
        begin
          FoldRanges.StopFoldRange(LineIndex + 1, LuaFoldRegionType);
          Inc(I, 3);
          Continue;
        end
        else if IsWordAt(Line, I, 'until') then
        begin
          FoldRanges.StopFoldRange(LineIndex + 1, LuaFoldRegionType);
          Inc(I, 5);
          Continue;
        end;
      end;

      Inc(I);
    end;
  end;
end;

function TSynLuaSyn.GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes;
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

function TSynLuaSyn.GetEol: Boolean;
begin
  Result := Run = fLineLen + 1;
end;

function TSynLuaSyn.GetTokenID: TtkTokenKind;
begin
  Result := FTokenID;
end;

function TSynLuaSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case GetTokenID of
    tkComment: Result := fCommentAttri;
    tkFunction: Result := fFunctionAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkLabel: Result := fLabelAttri;
    tkNumber: Result := fNumberAttri;
    tkOperator: Result := fOperatorAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fIdentifierAttri;
  else
    Result := nil;
  end;
end;

function TSynLuaSyn.GetTokenKind: Integer;
begin
  Result := Ord(FTokenID);
end;

procedure TSynLuaSyn.ResetRange;
begin
  fRange := rsUnknown;
  fBracketLevel := 0;
end;

procedure TSynLuaSyn.SetRange(Value: Pointer);
var
  RangeValue: NativeUInt;
begin
  RangeValue := NativeUInt(Value);
  fRange := TRangeState(RangeValue and $FF);
  fBracketLevel := (RangeValue shr 8) and $FF;
end;

function TSynLuaSyn.GetRange: Pointer;
begin
  Result := Pointer(NativeUInt(Ord(fRange)) or (NativeUInt(fBracketLevel) shl 8));
end;

function TSynLuaSyn.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterLua;
end;

class function TSynLuaSyn.GetLanguageName: string;
begin
  Result := SYNS_LangLua;
end;

class function TSynLuaSyn.GetFriendlyLanguageName: string;
begin
  Result := SYNS_FriendlyLangLua;
end;

function TSynLuaSyn.GetSampleSource: string;
begin
  Result :=
    '-- Lua 5.4 / LuaJIT sample code'#13#10 +
    'local ffi = require("ffi")'#13#10 +
    'local bit = require("bit")'#13#10 +
    #13#10 +
    '-- Metamethods example'#13#10 +
    'local Vector = {}'#13#10 +
    'Vector.__index = Vector'#13#10 +
    'function Vector.__add(a, b)'#13#10 +
    '  return Vector.new(a.x + b.x, a.y + b.y)'#13#10 +
    'end'#13#10 +
    #13#10 +
    'function Vector.new(x, y)'#13#10 +
    '  return setmetatable({x = x, y = y}, Vector)'#13#10 +
    'end'#13#10 +
    #13#10 +
    '-- LuaJIT FFI example'#13#10 +
    'ffi.cdef[['#13#10 +
    '  int printf(const char *fmt, ...);'#13#10 +
    ']]'#13#10 +
    #13#10 +
    'local function factorial(n)'#13#10 +
    '  if n <= 1 then return 1 end'#13#10 +
    '  return n * factorial(n - 1)'#13#10 +
    'end'#13#10 +
    #13#10 +
    'for i = 1, 10 do'#13#10 +
    '  local result = factorial(i)'#13#10 +
    '  -- Bitwise operations (LuaJIT)'#13#10 +
    '  local bits = bit.bor(i, 0x10)'#13#10 +
    '  print(result, bits)'#13#10 +
    'end'#13#10 +
    #13#10 +
    '-- UTF-8 support'#13#10 +
    'local text = "Привет мир"'#13#10 +
    'print(utf8.len(text))'#13#10 +
    #13#10 +
    '--[=['#13#10 +
    '  Multiline comment'#13#10 +
    '  can be folded!'#13#10 +
    ']=]';
end;

initialization
  RegisterPlaceableHighlighter(TSynLuaSyn);
end.
