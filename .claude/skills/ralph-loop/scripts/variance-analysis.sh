#!/bin/bash
# Ralph Loop Variance Analysis Script
# Compares runs across different dimensions to identify trends and anomalies
# Usage: ./variance-analysis.sh [--compare <agent1,agent2>] [--trend] [--anomalies] [--json]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
RUNS_DIR="$PROJECT_ROOT/ralph-runs"

# Default values
COMPARE_AGENTS=""
SHOW_TREND=false
DETECT_ANOMALIES=false
OUTPUT_JSON=false
PERIOD_DAYS=90

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
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --compare)
      COMPARE_AGENTS="$2"
      shift 2
      ;;
    --trend)
      SHOW_TREND=true
      shift
      ;;
    --anomalies)
      DETECT_ANOMALIES=true
      shift
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
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --compare <agents>   Compare specific agents (comma-separated)"
      echo "  --trend              Show trend analysis over time"
      echo "  --anomalies          Detect anomalous runs"
      echo "  --period <days>      Analysis period in days (default: 90)"
      echo "  --json               Output in JSON format"
      echo "  --help               Show this help"
      echo ""
      echo "Examples:"
      echo "  $0 --compare claude-glm,qwen"
      echo "  $0 --trend --period 30"
      echo "  $0 --anomalies"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check dependencies
check_dependencies

# Calculate cutoff date
if date -v-1d &>/dev/null 2>&1; then
  CUTOFF_DATE=$(date -v-${PERIOD_DAYS}d +%Y-%m-%d)
else
  CUTOFF_DATE=$(date -d "-${PERIOD_DAYS} days" +%Y-%m-%d)
fi

# Collect all runs
collect_runs() {
  local runs="[]"

  if [[ ! -d "$RUNS_DIR" ]]; then
    echo "$runs"
    return
  fi

  while IFS= read -r -d '' metadata_file; do
    if [[ ! -f "$metadata_file" ]]; then
      continue
    fi

    # Validate JSON before processing
    if ! jq empty "$metadata_file" >/dev/null 2>&1; then
      continue
    fi

    local dir_name=$(dirname "$metadata_file")
    local run_date=$(basename "$dir_name" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "1970-01-01")

    if [[ "$run_date" < "$CUTOFF_DATE" ]]; then
      continue
    fi

    local run_data=$(cat "$metadata_file" | jq --arg date "$run_date" '. + {run_date: $date}')
    runs=$(echo "$runs" | jq --argjson run "$run_data" '. + [$run]')
  done < <(find "$RUNS_DIR" -name "metadata.json" -print0 2>/dev/null)

  echo "$runs"
}

