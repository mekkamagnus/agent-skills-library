#!/bin/bash
# Ralph Loop Benchmark Analysis Script
# Analyzes historical run data to provide performance benchmarks
# Usage: ./benchmark-analysis.sh [--agent <name>] [--period <days>] [--json]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
RUNS_DIR="$PROJECT_ROOT/ralph-runs"

# Default values
AGENT_FILTER=""
PERIOD_DAYS=30
OUTPUT_JSON=false

# Colors
if [ -t 1 ] && [ "$(tput colors 2>/dev/null)" -ge 8 ]; then
  COLOR_GREEN=$(tput setaf 2)
  COLOR_YELLOW=$(tput setaf 3)
  COLOR_RED=$(tput setaf 1)
  COLOR_CYAN=$(tput setaf 6)
  COLOR_MAGENTA=$(tput setaf 5)
  COLOR_RESET=$(tput sgr0)
else
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_CYAN=""
  COLOR_MAGENTA=""
  COLOR_RESET=""
fi

# Error handling
die() {
  echo "${COLOR_RED}ERROR: $1${COLOR_RESET}" >&2
  exit 1
}

# Check dependencies
check_dependencies() {
  if ! command -v jq &>/dev/null; then
    die "Missing required dependency: jq. Install with: brew install jq"
  fi
  if ! command -v awk &>/dev/null; then
    die "Missing required dependency: awk"
  fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --agent)
      AGENT_FILTER="$2"
      shift 2
      ;;
    --period)
      PERIOD_DAYS="$2"
      shift 2
      ;;
    --json)
      OUTPUT_JSON=true
      shift
      ;;
    --help)
      echo "Usage: $0 [--agent <name>] [--period <days>] [--json]"
      echo ""
      echo "Options:"
      echo "  --agent <name>   Filter by agent (claude-glm, qwen, codex, etc.)"
      echo "  --period <days>  Analysis period in days (default: 30)"
      echo "  --json           Output in JSON format"
      echo "  --help           Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Calculate cutoff date (macOS and Linux compatible)
if date -v-1d &>/dev/null 2>&1; then
  CUTOFF_DATE=$(date -v-${PERIOD_DAYS}d +%Y-%m-%d)
else
  CUTOFF_DATE=$(date -d "-${PERIOD_DAYS} days" +%Y-%m-%d)
fi

# Collect all metadata.json files
collect_metadata_files() {
  local files=""

  # From ralph-runs directory
  if [[ -d "$RUNS_DIR" ]]; then
    while IFS= read -r -d '' file; do
      files="$files $file"
    done < <(find "$RUNS_DIR" -name "metadata.json" -print0 2>/dev/null)
  fi

  echo "$files"
}

