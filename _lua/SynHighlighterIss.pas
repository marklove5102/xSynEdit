{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynHighlighterIss.pas, the Initial
Author of this file is Zhou Kan.
All Rights Reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynHighlighterIss.pas,v 1.00 2005/01/24 17:58:27 Kan Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}
{
@abstract(Provides a InstallShield Script highlighter for SynEdit)
@author(Zhou Kan [textrush@tom.com])
@created(June 2004)
@lastmod(2005-01-24)
The SynHighlighterIss unit provides SynEdit with a InstallShield Script (*.rul) highlighter.
The highlighter formats InstallShield Script source code highlighting keywords, strings, numbers and characters.
}

unit SynHighlighterIss;


interface

uses
  SysUtils, Classes, Graphics, SynEditHighlighter, SynEditTypes, SynEditStrConst;

type
  TtkTokenKind = (
    tkComment,
    tkDefinition,
    tkDirective,
    tkFunction,
    tkIdentifier,
    tkKey,
    tkNull,
    tkNumber,
    tkSpace,
    tkString,
    tkSymbol,
    tkUnknown);

  TRangeState = (rsUnKnown, rsAnsiC, rsComment, rsMultiComment, rsDirective,
    rsDirectiveComment, rsMultiLineDirective, rsString, rsQuoteString,
    rsMultilineString);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function: TtkTokenKind of object;

const
  MaxKey = 366;

type

  { TSynIssSyn }

  TSynIssSyn = class(TSynCustomHighlighter)
  private
    fLineRef: string;
    fLine: PChar;
    fLineNumber: Integer;
    fProcTable: array[#0..#255] of TProcTableProc;
    fRange: TRangeState;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fTokenPos: Integer;
    fTokenID: TtkTokenKind;
    fIdentFuncTable: array[0 .. MaxKey] of TIdentFuncTableFunc;
    fCommentAttri: TSynHighlighterAttributes;
    fDefinitionAttri: TSynHighlighterAttributes;
    fDirectiveAttri: TSynHighlighterAttributes;
    fFunctionAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fNumberAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fSymbolAttri: TSynHighlighterAttributes;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: string): Boolean;
    function Func17: TtkTokenKind;
    function Func20: TtkTokenKind;
    function Func26: TtkTokenKind;
    function Func27: TtkTokenKind;
    function Func28: TtkTokenKind;
    function Func29: TtkTokenKind;
    function Func30: TtkTokenKind;
    function Func32: TtkTokenKind;
    function Func33: TtkTokenKind;
    function Func34: TtkTokenKind;
    function Func37: TtkTokenKind;
    function Func38: TtkTokenKind;
    function Func39: TtkTokenKind;
    function Func40: TtkTokenKind;
    function Func41: TtkTokenKind;
    function Func42: TtkTokenKind;
    function Func43: TtkTokenKind;
    function Func44: TtkTokenKind;
    function Func45: TtkTokenKind;
    function Func46: TtkTokenKind;
    function Func47: TtkTokenKind;
    function Func48: TtkTokenKind;
    function Func49: TtkTokenKind;
    function Func50: TtkTokenKind;
    function Func51: TtkTokenKind;
    function Func52: TtkTokenKind;
    function Func53: TtkTokenKind;
    function Func54: TtkTokenKind;
    function Func55: TtkTokenKind;
    function Func56: TtkTokenKind;
    function Func58: TtkTokenKind;
    function Func59: TtkTokenKind;
    function Func60: TtkTokenKind;
    function Func61: TtkTokenKind;
    function Func62: TtkTokenKind;
    function Func63: TtkTokenKind;
    function Func64: TtkTokenKind;
    function Func65: TtkTokenKind;
    function Func66: TtkTokenKind;
    function Func67: TtkTokenKind;
    function Func68: TtkTokenKind;
    function Func69: TtkTokenKind;
    function Func70: TtkTokenKind;
    function Func71: TtkTokenKind;
    function Func73: TtkTokenKind;
    function Func74: TtkTokenKind;
    function Func75: TtkTokenKind;
    function Func76: TtkTokenKind;
    function Func77: TtkTokenKind;
    function Func78: TtkTokenKind;
    function Func79: TtkTokenKind;
    function Func80: TtkTokenKind;
    function Func81: TtkTokenKind;
    function Func82: TtkTokenKind;
    function Func84: TtkTokenKind;
    function Func85: TtkTokenKind;
    function Func86: TtkTokenKind;
    function Func87: TtkTokenKind;
    function Func88: TtkTokenKind;
    function Func89: TtkTokenKind;
    function Func90: TtkTokenKind;
    function Func91: TtkTokenKind;
    function Func92: TtkTokenKind;
    function Func93: TtkTokenKind;
    function Func94: TtkTokenKind;
    function Func95: TtkTokenKind;
    function Func96: TtkTokenKind;
    function Func97: TtkTokenKind;
    function Func98: TtkTokenKind;
    function Func99: TtkTokenKind;
    function Func100: TtkTokenKind;
    function Func101: TtkTokenKind;
    function Func102: TtkTokenKind;
    function Func103: TtkTokenKind;
    function Func104: TtkTokenKind;
    function Func105: TtkTokenKind;
    function Func106: TtkTokenKind;
    function Func107: TtkTokenKind;
    function Func108: TtkTokenKind;
    function Func109: TtkTokenKind;
    function Func110: TtkTokenKind;
    function Func111: TtkTokenKind;
    function Func112: TtkTokenKind;
    function Func113: TtkTokenKind;
    function Func114: TtkTokenKind;
    function Func115: TtkTokenKind;
    function Func116: TtkTokenKind;
    function Func117: TtkTokenKind;
    function Func118: TtkTokenKind;
    function Func119: TtkTokenKind;
    function Func120: TtkTokenKind;
    function Func121: TtkTokenKind;
    function Func122: TtkTokenKind;
    function Func123: TtkTokenKind;
    function Func124: TtkTokenKind;
    function Func125: TtkTokenKind;
    function Func126: TtkTokenKind;
    function Func127: TtkTokenKind;
    function Func128: TtkTokenKind;
    function Func129: TtkTokenKind;
    function Func130: TtkTokenKind;
    function Func131: TtkTokenKind;
    function Func132: TtkTokenKind;
    function Func133: TtkTokenKind;
    function Func134: TtkTokenKind;
    function Func135: TtkTokenKind;
    function Func136: TtkTokenKind;
    function Func137: TtkTokenKind;
    function Func138: TtkTokenKind;
    function Func139: TtkTokenKind;
    function Func140: TtkTokenKind;
    function Func141: TtkTokenKind;
    function Func142: TtkTokenKind;
    function Func143: TtkTokenKind;
    function Func144: TtkTokenKind;
    function Func145: TtkTokenKind;
    function Func146: TtkTokenKind;
    function Func147: TtkTokenKind;
    function Func148: TtkTokenKind;
    function Func149: TtkTokenKind;
    function Func150: TtkTokenKind;
    function Func151: TtkTokenKind;
    function Func152: TtkTokenKind;
    function Func153: TtkTokenKind;
    function Func154: TtkTokenKind;
    function Func155: TtkTokenKind;
    function Func156: TtkTokenKind;
    function Func157: TtkTokenKind;
    function Func158: TtkTokenKind;
    function Func159: TtkTokenKind;
    function Func160: TtkTokenKind;
    function Func161: TtkTokenKind;
    function Func162: TtkTokenKind;
    function Func163: TtkTokenKind;
    function Func164: TtkTokenKind;
    function Func165: TtkTokenKind;
    function Func166: TtkTokenKind;
    function Func167: TtkTokenKind;
    function Func168: TtkTokenKind;
    function Func169: TtkTokenKind;
    function Func170: TtkTokenKind;
    function Func171: TtkTokenKind;
    function Func172: TtkTokenKind;
    function Func173: TtkTokenKind;
    function Func174: TtkTokenKind;
    function Func175: TtkTokenKind;
    function Func176: TtkTokenKind;
    function Func177: TtkTokenKind;
    function Func178: TtkTokenKind;
    function Func181: TtkTokenKind;
    function Func182: TtkTokenKind;
    function Func183: TtkTokenKind;
    function Func184: TtkTokenKind;
    function Func185: TtkTokenKind;
    function Func186: TtkTokenKind;
    function Func187: TtkTokenKind;
    function Func188: TtkTokenKind;
    function Func189: TtkTokenKind;
    function Func190: TtkTokenKind;
    function Func191: TtkTokenKind;
    function Func192: TtkTokenKind;
    function Func193: TtkTokenKind;
    function Func194: TtkTokenKind;
    function Func195: TtkTokenKind;
    function Func196: TtkTokenKind;
    function Func197: TtkTokenKind;
    function Func198: TtkTokenKind;
    function Func199: TtkTokenKind;
    function Func200: TtkTokenKind;
    function Func201: TtkTokenKind;
    function Func202: TtkTokenKind;
    function Func203: TtkTokenKind;
    function Func204: TtkTokenKind;
    function Func205: TtkTokenKind;
    function Func207: TtkTokenKind;
    function Func208: TtkTokenKind;
    function Func209: TtkTokenKind;
    function Func210: TtkTokenKind;
    function Func211: TtkTokenKind;
    function Func213: TtkTokenKind;
    function Func214: TtkTokenKind;
    function Func215: TtkTokenKind;
    function Func216: TtkTokenKind;
    function Func217: TtkTokenKind;
    function Func218: TtkTokenKind;
    function Func221: TtkTokenKind;
    function Func222: TtkTokenKind;
    function Func223: TtkTokenKind;
    function Func224: TtkTokenKind;
    function Func226: TtkTokenKind;
    function Func227: TtkTokenKind;
    function Func228: TtkTokenKind;
    function Func229: TtkTokenKind;
    function Func230: TtkTokenKind;
    function Func231: TtkTokenKind;
    function Func232: TtkTokenKind;
    function Func233: TtkTokenKind;
    function Func234: TtkTokenKind;
    function Func236: TtkTokenKind;
    function Func237: TtkTokenKind;
    function Func238: TtkTokenKind;
    function Func240: TtkTokenKind;
    function Func241: TtkTokenKind;
    function Func242: TtkTokenKind;
    function Func244: TtkTokenKind;
    function Func245: TtkTokenKind;
    function Func246: TtkTokenKind;
    function Func247: TtkTokenKind;
    function Func248: TtkTokenKind;
    function Func249: TtkTokenKind;
    function Func250: TtkTokenKind;
    function Func251: TtkTokenKind;
    function Func252: TtkTokenKind;
    function Func253: TtkTokenKind;
    function Func254: TtkTokenKind;
    function Func255: TtkTokenKind;
    function Func256: TtkTokenKind;
    function Func257: TtkTokenKind;
    function Func258: TtkTokenKind;
    function Func259: TtkTokenKind;
    function Func260: TtkTokenKind;
    function Func262: TtkTokenKind;
    function Func263: TtkTokenKind;
    function Func264: TtkTokenKind;
    function Func265: TtkTokenKind;
    function Func266: TtkTokenKind;
    function Func267: TtkTokenKind;
    function Func269: TtkTokenKind;
    function Func270: TtkTokenKind;
    function Func273: TtkTokenKind;
    function Func274: TtkTokenKind;
    function Func280: TtkTokenKind;
    function Func282: TtkTokenKind;
    function Func283: TtkTokenKind;
    function Func284: TtkTokenKind;
    function Func285: TtkTokenKind;
    function Func286: TtkTokenKind;
    function Func288: TtkTokenKind;
    function Func289: TtkTokenKind;
    function Func290: TtkTokenKind;
    function Func292: TtkTokenKind;
    function Func293: TtkTokenKind;
    function Func301: TtkTokenKind;
    function Func304: TtkTokenKind;
    function Func306: TtkTokenKind;
    function Func310: TtkTokenKind;
    function Func316: TtkTokenKind;
    function Func318: TtkTokenKind;
    function Func323: TtkTokenKind;
    function Func333: TtkTokenKind;
    function Func340: TtkTokenKind;
    function Func343: TtkTokenKind;
    function Func344: TtkTokenKind;
    function Func366: TtkTokenKind;
    procedure IdentProc;
    procedure NumberProc;
    procedure UnknownProc;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
    procedure NullProc;
    procedure SpaceProc;
    procedure CRProc;
    procedure LFProc;
    procedure AndSymbolProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure GreaterProc;
    procedure LowerProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure SemiColonProc;
    procedure DirectiveProc;
    procedure EqualProc;
    procedure QuestionProc;
    procedure PlusProc;
    procedure MinusProc;
    procedure StarProc;
    procedure ModSymbolProc;
    procedure NotSymbolProc;
    procedure OrSymbolProc;
    procedure PointProc;
    procedure TildeProc;
    procedure AnsiCProc;
    procedure SlashProc;
    procedure StringProc;
    procedure QuoteStringProc;
    procedure DirectiveEndProc;
    procedure CommentProc;
    procedure StringEndProc;
  protected
    function GetIdentChars: TSynIdentChars; override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetRange: Pointer; override;
    procedure ResetRange; override;
    procedure SetRange(Value: Pointer); override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    function GetToken: String; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
      override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri write fCommentAttri;
    property DefinitionAttri: TSynHighlighterAttributes read fDefinitionAttri write fDefinitionAttri;
    property DirectiveAttri: TSynHighlighterAttributes read fDirectiveAttri write fDirectiveAttri;
    property FunctionAttri: TSynHighlighterAttributes read fFunctionAttri write fFunctionAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TSynHighlighterAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TSynHighlighterAttributes read fSymbolAttri write fSymbolAttri;
  end;

implementation

