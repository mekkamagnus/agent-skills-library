# Assertions vs Types

## Core Trade-off

| Aspect | Runtime Assertions | Compile-Time Types |
|--------|-------------------|-------------------|
| When errors caught | While program runs | Before program runs |
| Performance cost | Yes (every execution) | Zero (compile-time only) |
| Use case | External data boundaries | Internal domain logic |
| Example | `assert(value !== null)` | `value: NonNullable<T>` |

## When to Use Types

Encode invariants in the type system when you control the data:

```typescript
// ✅ GOOD - Type prevents invalid states
type PositiveNumber = number & { readonly __brand: 'Positive' };

const createPositive = (n: number): Result<Error, PositiveNumber> => {
  return n >= 0
    ? Result.ok(n as PositiveNumber)
    : Result.err(new Error(`Negative number: ${n}`));
};

function calculateInterest(principal: PositiveNumber, rate: PositiveNumber): PositiveNumber {
  // No need to assert - type guarantees positivity
  return (principal * rate) as PositiveNumber;
}
```

## When to Use Assertions

Use assertions at boundaries where data enters your system:

```typescript
// ✅ GOOD - Assert at external boundary
interface ExternalApiResponse {
  user?: { id: string; name: string } | null;
}

function fetchUserFromApi(id: string): Result<Error, User> {
  return Result.tryCatch(async () => {
    const response = await fetch(`/api/users/${id}`);
    const data: ExternalApiResponse = await response.json();

    // Assertion boundary - convert external data to typed domain
    if (!data.user) {
      throw new Error('User not found');
    }

    return createUser(data.user.id, data.user.name);
  });
}
```

## Make Illegal States Unrepresentable

```typescript
// ❌ BAD - Assert to check invariant
function processAmount(amount: number) {
  assert(amount >= 0, "Amount must be positive");
  return amount * 1.1; // What if we forget to assert elsewhere?
}

// ✅ GOOD - Type prevents invalid state
type PositiveNumber = number & { readonly __brand: 'Positive' };
function processAmount(amount: PositiveNumber): PositiveNumber {
  // Compiler guarantees amount is positive - no assertion needed
  return (amount * 1.1) as PositiveNumber;
}

// ❌ BAD - Nullable with assertion
function getUserName(user: User | null): string {
  assert(user !== null);
  return user.name;
}

// ✅ GOOD - Option type makes nullability explicit
function getUserName(user: Option<User>): string {
  return user.match({
    some: (u) => u.name,
    none: () => 'Guest',
  });
}
```

## The Boundary Pattern

Structure code to separate typed internals from asserted boundaries:

```typescript
// Boundary: External world (assertions, validation)
function parseInput(raw: unknown): Result<Error, ValidatedInput> {
  // Assert and validate at the edge
  if (typeof raw !== 'object' || raw === null) {
    return Result.err(new Error('Invalid input'));
  }
  // ... validation logic
}

// Core: Pure FP (types only)
function processInput(input: ValidatedInput): Result<Error, Output> {
  // No assertions needed - types guarantee validity
  return input.map(transform).andThen(validate);
}

// Boundary: External world (serialization)
function serializeOutput(output: Output): unknown {
  // Convert to plain types for API response
  return { ...output };
}
```

## Assertion Guidelines

**Use assertions for:**
- API response validation at the boundary
- Parsing user input, files, environment variables
- Type assertions (`as`, `!`) - immediately validate after lying to TypeScript
- Invariant checks in complex algorithms (debug builds only)

**Avoid assertions for:**
- Internal function parameters (use Option/Result instead)
- Domain modeling (use branded types instead)
- Control flow (use Result/Option instead)

## Type Guards as Assertions

Type guards bridge the gap - they're assertions that TypeScript understands:

```typescript
// User-defined type guard
function isUser(data: unknown): data is User {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data
  );
}

// Use at boundary
function processUnknown(data: unknown): Result<Error, User> {
  return Result.tryCatch(() => {
    if (!isUser(data)) {
      throw new Error('Invalid user data');
    }
    return data; // TypeScript knows this is User now
  });
}
```

## Rule of Thumb

1. **Inflow** → Assert at boundaries, convert to Result/Option
2. **Internal** → Pure types only, no assertions
3. **Outflow** → Serialize to plain types at boundaries

The goal: push assertions to the edges, keep the core purely typed.
