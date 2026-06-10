# Performance Considerations

## When FP has overhead

```typescript
// ❌ Avoid - Unnecessary copying in hot loops
function processMillionItems(items: Item[]): Item[] {
  return items.map(x => ({ ...x, processed: true })); // Creates 1M objects
}

// ✅ Better - Mutate if safe, or use lazy evaluation
function processMillionItems(items: Item[]): Item[] {
  const result = [];
  for (const item of items) {
    const processed = { ...item, processed: true };
    result.push(processed);
  }
  return result;
}
```

## Lazy evaluation for large datasets

```typescript
// Lazy generator instead of eager array
function* filterMap<T, U>(
  items: Iterable<T>,
  filterFn: (item: T) => boolean,
  mapFn: (item: T) => U
): Iterable<U> {
  for (const item of items) {
    if (filterFn(item)) {
      yield mapFn(item);
    }
  }
}

// Only processes what's consumed
for (const result of filterMap(hugeDataset, x => x.valid, x => x.transform)) {
  break; // Only processes first item
}
```

## Early exit in chains

```typescript
// ❌ Avoid - Continues through all chains
const result = data
  .map(x => expensiveOperation(x))
  .filter(x => x.isValid)
  .first(); // Still processed everything

// ✅ Better - Check early
const result = data
  .find(x => x.isValid)
  .map(x => expensiveOperation(x));
```
