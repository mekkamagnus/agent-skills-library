# Type Patterns

## Result Type (Either)

For operations that can fail:

```typescript
// ✅ GOOD - Result type for error handling
type Result<E, T> =
  | { _tag: 'ok'; value: T }
  | { _tag: 'err'; error: E };

// Usage
function getUser(id: string): Result<Error, User> {
  return Result.tryCatch(
    () => db.find(id),
    (error) => new Error(`Failed to find user: ${error}`)
  );
}

// ❌ BAD - try/catch with exceptions
function getUser(id: string): User | null {
  try {
    return db.find(id);
  } catch (e) {
    console.error(e);
    return null;
  }
}
```

## Option Type (Maybe)

For optional/nullable values:

```typescript
// ✅ GOOD - Option type for nullable values
type Option<T> =
  | { _tag: 'some'; value: T }
  | { _tag: 'none' };

// Usage
function findUser(id: string): Option<User> {
  return Option.fromNullable(db.find(id));
}

// ❌ BAD - null checks
function findUser(id: string): User | null {
  const user = db.find(id);
  if (!user) return null;
  return user;
}
```

## AsyncResult Type

For async operations:

```typescript
type AsyncResult<E, T> = Promise<Result<E, T>>;

// Usage
async function fetchUser(id: string): AsyncResult<Error, User> {
  return Result.tryCatchAsync(
    () => fetch(`/api/users/${id}`),
    (e) => new NetworkError(`Failed to fetch: ${e}`)
  ).andThen(res => Result.tryCatchAsync(
    () => res.json(),
    () => new ParseError('Invalid JSON')
  ));
}
```
