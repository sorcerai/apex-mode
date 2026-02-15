#!/bin/bash
# APEX v4.0 Test Suite
# Validates installation, hooks, state management, and v4.0 features

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APEX_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="/tmp/apex-test-$$"
PASSED=0
FAILED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    PASSED=$((PASSED + 1))
}

log_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    FAILED=$((FAILED + 1))
}

log_info() {
    echo -e "${YELLOW}INFO${NC}: $1"
}

cleanup() {
    rm -rf "$TEST_DIR" 2>/dev/null || true
}
trap cleanup EXIT

echo "================================"
echo "APEX v4.0 Test Suite"
echo "================================"
echo ""
echo "APEX Directory: $APEX_DIR"
echo "Test Directory: $TEST_DIR"
echo ""

mkdir -p "$TEST_DIR"

echo "--- Test Group: File Structure ---"
echo ""

test_file_exists() {
    local file="$1"
    local desc="$2"
    if [[ -f "$APEX_DIR/$file" ]]; then
        log_pass "$desc exists"
    else
        log_fail "$desc missing: $file"
    fi
}

test_dir_exists() {
    local dir="$1"
    local desc="$2"
    if [[ -d "$APEX_DIR/$dir" ]]; then
        log_pass "$desc exists"
    else
        log_fail "$desc missing: $dir"
    fi
}

test_file_exists "APEX.md" "Main APEX file"
test_file_exists "APEX_OPERATIONAL.md" "Operational procedures"
test_file_exists "APEX_REFERENCE.md" "Reference documentation"
test_file_exists "README.md" "README"
test_file_exists "VERSION.md" "Version tracking"
test_file_exists "install.sh" "Installer script"
test_file_exists "update-apex.sh" "Update script"

test_dir_exists "commands" "Commands directory"
test_dir_exists "hooks" "Hooks directory"
test_dir_exists "templates" "Templates directory"
test_dir_exists "integrations" "Integrations directory"
test_dir_exists "mcp" "MCP configs directory"
test_dir_exists "skills" "Skills directory"

echo ""
echo "--- Test Group: Shell Script Syntax ---"
echo ""

test_shell_syntax() {
    local script="$1"
    local desc="$2"
    if bash -n "$APEX_DIR/$script" 2>/dev/null; then
        log_pass "$desc syntax valid"
    else
        log_fail "$desc has syntax errors"
    fi
}

test_shell_syntax "install.sh" "Installer"
test_shell_syntax "update-apex.sh" "Updater"
test_shell_syntax "hooks/apex-circuit-breaker.sh" "Circuit breaker hook"
test_shell_syntax "hooks/apex-metrics.sh" "Metrics hook"
test_shell_syntax "hooks/apex-session.sh" "Session hook"

echo ""
echo "--- Test Group: JSON Validation ---"
echo ""

test_json_valid() {
    local file="$1"
    local desc="$2"
    if jq empty "$APEX_DIR/$file" 2>/dev/null; then
        log_pass "$desc is valid JSON"
    else
        log_fail "$desc is invalid JSON"
    fi
}

test_json_valid "mcp/grepai.json" "grepai MCP config"
test_json_valid "mcp/graph-code.json" "graph-code MCP config"

echo ""
echo "--- Test Group: Hook Execution ---"
echo ""

test_hook_execution() {
    local hook="$1"
    local input="$2"
    local desc="$3"
    
    mkdir -p "$TEST_DIR/.claude/apex/state"
    echo '{"version":"4.0.0","circuit_breakers":{"tool_calls":{"iteration_current":0,"cycle_current":0,"iteration_warning":40,"iteration_limit":50,"cycle_limit":200},"errors":{"iteration_current":0,"cycle_current":0,"iteration_warning":4,"iteration_limit":5,"cycle_limit":15,"history":[]},"same_file_edits":{"files":{},"iteration_warning":8,"iteration_limit":10,"cycle_limit":30},"stuck_loop":{"patterns":[],"threshold":3,"state_hashes":[],"stagnation_count":0},"tripped":false},"semantic_tools":{"available":{"grepai":false,"graph_code":false},"usage":{},"last_used":null},"mode":"default","current_session":null,"completion_cycle":{"active":false},"loop_mode":{"stagnation":{"current_hash":null,"consecutive_same":0,"threshold":3}}}' > "$TEST_DIR/.claude/apex/state/apex-state.json"

    export HOME="$TEST_DIR"

    if echo "$input" | "$APEX_DIR/$hook" >/dev/null 2>&1; then
        log_pass "$desc executed successfully"
    else
        local exit_code=$?
        if [[ $exit_code -eq 0 ]]; then
            log_pass "$desc executed successfully"
        else
            log_fail "$desc failed with exit code $exit_code"
        fi
    fi
}

