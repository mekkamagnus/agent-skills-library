#!/bin/bash
# Check Ralph status and progress
# Usage: ./status.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PRD_FILE="$PROJECT_ROOT/prd.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"

###############################################################################
# COLORS
###############################################################################

if [ -t 1 ] && [ "$(tput colors 2>/dev/null)" -ge 8 ]; then
  COLOR_GREEN=$(tput setaf 2)
  COLOR_YELLOW=$(tput setaf 3)
  COLOR_RED=$(tput setaf 1)
  COLOR_CYAN=$(tput setaf 6)
  COLOR_BLUE=$(tput setaf 4)
  COLOR_RESET=$(tput sgr0)
else
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_CYAN=""
  COLOR_BLUE=""
  COLOR_RESET=""
fi

###############################################################################
# FUNCTIONS
###############################################################################

print_header() {
  echo ""
  echo "${COLOR_CYAN}═══════════════════════════════════════════════════════${COLOR_RESET}"
  echo "${COLOR_CYAN}=== $1 ===${COLOR_RESET}"
  echo "${COLOR_CYAN}═══════════════════════════════════════════════════════${COLOR_RESET}"
  echo ""
}

print_section() {
  echo ""
  echo "${COLOR_BLUE}--- $1 ---${COLOR_RESET}"
}

###############################################################################
# CHECK PRD
###############################################################################

print_header "Ralph Status"

if [ ! -f "$PRD_FILE" ]; then
  echo "${COLOR_RED}✗ PRD file not found: $PRD_FILE${COLOR_RESET}"
  echo ""
  echo "Ralph requires a prd.json file in the project root."
  echo "Run Ralph to auto-create from example template."
  exit 1
fi

PROJECT_NAME=$(jq -r '.projectName // "Unknown"' "$PRD_FILE")
BRANCH_NAME=$(jq -r '.branchName // "Unknown"' "$PRD_FILE")

echo "Project: ${COLOR_YELLOW}$PROJECT_NAME${COLOR_RESET}"
echo "Branch:  ${COLOR_YELLOW}$BRANCH_NAME${COLOR_RESET}"

###############################################################################
# CHECK USER STORIES
###############################################################################

print_section "User Stories"

TOTAL_STORIES=$(jq '[.userStories[]] | length' "$PRD_FILE" 2>/dev/null || echo "0")
COMPLETED_STORIES=$(jq '[.userStories[] | select(.passes == true)] | length' "$PRD_FILE" 2>/dev/null || echo "0")
REMAINING_STORIES=$((TOTAL_STORIES - COMPLETED_STORIES))
PERCENT_COMPLETE=$((COMPLETED_STORIES * 100 / TOTAL_STORIES))

echo "Total:     ${COLOR_CYAN}$TOTAL_STORIES${COLOR_RESET}"
echo "Completed: ${COLOR_GREEN}$COMPLETED_STORIES${COLOR_RESET}"
echo "Remaining: ${COLOR_YELLOW}$REMAINING_STORIES${COLOR_RESET}"
echo "Progress:  ${COLOR_CYAN}${PERCENT_COMPLETE}%${COLOR_RESET}"

###############################################################################
# LIST REMAINING STORIES
###############################################################################

if [ "$REMAINING_STORIES" -gt 0 ]; then
  print_section "Remaining Stories (by priority)"

  jq -r '.userStories[] | select(.passes == false) | "\(.priority)|\(.id)|\(.title)"' "$PRD_FILE" 2>/dev/null | sort -n | head -10 | while IFS='|' read -r priority id title; do
    echo "  ${COLOR_YELLOW}[$id]${COLOR_RESET} $title ${COLOR_BLUE}(priority: $priority)${COLOR_RESET}"
  done

  if [ "$REMAINING_STORIES" -gt 10 ]; then
    echo "  ... and $((REMAINING_STORIES - 10)) more"
  fi
fi

###############################################################################
# CHECK PROGRESS FILE
###############################################################################

print_section "Progress Log"

if [ ! -f "$PROGRESS_FILE" ]; then
  echo "${COLOR_YELLOW}⚠ Progress file not found: $PROGRESS_FILE${COLOR_RESET}"
  echo "Ralph has not started yet."
else
  # Show last 5 entries from progress file
  echo "Recent progress:"
  grep "^## \[" "$PROGRESS_FILE" 2>/dev/null | tail -5 | while IFS=']' read -r timestamp rest; do
    echo "  ${COLOR_GREEN}${timestamp}]${COLOR_RESET}${rest}"
  done

  # Count iterations
  ITERATION_COUNT=$(grep -c "Starting iteration" "$PROGRESS_FILE" 2>/dev/null || echo "0")
  echo ""
  echo "Total iterations: ${COLOR_CYAN}$ITERATION_COUNT${COLOR_RESET}"
fi

###############################################################################
# CHECK ARCHIVE
###############################################################################

print_section "Archive"

ARCHIVE_DIR="$SCRIPT_DIR/archive"
if [ -d "$ARCHIVE_DIR" ]; then
  ARCHIVE_COUNT=$(ls -1 "$ARCHIVE_DIR" 2>/dev/null | wc -l)
  if [ "$ARCHIVE_COUNT" -gt 0 ]; then
    echo "Archived runs: ${COLOR_CYAN}$ARCHIVE_COUNT${COLOR_RESET}"
    ls -1t "$ARCHIVE_DIR" 2>/dev/null | head -3 | while read -r archive; do
      echo "  ${COLOR_BLUE}• $archive${COLOR_RESET}"
    done
  else
    echo "No archived runs"
  fi
else
  echo "No archive directory"
fi

###############################################################################
# SUMMARY
###############################################################################

print_section "Summary"

if [ "$REMAINING_STORIES" -eq 0 ]; then
  echo "${COLOR_GREEN}✓ All user stories completed!${COLOR_RESET}"
  echo "Ralph has finished successfully."
else
  echo "${COLOR_YELLOW}ℹ $REMAINING_STORIES stories remaining${COLOR_RESET}"
  echo "Ralph is still working or has not completed yet."
fi

echo ""
