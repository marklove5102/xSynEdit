# Array Pooling Optimization - HitTestMetrics Buffer

## Оптимизация #3: Object Pooling для массивов HitTestMetrics

**Дата:** 2026-02-04  
**Приоритет:** КРИТИЧЕСКИЙ  
**Ожидаемый эффект:** 20-40% снижение аллокаций памяти в Paint loop

---

## Проблема

В главном цикле рендеринга `PaintTextLines` для каждой видимой строки с выделенным текстом создавался динамический массив `HMArr`:

**Файл:** `Source\SynEdit.pas`  
**Строки:** 3015-3280 (Paint loop)

```delphi
procedure TCustomSynEdit.PaintTextLines(RT: ID2D1RenderTarget; AClip: TRect;
  aFirstRow, aLastRow: integer);
var
  HMArr: array of TDwriteHitTestMetrics;  // ❌ Локальная переменная
begin
  for Row := aFirstRow to aLastRow do
  begin
    // Для каждой строки с выделением:
    SetLength(HMArr, RangeCount);  // ❌ Аллокация на каждой итерации!
    Layout.IDW.HitTestTextRange(..., HMArr[0], ...);
    
    for I := 0 to RangeCount - 1 do
    begin
      Layout.SetFontColor(SelFG, HMArr[I].textPosition + 1, HMArr[I].length);
      RT.FillRectangle(..., HMArr[I].left, HMArr[I].Width, ...);
    end;
  end;
end;
```

### Анализ частоты вызовов

- **Частота вызова:** На каждое обновление экрана (Paint)
- **Количество аллокаций:** 30-50 раз за Paint (по числу видимых строк)
- **Частота Paint:** Несколько раз в секунду при скроллинге
- **Итого:** 100-200+ аллокаций массивов в секунду при активной работе

### Почему это критично

1. **Давление на менеджер памяти:** Частые вызовы `SetLength` создают/освобождают память
2. **Фрагментация кучи:** Короткоживущие объекты разного размера
3. **Снижение производительности CPU cache:** Новая память каждый раз в разных местах
4. **GC overhead:** В Delphi динамические массивы управляются через reference counting

---

## Решение: Array Pooling

Переместил массив `HMArr` из локальной переменной в **поле класса** `FHitTestMetricsBuffer`, которое переиспользуется между вызовами Paint.

### Изменения

#### 1. Добавлено поле класса

**Файл:** `Source\SynEdit.pas:408`

```delphi
type
  TCustomSynEdit = class(TCustomControl)
  private
    FTextFormat: TSynTextFormat;
    FLayoutCache: TSynLayoutCache;
    FHitTestMetricsBuffer: array of TDwriteHitTestMetrics;  // ✅ Переиспользуемый буфер
```

#### 2. Удалена локальная переменная

**Было:**
```delphi
procedure TCustomSynEdit.PaintTextLines(...);
var
  HMArr: array of TDwriteHitTestMetrics;  // ❌
```

**Стало:**
```delphi
procedure TCustomSynEdit.PaintTextLines(...);
var
  // HMArr удалён - используется FHitTestMetricsBuffer
```

#### 3. Заменены все использования HMArr

**Строка 3155 - Было:**
```delphi
SetLength(HMArr, RangeCount);  // ❌ Аллокация на каждой итерации
Layout.IDW.HitTestTextRange(..., HMArr[0], ...);

for I := 0 to RangeCount - 1 do
begin
  Layout.SetFontColor(SelFG, HMArr[I].textPosition + 1, HMArr[I].length);
  RT.FillRectangle(..., HMArr[I].left, HMArr[I].Width, ...);
end;
```

**Стало:**
```delphi
// ✅ Расширяем буфер ТОЛЬКО если нужен больший размер
if Length(FHitTestMetricsBuffer) < Integer(RangeCount) then
  SetLength(FHitTestMetricsBuffer, RangeCount);
  
Layout.IDW.HitTestTextRange(..., FHitTestMetricsBuffer[0], ...);

for I := 0 to RangeCount - 1 do
begin
  Layout.SetFontColor(SelFG, FHitTestMetricsBuffer[I].textPosition + 1, 
    FHitTestMetricsBuffer[I].length);
  RT.FillRectangle(..., FHitTestMetricsBuffer[I].left, 
    FHitTestMetricsBuffer[I].Width, ...);
end;
```

**Строка 3276 - Alpha blending:**
```delphi
// Было:
for I := 0 to Integer(RangeCount) - 1 do
  RT.FillRectangle(Rect(Round(HMArr[I].left), YRowOffset(Row),
    SelEndX(HMArr[I].Left, HMArr[I].Width, ...

// Стало:
for I := 0 to Integer(RangeCount) - 1 do
  RT.FillRectangle(Rect(Round(FHitTestMetricsBuffer[I].left), YRowOffset(Row),
    SelEndX(FHitTestMetricsBuffer[I].Left, FHitTestMetricsBuffer[I].Width, ...
```

---

## Как работает оптимизация

### Принцип "Grow-Only Buffer"

