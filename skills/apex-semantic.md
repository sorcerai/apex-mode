---
name: apex-semantic
description: "APEX Semantic Intelligence - Unified grepai + Graph-Code skill for deep codebase understanding. Invoke for ANY semantic search, call graph analysis, or knowledge graph queries."
---

# APEX Semantic Intelligence Skill

This skill provides unified access to semantic code intelligence via grepai and Graph-Code.

## CRITICAL: When to Invoke This Skill

Invoke this skill **IMMEDIATELY** when:

### Semantic Search (grepai)
- User asks to find code by **intent**: "where is authentication handled?"
- User asks what code **does**: "how does the indexer work?"
- User asks about **functionality**: "find error handling logic"
- You need to understand **relationships**: "what calls this function?"

### Knowledge Graph (graph-code)
- User asks about **architecture**: "what are the main modules?"
- User asks about **dependencies**: "what uses UserService?"
- User needs **impact analysis**: "what would break if I change this?"
- You need to **surgically edit** code with precision

## Tool Selection Guide

| Need | Tool | Command |
|------|------|---------|
| Find code by meaning | grepai | `grepai search "intent" --json` |
| Find callers of function | grepai | `grepai trace callers "Name" --json` |
| Find callees of function | grepai | `grepai trace callees "Name" --json` |
| Full call graph | grepai | `grepai trace graph "Name" --depth 3 --json` |
| Architecture overview | graph-code | `query_code_graph "main modules?"` |
| Class relationships | graph-code | `query_code_graph "class hierarchy?"` |
| Get source code | graph-code | `get_code_snippet "Module.func"` |
| Precise code edit | graph-code | `surgical_replace_code(...)` |
| Find exact text | grep | `grep "exactPattern"` |

## grepai Commands

### Semantic Search

```bash
# Always use English for best results
grepai search "user authentication flow" --json --compact
grepai search "error handling middleware" --json --compact
grepai search "database connection management" --json --compact

# Limit results
grepai search "error handling" -n 5 --json
```

### Call Graph Tracing

```bash
# Who calls this function?
grepai trace callers "HandleRequest" --json

# What does this function call?
grepai trace callees "ProcessOrder" --json

# Full dependency tree
grepai trace graph "ValidateToken" --depth 3 --json
```

## graph-code Commands

### Query Knowledge Graph

```bash
# Via MCP tool: query_code_graph
query_code_graph "What are the main modules and their purposes?"
query_code_graph "Show me all classes that implement Repository"
query_code_graph "What functions call UserService.create?"
query_code_graph "What are the external dependencies?"
```

### Get Code

```bash
# Via MCP tool: get_code_snippet
get_code_snippet "UserService.createUser")
get_code_snippet "AuthController.login")
```

### Surgical Editing

```bash
# Via MCP tool: surgical_replace_code
surgical_replace_code(
    file_path="src/auth/handler.go",
    target_code="func Login(ctx context.Context) error { ... }",
    replacement_code="func Login(ctx context.Context) (*Token, error) { ... }"
)
```

## APEX Phase Integration

### DISCOVER Phase

```bash
# Understand existing patterns
grepai search "similar to what user wants" --json --compact

# Get architecture overview
query_code_graph "What are the main modules?"
query_code_graph "How is authentication handled?"
```

### PLAN Phase

```bash
# Find similar implementations
grepai search "existing X implementation" --json

# Analyze dependencies
query_code_graph "What depends on ModuleToChange?"
grepai trace callers "FunctionToModify" --json
```

### EXECUTE Phase

```bash
# Find code to modify
grepai search "function that handles X" --json

# Get exact code
get_code_snippet "Module.function"

# Make precise changes
surgical_replace_code(...)

# Verify changes
grepai trace callees "ModifiedFunction" --json
```

### REVIEW Phase

```bash
# Check impact
grepai trace callers "ChangedFunction" --json
query_code_graph "What depends on changed code?"

# Verify patterns
grepai search "similar patterns for consistency" --json
```

### DOCS Phase

```bash
# Extract API info
query_code_graph "List all public functions with parameters"
grepai search "docstrings and comments" --json

# Get structure
query_code_graph "Show module hierarchy"
```

## Fallback Behavior

If grepai not available:
```bash
# Fall back to standard grep
grep -r "pattern" --include="*.ts"
```

If graph-code not available:
```bash
# Fall back to AST grep
ast-grep --pattern "function $NAME($$$)" --lang typescript
```

## Best Practices

### DO
```bash
# Semantic queries
grepai search "How are file chunks created and stored?"
grepai search "Configuration loading and validation"

# Specific graph queries
query_code_graph "What methods does UserService have?"
```

### DON'T
```bash
# Too vague
grepai search "func"
grepai search "error"

# Use grep for exact matches
grepai search "HandleRequest"  # Wrong! Use grep instead
```

## Keywords

semantic search, code search, natural language, call graph, callers, callees,
knowledge graph, cypher, memgraph, surgical edit, code understanding,
architecture, dependencies, impact analysis, grepai, graph-code, APEX
