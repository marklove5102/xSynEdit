unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.ComCtrls,
  SynEdit, SynEditTypes, SynEditHighlighter,
  SynHighlighterPas, SynHighlighterCpp, SynHighlighterSQL, SynHighlighterXML,
  SynEditPopupMenu, SynEditSearchPanel;

type
  TFormMain = class(TForm)
    PanelTop: TPanel;
    PanelMain: TPanel;
    SynEdit1: TSynEdit;
    StatusBar1: TStatusBar;
    BtnOpenFile: TButton;
    BtnSaveFile: TButton;
    ComboHighlighter: TComboBox;
    Label1: TLabel;
    ChkReadOnly: TCheckBox;
    BtnAbout: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SynPasSyn1: TSynPasSyn;
    SynCppSyn1: TSynCppSyn;
    SynSQLSyn1: TSynSQLSyn;
    SynXMLSyn1: TSynXMLSyn;
    procedure FormCreate(Sender: TObject);
    procedure BtnOpenFileClick(Sender: TObject);
    procedure BtnSaveFileClick(Sender: TObject);
    procedure ComboHighlighterChange(Sender: TObject);
    procedure ChkReadOnlyClick(Sender: TObject);
    procedure BtnAboutClick(Sender: TObject);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FPopupMenu: TSynEditPopupMenu;
    FSearchPanel: TSynEditSearchPanel;

    procedure FindHandler(Sender: TObject; Editor: TSynEdit);
    procedure ReplaceHandler(Sender: TObject; Editor: TSynEdit);
    procedure GotoLineHandler(Sender: TObject; Editor: TSynEdit);
    procedure ClearAllHandler(Sender: TObject; Editor: TSynEdit);
    procedure SearchFoundHandler(Sender: TObject; MatchCount: Integer);
    procedure SearchCloseHandler(Sender: TObject);
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // Setup editor
  SynEdit1.Font.Name := 'Consolas';
  SynEdit1.Font.Size := 10;
  SynEdit1.Gutter.Font.Name := 'Consolas';
  SynEdit1.Gutter.Font.Size := 9;
  SynEdit1.Lines.Text :=
    '// SynEdit PopupMenu and SearchPanel Demo'#13#10 +
    '//'#13#10 +
    '// Features:'#13#10 +
    '// 1. Right-click for context menu (auto-detects Windows language!)'#13#10 +
    '// 2. Press Ctrl+F for search panel'#13#10 +
    '// 3. Press Ctrl+H for replace panel'#13#10 +
    '// 4. All standard shortcuts work (Ctrl+C, Ctrl+V, Ctrl+Z, etc.)'#13#10 +
    '//'#13#10 +
    '// Try it now!'#13#10#13#10 +
    'procedure HelloWorld;'#13#10 +
    'begin'#13#10 +
    '  WriteLn(''Hello, World!'');'#13#10 +
    'end;'#13#10;

  // Create and configure popup menu
  FPopupMenu := TSynEditPopupMenu.Create(Self);
  FPopupMenu.Editor := SynEdit1;
  FPopupMenu.OnFind := FindHandler;
  FPopupMenu.OnReplace := ReplaceHandler;
  FPopupMenu.OnGotoLine := GotoLineHandler;
  FPopupMenu.OnClearAll := ClearAllHandler;

  // You can customize which items are visible
  // FPopupMenu.HideMenuItem(pmiClearAll);  // Uncomment to hide "Clear All"

  // Set popup menu
  SynEdit1.PopupMenu := FPopupMenu;

  // Create search panel
  FSearchPanel := TSynEditSearchPanel.Create(Self);
  FSearchPanel.Parent := PanelMain;
  FSearchPanel.Editor := SynEdit1;
  FSearchPanel.Position := sppTop;
  FSearchPanel.Align := alTop;
  FSearchPanel.Visible := False;
  FSearchPanel.AutoHighlight := True;
  FSearchPanel.OnSearchFound := SearchFoundHandler;
  FSearchPanel.OnClose := SearchCloseHandler;

  // Setup highlighter combo
  ComboHighlighter.Items.Clear;
  ComboHighlighter.Items.Add('Pascal');
  ComboHighlighter.Items.Add('C++');
  ComboHighlighter.Items.Add('SQL');
  ComboHighlighter.Items.Add('XML');
  ComboHighlighter.Items.Add('None');
  ComboHighlighter.ItemIndex := 0;
  SynEdit1.Highlighter := SynPasSyn1;

  // Initial status
  SynEdit1StatusChange(Self, [scAll]);
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Handle Ctrl+F and Ctrl+H globally
  if ssCtrl in Shift then
  begin
    case Key of
      Ord('F'):
        begin
          FSearchPanel.ShowPanel(spmFind);
          if SynEdit1.SelAvail then
            FSearchPanel.SearchText := SynEdit1.SelText;
          Key := 0;
        end;
      Ord('H'):
        begin
          FSearchPanel.ShowPanel(spmReplace);
          if SynEdit1.SelAvail then
            FSearchPanel.SearchText := SynEdit1.SelText;
          Key := 0;
        end;
    end;
  end;
end;

