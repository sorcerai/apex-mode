#!/bin/bash
# APEX Circuit Breaker v4.0 - PreToolUse Hook
# Checks circuit breaker state and semantic tool availability

set -e

APEX_STATE="$HOME/.claude/apex/state/apex-state.json"
APEX_LOCK="$APEX_STATE.lock"

if [[ ! -f "$APEX_STATE" ]]; then
    exit 0
fi

if ! jq -e '.' "$APEX_STATE" >/dev/null 2>&1; then
    exit 0
fi

HOOK_INPUT=$(cat)
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_input // empty')

# Atomic read with flock
(
flock -s 200

# Read current state
STATE=$(cat "$APEX_STATE")

ALREADY_TRIPPED=$(echo "$STATE" | jq -r '.circuit_breakers.tripped // false')
if [[ "$ALREADY_TRIPPED" == "true" ]]; then
    echo "🚨 APEX CIRCUIT BREAKER ALREADY TRIPPED" >&2
    echo "   Run '/apex/resume' to reset and continue." >&2
    echo "   Run '/apex/status' to see details." >&2
    exit 1
fi

MODE=$(echo "$STATE" | jq -r '.mode // "default"')
RALPH_ACTIVE=$(echo "$STATE" | jq -r '.completion_cycle.active // false')

case "$MODE" in
    "safe")
        ITER_TOOL_LIMIT=25
        ITER_ERROR_LIMIT=3
        ITER_FILE_LIMIT=5
        CYCLE_TOOL_LIMIT=100
        CYCLE_ERROR_LIMIT=10
        STUCK_THRESHOLD=2
        ;;
    "fast")
        ITER_TOOL_LIMIT=100
        ITER_ERROR_LIMIT=10
        ITER_FILE_LIMIT=20
        CYCLE_TOOL_LIMIT=400
        CYCLE_ERROR_LIMIT=30
        STUCK_THRESHOLD=5
        ;;
    *)
        ITER_TOOL_LIMIT=50
        ITER_ERROR_LIMIT=5
        ITER_FILE_LIMIT=10
        CYCLE_TOOL_LIMIT=200
        CYCLE_ERROR_LIMIT=15
        STUCK_THRESHOLD=3
        ;;
esac

trip_breaker() {
    local reason="$1"
    jq --arg reason "$reason" '.circuit_breakers.tripped = true | .circuit_breakers.trip_reason = $reason' "$APEX_STATE" > "$APEX_STATE.tmp"
    mv "$APEX_STATE.tmp" "$APEX_STATE"
    exit 1
}

SEMANTIC_TOOLS="grepai_search grepai_trace query_code_graph get_code_snippet surgical_replace_code"
for sem_tool in $SEMANTIC_TOOLS; do
    if [[ "$TOOL_NAME" == "$sem_tool" ]]; then
        GREPAI_AVAIL=$(echo "$STATE" | jq -r '.semantic_tools.available.grepai // false')
        GRAPHCODE_AVAIL=$(echo "$STATE" | jq -r '.semantic_tools.available.graph_code // false')
        
        if [[ "$TOOL_NAME" == grepai_* && "$GREPAI_AVAIL" == "false" ]]; then
            echo "⚠️  grepai not available - using grep fallback" >&2
        fi
        if [[ "$TOOL_NAME" == query_* || "$TOOL_NAME" == get_code_* || "$TOOL_NAME" == surgical_* ]]; then
            if [[ "$GRAPHCODE_AVAIL" == "false" ]]; then
                echo "⚠️  graph-code not available - using AST fallback" >&2
            fi
        fi
        exit 0
    fi
done

ITER_TOOL_CALLS=$(echo "$STATE" | jq -r '.circuit_breakers.tool_calls.iteration_current // 0')
if [[ "$ITER_TOOL_CALLS" -ge "$ITER_TOOL_LIMIT" ]]; then
    echo "🚨 APEX CIRCUIT BREAKER TRIPPED: Tool calls limit reached ($ITER_TOOL_CALLS/$ITER_TOOL_LIMIT)" >&2
    if [[ "$RALPH_ACTIVE" == "true" ]]; then
        echo "   Ralph mode active - run '/apex/resume' to continue next iteration." >&2
    else
        echo "   Run '/apex/resume' to reset and continue." >&2
    fi
    trip_breaker "tool_calls_iteration"
fi

if [[ "$RALPH_ACTIVE" == "true" ]]; then
    CYCLE_TOOL_CALLS=$(echo "$STATE" | jq -r '.circuit_breakers.tool_calls.cycle_current // 0')
    if [[ "$CYCLE_TOOL_CALLS" -ge "$CYCLE_TOOL_LIMIT" ]]; then
        echo "🚨 APEX HARD LIMIT REACHED: Total tool calls across all iterations ($CYCLE_TOOL_CALLS/$CYCLE_TOOL_LIMIT)" >&2
        echo "   This cycle has used maximum allowed tool calls." >&2
        echo "   Run '/apex/resume --reset-cycle' or start fresh." >&2
        trip_breaker "tool_calls_cycle"
    fi
