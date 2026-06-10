#!/bin/bash
# Ralph Loop Artifact Archival Script
# Called at end of Ralph Loop run to archive artifacts

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run metadata (should be set by ralph.sh)
RUN_ID="${RUN_ID:-$(date '+%Y-%m-%d_%H%M%S')_unknown_session}"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
RUN_DIR="$PROJECT_ROOT/ralph-runs/$RUN_ID"

# Create run directory
mkdir -p "$RUN_DIR"

log_info() {
  echo "[RALPH ARCHIVE] $*" >&2
}

log_error() {
  echo "[RALPH ARCHIVE] ERROR: $*" >&2
}

# Archive artifacts
log_info "Archiving artifacts to $RUN_DIR"

# Copy summary if exists
if [[ -f "/tmp/ralph_summary.txt" ]]; then
  cp "/tmp/ralph_summary.txt" "$RUN_DIR/summary.txt"
  log_info "Archived summary.txt"
else
  log_error "Summary file not found: /tmp/ralph_summary.txt"
fi

# Copy full buffer if exists
if [[ -f "/tmp/ralph_full_buffer.txt" ]]; then
  cp "/tmp/ralph_full_buffer.txt" "$RUN_DIR/full_buffer.txt"
  log_info "Archived full_buffer.txt"
else
  log_error "Buffer file not found: /tmp/ralph_full_buffer.txt"
fi

# Copy progress file
if [[ -f "$SCRIPT_DIR/progress.txt" ]]; then
  cp "$SCRIPT_DIR/progress.txt" "$RUN_DIR/progress.txt"
  log_info "Archived progress.txt"
else
  log_error "Progress file not found: $SCRIPT_DIR/progress.txt"
fi

# Get git commit SHA if in git repo
GIT_SHA=""
if [[ -d "$PROJECT_ROOT/.git" ]]; then
  cd "$PROJECT_ROOT"
  GIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
  log_info "Git commit SHA: $GIT_SHA"
else
  log_info "Not in a git repository"
fi

# Create metadata.json if provided via environment variables
if [[ -n "${STORIES_STARTED:-}" ]]; then
  # Calculate additional benchmark metrics
  STORIES_PER_HOUR=$(awk "BEGIN {printf \"%.2f\", (${STORIES_COMPLETED:-0} / ${DURATION_SECONDS:-1}) * 3600}")
  ITERATIONS_PER_HOUR=$(awk "BEGIN {printf \"%.2f\", (${ITERATIONS_COMPLETED:-0} / ${DURATION_SECONDS:-1}) * 3600}")

  cat > "$RUN_DIR/metadata.json" << EOF
{
  "run_id": "$RUN_ID",
  "start_time": "${START_TIME:-unknown}",
  "end_time": "${END_TIME:-unknown}",
  "duration_seconds": ${DURATION_SECONDS:-0},
  "agent": "${AGENT:-unknown}",
  "iterations_completed": ${ITERATIONS_COMPLETED:-0},
  "iterations_target": ${ITERATIONS_TARGET:-0},
  "stories_started": ${STORIES_STARTED:-0},
  "stories_completed": ${STORIES_COMPLETED:-0},
  "git_commit_sha": "$GIT_SHA",
  "test_results": {
    "passing": ${TESTS_PASSING:-0},
    "failing": ${TESTS_FAILING:-0}
  },
  "performance_metrics": {
    "avg_iteration_duration_seconds": ${AVG_ITERATION_DURATION:-0},
    "avg_stories_per_iteration": ${AVG_STORIES_PER_ITERATION:-0.0},
    "stories_per_hour": ${STORIES_PER_HOUR},
    "iterations_per_hour": ${ITERATIONS_PER_HOUR}
  },
  "issues": ${ISSUES_JSON:-[]},
  "status": "${STATUS:-UNKNOWN}",
  "api_endpoint": "${API_ENDPOINT:-unknown}",
  "notes": "${RUN_NOTES:-}"
}
EOF
  log_info "Created metadata.json"
fi

# Update symlink to latest run (relative path from scripts/)
ln -sf "../ralph-runs/$RUN_ID/progress.txt" "$SCRIPT_DIR/progress.txt"
log_info "Updated progress.txt symlink to latest run"

log_info "Artifact archival complete: $RUN_DIR"