test_hook_execution "hooks/apex-circuit-breaker.sh" '{"tool_name":"Read","tool_input":{}}' "Circuit breaker with Read tool"

echo ""
echo "--- Test Group: State Management ---"
echo ""

test_state_increment() {
    mkdir -p "$TEST_DIR/.claude/apex/state"
    echo '{"version":"4.0.0","circuit_breakers":{"tool_calls":{"iteration_current":0,"cycle_current":0,"iteration_warning":40,"iteration_limit":50,"cycle_limit":200},"errors":{"iteration_current":0,"cycle_current":0,"iteration_warning":4,"iteration_limit":5,"cycle_limit":15,"history":[]},"same_file_edits":{"files":{},"iteration_warning":8,"iteration_limit":10,"cycle_limit":30},"stuck_loop":{"patterns":[],"threshold":3,"state_hashes":[],"stagnation_count":0},"tripped":false},"semantic_tools":{"available":{"grepai":false,"graph_code":false},"usage":{},"last_used":null},"mode":"default","current_session":null,"completion_cycle":{"active":false},"loop_mode":{"stagnation":{"current_hash":null,"consecutive_same":0,"threshold":3}}}' > "$TEST_DIR/.claude/apex/state/apex-state.json"

    export HOME="$TEST_DIR"

    echo '{"tool_name":"Read","tool_input":{},"error":null}' | "$APEX_DIR/hooks/apex-metrics.sh" >/dev/null 2>&1

    local iter_count=$(jq -r '.circuit_breakers.tool_calls.iteration_current' "$TEST_DIR/.claude/apex/state/apex-state.json")
    local cycle_count=$(jq -r '.circuit_breakers.tool_calls.cycle_current' "$TEST_DIR/.claude/apex/state/apex-state.json")

    if [[ "$iter_count" == "1" && "$cycle_count" == "1" ]]; then
        log_pass "Metrics hook increments tool_calls counter"
    else
        log_fail "Metrics hook should increment to 1, got: iteration=$iter_count, cycle=$cycle_count"
    fi
}

test_state_increment

test_error_tracking() {
    mkdir -p "$TEST_DIR/.claude/apex/state"
    echo '{"version":"4.0.0","circuit_breakers":{"tool_calls":{"iteration_current":0,"cycle_current":0,"iteration_warning":40,"iteration_limit":50,"cycle_limit":200},"errors":{"iteration_current":0,"cycle_current":0,"iteration_warning":4,"iteration_limit":5,"cycle_limit":15,"history":[]},"same_file_edits":{"files":{},"iteration_warning":8,"iteration_limit":10,"cycle_limit":30},"stuck_loop":{"patterns":[],"threshold":3,"state_hashes":[],"stagnation_count":0},"tripped":false},"semantic_tools":{"available":{"grepai":false,"graph_code":false},"usage":{},"last_used":null},"mode":"default","current_session":null,"completion_cycle":{"active":false},"loop_mode":{"stagnation":{"current_hash":null,"consecutive_same":0,"threshold":3}}}' > "$TEST_DIR/.claude/apex/state/apex-state.json"

    export HOME="$TEST_DIR"

    echo '{"tool_name":"Edit","tool_input":{},"error":"Some error occurred"}' | "$APEX_DIR/hooks/apex-metrics.sh" >/dev/null 2>&1

    local error_count=$(jq -r '.circuit_breakers.errors.iteration_current' "$TEST_DIR/.claude/apex/state/apex-state.json")
    local history_len=$(jq -r '.circuit_breakers.errors.history | length' "$TEST_DIR/.claude/apex/state/apex-state.json")

    if [[ "$error_count" == "1" && "$history_len" == "1" ]]; then
        log_pass "Metrics hook tracks errors correctly"
    else
        log_fail "Error tracking failed: count=$error_count, history_len=$history_len"
    fi
}

