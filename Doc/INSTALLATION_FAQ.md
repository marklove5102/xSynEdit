# SynEdit - Installation FAQ

## Вопрос: CBuilder - автоматически или нужно добавлять отдельно?

### Ответ: **Автоматически!**

C++Builder использует Delphi runtime packages (`.dpk`), поэтому:

✅ **Что сделано:**
- Компоненты добавлены в `SynEditDR.dpk` (Delphi Runtime)
- Это **runtime** package, используемый и Delphi, и C++Builder

✅ **Что получается:**
- После компиляции `SynEditDR.dpk` → компоненты видны в **Delphi**
- C++Builder автоматически видит те же компоненты через Delphi runtime
- Не нужно дублировать код в C++Builder packages

### Как это работает:

```
SynEditDR.dpk (Delphi Runtime)
     ↓
     ├─→ Используется Delphi приложениями
     └─→ Используется C++Builder приложениями (через Delphi runtime)

SynEditDD.dpk (Delphi Design-time)
     ↓
     └─→ Регистрирует компоненты в палитре для Delphi

SynEditCD.cbproj (C++Builder Design-time)
     ↓
     └─→ Регистрирует компоненты в палитре для C++Builder
          (но использует SynEditDR.dpk для runtime!)
```

---

## Установка для Delphi

### 1. Откройте package
```
Packages\11AndAbove\Delphi\SynEditDR.dpk
```

### 2. Скомпилируйте
```
Project → Build
```

### 3. Установите design-time (опционально)
```
Packages\11AndAbove\Delphi\SynEditDD.dpk
```

### 4. Готово!
Компоненты появятся в палитре **SynEdit**:
- TSynEdit
- TSynEditPopupMenu ✨ NEW
- TSynEditSearchPanel ✨ NEW
- и другие...

---

## Установка для C++Builder

### Вариант А: Использовать Delphi package (рекомендуется)

✅ **Самый простой способ:**

1. Скомпилируйте Delphi runtime: `SynEditDR.dpk`
2. C++Builder автоматически видит компоненты!
3. Используйте в C++Builder проектах:

```cpp
// В C++Builder приложении:
#include <SynEdit.hpp>
#include <SynEditPopupMenu.hpp>
#include <SynEditSearchPanel.hpp>

// Использование как обычно:
TSynEdit *editor = new TSynEdit(this);
TSynEditPopupMenu *popup = new TSynEditPopupMenu(this);
popup->Editor = editor;
```

### Вариант Б: Скомпилировать C++Builder design-time package

Если хотите чтобы компоненты появились в палитре C++Builder:

1. Откройте: `Packages\11AndAbove\CBuilder\SynEditCD.cbproj`
2. Build
3. Install

**Примечание:** Runtime всё равно использует Delphi `SynEditDR.dpk`

---

## Исправленные ошибки компиляции

### Ошибка 1: `E2003 Undeclared identifier: 'IndexStr'`
**Исправлено:** Добавлен `System.StrUtils` в uses

### Ошибка 2: `E2003 Undeclared identifier: 'VK_Z'`
**Исправлено:** Заменено на `Ord('Z')`

### Ошибка 3: `E2007 Constant or type identifier expected`
**Исправлено:** Использование правильных констант языков Windows

---

## Тестирование установки

### Для Delphi:

1. Создайте новое VCL приложение
2. Бросьте `TSynEdit` на форму
3. Бросьте `TSynEditPopupMenu` на форму
4. Установите `PopupMenu1.Editor := SynEdit1;`
5. Запустите - меню должно работать!

### Для C++Builder:

1. Создайте новое C++Builder VCL приложение
2. Добавьте в uses: `#include <SynEdit.hpp>`
3. Добавьте: `#include <SynEditPopupMenu.hpp>`
4. Создайте компоненты программно или через форму
5. Запустите!

---

## Демо-приложение

**Путь:** `Demos\PopupAndSearchDemo\`

### Для Delphi:
```
Открыть: PopupAndSearchDemo.dpr
Нажать: F9
```

### Для C++Builder:
Можно использовать тот же демо-проект, так как он использует Delphi runtime.

Или создать свой C++ проект на основе примеров из `POPUP_AND_SEARCH_USAGE.md`

---

## Структура Packages

```
Packages/
├── 11AndAbove/
│   ├── Delphi/
│   │   ├── SynEditDR.dpk       ← Runtime (для Delphi И C++Builder!)
│   │   └── SynEditDD.dpk       ← Design-time (только Delphi)
│   └── CBuilder/
│       ├── SynEditCR.cbproj    ← Runtime wrapper (optional)
│       └── SynEditCD.cbproj    ← Design-time (только C++Builder)
├── Sydney/
│   └── CBuilder/...
├── Tokyo/
│   └── CBuilder/...
└── ...
```

**Важно:** 
- **Runtime** один для всех → `SynEditDR.dpk`
- **Design-time** разные → `SynEditDD.dpk` (Delphi) и `SynEditCD.cbproj` (C++Builder)

---

## Частые вопросы

### Q: Нужно ли что-то делать для C++Builder отдельно?
**A:** Нет! После компиляции `SynEditDR.dpk` всё работает автоматически.

### Q: Почему компоненты не видны в палитре C++Builder?
**A:** Скомпилируйте и установите `SynEditCD.cbproj` design-time package.

### Q: Можно ли использовать только runtime без design-time?
**A:** Да! Создавайте компоненты программно:
```cpp
TSynEditPopupMenu *menu = new TSynEditPopupMenu(this);
menu->Editor = SynEdit1;
```

### Q: Какую версию RAD Studio нужно?
**A:** 11 или выше (папка `11AndAbove`). Для старых версий используйте соответствующие папки (Sydney, Tokyo, Rio, Berlin).

### Q: Где найти примеры для C++Builder?
**A:** Все примеры из `POPUP_AND_SEARCH_USAGE.md` можно адаптировать, заменив Delphi синтаксис на C++:
- `PopupMenu := TSynEditPopupMenu.Create(Self);` → `TSynEditPopupMenu *menu = new TSynEditPopupMenu(this);`
- `PopupMenu.Editor := SynEdit1;` → `menu->Editor = SynEdit1;`

---

## Проверка что всё установлено правильно

### 1. Проверить что package скомпилирован:
```
<BDS>\bin
    ├── SynEditDR290.bpl    ← Runtime package (для 11.x версии)
    └── ...
```

### 2. Проверить что компоненты видны:
- Откройте Delphi/C++Builder IDE
- View → Tool Palette
- Найдите секцию **SynEdit**
- Должны быть: TSynEdit, TSynEditPopupMenu, TSynEditSearchPanel

### 3. Запустить демо:
```
Demos\PopupAndSearchDemo\PopupAndSearchDemo.dpr
```
Если запускается - всё работает!

---

## Поддержка

Если возникли проблемы:
1. Проверьте что `SynEditDR.dpk` скомпилирован успешно
2. Проверьте что нет ошибок компиляции
3. Попробуйте перезапустить IDE
4. Проверьте что пути к source файлам правильные

Для отладки включите подробный вывод компилятора:
```
Tools → Options → Building → Compiler → Output Verbosity = Detailed
```

---

## Готово! 🎉

После компиляции `SynEditDR.dpk`:
- ✅ Работает в Delphi
- ✅ Работает в C++Builder
- ✅ Компоненты в палитре (после установки design-time)
- ✅ Готово к использованию!
