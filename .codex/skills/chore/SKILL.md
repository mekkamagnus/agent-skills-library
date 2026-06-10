---
name: chore
description: "Plan maintenance tasks, cleanups, refactoring, and other non-feature non-bug work. Use when the user wants to plan a chore, maintenance task, dependency update, code cleanup, refactoring, configuration change, or any technical work that isn't a bug fix or new feature. Triggers on: chore, cleanup, refactor, maintenance, update deps, tidy, reorganize, rename, migrate."
---

# Chore Planning

Create a new plan in specs/*.md to resolve the chore using the Plan Format below.

## Instructions

- Write a plan to resolve a chore — simple but thorough so we don't miss anything.
- Create the plan in the `specs/` directory. The filename MUST follow `CHORE-##-{slug}.md` format. Run the numbering script to determine the next number:
  ```bash
  python3 ~/.claude/skills/chore/next_chore.py <project-root>/specs <chore-slug>
  ```
  Example: `python3 ~/.claude/skills/chore/next_chore.py ./specs update-deps` → `CHORE-01-update-deps.md`.
- Research the codebase and put together a plan.
- Replace every `<placeholder>` in the Plan Format with the requested value.
- Start research by reading `README.md`.

## Plan Format

```md
# Chore: <chore name>

## Chore Description
<describe the chore in detail>

## Relevant Files
Use these files to resolve the chore:

<list relevant files with bullet points explaining why. Add h3 'New Files' for new files.>

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

<list step by step tasks as h3 headers plus bullet points. Last step: run Validation Commands.>

## Validation Commands
Execute every command to validate the chore is complete with zero regressions.

<list commands to validate with 100% confidence. Every command must execute without errors. Don't validate with curl.>
- `cd app/server && uv run pytest` - Run server tests

## Notes
<optional additional notes or context>
```

## Chore
$ARGUMENTS
