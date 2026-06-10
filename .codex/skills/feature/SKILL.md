---
name: feature
description: "Plan new features with user stories, acceptance criteria, and implementation phases. Use when the user wants to add new functionality, implement a feature, build a new capability, or extend the application. Triggers on: feature, new functionality, add capability, implement, build, create new, extend, enhancement. Also use when the user describes what they want the app to do that it doesn't currently do."
---

# Feature Planning

Create a new plan in specs/*.md to implement the feature using the Plan Format below.

## Instructions

- Write a plan to implement a net new feature that adds value.
- Create the plan in the `specs/` directory. The filename MUST follow `SPEC-###-{slug}.md` format. Run the numbering script to determine the next number:
  ```bash
  python3 ~/.claude/skills/feature/next_spec.py <project-root>/specs <feature-slug>
  ```
  Example: `python3 ~/.claude/skills/feature/next_spec.py ./specs auth-login` → `SPEC-002-auth-login.md`.
- Research the codebase to understand existing patterns, architecture, and conventions.
- Replace every `<placeholder>` in the Plan Format with the requested value.
- Follow existing patterns and conventions. Don't reinvent the wheel.
- Design for extensibility and maintainability.
- If you need a new library, use `uv add` and report it in the Notes section.
- Start research by reading `README.md`.

## Plan Format

```md
# Feature: <feature name>

## Feature Description
<describe the feature in detail, including its purpose and value to users>

## User Story
As a <type of user>
I want to <action/goal>
So that <benefit/value>

## Problem Statement
<clearly define the specific problem or opportunity this feature addresses>

## Solution Statement
<describe the proposed solution approach and how it solves the problem>

## Relevant Files
Use these files to implement the feature:

<list relevant files with bullet points explaining why. Add h3 'New Files' for new files.>

## Implementation Plan
### Phase 1: Foundation
<describe foundational work>

### Phase 2: Core Implementation
<describe main implementation>

### Phase 3: Integration
<describe integration with existing functionality>

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

<list step by step tasks as h3 headers plus bullet points. Last step: run Validation Commands.>

## Testing Strategy
### Unit Tests
<describe unit tests needed>

### Integration Tests
<describe integration tests needed>

### Edge Cases
<list edge cases to test>

## Acceptance Criteria
<list specific, measurable criteria for completion>

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

<list commands to validate with 100% confidence. Every command must execute without errors.>
- `cd app/server && uv run pytest` - Run server tests

## Notes
<optional additional notes or context>
```

## Feature
$ARGUMENTS
