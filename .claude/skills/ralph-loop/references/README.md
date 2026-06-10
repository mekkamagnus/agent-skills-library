# Ralph Loop Skill - Complete Guide

Autonomous AI agent system for systematic PRD implementation using Test-Driven Development.

## Table of Contents

- [Overview](#overview)
- [Environment Setup](#environment-setup)
- [PRD Requirements](#prd-requirements)
- [Usage](#usage)
- [Progress Tracking](#progress-tracking)
- [Archive Management](#archive-management)
- [Best Practices](#best-practices)

## Overview

Ralph Loop is an autonomous AI agent that systematically implements user stories from a Product Requirements Document (PRD) using Test-Driven Development (TDD) methodology.

**Key Features:**
- Multi-agent support (qwen, codex, gemini, opencode)
- TDD-mandated workflow (tests first, implementation second)
- Automatic progress tracking and archiving
- Tmux integration for long-running sessions
- Quality gates (tests must pass before commit)
- Branch-aware execution

## Environment Setup

### Required Tools

**Essential:**
```bash
# Install jq for JSON parsing
brew install jq  # macOS
# OR
sudo apt-get install jq  # Linux

# Install tmux (optional, recommended for long sessions)
brew install tmux  # macOS
# OR
sudo apt-get install tmux  # Linux
```

**AI Agents (install at least one):**
```bash
# Qwen (default, balanced capability)
npm install -g @anthropic-ai/qwen

# Codex (best for complex refactoring)
npm install -g @anthropic-ai/codex

# Gemini (alternative for code synthesis)
npm install -g @anthropic-ai/gemini

# OpenCode (lightweight option)
npm install -g @anthropic-ai/opencode
```

### Project Structure

```
your-project/
├── prd.json                           # PRD file (auto-created if missing)
└── .claude/
    └── skills/
        └── ralph-loop/
            ├── SKILL.md               # Skill definition
            ├── scripts/
            │   ├── ralph.sh           # Main Ralph loop
            │   ├── prompt.md          # Agent instructions
            │   ├── prd_example.json   # PRD template
            │   ├── start-tmux.sh      # Tmux integration
            │   ├── status.sh          # Status checker
            │   ├── progress.txt       # Progress log
            │   ├── archive/           # Archived runs
            │   └── .last-branch       # Branch tracking
            └── references/
                └── README.md          # This file
```

## PRD Requirements

### PRD Structure

Your `prd.json` file must follow this structure:

```json
{
  "projectName": "your-project-name",
  "branchName": "ralph/001-feature-name",
  "userStories": [
    {
      "id": "US-001",
      "title": "Clear, descriptive title",
      "description": "Detailed description of what needs to be done",
      "acceptanceCriteria": [
        "Specific, testable condition 1",
        "Specific, testable condition 2",
        "Specific, testable condition 3"
      ],
      "priority": 10,
      "passes": false,
      "notes": "Optional context or references"
    }
  ]
}
```

### Field Descriptions

**Required Fields:**
- `projectName`: Name of your project
- `branchName`: Git branch for this Ralph session (format: `ralph/XXX-description`)
- `userStories`: Array of user story objects

**User Story Fields:**
- `id`: Unique identifier (e.g., `US-001`, `US-002`)
- `title`: Short, descriptive title
- `description`: Detailed description of requirements
- `acceptanceCriteria`: Array of testable conditions
- `priority`: Integer (1=P0/critical, 10=P1/important, 20=P2/nice-to-have)
- `passes`: Boolean - Ralph sets to `true` when complete
- `notes`: Optional context, dependencies, or references

### Creating Your PRD

**Option 1: Auto-create from example**
```bash
# Run Ralph - it will auto-create prd.json from the example template
skill: "ralph-loop"

# Then edit prd.json to customize your project
vim prd.json
```

**Option 2: Manual creation**
```bash
# Copy the example template
cp .claude/skills/ralph-loop/scripts/prd_example.json prd.json

# Edit to customize
vim prd.json
```

### Writing Good User Stories

**Characteristics of good user stories:**
1. **Independent**: Can be completed in one iteration
2. **Testable**: Acceptance criteria are specific and verifiable
3. **Sized**: Small enough to complete in 30-60 minutes
4. **Prioritized**: Lower number = higher priority

**Example of a good story:**
```json
{
  "id": "US-001",
  "title": "Add user authentication API endpoint",
  "description": "Create POST /api/auth/login endpoint that accepts username/password and returns JWT token",
  "acceptanceCriteria": [
    "Endpoint returns 200 on valid credentials",
    "Endpoint returns 401 on invalid credentials",
    "Response includes valid JWT token",
    "Unit tests for all cases"
  ],
  "priority": 10,
  "passes": false
}
```

## Usage

### Basic Execution

**Direct execution (foreground):**
```bash
# Use default agent (qwen) and 10 iterations
.claude/skills/ralph-loop/scripts/ralph.sh

# Specify agent and iterations
.claude/skills/ralph-loop/scripts/ralph.sh codex 50
```

**Via Claude Code skill (recommended):**
```bash
# Basic
skill: "ralph-loop"

# With tmux (recommended for long sessions)
skill: "ralph-loop", args: "--tmux --agent qwen --max-iterations 20"

# High-iteration production run
skill: "ralph-loop", args: "--tmux --agent codex --max-iterations 100"
```

### Tmux Integration

**Why use tmux?**
- Detached execution (Ralph runs in background)
- Long-running sessions (20+ iterations)
- Easy monitoring and interaction
- Survives terminal disconnections

**Starting with tmux:**
```bash
# Start Ralph in tmux
skill: "ralph-loop", args: "--tmux --agent qwen --max-iterations 50"

# Or manually
.claude/skills/ralph-loop/scripts/start-tmux.sh --agent qwen --max-iterations 50
```

**Monitoring Ralph in tmux:**
```bash
# Attach to tmux session
tmux attach-session -t <session-name>

# Switch to 'ralph' window
Prefix + w (then select 'ralph')
# OR
Prefix + :select-window -t ralph

# Detach from session
Prefix + d

# Kill Ralph window
tmux kill-window -t <session>:ralph
```

### Agent Selection

| Agent | Best For | Command Line |
|-------|----------|--------------|
| **qwen** | General development, balanced capability | `qwen -p --yolo` |
| **codex** | Complex refactoring, architecture work | `codex exec --dangerously-bypass-approvals-and-sandbox` |
| **gemini** | Alternative code synthesis | `gemini -p --yolo` |
| **opencode** | Simple tasks, lightweight | `opencode -p --yolo` |

### Checking Status

```bash
# Check Ralph status and progress
.claude/skills/ralph-loop/scripts/status.sh
```

**Output includes:**
- Project name and branch
- Total/Completed/Remaining stories
- Progress percentage
- List of remaining stories (by priority)
- Recent progress log entries
- Archive information

## Progress Tracking

### Progress File

**Location:** `.claude/skills/ralph-loop/scripts/progress.txt`

**Contents:**
```
# Ralph Progress Log
Started: 2026-01-26 10:00:00
---
## Codebase Patterns
- Example: Use `sql<number>` template for aggregations
- Example: Always use `IF NOT EXISTS` for migrations
## [2026-01-26 10:05:23] - Starting iteration 1 of 20
## [2026-01-26 10:15:47] - US-001
- Implemented user authentication endpoint
- Files: api/auth.ts, tests/auth.test.ts
- **Learnings for future iterations:**
  - Use bcrypt for password hashing
  - JWT secret is in environment variable
---
## [2026-01-26 10:16:02] - Starting iteration 2 of 20
...
```

**Sections:**
1. **Codebase Patterns**: Reusable patterns discovered (at top)
2. **Progress Log**: Chronological iteration history

### Monitoring Progress

**Real-time monitoring (tmux):**
```bash
# Attach to tmux session
tmux attach-session -t <session-name>

# Switch to ralph window
Prefix + w → select 'ralph'
```

**Status checks:**
```bash
# Quick status check
.claude/skills/ralph-loop/scripts/status.sh

# View progress file
tail -50 .claude/skills/ralph-loop/scripts/progress.txt

# Watch progress in real-time
tail -f .claude/skills/ralph-loop/scripts/progress.txt
```

### Completion Verification

Ralph only signals completion when **ALL** user stories have `passes: true`:

```bash
# Check completion status
jq '[.userStories[] | select(.passes == false)] | length' prd.json

# Output: 0 = complete, >0 = incomplete
```

## Archive Management

### Automatic Archiving

Ralph automatically archives previous runs when the branch changes:

**Trigger:** Branch name in `prd.json` differs from last run

**Archive Location:** `.claude/skills/ralph-loop/scripts/archive/[DATE]-[BRANCH]/`

**Archived Contents:**
- `prd.json` - PRD snapshot from that run
- `progress.txt` - Complete progress log

**Example Archive Structure:**
```
archive/
├── 2026-01-25-feature-auth/
│   ├── prd.json
│   └── progress.txt
├── 2026-01-26-bug-fix-login/
│   ├── prd.json
│   └── progress.txt
└── 2026-01-26-refactor-api/
    ├── prd.json
    └── progress.txt
```

### Manual Archive Management

**List archives:**
```bash
ls -l .claude/skills/ralph-loop/scripts/archive/
```

**View specific archive:**
```bash
cat .claude/skills/ralph-loop/scripts/archive/2026-01-26-feature-auth/progress.txt
```

**Clean old archives:**
```bash
# Remove archives older than 30 days
find .claude/skills/ralph-loop/scripts/archive/ -type d -mtime +30 -exec rm -rf {} \;
```

## Best Practices

### PRD Preparation

1. **Start Small**: Begin with 5-10 well-defined stories
2. **Prioritize Wisely**: Use priority (1, 10, 20) to guide Ralph
3. **Testable Criteria**: Make acceptance criteria specific and verifiable
4. **Independent Stories**: Each story should be completable in one iteration
5. **Clear Descriptions**: Provide context about what and why

### Running Ralph

1. **Test First**: Run with 5-10 iterations to validate setup
2. **Use Tmux**: For long-running sessions (20+ iterations)
3. **Monitor Progress**: Check `progress.txt` regularly
4. **Agent Selection**: Match agent to task complexity
5. **Quality Gates**: Ralph won't commit failing tests

### Quality Assurance

**Ralph enforces TDD:**
1. Write tests FIRST (Red)
2. Implement feature (Green)
3. Refactor code (keep green)
4. All tests must pass before commit

**Quality checks:**
- Unit tests pass
- Integration tests pass
- Code coverage maintained or improved
- Typecheck/lint checks pass

### Troubleshooting

**"Missing prd.json":**
- Ralph auto-creates from `prd_example.json`
- Edit `prd.json` to customize your project

**"Agent not found":**
- Install selected agent CLI
- Check `--agent` parameter matches installed tool

**"Tmux session not found":**
- Start tmux: `tmux new-session -s <name>`
- Or run without `--tmux` flag

**"Branch mismatch":**
- Ralph checks out/creates branch from PRD
- Verify `branchName` in `prd.json`

**Iteration limit reached:**
- Check `progress.txt` for status
- Increase `--max-iterations`
- Stories may be blocked or poorly defined

**Tests failing:**
- Ralph will NOT commit failing tests
- Check `progress.txt` for error details
- Fix acceptance criteria or implementation

### Workflow Tips

1. **One Branch Per Session**: Each Ralph session should have its own branch
2. **Review Progress**: Check `progress.txt` after each iteration
3. **Learn from Patterns**: Review "Codebase Patterns" section regularly
4. **Archive Knowledge**: Archives contain valuable learnings
5. **Iterative Approach**: Start small, scale up based on success

## Advanced Usage

### Custom Completion Promise

Ralph looks for `<promise>COMPLETE</promise>` by default. You can customize this:

```bash
skill: "ralph-loop", args: "--completion-promise DONE"
```

**Note:** This requires modifying the prompt.md file to use your custom promise.

### Environment Variables

Ralph respects these environment variables:

```bash
# Z AI credentials (auto-extracted from ~/.sh/providers.yaml)
export ANTHROPIC_AUTH_TOKEN="your-token"
export ANTHROPIC_BASE_URL="your-base-url"

# Custom agent paths
export PATH="/path/to/agents:$PATH"
```

### Integration with CI/CD

```bash
# Run Ralph in CI pipeline
- name: Run Ralph
  run: |
    .claude/skills/ralph-loop/scripts/ralph.sh qwen 50

# Check completion
- name: Verify Completion
  run: |
    INCOMPLETE=$(jq '[.userStories[] | select(.passes == false)] | length' prd.json)
    if [ "$INCOMPLETE" -gt 0 ]; then
      echo "Ralph did not complete all stories"
      exit 1
    fi
```

## Support and Documentation

- **Main Skill Definition**: `.claude/skills/ralph-loop/SKILL.md`
- **Agent Instructions**: `.claude/skills/ralph-loop/scripts/prompt.md`
- **PRD Template**: `.claude/skills/ralph-loop/scripts/prd_example.json`
- **Status Checker**: `.claude/skills/ralph-loop/scripts/status.sh`

---

**Happy autonomous coding with Ralph! 🤖**
