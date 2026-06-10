# Branded Types for Type Safety

## Branded types prevent mixing domains

```typescript
type USD = { _brand: 'USD'; value: number };
type EUR = { _brand: 'EUR'; value: number };

const usd = (n: number): USD => ({ _brand: 'USD', value: n });
const eur = (n: number): EUR => ({ _brand: 'EUR', value: n });

const addUSD = (a: USD, b: USD): USD => usd(a.value + b.value);

// Type error - can't add different currencies!
// addUSD(usd(10), eur(10)); // ❌ Error
addUSD(usd(10), usd(5));  // ✅ OK
```

## Opaque types for domain modeling

```typescript
// Prevent primitive obsession
type UserId = string & { readonly __brand: unique symbol };
type Email = string & { readonly __brand: 'Email' };

const createUserId = (id: string): UserId => id as UserId;
const createEmail = (email: string): Email => email as Email;

function sendEmail(to: Email, subject: string) {
  // Type-safe - can't pass raw string by mistake
}

// ❌ Error
sendEmail('user@example.com', 'Hello');

// ✅ OK
sendEmail(createEmail('user@example.com'), 'Hello');
```
