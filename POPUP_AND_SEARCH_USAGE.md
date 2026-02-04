# Использование SynEditPopupMenu и SynEditSearchPanel

## 1. Контекстное меню (SynEditPopupMenu)

### Базовое использование

```delphi
uses
  SynEdit, SynEditPopupMenu;

procedure TForm1.FormCreate(Sender: TObject);
var
  PopupMenu: TSynEditPopupMenu;
begin
  // Создать popup menu
  PopupMenu := TSynEditPopupMenu.Create(Self);
  PopupMenu.Editor := SynEdit1;
  
  // Автоматически определяет язык Windows!
  // Для русской Windows будет русское меню
  // Для английской Windows будет английское меню
  
  // Готово! Меню работает
end;
```

### Отключение отдельных пунктов меню

```delphi
procedure TForm1.FormCreate(Sender: TObject);
var
  PopupMenu: TSynEditPopupMenu;
begin
  PopupMenu := TSynEditPopupMenu.Create(Self);
  PopupMenu.Editor := SynEdit1;
  
  // Отключить "Найти" и "Заменить" (если у вас своя панель поиска)
  PopupMenu.HideMenuItem(pmiFind);
  PopupMenu.HideMenuItem(pmiReplace);
  
  // Отключить "Очистить всё" (если не нужно)
  PopupMenu.HideMenuItem(pmiClearAll);
  
  // Или настроить через свойство:
  PopupMenu.VisibleItems := [
    pmiUndo, pmiRedo, pmiSep1,
    pmiCut, pmiCopy, pmiPaste, pmiDelete, pmiSep2,
    pmiSelectAll
  ];
end;
```

### Программное показ/скрытие пунктов

```delphi
// Скрыть пункт
PopupMenu.HideMenuItem(pmiGotoLine);

// Показать пункт
PopupMenu.ShowMenuItem(pmiGotoLine);

// Проверить видимость
if PopupMenu.IsMenuItemVisible(pmiFind) then
  ShowMessage('Find menu visible');
```

### Смена языка вручную

```delphi
// Отключить автоопределение
PopupMenu.AutoDetectLanguage := False;

// Установить язык вручную
PopupMenu.Language := 'ru';  // Русский
// PopupMenu.Language := 'en';  // English
// PopupMenu.Language := 'de';  // Deutsch
// PopupMenu.Language := 'fr';  // Français
```

### Обработка событий поиска/замены

```delphi
procedure TForm1.FormCreate(Sender: TObject);
begin
  PopupMenu := TSynEditPopupMenu.Create(Self);
  PopupMenu.Editor := SynEdit1;
  
  // Подключить свои обработчики
  PopupMenu.OnFind := MyFindHandler;
  PopupMenu.OnReplace := MyReplaceHandler;
  PopupMenu.OnGotoLine := MyGotoLineHandler;
  PopupMenu.OnClearAll := MyClearAllHandler;
end;

procedure TForm1.MyFindHandler(Sender: TObject; Editor: TSynEdit);
begin
  // Показать свою панель поиска
  SearchPanel1.ShowPanel(spmFind);
end;

procedure TForm1.MyReplaceHandler(Sender: TObject; Editor: TSynEdit);
begin
  // Показать панель замены
  SearchPanel1.ShowPanel(spmReplace);
end;

procedure TForm1.MyGotoLineHandler(Sender: TObject; Editor: TSynEdit);
var
  LineNum: Integer;
begin
  if InputQuery('Go to Line', 'Line number:', LineNum) then
    Editor.GotoLineAndCenter(LineNum);
end;

procedure TForm1.MyClearAllHandler(Sender: TObject; Editor: TSynEdit);
begin
  if MessageDlg('Clear all text?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    Editor.Lines.Clear;
end;
```

---

## 2. Панель поиска (SynEditSearchPanel)

### Базовое использование

```delphi
uses
  SynEdit, SynEditSearchPanel;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Создать панель поиска
  SearchPanel1 := TSynEditSearchPanel.Create(Self);
  SearchPanel1.Parent := Self;  // или Panel1, если есть контейнер
  SearchPanel1.Editor := SynEdit1;
  SearchPanel1.Position := sppTop;  // Сверху (как в VS Code)
  SearchPanel1.Align := alTop;
  
  // По умолчанию скрыта
  SearchPanel1.Visible := False;
end;

// Показать панель по Ctrl+F
procedure TForm1.SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (ssCtrl in Shift) then
  begin
    SearchPanel1.ShowPanel(spmFind);
    Key := 0;
  end;
end;
```

### Позиция панели

```delphi
// Сверху (как в VS Code)
SearchPanel1.Position := sppTop;

// Снизу (как в Chrome)
SearchPanel1.Position := sppBottom;
```

### Режимы работы

```delphi
// Только поиск
SearchPanel1.ShowPanel(spmFind);

// Поиск и замена
SearchPanel1.ShowPanel(spmReplace);

// Переключение режима
if SearchPanel1.Mode = spmFind then
  SearchPanel1.Mode := spmReplace
else
  SearchPanel1.Mode := spmFind;
```

### Программное управление поиском

```delphi
// Установить текст поиска
SearchPanel1.SearchText := 'procedure';

// Установить текст замены
SearchPanel1.ReplaceText := 'function';

// Опции поиска
SearchPanel1.CaseSensitive := True;
SearchPanel1.WholeWordsOnly := True;
SearchPanel1.UseRegex := False;

// Выполнить поиск
SearchPanel1.FindNext;      // Следующий
SearchPanel1.FindPrevious;  // Предыдущий

// Замена
SearchPanel1.Replace;       // Заменить текущий
SearchPanel1.ReplaceAll;    // Заменить все
```

### События

