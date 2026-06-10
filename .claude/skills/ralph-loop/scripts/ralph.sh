#!/bin/bash
# Ralph Wiggum - Long-running AI agent loop
# Usage: ./ralph.sh [agent] [max_iterations] [--no-tmux]
# Agents: claude-glm (default, Z.ai), claude (Anthropic), qwen, codex, opencode, gemini
# Default: Runs in a tmux window (use --no-tmux to run in current terminal)

set -e

# Default values
AGENT="claude-glm"
MAX_ITERATIONS=10
NO_TMUX=false
WINDOW_NAME="ralph"

# Parse arguments (support both positional and flags)
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-tmux)
      NO_TMUX=true
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
    --help)
      echo "Usage: $0 [agent] [max_iterations] [--no-tmux]"
      echo ""
      echo "Arguments:"
      echo "  agent            AI agent to use (default: claude-glm)"
      echo "  max_iterations   Maximum iterations (default: 10)"
      echo ""
      echo "Flags:"
      echo "  --no-tmux        Run in current terminal instead of tmux window"
      echo "  --help           Show this help"
      echo ""
      echo "Agents: claude-glm, claude, qwen, codex, opencode, gemini"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
    *)
      # Positional argument - use a counter to track position
      if [[ -z "$POSITIONAL_INDEX" ]]; then
        POSITIONAL_INDEX=0
      fi
      POSITIONAL_INDEX=$((POSITIONAL_INDEX + 1))

      if [[ $POSITIONAL_INDEX -eq 1 ]]; then
        AGENT="$1"
      elif [[ $POSITIONAL_INDEX -eq 2 ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

# Capture the ACTUAL project root from where the script was invoked
# This is the directory where the user ran ralph-loop from
RALPH_PROJECT_ROOT="${RALPH_PROJECT_ROOT:-$PWD}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$RALPH_PROJECT_ROOT"
PRD_FILE="$PROJECT_ROOT/prd.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"
PRD_EXAMPLE="$SCRIPT_DIR/prd_example.json"

###############################################################################
# LOGGING FUNCTIONS
###############################################################################

# Check if terminal supports colors
if [ -t 1 ] && [ "$(tput colors 2>/dev/null)" -ge 8 ]; then
  USE_COLORS=true
else
  USE_COLORS=false
fi

# Color codes using tput
if [ "$USE_COLORS" = true ]; then
  COLOR_BLUE=$(tput setaf 4)
  COLOR_GREEN=$(tput setaf 2)
  COLOR_YELLOW=$(tput setaf 3)
  COLOR_RED=$(tput setaf 1)
  COLOR_CYAN=$(tput setaf 6)
  COLOR_MAGENTA=$(tput setaf 5)
  COLOR_RESET=$(tput sgr0)
else
  COLOR_BLUE=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_CYAN=""
  COLOR_MAGENTA=""
  COLOR_RESET=""
fi

# Get formatted timestamp
timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

# Log info message (blue)
log_info() {
  echo "${COLOR_BLUE}[INFO] [$(timestamp)]${COLOR_RESET} $1"
}

# Log success message (green)
log_success() {
  echo "${COLOR_GREEN}[SUCCESS] [$(timestamp)]${COLOR_RESET} $1"
}

# Log warning message (yellow)
log_warning() {
  echo "${COLOR_YELLOW}[WARNING] [$(timestamp)]${COLOR_RESET} $1"
}

# Log error message (red)
log_error() {
  echo "${COLOR_RED}[ERROR] [$(timestamp)]${COLOR_RESET} $1" >&2
}

# Log iteration start (cyan with borders)
log_iteration_start() {
  local iteration=$1
  local total=$2
  echo ""
  echo "${COLOR_CYAN}═══════════════════════════════════════════════════════${COLOR_RESET}"
  echo "${COLOR_CYAN}=== Iteration ${iteration} of ${total} ===${COLOR_RESET}"
  echo "${COLOR_CYAN}═══════════════════════════════════════════════════════${COLOR_RESET}"
  echo ""
}

# Log section header (magenta)
log_section() {
  echo ""
  echo "${COLOR_MAGENTA}--- $1 ---${COLOR_RESET}"
}

# Log to progress file with timestamp
log_to_progress() {
  local message="$1"
  echo "## [$(timestamp)] - $message" >> "$PROGRESS_FILE"
}

###############################################################################
# TMUX WINDOW MANAGEMENT
###############################################################################

# Setup tmux window for Ralph execution
# Creates a 'ralph' window in the active tmux session and re-executes there
setup_tmux_window() {
  # Skip if --no-tmux flag is set
  if [ "$NO_TMUX" = true ]; then
    log_info "Running in current terminal (--no-tmux specified)"
    return 0
  fi

  # Check if tmux is installed
  if ! command -v tmux &> /dev/null; then
    log_warning "tmux is not installed. Running in current terminal."
    log_warning "Install tmux for better isolation: brew install tmux"
    return 0
  fi

  # Check if already running inside the ralph window (prevent infinite loop)
  if [ -n "$RALPH_WINDOW" ]; then
    log_info "Already running in ralph tmux window"
    return 0
  fi

  local session_name=""
  local window_target=""

  # Detect current tmux session
  if [ -n "$TMUX" ]; then
    # We're inside tmux - get current session
    session_name=$(tmux display-message -p '#{session_name}')
    log_info "Detected active tmux session: $session_name"
  else
    # Not in tmux - find existing sessions
    local sessions
    sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null || true)

    if [ -z "$sessions" ]; then
      log_error "No tmux session found"
      log_error "Please start tmux first: tmux new-session -s ralph"
      log_error "Or use --no-tmux to run in current terminal"
      exit 1
    fi

    # Use most recent session if multiple exist
    if [ "$(echo "$sessions" | wc -l | tr -d ' ')" -gt 1 ]; then
      session_name=$(tmux list-sessions -F '#{session_name} #{session_last_attached}' 2>/dev/null | sort -k2 -rn | head -1 | cut -d' ' -f1)
      log_info "Multiple sessions found. Using most recent: $session_name"
    else
      session_name=$(echo "$sessions" | head -1)
      log_info "Found tmux session: $session_name"
    fi
  fi

  # Validate session exists
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    log_error "Tmux session '$session_name' does not exist"
    exit 1
  fi

  window_target="${session_name}:${WINDOW_NAME}"

  # Check if window already exists and kill it
  if tmux list-windows -t "$session_name" -F '#{window_name}' 2>/dev/null | grep -q "^${WINDOW_NAME}$"; then
    log_warning "Killing existing ralph window..."
    tmux kill-window -t "$window_target" 2>/dev/null || true
    sleep 1
  fi

  # Create new window
  log_info "Creating tmux window: $window_target"
  tmux new-window -t "$session_name" -n "$WINDOW_NAME" -c "$PROJECT_ROOT" 2>/dev/null

  if [ $? -ne 0 ]; then
    log_error "Failed to create tmux window"
    exit 1
  fi

  log_success "Created tmux window: $WINDOW_NAME"

  # Build the command to run Ralph in the new window
  # Source shell profile to ensure PATH includes ~/.local/bin etc.
  local profile_source=""
  if [ -f "$HOME/.zshrc" ]; then
    profile_source="source '$HOME/.zshrc' 2>/dev/null || true && "
  elif [ -f "$HOME/.bashrc" ]; then
    profile_source="source '$HOME/.bashrc' 2>/dev/null || true && "
  fi

  local ralph_cmd="${profile_source}cd '$RALPH_PROJECT_ROOT' && RALPH_PROJECT_ROOT='$RALPH_PROJECT_ROOT' RALPH_WINDOW=1 '$SCRIPT_DIR/ralph.sh' --no-tmux --agent '$AGENT' --max-iterations '$MAX_ITERATIONS'"

  # Send command to the window
  tmux send-keys -t "$window_target" "$ralph_cmd" C-m

  log_success "Ralph started in tmux window: $window_target"
  echo ""
  echo "To interact with Ralph:"
  if [ -n "$TMUX" ]; then
    echo "  Switch to window:     Prefix + w (then select $WINDOW_NAME)"
    echo "  Select directly:      tmux select-window -t $window_target"
  else
    echo "  Attach to session:    tmux attach-session -t $session_name"
    echo "  Switch to window:     Prefix + w (then select $WINDOW_NAME)"
  fi
  echo ""
  echo "To stop Ralph:"
  echo "  Kill the window:      tmux kill-window -t $window_target"
  echo "  Or press:             Ctrl+C in the Ralph window"
  echo ""

  # Exit the parent process - Ralph is now running in the tmux window
  exit 0
}

###############################################################################
# NOTIFICATION FUNCTION
###############################################################################

notify_completion() {
  # TMUX notification (if running in tmux)
  if [ -n "${TMUX:-}" ]; then
    tmux display-message -p 0 "✅ Ralph Loop Complete!"
  fi

  # Desktop notification (macOS)
  if command -v osascript &> /dev/null; then
    osascript -e 'display notification "Ralph Loop" with title "✅ Complete"' 2>/dev/null || true
  fi
}

###############################################################################
# PRD FILE HANDLING
###############################################################################

ensure_prd_exists() {
  if [ ! -f "$PRD_FILE" ]; then
    log_warning "PRD file not found: $PRD_FILE"

    if [ ! -f "$PRD_EXAMPLE" ]; then
      log_error "PRD example template not found: $PRD_EXAMPLE"
      log_error "Cannot create default PRD. Please create prd.json manually."
      exit 1
    fi

    log_info "Creating PRD from example template..."
    cp "$PRD_EXAMPLE" "$PRD_FILE"
    log_success "Created prd.json from example template"
    log_warning "Please edit prd.json to customize your project before running Ralph again"
    exit 0
  fi
}

###############################################################################
# ENVIRONMENT VALIDATION
###############################################################################

validate_environment() {
  local missing_tools=()
  local missing_files=()

  # Ensure PRD exists
  ensure_prd_exists

  # Check required tools
  if ! command -v jq &> /dev/null; then
    missing_tools+=("jq")
  fi

  # Map agent names to their actual CLI commands
  # claude-glm and claude both use the 'claude' CLI
  case "$AGENT" in
    claude-glm|claude)
      AGENT_CMD="claude"
      ;;
    codex)
      AGENT_CMD="codex"
      ;;
    opencode)
      AGENT_CMD="opencode"
      ;;
    gemini)
      AGENT_CMD="gemini"
      ;;
    qwen|*)
      AGENT_CMD="qwen"
      ;;
  esac

  # Check for the selected agent command
  if ! command -v "$AGENT_CMD" &> /dev/null; then
    missing_tools+=("$AGENT_CMD")
  fi

  # Check required files
  if [ ! -f "$PRD_FILE" ]; then
    missing_files+=("$PRD_FILE")
  fi

  # Report errors
  if [ ${#missing_tools[@]} -gt 0 ] || [ ${#missing_files[@]} -gt 0 ]; then
    log_error "Environment validation failed"

    if [ ${#missing_tools[@]} -gt 0 ]; then
      log_error "Missing required tools: ${missing_tools[*]}"
    fi

    if [ ${#missing_files[@]} -gt 0 ]; then
      log_error "Missing required files: ${missing_files[*]}"
    fi

    exit 1
  fi
}

###############################################################################
# LOAD CREDENTIALS FROM .ENV FILE
###############################################################################

# Load credentials from .env file
ENV_FILE="$SCRIPT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
  # Source the .env file (ensure variables are exported)
  set -a  # Automatically export all variables
  source "$ENV_FILE"
  set +a  # Stop automatically exporting

  # Select credentials based on agent
  case "$AGENT" in
    claude-glm)
      export ANTHROPIC_AUTH_TOKEN="$CLAUDE_GLM_AUTH_TOKEN"
      export ANTHROPIC_BASE_URL="$CLAUDE_GLM_BASE_URL"
      ;;
    claude)
      export ANTHROPIC_AUTH_TOKEN="$CLAUDE_AUTH_TOKEN"
      export ANTHROPIC_BASE_URL="$CLAUDE_BASE_URL"
      ;;
  esac
else
  log_warning "Credentials file not found: $ENV_FILE"
  log_warning "Please create .env file from .env.example template"
  exit 1
fi

###############################################################################
# VALIDATE ENVIRONMENT
###############################################################################

validate_environment

###############################################################################
# SETUP TMUX WINDOW (Default behavior)
###############################################################################

# Setup tmux window for isolated execution (unless --no-tmux is set)
setup_tmux_window

###############################################################################
# ARCHIVE PREVIOUS RUN IF BRANCH CHANGED
###############################################################################

if [ -f "$PRD_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    log_section "Archiving Previous Run"

    DATE=$(date +%Y-%m-%d)
    # Strip "ralph/" prefix from branch name for folder
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    log_info "Branch changed from '$LAST_BRANCH' to '$CURRENT_BRANCH'"
    log_info "Creating archive folder: $ARCHIVE_FOLDER"
    mkdir -p "$ARCHIVE_FOLDER"

    if [ -f "$PRD_FILE" ]; then
      log_info "Copying PRD file to archive"
      cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    fi

    if [ -f "$PROGRESS_FILE" ]; then
      log_info "Copying progress file to archive"
      cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    fi

    log_success "Archived previous run to: $ARCHIVE_FOLDER"
    log_to_progress "Archived previous run ($LAST_BRANCH) to $ARCHIVE_FOLDER"

    # Reset progress file for new run
    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

###############################################################################
# TRACK CURRENT BRANCH
###############################################################################

log_section "Initializing Ralph"

if [ -f "$PRD_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
    log_info "Current branch: $CURRENT_BRANCH"
  fi
fi

###############################################################################
# INITIALIZE RUN TRACKING
###############################################################################

# Generate run ID based on timestamp
RUN_TIMESTAMP=$(date '+%Y-%m-%d_%H%M%S')
RUN_ID="${RUN_TIMESTAMP}_${AGENT}_session"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
RUN_DIR="$PROJECT_ROOT/ralph-runs/$RUN_ID"

# Create run directory
mkdir -p "$RUN_DIR"
log_info "Run ID: $RUN_ID"
log_info "Artifacts will be saved to: $RUN_DIR"

# Record start time
RUN_START=$(date +%s)
export RUN_ID
export RUN_START
export START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
export AGENT
export API_ENDPOINT="${ANTHROPIC_BASE_URL:-unknown}"

###############################################################################
# INITIALIZE PROGRESS FILE
###############################################################################

if [ ! -f "$PROGRESS_FILE" ]; then
  log_info "Creating progress file: $PROGRESS_FILE"
  echo "# Ralph Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
else
  log_info "Using existing progress file: $PROGRESS_FILE"
fi

log_success "Initialization complete"

###############################################################################
# MAIN RALPH LOOP
###############################################################################

log_info "Starting Ralph - Agent: $AGENT - Max iterations: $MAX_ITERATIONS"
log_to_progress "Starting Ralph (agent: $AGENT, max iterations: $MAX_ITERATIONS)"

for i in $(seq 1 $MAX_ITERATIONS); do
  # Track iteration start time
  ITERATION_START=$(date +%s)

  log_iteration_start "$i" "$MAX_ITERATIONS"
  log_to_progress "Starting iteration $i of $MAX_ITERATIONS"

  # Run AI agent with the ralph prompt (non-interactive mode)
  # Save output to temp file for completion check
  TEMP_OUTPUT=$(mktemp)

  # Different agents have different command syntax
  case "$AGENT" in
    claude-glm)
      # Claude with Z.ai credentials (default)
      cd "$PROJECT_ROOT" && cat "$SCRIPT_DIR/prompt.md" | claude -p --dangerously-skip-permissions --allowed-tools "Read,Write,Edit,Glob,Grep,AskUserQuestion,Bash,TodoWrite" 2>&1 | tee "$TEMP_OUTPUT"
      ;;
    claude)
      # Claude with official Anthropic credentials
      cd "$PROJECT_ROOT" && cat "$SCRIPT_DIR/prompt.md" | claude -p --dangerously-skip-permissions --allowed-tools "Read,Write,Edit,Glob,Grep,AskUserQuestion,Bash,TodoWrite" 2>&1 | tee "$TEMP_OUTPUT"
      ;;
    codex)
      # Codex uses 'exec' subcommand with bypass flag to avoid sandbox git restrictions
      cd "$PROJECT_ROOT" && cat "$SCRIPT_DIR/prompt.md" | codex exec --dangerously-bypass-approvals-and-sandbox 2>&1 | tee "$TEMP_OUTPUT"
      ;;
    opencode)
      # OpenCode might need different syntax
      cd "$PROJECT_ROOT" && cat "$SCRIPT_DIR/prompt.md" | opencode -p --yolo 2>&1 | tee "$TEMP_OUTPUT"
      ;;
    gemini)
      # Gemini uses --yolo flag and accepts prompt via stdin
      # --allowed-tools specifies which tools can auto-approve
      cd "$PROJECT_ROOT" && cat "$SCRIPT_DIR/prompt.md" | gemini --yolo --allowed-tools Read,Write,Edit,Glob,Grep,AskUserQuestion,Bash,TodoWrite 2>&1 | tee "$TEMP_OUTPUT"
      ;;
    qwen|*)
      # Qwen is the default
      cd "$PROJECT_ROOT" && cat "$SCRIPT_DIR/prompt.md" | qwen -p --yolo --allowed-tools "Read,Write,Edit,Glob,Grep,AskUserQuestion,Bash,TodoWrite" 2>&1 | tee "$TEMP_OUTPUT"
      ;;
  esac

  # Calculate iteration duration
  ITERATION_END=$(date +%s)
  ITERATION_DURATION=$((ITERATION_END - ITERATION_START))

  # Check for completion signal
  if grep -q "<promise>COMPLETE</promise>" "$TEMP_OUTPUT"; then
    echo ""
    log_info "Agent signaled completion. Verifying all user stories are complete..."

    # Verify ALL user stories have passes: true
    INCOMPLETE_STORIES=$(jq '[.userStories[] | select(.passes == false)] | length' "$PRD_FILE" 2>/dev/null || echo "0")

    if [ "$INCOMPLETE_STORIES" -eq "0" ]; then
      # All stories are complete - safe to exit
      log_success "Verification passed: All user stories have passes: true"
      log_success "Ralph completed all tasks!"
      log_success "Completed at iteration $i of $MAX_ITERATIONS"
      log_to_progress "Completed all tasks at iteration $i of $MAX_ITERATIONS (duration: ${ITERATION_DURATION}s)"
      rm -f "$TEMP_OUTPUT"

      # Archive artifacts and notify
      log_section "Archiving Artifacts"
      RUN_END=$(date +%s)
      DURATION_SECONDS=$((RUN_END - RUN_START))
      export END_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      export DURATION_SECONDS
      export ITERATIONS_COMPLETED="$i"
      export ITERATIONS_TARGET="$MAX_ITERATIONS"
      export STATUS="COMPLETE"

      # Get stories count from PRD
      TOTAL_STORIES=$(jq '.userStories | length' "$PRD_FILE" 2>/dev/null || echo "0")
      export STORIES_COMPLETED="$TOTAL_STORIES"
      export STORIES_STARTED="$TOTAL_STORIES"
      export ITERATIONS_TARGET="$MAX_ITERATIONS"

      # Calculate performance metrics
      export AVG_ITERATION_DURATION=$((DURATION_SECONDS / i))
      export AVG_STORIES_PER_ITERATION=$(awk "BEGIN {printf \"%.2f\", $TOTAL_STORIES/$i}")
      export TESTS_PASSING=$(bun test 2>&1 | grep -o '[0-9]* pass' | awk '{print $1}' || echo "0")
      export TESTS_FAILING="0"
      export ISSUES_JSON='[]'
      export RUN_NOTES="Completed all $TOTAL_STORIES stories in $i iterations"

      # Run archival script
      bash "$SCRIPT_DIR/create-run-artifacts.sh"

      # Send notifications
      notify_completion

      exit 0
    else
      # Agent signaled complete but stories are still incomplete - continue
      log_warning "Agent signaled completion but $INCOMPLETE_STORIES stories still have passes: false"
      log_warning "Ignoring premature completion signal and continuing..."
      log_to_progress "WARNING: Ignored premature completion signal at iteration $i ($INCOMPLETE_STORIES stories remaining)"
    fi
  fi

  rm -f "$TEMP_OUTPUT"

  # Log iteration completion
  if [ $i -lt $MAX_ITERATIONS ]; then
    log_info "Iteration $i complete (duration: ${ITERATION_DURATION}s). Continuing..."
    log_to_progress "Iteration $i complete (duration: ${ITERATION_DURATION}s)"
    echo ""
    sleep 2
  fi
