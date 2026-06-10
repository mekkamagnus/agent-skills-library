---
name: claude-bowser
description: Observable browser automation via Chrome MCP. Uses the user's real Chrome browser. Single instance only — no parallel execution. Adapted from Bowser.
allowed-tools: Bash
---

# Claude Bowser

Observable browser automation using Chrome MCP tools. Operates the user's real Chrome browser — they can watch the automation happen live.

## Prerequisites

Requires Claude Code launched with `--chrome` flag:

```bash
claude --chrome
```

Without `--chrome`, the MCP tools (`mcp__claude_in_chrome__*`) are not available.

## Constraint: Single Instance

Only one Chrome MCP session can be active at a time. **Do not spawn multiple agents using this skill.** It cannot run in parallel — use `playwright-bowser` for parallel automation.

## Tools

This skill uses `mcp__claude_in_chrome__*` MCP tools, not `playwright-cli`. Available tools include:

- `mcp__claude_in_chrome__navigate` — go to URL
- `mcp__claude_in_chrome__click` — click element
- `mcp__claude_in_chrome__type` — type text
- `mcp__claude_in_chrome__screenshot` — capture screenshot
- `mcp__claude_in_chrome__get_console_logs` — read console output

## When to Use

**Good for:**
- Interactive debugging — user watches the browser live
- Demo flows — showing someone how a feature works
- Personal browsing automation — logged-in sessions, cookies preserved
- Single-instance tasks — filling forms, checking pages

**Not good for:**
- Parallel QA runs — can only do one at a time
- Headless CI — requires a visible Chrome window
- Isolated test sessions — shares the user's real browser state

## Workflow

1. Navigate to the target URL using `mcp__claude_in_chrome__navigate`
2. Interact with elements using click/type tools
3. Verify state via screenshot or console logs
4. Report results

## Switching to Playwright

If you need parallel execution or headless mode, use `/playwright-bowser` instead. The skills are complementary — `claude-bowser` for observable single-session work, `playwright-bowser` for parallel headless automation.
