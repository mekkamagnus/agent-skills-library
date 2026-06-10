# Common Pitfalls

## Don't nest match/andThen too deeply

```typescript
// ❌ BAD - Hard to read, hard to debug
result.andThen(x =>
  x.andThen(y =>
    y.andThen(z => ...)
  )
);

// ✅ GOOD - Flat structure, use helper functions
result.andThen(processLayer1)
  .andThen(processLayer2)
  .andThen(processLayer3);

// Or extract into named functions
const processAll = pipe(
  processLayer1,
  processLayer2,
  processLayer3
);
```

## Don't unwrap too early

```typescript
// ❌ BAD - Loses type safety
function process(config: Option<Config>) {
  const cfg = config.unwrapOr(defaultConfig); // Now just a Config
  if (cfg.apiKey) { ... } // No longer wrapped in Option
}

// ✅ GOOD - Keep wrapped, use map/andThen
function process(config: Option<Config>) {
  return config
    .map(c => c.apiKey)
    .andThen(apiKey => fetchWithKey(apiKey));
}
```

## Don't mix paradigms

```typescript
// ❌ BAD - Inconsistent error handling
function processData(data: string) {
  if (error) throw new Error('Bad data');
  return JSON.parse(data); // Can throw!
}

// ✅ GOOD - Consistent Result type
function processData(data: string): Result<Error, Data> {
  return Result.tryCatch(
    () => JSON.parse(data),
    (e) => new Error(`Invalid JSON: ${e}`)
  );
}
```

## Don't ignore errors

```typescript
// ❌ BAD - Swallows errors
const result = someOperation();
result.match({ ok: (v) => v, err: () => {} }); // Error lost

// ✅ GOOD - Always handle errors
const result = someOperation();
result.match({
  ok: (v) => v,
  err: (error) => {
    logger.error('Operation failed', { error });
    return defaultValue; // Explicit fallback
  }
});
```

## Avoid wrapper hell

```typescript
// ❌ BAD - Layers of nested Result.tryCatch
function process() {
  return Result.tryCatch(() =>
    Result.tryCatch(() =>
      Result.tryCatch(() =>
        doWork(),
        (e) => new Error('Level 3')
      ),
      (e) => new Error('Level 2')
    ),
    (e) => new Error('Level 1')
  );
}

// ✅ GOOD - Linear chain with early returns
function process(): Result<Error, Work> {
  const step1 = doStep1();
  if (step1.isErr()) return step1;

  const step2 = doStep2(step1.value);
  if (step2.isErr()) return step2;

  return doStep3(step2.value);
}
```
