# SynEdit PopupMenu & SearchPanel Demo

Демонстрационное приложение для новых компонентов SynEdit:
- **TSynEditPopupMenu** - многоязычное контекстное меню
- **TSynEditSearchPanel** - современная панель поиска в стиле VS Code

## Возможности

### Контекстное меню (правый клик)
- ✅ Автоматическое определение языка Windows (12 языков)
- ✅ Все стандартные команды: Undo, Redo, Cut, Copy, Paste, Delete, Select All
- ✅ Команды поиска: Find, Replace, Go to Line
- ✅ Динамическое включение/выключение пунктов в зависимости от состояния
- ✅ Горячие клавиши для всех команд

### Панель поиска (Ctrl+F)
- ✅ Встроенная панель сверху (как в VS Code)
- ✅ Живой подсчёт совпадений ("3 of 15")
- ✅ Навигация: Previous (Shift+Enter) / Next (Enter)
- ✅ Опции: Case Sensitive, Whole Word, Regex
- ✅ Режим замены (Ctrl+H)
- ✅ Replace и Replace All
- ✅ Закрытие по Esc

## Горячие клавиши

### Редактирование
- **Ctrl+Z** - Отменить
- **Ctrl+Y** - Повторить
- **Ctrl+X** - Вырезать
- **Ctrl+C** - Копировать
- **Ctrl+V** - Вставить
- **Del** - Удалить
- **Ctrl+A** - Выделить всё

### Поиск и навигация
- **Ctrl+F** - Открыть панель поиска
- **Ctrl+H** - Открыть панель замены
- **Enter** - Следующее совпадение
- **Shift+Enter** - Предыдущее совпадение
- **Esc** - Закрыть панель поиска
- **Ctrl+G** - Перейти к строке

## Как запустить

1. Откройте проект `PopupAndSearchDemo.dpr` в RAD Studio
2. Убедитесь что package `SynEditDR` скомпилирован и установлен
3. Нажмите F9 для запуска

## Тестирование возможностей

### 1. Контекстное меню
- Щёлкните правой кнопкой в редакторе
- Меню автоматически на языке вашей Windows!
- Попробуйте различные команды

### 2. Панель поиска
- Нажмите Ctrl+F
- Введите текст для поиска (например, "procedure")
- Используйте кнопки ▲▼ или Enter/Shift+Enter для навигации
- Включите опции (Aa, W, .*)
- Попробуйте режим замены (Ctrl+H)

### 3. Смена языка интерфейса
Меню автоматически использует язык Windows:
- Русская Windows → Русское меню
- English Windows → English menu
- Deutsche Windows → Deutsches Menü
- И так далее для 12 языков

### 4. Read-Only режим
- Включите checkbox "Read Only"
- Попробуйте открыть контекстное меню
- Команды редактирования будут отключены (disabled)

### 5. Различные подсветки
- Выберите разные highlighters из выпадающего списка
- Загрузите файлы разных типов через "Open File"
- Подсветка определяется автоматически по расширению

## Требования

- RAD Studio 11 или выше
- Windows 7 или выше
- SynEdit library (включена в проект)

## Структура проекта

```
PopupAndSearchDemo/
├── PopupAndSearchDemo.dpr    - Главный файл проекта
├── MainForm.pas               - Главная форма
├── MainForm.dfm               - Дизайн формы
└── README.md                  - Эта документация
```

## Использованные компоненты

- **TSynEdit** - Основной редактор кода
- **TSynEditPopupMenu** - Контекстное меню (NEW!)
- **TSynEditSearchPanel** - Панель поиска (NEW!)
- **TSynPasSyn, TSynCppSyn, TSynSQLSyn, TSynXMLSyn** - Подсветка синтаксиса

## Настройка компонентов

### PopupMenu
```delphi
FPopupMenu := TSynEditPopupMenu.Create(Self);
FPopupMenu.Editor := SynEdit1;
FPopupMenu.OnFind := FindHandler;
FPopupMenu.OnReplace := ReplaceHandler;
FPopupMenu.OnGotoLine := GotoLineHandler;
FPopupMenu.OnClearAll := ClearAllHandler;

// Отключить ненужные пункты:
// FPopupMenu.HideMenuItem(pmiClearAll);
```

### SearchPanel
```delphi
FSearchPanel := TSynEditSearchPanel.Create(Self);
FSearchPanel.Parent := PanelMain;
FSearchPanel.Editor := SynEdit1;
FSearchPanel.Position := sppTop;  // или sppBottom
FSearchPanel.Align := alTop;
FSearchPanel.Visible := False;
FSearchPanel.AutoHighlight := True;
FSearchPanel.OnSearchFound := SearchFoundHandler;
FSearchPanel.OnClose := SearchCloseHandler;
```

## Поддерживаемые языки меню

1. **en** - English
2. **ru** - Русский
3. **de** - Deutsch (Немецкий)
4. **fr** - Français (Французский)
5. **es** - Español (Испанский)
6. **it** - Italiano (Итальянский)
7. **pt** - Português (Португальский)
8. **zh** - 中文 (Китайский)
9. **ja** - 日本語 (Японский)
10. **ko** - 한국어 (Корейский)
11. **pl** - Polski (Польский)
12. **uk** - Українська (Украинский)

## Известные особенности

- Regex поиск использует стандартный Delphi regex engine
- Подсветка совпадений (highlight) будет добавлена в будущих версиях
- История поиска будет добавлена в будущих версиях

## Лицензия

Этот демо-проект распространяется под той же лицензией что и SynEdit library (MPL 1.1 / GPL 2+).

## Автор

Created 2026-02-04 as part of SynEdit enhancements.

## Обратная связь

Если вы нашли баг или у вас есть предложения по улучшению, пожалуйста создайте issue в репозитории SynEdit.
