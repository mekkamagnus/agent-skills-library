# Playwright Browser Skill

Launches and controls a Playwright browser for web automation, testing, and scraping.

## Usage

```
/playwright-browser [action]
```

Available actions:
- `start` - Launch the browser
- `navigate <url>` - Navigate to a URL
- `screenshot [path]` - Take a screenshot
- `snapshot` - Capture accessibility snapshot
- `close` - Close the browser
- `run <code>` - Run Playwright code
- `type <selector> <text>` - Type text into an element
- `click <selector>` - Click an element
- `fill <form_fields_json>` - Fill multiple form fields
- `wait_for <text>` - Wait for text to appear
- `console` - Get console messages

## Examples

```
/playwright-browser start
/playwright-browser navigate https://example.com
/playwright-browser screenshot example.png
/playwright-browser close
```

## Implementation

Located at `.claude/skills/playwright-browser/`.
