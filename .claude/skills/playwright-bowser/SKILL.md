---
name: playwright-bowser
description: Headless browser automation via playwright-cli. Supports named sessions for parallel execution, persistent profiles, accessibility tree snapshots, and vision mode. Adapted from Bowser.
allowed-tools: Bash
---

# Playwright Bowser

Headless browser automation using playwright-cli with named sessions, accessibility-tree snapshots, and optional vision mode.

## Session Management

Every command targets a named session via `-s={name}`. Named sessions isolate browser state — multiple agents can run in parallel without interference.

```bash
# Open a page in a named session with persistent profile
playwright-cli -s=my-session open https://example.com --persistent

# Close when done (always do this)
playwright-cli -s=my-session close
```

**Always close sessions when done.** Leaked sessions hold browser processes.

## Viewport

Set via environment variable:

```bash
PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 playwright-cli -s=my-session open https://example.com --persistent
```

## Finding Elements

Use `snapshot` to get the accessibility tree. Elements have `ref=N` identifiers used for targeting:

```bash
playwright-cli -s=my-session snapshot
```

Output contains lines like:
```
link "Sign in" [ref=5]
textbox "Email" [ref=12]
button "Submit" [ref=15]
```

Use those `ref=N` values as targets for `click`, `fill`, etc.

## Commands

### Navigation

```bash
# Open URL
playwright-cli -s={session} open {url} --persistent

# Snapshot (accessibility tree)
playwright-cli -s={session} snapshot
```

### Interaction

```bash
# Click element by ref
playwright-cli -s={session} click ref={N}

# Fill text into element
playwright-cli -s={session} fill ref={N} "text content"

# Type into focused element
playwright-cli -s={session} type "text content"

# Press keyboard key
playwright-cli -s={session} press Enter
playwright-cli -s={session} press Tab
```

### Capture

```bash
# Screenshot to file
playwright-cli -s={session} screenshot --filename=path/to/file.png

# Console log (for error checking)
playwright-cli -s={session} console
```

### Cleanup

```bash
# Close session
playwright-cli -s={session} close

# Kill all sessions (emergency)
playwright-cli kill-all
```

## Vision Mode

Replace accessibility-tree interactions with screenshot-based vision. The agent "sees" the page visually instead of reading the accessibility tree.

```bash
PLAYWRIGHT_MCP_CAPS=vision playwright-cli -s={session} screenshot
```

Vision mode is more token-expensive but handles visual layouts the accessibility tree can't represent (canvas, complex CSS, etc.).

## Patterns

### Single-page verification

```bash
SESSION="verify-$(date +%s)"
PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 playwright-cli -s=$SESSION open https://example.com --persistent
playwright-cli -s=$SESSION snapshot
playwright-cli -s=$SESSION screenshot --filename=screenshots/home.png
playwright-cli -s=$SESSION console
playwright-cli -s=$SESSION close
```

### Multi-step interaction

```bash
SESSION="login-test"
PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 playwright-cli -s=$SESSION open https://example.com/login --persistent
playwright-cli -s=$SESSION snapshot
# → find ref=N for email field
playwright-cli -s=$SESSION fill ref=5 "user@example.com"
playwright-cli -s=$SESSION fill ref=8 "password123"
playwright-cli -s=$SESSION click ref=12
playwright-cli -s=$SESSION snapshot
playwright-cli -s=$SESSION screenshot --filename=screenshots/after-login.png
playwright-cli -s=$SESSION close
```

### Parallel sessions

Each agent or test gets its own session name. Sessions are independent:

```bash
# Agent 1
playwright-cli -s=test-1 open https://example.com --persistent

# Agent 2 (parallel, isolated)
playwright-cli -s=test-2 open https://example.com --persistent
```

## Troubleshooting

```bash
# Check if daemon is stuck
playwright-cli kill-all

# Reinstall browser binaries
playwright-cli install-browser

# Verify installation
playwright-cli --version
```
