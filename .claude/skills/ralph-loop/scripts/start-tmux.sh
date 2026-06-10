#!/bin/bash
# Start Ralph in a new tmux window
# Usage: ./start-tmux.sh --agent [agent] --max-iterations [n]

set -e

AGENT="qwen"
MAX_ITERATIONS=10
WINDOW_NAME="ralph"

###############################################################################
# PARSE ARGUMENTS
###############################################################################

while [[ $# -gt 0 ]]; do
  case $1 in
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
      echo "Usage: $0 --agent [qwen|codex|gemini|opencode] --max-iterations [n]"
      exit 1
      ;;
  esac
done

###############################################################################
# DETECT TMUX SESSION
###############################################################################

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
  echo "Error: tmux is not installed"
  echo "Install tmux or run without --tmux flag"
  exit 1
fi

# Detect current tmux session or find an available one
CURRENT_SESSION=""
if [ -n "$TMUX" ]; then
  # We're inside tmux
  CURRENT_SESSION=$(tmux display-message -p '#S')
else
  # We're outside tmux, find or list sessions
  SESSION_COUNT=$(tmux ls 2>/dev/null | wc -l)

  if [ "$SESSION_COUNT" -eq 0 ]; then
    echo "Error: No tmux sessions found"
    echo "Create one first with: tmux new-session -s <name>"
    exit 1
  elif [ "$SESSION_COUNT" -eq 1 ]; then
    # Only one session, use it
    CURRENT_SESSION=$(tmux ls -F "#{session_name}" 2>/dev/null | head -1)
  else
    # Multiple sessions, try to pick the most recent
    CURRENT_SESSION=$(tmux ls -F "#{session_name} #{session_last_attached}" 2>/dev/null | sort -k2 -r | head -1 | cut -d' ' -f1)
    echo "Warning: Multiple tmux sessions detected"
    echo "Using most recent session: $CURRENT_SESSION"
    echo ""
    echo "All sessions:"
    tmux ls -F "  - #{session_name}" 2>/dev/null
    echo ""
    read -p "Press Enter to use $CURRENT_SESSION, or Ctrl+C to cancel..."
  fi
fi

###############################################################################
# VALIDATE SESSION
###############################################################################

if ! tmux has-session -t "$CURRENT_SESSION" 2>/dev/null; then
  echo "Error: Tmux session '$CURRENT_SESSION' does not exist"
  exit 1
fi

###############################################################################
# PREPARE WINDOW
###############################################################################

# Check if window already exists
if tmux list-windows -t "$CURRENT_SESSION" -F "#{window_name}" | grep -q "^$WINDOW_NAME$"; then
  echo "Warning: Window '$WINDOW_NAME' already exists in session '$CURRENT_SESSION'"
  echo "Killing existing window..."
  tmux kill-window -t "$CURRENT_SESSION:$WINDOW_NAME" 2>/dev/null || true
  sleep 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# START RALPH
###############################################################################

echo ""
echo "=== Starting Ralph in Tmux ==="
echo ""
echo "Configuration:"
echo "  Session: $CURRENT_SESSION"
echo "  Window: $WINDOW_NAME"
echo "  Agent: $AGENT"
echo "  Max iterations: $MAX_ITERATIONS"
echo ""

# Create new window
tmux new-window -t "$CURRENT_SESSION" -n "$WINDOW_NAME" -c "$PWD"

# Send the command to run Ralph
tmux send-keys -t "$CURRENT_SESSION:$WINDOW_NAME" "$SCRIPT_DIR/ralph.sh $AGENT $MAX_ITERATIONS" C-m

###############################################################################
# DISPLAY USAGE INFO
###############################################################################

echo "Status: Ralph is now running"
echo ""
echo "To interact with Ralph:"
if [ -n "$TMUX" ]; then
  echo "  Switch to window:     Prefix + w (then select $WINDOW_NAME)"
  echo "  Select directly:      Prefix + :select-window -t $WINDOW_NAME"
else
  echo "  Attach to session:    tmux attach-session -t $CURRENT_SESSION"
  echo "  Switch to window:     Prefix + w (then select $WINDOW_NAME)"
  echo "  Select directly:      Prefix + :select-window -t $WINDOW_NAME"
fi
echo ""
echo "To stop Ralph:"
echo "  Kill the window:      tmux kill-window -t $CURRENT_SESSION:$WINDOW_NAME"
echo "  Or press:             Ctrl+C in the Ralph window"
echo ""
