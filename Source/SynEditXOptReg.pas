{-------------------------------------------------------------------------------
  SynEditXOptReg - Property Editors for TSynXOpt
  Provides dropdown lists in the IDE designer for:
  - Keyboard layout selection
  - Input mode selection
  - Case conversion selection
-------------------------------------------------------------------------------}
unit SynEditXOptReg;

{$I SynEdit.inc}

interface

uses
  DesignIntf,
  DesignEditors,
  Classes;

type
  { Property editor for TargetLayoutId - shows dropdown with installed layouts }
  TSynXOptLayoutIdProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

procedure Register;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  SynEditXOpt;

{ TSynXOptLayoutIdProperty }

function TSynXOptLayoutIdProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paRevertable];
end;

procedure TSynXOptLayoutIdProperty.GetValues(Proc: TGetStrProc);
var
  LayoutList: array[0..63] of HKL;
  LayoutCount, I: Integer;
  LocaleName: array[0..85] of Char;
  LangId: Word;
  LayoutId: string;
begin
  LayoutCount := GetKeyboardLayoutList(Length(LayoutList), LayoutList);

  for I := 0 to LayoutCount - 1 do
  begin
    LangId := LoWord(NativeUInt(LayoutList[I]));

    if GetLocaleInfo(LangId, LOCALE_SLANGUAGE, LocaleName, Length(LocaleName)) > 0 then
      LayoutId := Format('%.8x (%s)', [LangId, LocaleName])
    else
      LayoutId := Format('%.8x', [LangId]);

    Proc(LayoutId);
  end;
end;

procedure Register;
begin
  // Register property editor for Keyboard.TargetLayoutId
  RegisterPropertyEditor(TypeInfo(string), TSynXOptKeyboard, 'TargetLayoutId', TSynXOptLayoutIdProperty);
end;

end.
