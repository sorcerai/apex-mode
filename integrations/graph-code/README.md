# Graph-Code Integration for APEX

Integration layer for knowledge graph RAG and surgical code editing.

## Overview

Graph-Code (code-graph-rag) provides:
- **Knowledge Graph**: Memgraph-backed codebase structure
- **Natural Language Query**: English → Cypher → Results
- **Surgical Editing**: AST-based precise code modifications
- **MCP Server**: Native Claude Code integration

## Setup

### 1. Prerequisites

```bash
# Required tools
brew install cmake ripgrep  # macOS
# or: sudo apt install cmake ripgrep  # Linux

# Docker for Memgraph
docker --version
```

### 2. Install Graph-Code

```bash
git clone https://github.com/vitali87/code-graph-rag.git
cd code-graph-rag

# Install with full language support
uv sync --extra treesitter-full

# Set up environment
cp .env.example .env
# Edit .env with your config (see below)

# Start Memgraph
docker-compose up -d
```

### 3. Configure LLM Provider

In `.env`:

```bash
# Option 1: Ollama (local, private)
ORCHESTRATOR_PROVIDER=ollama
ORCHESTRATOR_MODEL=llama3.2
CYPHER_PROVIDER=ollama
CYPHER_MODEL=codellama

# Option 2: OpenAI
ORCHESTRATOR_PROVIDER=openai
ORCHESTRATOR_MODEL=gpt-4o
CYPHER_PROVIDER=openai
CYPHER_MODEL=gpt-4o-mini
CYPHER_API_KEY=sk-your-key

# Option 3: Google
ORCHESTRATOR_PROVIDER=google
ORCHESTRATOR_MODEL=gemini-2.5-pro
CYPHER_PROVIDER=google
CYPHER_MODEL=gemini-2.5-flash
CYPHER_API_KEY=your-google-key
```

### 4. Add MCP Server

```bash
claude mcp add --transport stdio graph-code \
  --env TARGET_REPO_PATH=/path/to/your/project \
  --env CYPHER_PROVIDER=ollama \
  --env CYPHER_MODEL=codellama \
  -- uv run --directory /path/to/code-graph-rag graph-code mcp-server
```

## MCP Tools

| Tool | Description |
|------|-------------|
| `list_projects` | List indexed projects |
| `delete_project` | Remove project from graph |
| `wipe_database` | Clear entire database |
| `index_repository` | Build/rebuild knowledge graph |
| `query_code_graph` | Natural language queries |
| `get_code_snippet` | Get source by qualified name |
| `surgical_replace_code` | Precise code modifications |
| `read_file` | Read file contents |
| `write_file` | Write file contents |
| `list_directory` | List directory contents |

## CLI Usage

### Index Repository

```bash
# First time (clean start)
cgr start --repo-path /path/to/repo --update-graph --clean

# Update existing
cgr start --repo-path /path/to/repo --update-graph
```

### Interactive Query

```bash
cgr start --repo-path /path/to/repo
```

Then ask questions:
- "Show me all classes that contain 'user' in their name"
- "Find functions related to database operations"
- "What methods does the User class have?"
- "Show me functions that handle authentication"

### Real-Time Updates

```bash
# In separate terminal
make watch REPO_PATH=/path/to/repo
```

### Export Graph

```bash
cgr export -o my_graph.json
```

## APEX Integration Points

### DISCOVER Phase

```bash
# Understand architecture
query_code_graph "What are the main modules and their purposes?"
query_code_graph "What are the external dependencies?"

# Find patterns
query_code_graph "Show me authentication-related code"
```

### PLAN Phase

```bash
# Analyze impact
query_code_graph "What functions call UserService?"
query_code_graph "Show module dependencies"

# Find similar implementations
query_code_graph "Find classes that implement Repository interface"
```

### EXECUTE Phase

```bash
# Surgical editing via MCP
surgical_replace_code(
    file_path="src/auth/handler.go",
    target_code="func Login(...) { ... }",
    replacement_code="func Login(...) { /* new implementation */ }"
)

# Get code for modification
get_code_snippet("UserService.createUser")
```

### REVIEW Phase

```bash
# Verify changes
query_code_graph "What functions were modified?"
query_code_graph "Check call relationships of modified functions"

# Impact analysis
query_code_graph "What depends on the changed code?"
```

### DOCS Phase

```bash
# Extract documentation
query_code_graph "List all public functions with their parameters"
query_code_graph "Show class hierarchies"
query_code_graph "What are the main API endpoints?"
```

## Graph Schema

### Node Types

| Label | Properties |
|-------|------------|
| Project | `{name}` |
| Package | `{qualified_name, name, path}` |
| Module | `{qualified_name, name, path}` |
| Class | `{qualified_name, name, decorators}` |
| Function | `{qualified_name, name, decorators}` |
| Method | `{qualified_name, name, decorators}` |
| Interface | `{qualified_name, name}` |
| ExternalPackage | `{name, version_spec}` |

### Relationships

| Source | Relationship | Target |
|--------|--------------|--------|
| Module | DEFINES | Class, Function |
| Class | DEFINES_METHOD | Method |
| Module | IMPORTS | Module |
| Class | INHERITS | Class |
| Class | IMPLEMENTS | Interface |
| Function | CALLS | Function |

## Supported Languages

| Language | Extensions | Status |
|----------|------------|--------|
| Python | .py | Fully Supported |
| TypeScript | .ts, .tsx | Fully Supported |
| JavaScript | .js, .jsx | Fully Supported |
| Go | .go | In Development |
| Rust | .rs | Fully Supported |
| Java | .java | Fully Supported |
| C++ | .cpp, .h, .hpp | Fully Supported |

## Troubleshooting

### Memgraph not connecting

```bash
# Check Docker
docker-compose ps
docker-compose logs memgraph

# Restart
docker-compose down && docker-compose up -d
```

### Index empty

```bash
# Check files are being parsed
cgr start --repo-path . --update-graph --clean

# View in Memgraph Lab
open http://localhost:3000
```

### MCP errors

```bash
# Test MCP server directly
uv run --directory /path/to/code-graph-rag graph-code mcp-server

# Check environment
echo $TARGET_REPO_PATH
```

### Ollama issues

```bash
# Check Ollama running
ollama list

# Pull required models
ollama pull llama3.2
ollama pull codellama
```
