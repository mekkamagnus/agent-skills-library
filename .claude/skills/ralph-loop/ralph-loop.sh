#!/bin/bash
# Ralph Loop Skill - Entry Point
# Usage: skill: "ralph-loop", args: "[--tmux] [--agent claude-glm] [--max-iterations N]"

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
USE_TMUX=false
AGENT="claude-glm"
MAX_ITERATIONS=10

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --tmux)
      USE_TMUX=true
      shift
      ;;
    --agent)
      AGENT="$2"
      shift 2
      ;;
    --max-iterations)
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--tmux] [--agent claude-glm|claude|qwen|codex|gemini|opencode] [--max-iterations N]"
      exit 1
      ;;
  esac
done

# Execute Ralph
if [ "$USE_TMUX" = true ]; then
  exec "$SCRIPT_DIR/scripts/start-tmux.sh" --agent "$AGENT" --max-iterations "$MAX_ITERATIONS"
else
  exec "$SCRIPT_DIR/scripts/ralph.sh" "$AGENT" "$MAX_ITERATIONS"
fi
