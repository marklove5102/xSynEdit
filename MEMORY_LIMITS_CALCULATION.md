# SynEdit Memory Limits Calculation
## Safe Limits to Prevent Crashes and Memory Leaks

---

## Структура TSynEditStringRec (на 64-bit)

```delphi
TSynEditStringRec = record
  FString: string;           // 8 bytes (pointer)
  FObject: TObject;          // 8 bytes (pointer)
  FRange: TSynEditRange;     // 8 bytes (pointer)
  FTextWidth: Integer;       // 4 bytes
  FCharIndex: Integer;       // 4 bytes
  FFlags: TSynEditStringFlags; // 1 byte + 7 bytes padding
end;
// Total: 40 bytes per line (aligned)
```

---

## Теоретические лимиты

### Константа из кода:
```delphi
const
  SynEditStringRecSize = SizeOf(TSynEditStringRec);  // 40 bytes
  MaxSynEditStrings = MaxInt div SynEditStringRecSize;
  // MaxInt = 2,147,483,647
  // MaxSynEditStrings = 53,687,091 строк
```

### Но это НЕ учитывает:
1. Память для самих строк (string data)
2. Layout cache
3. Fold ranges
4. Undo/Redo buffers
5. Highlighter ranges
6. Font metrics cache
7. Render targets

---

## Реальная память на строку

### Минимальная строка (пустая):
- TSynEditStringRec: **40 bytes**
- String header: **24 bytes** (refcount, length, codepage)
- **Total: ~64 bytes** на пустую строку

### Средняя строка (80 символов):
- TSynEditStringRec: **40 bytes**
- String data: **24 + (80 × 2) = 184 bytes**
- Layout cache entry: **~200 bytes** (IDWriteTextLayout)
- Highlighter range: **~16 bytes**
- **Total: ~440 bytes** на строку

### Длинная строка (200 символов):
- TSynEditStringRec: **40 bytes**
- String data: **24 + (200 × 2) = 424 bytes**
- Layout cache entry: **~300 bytes**
- Highlighter range: **~16 bytes**
- **Total: ~780 bytes** на строку

---

## Практические лимиты (Windows 64-bit)

### Доступная память процесса:
- **Теоретический максимум**: 8 TB (Windows 64-bit)
- **Практический лимит**: 2-4 GB для user-mode приложений
- **Безопасный лимит**: 1.5 GB (оставляем запас для OS и других данных)

### Расчёт максимального количества строк:

#### Сценарий 1: Короткие строки (40 chars average)
```
Memory per line = 40 + 24 + 80 + 150 + 16 = 310 bytes
Available memory = 1.5 GB = 1,610,612,736 bytes
Max lines = 1,610,612,736 / 310 = 5,195,847 строк

✅ БЕЗОПАСНЫЙ ЛИМИТ: 5,000,000 строк
```

#### Сценарий 2: Средние строки (80 chars average)
```
Memory per line = 40 + 24 + 160 + 200 + 16 = 440 bytes
Available memory = 1.5 GB = 1,610,612,736 bytes
Max lines = 1,610,612,736 / 440 = 3,660,938 строк

✅ БЕЗОПАСНЫЙ ЛИМИТ: 3,500,000 строк
```

#### Сценарий 3: Длинные строки (200 chars average)
```
Memory per line = 40 + 24 + 400 + 300 + 16 = 780 bytes
Available memory = 1.5 GB = 1,610,612,736 bytes
Max lines = 1,610,612,736 / 780 = 2,065,145 строк

✅ БЕЗОПАСНЫЙ ЛИМИТ: 2,000,000 строк
```

#### Сценарий 4: Очень длинные строки (500 chars average)
```
Memory per line = 40 + 24 + 1000 + 500 + 16 = 1,580 bytes
Available memory = 1.5 GB = 1,610,612,736 bytes
Max lines = 1,610,612,736 / 1,580 = 1,019,373 строк

✅ БЕЗОПАСНЫЙ ЛИМИТ: 1,000,000 строк
```

---

## Рекомендуемые лимиты для xOpt.Limits

### Универсальный безопасный лимит:
```delphi
xOpt.Limits.Enabled := True;
xOpt.Limits.MaxLines := 1000000;  // 1 миллион строк
```