# Calculate variance: sum of squared differences from mean divided by n
# Args: values as space-separated string
calculate_variance() {
  local values=($1)
  local n=${#values[@]}

  if [[ $n -lt 2 ]]; then
    echo "0"
    return
  fi

  # Calculate mean
  local sum=0
  for v in "${values[@]}"; do
    sum=$(awk "BEGIN {print $sum + $v}")
  done
  local mean=$(awk "BEGIN {print $sum / $n}")

  # Calculate variance
  local variance_sum=0
  for v in "${values[@]}"; do
    local diff=$(awk "BEGIN {print $v - $mean}")
    variance_sum=$(awk "BEGIN {print $variance_sum + ($diff * $diff)}")
  done
  local variance=$(awk "BEGIN {print $variance_sum / $n}")

  echo "$variance"
}

# Calculate standard deviation
calculate_stddev() {
  local variance=$1
  awk "BEGIN {printf \"%.1f\", sqrt($variance)}"
}

# Main analysis
analyze_runs() {
  local metadata_files=$(collect_metadata_files)

  if [[ -z "$metadata_files" ]]; then
    if [[ "$OUTPUT_JSON" == "true" ]]; then
      echo '{"error": "No runs found in the specified period"}'
    else
      echo "${COLOR_YELLOW}No runs found in the last $PERIOD_DAYS days${COLOR_RESET}"
    fi
    exit 0
  fi

  # Arrays to collect metrics
  local durations=()
  local iterations=()
  local stories=()
  local total_runs=0
  local completed_runs=0
  local incomplete_runs=0
  local total_stories=0
  local total_iterations=0
  local total_duration=0
  local max_duration=0
  local min_duration=999999
  local max_iterations=0
  local min_iterations=999999
  local agents_json="{}"

  # Process each metadata file
  for metadata_file in $metadata_files; do
    if [[ ! -f "$metadata_file" ]]; then
      continue
    fi

    # Validate JSON before processing
    if ! jq empty "$metadata_file" >/dev/null 2>&1; then
      continue
    fi

    # Extract run date from directory name
    dir_name=$(dirname "$metadata_file")
    run_date=$(basename "$dir_name" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "1970-01-01")

    # Skip if before cutoff
    if [[ "$run_date" < "$CUTOFF_DATE" ]]; then
      continue
    fi

    # Read metadata
    local metadata=$(cat "$metadata_file")
    local agent=$(echo "$metadata" | jq -r '.agent // "unknown"')
    local duration=$(echo "$metadata" | jq -r '.duration_seconds // 0')
    local iter_completed=$(echo "$metadata" | jq -r '.iterations_completed // 0')
    local stories_completed=$(echo "$metadata" | jq -r '.stories_completed // 0')
    local status=$(echo "$metadata" | jq -r '.status // "UNKNOWN"')
    local avg_iter_dur=$(echo "$metadata" | jq -r '.performance_metrics.avg_iteration_duration_seconds // 0')
    local avg_stories_iter=$(echo "$metadata" | jq -r '.performance_metrics.avg_stories_per_iteration // 0')

    # Apply agent filter
    if [[ -n "$AGENT_FILTER" && "$agent" != "$AGENT_FILTER" ]]; then
      continue
    fi

    # Collect metrics
    ((total_runs++))
    total_duration=$((total_duration + duration))
    total_iterations=$((total_iterations + iter_completed))
    total_stories=$((total_stories + stories_completed))

    durations+=($duration)
    iterations+=($iter_completed)
    stories+=($stories_completed)

    if [[ "$status" == "COMPLETE" ]]; then
      ((completed_runs++))
    else
      ((incomplete_runs++))
    fi

    # Track max/min
    if [[ $duration -gt $max_duration ]]; then
      max_duration=$duration
    fi
    if [[ $duration -lt $min_duration ]]; then
      min_duration=$duration
    fi
    if [[ $iter_completed -gt $max_iterations ]]; then
      max_iterations=$iter_completed
    fi
    if [[ $iter_completed -lt $min_iterations ]]; then
      min_iterations=$iter_completed
    fi

    # Track by agent
    local agent_count=$(echo "$agents_json" | jq -r --arg a "$agent" '.[$a].count // 0')
    local agent_completed=$(echo "$agents_json" | jq -r --arg a "$agent" '.[$a].completed // 0')
    ((agent_count++))
    if [[ "$status" == "COMPLETE" ]]; then
      ((agent_completed++))
    fi
    agents_json=$(echo "$agents_json" | jq --arg a "$agent" --argjson count $agent_count --argjson completed $agent_completed 'setpath([$a]; {count: $count, completed: $completed})')
  done

  if [[ $total_runs -eq 0 ]]; then
    if [[ "$OUTPUT_JSON" == "true" ]]; then
      echo '{"error": "No runs match the specified criteria"}'
    else
      echo "${COLOR_YELLOW}No runs match the specified criteria${COLOR_RESET}"
    fi
    exit 0
  fi

  # Calculate averages
  local avg_duration=$(awk "BEGIN {printf \"%.1f\", $total_duration / $total_runs}")
  local avg_iterations=$(awk "BEGIN {printf \"%.1f\", $total_iterations / $total_runs}")
  local avg_stories=$(awk "BEGIN {printf \"%.2f\", $total_stories / $total_runs}")
  local success_rate=$(awk "BEGIN {printf \"%.1f\", ($completed_runs / $total_runs) * 100}")
  local avg_iter_duration=$(awk "BEGIN {printf \"%.1f\", $total_duration / $total_iterations}") 2>/dev/null || avg_iter_duration="0"
  local avg_stories_iteration=$(awk "BEGIN {printf \"%.2f\", $total_stories / $total_iterations}") 2>/dev/null || avg_stories_iteration="0"

  # Calculate variance and stddev
  local durations_str="${durations[*]}"
  local iterations_str="${iterations[*]}"
  local duration_variance=$(calculate_variance "$durations_str")
  local iteration_variance=$(calculate_variance "$iterations_str")
  local duration_stddev=$(calculate_stddev "$duration_variance")
  local iteration_stddev=$(calculate_stddev "$iteration_variance")

  # Handle edge cases for min values
  if [[ $min_duration -eq 999999 ]]; then
    min_duration=0
  fi
  if [[ $min_iterations -eq 999999 ]]; then
    min_iterations=0
  fi

  # Output
  if [[ "$OUTPUT_JSON" == "true" ]]; then
    jq -n \
      --argjson total_runs "$total_runs" \
      --argjson completed_runs "$completed_runs" \
      --argjson incomplete_runs "$incomplete_runs" \
      --arg success_rate "$success_rate" \
      --argjson avg_duration "$avg_duration" \
      --argjson max_duration "$max_duration" \
      --argjson min_duration "$min_duration" \
      --arg duration_stddev "$duration_stddev" \
      --arg duration_variance "$duration_variance" \
      --argjson avg_iterations "$avg_iterations" \
      --argjson max_iterations "$max_iterations" \
      --argjson min_iterations "$min_iterations" \
      --arg iteration_stddev "$iteration_stddev" \
      --arg iteration_variance "$iteration_variance" \
      --argjson total_stories "$total_stories" \
      --arg avg_stories_per_run "$avg_stories" \
      --arg avg_stories_per_iteration "$avg_stories_iteration" \
      --arg avg_iteration_duration "$avg_iter_duration" \
      --argjson period_days "$PERIOD_DAYS" \
      --arg cutoff_date "$CUTOFF_DATE" \
      --argjson agents "$agents_json" \
      '{
        analysis_period: {
          days: $period_days,
          cutoff_date: $cutoff_date
        },
        run_statistics: {
          total: $total_runs,
          completed: $completed_runs,
          incomplete: $incomplete_runs,
          success_rate: ($success_rate | tonumber)
        },
        duration_metrics: {
          avg_seconds: ($avg_duration | tonumber),
          max_seconds: $max_duration,
          min_seconds: $min_duration,
          stddev_seconds: ($duration_stddev | tonumber),
          variance: ($duration_variance | tonumber)
        },
        iteration_metrics: {
          avg: ($avg_iterations | tonumber),
          max: $max_iterations,
          min: $min_iterations,
          stddev: ($iteration_stddev | tonumber),
          variance: ($iteration_variance | tonumber)
        },
        productivity_metrics: {
          total_stories: $total_stories,
          avg_stories_per_run: ($avg_stories_per_run | tonumber),
          avg_stories_per_iteration: ($avg_stories_per_iteration | tonumber),
          avg_iteration_duration_seconds: ($avg_iteration_duration | tonumber)
        },
        expected_benchmarks: {
          duration_seconds: (($avg_duration | tonumber) + ($duration_stddev | tonumber) | floor),
          iterations: (($avg_iterations | tonumber) + ($iteration_stddev | tonumber) | floor),
          stories_per_hour: ((($avg_stories_per_run | tonumber) / ($avg_duration | tonumber)) * 3600)
        },
        by_agent: $agents
      }'
  else
    echo ""
    echo "${COLOR_CYAN}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo "${COLOR_CYAN}         RALPH LOOP BENCHMARK ANALYSIS${COLOR_RESET}"
    echo "${COLOR_CYAN}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo ""
    echo "${COLOR_MAGENTA}Analysis Period:${COLOR_RESET} Last $PERIOD_DAYS days (since $CUTOFF_DATE)"
    echo ""
    echo "${COLOR_YELLOW}Run Statistics:${COLOR_RESET}"
    echo "  Total Runs:           $total_runs"
    echo "  Completed:            $completed_runs"
    echo "  Incomplete:           $incomplete_runs"
    echo "  Success Rate:         ${success_rate}%"
    echo ""
    echo "${COLOR_YELLOW}Duration Metrics:${COLOR_RESET}"
    printf "  Average Duration:     %s seconds (%.1f min)\n" "$avg_duration" "$(awk "BEGIN {print $avg_duration/60}")"
    printf "  Max Duration:         %d seconds (%.1f min)\n" "$max_duration" "$(awk "BEGIN {print $max_duration/60}")"
    printf "  Min Duration:         %d seconds (%.1f min)\n" "$min_duration" "$(awk "BEGIN {print $min_duration/60}")"
    printf "  Std Deviation:        %s seconds\n" "$duration_stddev"
    printf "  Variance:             %s\n" "$duration_variance"
    echo ""
    echo "${COLOR_YELLOW}Iteration Metrics:${COLOR_RESET}"
    printf "  Average Iterations:   %s\n" "$avg_iterations"
    printf "  Max Iterations:       %d\n" "$max_iterations"
    printf "  Min Iterations:       %d\n" "$min_iterations"
    printf "  Std Deviation:        %s\n" "$iteration_stddev"
    printf "  Variance:             %s\n" "$iteration_variance"
    echo ""
    echo "${COLOR_YELLOW}Productivity Metrics:${COLOR_RESET}"
    printf "  Total Stories:        %d\n" "$total_stories"
    printf "  Avg Stories/Run:      %s\n" "$avg_stories"
    printf "  Avg Stories/Iter:     %s\n" "$avg_stories_iteration"
    printf "  Avg Iter Duration:    %s seconds\n" "$avg_iter_duration"
    echo ""
    echo "${COLOR_YELLOW}Expected Benchmarks (avg + 1 stddev):${COLOR_RESET}"
    local expected_time=$(awk "BEGIN {printf \"%.0f\", $avg_duration + $duration_stddev}")
    local expected_iters=$(awk "BEGIN {printf \"%.0f\", $avg_iterations + $iteration_stddev}")
    printf "  Expected Duration:    %s seconds (%.1f min)\n" "$expected_time" "$(awk "BEGIN {print $expected_time/60}")"
    printf "  Expected Iterations:  %s\n" "$expected_iters"
    local stories_per_hour=$(awk "BEGIN {printf \"%.1f\", ($avg_stories / $avg_duration) * 3600}")
    printf "  Stories/Hour:         %s\n" "$stories_per_hour"
    echo ""
    echo "${COLOR_YELLOW}By Agent:${COLOR_RESET}"
    echo "$agents_json" | jq -r 'to_entries[] | "  \(.key): \(.value.count) runs (\(.value.completed) completed)"'
    echo ""
    echo "${COLOR_CYAN}═══════════════════════════════════════════════════════════${COLOR_RESET}"
  fi
}

# Run analysis
analyze_runs
