#!/bin/bash
# APEX Metrics - PostToolUse Hook
# Updates circuit breaker counters after tool execution

set -e

APEX_STATE="$HOME/.claude/apex/state/apex-state.json"

# Ensure state file exists
if [[ ! -f "$APEX_STATE" ]]; then
    exit 0
fi

# Parse hook input from stdin
HOOK_INPUT=$(cat)
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_input // empty')
TOOL_OUTPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_output // empty')
TOOL_ERROR=$(echo "$HOOK_INPUT" | jq -r '.error // empty')

# Read current state
STATE=$(cat "$APEX_STATE")

# Increment tool calls
STATE=$(echo "$STATE" | jq '.circuit_breakers.tool_calls.current += 1')

# Track errors
if [[ -n "$TOOL_ERROR" && "$TOOL_ERROR" != "null" ]]; then
    STATE=$(echo "$STATE" | jq --arg err "$TOOL_ERROR" '
        .circuit_breakers.errors.current += 1 |
        .circuit_breakers.errors.history += [$err] |
        .circuit_breakers.errors.history = .circuit_breakers.errors.history[-10:]
    ')
fi

# Track same-file edits
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "MultiEdit" ]]; then
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
    if [[ -n "$FILE_PATH" ]]; then
        STATE=$(echo "$STATE" | jq --arg fp "$FILE_PATH" '
            .circuit_breakers.same_file_edits.files[$fp] =
                ((.circuit_breakers.same_file_edits.files[$fp] // 0) + 1)
        ')
    fi
fi

# Track action pattern for stuck loop detection
PATTERN="[\"$TOOL_NAME\", \"$(echo "$TOOL_INPUT" | jq -r 'keys[0] // "unknown"')\", \"$(if [[ -n "$TOOL_ERROR" ]]; then echo "error"; else echo "success"; fi)\"]"
STATE=$(echo "$STATE" | jq --argjson pat "$PATTERN" '
    .circuit_breakers.stuck_loop.patterns += [$pat] |
    .circuit_breakers.stuck_loop.patterns = .circuit_breakers.stuck_loop.patterns[-20:]
')

# Update last activity timestamp
STATE=$(echo "$STATE" | jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
    .current_session.last_activity = $ts
')

# Write updated state
echo "$STATE" | jq '.' > "$APEX_STATE"

exit 0
