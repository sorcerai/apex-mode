#!/bin/bash
# APEX Installer v4.0
# Installs APEX to ~/.claude/apex/ with semantic intelligence, context efficiency, and Theory of Mind

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}"
echo "    _    ____  _______  __   _  _    ___  "
echo "   / \  |  _ \| ____\ \/ /  | || |  / _ \ "
echo "  / _ \ | |_) |  _|  \  /   | || |_| | | |"
echo " / ___ \|  __/| |___ /  \   |__   _| |_| |"
echo "/_/   \_\_|   |_____/_/\_\     |_|  \___/ "
echo -e "${NC}"
echo "Autonomous Planning & EXecution v4.0"
echo "Context Efficiency + Theory of Mind"
echo "====================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APEX_DIR="$HOME/.claude/apex"
SETTINGS_FILE="$HOME/.claude/settings.json"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MCP_DIR="$APEX_DIR/mcp"

# Parse arguments
INSTALL_GREPAI=false
INSTALL_GRAPHCODE=false
INSTALL_ALL=false
SKIP_OPTIONAL=false

for arg in "$@"; do
    case $arg in
        --grepai)
            INSTALL_GREPAI=true
            ;;
        --graph-code)
            INSTALL_GRAPHCODE=true
            ;;
        --all)
            INSTALL_ALL=true
            INSTALL_GREPAI=true
            INSTALL_GRAPHCODE=true
            ;;
        --skip-optional)
            SKIP_OPTIONAL=true
            ;;
        --help)
            echo "Usage: ./install.sh [options]"
            echo ""
            echo "Options:"
            echo "  --grepai       Install grepai (semantic search)"
            echo "  --graph-code   Install graph-code (knowledge graph)"
            echo "  --all          Install all optional components"
            echo "  --skip-optional Skip all optional components"
            echo "  --help         Show this help"
            echo ""
            echo "Without options, installer will prompt for each component."
            exit 0
            ;;
    esac
done

# Check for required dependencies
echo -e "${BLUE}[1/7]${NC} Checking dependencies..."

DEPS_OK=true

# Check jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq is not installed (required for circuit breakers)${NC}"
    echo "  Install: brew install jq (macOS) or apt install jq (Linux)"
    DEPS_OK=false
fi

# Check git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ git is not installed (required)${NC}"
    DEPS_OK=false
fi

if [[ "$DEPS_OK" == "true" ]]; then
    echo -e "${GREEN}✓ Core dependencies OK${NC}"
fi

# Create apex directory structure
echo -e "${BLUE}[2/7]${NC} Creating APEX directory structure..."
mkdir -p "$APEX_DIR"
mkdir -p "$APEX_DIR/commands"
mkdir -p "$APEX_DIR/hooks"
mkdir -p "$APEX_DIR/state"
mkdir -p "$APEX_DIR/templates"
mkdir -p "$APEX_DIR/integrations/grepai"
mkdir -p "$APEX_DIR/integrations/graph-code"
mkdir -p "$APEX_DIR/skills"
mkdir -p "$MCP_DIR"

