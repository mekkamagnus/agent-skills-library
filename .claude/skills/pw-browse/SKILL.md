---
name: pw-browse
description: Headless browser automation using Playwright CLI. Use when you need headless browsing, parallel browser sessions, UI testing, screenshots, web scraping, or browser automation that can run in the background. Keywords - playwright, headless, browser, test, screenshot, scrape, parallel, ui test, blackbox test.
allowed-tools: Bash
---
# pw-browse Skill

Browse and test web applications using **playwright-cli** - a terminal-based Playwright controller.

## Important: Use playwright-cli, NOT the npm package

**ALWAYS use playwright-cli commands** - do NOT import the Playwright npm package in scripts.

Run `playwright-cli --help` for full details.

## Core Commands

### open [url]
Open the browser.

```bash
playwright-cli open http://localhost:8008/
```

### close
Close the browser.

```bash
playwright-cli close
```

### goto <url>
Navigate to a URL.

```bash
playwright-cli goto http://localhost:8008/dashboard
```

### type <text>
Type text into the currently focused editable element.

```bash
playwright-cli type "hello world"
```

### click <ref> [button]
Perform click on a web page. Button defaults to `left`.

```bash
playwright-cli click "#submitBtn"
playwright-cli click "text=Submit"
playwright-cli click "#cancelBtn" right
```

### dblclick <ref> [button]
Perform double click on a web page.

```bash
playwright-cli dblclick "#item"
```

### fill <ref> <text>
Fill text into an editable element.

```bash
playwright-cli fill "#messageInput" "!search playwright"
playwright-cli fill "[name=email]" "user@example.com"
playwright-cli fill "input[type=text]" "search query"
```

### drag <startRef> <endRef>
Perform drag and drop between two elements.

```bash
playwright-cli drag "#draggable" "#droppable"
```

### hover <ref>
Hover over element on page.

```bash
playwright-cli hover "#menu"
```

### select <ref> <val>
Select an option in a dropdown.

```bash
playwright-cli select "#country" "USA"
```

### upload <file>
Upload one or multiple files.

```bash
playwright-cli upload "/path/to/file.pdf"
```

### check <ref> / uncheck <ref>
Check or uncheck a checkbox or radio button.

```bash
playwright-cli check "#agree"
playwright-cli uncheck "#newsletter"
```

### snapshot
Capture page snapshot to obtain element ref.

```bash
playwright-cli snapshot
```

### eval <func> [ref]
Evaluate JavaScript expression on page or element.

```bash
playwright-cli eval "document.title"
playwright-cli eval "window.scrollTo(0, document.body.scrollHeight)"
```

### dialog-accept [prompt] / dialog-dismiss
Accept or dismiss a dialog.

```bash
playwright-cli dialog-accept "John Doe"
playwright-cli dialog-dismiss
```

### resize <w> <h>
Resize the browser window.

```bash
playwright-cli resize 1280 720
```

### delete-data
Delete session data.

```bash
playwright-cli delete-data
```

## Navigation Commands

### go-back / go-forward / reload

```bash
playwright-cli go-back
playwright-cli go-forward
playwright-cli reload
```

## Keyboard Commands

### press <key>
Press a key on the keyboard.

```bash
playwright-cli press Enter
playwright-cli press Escape
playwright-cli press "Meta+a"
```

### keydown <key> / keyup <key>
Press a key down or up on the keyboard.

```bash
playwright-cli keydown Shift
playwright-cli type "text"
playwright-cli keyup Shift
```

## Mouse Commands

### mousemove <x> <y>
Move mouse to a given position.

```bash
playwright-cli mousemove 100 200
```

### mousedown [button] / mouseup [button]
Press mouse down or up. Button defaults to `left`.

```bash
playwright-cli mousedown left
playwright-cli mouseup left
```

### mousewheel <dx> <dy>
Scroll mouse wheel.

```bash
playwright-cli mousewheel 0 -500  # scroll down
```

## Save As Commands

### screenshot [ref]
Screenshot of the current page or element.

```bash
playwright-cli screenshot
playwright-cli screenshot "#header"
```

### pdf
Save page as PDF.

```bash
playwright-cli pdf
```

## Tabs Commands

### tab-list / tab-new [url] / tab-close [index] / tab-select <index>

```bash
playwright-cli tab-list
playwright-cli tab-new http://example.com
playwright-cli tab-close 0
playwright-cli tab-select 1
```

## Storage Commands

### state-load <filename> / state-save [filename]
Load/save browser storage state (authentication).

```bash
playwright-cli state-save auth.json
playwright-cli state-load auth.json
```

### cookie commands
```bash
playwright-cli cookie-list
playwright-cli cookie-get "session"
playwright-cli cookie-set "theme" "dark"
playwright-cli cookie-delete "session"
playwright-cli cookie-clear
```

### localstorage commands
```bash
playwright-cli localstorage-list
playwright-cli localstorage-get "token"
playwright-cli localstorage-set "token" "abc123"
playwright-cli localstorage-delete "token"
playwright-cli localstorage-clear
```

### sessionstorage commands
```bash
playwright-cli sessionstorage-list
playwright-cli sessionstorage-get "temp"
playwright-cli sessionstorage-set "temp" "value"
playwright-cli sessionstorage-delete "temp"
playwright-cli sessionstorage-clear
```

## Network Commands

### route <pattern> / route-list / unroute [pattern]
Mock network requests matching a URL pattern.

```bash
playwright-cli route "**/api/**" '{"status": "ok"}'
playwright-cli route-list
playwright-cli unroute "**/api/**"
```

## DevTools Commands

### console [min-level]
List console messages.

```bash
playwright-cli console
playwright-cli console error
```

### run-code <code>
Run Playwright code snippet.

```bash
playwright-cli run-code "await page.title()"
```

### network
List all network requests since loading the page.

```bash
playwright-cli network
```

### tracing-start / tracing-stop
Start/stop trace recording.

```bash
playwright-cli tracing-start
playwright-cli tracing-stop
```

### video-start / video-stop
Start/stop video recording.

```bash
playwright-cli video-start
playwright-cli video-stop
```

### show / devtools-start
Show browser DevTools.

```bash
playwright-cli show
playwright-cli devtools-start
```

## Browser Sessions

### list / close-all / kill-all

```bash
playwright-cli list
playwright-cli close-all
playwright-cli kill-all
```

## Install Commands

### install / install-browser

```bash
playwright-cli install
playwright-cli install-browser
```

## Selector Tips

- Use camelCase for IDs: `#messageInput` not `#message-input`
- Use text selectors: `text=Submit`, `text=/regex/i`
- Use attribute selectors: `[data-testid="submit"]`
- Use CSS combinators: `div > button:first-child`

## Example: Testing a Chat Interface

```bash
# Open browser and navigate
playwright-cli open http://localhost:8008/

# Wait for page load, then fill input
playwright-cli fill "#messageInput" "!search playwright"

# Send by pressing Enter
playwright-cli press Enter

# Take screenshot
playwright-cli screenshot

# Close browser
playwright-cli close
```
## Full Help

Run `playwright-cli --help` or `playwright-cli --help <command>` for detailed command usage.

See [docs/playwright-cli.md](docs/playwright-cli.md) for full documentation.
