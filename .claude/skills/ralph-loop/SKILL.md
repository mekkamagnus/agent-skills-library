---
name: ralph-loop
description: |
  Autonomous TDD agent loop for PRD implementation. Supports multi-agent execution (claude-glm, qwen, codex, gemini, opencode) with tmux integration, progress tracking, and performance benchmarking tools.
  Triggers: ralph, loop, autonomous, benchmark, variance, anomaly detection, agent comparison
---

# Ralph Loop Skill

## Quick Start

**Basic execution (runs in tmux window by default):**
```
skill: "ralph-loop"
```

**Run in current terminal (no tmux):**
```
skill: "ralph-loop", args: "--no-tmux"
```

**High-iteration production run:**
```
skill: "ralph-loop", args: "--agent codex --max-iterations 100"
```

## Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `--no-tmux` | Run in current terminal instead of tmux | false | flag |
| `--agent` | AI agent to use | claude-glm | claude-glm, claude, qwen, codex, gemini, opencode |
| `--max-iterations` | Maximum Ralph iterations | 10 | integer |
| `--help` | Show usage information | - | flag |

**Note:** tmux window creation is now the default behavior. Use `--no-tmux` to run directly in the current terminal.

## Agent Selection

**qwen** (default)
- Balanced capability with good code generation
- Use for general-purpose development
- Requires: `qwen` CLI installed

**codex**
- Best for complex refactoring and architecture
- Requires: `codex` CLI installed
- Uses `exec` subcommand with bypass flag

**gemini**
- Alternative for code synthesis
- Requires: `gemini` CLI installed

**opencode**
- Lightweight option for simple tasks
- Requires: `opencode` CLI installed

## Tmux Integration

**Default behavior:**
- Automatically runs in a dedicated tmux window named 'ralph'
- Creates window in active tmux session
- Isolates Ralph from your current terminal

**If not in tmux:**
- Script exits with instructions to start tmux first
- Use: `tmux new-session -s ralph` then run ralph-loop

**Run without tmux:**
- Use `--no-tmux` flag to run directly in current terminal

**Manual tmux commands:**
```bash
# Attach to tmux session
tmux attach-session -t <session-name>

# Switch to ralph window
Prefix + w (then select 'ralph')

# Kill Ralph window
tmux kill-window -t <session>:ralph
```

## Prerequisites

**Required files:**
- `prd.json` in project root (auto-created from example if missing)

**Required tools:**
- `jq` - JSON parsing
- Selected agent CLI (qwen/codex/gemini/opencode)
- Git branch configured in PRD

**PRD structure:**
```json
{
  "projectName": "your-project",
  "branchName": "ralph/001-feature-name",
  "userStories": [
    {
      "id": "US-001",
      "title": "Feature title",
      "description": "What needs to be done",
      "acceptanceCriteria": ["testable condition 1"],
      "priority": 10,
      "passes": false,
      "notes": "Optional context"
    }
  ]
}
```

## Monitoring

**Progress tracking:**
- Real-time progress: `.claude/skills/ralph-loop/scripts/progress.txt`
- Color-coded log output (info, success, warning, error)
- Iteration timestamps and duration tracking

**Status checking:**
```bash
.claude/skills/ralph-loop/scripts/status.sh
```

**Log files:**
- Main loop: Color-coded console output
- Progress file: Detailed iteration history
- Archive: Previous runs auto-archived by branch

## Benchmark Analysis

**Performance benchmarks:**
```bash
# Basic analysis (last 30 days)
.claude/skills/ralph-loop/scripts/benchmark-analysis.sh

# Filter by agent
.claude/skills/ralph-loop/scripts/benchmark-analysis.sh --agent claude-glm

# Custom period
.claude/skills/ralph-loop/scripts/benchmark-analysis.sh --period 60

# JSON output for scripting
.claude/skills/ralph-loop/scripts/benchmark-analysis.sh --json
```

**Benchmark metrics include:**
- Run statistics (total, completed, incomplete, success rate)
- Duration metrics (avg, max, min, stddev, variance)
- Iteration metrics (avg, max, min, stddev, variance)
- Productivity metrics (stories/run, stories/iter, iter duration)
- Expected benchmarks (avg + 1σ thresholds)
- Agent breakdown

## Variance Analysis

**Compare agents:**
```bash
# Compare two agents
.claude/skills/ralph-loop/scripts/variance-analysis.sh --compare claude-glm,qwen
```

**Trend analysis:**
```bash
# Show monthly trends
.claude/skills/ralph-loop/scripts/variance-analysis.sh --trend --period 90
```

**Anomaly detection:**
```bash
# Find runs outside 2σ threshold
.claude/skills/ralph-loop/scripts/variance-analysis.sh --anomalies
```

**Combined analysis (JSON):**
```bash
.claude/skills/ralph-loop/scripts/variance-analysis.sh --trend --anomalies --json
```

**Variance metrics:**
- Agent comparison (count, success rate, avg duration)
- Monthly trends (runs, completed, avg duration)
- Anomaly detection (high/low duration outliers with 2σ thresholds)

## How Ralph Works

1. **Read PRD** - Loads user stories from `prd.json`
2. **Select Story** - Picks highest priority story with `passes: false`
3. **TDD Approach** - Writes tests FIRST (Red → Green → Refactor)
4. **Implement** - Codes feature to make tests pass
5. **Validate** - Runs all tests, quality checks
6. **Commit** - Commits with `feat: [ID] - [Title]`
7. **Update** - Sets story `passes: true` in PRD
8. **Repeat** - Until all stories have `passes: true`
9. **Complete** - Outputs `<promise>COMPLETE</promise>`

## TDD Workflow

**Ralph mandates TDD:**
1. Write test FIRST (fails - Red)
2. Implement feature (passes - Green)
3. Refactor code (keep green)
4. Add edge case tests
5. Ensure all tests pass before commit

**Quality gates:**
- All tests MUST pass
- New functionality MUST be tested
- Coverage maintained or improved
- Typecheck/lint checks pass

## Troubleshooting

**"Missing prd.json":**
- Skill auto-creates from `prd_example.json`
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

## Archive Management

Previous runs auto-archive when branch changes:
- Location: `scripts/archive/[DATE]-[BRANCH]/`
- Contains: PRD snapshot, progress log
- Preserves: History across branch switches

## Best Practices

1. **Start small** - Test with 5-10 iterations first
2. **Use tmux** - For long-running sessions (20+ iterations)
3. **Monitor progress** - Check `progress.txt` regularly
4. **Validate PRD** - Ensure stories are independent and testable
5. **Quality gates** - Ralph won't commit failing tests
6. **Branch hygiene** - One Ralph session per branch
7. **Archive review** - Learn from previous runs