**Обоснование:**
- Работает при любой средней длине строки (до 500 chars)
- Гарантирует < 1.6 GB памяти
- Оставляет запас для других компонентов
- Защищает от случайного краша

### Для текстовых редакторов кода:
```delphi
xOpt.Limits.MaxLines := 100000;  // 100,000 строк
```

**Обоснование:**
- Реальные файлы кода редко превышают 10,000 строк
- Быстрая навигация и рендеринг
- Минимальная задержка при скроллинге

### Для логов и больших данных:
```delphi
xOpt.Limits.MaxLines := 2000000;  // 2 миллиона строк
```

**Обоснование:**
- Для просмотра больших лог-файлов
- Требует мониторинга памяти
- Может быть медленным на старых ПК

### Для встраиваемых редакторов (комментарии, описания):
```delphi
xOpt.Limits.MaxLines := 10000;  // 10,000 строк
```

**Обоснование:**
- Достаточно для любого разумного текста
- Быстрая работа даже на слабых ПК
- Предотвращает случайную вставку огромных файлов

---

## Дополнительные факторы

### Code Folding:
```
Fold ranges: ~24 bytes per range
Typical file: 100-500 ranges
Memory overhead: ~12-120 KB (negligible)
```

### Undo/Redo:
```
Undo item: ~100 bytes per operation
Max undo items: typically 1000-10000
Memory overhead: ~100 KB - 1 MB
```

### Layout Cache (оптимизация Phase 2):
```
Cache entry: ~150-300 bytes per visible line
Visible lines: typically 50-100
Memory overhead: ~7.5-30 KB (negligible)
```

### Highlighter Attributes Cache (оптимизация Phase 3):
```
TSynAttributeData: 20 bytes per token type
Typical highlighter: 20-50 token types
Memory overhead: ~0.4-1 KB (negligible)
```

### Font Metrics Cache (оптимизация Phase 4):
```
Cache entry: ~40 bytes per font variant
Typical application: 5-20 variants
Memory overhead: ~200-800 bytes (negligible)
```

---

## Защита от утечек памяти

### В SynEdit уже реализованы:

1. **Automatic string management** (Delphi ARC для строк)
   - Автоматический refcounting
   - Нет manual free для строк

2. **COM interface management** (DirectWrite)
   - Автоматический AddRef/Release
   - Все кэши освобождаются в ResetRenderTarget

3. **TList<T> automatic cleanup**
   - Destructor автоматически очищает списки
   - Нет утечек при destroy

4. **Layout cache LRU eviction**
   - Автоматическое вытеснение старых записей
   - Контроль размера кэша

### Дополнительные меры безопасности:

```delphi
// В вашем приложении:
procedure TForm1.MonitorMemoryUsage;
var
  MemStatus: TMemoryManagerState;
  UsedMemory: Int64;
begin
  GetMemoryManagerState(MemStatus);
  UsedMemory := MemStatus.TotalAllocatedMediumBlockSize + 
                MemStatus.TotalAllocatedLargeBlockSize;
  
  // Если использовано > 1.2 GB, предупредить пользователя
  if UsedMemory > 1288490188 then  // 1.2 GB
  begin
    ShowMessage('Внимание: большое потребление памяти. ' +
                'Рекомендуется закрыть некоторые файлы.');
  end;
end;
```

---

## Таблица рекомендаций по типу использования

| Тип использования | MaxLines | MaxLineLength | Память (approx) |
|-------------------|----------|---------------|-----------------|
| Комментарий / Описание | 1,000 | 500 | ~1 MB |
| Код в IDE | 50,000 | 200 | ~50 MB |
| Текстовый редактор | 100,000 | 500 | ~150 MB |
| Просмотр логов | 500,000 | 200 | ~400 MB |
| Большие данные | 1,000,000 | 200 | ~800 MB |
| Максимум (риск) | 2,000,000 | 500 | ~1.5 GB |

---

## Примеры настройки для разных сценариев