```delphi
procedure TForm1.FormCreate(Sender: TObject);
begin
  SearchPanel1 := TSynEditSearchPanel.Create(Self);
  SearchPanel1.Parent := Self;
  SearchPanel1.Editor := SynEdit1;
  
  // События
  SearchPanel1.OnSearchFound := SearchFoundHandler;
  SearchPanel1.OnClose := SearchCloseHandler;
end;

procedure TForm1.SearchFoundHandler(Sender: TObject; MatchCount: Integer);
begin
  // Когда найдены совпадения
  StatusBar1.SimpleText := Format('Found %d matches', [MatchCount]);
end;

procedure TForm1.SearchCloseHandler(Sender: TObject);
begin
  // Когда панель закрывается
  SynEdit1.SetFocus;
end;
```

---

## 3. Полный пример интеграции

```delphi
unit MainForm;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Forms, Vcl.Controls,
  SynEdit, SynEditPopupMenu, SynEditSearchPanel, SynEditHighlighter,
  SynHighlighterPas;

type
  TFormMain = class(TForm)
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    procedure FormCreate(Sender: TObject);
  private
    FPopupMenu: TSynEditPopupMenu;
    FSearchPanel: TSynEditSearchPanel;
    
    procedure FindHandler(Sender: TObject; Editor: TSynEdit);
    procedure ReplaceHandler(Sender: TObject; Editor: TSynEdit);
    procedure GotoLineHandler(Sender: TObject; Editor: TSynEdit);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // Настроить редактор
  SynEdit1.Highlighter := SynPasSyn1;
  SynEdit1.Lines.LoadFromFile('MyUnit.pas');
  
  // Создать popup menu
  FPopupMenu := TSynEditPopupMenu.Create(Self);
  FPopupMenu.Editor := SynEdit1;
  FPopupMenu.OnFind := FindHandler;
  FPopupMenu.OnReplace := ReplaceHandler;
  FPopupMenu.OnGotoLine := GotoLineHandler;
  
  // Отключить "Clear All" для безопасности
  FPopupMenu.HideMenuItem(pmiClearAll);
  
  // Создать панель поиска
  FSearchPanel := TSynEditSearchPanel.Create(Self);
  FSearchPanel.Parent := Self;
  FSearchPanel.Editor := SynEdit1;
  FSearchPanel.Position := sppTop;
  FSearchPanel.Align := alTop;
  FSearchPanel.Visible := False;
  FSearchPanel.AutoHighlight := True;
  
  // Установить popup menu
  SynEdit1.PopupMenu := FPopupMenu;
end;

procedure TFormMain.FindHandler(Sender: TObject; Editor: TSynEdit);
begin
  // Показать панель поиска
  FSearchPanel.ShowPanel(spmFind);
  
  // Если есть выделенный текст - использовать его для поиска
  if Editor.SelAvail then
    FSearchPanel.SearchText := Editor.SelText;
end;

procedure TFormMain.ReplaceHandler(Sender: TObject; Editor: TSynEdit);
begin
  // Показать панель замены
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
  if InputQuery('Go to Line', 'Line number (1..' + 
     IntToStr(Editor.Lines.Count) + '):', LineNum) then
  begin
    if TryStrToInt(LineNum, Line) then
    begin
      if (Line >= 1) and (Line <= Editor.Lines.Count) then
      begin
        Editor.CaretXY := BufferCoord(1, Line);
        Editor.EnsureCursorPosVisible;
      end;
    end;
  end;
end;

end.
```

---

## 4. Горячие клавиши

### Popup Menu (автоматические)
- **Ctrl+Z** - Undo
- **Ctrl+Y** - Redo
- **Ctrl+X** - Cut
- **Ctrl+C** - Copy
- **Ctrl+V** - Paste
- **Del** - Delete
- **Ctrl+A** - Select All
- **Ctrl+F** - Find
- **Ctrl+H** - Replace
- **Ctrl+G** - Go to Line

### Search Panel
- **Enter** - Next match
- **Shift+Enter** - Previous match
- **Esc** - Close panel
- **Ctrl+F** - Open Find panel
- **Ctrl+H** - Open Replace panel

---

## 5. Настройка внешнего вида

### Цвета панели поиска

```delphi
SearchPanel1.Color := clWhite;
SearchPanel1.Font.Color := clBlack;
```

### Высота панели

```delphi
// Только поиск
SearchPanel1.Height := 40;

// Поиск + замена
SearchPanel1.Height := 70;
```

---

## 6. Доступные языки PopupMenu

- **en** - English
- **ru** - Русский
- **de** - Deutsch
- **fr** - Français
- **es** - Español
- **it** - Italiano
- **pt** - Português
- **zh** - 中文
- **ja** - 日本語
- **ko** - 한국어
- **pl** - Polski
- **uk** - Українська

Язык определяется автоматически из настроек Windows!

---

## 7. Видимые пункты меню (TSynPopupMenuItems)

```delphi
pmiUndo           // Отменить
pmiRedo           // Повторить
pmiSep1           // Разделитель
pmiCut            // Вырезать
pmiCopy           // Копировать
pmiPaste          // Вставить
pmiDelete         // Удалить
pmiSep2           // Разделитель
pmiSelectAll      // Выделить всё
pmiSep3           // Разделитель
pmiFind           // Найти
pmiReplace        // Заменить
pmiGotoLine       // Перейти к строке
pmiSep4           // Разделитель
pmiClearAll       // Очистить всё
```

---

## 8. Добавление в package

Добавить в `SynEditDR.dpk`:

```delphi
SynEditPopupMenu in '..\..\..\Source\SynEditPopupMenu.pas',
SynEditSearchPanel in '..\..\..\Source\SynEditSearchPanel.pas',
```

После компиляции компоненты появятся в палитре **SynEdit**!
