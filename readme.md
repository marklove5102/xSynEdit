# xSynEdit - Enhanced SynEdit for Delphi

[![Delphi](https://img.shields.io/badge/Delphi-11%20|%2012%20|%2013-red.svg)](https://www.embarcadero.com/)
[![Platform](https://img.shields.io/badge/Platform-Win32%20|%20Win64%20|%20Win64x-blue.svg)]()
[![License](https://img.shields.io/badge/License-MPL%201.1-green.svg)](LICENSE)
[![Performance](https://img.shields.io/badge/Performance-60--100%25%20Faster-brightgreen.svg)]()

---

**[English](#english)** | **[Русский](#russian)**

---

<a name="english"></a>
# English

**xSynEdit** is an enhanced and optimized version of the classic SynEdit component for Delphi, specifically adapted for modern Delphi versions with numerous performance improvements, modern highlighters, and extended capabilities.

## Supported RAD Studio Versions

| Version | BDS | Status |
|---------|-----|--------|
| RAD Studio 11 Alexandria | 24.0 | ✅ Supported |
| RAD Studio 12 Athens | 23.0 | ✅ Supported |
| RAD Studio 13 Florence | 37.0 | ✅ Supported |

## Supported Platforms

- **Win32** - Classic 32-bit Windows
- **Win64** - 64-bit Windows (Classic Clang)
- **Win64x** - 64-bit Windows (Modern Clang)

## Installation

### Automatic Installation (Recommended)

1. **Clone repository:**
```bash
git clone https://github.com/Platon7788/xSynEdit.git
cd xSynEdit
```

2. **Run installer:**
```
Install_SynEdit.bat
```

3. **Follow the prompts:**
   - Select your RAD Studio version (11, 12, or 13)
   - Select target platforms (Win32, Win64, Win64x)
   - Wait for compilation to complete
   - Restart RAD Studio

The installer will:
- Compile runtime and design-time packages
- Register packages in IDE (32-bit and 64-bit)
- Configure Delphi Library paths
- Configure C++ Include and Library paths
- Create registry backup before changes

### Uninstallation

```
Uninstall_SynEdit.bat
```

The uninstaller will:
- Unregister packages from IDE
- Remove compiled BPL/DCP files
- Optionally remove library paths
- Create registry backups (before and after)

### Manual Installation

1. Open `Packages\11AndAbove\Delphi\SynEditDR.dproj` - Runtime package
2. Build for required platforms (Win32, Win64, Win64x)
3. Open `Packages\11AndAbove\Delphi\SynEditDD.dproj` - Design-time package
4. Build and Install

## Key Features

### Extreme Performance
- **60-100% overall performance improvement** through 17 critical optimizations
- **Inline coordinate operations** - 15-25% faster
- **Font metrics caching** - 60-80% faster text format creation
- **O(n) RecreateFoldRanges algorithm** - 10-100x for large files
- **Interval cache for FoldLineToRow** - 10-100x for sequential rendering

### Modern Highlighters
- **Lua 5.4.7** - full support for `goto`, `<const>`, `<close>`, bitwise operators
- **Python 3.13+** - `async`/`await`, `match`/`case`, f-strings, walrus operator
- **Rust 1.93.0** - created from scratch, full keyword support
- **JSON, INI, MSG, UnrealScript** - verified and updated

### Safety Features
- **Automatic memory limits** - crash protection (2M lines default)
- **Character filtering** - input filtering by character mask
- **Length limits** - line and line count restrictions

### Extended Features (xOpt)
- **Smart Context Menu** - customizable context menu
- **Auto Keyboard Layout** - auto-switch layout on focus
- **Character Filter** - input filtering (Numeric, Hex, Alpha, Custom)
- **Case Conversion** - automatic case transformation

## Quick Start

```delphi
uses
  SynEdit, SynHighlighterPython;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SynEdit1 := TSynEdit.Create(Self);
  SynEdit1.Parent := Self;
  SynEdit1.Align := alClient;
  SynEdit1.Highlighter := TSynPythonSyn.Create(Self);
  SynEdit1.Lines.LoadFromFile('script.py');
end;
```

## Documentation

- [OPTIMIZATION_SUMMARY.md](Doc/OPTIMIZATION_SUMMARY.md) - detailed optimization report
- [HIGHLIGHTERS_MODERNIZATION.md](Doc/HIGHLIGHTERS_MODERNIZATION.md) - modern highlighters
- [MEMORY_LIMITS_CALCULATION.md](Doc/MEMORY_LIMITS_CALCULATION.md) - safe limits calculation
- [INSTALLATION_FAQ.md](Doc/INSTALLATION_FAQ.md) - installation troubleshooting
- [All documentation](Doc/) - complete documentation folder

## License

**Mozilla Public License Version 1.1 (MPL 1.1)**

### Credits
- **Original SynEdit** - Martin Waldenburg and contributors
- **Unicode translation** - Maël Hörz
- **Optimizations & Modernization** - Platon (2025-2026)

---

<a name="russian"></a>
# Русский

**xSynEdit** - это расширенная и оптимизированная версия классического компонента SynEdit для Delphi, специально адаптированная для современных версий Delphi с множеством улучшений производительности, современных highlighters и расширенными возможностями.

## Поддерживаемые версии RAD Studio

| Версия | BDS | Статус |
|--------|-----|--------|
| RAD Studio 11 Alexandria | 24.0 | ✅ Поддерживается |
| RAD Studio 12 Athens | 23.0 | ✅ Поддерживается |
| RAD Studio 13 Florence | 37.0 | ✅ Поддерживается |

## Поддерживаемые платформы

- **Win32** - Классический 32-битный Windows
- **Win64** - 64-битный Windows (Classic Clang)
- **Win64x** - 64-битный Windows (Modern Clang)

## Установка

### Автоматическая установка (Рекомендуется)

1. **Клонировать репозиторий:**
```bash
git clone https://github.com/Platon7788/xSynEdit.git
cd xSynEdit
```

2. **Запустить установщик:**
```
Install_SynEdit.bat
```

3. **Следовать инструкциям:**
   - Выбрать версию RAD Studio (11, 12 или 13)
   - Выбрать целевые платформы (Win32, Win64, Win64x)
   - Дождаться завершения компиляции
   - Перезапустить RAD Studio

Установщик выполнит:
- Компиляцию runtime и design-time пакетов
- Регистрацию пакетов в IDE (32-bit и 64-bit)
- Настройку путей библиотек Delphi
- Настройку путей Include и Library для C++
- Создание резервной копии реестра перед изменениями

### Удаление

```
Uninstall_SynEdit.bat
```

Деинсталлятор выполнит:
- Отмену регистрации пакетов в IDE
- Удаление скомпилированных BPL/DCP файлов
- Опционально удаление путей библиотек
- Создание резервных копий реестра (до и после)

### Ручная установка

1. Открыть `Packages\11AndAbove\Delphi\SynEditDR.dproj` - Runtime пакет
2. Собрать для нужных платформ (Win32, Win64, Win64x)
3. Открыть `Packages\11AndAbove\Delphi\SynEditDD.dproj` - Design-time пакет
4. Собрать и установить

## Ключевые особенности

### Экстремальная производительность
- **60-100% общее улучшение производительности** за счёт 17 критических оптимизаций
- **Inline операции с координатами** - 15-25% быстрее
- **Кэширование font metrics** - 60-80% быстрее создание text formats
- **O(n) алгоритм RecreateFoldRanges** - 10-100x для больших файлов
- **Interval cache для FoldLineToRow** - 10-100x для последовательного рендеринга

### Современные Highlighters
- **Lua 5.4.7** - полная поддержка `goto`, `<const>`, `<close>`, битовых операторов
- **Python 3.13+** - `async`/`await`, `match`/`case`, f-strings, walrus operator
- **Rust 1.93.0** - создан с нуля, полная поддержка всех keywords
- **JSON, INI, MSG, UnrealScript** - проверены и актуализированы

### Безопасность
- **Автоматические лимиты памяти** - защита от краша (2M строк по умолчанию)
- **Character filtering** - фильтрация ввода по маске символов
- **Length limits** - ограничение длины строк и количества строк

### Расширенные возможности (xOpt)
- **Smart Context Menu** - настраиваемое контекстное меню
- **Auto Keyboard Layout** - автопереключение раскладки при фокусе
- **Character Filter** - фильтрация ввода (Numeric, Hex, Alpha, Custom)
- **Case Conversion** - автоматическое преобразование регистра

## Быстрый старт

```delphi
uses
  SynEdit, SynHighlighterPython;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SynEdit1 := TSynEdit.Create(Self);
  SynEdit1.Parent := Self;
  SynEdit1.Align := alClient;
  SynEdit1.Highlighter := TSynPythonSyn.Create(Self);
  SynEdit1.Lines.LoadFromFile('script.py');
end;
```

## Документация

- [OPTIMIZATION_SUMMARY.md](Doc/OPTIMIZATION_SUMMARY.md) - детальный отчёт по оптимизациям
- [HIGHLIGHTERS_MODERNIZATION.md](Doc/HIGHLIGHTERS_MODERNIZATION.md) - современные highlighters
- [MEMORY_LIMITS_CALCULATION.md](Doc/MEMORY_LIMITS_CALCULATION.md) - расчёт безопасных лимитов
- [INSTALLATION_FAQ.md](Doc/INSTALLATION_FAQ.md) - решение проблем установки
- [Вся документация](Doc/) - полная папка документации

## Лицензия

**Mozilla Public License Version 1.1 (MPL 1.1)**

### Благодарности
- **Original SynEdit** - Martin Waldenburg и контрибьюторы
- **Unicode translation** - Maël Hörz
- **Оптимизации и модернизация** - Platon (2025-2026)

---

## Контакты

- **GitHub:** [github.com/Platon7788/xSynEdit](https://github.com/Platon7788/xSynEdit)
- **Issues:** [github.com/Platon7788/xSynEdit/issues](https://github.com/Platon7788/xSynEdit/issues)

---

**Made with ❤️ for Delphi community by Platon**

*xSynEdit - Enhanced, Optimized, Modern*
