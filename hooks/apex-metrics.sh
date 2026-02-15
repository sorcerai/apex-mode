#!/bin/bash
# APEX Metrics v4.0 - PostToolUse Hook
# Updates circuit breaker counters, tracks semantic tool usage, and context efficiency

set -e

APEX_STATE="$HOME/.claude/apex/state/apex-state.json"
APEX_LOCK="$APEX_STATE.lock"

if [[ ! -f "$APEX_STATE" ]]; then
    exit 0
fi

HOOK_INPUT=$(cat)
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_input // empty')
TOOL_ERROR=$(echo "$HOOK_INPUT" | jq -r '.error // empty')

# Extract token usage if present
INPUT_TOKENS=$(echo "$HOOK_INPUT" | jq -r '.usage.input_tokens // 0')
OUTPUT_TOKENS=$(echo "$HOOK_INPUT" | jq -r '.usage.output_tokens // 0')

# Atomic update with flock
(
flock -x 200

# Read current state
STATE=$(cat "$APEX_STATE")

STATE=$(echo "$STATE" | jq '
    .circuit_breakers.tool_calls.iteration_current += 1 |
    .circuit_breakers.tool_calls.cycle_current += 1
')

# Track token usage
if [[ "$INPUT_TOKENS" -gt 0 || "$OUTPUT_TOKENS" -gt 0 ]]; then
    STATE=$(echo "$STATE" | jq --argjson inp "$INPUT_TOKENS" --argjson out "$OUTPUT_TOKENS" '
        .metrics.tokens.input += $inp |
        .metrics.tokens.output += $out |
        .metrics.tokens.total = (.metrics.tokens.input + .metrics.tokens.output)
    ')
fi

# Track errors
if [[ -n "$TOOL_ERROR" && "$TOOL_ERROR" != "null" ]]; then
    STATE=$(echo "$STATE" | jq --arg err "$TOOL_ERROR" '
        .circuit_breakers.errors.iteration_current += 1 |
        .circuit_breakers.errors.cycle_current += 1 |
        .circuit_breakers.errors.history += [$err] |
        .circuit_breakers.errors.history = .circuit_breakers.errors.history[-10:]
    ')
fi

if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "MultiEdit" ]]; then
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
    if [[ -n "$FILE_PATH" ]]; then
        STATE=$(echo "$STATE" | jq --arg fp "$FILE_PATH" '
            .circuit_breakers.same_file_edits.files[$fp] =
                ((.circuit_breakers.same_file_edits.files[$fp] // 0) + 1)
        ')
    fi
fi

SEMANTIC_TOOLS="grepai_search grepai_trace query_code_graph get_code_snippet surgical_replace_code index_repository"
for sem_tool in $SEMANTIC_TOOLS; do
    if [[ "$TOOL_NAME" == "$sem_tool" ]]; then
        STATE=$(echo "$STATE" | jq --arg tool "$TOOL_NAME" '
            .semantic_tools.usage[$tool] = ((.semantic_tools.usage[$tool] // 0) + 1) |
            .semantic_tools.last_used = $tool
        ')
        break
    fi
done

PAT_ACTION=$(echo "$TOOL_INPUT" | jq -r 'keys[0] // "unknown"')
PAT_STATUS=$(if [[ -n "$TOOL_ERROR" && "$TOOL_ERROR" != "null" ]]; then echo "error"; else echo "success"; fi)
STATE=$(echo "$STATE" | jq --arg tool "$TOOL_NAME" --arg action "$PAT_ACTION" --arg status "$PAT_STATUS" '
    .circuit_breakers.stuck_loop.patterns += [[ $tool, $action, $status ]] |
    .circuit_breakers.stuck_loop.patterns = .circuit_breakers.stuck_loop.patterns[-20:]
')

CURRENT_HASH=$(echo "$STATE" | jq -r '.circuit_breakers.stuck_loop.patterns[-5:] | @base64')
LAST_HASH=$(echo "$STATE" | jq -r '.loop_mode.stagnation.current_hash // ""')

if [[ "$CURRENT_HASH" == "$LAST_HASH" && -n "$LAST_HASH" ]]; then
    STATE=$(echo "$STATE" | jq '
        .loop_mode.stagnation.consecutive_same += 1 |
        .circuit_breakers.stuck_loop.stagnation_count += 1
    ')
else
    STATE=$(echo "$STATE" | jq --arg hash "$CURRENT_HASH" '
        .loop_mode.stagnation.current_hash = $hash |
        .loop_mode.stagnation.consecutive_same = 0
    ')
fi

if [[ "$TOOL_NAME" == "Read" || "$TOOL_NAME" == "Grep" || "$TOOL_NAME" == "Glob" ]]; then
    STATE=$(echo "$STATE" | jq '
        .context_efficiency.files_loaded += 1
    ')
fi

if [[ "$TOOL_NAME" == "grepai_search" || "$TOOL_NAME" == "query_code_graph" ]]; then
    STATE=$(echo "$STATE" | jq '
        .context_efficiency.searches_performed += 1
    ')
fi

STATE=$(echo "$STATE" | jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
    .current_session.last_activity = $ts
')

# Write updated state atomically
echo "$STATE" | jq '.' > "$APEX_STATE.tmp" && mv "$APEX_STATE.tmp" "$APEX_STATE"

) 200>"$APEX_LOCK"

exit 0
