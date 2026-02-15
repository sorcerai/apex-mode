#!/bin/bash
# APEX Session - Stop Hook
# Persists session state and archives completed work

set -e

APEX_STATE="$HOME/.claude/apex/state/apex-state.json"

# Ensure state file exists
if [[ ! -f "$APEX_STATE" ]]; then
    exit 0
fi

# Read current state
STATE=$(cat "$APEX_STATE")

# Check if there's an active session
CURRENT_SESSION=$(echo "$STATE" | jq -r '.current_session // null')
if [[ "$CURRENT_SESSION" == "null" ]]; then
    exit 0
fi

SESSION_ID=$(echo "$CURRENT_SESSION" | jq -r '.id // "unknown"')
SESSION_START=$(echo "$CURRENT_SESSION" | jq -r '.started // ""')
SESSION_PHASE=$(echo "$CURRENT_SESSION" | jq -r '.phase // "unknown"')
TOOL_CALLS=$(echo "$STATE" | jq -r '.circuit_breakers.tool_calls.iteration_current // 0')

# Create session summary
SESSION_END=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Add to session history
STATE=$(echo "$STATE" | jq --arg id "$SESSION_ID" \
    --arg started "$SESSION_START" \
    --arg ended "$SESSION_END" \
    --arg phase "$SESSION_PHASE" \
    --arg tools "$TOOL_CALLS" '
    .session_history += [{
        "id": $id,
        "started": $started,
        "ended": $ended,
        "final_phase": $phase,
        "tool_calls": ($tools | tonumber // 0),
        "outcome": "session_end"
    }] |
    .session_history = .session_history[-50:]
')

# Reset circuit breakers for next session
STATE=$(echo "$STATE" | jq '
    .circuit_breakers.tool_calls.iteration_current = 0 |
    .circuit_breakers.tool_calls.cycle_current = 0 |
    .circuit_breakers.errors.iteration_current = 0 |
    .circuit_breakers.errors.cycle_current = 0 |
    .circuit_breakers.errors.history = [] |
    .circuit_breakers.same_file_edits.files = {} |
    .circuit_breakers.stuck_loop.patterns = []
')

# Clear current session (will be recreated on next start)
STATE=$(echo "$STATE" | jq '.current_session = null')

# Write final state
echo "$STATE" | jq '.' > "$APEX_STATE"

# Log session end
echo "📊 APEX Session ended: $SESSION_ID"
echo "   Duration: $SESSION_START → $SESSION_END"
echo "   Final phase: $SESSION_PHASE"
echo "   Tool calls: $TOOL_CALLS"

exit 0