fi

ITER_TOOL_WARNING=$((ITER_TOOL_LIMIT * 80 / 100))
if [[ "$ITER_TOOL_CALLS" -ge "$ITER_TOOL_WARNING" ]]; then
    echo "⚠️  APEX Warning: Tool calls at $ITER_TOOL_CALLS/$ITER_TOOL_LIMIT (iteration)" >&2
fi

ITER_ERRORS=$(echo "$STATE" | jq -r '.circuit_breakers.errors.iteration_current // 0')
if [[ "$ITER_ERRORS" -ge "$ITER_ERROR_LIMIT" ]]; then
    echo "🚨 APEX CIRCUIT BREAKER TRIPPED: Error limit reached ($ITER_ERRORS/$ITER_ERROR_LIMIT)" >&2
    echo "   Recent errors:" >&2
    echo "$STATE" | jq -r '.circuit_breakers.errors.history[-3:][]' 2>/dev/null >&2 || true
    trip_breaker "errors_iteration"
fi

if [[ "$RALPH_ACTIVE" == "true" ]]; then
    CYCLE_ERRORS=$(echo "$STATE" | jq -r '.circuit_breakers.errors.cycle_current // 0')
    if [[ "$CYCLE_ERRORS" -ge "$CYCLE_ERROR_LIMIT" ]]; then
        echo "🚨 APEX HARD LIMIT REACHED: Total errors across all iterations ($CYCLE_ERRORS/$CYCLE_ERROR_LIMIT)" >&2
        trip_breaker "errors_cycle"
    fi
fi

if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "MultiEdit" ]]; then
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
    if [[ -n "$FILE_PATH" ]]; then
        FILE_EDITS=$(echo "$STATE" | jq -r --arg fp "$FILE_PATH" '.circuit_breakers.same_file_edits.files[$fp] // 0')
        if [[ "$FILE_EDITS" -ge "$ITER_FILE_LIMIT" ]]; then
            echo "🚨 APEX CIRCUIT BREAKER TRIPPED: Same file edited too many times ($FILE_EDITS/$ITER_FILE_LIMIT)" >&2
            echo "   File: $FILE_PATH" >&2
            echo "   Consider a different approach or run '/apex/resume'." >&2
            trip_breaker "same_file_edits"
        fi

        ITER_FILE_WARNING=$((ITER_FILE_LIMIT * 80 / 100))
        if [[ "$FILE_EDITS" -ge "$ITER_FILE_WARNING" ]]; then
            echo "⚠️  APEX Warning: File '$FILE_PATH' edited $FILE_EDITS times" >&2
        fi
    fi
fi

# Improved stuck loop detection using hash-based approach
PATTERN_HASHES=$(echo "$STATE" | jq -r '[.circuit_breakers.stuck_loop.patterns[-'$STUCK_THRESHOLD':][]] | map(@base64) | .[]' 2>/dev/null || echo "")
if [[ -n "$PATTERN_HASHES" ]]; then
    UNIQUE_COUNT=$(echo "$PATTERN_HASHES" | sort -u | wc -l | tr -d ' ')
    TOTAL_COUNT=$(echo "$PATTERN_HASHES" | wc -l | tr -d ' ')

    if [[ "$TOTAL_COUNT" -ge "$STUCK_THRESHOLD" && "$UNIQUE_COUNT" -eq 1 ]]; then
        echo "🚨 APEX STUCK LOOP DETECTED: Same action pattern repeated $STUCK_THRESHOLD times" >&2
        echo "   Try a different approach." >&2
        trip_breaker "stuck_loop"
    fi
    
    # Also detect longer cycles (A→B→A→B)
    if [[ "$TOTAL_COUNT" -ge 4 ]]; then
        HALF=$((TOTAL_COUNT / 2))
        FIRST_HALF=$(echo "$PATTERN_HASHES" | head -n $HALF | md5sum | cut -d' ' -f1)
        SECOND_HALF=$(echo "$PATTERN_HASHES" | tail -n $HALF | md5sum | cut -d' ' -f1)
        if [[ "$FIRST_HALF" == "$SECOND_HALF" ]]; then
            echo "🚨 APEX CYCLE DETECTED: Repeating pattern of length $HALF detected" >&2
            echo "   Try a different approach." >&2
            exit 1
        fi
    fi
fi

) 200>"$APEX_LOCK"

# All checks passed
exit 0
