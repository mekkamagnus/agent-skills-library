---
name: functional-pattern-refactor
description: Refactor code to functional programming patterns using Result/Option types. Use when: (1) Converting imperative code to functional patterns, (2) Implementing Result/Option/Maybe error handling, (3) Refactoring away try/catch, if/else chains, and null checks, (4) Enforcing immutability and pure functions, (5) Writing tests for FP code, (6) Migrating codebases to functional-first architecture. Keywords: functional programming, FP, refactor, Result, Option, Either, Maybe, immutability, pure functions, tryCatch.
---

# Functional Pattern Refactor

Refactor code to functional-first patterns using Result, Option, and Maybe types.

## Core Principles

1. **No Exceptions** - Use Result/Either types for error handling
2. **No Null/Undefined** - Use Option/Maybe types for optional values
3. **Immutability** - Use `const`, no reassignment
4. **Pure Functions** - No side effects, same input → same output
5. **Composition** - Use `map`/`filter`/`reduce` over loops

## Quick Reference

| Pattern | Avoid | Use Instead |
|---------|-------|-------------|
| Error handling | `try/catch`, throw | `Result.tryCatch`, `.match()` |
| Null values | `null`, `undefined`, `if (x)` | `Option.fromNullable`, `.match()` |
| Chaining | `if/else`, nested `if` | `.andThen()`, `.map()` |
| Mutation | `let`, `x.y = z` | `const`, `{...x, y: z}` |
| Loops | `for`, `while` | `.map()`, `.filter()`, `.reduce()` |
| Async | Nested try/catch | `Result.tryCatchAsync`, `.andThen()` |
| External data | Internal assertions | Boundary: assert→convert→types |
| Invariants | Runtime checks | Branded types, "make illegal states unrepresentable" |

## When NOT to Use FP

- External APIs requiring exceptions
- Performance-critical tight loops
- Framework-required patterns (React hooks, class components)
- Simple scripts where FP overhead isn't justified

## Pre-Refactoring Setup

**Before refactoring**, ensure the project has proper linting configuration to catch FP violations.

### Step 1: Check Existing Configuration

```bash
# Check for ESLint
ls eslint.config.*  # flat config (ESLint 9+)
ls .eslintrc.*      # legacy config

# Check for Biome
ls biome.json

# Check package.json scripts
cat package.json | grep -A5 '"scripts"'
```

### Step 2: ESLint Configuration Template

**Install dependencies:**
```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-plugin-fp
```

**Create `eslint.config.mjs` (flat config):**
```javascript
/**
 * ESLint Configuration with Functional-First Programming Rules
 */
import fp from 'eslint-plugin-fp';
import tsParser from '@typescript-eslint/parser';
import tsPlugin from '@typescript-eslint/eslint-plugin';

export default [
  {
    files: ['**/*.ts', '**/*.tsx'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        project: './tsconfig.json',
        tsconfigRootDir: import.meta.dirname,
      },
      ecmaVersion: 2022,
      sourceType: 'module',
    },
    plugins: {
      '@typescript-eslint': tsPlugin,
      fp,
    },
    rules: {
      // Core FP rules
      'fp/no-let': 'error',
      'fp/no-delete': 'error',
      'fp/no-arguments': 'error',
      'fp/no-rest-parameters': 'warn',
      'fp/no-loops': 'warn',

      // Unused variables (prefix with _ to ignore)
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      '@typescript-eslint/no-floating-promises': 'error',

      // Immutability
      'no-var': 'error',
      'prefer-const': 'warn',
      'no-const-assign': 'error',
      'no-param-reassign': 'warn',
    },
  },
  // Test files - more permissive
  {
    files: ['**/*.test.ts', '**/*.spec.ts', 'tests/**/*.ts'],
    rules: {
      'fp/no-loops': 'off',
      'no-console': 'off',
    },
  },
];
```

### Step 3: Biome Configuration Template

**Install Biome (ESLint alternative):**
```bash
npm install --save-dev @biomejs/biome
```

**Create `biome.json`:**
```json
{
  "$schema": "https://biomejs.dev/schemas/1.5.0/schema.json",
  "files": {
    "ignore": ["node_modules", "dist", "build"]
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "style": {
        "useConst": "error",
        "noVar": "error",
        "noArguments": "warn",
        "noParameterAssign": "warn"
      },
      "correctness": {
        "noUnusedVariables": "error",
        "noUnusedImports": "error",
        "noConstAssign": "error"
      },
      "suspicious": {
        "noConsoleLog": "warn",
        "noDelete": "warn",
        "noExplicitAny": "warn"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "semicolons": "always"
    }
  }
}
```

### Step 4: Package.json Scripts

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "lint:fp": "eslint . --rule 'fp/no-let:error' --rule 'fp/no-loops:warn'",
    "check": "biome check .",
    "check:fix": "biome check --write ."
  }
}
```

### Step 5: Run Baseline Linting

```bash
# Establish baseline
npm run lint 2> lint-baseline.txt

# Count issues
npm run lint | grep -E '(error|warning)' | wc -l
```

**Track progress:** Re-run after refactoring to verify improvements.

## Detailed References

Load these when needed:

- **[assertions-vs-types.md](references/assertions-vs-types.md)** - Runtime assertions vs compile-time types, boundary pattern
- **[type-patterns.md](references/type-patterns.md)** - Result, Option, AsyncResult definitions and examples
- **[async-patterns.md](references/async-patterns.md)** - Sequential/parallel async operations
- **[composition.md](references/composition.md)** - Pipe operator, currying, function combination
- **[branded-types.md](references/branded-types.md)** - Type safety with branded/opaque types
- **[testing.md](references/testing.md)** - Testing Result/Option/AsyncResult patterns
- **[migration.md](references/migration.md)** - 4-phase gradual adoption strategy
- **[performance.md](references/performance.md)** - Lazy evaluation, early exit, hot paths
- **[pitfalls.md](references/pitfalls.md)** - Common mistakes and how to avoid them
- **[advanced.md](references/advanced.md)** - Railway-oriented programming, state machines
- **[type-definitions.md](references/type-definitions.md)** - Generic type definitions
- **[tooling.md](references/tooling.md)** - ESLint fp rules, Biome, custom linters

## Implementation Checklist

### Setup (First)
- [ ] Configure ESLint or Biome with FP rules (see Pre-Refactoring Setup)
- [ ] Run baseline linting to identify violations
- [ ] Ensure FP types (Result/Option) are available in project

### Core Refactoring
- [ ] Replace `try/catch` with `Result.tryCatch`
- [ ] Replace `null/undefined` returns with `Option`
- [ ] Replace `if/else` Result handling with `.match()`
- [ ] Replace `let` with `const`
- [ ] Replace imperative loops with `map/filter/reduce`
- [ ] Use object spread instead of mutation
- [ ] Use `.andThen()` for chaining Results
- [ ] Write tests for Result/Option branches

## Common Libraries

- **fp-ts** - TypeScript functional programming
- **neverthrow** - Error handling with Result types
- **remeda** - Immutability and data transformation
- **effect-ts** - Type-safe functional effects
