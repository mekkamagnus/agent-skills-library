#!/usr/bin/env bun
/**
 * Playwright Browser Control Script
 * Usage: ./playwright-browser.ts [action] [args...]
 */

import { launch } from 'playwright';
import { stderr, stdout } from 'node:process';

const BROWSER = {
  instance: null as any,
  page: null as any,
  context: null as any,
};

async function startBrowser() {
  if (BROWSER.instance) {
    console.log('Browser already running');
    return;
  }

  BROWSER.instance = await launch('chromium', { headless: false });
  BROWSER.context = await BROWSER.instance.newContext();
  BROWSER.page = await BROWSER.context.newPage();

  console.log('Browser started');
}

async function navigateTo(url: string) {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  await BROWSER.page.goto(url);
  console.log(`Navigated to: ${url}`);
}

async function takeScreenshot(path?: string) {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
  const defaultPath = `screenshot-${timestamp}.png`;
  const screenshotPath = path || defaultPath;

  await BROWSER.page.screenshot({ path: screenshotPath });
  console.log(`Screenshot saved to: ${screenshotPath}`);
}

async function captureSnapshot() {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  const snapshot = await BROWSER.page.accessibility.snapshot();
  console.log(snapshot);
}

async function closeBrowser() {
  if (BROWSER.instance) {
    await BROWSER.instance.close();
    BROWSER.instance = null;
    BROWSER.page = null;
    BROWSER.context = null;
    console.log('Browser closed');
  } else {
    console.log('Browser not running');
  }
}

async function runCode(code: string) {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  try {
    const result = await BROWSER.page.evaluate(code);
    console.log('Result:', result);
  } catch (error) {
    console.error('Error:', error);
  }
}

async function typeInto(selector: string, text: string) {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  await BROWSER.page.fill(selector, text);
  console.log(`Typed "${text}" into ${selector}`);
}

async function clickElement(selector: string) {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  await BROWSER.page.click(selector);
  console.log(`Clicked: ${selector}`);
}

async function fillForm(fieldsJson: string) {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  const fields = JSON.parse(fieldsJson);
  for (const field of fields) {
    await BROWSER.page.fill(field.selector, field.value);
    console.log(`Filled ${field.selector} with "${field.value}"`);
  }
}

async function waitForText(text: string) {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  await BROWSER.page.waitForSelector(`text=${text}`, { timeout: 30000 });
  console.log(`Found text: ${text}`);
}

async function getConsoleMessages() {
  if (!BROWSER.page) {
    console.error('Browser not started. Run start first.');
    process.exit(1);
  }

  // Get console messages (requires listener setup)
  console.log('Console messages not available in this implementation');
}

// Main CLI handler
const action = process.argv[2];
const args = process.argv.slice(3);

async function main() {
  try {
    switch (action) {
      case 'start':
        await startBrowser();
        break;
      case 'navigate':
        if (!args[0]) {
          console.error('Usage: playwright-browser navigate <url>');
          process.exit(1);
        }
        await navigateTo(args[0]);
        break;
      case 'screenshot':
        await takeScreenshot(args[0]);
        break;
      case 'snapshot':
        await captureSnapshot();
        break;
      case 'close':
        await closeBrowser();
        break;
      case 'run':
        if (!args[0]) {
          console.error('Usage: playwright-browser run <javascript_code>');
          process.exit(1);
        }
        await runCode(args[0]);
        break;
      case 'type':
        if (!args[0] || !args[1]) {
          console.error('Usage: playwright-browser type <selector> <text>');
          process.exit(1);
        }
        await typeInto(args[0], args[1]);
        break;
      case 'click':
        if (!args[0]) {
          console.error('Usage: playwright-browser click <selector>');
          process.exit(1);
        }
        await clickElement(args[0]);
        break;
      case 'fill':
        if (!args[0]) {
          console.error('Usage: playwright-browser fill \'[{"selector":"css","value":"text"}]\'');
          process.exit(1);
        }
        await fillForm(args[0]);
        break;
      case 'wait':
        if (!args[0]) {
          console.error('Usage: playwright-browser wait <text>');
          process.exit(1);
        }
        await waitForText(args[0]);
        break;
      case 'console':
        await getConsoleMessages();
        break;
      default:
        console.log(`Available actions:
  start           - Launch the browser
  navigate <url>   - Navigate to a URL
  screenshot [path] - Take a screenshot
  snapshot        - Capture accessibility snapshot
  close           - Close the browser
  run <code>      - Run Playwright code
  type <sel> <txt> - Type text into element
  click <sel>     - Click an element
  fill <json>      - Fill form fields
  wait <text>     - Wait for text to appear
  console         - Get console messages`);
        process.exit(0);
    }
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  } finally {
    // Don't auto-close - keep browser open for interactive use
    if (action !== 'close' && action !== 'start' && action !== 'navigate' && action !== 'screenshot' && action !== 'snapshot' && action !== 'run' && action !== 'type' && action !== 'click' && action !== 'fill' && action !== 'wait') {
      // For quick actions, close browser after
      // await closeBrowser();
    }
  }
}

main();