# Copy core files
echo -e "${BLUE}[3/7]${NC} Copying APEX core files..."
cp -r "$SCRIPT_DIR"/*.md "$APEX_DIR/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/commands/* "$APEX_DIR/commands/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/hooks/* "$APEX_DIR/hooks/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/state/* "$APEX_DIR/state/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/templates/* "$APEX_DIR/templates/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/integrations/* "$APEX_DIR/integrations/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/skills/* "$APEX_DIR/skills/" 2>/dev/null || true
cp "$SCRIPT_DIR"/update-apex.sh "$APEX_DIR/" 2>/dev/null || true

# Make hooks executable
chmod +x "$APEX_DIR"/hooks/*.sh 2>/dev/null || true
chmod +x "$APEX_DIR"/update-apex.sh 2>/dev/null || true

echo -e "${GREEN}✓ Core files copied to $APEX_DIR${NC}"

# Initialize state file
if [[ ! -f "$APEX_DIR/state/apex-state.json" ]]; then
    cp "$APEX_DIR/state/apex-state.json.template" "$APEX_DIR/state/apex-state.json"
    echo -e "${GREEN}✓ State file initialized${NC}"
fi

# Initialize profile file (v4.0)
if [[ ! -f "$APEX_DIR/state/apex-profile.json" ]]; then
    cp "$APEX_DIR/state/apex-profile.json.template" "$APEX_DIR/state/apex-profile.json"
    echo -e "${GREEN}✓ Profile file initialized${NC}"
fi

# Install optional: grepai
echo -e "${BLUE}[4/7]${NC} Semantic tools setup..."

if [[ "$SKIP_OPTIONAL" == "false" ]]; then
    # Check for Ollama (required for grepai)
    if command -v ollama &> /dev/null; then
        echo -e "${GREEN}✓ Ollama detected${NC}"
        OLLAMA_AVAILABLE=true
    else
        echo -e "${YELLOW}⚠ Ollama not found (required for grepai)${NC}"
        echo "  Install: https://ollama.ai/download"
        OLLAMA_AVAILABLE=false
    fi

    # grepai installation
    if [[ "$INSTALL_GREPAI" == "true" ]] || [[ "$INSTALL_ALL" == "false" && "$SKIP_OPTIONAL" == "false" ]]; then
        if [[ "$INSTALL_GREPAI" != "true" && "$OLLAMA_AVAILABLE" == "true" ]]; then
            read -p "Install grepai (semantic code search)? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                INSTALL_GREPAI=true
            fi
        fi
    fi

    if [[ "$INSTALL_GREPAI" == "true" ]]; then
        echo -e "${CYAN}Installing grepai...${NC}"
        if command -v pip &> /dev/null || command -v pip3 &> /dev/null; then
            PIP_CMD=$(command -v pip3 || command -v pip)
            $PIP_CMD install grepai 2>/dev/null && {
                echo -e "${GREEN}✓ grepai installed${NC}"
                # Update state
                jq '.semantic_tools.available.grepai = true' "$APEX_DIR/state/apex-state.json" > "$APEX_DIR/state/apex-state.json.tmp"
                mv "$APEX_DIR/state/apex-state.json.tmp" "$APEX_DIR/state/apex-state.json"
            } || {
                echo -e "${YELLOW}⚠ grepai installation failed - will use fallback${NC}"
            }
        else
            echo -e "${YELLOW}⚠ pip not found - skipping grepai${NC}"
        fi
    fi

    # graph-code installation
    if [[ "$INSTALL_GRAPHCODE" == "true" ]] || [[ "$INSTALL_ALL" == "false" && "$SKIP_OPTIONAL" == "false" ]]; then
        if [[ "$INSTALL_GRAPHCODE" != "true" ]]; then
            read -p "Install graph-code (knowledge graph RAG)? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                INSTALL_GRAPHCODE=true
            fi
        fi
    fi

    if [[ "$INSTALL_GRAPHCODE" == "true" ]]; then
        echo -e "${CYAN}Installing graph-code dependencies...${NC}"
        # Check for Docker (required for Memgraph)
        if command -v docker &> /dev/null; then
            echo -e "${GREEN}✓ Docker detected${NC}"
            
            # Pull Memgraph if not exists
            if ! docker images | grep -q memgraph; then
                echo "Pulling Memgraph image..."
                docker pull memgraph/memgraph-platform 2>/dev/null || {
                    echo -e "${YELLOW}⚠ Failed to pull Memgraph - graph-code will have limited functionality${NC}"
                }
            fi
            
            # Clone graph-code if needed
            if [[ ! -d "$APEX_DIR/integrations/graph-code/src" ]]; then
                echo "Cloning graph-code..."
                git clone --depth 1 https://github.com/vitali87/code-graph-rag.git "$APEX_DIR/integrations/graph-code/src" 2>/dev/null && {
                    echo -e "${GREEN}✓ graph-code cloned${NC}"
                    jq '.semantic_tools.available.graph_code = true' "$APEX_DIR/state/apex-state.json" > "$APEX_DIR/state/apex-state.json.tmp"
                    mv "$APEX_DIR/state/apex-state.json.tmp" "$APEX_DIR/state/apex-state.json"
                } || {
                    echo -e "${YELLOW}⚠ graph-code clone failed${NC}"
                }
            fi
        else
            echo -e "${YELLOW}⚠ Docker not found (required for graph-code Memgraph)${NC}"
            echo "  Install: https://docs.docker.com/get-docker/"
        fi
    fi
else
    echo -e "${YELLOW}Skipping optional components${NC}"
fi

# Update fallback mode based on availability
GREPAI_AVAIL=$(jq -r '.semantic_tools.available.grepai' "$APEX_DIR/state/apex-state.json")
GRAPHCODE_AVAIL=$(jq -r '.semantic_tools.available.graph_code' "$APEX_DIR/state/apex-state.json")

if [[ "$GREPAI_AVAIL" == "true" && "$GRAPHCODE_AVAIL" == "true" ]]; then
    jq '.semantic_tools.fallback_mode = "none"' "$APEX_DIR/state/apex-state.json" > "$APEX_DIR/state/apex-state.json.tmp"
elif [[ "$GREPAI_AVAIL" == "true" || "$GRAPHCODE_AVAIL" == "true" ]]; then
    jq '.semantic_tools.fallback_mode = "partial"' "$APEX_DIR/state/apex-state.json" > "$APEX_DIR/state/apex-state.json.tmp"
else
    jq '.semantic_tools.fallback_mode = "full"' "$APEX_DIR/state/apex-state.json" > "$APEX_DIR/state/apex-state.json.tmp"
fi
mv "$APEX_DIR/state/apex-state.json.tmp" "$APEX_DIR/state/apex-state.json" 2>/dev/null || true

# Create MCP configuration templates
echo -e "${BLUE}[5/7]${NC} Creating MCP configuration templates..."

# Copy the complete MCP settings template from repo (includes OLLAMA_MODEL etc.)
if [[ -f "$SCRIPT_DIR/mcp/settings.json.template" ]]; then
    cp "$SCRIPT_DIR/mcp/settings.json.template" "$MCP_DIR/settings.json.template"
else
    # Fallback: create minimal template if repo file missing
    cat > "$MCP_DIR/settings.json.template" << 'EOF'
{
  "mcpServers": {
    "grepai": {
      "command": "grepai",
      "args": ["mcp-serve"],
      "env": {
        "OLLAMA_HOST": "http://localhost:11434",
        "OLLAMA_MODEL": "nomic-embed-text"
      }
    },
    "graph-code": {
      "command": "python",
      "args": ["-m", "code_graph_rag.mcp_server"],
      "cwd": "~/.claude/apex/integrations/graph-code/src",
      "env": {
        "MEMGRAPH_HOST": "localhost",
        "MEMGRAPH_PORT": "7687"
      }
    }
  }
}
EOF
fi

echo -e "${GREEN}✓ MCP templates created at $MCP_DIR${NC}"

# Configure hooks
echo -e "${BLUE}[6/7]${NC} Configuring hooks..."

if [[ -f "$SETTINGS_FILE" ]]; then
    if grep -q "apex-circuit-breaker" "$SETTINGS_FILE" 2>/dev/null; then
        echo -e "${YELLOW}Hooks already configured in settings.json${NC}"
    else
        echo -e "${YELLOW}Add APEX hooks to your settings.json:${NC}"
        echo ""
        cat << 'EOF'
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "",
      "hooks": [{"type": "command", "command": "~/.claude/apex/hooks/apex-circuit-breaker.sh"}]
    }],
    "PostToolUse": [{
      "matcher": "",
      "hooks": [{"type": "command", "command": "~/.claude/apex/hooks/apex-metrics.sh"}]
    }],
    "Stop": [{
      "matcher": "",
      "hooks": [{"type": "command", "command": "~/.claude/apex/hooks/apex-session.sh"}]
    }]
  }
}
EOF
    fi
else
    echo -e "${YELLOW}settings.json not found at $SETTINGS_FILE${NC}"
fi

# Configure CLAUDE.md
echo -e "${BLUE}[7/7]${NC} Configure CLAUDE.md import..."

if [[ -f "$CLAUDE_MD" ]]; then
    if grep -q "@apex/APEX.md" "$CLAUDE_MD" 2>/dev/null; then
        echo -e "${GREEN}✓ APEX already imported in CLAUDE.md${NC}"
    else
        read -p "Add APEX import to CLAUDE.md? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "" >> "$CLAUDE_MD"
            echo "# APEX: Autonomous Planning & EXecution v4.0" >> "$CLAUDE_MD"
            echo "@apex/APEX.md" >> "$CLAUDE_MD"
            echo "" >> "$CLAUDE_MD"
            echo "# APEX Semantic Skill" >> "$CLAUDE_MD"
            echo "@apex/skills/apex-semantic.md" >> "$CLAUDE_MD"
            echo -e "${GREEN}✓ Added APEX import to CLAUDE.md${NC}"
        fi
    fi
else
    echo -e "${YELLOW}CLAUDE.md not found at $CLAUDE_MD${NC}"
    echo "Create one and add: @apex/APEX.md"
fi

# Summary
echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}APEX v4.0 installation complete!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

# Show status
echo -e "${CYAN}Installed Components:${NC}"
echo -e "  Core APEX:     ${GREEN}✓${NC}"
GREPAI_STATUS=$(jq -r '.semantic_tools.available.grepai' "$APEX_DIR/state/apex-state.json")
GRAPHCODE_STATUS=$(jq -r '.semantic_tools.available.graph_code' "$APEX_DIR/state/apex-state.json")
FALLBACK=$(jq -r '.semantic_tools.fallback_mode' "$APEX_DIR/state/apex-state.json")

if [[ "$GREPAI_STATUS" == "true" ]]; then
    echo -e "  grepai:        ${GREEN}✓${NC}"
else
    echo -e "  grepai:        ${YELLOW}○ (using fallback)${NC}"
fi

if [[ "$GRAPHCODE_STATUS" == "true" ]]; then
    echo -e "  graph-code:    ${GREEN}✓${NC}"
else
    echo -e "  graph-code:    ${YELLOW}○ (using fallback)${NC}"
fi

echo ""
echo -e "${CYAN}Fallback Mode:${NC} $FALLBACK"
echo ""
echo "Usage:"
echo "  /apex/yolo [task]       Full autonomous run with semantic intelligence"
echo "  /apex/yolo --docs       Auto-generate documentation after completion"
echo "  /apex/docs              Generate documentation for current project"
echo "  /apex/discover          Requirements elicitation"
echo "  /apex/plan              Create workflow files"
echo "  /apex/task              Decompose into todos"
echo "  /apex/execute           Implement with safety"
echo "  /apex/review            Validate quality"
echo "  /apex/commit            Git workflow"
echo ""
echo "Files installed to: $APEX_DIR"
echo ""

# Optional: Start services
if [[ "$GREPAI_STATUS" == "true" || "$GRAPHCODE_STATUS" == "true" ]]; then
    echo -e "${CYAN}To start semantic services:${NC}"
    if [[ "$GREPAI_STATUS" == "true" ]]; then
        echo "  ollama serve  # Required for grepai"
    fi
    if [[ "$GRAPHCODE_STATUS" == "true" ]]; then
        echo "  docker run -d -p 7687:7687 memgraph/memgraph-platform  # Required for graph-code"
    fi
    echo ""
fi
