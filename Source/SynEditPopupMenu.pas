{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

SynEdit Popup Menu Component
Author: Created 2026-02-04
Description: Standard context menu for TSynEdit using system localization
-------------------------------------------------------------------------------}

unit SynEditPopupMenu;

{$I SynEdit.inc}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Vcl.Menus,
  SynEdit;

type
  TSynEditPopupMenu = class(TPopupMenu)
  private
    FEditor: TSynEdit;

    // Menu items
    FMenuUndo: TMenuItem;
    FMenuRedo: TMenuItem;
    FMenuSep1: TMenuItem;
    FMenuCut: TMenuItem;
    FMenuCopy: TMenuItem;
    FMenuPaste: TMenuItem;
    FMenuDelete: TMenuItem;
    FMenuSep2: TMenuItem;
    FMenuSelectAll: TMenuItem;

    procedure SetEditor(const Value: TSynEdit);

    // Command handlers
    procedure DoUndo(Sender: TObject);
    procedure DoRedo(Sender: TObject);
    procedure DoCut(Sender: TObject);
    procedure DoCopy(Sender: TObject);
    procedure DoPaste(Sender: TObject);
    procedure DoDelete(Sender: TObject);
    procedure DoSelectAll(Sender: TObject);

    procedure OnPopupHandler(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Editor: TSynEdit read FEditor write SetEditor;
  end;

procedure Register;

implementation

uses
  Vcl.Clipbrd;

{ TSynEditPopupMenu }

constructor TSynEditPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FEditor := nil;
  OnPopup := OnPopupHandler;

  // Create menu items with system localized captions
  FMenuUndo := TMenuItem.Create(Self);
  FMenuUndo.Caption := '&Undo';
  FMenuUndo.ShortCut := ShortCut(Ord('Z'), [ssCtrl]);
  FMenuUndo.OnClick := DoUndo;
  Items.Add(FMenuUndo);

  FMenuRedo := TMenuItem.Create(Self);
  FMenuRedo.Caption := '&Redo';
  FMenuRedo.ShortCut := ShortCut(Ord('Y'), [ssCtrl]);
  FMenuRedo.OnClick := DoRedo;
  Items.Add(FMenuRedo);

  FMenuSep1 := TMenuItem.Create(Self);
  FMenuSep1.Caption := '-';
  Items.Add(FMenuSep1);

  FMenuCut := TMenuItem.Create(Self);
  FMenuCut.Caption := 'Cu&t';
  FMenuCut.ShortCut := ShortCut(Ord('X'), [ssCtrl]);
  FMenuCut.OnClick := DoCut;
  Items.Add(FMenuCut);

  FMenuCopy := TMenuItem.Create(Self);
  FMenuCopy.Caption := '&Copy';
  FMenuCopy.ShortCut := ShortCut(Ord('C'), [ssCtrl]);
  FMenuCopy.OnClick := DoCopy;
  Items.Add(FMenuCopy);

  FMenuPaste := TMenuItem.Create(Self);
  FMenuPaste.Caption := '&Paste';
  FMenuPaste.ShortCut := ShortCut(Ord('V'), [ssCtrl]);
  FMenuPaste.OnClick := DoPaste;
  Items.Add(FMenuPaste);

  FMenuDelete := TMenuItem.Create(Self);
  FMenuDelete.Caption := '&Delete';
  FMenuDelete.ShortCut := ShortCut($2E, []); // VK_DELETE
  FMenuDelete.OnClick := DoDelete;
  Items.Add(FMenuDelete);

  FMenuSep2 := TMenuItem.Create(Self);
  FMenuSep2.Caption := '-';
  Items.Add(FMenuSep2);

  FMenuSelectAll := TMenuItem.Create(Self);
  FMenuSelectAll.Caption := 'Select &All';
  FMenuSelectAll.ShortCut := ShortCut(Ord('A'), [ssCtrl]);
  FMenuSelectAll.OnClick := DoSelectAll;
  Items.Add(FMenuSelectAll);
end;

procedure TSynEditPopupMenu.SetEditor(const Value: TSynEdit);
begin
  FEditor := Value;
end;

procedure TSynEditPopupMenu.OnPopupHandler(Sender: TObject);
begin
  if not Assigned(FEditor) then Exit;

  // Enable/disable items based on editor state
  FMenuUndo.Enabled := FEditor.CanUndo;
  FMenuRedo.Enabled := FEditor.CanRedo;
  FMenuCut.Enabled := (not FEditor.ReadOnly) and FEditor.SelAvail;
  FMenuCopy.Enabled := FEditor.SelAvail;
  FMenuPaste.Enabled := (not FEditor.ReadOnly) and FEditor.CanPaste;
  FMenuDelete.Enabled := (not FEditor.ReadOnly) and FEditor.SelAvail;
  FMenuSelectAll.Enabled := FEditor.Lines.Count > 0;
end;

// Command handlers

procedure TSynEditPopupMenu.DoUndo(Sender: TObject);
begin
  if Assigned(FEditor) and FEditor.CanUndo then
    FEditor.Undo;
end;

procedure TSynEditPopupMenu.DoRedo(Sender: TObject);
begin
  if Assigned(FEditor) and FEditor.CanRedo then
    FEditor.Redo;
end;

procedure TSynEditPopupMenu.DoCut(Sender: TObject);
begin
  if Assigned(FEditor) and (not FEditor.ReadOnly) and FEditor.SelAvail then
    FEditor.CutToClipboard;
end;

procedure TSynEditPopupMenu.DoCopy(Sender: TObject);
begin
  if Assigned(FEditor) and FEditor.SelAvail then
    FEditor.CopyToClipboard;
end;

procedure TSynEditPopupMenu.DoPaste(Sender: TObject);
begin
  if Assigned(FEditor) and (not FEditor.ReadOnly) and FEditor.CanPaste then
    FEditor.PasteFromClipboard;
end;

procedure TSynEditPopupMenu.DoDelete(Sender: TObject);
begin
  if Assigned(FEditor) and (not FEditor.ReadOnly) and FEditor.SelAvail then
    FEditor.SelText := '';
end;

procedure TSynEditPopupMenu.DoSelectAll(Sender: TObject);
begin
  if Assigned(FEditor) then
    FEditor.SelectAll;
end;

procedure Register;
begin
  RegisterComponents('SynEdit', [TSynEditPopupMenu]);
end;

end.
