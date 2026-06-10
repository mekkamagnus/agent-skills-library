# Testing FP Code

## Testing Result types

```typescript
import { describe, expect, test } from 'bun:test';

describe('getUser', () => {
  test('returns user when found', () => {
    const result = getUser('123');

    expect(result._tag).toBe('ok');
    expect(result.isOk?.()).toBe(true);

    result.match({
      ok: (user) => {
        expect(user.id).toBe('123');
      },
      err: () => {
        throw new Error('Should not reach here');
      }
    });
  });

  test('returns error when not found', () => {
    const result = getUser('999');

    expect(result._tag).toBe('err');
    expect(result.isErr?.()).toBe(true);
    expect(result.error.message).toContain('not found');
  });
});
```

## Testing Option types

```typescript
describe('findUser', () => {
  test('returns some when user exists', () => {
    const result = findUser('123');

    expect(result._tag).toBe('some');
    expect(result.isSome?.()).toBe(true);

    result.match({
      some: (user) => {
        expect(user.name).toBe('Alice');
      },
      none: () => {
        throw new Error('Should not reach here');
      }
    });
  });

  test('returns none when user missing', () => {
    const result = findUser('999');

    expect(result._tag).toBe('none');
    expect(result.isNone?.()).toBe(true);
    expect(result.unwrapOr('Guest')).toBe('Guest');
  });
});
```

## Testing async operations

```typescript
describe('fetchUser', async () => {
  test('fetches and parses user data', async () => {
    const result = await fetchUser('123');

    expect(result).toBeOk();

    result.match({
      ok: (user) => {
        expect(user.id).toBe('123');
      },
      err: () => {
        throw new Error('Should not reach here');
      }
    });
  });
});
```