test_error_tracking

test_circuit_breaker_trip() {
    mkdir -p "$TEST_DIR/.claude/apex/state"
    echo '{"version":"4.0.0","circuit_breakers":{"tool_calls":{"iteration_current":50,"cycle_current":50,"iteration_warning":40,"iteration_limit":50,"cycle_limit":200},"errors":{"iteration_current":0,"cycle_current":0,"iteration_warning":4,"iteration_limit":5,"cycle_limit":15,"history":[]},"same_file_edits":{"files":{},"iteration_warning":8,"iteration_limit":10,"cycle_limit":30},"stuck_loop":{"patterns":[],"threshold":3,"state_hashes":[],"stagnation_count":0},"tripped":false},"semantic_tools":{"available":{"grepai":false,"graph_code":false},"usage":{},"last_used":null},"mode":"default","current_session":null,"completion_cycle":{"active":false},"loop_mode":{"stagnation":{"current_hash":null,"consecutive_same":0,"threshold":3}}}' > "$TEST_DIR/.claude/apex/state/apex-state.json"
    
    export HOME="$TEST_DIR"
    
    if echo '{"tool_name":"Read","tool_input":{}}' | "$APEX_DIR/hooks/apex-circuit-breaker.sh" >/dev/null 2>&1; then
        log_fail "Circuit breaker should trip at limit"
    else
        local tripped=$(jq -r '.circuit_breakers.tripped' "$TEST_DIR/.claude/apex/state/apex-state.json")
        if [[ "$tripped" == "true" ]]; then
            log_pass "Circuit breaker trips correctly at limit"
        else
            log_fail "Circuit breaker should set tripped=true"
        fi
    fi
}

test_circuit_breaker_trip

echo ""
echo "--- Test Group: Command Files ---"
echo ""

test_command_exists() {
    local cmd="$1"
    if [[ -f "$APEX_DIR/commands/$cmd.md" ]]; then
        log_pass "Command $cmd exists"
    else
        log_fail "Command $cmd missing"
    fi
}

test_command_exists "yolo"
test_command_exists "discover"
test_command_exists "plan"
test_command_exists "task"
test_command_exists "execute"
test_command_exists "review"
test_command_exists "commit"
test_command_exists "docs"
test_command_exists "simplify"
test_command_exists "profile"
test_command_exists "resume"
test_command_exists "status"
test_command_exists "help"

echo ""
echo "--- Test Group: Integration Files ---"
echo ""

test_file_exists "integrations/grepai/README.md" "grepai integration docs"
test_file_exists "integrations/graph-code/README.md" "graph-code integration docs"
test_file_exists "skills/apex-semantic.md" "Semantic skill"

echo ""
echo "--- Test Group: v4.0 Features ---"
echo ""

test_dir_exists "templates/docs" "Documentation templates directory"

test_file_exists "skills/apex-context.md" "Context efficiency skill"
test_file_exists "skills/apex-profile.md" "Theory of Mind skill"
test_file_exists "commands/simplify.md" "Simplify command"
test_file_exists "state/apex-profile.json.template" "Profile template"

test_json_valid "state/apex-state.json.template" "State template (v4.0)"
test_json_valid "state/apex-profile.json.template" "Profile template"

test_state_v4_fields() {
    local state_file="$APEX_DIR/state/apex-state.json.template"
    
    local has_context_budget=$(jq 'has("context_budget")' "$state_file")
    local has_loop_mode=$(jq 'has("loop_mode")' "$state_file")
    local has_tom=$(jq 'has("theory_of_mind")' "$state_file")
    local has_simplification=$(jq 'has("simplification")' "$state_file")
    
    if [[ "$has_context_budget" == "true" && "$has_loop_mode" == "true" && "$has_tom" == "true" && "$has_simplification" == "true" ]]; then
        log_pass "State template has all v4.0 fields"
    else
        log_fail "State template missing v4.0 fields"
    fi
}

test_state_v4_fields

echo ""
echo "================================"
echo "Test Results"
echo "================================"
echo ""
echo -e "${GREEN}Passed${NC}: $PASSED"
echo -e "${RED}Failed${NC}: $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
