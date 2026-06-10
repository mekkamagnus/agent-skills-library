---
name: bug
description: "Plan and resolve bugs with root cause analysis and regression prevention. Use when the user reports a bug, defect, error, crash, unexpected behavior, or asks to fix something broken. Also use for investigating issues, debugging problems, or troubleshooting failures. Triggers on: bug, fix, broken, error, crash, defect, issue, not working, unexpected."
---

# Bug Planning

Create a new plan in specs/*.md to resolve the bug using the Plan Format below.

## Instructions

- Write a plan to resolve a bug — thorough and precise so we fix the root cause and prevent regressions.
- Create the plan in the `specs/` directory. The filename MUST follow `BUG-##-{slug}.md` format. Run the numbering script to determine the next number:
  ```bash
  python3 ~/.claude/skills/bug/next_bug.py <project-root>/specs <bug-slug>
  ```
  Example: `python3 ~/.claude/skills/bug/next_bug.py ./specs card-generate-button` → `BUG-01-card-generate-button.md`.
- Research the codebase to understand the bug, reproduce it, and put together a plan.
- Replace every `<placeholder>` in the Plan Format with the requested value.
- Be surgical with the fix — minimal changes that solve the bug at hand.
- If you need a new library, use `uv add` and report it in the Notes section.
- Start research by reading `README.md`.

## Plan Format

```md
# Bug: <bug name>

## Bug Description
<describe the bug in detail, including symptoms and expected vs actual behavior>

## Problem Statement
<clearly define the specific problem that needs to be solved>

## Solution Statement
<describe the proposed solution approach to fix the bug>

## Steps to Reproduce
<list exact steps to reproduce the bug>

## Root Cause Analysis
<analyze and explain the root cause of the bug>

## Relevant Files
Use these files to fix the bug:

<list relevant files with bullet points explaining why. Add h3 'New Files' for new files.>

## Step by Step Tasks
IMPORTANT: Execute every step in order, top to bottom.

<list step by step tasks as h3 headers plus bullet points. Last step: run Validation Commands.>

## Validation Commands
Execute every command to validate the bug is fixed with zero regressions.

<list commands to validate with 100% confidence. Every command must execute without errors.>
- `cd app/server && uv run pytest` - Run server tests

## Notes
<optional additional notes or context>
```

## Bug
$ARGUMENTS
