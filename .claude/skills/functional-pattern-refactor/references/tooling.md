# Tooling

## ESLint FP rules

```bash
bun add -D eslint-plugin-fp
```

```json
{
  "rules": {
    "fp/no-let": "error",
    "fp/no-loops": "warn",
    "fp/no-mutating-methods": "error"
  }
}
```

## Biome as alternative

Biome provides faster linting with some FP support:

```json
{
  "linter": {
    "rules": {
      "style": {
        "useConst": "error",
        "noVar": "error",
        "noParameterAssign": "warn"
      },
      "complexity": {
        "noForEach": "warn"
      }
    }
  }
}
```

## Custom linter script

```typescript
// scripts/lint-fp.ts
const FP_VIOLATIONS = [
  { pattern: /catch\s*\(/, message: 'Use Result.tryCatch instead' },
  { pattern: /if\s*\([^)]+\)\s*{[\s\S]*?else/, message: 'Use result.match() instead' },
  { pattern: /!==\s*null|\!==\s*undefined/, message: 'Use Option.fromNullable()' },
];

function checkFile(filePath: string) {
  const content = fs.readFileSync(filePath, 'utf-8');
  content.split('\n').forEach((line, i) => {
    FP_VIOLATIONS.forEach(({ pattern, message }) => {
      if (pattern.test(line)) {
        console.log(`${filePath}:${i + 1}: ${message}`);
      }
    });
  });
}
```
