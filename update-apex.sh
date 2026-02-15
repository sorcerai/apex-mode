#!/bin/bash
# APEX Updater v4.0 - Pull latest from upstream sources and regenerate
# Usage: ./update-apex.sh [component]
# Components: prism, planning, aidd, ralph, grepai, graph-code, navigator, pilot, all

set -e

APEX_DIR="$HOME/.claude/apex"
TEMP_DIR="/tmp/apex-update-$(date +%s)"
mkdir -p "$TEMP_DIR"

echo "🔄 APEX Updater v4.0"
echo "===================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

COMPONENT="${1:-all}"

clone_repo() {
    local name="$1"
    local url="$2"
    local dir="$TEMP_DIR/$name"

    echo -e "${YELLOW}Updating $name...${NC}"
    if git clone --depth 1 "$url" "$dir" 2>/dev/null; then
        echo -e "${GREEN}✓ Cloned $name${NC}"
        echo "Review: $dir"

        # Show latest commit
        local latest_commit
        latest_commit=$(cd "$dir" && git log -1 --format="%ci %s" 2>/dev/null)
        echo -e "${CYAN}Latest commit:${NC} $latest_commit"

        # Show README head
        if [[ -f "$dir/README.md" ]]; then
            echo ""
            echo "=== Latest README (first 30 lines) ==="
            head -30 "$dir/README.md"
        fi
        return 0
    else
        echo -e "${RED}✗ Failed to clone $name${NC}"
        return 1
    fi
}

update_prism() {
    echo -e "${YELLOW}Updating PRISM...${NC}"
    echo "PRISM is a methodology, not a repo. Manual review needed."
    echo "Check: Your PRISM v3.3.zip or methodology updates"
    echo "APEX files to update: APEX.md, APEX_OPERATIONAL.md, APEX_REFERENCE.md"
}

update_planning() {
    if clone_repo "planning" "https://github.com/OthmanAdi/planning-with-files.git"; then
        echo ""
        echo "APEX files to update: commands/plan.md, templates/*"
    fi
}

update_aidd() {
    if clone_repo "aidd" "https://github.com/paralleldrive/aidd.git"; then
        echo ""
        echo "APEX files to update: commands/discover.md, commands/task.md, commands/execute.md, commands/review.md, commands/commit.md"

        # Check for prompts directory
        if [[ -d "$TEMP_DIR/aidd/prompts" ]]; then
            echo ""
            echo "=== Prompts found ==="
            ls -la "$TEMP_DIR/aidd/prompts/"
        fi
    fi
}

update_ralph() {
    if clone_repo "ralph" "https://github.com/frankbria/ralph-claude-code.git"; then
        echo ""
        echo "APEX files to update: hooks/*, state/apex-state.json schema"
    fi
}

update_grepai() {
    if clone_repo "grepai" "https://github.com/yoanbernabeu/grepai.git"; then
        echo ""
        echo "APEX files to update: integrations/grepai/README.md, mcp/grepai.json, skills/apex-semantic.md"

        # Check version
        if [[ -f "$TEMP_DIR/grepai/pyproject.toml" ]]; then
            local version
            version=$(grep -m1 'version' "$TEMP_DIR/grepai/pyproject.toml" 2>/dev/null | head -1)
            echo -e "${CYAN}Version:${NC} $version"
        fi
    fi
}

update_graph_code() {
    if clone_repo "graph-code" "https://github.com/vitali87/code-graph-rag.git"; then
        echo ""
        echo "APEX files to update: integrations/graph-code/README.md, mcp/graph-code.json"

        # Check version
        if [[ -f "$TEMP_DIR/graph-code/pyproject.toml" ]]; then
            local version
            version=$(grep -m1 'version' "$TEMP_DIR/graph-code/pyproject.toml" 2>/dev/null | head -1)
            echo -e "${CYAN}Version:${NC} $version"
        fi
    fi
}

update_navigator() {
    if clone_repo "navigator" "https://github.com/alekspetrov/navigator.git"; then
        echo ""
        echo "APEX files to update: skills/apex-context.md, skills/apex-profile.md, commands/simplify.md, commands/yolo.md (loop mode)"

        # Check version
        if [[ -f "$TEMP_DIR/navigator/package.json" ]]; then
            local version
            version=$(jq -r '.version // "unknown"' "$TEMP_DIR/navigator/package.json" 2>/dev/null)
            echo -e "${CYAN}Version:${NC} $version"
        elif [[ -f "$TEMP_DIR/navigator/VERSION" ]]; then
            echo -e "${CYAN}Version:${NC} $(cat "$TEMP_DIR/navigator/VERSION")"
        fi
    fi
}

update_pilot() {
    if clone_repo "pilot" "https://github.com/alekspetrov/pilot.git"; then
        echo ""
        echo "Pilot is an autonomous dev pipeline (ticket → plan → code → PR)."
        echo "It's a companion to Navigator with Signal Protocol v2 integration."
        echo "APEX files to update: evaluate for integration into APEX workflow"
    fi
}

case "$COMPONENT" in
    prism)
        update_prism
        ;;
    planning)
        update_planning
        ;;
    aidd)
        update_aidd
        ;;
    ralph)
        update_ralph
        ;;
    grepai)
        update_grepai
        ;;
    graph-code)
        update_graph_code
        ;;
    navigator)
        update_navigator
        ;;
    pilot)
        update_pilot
        ;;
    all)
        update_prism
        echo ""
        update_planning
        echo ""
        update_aidd
        echo ""
        update_ralph
        echo ""
        update_grepai
        echo ""
        update_graph_code
        echo ""
        update_navigator
        echo ""
        update_pilot
        ;;
    *)
        echo "Unknown component: $COMPONENT"
        echo "Usage: $0 [prism|planning|aidd|ralph|grepai|graph-code|navigator|pilot|all]"
        exit 1
        ;;
esac

echo ""
echo "===================="
echo -e "${GREEN}Update check complete${NC}"
echo ""
echo "Temp files in: $TEMP_DIR"
echo ""
echo "Next steps:"
echo "1. Review changes in temp directory"
echo "2. Update relevant APEX files manually"
echo "3. Or ask Claude: 'Update APEX from $TEMP_DIR/[component]'"
echo ""
echo "To clean up: rm -rf $TEMP_DIR"
