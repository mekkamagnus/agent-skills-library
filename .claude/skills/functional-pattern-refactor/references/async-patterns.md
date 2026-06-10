# Async/Await Patterns

## Handling async operations functionally

```typescript
// ❌ BEFORE
async function fetchUser(id: string) {
  try {
    const res = await fetch(`/api/users/${id}`);
    const data = await res.json();
    return data;
  } catch (e) {
    console.error(e);
    return null;
  }
}

// ✅ AFTER
async function fetchUser(id: string): AsyncResult<Error, User> {
  return Result.tryCatchAsync(
    () => fetch(`/api/users/${id}`),
    (e) => new NetworkError(`Failed to fetch: ${e}`)
  ).andThen(async (res) =>
    Result.tryCatchAsync(
      () => res.json(),
      () => new ParseError('Invalid JSON')
    )
  );
}
```

## Sequential async operations

```typescript
// ❌ BEFORE - nested try/catch
async function processUserWorkflow(id: string) {
  try {
    const user = await fetchUser(id);
    if (!user) throw new Error('User not found');
    const validated = await validateUser(user);
    const saved = await saveUser(validated);
    return saved;
  } catch (e) {
    console.error(e);
    return null;
  }
}

// ✅ AFTER - functional chaining
async function processUserWorkflow(id: string): AsyncResult<Error, User> {
  return fetchUser(id)
    .andThen(validateUser)
    .andThen(saveUser);
}
```

## Parallel async operations

```typescript
// ✅ GOOD - AllSettle for parallel operations
async function fetchAllUsers(ids: string[]): AsyncResult<Error, User[]> {
  const results = await Promise.allSettled(
    ids.map(id => fetchUser(id))
  );

  const successes = results
    .filter((r): r is PromiseFulfilledResult<User> => r.status === 'fulfilled')
    .map(r => r.value)
    .filter((r): r is Result<Error, User> => r._tag === 'ok');

  // Combine all errors
  const errors = results
    .filter((r): r is PromiseRejectedResult => r.status === 'rejected')
    .map((r, i) => ({ id: ids[i], error: r.reason }));

  if (errors.length > 0) {
    return Result.err({
      kind: 'aggregate',
      errors,
      message: `Failed to fetch ${errors.length} users`
    } as AppError);
  }

  return Result.ok(successes);
}
```