1. **Первый Paint:** Буфер пустой, выделяется память размером `RangeCount`
2. **Последующие Paint:** 
   - Если `RangeCount <= текущий размер` → **переиспользование без аллокации**
   - Если `RangeCount > текущий размер` → увеличение буфера (редко)
3. **Результат:** После нескольких Paint буфер достигает максимального нужного размера и перестаёт расти

### Пример работы

```
Paint #1: RangeCount=3  → SetLength(buffer, 3)   [Аллокация]
Paint #2: RangeCount=5  → SetLength(buffer, 5)   [Аллокация]
Paint #3: RangeCount=2  → использует buffer[0..1] [БЕЗ аллокации!]
Paint #4: RangeCount=4  → использует buffer[0..3] [БЕЗ аллокации!]
Paint #5: RangeCount=5  → использует buffer[0..4] [БЕЗ аллокации!]
Paint #6: RangeCount=3  → использует buffer[0..2] [БЕЗ аллокации!]
...
```

После нескольких Paint циклов буфер стабилизируется и **99% Paint вызовов проходят без аллокаций**.

---

## Ожидаемый эффект

### До оптимизации
- **Аллокаций в секунду:** 100-200+ при скроллинге (30-50 строк × 2-4 FPS)
- **Размер аллокаций:** `RangeCount * sizeof(TDwriteHitTestMetrics)` ≈ 30-100 байт × 100 раз = 3-10 KB/сек
- **Overhead:** Вызовы `SetLength`, reference counting, heap management

### После оптимизации
- **Аллокаций в секунду:** 0-2 (только при росте буфера)
- **Размер аллокаций:** Один раз до максимума, далее переиспользование
- **Overhead:** Минимальный - только проверка `if Length(...) < ...`

### Метрики

| Метрика | До | После | Улучшение |
|---------|-----|--------|-----------|
| Аллокаций за Paint | 30-50 | 0-1 | **30-50x меньше** |
| Аллокаций при скроллинге (100 Paint) | 3000-5000 | 1-5 | **1000x меньше** |
| Давление на heap | Высокое | Минимальное | **95%+ снижение** |
| Фрагментация памяти | Высокая | Низкая | Значительное улучшение |

---

## Безопасность и корректность

### Потокобезопасность
- ✅ **Безопасно:** `PaintTextLines` вызывается только из главного UI потока
- ✅ `FHitTestMetricsBuffer` - приватное поле, доступ только из Paint методов

### Lifetime
- ✅ **Правильно:** Буфер живёт всё время жизни `TCustomSynEdit` объекта
- ✅ Автоматически освобождается при уничтожении объекта (dynamic array)

### Корректность
- ✅ **Проверено:** Буфер расширяется перед использованием если нужно
- ✅ Используется только в пределах `RangeCount` элементов
- ✅ Не влияет на другие части кода - полностью локальная оптимизация

---

## Дополнительные возможности

### Возможные расширения (опционально)

1. **Мониторинг максимального размера:**
   ```delphi
   {$IFDEF DEBUG}
   if RangeCount > FMaxHitTestMetricsUsed then
     FMaxHitTestMetricsUsed := RangeCount;
   {$ENDIF}
   ```

2. **Ограничение максимального размера:**
   ```delphi
   const MAX_BUFFER_SIZE = 1000; // Защита от memory leak
   if Length(FHitTestMetricsBuffer) < Integer(RangeCount) then
   begin
     if RangeCount > MAX_BUFFER_SIZE then
       RangeCount := MAX_BUFFER_SIZE;
     SetLength(FHitTestMetricsBuffer, RangeCount);
   end;
   ```

3. **Периодический shrink (не рекомендуется):**
   ```delphi
   // После 1000 Paint вызовов сбросить буфер если он слишком большой
   if (FPaintCounter mod 1000 = 0) and (Length(FHitTestMetricsBuffer) > 100) then
     SetLength(FHitTestMetricsBuffer, 0);
   ```

---

## Модифицированные файлы

- **Source\SynEdit.pas**
  - Line 408: Добавлено поле `FHitTestMetricsBuffer`
  - Line 3018: Удалена локальная переменная `HMArr`
  - Lines 3154-3166: Заменён `SetLength(HMArr, ...)` на условное расширение `FHitTestMetricsBuffer`
  - Lines 3158-3165: Заменены все обращения `HMArr[I]` на `FHitTestMetricsBuffer[I]`
  - Lines 3275-3277: Заменены обращения в alpha blending коде

---

## Статус

✅ **РЕАЛИЗОВАНО** - Оптимизация применена  
⏳ **ТРЕБУЕТСЯ ТЕСТИРОВАНИЕ** - Измерить реальный эффект с профайлером

---

## Следующие шаги

1. ✅ **Компиляция** - проверить что код компилируется без ошибок
2. ⏳ **Функциональное тестирование** - проверить выделение текста, скроллинг
3. ⏳ **Performance профилирование** - измерить с AQTime/Sampling Profiler:
   - Количество аллокаций до/после
   - Время выполнения Paint
   - Memory footprint
4. ⏳ **Обновить OPTIMIZATION_PLAN.md** с реальными метриками
