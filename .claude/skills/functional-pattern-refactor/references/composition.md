# Function Composition

## Pipe operator for composition

```typescript
// Helper for function composition
const pipe = <T>(...fns: Array<(arg: T) => T>) => (value: T): T =>
  fns.reduce((acc, fn) => fn(acc), value);

// Usage
const process = pipe(
  validate,
  transform,
  save
);

// Instead of
const result = save(transform(validate(data)));
```

## Currying for partial application

```typescript
// ❌ BEFORE
function filterBy(category: string, items: Item[]) {
  return items.filter(item => item.category === category);
}

// ✅ AFTER - curried for reusability
const filterBy = (category: string) => (items: Item[]): Item[] =>
  items.filter(item => item.category === category);

const getProjects = filterBy('projects');
const getIdeas = filterBy('ideas');
```

## Combining multiple functions

```typescript
// ❌ BEFORE
function processItems(items: Item[]) {
  const filtered = items.filter(x => x.active);
  const mapped = filtered.map(x => ({ ...x, processed: true }));
  return mapped;
}

// ✅ AFTER - composed pipeline
const processItems = pipe(
  filter(x => x.active),
  map(x => ({ ...x, processed: true }))
);
```