uses LazUTF8;

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable : array[#0..#255] of Integer;

procedure MakeIdentTable;
var
  I: Char;
begin
  for I := #0 to #255 do
  begin
    case I of
      '_', 'a'..'z', 'A'..'Z', '0'..'9': Identifiers[I] := True;
    else
      Identifiers[I] := False;
    end;
    case I in ['_', 'A'..'Z', 'a'..'z'] of
      True:
        begin
          if (I > #64) and (I < #91) then
            mHashTable[I] := Ord(I) - 64
          else if (I > #96) then
            mHashTable[I] := Ord(I) - 95;
        end;
    else
      mHashTable[I] := 0;
    end;
  end;
end;

procedure TSynIssSyn.InitIdent;
var
  I: Integer;
  pF: PIdentFuncTableFunc;
begin
  pF := PIdentFuncTableFunc(@fIdentFuncTable);
  for I := Low(fIdentFuncTable) to High(fIdentFuncTable) do
  begin
    pF^ := @AltFunc;
    Inc(pF);
  end;
  fIdentFuncTable[17] := @Func17;
  fIdentFuncTable[20] := @Func20;
  fIdentFuncTable[26] := @Func26;
  fIdentFuncTable[27] := @Func27;
  fIdentFuncTable[28] := @Func28;
  fIdentFuncTable[29] := @Func29;
  fIdentFuncTable[30] := @Func30;
  fIdentFuncTable[32] := @Func32;
  fIdentFuncTable[33] := @Func33;
  fIdentFuncTable[34] := @Func34;
  fIdentFuncTable[37] := @Func37;
  fIdentFuncTable[38] := @Func38;
  fIdentFuncTable[39] := @Func39;
  fIdentFuncTable[40] := @Func40;
  fIdentFuncTable[41] := @Func41;
  fIdentFuncTable[42] := @Func42;
  fIdentFuncTable[43] := @Func43;
  fIdentFuncTable[44] := @Func44;
  fIdentFuncTable[45] := @Func45;
  fIdentFuncTable[46] := @Func46;
  fIdentFuncTable[47] := @Func47;
  fIdentFuncTable[48] := @Func48;
  fIdentFuncTable[49] := @Func49;
  fIdentFuncTable[50] := @Func50;
  fIdentFuncTable[51] := @Func51;
  fIdentFuncTable[52] := @Func52;
  fIdentFuncTable[53] := @Func53;
  fIdentFuncTable[54] := @Func54;
  fIdentFuncTable[55] := @Func55;
  fIdentFuncTable[56] := @Func56;
  fIdentFuncTable[58] := @Func58;
  fIdentFuncTable[59] := @Func59;
  fIdentFuncTable[60] := @Func60;
  fIdentFuncTable[61] := @Func61;
  fIdentFuncTable[62] := @Func62;
  fIdentFuncTable[63] := @Func63;
  fIdentFuncTable[64] := @Func64;
  fIdentFuncTable[65] := @Func65;
  fIdentFuncTable[66] := @Func66;
  fIdentFuncTable[67] := @Func67;
  fIdentFuncTable[68] := @Func68;
  fIdentFuncTable[69] := @Func69;
  fIdentFuncTable[70] := @Func70;
  fIdentFuncTable[71] := @Func71;
  fIdentFuncTable[73] := @Func73;
  fIdentFuncTable[74] := @Func74;
  fIdentFuncTable[75] := @Func75;
  fIdentFuncTable[76] := @Func76;
  fIdentFuncTable[77] := @Func77;
  fIdentFuncTable[78] := @Func78;
  fIdentFuncTable[79] := @Func79;
  fIdentFuncTable[80] := @Func80;
  fIdentFuncTable[81] := @Func81;
  fIdentFuncTable[82] := @Func82;
  fIdentFuncTable[84] := @Func84;
  fIdentFuncTable[85] := @Func85;
  fIdentFuncTable[86] := @Func86;
  fIdentFuncTable[87] := @Func87;
  fIdentFuncTable[88] := @Func88;
  fIdentFuncTable[89] := @Func89;
  fIdentFuncTable[90] := @Func90;
  fIdentFuncTable[91] := @Func91;
  fIdentFuncTable[92] := @Func92;
  fIdentFuncTable[93] := @Func93;
  fIdentFuncTable[94] := @Func94;
  fIdentFuncTable[95] := @Func95;
  fIdentFuncTable[96] := @Func96;
  fIdentFuncTable[97] := @Func97;
  fIdentFuncTable[98] := @Func98;
  fIdentFuncTable[99] := @Func99;
  fIdentFuncTable[100] := @Func100;
  fIdentFuncTable[101] := @Func101;
  fIdentFuncTable[102] := @Func102;
  fIdentFuncTable[103] := @Func103;
  fIdentFuncTable[104] := @Func104;
  fIdentFuncTable[105] := @Func105;
  fIdentFuncTable[106] := @Func106;
  fIdentFuncTable[107] := @Func107;
  fIdentFuncTable[108] := @Func108;
  fIdentFuncTable[109] := @Func109;
  fIdentFuncTable[110] := @Func110;
  fIdentFuncTable[111] := @Func111;
  fIdentFuncTable[112] := @Func112;
  fIdentFuncTable[113] := @Func113;
  fIdentFuncTable[114] := @Func114;
  fIdentFuncTable[115] := @Func115;
  fIdentFuncTable[116] := @Func116;
  fIdentFuncTable[117] := @Func117;
  fIdentFuncTable[118] := @Func118;
  fIdentFuncTable[119] := @Func119;
  fIdentFuncTable[120] := @Func120;
  fIdentFuncTable[121] := @Func121;
  fIdentFuncTable[122] := @Func122;
  fIdentFuncTable[123] := @Func123;
  fIdentFuncTable[124] := @Func124;
  fIdentFuncTable[125] := @Func125;
  fIdentFuncTable[126] := @Func126;
  fIdentFuncTable[127] := @Func127;
  fIdentFuncTable[128] := @Func128;
  fIdentFuncTable[129] := @Func129;
  fIdentFuncTable[130] := @Func130;
  fIdentFuncTable[131] := @Func131;
  fIdentFuncTable[132] := @Func132;
  fIdentFuncTable[133] := @Func133;
  fIdentFuncTable[134] := @Func134;
  fIdentFuncTable[135] := @Func135;
  fIdentFuncTable[136] := @Func136;
  fIdentFuncTable[137] := @Func137;
  fIdentFuncTable[138] := @Func138;
  fIdentFuncTable[139] := @Func139;
  fIdentFuncTable[140] := @Func140;
  fIdentFuncTable[141] := @Func141;
  fIdentFuncTable[142] := @Func142;
  fIdentFuncTable[143] := @Func143;
  fIdentFuncTable[144] := @Func144;
  fIdentFuncTable[145] := @Func145;
  fIdentFuncTable[146] := @Func146;
  fIdentFuncTable[147] := @Func147;
  fIdentFuncTable[148] := @Func148;
  fIdentFuncTable[149] := @Func149;
  fIdentFuncTable[150] := @Func150;
  fIdentFuncTable[151] := @Func151;
  fIdentFuncTable[152] := @Func152;
  fIdentFuncTable[153] := @Func153;
  fIdentFuncTable[154] := @Func154;
  fIdentFuncTable[155] := @Func155;
  fIdentFuncTable[156] := @Func156;
  fIdentFuncTable[157] := @Func157;
  fIdentFuncTable[158] := @Func158;
  fIdentFuncTable[159] := @Func159;
  fIdentFuncTable[160] := @Func160;
  fIdentFuncTable[161] := @Func161;
  fIdentFuncTable[162] := @Func162;
  fIdentFuncTable[163] := @Func163;
  fIdentFuncTable[164] := @Func164;
  fIdentFuncTable[165] := @Func165;
  fIdentFuncTable[166] := @Func166;
  fIdentFuncTable[167] := @Func167;
  fIdentFuncTable[168] := @Func168;
  fIdentFuncTable[169] := @Func169;
  fIdentFuncTable[170] := @Func170;
  fIdentFuncTable[171] := @Func171;
  fIdentFuncTable[172] := @Func172;
  fIdentFuncTable[173] := @Func173;
  fIdentFuncTable[174] := @Func174;
  fIdentFuncTable[175] := @Func175;
  fIdentFuncTable[176] := @Func176;
  fIdentFuncTable[177] := @Func177;
  fIdentFuncTable[178] := @Func178;
  fIdentFuncTable[181] := @Func181;
  fIdentFuncTable[182] := @Func182;
  fIdentFuncTable[183] := @Func183;
  fIdentFuncTable[184] := @Func184;
  fIdentFuncTable[185] := @Func185;
  fIdentFuncTable[186] := @Func186;
  fIdentFuncTable[187] := @Func187;
  fIdentFuncTable[188] := @Func188;
  fIdentFuncTable[189] := @Func189;
  fIdentFuncTable[190] := @Func190;
  fIdentFuncTable[191] := @Func191;
  fIdentFuncTable[192] := @Func192;
  fIdentFuncTable[193] := @Func193;
  fIdentFuncTable[194] := @Func194;
  fIdentFuncTable[195] := @Func195;
  fIdentFuncTable[196] := @Func196;
  fIdentFuncTable[197] := @Func197;
  fIdentFuncTable[198] := @Func198;
  fIdentFuncTable[199] := @Func199;
  fIdentFuncTable[200] := @Func200;
  fIdentFuncTable[201] := @Func201;
  fIdentFuncTable[202] := @Func202;
  fIdentFuncTable[203] := @Func203;
  fIdentFuncTable[204] := @Func204;
  fIdentFuncTable[205] := @Func205;
  fIdentFuncTable[207] := @Func207;
  fIdentFuncTable[208] := @Func208;
  fIdentFuncTable[209] := @Func209;
  fIdentFuncTable[210] := @Func210;
  fIdentFuncTable[211] := @Func211;
  fIdentFuncTable[213] := @Func213;
  fIdentFuncTable[214] := @Func214;
  fIdentFuncTable[215] := @Func215;
  fIdentFuncTable[216] := @Func216;
  fIdentFuncTable[217] := @Func217;
  fIdentFuncTable[218] := @Func218;
  fIdentFuncTable[221] := @Func221;
  fIdentFuncTable[222] := @Func222;
  fIdentFuncTable[223] := @Func223;
  fIdentFuncTable[224] := @Func224;
  fIdentFuncTable[226] := @Func226;
  fIdentFuncTable[227] := @Func227;
  fIdentFuncTable[228] := @Func228;
  fIdentFuncTable[229] := @Func229;
  fIdentFuncTable[230] := @Func230;
  fIdentFuncTable[231] := @Func231;
  fIdentFuncTable[232] := @Func232;
  fIdentFuncTable[233] := @Func233;
  fIdentFuncTable[234] := @Func234;
  fIdentFuncTable[236] := @Func236;
  fIdentFuncTable[237] := @Func237;
  fIdentFuncTable[238] := @Func238;
  fIdentFuncTable[240] := @Func240;
  fIdentFuncTable[241] := @Func241;
  fIdentFuncTable[242] := @Func242;
  fIdentFuncTable[244] := @Func244;
  fIdentFuncTable[245] := @Func245;
  fIdentFuncTable[246] := @Func246;
  fIdentFuncTable[247] := @Func247;
  fIdentFuncTable[248] := @Func248;
  fIdentFuncTable[249] := @Func249;
  fIdentFuncTable[250] := @Func250;
  fIdentFuncTable[251] := @Func251;
  fIdentFuncTable[252] := @Func252;
  fIdentFuncTable[253] := @Func253;
  fIdentFuncTable[254] := @Func254;
  fIdentFuncTable[255] := @Func255;
  fIdentFuncTable[256] := @Func256;
  fIdentFuncTable[257] := @Func257;
  fIdentFuncTable[258] := @Func258;
  fIdentFuncTable[259] := @Func259;
  fIdentFuncTable[260] := @Func260;
  fIdentFuncTable[262] := @Func262;
  fIdentFuncTable[263] := @Func263;
  fIdentFuncTable[264] := @Func264;
  fIdentFuncTable[265] := @Func265;
  fIdentFuncTable[266] := @Func266;
  fIdentFuncTable[267] := @Func267;
  fIdentFuncTable[269] := @Func269;
  fIdentFuncTable[270] := @Func270;
  fIdentFuncTable[273] := @Func273;
  fIdentFuncTable[274] := @Func274;
  fIdentFuncTable[280] := @Func280;
  fIdentFuncTable[282] := @Func282;
  fIdentFuncTable[283] := @Func283;
  fIdentFuncTable[284] := @Func284;
  fIdentFuncTable[285] := @Func285;
  fIdentFuncTable[286] := @Func286;
  fIdentFuncTable[288] := @Func288;
  fIdentFuncTable[289] := @Func289;
  fIdentFuncTable[290] := @Func290;
  fIdentFuncTable[292] := @Func292;
  fIdentFuncTable[293] := @Func293;
  fIdentFuncTable[301] := @Func301;
  fIdentFuncTable[304] := @Func304;
  fIdentFuncTable[306] := @Func306;
  fIdentFuncTable[310] := @Func310;
  fIdentFuncTable[316] := @Func316;
  fIdentFuncTable[318] := @Func318;
  fIdentFuncTable[323] := @Func323;
  fIdentFuncTable[333] := @Func333;
  fIdentFuncTable[340] := @Func340;
  fIdentFuncTable[343] := @Func343;
  fIdentFuncTable[344] := @Func344;
  fIdentFuncTable[366] := @Func366;
end;

function TSynIssSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', 'a'..'z', 'A'..'Z', '0'..'9'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end;

function TSynIssSyn.KeyComp(const aKey: string): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if Temp^ <> aKey[i] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end
  else
    Result := False;
end;

function TSynIssSyn.Func17: TtkTokenKind;
begin
  if KeyComp('if') then Result := tkKey else
    if KeyComp('BACK') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func20: TtkTokenKind;
begin
  if KeyComp('Do') then Result := tkFunction else
    if KeyComp('GDI') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func26: TtkTokenKind;
begin
  if KeyComp('end') then Result := tkKey else
    if KeyComp('OK') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func27: TtkTokenKind;
begin
  if KeyComp('RGB') then Result := tkFunction else
    if KeyComp('RED') then Result := tkDefinition else
      if KeyComp('CDECL') then Result := tkKey else
        if KeyComp('OFF') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func28: TtkTokenKind;
begin
  if KeyComp('IS_386') then Result := tkDefinition else
    if KeyComp('IS_486') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func29: TtkTokenKind;
begin
  if KeyComp('Is') then Result := tkFunction else
    if KeyComp('NO') then Result := tkDefinition else
      if KeyComp('ON') then Result := tkDefinition else
        if KeyComp('BLACK') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func30: TtkTokenKind;
begin
  if KeyComp('DATE') then Result := tkDefinition else
    if KeyComp('CHAR') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func32: TtkTokenKind;
begin
  if KeyComp('case') then Result := tkKey else
    if KeyComp('__FILE__') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func33: TtkTokenKind;
begin
  if KeyComp('EFF_FADE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func34: TtkTokenKind;
begin
  if KeyComp('char') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func37: TtkTokenKind;
begin
  if KeyComp('to') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func38: TtkTokenKind;
begin
  if KeyComp('CANCEL') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func39: TtkTokenKind;
begin
  if KeyComp('ENABLE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func40: TtkTokenKind;
begin
  if KeyComp('CPU') then Result := tkDefinition else
    if KeyComp('__LINE__') then Result := tkDefinition else
      if KeyComp('BK_RED') then Result := tkDefinition else
        if KeyComp('BLUE') then Result := tkDefinition else
          if KeyComp('catch') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func41: TtkTokenKind;
begin
  if KeyComp('IS_EGA') then Result := tkDefinition else
    if KeyComp('HELP') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func42: TtkTokenKind;
begin
  if KeyComp('begin') then Result := tkKey else
    if KeyComp('for') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func43: TtkTokenKind;
begin
  if KeyComp('DISK') then Result := tkDefinition else
    if KeyComp('INT') then Result := tkKey else
      if KeyComp('endif') then Result := tkKey else
        if KeyComp('FALSE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func44: TtkTokenKind;
begin
  if KeyComp('BOOL') then Result := tkKey else
    if KeyComp('Enable') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func45: TtkTokenKind;
begin
  if KeyComp('PATH') then Result := tkDefinition else
    if KeyComp('else') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func46: TtkTokenKind;
begin
  if KeyComp('int') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func47: TtkTokenKind;
begin
  if KeyComp('TIME') then Result := tkDefinition else
    if KeyComp('set') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func48: TtkTokenKind;
begin
  if KeyComp('LONG') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func49: TtkTokenKind;
begin
  if KeyComp('BatchAdd') then Result := tkFunction else
    if KeyComp('YES') then Result := tkDefinition else
      if KeyComp('HWND') then Result := tkKey else
        if KeyComp('GREEN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func50: TtkTokenKind;
begin
  if KeyComp('AFTER') then Result := tkDefinition else
    if KeyComp('TILED') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func51: TtkTokenKind;
begin
  if KeyComp('Delay') then Result := tkFunction else
    if KeyComp('then') then Result := tkKey else
      if KeyComp('BEFORE') then Result := tkDefinition else
        if KeyComp('FULL') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func52: TtkTokenKind;
begin
  if KeyComp('long') then Result := tkKey else
    if KeyComp('DISABLE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func53: TtkTokenKind;
begin
  if KeyComp('CDROM') then Result := tkDefinition else
    if KeyComp('WAIT') then Result := tkDefinition else
      if KeyComp('BK_BLUE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func54: TtkTokenKind;
begin
  if KeyComp('void') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func55: TtkTokenKind;
begin
  if KeyComp('VIDEO') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func56: TtkTokenKind;
begin
  if KeyComp('APPEND') then Result := tkDefinition else
    if KeyComp('BYREF') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func58: TtkTokenKind;
begin
  if KeyComp('IS_VGA') then Result := tkDefinition else
    if KeyComp('Disable') then Result := tkFunction else
      if KeyComp('DRIVE') then Result := tkDefinition else
        if KeyComp('EXIT') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func59: TtkTokenKind;
begin
  if KeyComp('NULL') then Result := tkDefinition else
    if KeyComp('PathAdd') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func60: TtkTokenKind;
begin
  if KeyComp('REPLACE') then Result := tkDefinition else
    if KeyComp('LIST') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func61: TtkTokenKind;
begin
  if KeyComp('goto') then Result := tkKey else
    if KeyComp('abort') then Result := tkKey else
      if KeyComp('MAGENTA') then Result := tkDefinition else
        if KeyComp('byref') then Result := tkKey else
          if KeyComp('object') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func62: TtkTokenKind;
begin
  if KeyComp('elseif') then Result := tkKey else
    if KeyComp('while') then Result := tkKey else
      if KeyComp('BK_GREEN') then Result := tkDefinition else
        if KeyComp('BYVAL') then Result := tkKey else
          if KeyComp('FILE_DATE') then Result := tkDefinition else
            if KeyComp('exit') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func63: TtkTokenKind;
begin
  if KeyComp('USER') then Result := tkKey else
    if KeyComp('NEXT') then Result := tkDefinition else
      if KeyComp('BK_PINK') then Result := tkDefinition else
        if KeyComp('COMMAND') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func64: TtkTokenKind;
begin
  if KeyComp('DLG_ERR') then Result := tkDefinition else
    if KeyComp('step') then Result := tkKey else
      if KeyComp('SERIAL') then Result := tkDefinition else
        if KeyComp('TRUE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func65: TtkTokenKind;
begin
  if KeyComp('FILENAME') then Result := tkDefinition else
    if KeyComp('KERNEL') then Result := tkKey else
      if KeyComp('WHITE') then Result := tkDefinition else
        if KeyComp('EFF_NONE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func66: TtkTokenKind;
begin
  if KeyComp('endcatch') then Result := tkKey else
    if KeyComp('try') then Result := tkKey else
      if KeyComp('IS_ALPHA') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func67: TtkTokenKind;
begin
  if KeyComp('GetDir') then Result := tkFunction else
    if KeyComp('byval') then Result := tkKey else
      if KeyComp('RESET') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func68: TtkTokenKind;
begin
  if KeyComp('endfor') then Result := tkKey else
    if KeyComp('DIALOGCACHE') then Result := tkDefinition else
      if KeyComp('ROOT') then Result := tkDefinition else
        if KeyComp('Handler') then Result := tkFunction else
          if KeyComp('LANGUAGE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func69: TtkTokenKind;
begin
  if KeyComp('DEFAULT') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func70: TtkTokenKind;
begin
  if KeyComp('ERR_NO') then Result := tkDefinition else
    if KeyComp('CHECKLINE') then Result := tkDefinition else
      if KeyComp('ConfigAdd') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func71: TtkTokenKind;
begin
  if KeyComp('FindFile') then Result := tkFunction else
    if KeyComp('repeat') then Result := tkKey else
      if KeyComp('METAFILE') then Result := tkDefinition else
        if KeyComp('method') then Result := tkKey else
          if KeyComp('LOGGING') then Result := tkDefinition else
            if KeyComp('BYTES') then Result := tkDefinition else
              if KeyComp('COMPACT') then Result := tkDefinition else
                if KeyComp('STDCALL') then Result := tkKey else
                  if KeyComp('CHECKBOX95') then Result := tkDefinition else
                    if KeyComp('CHECKBOX') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func73: TtkTokenKind;
begin
  if KeyComp('CHECKMARK') then Result := tkDefinition else
    if KeyComp('NUMBER') then Result := tkKey else
      if KeyComp('NOSET') then Result := tkDefinition else
        if KeyComp('COMMON') then Result := tkDefinition else
          if KeyComp('BK_ORANGE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func74: TtkTokenKind;
begin
  if KeyComp('SEVERE') then Result := tkDefinition else
    if KeyComp('BK_MAGENTA') then Result := tkDefinition else
      if KeyComp('BatchFind') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func75: TtkTokenKind;
begin
  if KeyComp('UseDLL') then Result := tkFunction else
    if KeyComp('BILLBOARD') then Result := tkDefinition else
      if KeyComp('EQUALS') then Result := tkDefinition else
        if KeyComp('DLG_INIT') then Result := tkDefinition else
          if KeyComp('IS_ITEM') then Result := tkDefinition else
            if KeyComp('binary') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func76: TtkTokenKind;
begin
  if KeyComp('END_OF_FILE') then Result := tkDefinition else
    if KeyComp('IS_FIXED') then Result := tkDefinition else
      if KeyComp('ASKPATH') then Result := tkDefinition else
        if KeyComp('WELCOME') then Result := tkDefinition else
          if KeyComp('default') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func77: TtkTokenKind;
begin
  if KeyComp('HIWORD') then Result := tkFunction else
    if KeyComp('DLG_CLOSE') then Result := tkDefinition else
      if KeyComp('GetLine') then Result := tkFunction else
        if KeyComp('PARTIAL') then Result := tkDefinition else
          if KeyComp('PARALLEL') then Result := tkDefinition else
            if KeyComp('DELETE_EOF') then Result := tkDefinition else
              if KeyComp('MMEDIA_AVI') then Result := tkDefinition else
                if KeyComp('IS_SVGA') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func78: TtkTokenKind;
begin
  if KeyComp('GBYTES') then Result := tkDefinition else
    if KeyComp('REMOVE') then Result := tkDefinition else
      if KeyComp('EndDialog') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func79: TtkTokenKind;
begin
  if KeyComp('number') then Result := tkKey else
    if KeyComp('IS_UVGA') then Result := tkDefinition else
      if KeyComp('FILE_TIME') then Result := tkDefinition else
        if KeyComp('SdInit') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func80: TtkTokenKind;
begin
  if KeyComp('SHORT') then Result := tkKey else
    if KeyComp('MMEDIA_MIDI') then Result := tkDefinition else
      if KeyComp('GetDisk') then Result := tkFunction else
        if KeyComp('FILE_BIN_END') then Result := tkDefinition else
          if KeyComp('EFF_REVEAL') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func81: TtkTokenKind;
begin
  if KeyComp('AskPath') then Result := tkFunction else
    if KeyComp('IS_CDROM') then Result := tkDefinition else
      if KeyComp('until') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func82: TtkTokenKind;
begin
  if KeyComp('NOWAIT') then Result := tkDefinition else
    if KeyComp('FILE_LOCKED') then Result := tkDefinition else
      if KeyComp('PathGet') then Result := tkFunction else
        if KeyComp('LOCKEDFILE') then Result := tkDefinition else
          if KeyComp('COLORS') then Result := tkDefinition else
            if KeyComp('IS_XVGA') then Result := tkDefinition else
              if KeyComp('KBYTES') then Result := tkDefinition else
                if KeyComp('Welcome') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func84: TtkTokenKind;
begin
  if KeyComp('PathFind') then Result := tkFunction else
    if KeyComp('FileGrep') then Result := tkFunction else
      if KeyComp('MBYTES') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func85: TtkTokenKind;
begin
  if KeyComp('short') then Result := tkKey else
    if KeyComp('LPSTR') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func86: TtkTokenKind;
begin
  if KeyComp('TYPICAL') then Result := tkDefinition else
    if KeyComp('DLG_DIR_FILE') then Result := tkDefinition else
      if KeyComp('WARNING') then Result := tkDefinition else
        if KeyComp('DATA_LIST') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func87: TtkTokenKind;
begin
  if KeyComp('STRING') then Result := tkKey else
    if KeyComp('SHAREDFILE') then Result := tkDefinition else
      if KeyComp('DLG_MSG_ALL') then Result := tkDefinition else
        if KeyComp('LOWORD') then Result := tkFunction else
          if KeyComp('ISLANG_ALL') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func88: TtkTokenKind;
begin
  if KeyComp('REGDB_NAMES') then Result := tkDefinition else
    if KeyComp('IS_FOLDER') then Result := tkDefinition else
      if KeyComp('endwhile') then Result := tkKey else
        if KeyComp('switch') then Result := tkKey else
          if KeyComp('typedef') then Result := tkKey else
            if KeyComp('OpenFile') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func89: TtkTokenKind;
begin
  if KeyComp('CtrlDir') then Result := tkFunction else
    if KeyComp('DeleteDir') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func90: TtkTokenKind;
begin
  if KeyComp('CallDLLFx') then Result := tkFunction else
    if KeyComp('SdBitmap') then Result := tkFunction else
      if KeyComp('ERR_YES') then Result := tkDefinition else
        if KeyComp('CreateDir') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func91: TtkTokenKind;
begin
  if KeyComp('FILE_SIZE') then Result := tkDefinition else
    if KeyComp('DeleteFile') then Result := tkFunction else
      if KeyComp('CUSTOM') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func92: TtkTokenKind;
begin
  if KeyComp('GetFont') then Result := tkFunction else
    if KeyComp('variant') then Result := tkKey else
      if KeyComp('CreateFile') then Result := tkFunction else
        if KeyComp('YELLOW') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func93: TtkTokenKind;
begin
  if KeyComp('SdMakeName') then Result := tkFunction else
    if KeyComp('string') then Result := tkKey else
      if KeyComp('VALID_PATH') then Result := tkDefinition else
        if KeyComp('VarSave') then Result := tkFunction else
          if KeyComp('CloseFile') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func94: TtkTokenKind;
begin
  if KeyComp('SdFinish') then Result := tkFunction else
    if KeyComp('PathSet') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func95: TtkTokenKind;
begin
  if KeyComp('ConfigFind') then Result := tkFunction else
    if KeyComp('StrFind') then Result := tkFunction else
      if KeyComp('program') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func96: TtkTokenKind;
begin
  if KeyComp('ISLANG_ARABIC') then Result := tkDefinition else
    if KeyComp('BACKGROUND') then Result := tkDefinition else
      if KeyComp('EXISTS') then Result := tkDefinition else
        if KeyComp('RenameFile') then Result := tkFunction else
          if KeyComp('REGDB_KEYS') then Result := tkDefinition else
            if KeyComp('MMEDIA_WAVE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func97: TtkTokenKind;
begin
  if KeyComp('DLG_CENTERED') then Result := tkDefinition else
    if KeyComp('POINTER') then Result := tkKey else
      if KeyComp('downto') then Result := tkKey else
        if KeyComp('ONLYDIR') then Result := tkDefinition else
          if KeyComp('ERR_ABORT') then Result := tkDefinition else
            if KeyComp('CopyFile') then Result := tkFunction else
              if KeyComp('SdLicense') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func98: TtkTokenKind;
begin
  if KeyComp('EXPORT') then Result := tkKey else
    if KeyComp('LESS_THAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func99: TtkTokenKind;
begin
  if KeyComp('BK_SOLIDRED') then Result := tkDefinition else
    if KeyComp('DATA_NUMBER') then Result := tkDefinition else
      if KeyComp('EXTERNAL') then Result := tkKey else
        if KeyComp('FILE_BIN_CUR') then Result := tkDefinition else
          if KeyComp('CtrlClear') then Result := tkFunction else
            if KeyComp('LaunchApp') then Result := tkFunction else
              if KeyComp('ISOSL_ALL') then Result := tkDefinition else
                if KeyComp('DLG_ASK_PATH') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func100: TtkTokenKind;
begin
  if KeyComp('PERSONAL') then Result := tkDefinition else
    if KeyComp('ISLANG_THAI') then Result := tkDefinition else
      if KeyComp('STATUS') then Result := tkDefinition else
        if KeyComp('ASKTEXT') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func101: TtkTokenKind;
begin
  if KeyComp('RESTART') then Result := tkDefinition else
    if KeyComp('CONTINUE') then Result := tkDefinition else
      if KeyComp('COMPARE_DATE') then Result := tkDefinition else
        if KeyComp('DefineDialog') then Result := tkFunction else
          if KeyComp('BK_SOLIDBLACK') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func102: TtkTokenKind;
begin
  if KeyComp('SelectDir') then Result := tkFunction else
    if KeyComp('BITMAPICON') then Result := tkDefinition else
      if KeyComp('return') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func103: TtkTokenKind;
begin
  if KeyComp('StrSub') then Result := tkFunction else
    if KeyComp('BK_SMOOTH') then Result := tkDefinition else
      if KeyComp('FILE_SRC_OLD') then Result := tkDefinition else
        if KeyComp('WINMAJOR') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func104: TtkTokenKind;
begin
  if KeyComp('pointer') then Result := tkKey else
    if KeyComp('SetFont') then Result := tkFunction else
      if KeyComp('export') then Result := tkKey else
        if KeyComp('GetMemFree') then Result := tkFunction else
          if KeyComp('PathDelete') then Result := tkFunction else
            if KeyComp('END_OF_LIST') then Result := tkDefinition else
              if KeyComp('IS_REMOTE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func105: TtkTokenKind;
begin
  if KeyComp('REGDB_BINARY') then Result := tkDefinition else
    if KeyComp('BK_YELLOW') then Result := tkDefinition else
      if KeyComp('ENTERDISK') then Result := tkDefinition else
        if KeyComp('AskText') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func106: TtkTokenKind;
begin
  if KeyComp('PathMove') then Result := tkFunction else
    if KeyComp('PlayMMedia') then Result := tkFunction else
      if KeyComp('System') then Result := tkFunction else
        if KeyComp('MessageBeep') then Result := tkFunction else
          if KeyComp('ReadBytes') then Result := tkFunction else
            if KeyComp('FIXED_DRIVE') then Result := tkDefinition else
              if KeyComp('SdWelcome') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func107: TtkTokenKind;
begin
  if KeyComp('external') then Result := tkKey else
    if KeyComp('ISLANG_CZECH') then Result := tkDefinition else
      if KeyComp('PlaceBitmap') then Result := tkFunction else
        if KeyComp('SW_SHOW') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func108: TtkTokenKind;
begin
  if KeyComp('BatchFileLoad') then Result := tkFunction else
    if KeyComp('Sprintf') then Result := tkFunction else
      if KeyComp('ISLANG_GREEK') then Result := tkDefinition else
        if KeyComp('ISOSL_NT40') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func109: TtkTokenKind;
begin
  if KeyComp('REGDB_NUMBER') then Result := tkDefinition else
    if KeyComp('ERR_IGNORE') then Result := tkDefinition else
      if KeyComp('BACKBUTTON') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func110: TtkTokenKind;
begin
  if KeyComp('function') then Result := tkKey else
    if KeyComp('DLG_ERR_ENDDLG') then Result := tkDefinition else
      if KeyComp('NORMALMODE') then Result := tkDefinition else
        if KeyComp('FILE_IS_LOCKED') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func111: TtkTokenKind;
begin
  if KeyComp('ParsePath') then Result := tkFunction else
    if KeyComp('CDROM_DRIVE') then Result := tkDefinition else
      if KeyComp('UnUseDLL') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func112: TtkTokenKind;
begin
  if KeyComp('FileCompare') then Result := tkFunction else
    if KeyComp('EnterDisk') then Result := tkFunction else
      if KeyComp('LISTLAST') then Result := tkDefinition else
        if KeyComp('DLG_DIR_DRIVE') then Result := tkDefinition else
          if KeyComp('BK_SOLIDBLUE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func113: TtkTokenKind;
begin
  if KeyComp('SetColor') then Result := tkFunction else
    if KeyComp('DoInstall') then Result := tkFunction else
      if KeyComp('LINE_NUMBER') then Result := tkDefinition else
        if KeyComp('DATA_STRING') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func114: TtkTokenKind;
begin
  if KeyComp('AskYesNo') then Result := tkFunction else
    if KeyComp('REGDB_APPPATH') then Result := tkDefinition else
      if KeyComp('endswitch') then Result := tkKey else
        if KeyComp('STYLE_BOLD') then Result := tkDefinition else
          if KeyComp('ISLANG_CATALAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func115: TtkTokenKind;
begin
  if KeyComp('ISLANG_FARSI') then Result := tkDefinition else
    if KeyComp('FULLSCREEN') then Result := tkDefinition else
      if KeyComp('ConfigDelete') then Result := tkFunction else
        if KeyComp('MMEDIA_STOP') then Result := tkDefinition else
          if KeyComp('WINMINOR') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func116: TtkTokenKind;
begin
  if KeyComp('GetFileInfo') then Result := tkFunction else
    if KeyComp('BASEMEMORY') then Result := tkDefinition else
      if KeyComp('SILENTMODE') then Result := tkDefinition else
        if KeyComp('SetTitle') then Result := tkFunction else
          if KeyComp('FindAllDirs') then Result := tkFunction else
            if KeyComp('LOWER_LEFT') then Result := tkDefinition else
              if KeyComp('ISLANG_FRENCH') then Result := tkDefinition else
                if KeyComp('ISLANG_ALBANIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func117: TtkTokenKind;
begin
  if KeyComp('EDITBOX_CHANGE') then Result := tkDefinition else
    if KeyComp('DIRECTORY') then Result := tkDefinition else
      if KeyComp('ISLANG_DANISH') then Result := tkDefinition else
        if KeyComp('GREATER_THAN') then Result := tkDefinition else
          if KeyComp('ConfigMove') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func118: TtkTokenKind;
begin
  if KeyComp('SeekBytes') then Result := tkFunction else
    if KeyComp('MessageBox') then Result := tkFunction else
      if KeyComp('ISLANG_DUTCH') then Result := tkDefinition else
        if KeyComp('FindAllFiles') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func119: TtkTokenKind;
begin
  if KeyComp('LIST_NULL') then Result := tkDefinition else
    if KeyComp('UPPER_LEFT') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func120: TtkTokenKind;
begin
  if KeyComp('FILE_RD_ONLY') then Result := tkDefinition else
    if KeyComp('ISOSL_WIN2000') then Result := tkDefinition else
      if KeyComp('ISOSL_WIN95') then Result := tkDefinition else
        if KeyComp('ISOSL_WIN98') then Result := tkDefinition else
          if KeyComp('COMP_NORMAL') then Result := tkDefinition else
            if KeyComp('GetEnvVar') then Result := tkFunction else
              if KeyComp('ListCreate') then Result := tkFunction else
                if KeyComp('EXCLUSIVE') then Result := tkDefinition else
                  if KeyComp('AddFolderIcon') then Result := tkFunction else
                    if KeyComp('HOURGLASS') then Result := tkDefinition else
                      if KeyComp('VOLUMELABEL') then Result := tkDefinition else
                        if KeyComp('SendMessage') then Result := tkFunction else
                          if KeyComp('ISLANG_GERMAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func121: TtkTokenKind;
begin
  if KeyComp('IS_REMOVABLE') then Result := tkDefinition else
    if KeyComp('STATUSBAR') then Result := tkDefinition else
      if KeyComp('endprogram') then Result := tkKey else
        if KeyComp('XCopyFile') then Result := tkFunction else
          if KeyComp('BK_SOLIDGREEN') then Result := tkDefinition else
            if KeyComp('LISTPREV') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func122: TtkTokenKind;
begin
  if KeyComp('BK_SOLIDPINK') then Result := tkDefinition else
    if KeyComp('ISLANG_ICELANDIC') then Result := tkDefinition else
      if KeyComp('RegDBGetItem') then Result := tkFunction else
        if KeyComp('WriteLine') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func123: TtkTokenKind;
begin
  if KeyComp('LISTNEXT') then Result := tkDefinition else
    if KeyComp('BatchFileSave') then Result := tkFunction else
      if KeyComp('ISLANG_HEBREW') then Result := tkDefinition else
        if KeyComp('REGDB_STRING') then Result := tkDefinition else
          if KeyComp('STATUSDLG') then Result := tkDefinition else
            if KeyComp('ISLANG_ARABIC_UAE') then Result := tkDefinition else
              if KeyComp('DLG_STATUS') then Result := tkDefinition else
                if KeyComp('DLG_ASK_TEXT') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func124: TtkTokenKind;
begin
  if KeyComp('ASKDESTPATH') then Result := tkDefinition else
    if KeyComp('SELECTFOLDER') then Result := tkDefinition else
      if KeyComp('ReleaseDialog') then Result := tkFunction else
        if KeyComp('ListAddItem') then Result := tkFunction else
          if KeyComp('SdFinishEx') then Result := tkFunction else
            if KeyComp('VerCompare') then Result := tkFunction else
              if KeyComp('BatchDeleteEx') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func125: TtkTokenKind;
begin
  if KeyComp('ISLANG_CHINESE') then Result := tkDefinition else
    if KeyComp('FILE_MODE_APPEND') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func126: TtkTokenKind;
begin
  if KeyComp('BatchMoveEx') then Result := tkFunction else
    if KeyComp('ISLANG_KOREAN') then Result := tkDefinition else
      if KeyComp('DIR_WRITEABLE') then Result := tkDefinition else
        if KeyComp('IS_PENTIUM') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func127: TtkTokenKind;
begin
  if KeyComp('FILE_WRITEABLE') then Result := tkDefinition else
    if KeyComp('ERR_RETRY') then Result := tkDefinition else
      if KeyComp('ISLANG_BASQUE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func128: TtkTokenKind;
begin
  if KeyComp('DLG_ENTER_DISK') then Result := tkDefinition else
    if KeyComp('FILE_INSTALLED') then Result := tkDefinition else
      if KeyComp('GetDiskSpace') then Result := tkFunction else
        if KeyComp('FILE_EXISTS') then Result := tkDefinition else
          if KeyComp('ISLANG_ITALIAN') then Result := tkDefinition else
            if KeyComp('OpenFileMode') then Result := tkFunction else
              if KeyComp('SetFileInfo') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func129: TtkTokenKind;
begin
  if KeyComp('EzBatchAddPath') then Result := tkFunction else
    if KeyComp('FindWindow') then Result := tkFunction else
      if KeyComp('ConfigFileLoad') then Result := tkFunction else
        if KeyComp('STATUSEX') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func130: TtkTokenKind;
begin
  if KeyComp('StrLength') then Result := tkFunction else
    if KeyComp('COMPARE_SIZE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func131: TtkTokenKind;
begin
  if KeyComp('BUTTON_CHECKED') then Result := tkDefinition else
    if KeyComp('FILENAME_ONLY') then Result := tkDefinition else
      if KeyComp('STATUSOLD') then Result := tkDefinition else
        if KeyComp('HKEY_USERS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func132: TtkTokenKind;
begin
  if KeyComp('LISTFIRST') then Result := tkDefinition else
    if KeyComp('DLG_ASK_YESNO') then Result := tkDefinition else
      if KeyComp('AskDestPath') then Result := tkFunction else
        if KeyComp('BK_SOLIDORANGE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func133: TtkTokenKind;
begin
  if KeyComp('CmdGetHwndDlg') then Result := tkFunction else
    if KeyComp('BK_SOLIDMAGENTA') then Result := tkDefinition else
      if KeyComp('NUMBERLIST') then Result := tkDefinition else
        if KeyComp('ISLANG_JAPANESE') then Result := tkDefinition else
          if KeyComp('EzDefineDialog') then Result := tkFunction else
            if KeyComp('RebootDialog') then Result := tkFunction else
              if KeyComp('SdShowMsg') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func134: TtkTokenKind;
begin
  if KeyComp('SelectFolder') then Result := tkFunction else
    if KeyComp('PlaceWindow') then Result := tkFunction else
      if KeyComp('ExistsDir') then Result := tkFunction else
        if KeyComp('FileDeleteLine') then Result := tkFunction else
          if KeyComp('RegDBSetItem') then Result := tkFunction else
            if KeyComp('ERR_BOX_BADPATH') then Result := tkDefinition else
              if KeyComp('REMOTE_DRIVE') then Result := tkDefinition else
                if KeyComp('INFORMATION') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func135: TtkTokenKind;
begin
  if KeyComp('DLG_INFO_ALTIMAGE') then Result := tkDefinition else
    if KeyComp('ALLCONTENTS') then Result := tkDefinition else
      if KeyComp('STYLE_ITALIC') then Result := tkDefinition else
        if KeyComp('FILE_BIN_START') then Result := tkDefinition else
          if KeyComp('FILE_ATTR_HIDDEN') then Result := tkDefinition else
            if KeyComp('LOWER_RIGHT') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func136: TtkTokenKind;
begin
  if KeyComp('ISLANG_FAEROESE') then Result := tkDefinition else
    if KeyComp('DLG_MSG_SEVERE') then Result := tkDefinition else
      if KeyComp('EzBatchReplace') then Result := tkFunction else
        if KeyComp('HWND_INSTALL') then Result := tkDefinition else
          if KeyComp('StrCompare') then Result := tkFunction else
            if KeyComp('ISLANG_ENGLISH') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func137: TtkTokenKind;
begin
  if KeyComp('CopyBytes') then Result := tkFunction else
    if KeyComp('GetProfInt') then Result := tkFunction else
      if KeyComp('RegDBDeleteKey') then Result := tkFunction else
        if KeyComp('BK_SOLIDWHITE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func138: TtkTokenKind;
begin
  if KeyComp('UPPER_RIGHT') then Result := tkDefinition else
    if KeyComp('FILE_LINE_LENGTH') then Result := tkDefinition else
      if KeyComp('ERR_BOX_DISKID') then Result := tkDefinition else
        if KeyComp('ConfigGetInt') then Result := tkFunction else
          if KeyComp('OTHER_FAILURE') then Result := tkDefinition else
            if KeyComp('FILE_MODE_BINARY') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func139: TtkTokenKind;
begin
  if KeyComp('HWND_DESKTOP') then Result := tkDefinition else
    if KeyComp('WaitOnDialog') then Result := tkFunction else
      if KeyComp('ASKOPTIONS') then Result := tkDefinition else
        if KeyComp('ISLANG_ARABIC_OMAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func140: TtkTokenKind;
begin
  if KeyComp('ListCount') then Result := tkFunction else
    if KeyComp('SW_MINIMIZE') then Result := tkDefinition else
      if KeyComp('DEFWINDOWMODE') then Result := tkDefinition else
        if KeyComp('IS_UNKNOWN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func141: TtkTokenKind;
begin
  if KeyComp('ALLCONTROLS') then Result := tkDefinition else
    if KeyComp('INCLUDE_SUBDIR') then Result := tkDefinition else
      if KeyComp('FILE_NOT_FOUND') then Result := tkDefinition else
        if KeyComp('PATH_EXISTS') then Result := tkDefinition else
          if KeyComp('ISLANG_LATVIAN') then Result := tkDefinition else
            if KeyComp('DATA_COMPONENT') then Result := tkDefinition else
              if KeyComp('ISLANG_FINNISH') then Result := tkDefinition else
                if KeyComp('ISLANG_ARABIC_IRAQ') then Result := tkDefinition else
                  if KeyComp('ISLANG_POLISH') then Result := tkDefinition else
                    if KeyComp('property') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func142: TtkTokenKind;
begin
  if KeyComp('SW_MAXIMIZE') then Result := tkDefinition else
    if KeyComp('FILE_MODE_NORMAL') then Result := tkDefinition else
      if KeyComp('ISLANG_SLOVAK') then Result := tkDefinition else
        if KeyComp('SRCTARGETDIR') then Result := tkDefinition else
          if KeyComp('SW_RESTORE') then Result := tkDefinition else
            if KeyComp('ISLANG_AFRIKAANS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func143: TtkTokenKind;
begin
  if KeyComp('DLG_MSG_STANDARD') then Result := tkDefinition else
    if KeyComp('BatchGetFileName') then Result := tkFunction else
      if KeyComp('SELFREGISTER') then Result := tkDefinition else
        if KeyComp('ISLANG_CROATIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func144: TtkTokenKind;
begin
  if KeyComp('SilentReadData') then Result := tkFunction else
    if KeyComp('COMP_UPDATE_DATE') then Result := tkDefinition else
      if KeyComp('ConfigFileSave') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func145: TtkTokenKind;
begin
  if KeyComp('NumToStr') then Result := tkFunction else
    if KeyComp('EFF_BOXSTRIPE') then Result := tkDefinition else
      if KeyComp('NOTEXISTS') then Result := tkDefinition else
        if KeyComp('ISLANG_ARABIC_LIBYA') then Result := tkDefinition else
          if KeyComp('HKEY_LOCAL_MACHINE') then Result := tkDefinition else
            if KeyComp('StrToNum') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func146: TtkTokenKind;
begin
  if KeyComp('DialogSetInfo') then Result := tkFunction else
    if KeyComp('ISOSL_NT40_ALPHA') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func147: TtkTokenKind;
begin
  if KeyComp('EXCLUDE_SUBDIR') then Result := tkDefinition else
    if KeyComp('SETUPTYPE') then Result := tkDefinition else
      if KeyComp('GetExtents') then Result := tkFunction else
        if KeyComp('AskOptions') then Result := tkFunction else
          if KeyComp('ExistsDisk') then Result := tkFunction else
            if KeyComp('STRINGLIST') then Result := tkDefinition else
              if KeyComp('BOOTUPDRIVE') then Result := tkDefinition else
                if KeyComp('EFF_HORZREVEAL') then Result := tkDefinition else
                  if KeyComp('ISLANG_BULGARIAN') then Result := tkDefinition else
                    if KeyComp('ISLANG_ROMANIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func148: TtkTokenKind;
begin
  if KeyComp('DLG_MSG_WARNING') then Result := tkDefinition else
    if KeyComp('ISLANG_SPANISH') then Result := tkDefinition else
      if KeyComp('VER_UPDATE_COND') then Result := tkDefinition else
        if KeyComp('FILE_ATTRIBUTE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func149: TtkTokenKind;
begin
  if KeyComp('ISLANG_ARABIC_ALGERIA') then Result := tkDefinition else
    if KeyComp('ERR_BOX_BADTAGFILE') then Result := tkDefinition else
      if KeyComp('ISLANG_SWEDISH') then Result := tkDefinition else
        if KeyComp('ListFindItem') then Result := tkFunction else
          if KeyComp('ISLANG_ARABIC_BAHRAIN') then Result := tkDefinition else
            if KeyComp('VarRestore') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func150: TtkTokenKind;
begin
  if KeyComp('ConfigSetInt') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func151: TtkTokenKind;
begin
  if KeyComp('STYLE_SHADOW') then Result := tkDefinition else
    if KeyComp('SprintfBox') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func152: TtkTokenKind;
begin
  if KeyComp('COMP_UPDATE_SAME') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func153: TtkTokenKind;
begin
  if KeyComp('ISLANG_ARABIC_QATAR') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func154: TtkTokenKind;
begin
  if KeyComp('WriteBytes') then Result := tkFunction else
    if KeyComp('VerUpdateFile') then Result := tkFunction else
      if KeyComp('SetupType') then Result := tkFunction else
        if KeyComp('STYLE_NORMAL') then Result := tkDefinition else
          if KeyComp('RegDBGetAppInfo') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func155: TtkTokenKind;
begin
  if KeyComp('ISLANG_HUNGARIAN') then Result := tkDefinition else
    if KeyComp('DISK_TOTALSPACE') then Result := tkDefinition else
      if KeyComp('RUN_MINIMIZED') then Result := tkDefinition else
        if KeyComp('SizeWindow') then Result := tkFunction else
          if KeyComp('BatchSetFileName') then Result := tkFunction else
            if KeyComp('NEXTBUTTON') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func156: TtkTokenKind;
begin
  if KeyComp('REMOVEABLE_DRIVE') then Result := tkDefinition else
    if KeyComp('SdAskDestPath') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func157: TtkTokenKind;
begin
  if KeyComp('RUN_MAXIMIZED') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func158: TtkTokenKind;
begin
  if KeyComp('GetDiskSpaceEx') then Result := tkFunction else
    if KeyComp('SdShowDlgEdit3') then Result := tkFunction else
      if KeyComp('SdShowDlgEdit2') then Result := tkFunction else
        if KeyComp('SdSelectFolder') then Result := tkFunction else
          if KeyComp('SdShowDlgEdit1') then Result := tkFunction else
            if KeyComp('ISLANG_ARABIC_YEMEN') then Result := tkDefinition else
              if KeyComp('ISOSL_WIN2000_ALPHA') then Result := tkDefinition else
                if KeyComp('ISLANG_ARABIC_JORDAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func159: TtkTokenKind;
begin
  if KeyComp('CtrlGetState') then Result := tkFunction else
    if KeyComp('IS_WINDOWS9X') then Result := tkDefinition else
      if KeyComp('RegDBDeleteValue') then Result := tkFunction else
        if KeyComp('ISLANG_ARABIC_LEBANON') then Result := tkDefinition else
          if KeyComp('DLG_INFO_USEDECIMAL') then Result := tkDefinition else
            if KeyComp('ISLANG_ESTONIAN') then Result := tkDefinition else
              if KeyComp('prototype') then Result := tkKey else Result := tkIdentifier;
end;

function TSynIssSyn.Func160: TtkTokenKind;
begin
  if KeyComp('ISLANG_UKRAINIAN') then Result := tkDefinition else
    if KeyComp('CtrlSetFont') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func161: TtkTokenKind;
begin
  if KeyComp('AddProfString') then Result := tkFunction else
    if KeyComp('DLG_INFO_KUNITS') then Result := tkDefinition else
      if KeyComp('FILE_ATTR_ARCHIVED') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func162: TtkTokenKind;
begin
  if KeyComp('ISLANG_KOREAN_JOHAB') then Result := tkDefinition else
    if KeyComp('DLG_ASK_OPTIONS') then Result := tkDefinition else
      if KeyComp('CtrlGetText') then Result := tkFunction else
        if KeyComp('ISLANG_CHINESE_PRC') then Result := tkDefinition else
          if KeyComp('RegDBKeyExist') then Result := tkFunction else
            if KeyComp('WINDOWS_SHARED') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func163: TtkTokenKind;
begin
  if KeyComp('SdProductName') then Result := tkFunction else
    if KeyComp('LISTBOX_ENTER') then Result := tkDefinition else
      if KeyComp('ISLANG_RUSSIAN') then Result := tkDefinition else
        if KeyComp('NONEXCLUSIVE') then Result := tkDefinition else
          if KeyComp('SdExceptions') then Result := tkFunction else
            if KeyComp('FILE_NO_VERSION') then Result := tkDefinition else
              if KeyComp('ISLANG_FRENCH_CANADIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func164: TtkTokenKind;
begin
  if KeyComp('FILE_ATTR_NORMAL') then Result := tkDefinition else
    if KeyComp('OUT_OF_DISK_SPACE') then Result := tkDefinition else
      if KeyComp('BK_SOLIDYELLOW') then Result := tkDefinition else
        if KeyComp('DLG_USER_CAPTION') then Result := tkDefinition else
          if KeyComp('ConfigGetFileName') then Result := tkFunction else
            if KeyComp('ISLANG_BELARUSIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func165: TtkTokenKind;
begin
  if KeyComp('LISTBOX_SELECT') then Result := tkDefinition else
    if KeyComp('DeleteFolderIcon') then Result := tkFunction else
      if KeyComp('CtrlSetList') then Result := tkFunction else
        if KeyComp('SetErrorMsg') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func166: TtkTokenKind;
begin
  if KeyComp('ISLANG_FRENCH_BELGIAN') then Result := tkDefinition else
    if KeyComp('RegDBSetAppInfo') then Result := tkFunction else
      if KeyComp('ListAddString') then Result := tkFunction else
        if KeyComp('BUTTON_UNCHECKED') then Result := tkDefinition else
          if KeyComp('ISLANG_INDONESIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func167: TtkTokenKind;
begin
  if KeyComp('SdWelcomeMaint') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func168: TtkTokenKind;
begin
  if KeyComp('ISLANG_NORWEGIAN') then Result := tkDefinition else
    if KeyComp('ISLANG_TURKISH') then Result := tkDefinition else
      if KeyComp('SdStartCopy') then Result := tkFunction else
        if KeyComp('SYS_BOOTMACHINE') then Result := tkDefinition else
          if KeyComp('ISLANG_ARABIC_SYRIA') then Result := tkDefinition else
            if KeyComp('ISLANG_DUTCH_BELGIAN') then Result := tkDefinition else
              if KeyComp('MMEDIA_PLAYSYNCH') then Result := tkDefinition else
                if KeyComp('ChangeDirectory') then Result := tkFunction else
                  if KeyComp('FileInsertLine') then Result := tkFunction else
                    if KeyComp('RegDBCreateKeyEx') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func169: TtkTokenKind;
begin
  if KeyComp('MMEDIA_PLAYASYNCH') then Result := tkDefinition else
    if KeyComp('IS_WINDOWSNT') then Result := tkDefinition else
      if KeyComp('ListDeleteItem') then Result := tkFunction else
        if KeyComp('EFF_VERTSTRIPE') then Result := tkDefinition else
          if KeyComp('SetDialogTitle') then Result := tkFunction else
            if KeyComp('ISLANG_ARABIC_EGYPT') then Result := tkDefinition else
              if KeyComp('ListSetIndex') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func170: TtkTokenKind;
begin
  if KeyComp('EXTENDEDMEMORY') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func171: TtkTokenKind;
begin
  if KeyComp('DLG_DIR_DIRECTORY') then Result := tkDefinition else
    if KeyComp('EFF_HORZSTRIPE') then Result := tkDefinition else
      if KeyComp('ISLANG_LITHUANIAN') then Result := tkDefinition else
        if KeyComp('RegDBQueryKey') then Result := tkFunction else
          if KeyComp('CtrlSetState') then Result := tkFunction else
            if KeyComp('SdAskOptions') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func172: TtkTokenKind;
begin
  if KeyComp('CtrlGetCurSel') then Result := tkFunction else
    if KeyComp('StrToLower') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func173: TtkTokenKind;
begin
  if KeyComp('ISLANG_SLOVENIAN') then Result := tkDefinition else
    if KeyComp('EzBatchAddString') then Result := tkFunction else
      if KeyComp('CtrlPGroups') then Result := tkFunction else
        if KeyComp('COMPARE_VERSION') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func174: TtkTokenKind;
begin
  if KeyComp('SdFinishReboot') then Result := tkFunction else
    if KeyComp('CtrlSetText') then Result := tkFunction else
      if KeyComp('ISLANG_ENGLISH_JAMAICA') then Result := tkDefinition else
        if KeyComp('BACKGROUNDCAPTION') then Result := tkDefinition else
          if KeyComp('FULLSCREENSIZE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func175: TtkTokenKind;
begin
  if KeyComp('StrToUpper') then Result := tkFunction else
    if KeyComp('ListDestroy') then Result := tkFunction else
      if KeyComp('ISLANG_VIETNAMESE') then Result := tkDefinition else
        if KeyComp('ReplaceFolderIcon') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func176: TtkTokenKind;
begin
  if KeyComp('LaunchAppAndWait') then Result := tkFunction else
    if KeyComp('GetWindowHandle') then Result := tkFunction else
      if KeyComp('ConfigSetFileName') then Result := tkFunction else
        if KeyComp('ComponentDialog') then Result := tkFunction else
          if KeyComp('FULLWINDOWMODE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func177: TtkTokenKind;
begin
  if KeyComp('StatusUpdate') then Result := tkFunction else
    if KeyComp('SELFREGISTERBATCH') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func178: TtkTokenKind;
begin
  if KeyComp('SdSetupType') then Result := tkFunction else
    if KeyComp('ISLANG_ARABIC_MOROCCO') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func181: TtkTokenKind;
begin
  if KeyComp('ISLANG_ARABIC_KUWAIT') then Result := tkDefinition else
    if KeyComp('SdShowFileMods') then Result := tkFunction else
      if KeyComp('ISLANG_THAI_STANDARD') then Result := tkDefinition else
        if KeyComp('REGDB_ERR_INVALIDNAME') then Result := tkDefinition else
          if KeyComp('INDVFILESTATUS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func182: TtkTokenKind;
begin
  if KeyComp('StrGetTokens') then Result := tkFunction else
    if KeyComp('ISLANG_ARABIC_SAUDIARABIA') then Result := tkDefinition else
      if KeyComp('WriteProfInt') then Result := tkFunction else
        if KeyComp('VER_DLL_NOT_FOUND') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func183: TtkTokenKind;
begin
  if KeyComp('EzConfigAddDriver') then Result := tkFunction else
    if KeyComp('StrLengthChars') then Result := tkFunction else
      if KeyComp('ISLANG_ENGLISH_CANADIAN') then Result := tkDefinition else
        if KeyComp('REGDB_APPPATH_DEFAULT') then Result := tkDefinition else
          if KeyComp('COPY_ERR_CREATEDIR') then Result := tkDefinition else
            if KeyComp('STYLE_UNDERLINE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func184: TtkTokenKind;
begin
  if KeyComp('GetProfString') then Result := tkFunction else
    if KeyComp('ListReadFromFile') then Result := tkFunction else
      if KeyComp('ComponentAddItem') then Result := tkFunction else
        if KeyComp('CtrlSetCurSel') then Result := tkFunction else
          if KeyComp('DISK_TOTALSPACE_EX') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func185: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_CHILE') then Result := tkDefinition else
    if KeyComp('SdConfirmNewDir') then Result := tkFunction else
      if KeyComp('FILE_ATTR_READONLY') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func186: TtkTokenKind;
begin
  if KeyComp('DeinstallStart') then Result := tkFunction else
    if KeyComp('COMPONENT_FIELD_IMAGE') then Result := tkDefinition else
      if KeyComp('ComponentGetData') then Result := tkFunction else
        if KeyComp('ISLANG_SERBIAN_LATIN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func187: TtkTokenKind;
begin
  if KeyComp('GetSystemInfo') then Result := tkFunction else
    if KeyComp('REGDB_STRING_EXPAND') then Result := tkDefinition else
      if KeyComp('SdShowAnyDialog') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func188: TtkTokenKind;
begin
  if KeyComp('SetDisplayEffect') then Result := tkFunction else
    if KeyComp('MATH_COPROCESSOR') then Result := tkDefinition else
      if KeyComp('ISLANG_CZECH_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func189: TtkTokenKind;
begin
  if KeyComp('ISLANG_GREEK_STANDARD') then Result := tkDefinition else
    if KeyComp('COPY_ERR_MEMORY') then Result := tkDefinition else
      if KeyComp('ISLANG_ARABIC_TUNISIA') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func190: TtkTokenKind;
begin
  if KeyComp('ERR_BOX_DRIVEOPEN') then Result := tkDefinition else
    if KeyComp('EzConfigGetValue') then Result := tkFunction else
      if KeyComp('QueryShellMgr') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func191: TtkTokenKind;
begin
  if KeyComp('ISLANG_ENGLISH_CARIBBEAN') then Result := tkDefinition else
    if KeyComp('EXTENSION_ONLY') then Result := tkDefinition else
      if KeyComp('MaintenanceStart') then Result := tkFunction else
        if KeyComp('ListFindString') then Result := tkFunction else
          if KeyComp('REGDB_UNINSTALL_NAME') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func192: TtkTokenKind;
begin
  if KeyComp('SilentWriteData') then Result := tkFunction else
    if KeyComp('FILE_ATTR_SYSTEM') then Result := tkDefinition else
      if KeyComp('CtrlGetMLEText') then Result := tkFunction else
        if KeyComp('REGDB_ERR_INVALIDHANDLE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func193: TtkTokenKind;
begin
  if KeyComp('ISLANG_CHINESE_TAIWAN') then Result := tkDefinition else
    if KeyComp('VER_UPDATE_ALWAYS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func194: TtkTokenKind;
begin
  if KeyComp('SetErrorTitle') then Result := tkFunction else
    if KeyComp('ISLANG_SPANISH_PANAMA') then Result := tkDefinition else
      if KeyComp('EzConfigAddString') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func195: TtkTokenKind;
begin
  if KeyComp('ISLANG_CATALAN_STANDARD') then Result := tkDefinition else
    if KeyComp('HKEY_CLASSES_ROOT') then Result := tkDefinition else
      if KeyComp('COMPONENT_FIELD_MISC') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func196: TtkTokenKind;
begin
  if KeyComp('DLG_MSG_INFORMATION') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func197: TtkTokenKind;
begin
  if KeyComp('ISLANG_ALBANIAN_STANDARD') then Result := tkDefinition else
    if KeyComp('CtrlSelectText') then Result := tkFunction else
      if KeyComp('ISLANG_FRENCH_STANDARD') then Result := tkDefinition else
        if KeyComp('CreateShellObjects') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func198: TtkTokenKind;
begin
  if KeyComp('SdComponentTree') then Result := tkFunction else
    if KeyComp('ISLANG_DANISH_STANDARD') then Result := tkDefinition else
      if KeyComp('REGDB_STRING_MULTI') then Result := tkDefinition else
        if KeyComp('SdRegisterUser') then Result := tkFunction else
          if KeyComp('GetFolderNameList') then Result := tkFunction else
            if KeyComp('ComponentSetData') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func199: TtkTokenKind;
begin
  if KeyComp('DLG_INFO_CHECKSELECTION') then Result := tkDefinition else
    if KeyComp('ISLANG_DUTCH_STANDARD') then Result := tkDefinition else
      if KeyComp('ISLANG_ENGLISH_IRELAND') then Result := tkDefinition else
        if KeyComp('QueryProgItem') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func200: TtkTokenKind;
begin
  if KeyComp('SdComponentDialog2') then Result := tkFunction else
    if KeyComp('SdComponentDialog') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func201: TtkTokenKind;
begin
  if KeyComp('ISLANG_GERMAN_STANDARD') then Result := tkDefinition else
    if KeyComp('ComponentError') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func202: TtkTokenKind;
begin
  if KeyComp('SdShowInfoList') then Result := tkFunction else
    if KeyComp('EzConfigSetValue') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func203: TtkTokenKind;
begin
  if KeyComp('SdDisplayTopics') then Result := tkFunction else
    if KeyComp('CtrlGetSubCommand') then Result := tkFunction else
      if KeyComp('ISLANG_ICELANDIC_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func204: TtkTokenKind;
begin
  if KeyComp('InstallationInfo') then Result := tkFunction else
    if KeyComp('ComponentValidate') then Result := tkFunction else
      if KeyComp('ISLANG_HEBREW_STANDARD') then Result := tkDefinition else
        if KeyComp('CtrlSetMLEText') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func205: TtkTokenKind;
begin
  if KeyComp('ISLANG_FRENCH_SWISS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func207: TtkTokenKind;
begin
  if KeyComp('ISLANG_KOREAN_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func208: TtkTokenKind;
begin
  if KeyComp('SdSetupTypeEx') then Result := tkFunction else
    if KeyComp('ISLANG_SPANISH_PERU') then Result := tkDefinition else
      if KeyComp('ISLANG_BASQUE_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func209: TtkTokenKind;
begin
  if KeyComp('ISLANG_ITALIAN_STANDARD') then Result := tkDefinition else
    if KeyComp('ISLANG_PORTUGUESE') then Result := tkDefinition else
      if KeyComp('ISLANG_GERMAN_SWISS') then Result := tkDefinition else
        if KeyComp('ISLANG_SWEDISH_FINLAND') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func210: TtkTokenKind;
begin
  if KeyComp('ComponentMoveData') then Result := tkFunction else
    if KeyComp('COMPONENT_FIELD_SIZE') then Result := tkDefinition else
      if KeyComp('RegDBGetKeyValueEx') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func211: TtkTokenKind;
begin
  if KeyComp('ListDeleteString') then Result := tkFunction else
    if KeyComp('HKEY_CURRENT_USER') then Result := tkDefinition else
      if KeyComp('COMPONENT_FIELD_FILENEED') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func213: TtkTokenKind;
begin
  if KeyComp('ListGetNextItem') then Result := tkFunction else
    if KeyComp('ListWriteToFile') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func214: TtkTokenKind;
begin
  if KeyComp('ISLANG_JAPANESE_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func215: TtkTokenKind;
begin
  if KeyComp('DeleteProgramFolder') then Result := tkFunction else
    if KeyComp('ISLANG_SPANISH_ECUADOR') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func216: TtkTokenKind;
begin
  if KeyComp('ISLANG_CHINESE_HONGKONG') then Result := tkDefinition else
    if KeyComp('CreateProgramFolder') then Result := tkFunction else
      if KeyComp('COMP_UPDATE_VERSION') then Result := tkDefinition else
        if KeyComp('SdComponentMult') then Result := tkFunction else
          if KeyComp('COPY_ERR_NODISKSPACE') then Result := tkDefinition else
            if KeyComp('ReplaceProfString') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func217: TtkTokenKind;
begin
  if KeyComp('LongPathToQuote') then Result := tkFunction else
    if KeyComp('ISLANG_FAEROESE_STANDARD') then Result := tkDefinition else
      if KeyComp('ISLANG_SPANISH_MEXICAN') then Result := tkDefinition else
        if KeyComp('ISLANG_ITALIAN_SWISS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func218: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_BOLIVIA') then Result := tkDefinition else
    if KeyComp('ISLANG_SPANISH_COLOMBIA') then Result := tkDefinition else
      if KeyComp('ListCurrentItem') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func221: TtkTokenKind;
begin
  if KeyComp('ISLANG_SERBIAN_CYRILLIC') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func222: TtkTokenKind;
begin
  if KeyComp('ISLANG_NORWEGIAN_BOKMAL') then Result := tkDefinition else
    if KeyComp('ISLANG_FINNISH_STANDARD') then Result := tkDefinition else
      if KeyComp('ISLANG_LATVIAN_STANDARD') then Result := tkDefinition else
        if KeyComp('RegDBSetKeyValueEx') then Result := tkFunction else
          if KeyComp('ISLANG_POLISH_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func223: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_NICARAGUA') then Result := tkDefinition else
    if KeyComp('ListGetFirstItem') then Result := tkFunction else
      if KeyComp('ISLANG_AFRIKAANS_STANDARD') then Result := tkDefinition else
        if KeyComp('ISLANG_SLOVAK_STANDARD') then Result := tkDefinition else
          if KeyComp('ISLANG_GERMAN_AUSTRIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func224: TtkTokenKind;
begin
  if KeyComp('VerGetFileVersion') then Result := tkFunction else
    if KeyComp('ISLANG_CROATIAN_STANDARD') then Result := tkDefinition else
      if KeyComp('COMPONENT_FIELD_SELECTED') then Result := tkDefinition else
        if KeyComp('USER_ADMINISTRATOR') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func226: TtkTokenKind;
begin
  if KeyComp('ISCompareServicePack') then Result := tkFunction else
    if KeyComp('VerFindFileVersion') then Result := tkFunction else
      if KeyComp('DLG_ERR_ALREADY_EXISTS') then Result := tkDefinition else
        if KeyComp('ProgDefGroupType') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func227: TtkTokenKind;
begin
  if KeyComp('ShowProgramFolder') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func228: TtkTokenKind;
begin
  if KeyComp('ISLANG_BULGARIAN_STANDARD') then Result := tkDefinition else
    if KeyComp('SdRegisterUserEx') then Result := tkFunction else
      if KeyComp('ISLANG_ROMANIAN_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func229: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_GUATEMALA') then Result := tkDefinition else
    if KeyComp('ISLANG_CHINESE_SINGAPORE') then Result := tkDefinition else
      if KeyComp('SdComponentDialogAdv') then Result := tkFunction else
        if KeyComp('COMPONENT_FIELD_VISIBLE') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func230: TtkTokenKind;
begin
  if KeyComp('ISLANG_SWEDISH_STANDARD') then Result := tkDefinition else
    if KeyComp('COPY_ERR_OPENINPUT') then Result := tkDefinition else
      if KeyComp('RegDBSetDefaultRoot') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func231: TtkTokenKind;
begin
  if KeyComp('GetValidDrivesList') then Result := tkFunction else
    if KeyComp('CreateRegistrySet') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func232: TtkTokenKind;
begin
  if KeyComp('FILE_MODE_BINARYREADONLY') then Result := tkDefinition else
    if KeyComp('ComponentFilterOS') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func233: TtkTokenKind;
begin
  if KeyComp('ComponentRemoveAll') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func234: TtkTokenKind;
begin
  if KeyComp('SdAskOptionsList') then Result := tkFunction else
    if KeyComp('VerSearchAndUpdateFile') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func236: TtkTokenKind;
begin
  if KeyComp('ISLANG_HUNGARIAN_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func237: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_ARGENTINA') then Result := tkDefinition else
    if KeyComp('DeinstallSetReference') then Result := tkFunction else
      if KeyComp('ISLANG_SPANISH_COSTARICA') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func238: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_PARAGUAY') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func240: TtkTokenKind;
begin
  if KeyComp('ISLANG_ESTONIAN_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func241: TtkTokenKind;
begin
  if KeyComp('ISLANG_UKRAINIAN_STANDARD') then Result := tkDefinition else
    if KeyComp('ISLANG_ENGLISH_NEWZEALAND') then Result := tkDefinition else
      if KeyComp('CtrlGetMultCurSel') then Result := tkFunction else
        if KeyComp('ComponentReinstall') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func242: TtkTokenKind;
begin
  if KeyComp('ComponentSelectItem') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func244: TtkTokenKind;
begin
  if KeyComp('ISLANG_RUSSIAN_STANDARD') then Result := tkDefinition else
    if KeyComp('SetStatusWindow') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func245: TtkTokenKind;
begin
  if KeyComp('ISLANG_BELARUSIAN_STANDARD') then Result := tkDefinition else
    if KeyComp('REGDB_ERR_INITIALIZATION') then Result := tkDefinition else
      if KeyComp('ComponentSetTarget') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func246: TtkTokenKind;
begin
  if KeyComp('ComponentInitialize') then Result := tkFunction else
    if KeyComp('RegDBConnectRegistry') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func247: TtkTokenKind;
begin
  if KeyComp('ISLANG_INDONESIAN_STANDARD') then Result := tkDefinition else
    if KeyComp('GetProfStringList') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func248: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_HONDURAS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func249: TtkTokenKind;
begin
  if KeyComp('ISLANG_TURKISH_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func250: TtkTokenKind;
begin
  if KeyComp('MMEDIA_PLAYCONTINUOUS') then Result := tkDefinition else
    if KeyComp('SetInstallationInfo') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func251: TtkTokenKind;
begin
  if KeyComp('COMPONENT_VALUE_CRITICAL') then Result := tkDefinition else
    if KeyComp('COMPONENT_FIELD_STATUS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func252: TtkTokenKind;
begin
  if KeyComp('ISLANG_LITHUANIAN_STANDARD') then Result := tkDefinition else
    if KeyComp('ISLANG_ENGLISH_AUSTRALIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func253: TtkTokenKind;
begin
  if KeyComp('CtrlSetMultCurSel') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func254: TtkTokenKind;
begin
  if KeyComp('ISLANG_FRENCH_LUXEMBOURG') then Result := tkDefinition else
    if KeyComp('ISLANG_SLOVENIAN_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func255: TtkTokenKind;
begin
  if KeyComp('SdOptionsButtons') then Result := tkFunction else
    if KeyComp('ListGetNextString') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func256: TtkTokenKind;
begin
  if KeyComp('ISLANG_VIETNAMESE_STANDARD') then Result := tkDefinition else
    if KeyComp('ComponentListItems') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func257: TtkTokenKind;
begin
  if KeyComp('COMPONENT_VALUE_STANDARD') then Result := tkDefinition else
    if KeyComp('ERR_PERFORM_AFTER_REBOOT') then Result := tkDefinition else
      if KeyComp('ComponentTotalSize') then Result := tkFunction else
        if KeyComp('ISLANG_ENGLISH_SOUTHAFRICA') then Result := tkDefinition else
          if KeyComp('ISLANG_SPANISH_ELSALVADOR') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func258: TtkTokenKind;
begin
  if KeyComp('ISLANG_GERMAN_LUXEMBOURG') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func259: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_VENEZUELA') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func260: TtkTokenKind;
begin
  if KeyComp('StrRemoveLastSlash') then Result := tkFunction else
    if KeyComp('ListCurrentString') then Result := tkFunction else
      if KeyComp('ComponentTransferData') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func262: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_URUGUAY') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func263: TtkTokenKind;
begin
  if KeyComp('ISLANG_GERMAN_LIECHTENSTEIN') then Result := tkDefinition else
    if KeyComp('COPY_ERR_OPENOUTPUT') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func264: TtkTokenKind;
begin
  if KeyComp('ListSetCurrentItem') then Result := tkFunction else
    if KeyComp('COMPONENT_FIELD_CDROM_FOLDER') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func265: TtkTokenKind;
begin
  if KeyComp('COPY_ERR_TARGETREADONLY') then Result := tkDefinition else
    if KeyComp('ListGetFirstString') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func266: TtkTokenKind;
begin
  if KeyComp('COMPONENT_FIELD_PASSWORD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func267: TtkTokenKind;
begin
  if KeyComp('LongPathToShortPath') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func269: TtkTokenKind;
begin
  if KeyComp('ComponentGetItemSize') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func270: TtkTokenKind;
begin
  if KeyComp('COMPONENT_FIELD_DISPLAYNAME') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func273: TtkTokenKind;
begin
  if KeyComp('ComponentFilterLanguage') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func274: TtkTokenKind;
begin
  if KeyComp('SdConfirmRegistration') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func280: TtkTokenKind;
begin
  if KeyComp('RegDBDisConnectRegistry') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func282: TtkTokenKind;
begin
  if KeyComp('ComponentIsItemSelected') then Result := tkFunction else
    if KeyComp('COMPONENT_FIELD_FTPLOCATION') then Result := tkDefinition else
      if KeyComp('ISLANG_ENGLISH_UNITEDKINGDOM') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func283: TtkTokenKind;
begin
  if KeyComp('COMPONENT_FIELD_DESCRIPTION') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func284: TtkTokenKind;
begin
  if KeyComp('ISLANG_NORWEGIAN_NYNORSK') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func285: TtkTokenKind;
begin
  if KeyComp('REGDB_ERR_CONNECTIONEXISTS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func286: TtkTokenKind;
begin
  if KeyComp('LongPathFromShortPath') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func288: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_PUERTORICO') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func289: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_MODERNSORT') then Result := tkDefinition else
    if KeyComp('ComponentGetTotalCost') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func290: TtkTokenKind;
begin
  if KeyComp('ISLANG_PORTUGUESE_STANDARD') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func292: TtkTokenKind;
begin
  if KeyComp('SELFREGISTRATIONPROCESS') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func293: TtkTokenKind;
begin
  if KeyComp('ISLANG_ENGLISH_UNITEDSTATES') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func301: TtkTokenKind;
begin
  if KeyComp('ISLANG_PORTUGUESE_BRAZILIAN') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func304: TtkTokenKind;
begin
  if KeyComp('COMPONENT_FIELD_HTTPLOCATION') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func306: TtkTokenKind;
begin
  if KeyComp('ListSetCurrentString') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func310: TtkTokenKind;
begin
  if KeyComp('SETUPTYPE_INFO_DISPLAYNAME') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func316: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_DOMINICANREPUBLIC') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func318: TtkTokenKind;
begin
  if KeyComp('CreateCreateInstallationInfo') then Result := tkFunction else
    if KeyComp('REGDB_ERR_CORRUPTEDREGISTRY') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func323: TtkTokenKind;
begin
  if KeyComp('ComponentSetupTypeSet') then Result := tkFunction else
    if KeyComp('SETUPTYPE_INFO_DESCRIPTION') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func333: TtkTokenKind;
begin
  if KeyComp('ComponentSetupTypeEnum') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func340: TtkTokenKind;
begin
  if KeyComp('ComponentSetupTypeGetData') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.Func343: TtkTokenKind;
begin
  if KeyComp('ISLANG_SPANISH_TRADITIONALSORT') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func344: TtkTokenKind;
begin
  if KeyComp('COMPONENT_VALUE_HIGHLYRECOMMENDED') then Result := tkDefinition else Result := tkIdentifier;
end;

function TSynIssSyn.Func366: TtkTokenKind;
begin
  if KeyComp('ComponentCompareSizeRequired') then Result := tkFunction else Result := tkIdentifier;
end;

function TSynIssSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TSynIssSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey <= MaxKey then
    Result := TIdentFuncTableFunc(fIdentFuncTable[HashKey])()
  else
    Result := tkIdentifier;
end;

procedure TSynIssSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      #0: fProcTable[I] := @NullProc;
      #10: fProcTable[I] := @LFProc;
      #13: fProcTable[I] := @CRProc;
      #1..#9, #11, #12, #14..#32 : fProcTable[I] := @SpaceProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := @IdentProc;
      '0'..'9': fProcTable[I] := @NumberProc;
      '/': fProcTable[I]  := @SlashProc;
      '''': fProcTable[I] := @StringProc;
      '"': fProcTable[I]  := @QuoteStringProc;
      '&': fProcTable[I]  := @AndSymbolProc;
      '}': fProcTable[I]  := @BraceCloseProc;
      '{': fProcTable[I]  := @BraceOpenProc;
      '>': fProcTable[I]  := @GreaterProc;
      '<': fProcTable[I]  := @LowerProc;
      ')': fProcTable[I]  := @RoundCloseProc;
      '(': fProcTable[I]  := @RoundOpenProc;
      ']': fProcTable[I]  := @SquareCloseProc;
      '[': fProcTable[I]  := @SquareOpenProc;
      ':': fProcTable[I]  := @ColonProc;
      ',': fProcTable[I]  := @CommaProc;
      ';': fProcTable[I]  := @SemiColonProc;
      '#': fProcTable[I]  := @DirectiveProc;
      '=': fProcTable[I]  := @EqualProc;
      '?': fProcTable[I]  := @QuestionProc;
      '+': fProcTable[I]  := @PlusProc;
      '-': fProcTable[I]  := @MinusProc;
      '*': fProcTable[I]  := @StarProc;
      '%': fProcTable[I]  := @ModSymbolProc;
      '!': fProcTable[I]  := @NotSymbolProc;
      '|': fProcTable[I]  := @OrSymbolProc;
      '.': fProcTable[I]  := @PointProc;
      '~': fProcTable[I]  := @TildeProc;
    else
      fProcTable[I] := @UnknownProc;
    end;
end;

constructor TSynIssSyn.Create(AOwner: TComponent);
const
  SYNS_AttrDefinition = 'ISS Attr Definition';
begin
  inherited Create(AOwner);
  fCommentAttri := TSynHighLighterAttributes.Create(SYNS_AttrComment);
  fCommentAttri.Foreground := clGreen;
  AddAttribute(fCommentAttri);

  fDefinitionAttri := TSynHighLighterAttributes.Create(SYNS_AttrDefinition);
  fDefinitionAttri.Foreground := $00996600;
  AddAttribute(fDefinitionAttri);

  fDirectiveAttri := TSynHighLighterAttributes.Create(SYNS_AttrDirective);
  fDirectiveAttri.Foreground := clBlue;
  AddAttribute(fDirectiveAttri);

  fFunctionAttri := TSynHighLighterAttributes.Create(SYNS_AttrFunction);
  fFunctionAttri.Foreground := $00C05000;
  AddAttribute(fFunctionAttri);

  fIdentifierAttri := TSynHighLighterAttributes.Create(SYNS_AttrIdentifier);
  fIdentifierAttri.Foreground := clWindowText;
  AddAttribute(fIdentifierAttri);

  fKeyAttri := TSynHighLighterAttributes.Create(SYNS_AttrReservedWord);
  fKeyAttri.Foreground := clBlue;
  AddAttribute(fKeyAttri);

  fNumberAttri := TSynHighLighterAttributes.Create(SYNS_AttrNumber);
  fNumberAttri.Foreground  := clPurple;
  AddAttribute(fNumberAttri);

  fSpaceAttri := TSynHighLighterAttributes.Create(SYNS_AttrSpace);
  AddAttribute(fSpaceAttri);

  fStringAttri := TSynHighLighterAttributes.Create(SYNS_AttrString);
  fStringAttri.Foreground  := clMaroon;
  AddAttribute(fStringAttri);

  fSymbolAttri := TSynHighLighterAttributes.Create(SYNS_AttrSymbol);
  fSymbolAttri.Foreground  := clNavy;
  AddAttribute(fSymbolAttri);

  SetAttributesOnChange(@DefHighlightChange);
  InitIdent;
  MakeMethodTables;
  fRange := rsUnknown;
end;

procedure TSynIssSyn.SpaceProc;
begin
  fTokenID := tkSpace;
  repeat
    Inc(Run);
  until not (fLine[Run] in [#1..#32]);
end;

procedure TSynIssSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TSynIssSyn.CRProc;
begin
  fTokenID := tkSpace;
  Inc(Run);
  if fLine[Run] = #10 then
    Inc(Run);
end;

procedure TSynIssSyn.LFProc;
begin
  fTokenID := tkSpace;
  Inc(Run);
end;

procedure TSynIssSyn.AnsiCProc;
begin
  fTokenID := tkComment;
  case FLine[Run] of
    #0:
      begin
        NullProc;
        exit;
      end;
    #10:
      begin
        LFProc;
        exit;
      end;
    #13:
      begin
        CRProc;
        exit;
      end;
  end;

  while FLine[Run] <> #0 do
    case FLine[Run] of
      '*':
        if fLine[Run + 1] = '/' then
        begin
          Inc(Run, 2);
          if (fRange = rsDirectiveComment) and not (fLine[Run] in [#0, #13, #10]) then
            fRange := rsMultiLineDirective
          else
            fRange := rsUnKnown;
          Break;
        end 
        else
          Inc(Run);
        #10: break;
      #13: break;
      else 
        inc(Run);
    end;
end;

procedure TSynIssSyn.DirectiveEndProc; // added to support multiline directives properly
begin
  fTokenID := tkDirective;
  case FLine[Run] of
    #0:
      begin
        NullProc;
        Exit;
      end;
    #10:
      begin
        LFProc;
        Exit;
      end;
    #13:
      begin
        CRProc;
        Exit;
      end;
  end;
  fRange := rsUnknown;
  repeat
    case FLine[Run] of
      #0, #10, #13: Break;
      '/': // comment?
        begin
          case fLine[Run + 1] of
            '/': // is end of directive as well
            begin
              fRange := rsUnknown;
              Exit;
            end;
            '*': // might be embedded only
            begin
              fRange := rsDirectiveComment;
              Exit;
            end;
          end;
        end;
      '\': // yet another line?
      begin
        if fLine[Run + 1] = #0 then
        begin
          Inc(Run);
          fRange := rsMultiLineDirective;
          Exit;
        end;
      end;
    end;
    Inc(Run);
  until fLine[Run] in [#0, #10, #13];
end;

procedure TSynIssSyn.CommentProc;
begin
  fTokenID := tkComment;

  case FLine[Run] of
    #0:
      begin
        NullProc;
        Exit;
      end;
    #10:
      begin
        LFProc;
        Exit;
      end;
    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  fRange := rsUnknown;

  while not (fLine[Run] in [#0, #10, #13]) do Inc(Run);
  if fLine[Run - 1] = '\' then
    fRange := rsMultiComment;
end;

procedure TSynIssSyn.SlashProc;
begin
  case FLine[Run + 1] of
    '/':                               {c++ style comments}
    begin
      fTokenID := tkComment;
      inc(Run, 2);
      while not (fLine[Run] in [#0, #10, #13]) do Inc(Run);
      if fLine[Run - 1] = '\' then
        fRange := rsMultiComment;
    end;
    '*':                               {c style comments}
    begin
      fTokenID := tkComment;
      if fRange <> rsDirectiveComment then
        fRange := rsAnsiC;
      Inc(Run, 2);
      while fLine[Run] <> #0 do
        case fLine[Run] of
          '*':
            if fLine[Run + 1] = '/' then
            begin
              inc(Run, 2);
              if fRange = rsDirectiveComment then
                fRange := rsMultiLineDirective
              else
              begin
                fRange := rsUnKnown;
              end;
              Break;
            end 
            else 
              Inc(Run);
            #10, #13:
            begin
              if fRange = rsDirectiveComment then
                fRange := rsAnsiC;
              Break;
            end;
          else 
            Inc(Run);
        end;
    end;
    '=':                               {divide assign}
    begin
      Inc(Run, 2);
      fTokenID := tkSymbol;
    end;
    else                               {divide}
    begin
      Inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TSynIssSyn.StringProc;
begin
  fTokenID := tkString;
  repeat
    if fLine[Run] = '\' then
    begin
      if fLine[Run + 1] in [#39, '\'] then
        Inc(Run);
    end;
    Inc(Run);
  until fLine[Run] in [#0, #10, #13, #39];
  if fLine[Run] = #39 then
    Inc(Run);
end;

procedure TSynIssSyn.QuoteStringProc;
begin
  fTokenID := tkString;
  repeat
    if fLine[Run] = '\' then 
    begin
      case fLine[Run + 1] of
        #34, '\':
          Inc(Run);
        #00:
        begin
          Inc(Run);
          fRange := rsMultilineString;
          Exit;
        end;
      end;
    end;
    Inc(Run);
  until fLine[Run] in [#0, #10, #13, #34];
  if FLine[Run] = #34 then
    Inc(Run);
end;

procedure TSynIssSyn.StringEndProc;
begin
  fTokenID := tkString;

  case FLine[Run] of
    #0:
      begin
        NullProc;
        Exit;
      end;
    #10:
      begin
        LFProc;
        Exit;
      end;
    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  fRange := rsUnknown;

  repeat
    case FLine[Run] of
      #0, #10, #13: Break;
      '\':
      begin
        case fLine[Run + 1] of
          #34, '\':
            Inc(Run);
          #00:
          begin
            Inc(Run);
            fRange := rsMultilineString;
            Exit;
          end;
        end;
      end;
      #34: Break;
    end;
    Inc(Run);
  until fLine[Run] in [#0, #10, #13, #34];
  if FLine[Run] = #34 then
    Inc(Run);
end;

procedure TSynIssSyn.AndSymbolProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2); // and assign
    '&': Inc(Run, 2); // logical and
    else Inc(Run);    // and
  end;
end;

procedure TSynIssSyn.BraceCloseProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynIssSyn.BraceOpenProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynIssSyn.GreaterProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2);                {greater than or equal to}
    '>':
    begin
      if FLine[Run + 2] = '=' then   {shift right assign}
        Inc(Run, 3)
      else                           {shift right}
        Inc(Run, 2);
    end;
    else                             {greater than}
      Inc(run);
  end;
end;

procedure TSynIssSyn.LowerProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2);               {less than or equal to}
    '<':
    begin
      if FLine[Run + 2] = '=' then  {shift left assign}
        Inc(Run, 3)
      else                          {shift left}
        Inc(Run, 2);
    end;
    else Inc(Run);                  {less than}
  end;
end;

procedure TSynIssSyn.RoundCloseProc;
begin
  Inc(Run);
  fTokenID := tkSymbol;
end;

procedure TSynIssSyn.RoundOpenProc;
begin
  Inc(Run);
  FTokenID := tkSymbol;
end;

procedure TSynIssSyn.SquareCloseProc;
begin
  Inc(Run);
  fTokenID := tkSymbol;
end;

procedure TSynIssSyn.SquareOpenProc;
begin
  Inc(Run);
  fTokenID := tkSymbol;
end;

procedure TSynIssSyn.ColonProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    ':': Inc(Run, 2); {scope resolution operator}
    else              {colon}
      Inc(Run);
  end;
end;

procedure TSynIssSyn.CommaProc;
begin
  Inc(Run);
  fTokenID := tkSymbol;
end;

procedure TSynIssSyn.SemiColonProc;
begin
  Inc(Run);
  fTokenID := tkSymbol;
end;

procedure TSynIssSyn.DirectiveProc; //Detect directive keywords   //Kan
begin
  fTokenID := tkDirective;
  Inc(Run);

  {#define}
  if (FLine[Run] = 'd') and (FLine[Run + 1] = 'e') and (FLine[Run + 2] = 'f')
    and (FLine[Run + 3] = 'i') and (FLine[Run + 4] = 'n') and (FLine[Run + 5] = 'e') then
  begin
    inc(Run, 5);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#elif}
  if (FLine[Run] = 'e') and (FLine[Run + 1] = 'l') and (FLine[Run + 2] = 'i')
    and (FLine[Run + 3] = 'f') then
  begin
    inc(Run, 3);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#else}
  if (FLine[Run] = 'e') and (FLine[Run + 1] = 'l') and (FLine[Run + 2] = 's')
    and (FLine[Run + 3] = 'e') then
  begin
    inc(Run, 3);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#endif}
  if (FLine[Run] = 'e') and (FLine[Run + 1] = 'n') and (FLine[Run + 2] = 'd')
    and (FLine[Run + 3] = 'i') and (FLine[Run + 4] = 'f') then
  begin
    inc(Run, 4);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#error}
  if (FLine[Run] = 'e') and (FLine[Run + 1] = 'r') and (FLine[Run + 2] = 'r')
    and (FLine[Run + 3] = 'o') and (FLine[Run + 4] = 'r') then
  begin
    inc(Run, 4);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#if/#ifdef/#ifndef}
  if (FLine[Run] = 'i') and (FLine[Run + 1] = 'f') then
  begin
    inc(Run, 1);
    fTokenID := tkDirective;
    inc(Run);
    case FLine[Run] of
      'd':
        begin
          if (FLine[Run + 1] = 'e') and (FLine[Run + 2] = 'f') then
          begin
            inc(Run, 2);
            fTokenID := tkDirective;
            inc(Run);
          end;
        end;
      'n':
        begin
          if (FLine[Run + 1] = 'd') and (FLine[Run + 2] = 'e') and (FLine[Run + 3] = 'f') then
          begin
            inc(Run, 3);
            fTokenID := tkDirective;
            inc(Run);
          end;
        end;
    end;
  end;

  {#import}
  if (FLine[Run] = 'i') and (FLine[Run + 1] = 'm') and (FLine[Run + 2] = 'p')
    and (FLine[Run + 3] = 'o') and (FLine[Run + 4] = 'r') and (FLine[Run + 5] = 't') then
  begin
    inc(Run, 5);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#include}
  if (FLine[Run] = 'i') and (FLine[Run + 1] = 'n') and (FLine[Run + 2] = 'c')
    and (FLine[Run + 3] = 'l') and (FLine[Run + 4] = 'u') and (FLine[Run + 5] = 'd') and
    (FLine[Run + 6] = 'e') then
  begin
    inc(Run, 6);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#line}
  if (FLine[Run] = 'l') and (FLine[Run + 1] = 'i') and (FLine[Run + 2] = 'n')
    and (FLine[Run + 3] = 'e') then
  begin
    inc(Run, 3);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#pragma}
  if (FLine[Run] = 'p') and (FLine[Run + 1] = 'r') and (FLine[Run + 2] = 'a')
    and (FLine[Run + 3] = 'g') and (FLine[Run + 4] = 'm') and (FLine[Run + 5] = 'a') then
  begin
    inc(Run, 5);
    fTokenID := tkDirective;
    inc(Run);
  end;

  {#undef}
  if (FLine[Run] = 'u') and (FLine[Run + 1] = 'n') and (FLine[Run + 2] = 'd')
    and (FLine[Run + 3] = 'e') and (FLine[Run + 4] = 'f') then
  begin
    inc(Run, 4);
    fTokenID := tkDirective;
    inc(Run);
  end;
end;

procedure TSynIssSyn.EqualProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2); {logical equal}
    else              {assign}
      Inc(Run);
  end;
end;

procedure TSynIssSyn.QuestionProc;
begin
  fTokenID := tkSymbol;                {conditional}
  Inc(Run);
end;

procedure TSynIssSyn.PlusProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2);    {add assign}
    '+': Inc(Run, 2);    {increment}
    else                 {add}
      Inc(Run);
  end;
end;

procedure TSynIssSyn.MinusProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2);                              {subtract assign}
    '-': Inc(Run, 2);                              {decrement}
    '>': Inc(Run, 2);                              {arrow}
    else Inc(Run);                                 {subtract}
  end;
end;

procedure TSynIssSyn.StarProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2);                              {multiply assign}
    else Inc(Run);                                 {star}
  end;
end;

procedure TSynIssSyn.ModSymbolProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2);                              {mod assign}
    else Inc(Run);                                 {mod}
  end;
end;

procedure TSynIssSyn.NotSymbolProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2);                              {not equal}
    else Inc(Run);                                 {not}
  end;
end;

procedure TSynIssSyn.OrSymbolProc;
begin
  fTokenID := tkSymbol;
  case FLine[Run + 1] of
    '=': Inc(Run, 2);                              {or assign}
    '|': Inc(Run, 2);                              {logical or}
    else Inc(Run);                                 {or}
  end;
end;

procedure TSynIssSyn.PointProc;
begin
  fTokenID := tkSymbol;
  if (FLine[Run + 1] = '.') and (FLine[Run + 2] = '.') then {ellipse}
    Inc(Run, 3)
  else if FLine[Run + 1] in ['0'..'9'] then // float
  begin
    Dec(Run); // numberproc must see the point
    NumberProc;
  end
  else                                 {point}
    Inc(Run);
end;

procedure TSynIssSyn.TildeProc;
begin
  Inc(Run);                            {bitwise complement}
  fTokenId := tkSymbol;
end;

procedure TSynIssSyn.NumberProc;
begin
  Inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in
    ['0'..'9', '.', 'u', 'U', 'l', 'L', 'x', 'X', 'e', 'E', 'f', 'F'] do //Kan
    //['0'..'9', 'A'..'F', 'a'..'f', '.', 'u', 'U', 'l', 'L', 'x', 'X'] do //Commented by Kan
  begin
    case FLine[Run] of
      '.': if FLine[Run + 1] = '.' then break;
    end;
    Inc(Run);
  end;
end;

procedure TSynIssSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  Inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do Inc(Run);
end;

procedure TSynIssSyn.UnknownProc;
var
  i:Integer;
begin
  if fLine[Run]>#127 then
    i:=UTF8CharacterLength(@fLine[Run])
    else
      i:=1;
  Inc(Run,i);
  fTokenID := tkUnknown;
end;

procedure TSynIssSyn.SetLine(const NewValue: String; LineNumber: Integer);
begin
  fLineRef := NewValue;
  fLine := PChar(fLineRef);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end;

procedure TSynIssSyn.Next;
begin
  fTokenPos := Run;
  case fRange of
    rsAnsiC, rsDirectiveComment: AnsiCProc;
    rsMultiLineDirective: DirectiveEndProc;
    rsMultilineString: StringEndProc;
    rsMultiComment:  CommentProc;
    else
    begin
      fRange := rsUnknown;
      fProcTable[fLine[Run]];
    end;
  end;
end;

function TSynIssSyn.GetDefaultAttribute(Index: integer
  ): TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT    : Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER : Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD    : Result := fKeyAttri;
    SYN_ATTR_STRING     : Result := fStringAttri;
    SYN_ATTR_WHITESPACE : Result := fSpaceAttri;
    SYN_ATTR_SYMBOL     : Result := fSymbolAttri;
  else
    Result := nil;
  end;
end;

function TSynIssSyn.GetEol: Boolean;
begin
  Result := fTokenID = tkNull;
end;

function TSynIssSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

procedure TSynIssSyn.GetTokenEx(out TokenStart: PChar; out TokenLength: integer
  );
begin
  TokenStart:=fLine+fTokenPos;
  TokenLength:=Run-fTokenPos;
end;

function TSynIssSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TSynIssSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case GetTokenID of
    tkComment: Result := fCommentAttri;
    tkDefinition: Result := fDefinitionAttri;
    tkDirective: Result := fDirectiveAttri;
    tkFunction: Result := fFunctionAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fIdentifierAttri;
  else
    Result := nil;
  end;
end;

function TSynIssSyn.GetTokenKind: integer;
begin
  Result := Ord(fTokenId);
end;

function TSynIssSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

function TSynIssSyn.GetIdentChars: TSynIdentChars;
begin
  Result := ['_', 'a'..'z', 'A'..'Z', '0'..'9'];
end;

procedure TSynIssSyn.ResetRange;
begin
  fRange := rsUnknown;
end;

procedure TSynIssSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TSynIssSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

initialization
  MakeIdentTable;
  RegisterPlaceableHighlighter(TSynIssSyn);
end.
