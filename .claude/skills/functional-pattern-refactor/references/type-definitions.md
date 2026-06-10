# Type Definitions

## Result/Either type

```typescript
type Result<E, T> =
  | { _tag: 'ok'; value: T }
  | { _tag: 'err'; error: E };
```

## Option/Maybe type

```typescript
type Option<T> =
  | { _tag: 'some'; value: T }
  | { _tag: 'none' };
```

## Async Result

```typescript
type AsyncResult<E, T> = Promise<Result<E, T>>;
```

## Result helper

```typescript
const Result = {
  ok: <E, T>(value: T): Result<E, T> => ({ _tag: 'ok', value }),
  err: <E, T>(error: E): Result<E, T> => ({ _tag: 'err', error }),
  tryCatch: <T, E = Error>(
    fn: () => T,
    onError: (error: unknown) => E
  ): Result<E, T> => {
    try {
      return Result.ok(fn());
    } catch (e) {
      return Result.err(onError(e));
    }
  },
  tryCatchAsync: async <T, E = Error>(
    fn: () => Promise<T>,
    onError: (error: unknown) => E
  ): Promise<Result<E, T>> => {
    try {
      return Result.ok(await fn());
    } catch (e) {
      return Result.err(onError(e));
    }
  },
  fromPromise: async <E, T>(
    promise: Promise<T>
  ): Result<E, T> => {
    try {
      return Result.ok(await promise);
    } catch (e) {
      return Result.err(e as E);
    }
  }
};
```

## Option helper

```typescript
const Option = {
  some: <T>(value: T): Option<T> => ({ _tag: 'some', value }),
  none: <T>(): Option<T> => ({ _tag: 'none' }),
  fromNullable: <T>(value: T | null | undefined): Option<T> =>
    value === null || value === undefined
      ? { _tag: 'none' }
      : { _tag: 'some', value },
  map: <T, U>(opt: Option<T>, fn: (value: T) => U): Option<U> =>
    opt._tag === 'some' ? { _tag: 'some', value: fn(opt.value) } : opt,
  andThen: <T, U>(opt: Option<T>, fn: (value: T) => Option<U>): Option<U> =>
    opt._tag === 'some' ? fn(opt.value) : opt,
  unwrapOr: <T>(opt: Option<T>, defaultValue: T): T =>
    opt._tag === 'some' ? opt.value : defaultValue,
  match: <T, U>(
    opt: Option<T>,
    handlers: { some: (value: T) => U; none: () => U }
  ): U => opt._tag === 'some' ? handlers.some(opt.value) : handlers.none(),
  isSome: <T>(opt: Option<T>): opt is { _tag: 'some'; value: T },
  isNone: <T>(opt: Option<T>): opt is { _tag: 'none' },
};
```

## Result methods

```typescript
const resultMethods = {
  map: <E, T, U>(result: Result<E, T>, fn: (value: T) => U): Result<E, U> =>
    result._tag === 'ok' ? Result.ok(fn(result.value)) : result,
  andThen: <E, T, U, E2>(
    result: Result<E, T>,
    fn: (value: T) => Result<E2, U>
  ): Result<E | E2, U> =>
    result._tag === 'ok' ? fn(result.value) : Result.err(result.error),
  match: <E, T, U>(
    result: Result<E, T>,
    handlers: { ok: (value: T) => U; err: (error: E) => U }
  ): U => result._tag === 'ok' ? handlers.ok(result.value) : handlers.err(error),
  unwrapOr: <E, T>(result: Result<E, T>, defaultValue: T): T =>
    result._tag === 'ok' ? result.value : defaultValue,
  isOk: <E, T>(result: Result<E, T>): result is { _tag: 'ok'; value: T },
  isErr: <E, T>(result: Result<E, T>): result is { _tag: 'err' },
};
```