# Calculate mean and stddev for numeric array
calc_stats() {
  local values=("$@")
  local n=${#values[@]}

  if [[ $n -lt 2 ]]; then
    echo '{"mean": 0, "stddev": 0}'
    return
  fi

  # Calculate mean
  local sum=0
  for v in "${values[@]}"; do
    sum=$(awk "BEGIN {print $sum + $v}")
  done
  local mean=$(awk "BEGIN {print $sum / $n}")

  # Calculate variance
  local var_sum=0
  for v in "${values[@]}"; do
    local diff=$(awk "BEGIN {print $v - $mean}")
    var_sum=$(awk "BEGIN {print $var_sum + ($diff * $diff)}")
  done
  local variance=$(awk "BEGIN {print $var_sum / $n}")
  local stddev=$(awk "BEGIN {printf \"%.1f\", sqrt($variance)}")

  echo "{\"mean\": $mean, \"stddev\": $stddev}"
}

# Compare agents
compare_agents() {
  local runs="$1"
  local agents_to_compare="$2"

  if [[ -z "$agents_to_compare" ]]; then
    echo "[]"
    return
  fi

  local comparison="[]"
  IFS=',' read -ra agent_list <<< "$agents_to_compare"

  for agent in "${agent_list[@]}"; do
    agent=$(echo "$agent" | xargs)  # trim whitespace
    local agent_runs=$(echo "$runs" | jq --arg a "$agent" '[.[] | select(.agent == $a)]')
    local count=$(echo "$agent_runs" | jq 'length')

    if [[ $count -gt 0 ]]; then
      local completed=$(echo "$agent_runs" | jq '[.[] | select(.status == "COMPLETE")] | length')
      local success_rate=$(awk "BEGIN {printf \"%.1f\", ($completed / $count) * 100}")
      local avg_duration=$(echo "$agent_runs" | jq '[.[].duration_seconds] | add / length')
      local avg_iterations=$(echo "$agent_runs" | jq '[.[].iterations_completed] | add / length')

      comparison=$(echo "$comparison" | jq --arg agent "$agent" \
        --argjson count "$count" \
        --argjson completed "$completed" \
        --arg success_rate "$success_rate" \
        --argjson avg_duration "$avg_duration" \
        --argjson avg_iterations "$avg_iterations" \
        '. + [{agent: $agent, count: $count, completed: $completed, success_rate: ($success_rate | tonumber), avg_duration_seconds: $avg_duration, avg_iterations: $avg_iterations}]')
    fi
  done

  echo "$comparison"
}

# Analyze trends by month
analyze_trend() {
  local runs="$1"

  echo "$runs" | jq '
    group_by(.run_date[:7]) |
    map({
      month: .[0].run_date[:7],
      runs: length,
      completed: [.[] | select(.status == "COMPLETE")] | length,
      total_duration: ([.[].duration_seconds] | add),
      avg_duration: ([.[].duration_seconds] | add / length)
    }) |
    sort_by(.month)
  '
}

# Detect anomalies (2σ threshold)
detect_anomalies() {
  local runs="$1"
  local anomalies="[]"

  local total_runs=$(echo "$runs" | jq 'length')
  if [[ $total_runs -lt 3 ]]; then
    echo '{"anomalies": [], "thresholds": {}}'
    return
  fi

  # Extract durations
  local durations=$(echo "$runs" | jq '[.[].duration_seconds]')

  # Calculate mean
  local mean=$(echo "$durations" | jq 'add / length')
  # Calculate variance and stddev
  local variance=$(echo "$durations" | jq --argjson mean "$mean" '[.[] | ((. - $mean) | . * .)] | add / length')
  local stddev=$(awk "BEGIN {printf \"%.1f\", sqrt($variance)}")

  local upper_threshold=$(awk "BEGIN {printf \"%.1f\", $mean + 2 * $stddev}")
  local lower_threshold=$(awk "BEGIN {printf \"%.1f\", $mean - 2 * $stddev}")

  # Find anomalies
  while IFS= read -r run; do
    local duration=$(echo "$run" | jq '.duration_seconds')
    local run_id=$(echo "$run" | jq -r '.run_id')
    local agent=$(echo "$run" | jq -r '.agent')

    if (( $(awk "BEGIN {print ($duration > $upper_threshold)}") )); then
      anomalies=$(echo "$anomalies" | jq --arg id "$run_id" --arg ag "$agent" --argjson dur "$duration" --argjson thresh "$upper_threshold" \
        '. + [{run_id: $id, agent: $ag, type: "high_duration", value: $dur, threshold: $thresh}]')
    elif (( $(awk "BEGIN {print ($duration < $lower_threshold && $duration > 0)}") )); then
      anomalies=$(echo "$anomalies" | jq --arg id "$run_id" --arg ag "$agent" --argjson dur "$duration" --argjson thresh "$lower_threshold" \
        '. + [{run_id: $id, agent: $ag, type: "low_duration", value: $dur, threshold: $thresh}]')
    fi
  done < <(echo "$runs" | jq -c '.[]')

  echo "{\"anomalies\": $anomalies, \"thresholds\": {mean: $mean, stddev: $stddev, upper: $upper_threshold, lower: $lower_threshold}}"
}

# Main
main() {
  local runs=$(collect_runs)
  local total_runs=$(echo "$runs" | jq 'length')

  if [[ $total_runs -eq 0 ]]; then
    if [[ "$OUTPUT_JSON" == "true" ]]; then
      echo '{"error": "No runs found in the specified period"}'
    else
      echo "${COLOR_YELLOW}No runs found in the last $PERIOD_DAYS days${COLOR_RESET}"
    fi
    exit 0
  fi

  local completed=$(echo "$runs" | jq '[.[] | select(.status == "COMPLETE")] | length')

  # Build result
  local result="{\"period_days\": $PERIOD_DAYS, \"total_runs\": $total_runs, \"completed_runs\": $completed}"

  # Agent comparison
  if [[ -n "$COMPARE_AGENTS" ]] || [[ "$OUTPUT_JSON" == "true" ]]; then
    local comparison=$(compare_agents "$runs" "$COMPARE_AGENTS")
    result=$(echo "$result" | jq --argjson comp "$comparison" '. + {agent_comparison: $comp}')
  fi

  # Trend analysis
  if [[ "$SHOW_TREND" == "true" ]] || [[ "$OUTPUT_JSON" == "true" ]]; then
    local trend=$(analyze_trend "$runs")
    result=$(echo "$result" | jq --argjson t "$trend" '. + {trend: $t}')
  fi

  # Anomaly detection
  if [[ "$DETECT_ANOMALIES" == "true" ]] || [[ "$OUTPUT_JSON" == "true" ]]; then
    local anomalies=$(detect_anomalies "$runs")
    result=$(echo "$result" | jq --argjson a "$anomalies" '. + {anomaly_detection: $a}')
  fi

  # Output
  if [[ "$OUTPUT_JSON" == "true" ]]; then
    echo "$result" | jq '.'
  else
    echo ""
    echo "${COLOR_CYAN}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo "${COLOR_CYAN}         RALPH LOOP VARIANCE ANALYSIS${COLOR_RESET}"
    echo "${COLOR_CYAN}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo ""
    echo "${COLOR_MAGENTA}Period:${COLOR_RESET} Last $PERIOD_DAYS days"
    echo "${COLOR_MAGENTA}Total Runs:${COLOR_RESET} $total_runs"
    echo "${COLOR_MAGENTA}Completed:${COLOR_RESET} $completed"
    echo ""

    # Agent comparison output
    if [[ -n "$COMPARE_AGENTS" ]]; then
      echo "${COLOR_YELLOW}Agent Comparison:${COLOR_RESET}"
      echo "$result" | jq -r '.agent_comparison[] | "  \(.agent): \(.count) runs, \(.success_rate)% success, avg \(.avg_duration_seconds | floor)s duration"'
      echo ""
    fi

    # Trend output
    if [[ "$SHOW_TREND" == "true" ]]; then
      echo "${COLOR_YELLOW}Monthly Trend:${COLOR_RESET}"
      echo "$result" | jq -r '.trend[] | "  \(.month): \(.runs) runs (\(.completed) completed), avg \(.avg_duration | floor)s"'
      echo ""
    fi

    # Anomaly output
    if [[ "$DETECT_ANOMALIES" == "true" ]]; then
      echo "${COLOR_YELLOW}Anomaly Detection (2σ threshold):${COLOR_RESET}"
      local anomaly_count=$(echo "$result" | jq '.anomaly_detection.anomalies | length')
      if [[ $anomaly_count -gt 0 ]]; then
        echo "$result" | jq -r '.anomaly_detection.anomalies[] | "  \(.type): \(.run_id) (\(.agent)) - \(.value)s (threshold: \(.threshold)s)"'
      else
        echo "  ${COLOR_GREEN}No anomalies detected${COLOR_RESET}"
      fi
      echo ""
      echo "  Thresholds:"
      echo "$result" | jq -r '.anomaly_detection.thresholds | "    Mean: \(.mean)s, StdDev: \(.stddev)s"'
      echo "$result" | jq -r '.anomaly_detection.thresholds | "    Upper: \(.upper)s, Lower: \(.lower)s"'
      echo ""
    fi

    echo "${COLOR_CYAN}═══════════════════════════════════════════════════════════${COLOR_RESET}"
  fi
}

main
