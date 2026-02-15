# grepai Integration for APEX

Integration layer for semantic code search and call graph tracing.

## Overview

grepai provides semantic understanding of your codebase:
- **Semantic Search**: Find code by intent, not keywords
- **Call Graph**: Trace function relationships
- **MCP Server**: Native tool integration

## Setup

### 1. Install grepai

```bash
curl -sSL https://raw.githubusercontent.com/yoanbernabeu/grepai/main/install.sh | sh
```

### 2. Initialize in Project

```bash
cd your-project
grepai init
grepai watch --background
```

### 3. Add MCP Server

```bash
claude mcp add grepai -- grepai mcp-serve
```

Or manually in `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "grepai": {
      "command": "grepai",
      "args": ["mcp-serve"]
    }
  }
}
```

## MCP Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `grepai_search` | Semantic code search | `query`, `limit` (default: 10) |
| `grepai_trace_callers` | Find function callers | `symbol` |
| `grepai_trace_callees` | Find function callees | `symbol` |
| `grepai_trace_graph` | Build call graph | `symbol`, `depth` (default: 2) |
| `grepai_index_status` | Check index health | none |

## CLI Usage

### Semantic Search

```bash
# Find by intent (always use English)
grepai search "user authentication flow"
grepai search "error handling middleware"
grepai search "database connection management"

# JSON output for AI agents
grepai search "authentication" --json --compact

# Limit results
grepai search "error handling" -n 5
```

### Call Graph Tracing

```bash
# Who calls this function?
grepai trace callers "HandleRequest" --json

# What does this function call?
grepai trace callees "ProcessOrder" --json

# Full call graph
grepai trace graph "ValidateToken" --depth 3 --json
```

## APEX Integration Points

### DISCOVER Phase

```bash
# Find existing patterns
grepai search "similar to what user wants" --json

# Understand architecture
grepai trace graph "MainEntryPoint" --depth 4 --json
```

### PLAN Phase

```bash
# Find related implementations
grepai search "existing implementation of X" --json

# Identify dependencies
grepai trace callers "FunctionToModify" --json
```

### EXECUTE Phase

```bash
# Find code to modify
grepai search "function that handles X" --json

# Verify no side effects
grepai trace callees "ModifiedFunction" --json
```

### REVIEW Phase

```bash
# Check impact
grepai trace callers "ChangedFunction" --json

# Verify patterns followed
grepai search "similar patterns in codebase" --json
```

## Configuration

`.grepai/config.yaml`:

```yaml
embedder:
  provider: ollama
  model: nomic-embed-text
  endpoint: http://localhost:11434
  dimensions: 768

store:
  backend: gob

chunking:
  size: 512
  overlap: 50

search:
  boost:
    enabled: true

trace:
  mode: fast  # fast (regex) | precise (tree-sitter)
```

## Best Practices

### DO

```bash
# Semantic queries
grepai search "How are file chunks created and stored?"
grepai search "Vector embedding generation process"
grepai search "Configuration loading and validation"
```

### DON'T

```bash
# Too vague
grepai search "func"
grepai search "error"

# Use Grep for exact matches
grepai search "HandleRequest"  # Use: grep "HandleRequest"
```

## Troubleshooting

### Index not building

```bash
# Check Ollama is running
ollama list

# Rebuild index
grepai watch --stop
rm -rf .grepai/index.gob
grepai watch
```

### No results

```bash
# Check index status
grepai status

# Verify files are indexed
ls .grepai/
```

### MCP not connecting

```bash
# Test MCP server directly
grepai mcp-serve

# Check Claude MCP config
claude mcp list
```
