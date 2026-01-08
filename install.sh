#!/bin/bash
# APEX Installer
# Installs APEX to ~/.claude/apex/ and configures hooks

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "    _    ____  _______  __"
echo "   / \  |  _ \| ____\ \/ /"
echo "  / _ \ | |_) |  _|  \  / "
echo " / ___ \|  __/| |___ /  \ "
echo "/_/   \_\_|   |_____/_/\_\\"
echo -e "${NC}"
echo "Autonomous Planning & EXecution"
echo "================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APEX_DIR="$HOME/.claude/apex"
SETTINGS_FILE="$HOME/.claude/settings.json"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq is not installed. Circuit breaker hooks require jq.${NC}"
    echo "Install with: brew install jq (macOS) or apt install jq (Linux)"
    echo ""
fi

# Create apex directory
echo -e "${BLUE}[1/4]${NC} Creating APEX directory..."
mkdir -p "$APEX_DIR"

# Copy files
echo -e "${BLUE}[2/4]${NC} Copying APEX files..."
cp -r "$SCRIPT_DIR"/*.md "$APEX_DIR/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/commands "$APEX_DIR/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/hooks "$APEX_DIR/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/state "$APEX_DIR/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/templates "$APEX_DIR/" 2>/dev/null || true
cp "$SCRIPT_DIR"/update-apex.sh "$APEX_DIR/" 2>/dev/null || true

# Make hooks executable
chmod +x "$APEX_DIR"/hooks/*.sh 2>/dev/null || true
chmod +x "$APEX_DIR"/update-apex.sh 2>/dev/null || true

echo -e "${GREEN}✓ Files copied to $APEX_DIR${NC}"

# Initialize state file if missing
if [[ ! -f "$APEX_DIR/state/apex-state.json" ]]; then
    mkdir -p "$APEX_DIR/state"
    cat > "$APEX_DIR/state/apex-state.json" << 'EOF'
{
  "version": "1.0.0",
  "current_session": null,
  "circuit_breakers": {
    "tool_calls": { "current": 0, "warning": 40, "limit": 50 },
    "errors": { "current": 0, "warning": 4, "limit": 5, "history": [] },
    "same_file_edits": { "files": {}, "warning": 8, "limit": 10 },
    "stuck_loop": { "patterns": [], "threshold": 3 }
  },
  "mode": "default",
  "session_history": []
}
EOF
fi

# Add hooks to settings.json
echo -e "${BLUE}[3/4]${NC} Configuring hooks..."

if [[ -f "$SETTINGS_FILE" ]]; then
    # Check if hooks already exist
    if grep -q "apex-circuit-breaker" "$SETTINGS_FILE" 2>/dev/null; then
        echo -e "${YELLOW}Hooks already configured in settings.json${NC}"
    else
        echo -e "${YELLOW}Note: Please add APEX hooks to your settings.json manually.${NC}"
        echo ""
        echo "Add to PreToolUse:"
        echo '  {"matcher": "", "hooks": [{"type": "command", "command": "~/.claude/apex/hooks/apex-circuit-breaker.sh"}]}'
        echo ""
        echo "Add to PostToolUse:"
        echo '  {"matcher": "", "hooks": [{"type": "command", "command": "~/.claude/apex/hooks/apex-metrics.sh"}]}'
        echo ""
        echo "Add to Stop:"
        echo '  {"matcher": "", "hooks": [{"type": "command", "command": "~/.claude/apex/hooks/apex-session.sh"}]}'
    fi
else
    echo -e "${YELLOW}settings.json not found. Skipping hook configuration.${NC}"
fi

# Offer to add import to CLAUDE.md
echo ""
echo -e "${BLUE}[4/4]${NC} Configure CLAUDE.md import..."

if [[ -f "$CLAUDE_MD" ]]; then
    if grep -q "@apex/APEX.md" "$CLAUDE_MD" 2>/dev/null; then
        echo -e "${GREEN}✓ APEX already imported in CLAUDE.md${NC}"
    else
        read -p "Add APEX import to CLAUDE.md? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "" >> "$CLAUDE_MD"
            echo "# APEX: Autonomous Planning & EXecution" >> "$CLAUDE_MD"
            echo "@apex/APEX.md" >> "$CLAUDE_MD"
            echo -e "${GREEN}✓ Added APEX import to CLAUDE.md${NC}"
        fi
    fi
else
    echo -e "${YELLOW}CLAUDE.md not found at $CLAUDE_MD${NC}"
    echo "Create one and add: @apex/APEX.md"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}APEX installation complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Usage:"
echo "  /apex/yolo [task]    Full autonomous run"
echo "  /apex/discover       Requirements elicitation"
echo "  /apex/plan           Create workflow files"
echo "  /apex/task           Decompose into todos"
echo "  /apex/execute        Implement with safety"
echo "  /apex/review         Validate quality"
echo "  /apex/commit         Git workflow"
echo ""
echo "Files installed to: $APEX_DIR"
echo ""
