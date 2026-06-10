# Advanced Patterns

## Railway-oriented programming

```typescript
// Track state transitions through type system
type State =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Data }
  | { status: 'error'; error: Error };

function transition(state: State, action: Action): State {
  switch (state.status) {
    case 'idle':
      return action.type === 'fetch'
        ? { status: 'loading' }
        : state;
    case 'loading':
      return action.type === 'success'
        ? { status: 'success', data: action.data }
        : action.type === 'error'
        ? { status: 'error', error: action.error }
        : state;
    default:
      return state;
  }
}
```

## State machines with exhaustive matching

```typescript
// TypeScript ensures all cases are handled
function processState(state: State): void {
  switch (state.status) {
    case 'idle':
      console.log('Ready to start');
      break;
    case 'loading':
      console.log('Loading...');
      break;
    case 'success':
      console.log('Loaded:', state.data);
      break;
    case 'error':
      console.error('Error:', state.error);
      break;
  }
}
```