### 1. IDE Code Editor (RAD Studio, Visual Studio style)
```delphi
SynEdit1.xOpt.Limits.Enabled := True;
SynEdit1.xOpt.Limits.MaxLines := 100000;
SynEdit1.xOpt.Limits.MaxLineLength := 500;
SynEdit1.xOpt.Limits.LengthMode := lmChars;
```

### 2. Log Viewer
```delphi
SynEdit1.xOpt.Limits.Enabled := True;
SynEdit1.xOpt.Limits.MaxLines := 500000;
SynEdit1.xOpt.Limits.MaxLineLength := 1000;
SynEdit1.xOpt.Limits.LengthMode := lmChars;
```

### 3. Embedded Note/Description Editor
```delphi
SynEdit1.xOpt.Limits.Enabled := True;
SynEdit1.xOpt.Limits.MaxLines := 5000;
SynEdit1.xOpt.Limits.MaxLineLength := 300;
SynEdit1.xOpt.Limits.LengthMode := lmChars;
```

### 4. Chat/Message Editor
```delphi
SynEdit1.xOpt.Limits.Enabled := True;
SynEdit1.xOpt.Limits.MaxLines := 1000;
SynEdit1.xOpt.Limits.MaxLineLength := 500;
SynEdit1.xOpt.Limits.LengthMode := lmChars;
```

### 5. SQL Query Editor
```delphi
SynEdit1.xOpt.Limits.Enabled := True;
SynEdit1.xOpt.Limits.MaxLines := 10000;
SynEdit1.xOpt.Limits.MaxLineLength := 1000;
SynEdit1.xOpt.Limits.LengthMode := lmChars;
```

---

## Мониторинг и отладка

### Проверка текущего использования памяти:
```delphi
function GetSynEditMemoryUsage(Editor: TCustomSynEdit): Int64;
var
  LineCount, i: Integer;
  AvgLineLength: Integer;
begin
  LineCount := Editor.Lines.Count;
  AvgLineLength := 0;
  
  // Sample first 100 lines to estimate average
  for i := 0 to Min(99, LineCount - 1) do
    Inc(AvgLineLength, Length(Editor.Lines[i]));
  
  if LineCount > 0 then
    AvgLineLength := AvgLineLength div Min(100, LineCount);
  
  // Estimate total memory
  Result := LineCount * (40 + 24 + AvgLineLength * 2 + 200 + 16);
end;
```

### Предупреждение при загрузке большого файла:
```delphi
procedure TForm1.LoadFileWithCheck(const FileName: string);
var
  FileSize: Int64;
  EstimatedLines: Integer;
begin
  FileSize := GetFileSize(FileName);
  EstimatedLines := FileSize div 50;  // Assume 50 bytes per line average
  
  if EstimatedLines > 500000 then
  begin
    if MessageDlg(Format('Файл содержит примерно %d строк. ' +
                         'Открытие может занять время и использовать много памяти. ' +
                         'Продолжить?', [EstimatedLines]),
                  mtWarning, [mbYes, mbNo], 0) <> mrYes then
      Exit;
  end;
  
  SynEdit1.Lines.LoadFromFile(FileName);
end;
```

---

## Итоговые рекомендации

### 🟢 Безопасный универсальный лимит:
```delphi
MaxLines = 1,000,000 строк
```

### 🟡 Оптимальный для большинства случаев:
```delphi
MaxLines = 100,000 строк
```

### 🔴 Минимум для защиты от краша:
```delphi
MaxLines = 2,000,000 строк (только для специальных случаев!)
```

### ⚠️ НЕ рекомендуется:
```delphi
MaxLines > 2,000,000 строк (риск краша при длинных строках!)
```

---

## Заключение

**Для 99% приложений рекомендуется:**
```delphi
xOpt.Limits.Enabled := True;
xOpt.Limits.MaxLines := 100000;  // 100K строк
xOpt.Limits.MaxLineLength := 500;
```

Это обеспечивает:
- ✅ Полную защиту от краша
- ✅ Отличную производительность
- ✅ Покрытие 99.9% реальных случаев использования
- ✅ Быструю работу даже на старых ПК

---

*Расчёты выполнены для SynEdit 2025.03 на Windows 64-bit*  
*Delphi 13.0 Florence (VER370)*
