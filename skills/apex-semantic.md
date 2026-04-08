---
name: apex-semantic
description: "APEX Semantic Intelligence - Graph-Code skill for deep codebase understanding. Invoke for knowledge graph queries, architecture analysis, or surgical code edits."
---

# APEX Semantic Intelligence Skill

This skill provides access to semantic code intelligence via Graph-Code.

## CRITICAL: When to Invoke This Skill

Invoke this skill **IMMEDIATELY** when:

- User asks about **architecture**: "what are the main modules?"
- User asks about **dependencies**: "what uses UserService?"
- User needs **impact analysis**: "what would break if I change this?"
- You need to **surgically edit** code with precision

## Tool Selection Guide

| Need | Tool | Command |
|------|------|---------|
| Architecture overview | graph-code | `query_code_graph "main modules?"` |
| Class relationships | graph-code | `query_code_graph "class hierarchy?"` |
| Get source code | graph-code | `get_code_snippet "Module.func"` |
| Precise code edit | graph-code | `surgical_replace_code(...)` |
| Find exact text | grep | `grep "exactPattern"` |
| Find by pattern | Grep tool | Use Claude Code's built-in Grep |

## graph-code Commands

### Query Knowledge Graph

```bash
query_code_graph "What are the main modules and their purposes?"
query_code_graph "Show me all classes that implement Repository"
query_code_graph "What functions call UserService.create?"
query_code_graph "What are the external dependencies?"
```

### Get Code

```bash
get_code_snippet "UserService.createUser"
get_code_snippet "AuthController.login"
```

### Surgical Editing

```bash
surgical_replace_code(
    file_path="src/auth/handler.go",
    target_code="func Login(ctx context.Context) error { ... }",
    replacement_code="func Login(ctx context.Context) (*Token, error) { ... }"
)
```

## APEX Phase Integration

### DISCOVER Phase

```bash
query_code_graph "What are the main modules?"
query_code_graph "How is authentication handled?"
```

### PLAN Phase

```bash
query_code_graph "What depends on ModuleToChange?"
```

### EXECUTE Phase

```bash
get_code_snippet "Module.function"
surgical_replace_code(...)
```

### REVIEW Phase

```bash
query_code_graph "What depends on changed code?"
```

## Fallback Behavior

If graph-code not available:
```bash
# Use Claude Code built-in tools
Grep "pattern" --type ts
Glob "**/*.ts"
```

## Keywords

knowledge graph, cypher, memgraph, surgical edit, code understanding,
architecture, dependencies, impact analysis, graph-code, APEX