done

echo ""
log_error "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks"
log_info "Check $PROGRESS_FILE for status"
log_to_progress "Reached max iterations ($MAX_ITERATIONS) without completing"

# Archive artifacts even though incomplete
log_section "Archiving Artifacts"
RUN_END=$(date +%s)
DURATION_SECONDS=$((RUN_END - RUN_START))
export END_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
export DURATION_SECONDS
export ITERATIONS_COMPLETED="$MAX_ITERATIONS"
export ITERATIONS_TARGET="$MAX_ITERATIONS"
export STATUS="INCOMPLETE"

# Get stories count from PRD
TOTAL_STORIES=$(jq '.userStories | length' "$PRD_FILE" 2>/dev/null || echo "0")
COMPLETED_STORIES=$(jq '[.userStories[] | select(.passes == true)] | length' "$PRD_FILE" 2>/dev/null || echo "0")
export STORIES_COMPLETED="$COMPLETED_STORIES"
export STORIES_STARTED="$TOTAL_STORIES"
export ITERATIONS_TARGET="$MAX_ITERATIONS"

# Calculate performance metrics
export AVG_ITERATION_DURATION=$((DURATION_SECONDS / MAX_ITERATIONS))
export AVG_STORIES_PER_ITERATION=$(awk "BEGIN {printf \"%.2f\", $COMPLETED_STORIES/$MAX_ITERATIONS}")
export TESTS_PASSING=$(bun test 2>&1 | grep -o '[0-9]* pass' | awk '{print $1}' || echo "0")
export TESTS_FAILING="0"
export ISSUES_JSON='[{"type": "max_iterations_reached", "count": 1, "description": "Reached max iterations without completing all stories"}]'
export RUN_NOTES="Completed $COMPLETED_STORIES of $TOTAL_STORIES stories in $MAX_ITERATIONS iterations"

# Run archival script
bash "$SCRIPT_DIR/create-run-artifacts.sh"

# Send notifications
notify_completion

exit 1
