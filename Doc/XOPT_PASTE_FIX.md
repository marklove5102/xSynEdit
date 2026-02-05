# xOpt Paste Bypass Bug Fix

## Проблема

В xOpt опциях SynEdit есть возможность включить ограничение на количество строк (`MaxLines`) и длину строк (`MaxLineLength`). Однако эти ограничения можно было обойти при вставке текста через Ctrl+V (WM_PASTE).

При обычном вводе символов проверки работали корректно:
- **Source\SynEdit.pas:5684** - проверка `fXOpt.CanAddChar(LineText)` перед вводом символа
- **Source\SynEdit.pas:6353** - проверка `fXOpt.CanAddLine(Lines.Count)` перед добавлением новой строки

Но при вставке через `PasteFromClipboard` → `SetSelTextPrimitiveEx` проверки не выполнялись.

## Решение

Добавлены проверки xOpt лимитов во все три режима вставки в процедуре `SetSelTextPrimitiveEx`:

### 1. InsertNormal (обычная вставка)

**Файл:** `Source\SynEdit.pas`  
**Строки:** 3844-3891

```delphi
// xOpt: Check line count limit
if fXOpt.Limits.Enabled and (fXOpt.Limits.MaxLines > 0) then
begin
  MaxLinesToAdd := fXOpt.Limits.MaxLines - Lines.Count;
  if MaxLinesToAdd <= 0 then
    Exit; // Already at or over limit
  if LineCount > MaxLinesToAdd + 1 then
    LineCount := MaxLinesToAdd + 1; // +1 because first line replaces current
  SetLength(NewLines, LineCount);
end;

// Apply trimming first
if eoTrimTrailingSpaces in Options then
  for I := 0 to LineCount - 1 do
    NewLines[I] := NewLines[I].TrimRight;

// xOpt: Check line length limit for each line
if fXOpt.Limits.Enabled and (fXOpt.Limits.MaxLineLength > 0) then
begin
  for I := 0 to LineCount - 1 do
  begin
    if fXOpt.Limits.GetLineLength(NewLines[I]) > fXOpt.Limits.MaxLineLength then
    begin
      // Truncate line to max length
      case fXOpt.Limits.LengthMode of
        lmChars:
          NewLines[I] := Copy(NewLines[I], 1, fXOpt.Limits.MaxLineLength);
        lmBytes:
          begin
            // For bytes mode, need to truncate carefully to not break UTF-8
            while fXOpt.Limits.GetLineLength(NewLines[I]) > fXOpt.Limits.MaxLineLength do
              SetLength(NewLines[I], Length(NewLines[I]) - 1);
          end;
      end;
    end;
  end;
end;
```

### 2. InsertColumn (колоночная вставка)

**Файл:** `Source\SynEdit.pas`  
**Строки:** 3930-3963

```delphi
if CaretY > Lines.Count then
begin
  // xOpt: Check line count limit before adding new line
  if fXOpt.Limits.Enabled and (fXOpt.Limits.MaxLines > 0) and 
     (Lines.Count >= fXOpt.Limits.MaxLines) then
    Break; // Stop at line limit
    
  TempString := StringofChar(#32, InsertPos - 1) + Str;
  Lines.Add('');
end

// xOpt: Check line length limit
if fXOpt.Limits.Enabled and (fXOpt.Limits.MaxLineLength > 0) then
begin
  if fXOpt.Limits.GetLineLength(TempString) > fXOpt.Limits.MaxLineLength then
  begin
    case fXOpt.Limits.LengthMode of
      lmChars:
        TempString := Copy(TempString, 1, fXOpt.Limits.MaxLineLength);
      lmBytes:
        while fXOpt.Limits.GetLineLength(TempString) > fXOpt.Limits.MaxLineLength do
          SetLength(TempString, Length(TempString) - 1);
    end;
  end;
end;
```

### 3. InsertLine (построчная вставка)

**Файл:** `Source\SynEdit.pas`  
**Строки:** 3995-4070

```delphi
// xOpt: Check line count limit
if fXOpt.Limits.Enabled and (fXOpt.Limits.MaxLines > 0) then
begin
  MaxLinesToAdd := fXOpt.Limits.MaxLines - Lines.Count;
  if MaxLinesToAdd <= 0 then
    Exit; // Already at or over limit
  if LineCount > MaxLinesToAdd then
  begin
    LineCount := MaxLinesToAdd;
    SetLength(NewLines, LineCount);
  end;
end;

// ... для каждой строки ...

// xOpt: Check line length limit for each line
if fXOpt.Limits.Enabled and (fXOpt.Limits.MaxLineLength > 0) then
begin
  for I := 0 to LineCount - 1 do
  begin
    if fXOpt.Limits.GetLineLength(NewLines[I]) > fXOpt.Limits.MaxLineLength then
    begin
      case fXOpt.Limits.LengthMode of
        lmChars:
          NewLines[I] := Copy(NewLines[I], 1, fXOpt.Limits.MaxLineLength);
        lmBytes:
          while fXOpt.Limits.GetLineLength(NewLines[I]) > fXOpt.Limits.MaxLineLength do
            SetLength(NewLines[I], Length(NewLines[I]) - 1);
      end;
    end;
  end;
end;
```

## Поведение исправления

1. **Лимит количества строк (MaxLines):**
   - При вставке текста, превышающего лимит, вставляется только разрешенное количество строк
   - Остальные строки отбрасываются
   - Если лимит уже достигнут, вставка полностью блокируется

2. **Лимит длины строки (MaxLineLength):**
   - При вставке строки, превышающей лимит, строка обрезается до максимальной длины
   - Поддерживаются оба режима: `lmChars` (символы) и `lmBytes` (байты UTF-8)
   - В режиме `lmBytes` обрезка выполняется аккуратно, чтобы не сломать UTF-8 кодировку

3. **Совместимость:**
   - Исправление не затрагивает существующую логику, когда лимиты отключены
   - Все три режима вставки (Normal, Column, Line) теперь соблюдают лимиты
   - Работает с опцией `eoTrimTrailingSpaces`

## Тестирование

Создан тестовый файл `test_xopt_fix.pas` для проверки исправления:

**Тест 1:** Вставка строк сверх лимита
- Настройка: `MaxLines = 5`, уже есть 3 строки
- Действие: Вставка 5 строк через буфер обмена
- Ожидание: Добавится только 2 строки (до достижения лимита)

**Тест 2:** Вставка длинной строки
- Настройка: `MaxLineLength = 20`
- Действие: Вставка строки длиной 48 символов
- Ожидание: Строка обрезается до 20 символов

## Модифицированные файлы

- **Source\SynEdit.pas** - добавлены проверки xOpt лимитов в 3 процедуры вставки

## Статус

✅ **РЕАЛИЗОВАНО** - Исправление добавлено в код  
⏳ **ТРЕБУЕТСЯ ТЕСТИРОВАНИЕ** - Необходима компиляция и проверка на практике

## Примечания

- Исправление использует существующий API xOpt без изменения интерфейса
- Все проверки выполняются эффективно - только если лимиты включены
- Логика обрезки одинакова для всех трех режимов вставки
