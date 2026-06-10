# Migration Strategy

## Gradual adoption path

## Phase 1: Add Types (No Behavior Change)
- Add Result/Option types to codebase
- Keep existing try/catch working
- New code can start using FP patterns
- **Risk**: Low

## Phase 2: New Code Only
- All new functions use Result/Option
- Old code stays as-is
- Adapters/wrappers convert between old and new
- **Risk**: Low

## Phase 3: Refactor Hot Paths
- Identify frequently called functions
- Refactor to use Result/Option
- Add comprehensive tests
- **Risk**: Medium

## Phase 4: Enable Strict Rules
- Turn on `fp/no-let` as error
- Enable `fp/no-loops`
- Add custom linters for try/catch detection
- **Risk**: High

## Adapter pattern for legacy code

```typescript
// Wrap legacy functions in Result types
const legacyGetUser = (id: string): User | null => {
  // old implementation
  return db.find(id) || null;
};

const getUser = (id: string): Result<Error, User> => {
  return Option.fromNullable(legacyGetUser(id))
    .okOr(new Error(`User ${id} not found`));
};
```
