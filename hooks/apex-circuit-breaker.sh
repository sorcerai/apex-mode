#!/bin/bash
# APEX Circuit Breaker - PreToolUse Hook
# Checks circuit breaker state before allowing tool execution

set -e

APEX_STATE="$HOME/.claude/apex/state/apex-state.json"
APEX_DIR="$HOME/.claude/apex"

# Ensure state file exists
if [[ ! -f "$APEX_STATE" ]]; then
    exit 0  # No state = no limits yet
fi

# Parse hook input from stdin
HOOK_INPUT=$(cat)
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_input // empty')

# Read current state
STATE=$(cat "$APEX_STATE")

# Get current mode limits
MODE=$(echo "$STATE" | jq -r '.mode // "default"')

case "$MODE" in
    "safe")
        TOOL_LIMIT=25
        ERROR_LIMIT=3
        FILE_LIMIT=5
        STUCK_THRESHOLD=2
        ;;
    "fast")
        TOOL_LIMIT=100
        ERROR_LIMIT=10
        FILE_LIMIT=20
        STUCK_THRESHOLD=5
        ;;
    *)
        TOOL_LIMIT=50
        ERROR_LIMIT=5
        FILE_LIMIT=10
        STUCK_THRESHOLD=3
        ;;
esac

# Check tool calls breaker
TOOL_CALLS=$(echo "$STATE" | jq -r '.circuit_breakers.tool_calls.current // 0')
if [[ "$TOOL_CALLS" -ge "$TOOL_LIMIT" ]]; then
    echo "🚨 APEX CIRCUIT BREAKER TRIPPED: Tool calls limit reached ($TOOL_CALLS/$TOOL_LIMIT)" >&2
    echo "   Run '/apex/resume' with explicit confirmation to continue." >&2
    exit 1
fi

# Warning at 80%
TOOL_WARNING=$((TOOL_LIMIT * 80 / 100))
if [[ "$TOOL_CALLS" -ge "$TOOL_WARNING" ]]; then
    echo "⚠️  APEX Warning: Tool calls at $TOOL_CALLS/$TOOL_LIMIT" >&2
fi

# Check error breaker
ERRORS=$(echo "$STATE" | jq -r '.circuit_breakers.errors.current // 0')
if [[ "$ERRORS" -ge "$ERROR_LIMIT" ]]; then
    echo "🚨 APEX CIRCUIT BREAKER TRIPPED: Error limit reached ($ERRORS/$ERROR_LIMIT)" >&2
    echo "   Recent errors:" >&2
    echo "$STATE" | jq -r '.circuit_breakers.errors.history[-3:][]' >&2
    exit 1
fi

# Check same-file edit breaker (for Edit/Write tools)
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "MultiEdit" ]]; then
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
    if [[ -n "$FILE_PATH" ]]; then
        FILE_EDITS=$(echo "$STATE" | jq -r --arg fp "$FILE_PATH" '.circuit_breakers.same_file_edits.files[$fp] // 0')
        if [[ "$FILE_EDITS" -ge "$FILE_LIMIT" ]]; then
            echo "🚨 APEX CIRCUIT BREAKER TRIPPED: Same file edited too many times ($FILE_EDITS/$FILE_LIMIT)" >&2
            echo "   File: $FILE_PATH" >&2
            echo "   Consider a different approach or confirm to continue." >&2
            exit 1
        fi

        FILE_WARNING=$((FILE_LIMIT * 80 / 100))
        if [[ "$FILE_EDITS" -ge "$FILE_WARNING" ]]; then
            echo "⚠️  APEX Warning: File '$FILE_PATH' edited $FILE_EDITS times" >&2
        fi
    fi
fi

# Check stuck loop pattern
PATTERN_COUNT=$(echo "$STATE" | jq -r '.circuit_breakers.stuck_loop.patterns | length')
if [[ "$PATTERN_COUNT" -ge "$STUCK_THRESHOLD" ]]; then
    # Check if last N patterns are identical
    LAST_PATTERNS=$(echo "$STATE" | jq -r ".circuit_breakers.stuck_loop.patterns[-$STUCK_THRESHOLD:]")
    UNIQUE_PATTERNS=$(echo "$LAST_PATTERNS" | jq -r 'unique | length')

    if [[ "$UNIQUE_PATTERNS" -eq 1 ]]; then
        echo "🚨 APEX STUCK LOOP DETECTED: Same action pattern repeated $STUCK_THRESHOLD times" >&2
        echo "   Pattern: $(echo "$LAST_PATTERNS" | jq -r '.[0]')" >&2
        echo "   Try a different approach." >&2
        exit 1
    fi
fi

# All checks passed
exit 0