procedure TFormMain.BtnOpenFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    SynEdit1.Lines.LoadFromFile(OpenDialog1.FileName);
    StatusBar1.SimpleText := 'Loaded: ' + OpenDialog1.FileName;

    // Auto-detect highlighter based on extension
    if ExtractFileExt(OpenDialog1.FileName).ToLower = '.pas' then
    begin
      SynEdit1.Highlighter := SynPasSyn1;
      ComboHighlighter.ItemIndex := 0;
    end
    else if ExtractFileExt(OpenDialog1.FileName).ToLower = '.cpp' then
    begin
      SynEdit1.Highlighter := SynCppSyn1;
      ComboHighlighter.ItemIndex := 1;
    end
    else if ExtractFileExt(OpenDialog1.FileName).ToLower = '.sql' then
    begin
      SynEdit1.Highlighter := SynSQLSyn1;
      ComboHighlighter.ItemIndex := 2;
    end
    else if ExtractFileExt(OpenDialog1.FileName).ToLower = '.xml' then
    begin
      SynEdit1.Highlighter := SynXMLSyn1;
      ComboHighlighter.ItemIndex := 3;
    end;
  end;
end;

procedure TFormMain.BtnSaveFileClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    SynEdit1.Lines.SaveToFile(SaveDialog1.FileName);
    StatusBar1.SimpleText := 'Saved: ' + SaveDialog1.FileName;
  end;
end;

procedure TFormMain.ComboHighlighterChange(Sender: TObject);
begin
  case ComboHighlighter.ItemIndex of
    0: SynEdit1.Highlighter := SynPasSyn1;
    1: SynEdit1.Highlighter := SynCppSyn1;
    2: SynEdit1.Highlighter := SynSQLSyn1;
    3: SynEdit1.Highlighter := SynXMLSyn1;
    4: SynEdit1.Highlighter := nil;
  end;
end;

procedure TFormMain.ChkReadOnlyClick(Sender: TObject);
begin
  SynEdit1.ReadOnly := ChkReadOnly.Checked;
end;

procedure TFormMain.BtnAboutClick(Sender: TObject);
begin
  ShowMessage(
    'SynEdit PopupMenu & SearchPanel Demo'#13#10#13#10 +
    'Features:'#13#10 +
    '✓ Multilingual context menu (12 languages)'#13#10 +
    '✓ Modern search panel (VS Code style)'#13#10 +
    '✓ All standard editing commands'#13#10 +
    '✓ Customizable menu items'#13#10 +
    '✓ Regex search support'#13#10#13#10 +
    'Shortcuts:'#13#10 +
    'Ctrl+F - Find'#13#10 +
    'Ctrl+H - Replace'#13#10 +
    'Ctrl+G - Go to Line'#13#10 +
    'Ctrl+C/V/X - Copy/Paste/Cut'#13#10 +
    'Ctrl+Z/Y - Undo/Redo'#13#10 +
    'Ctrl+A - Select All'
  );
end;

procedure TFormMain.SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
  StatusBar1.Panels[0].Text := Format('Line: %d, Col: %d', [SynEdit1.CaretY, SynEdit1.CaretX]);
  StatusBar1.Panels[1].Text := Format('Lines: %d', [SynEdit1.Lines.Count]);

  if SynEdit1.Modified then
    StatusBar1.Panels[2].Text := 'Modified'
  else
    StatusBar1.Panels[2].Text := '';

  if SynEdit1.ReadOnly then
    StatusBar1.Panels[3].Text := 'ReadOnly'
  else if SynEdit1.InsertMode then
    StatusBar1.Panels[3].Text := 'Insert'
  else
    StatusBar1.Panels[3].Text := 'Overwrite';
end;

// PopupMenu event handlers

procedure TFormMain.FindHandler(Sender: TObject; Editor: TSynEdit);
begin
  FSearchPanel.ShowPanel(spmFind);
  if Editor.SelAvail then
    FSearchPanel.SearchText := Editor.SelText;
end;

procedure TFormMain.ReplaceHandler(Sender: TObject; Editor: TSynEdit);
begin
  FSearchPanel.ShowPanel(spmReplace);
  if Editor.SelAvail then
    FSearchPanel.SearchText := Editor.SelText;
end;

procedure TFormMain.GotoLineHandler(Sender: TObject; Editor: TSynEdit);
var
  LineNum: string;
  Line: Integer;
begin
  LineNum := IntToStr(Editor.CaretY);
  if InputQuery('Go to Line',
     Format('Line number (1..%d):', [Editor.Lines.Count]), LineNum) then
  begin
    if TryStrToInt(LineNum, Line) then
    begin
      if (Line >= 1) and (Line <= Editor.Lines.Count) then
      begin
        Editor.CaretXY := BufferCoord(1, Line);
        Editor.EnsureCursorPosVisible;
      end
      else
        ShowMessage(Format('Line number must be between 1 and %d', [Editor.Lines.Count]));
    end
    else
      ShowMessage('Invalid line number');
  end;
end;

procedure TFormMain.ClearAllHandler(Sender: TObject; Editor: TSynEdit);
begin
  if MessageDlg('Clear all text in the editor?',
     mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Editor.Lines.Clear;
    StatusBar1.SimpleText := 'Editor cleared';
  end;
end;

procedure TFormMain.SearchFoundHandler(Sender: TObject; MatchCount: Integer);
begin
  if MatchCount = 0 then
    StatusBar1.SimpleText := 'No matches found'
  else if MatchCount = 1 then
    StatusBar1.SimpleText := '1 match found'
  else
    StatusBar1.SimpleText := Format('%d matches found', [MatchCount]);
end;

procedure TFormMain.SearchCloseHandler(Sender: TObject);
begin
  StatusBar1.SimpleText := 'Search closed';
  SynEdit1.SetFocus;
end;

end.
