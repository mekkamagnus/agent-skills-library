---
name: adr
description: "Create an Architecture Decision Record. Use when the user wants to document a technical decision, record a design choice, or write an ADR. Triggers on: adr, architecture decision, decision record, document decision."
hooks:
  PreToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "python3 /Users/mekael/.zcode/v2/acp-config/claude/d1e7c6d3d969/skills/adr/validate_adr_name.py"
---

# Architecture Decision Record

Create a new ADR in `docs/adrs/` using the ADR format below. Follow the `Instructions` to create the record.

## Instructions

- You're documenting an architecture decision that was made or is being proposed. Be precise about the context, the decision, and the consequences.
- The filename MUST follow the format `ADR-###-{slug}.md` where `###` is a sequential zero-padded number. Run the numbering script to determine the next number:
  ```bash
  python3 ~/.claude/skills/adr/next_adr.py <project-root>/docs/adrs <adr-slug>
  ```
  Example: `python3 ~/.claude/skills/adr/next_adr.py ./docs/adrs use-postgres` → outputs `ADR-0003-use-postgres.md`.
  The slug should be a short kebab-case name derived from the decision.
- Use the ADR format below. Fill in every section with concrete, specific details — no placeholders.
- Before writing, research the codebase to understand the context and relevant files. Read existing ADRs for precedent.
- THINK HARD about the consequences. Consider both positive and negative outcomes honestly.

## ADR Format

```md
# ADR ####: <title>

**Date**: <YYYY-MM-DD>
**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-####

## Context

<What is the issue that we're seeing that is motivating this decision or change? Include any technical, organizational, or constraint factors that influence the decision. Reference relevant files, issues, or prior ADRs.>

## Decision

<What is the change that we're proposing and/or doing? State the decision clearly and concretely. If there are multiple parts, use numbered sub-decisions.>

## Consequences

### Positive

- <benefit 1>
- <benefit 2>

### Negative

- <drawback 1>

### Neutral

- <side effect that is neither good nor bad>
```

## ADR

$ARGUMENTS
