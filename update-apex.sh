#!/bin/bash
# APEX Updater - Pull latest from upstream sources and regenerate
# Usage: ./update-apex.sh [component]
# Components: prism, planning, aidd, ralph, all

set -e

APEX_DIR="$HOME/.claude/apex"
TEMP_DIR="/tmp/apex-update-$(date +%s)"
mkdir -p "$TEMP_DIR"

echo "🔄 APEX Updater"
echo "==============="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMPONENT="${1:-all}"

update_prism() {
    echo -e "${YELLOW}Updating PRISM...${NC}"
    echo "PRISM is a methodology, not a repo. Manual review needed."
    echo "Check: Your PRISM v3.3.zip or methodology updates"
    echo "APEX files to update: APEX.md, APEX_OPERATIONAL.md, APEX_REFERENCE.md"
}

update_planning() {
    echo -e "${YELLOW}Updating Planning with Files...${NC}"
    if git clone --depth 1 https://github.com/OthmanAdi/planning-with-files.git "$TEMP_DIR/planning" 2>/dev/null; then
        echo -e "${GREEN}✓ Cloned planning-with-files${NC}"
        echo "Review: $TEMP_DIR/planning"
        echo "APEX files to update: commands/plan.md, templates/*"

        # Show what changed
        if [[ -f "$TEMP_DIR/planning/README.md" ]]; then
            echo ""
            echo "=== Latest README ==="
            head -50 "$TEMP_DIR/planning/README.md"
        fi
    else
        echo -e "${RED}✗ Failed to clone planning-with-files${NC}"
    fi
}

update_aidd() {
    echo -e "${YELLOW}Updating AIDD...${NC}"
    if git clone --depth 1 https://github.com/paralleldrive/aidd.git "$TEMP_DIR/aidd" 2>/dev/null; then
        echo -e "${GREEN}✓ Cloned aidd${NC}"
        echo "Review: $TEMP_DIR/aidd"
        echo "APEX files to update: commands/discover.md, commands/task.md, commands/execute.md, commands/review.md, commands/commit.md"

        # Show what changed
        if [[ -f "$TEMP_DIR/aidd/README.md" ]]; then
            echo ""
            echo "=== Latest README ==="
            head -50 "$TEMP_DIR/aidd/README.md"
        fi

        # Check for prompts directory
        if [[ -d "$TEMP_DIR/aidd/prompts" ]]; then
            echo ""
            echo "=== Prompts found ==="
            ls -la "$TEMP_DIR/aidd/prompts/"
        fi
    else
        echo -e "${RED}✗ Failed to clone aidd${NC}"
    fi
}

update_ralph() {
    echo -e "${YELLOW}Updating Ralph...${NC}"
    if git clone --depth 1 https://github.com/frankbria/ralph-claude-code.git "$TEMP_DIR/ralph" 2>/dev/null; then
        echo -e "${GREEN}✓ Cloned ralph-claude-code${NC}"
        echo "Review: $TEMP_DIR/ralph"
        echo "APEX files to update: hooks/*, state/apex-state.json schema"

        # Show what changed
        if [[ -f "$TEMP_DIR/ralph/README.md" ]]; then
            echo ""
            echo "=== Latest README ==="
            head -50 "$TEMP_DIR/ralph/README.md"
        fi
    else
        echo -e "${RED}✗ Failed to clone ralph-claude-code${NC}"
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
    all)
        update_prism
        echo ""
        update_planning
        echo ""
        update_aidd
        echo ""
        update_ralph
        ;;
    *)
        echo "Unknown component: $COMPONENT"
        echo "Usage: $0 [prism|planning|aidd|ralph|all]"
        exit 1
        ;;
esac

echo ""
echo "==============="
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
