# APEX v4.0: Autonomous Planning & EXecution

**Version**: 4.0.0  
**Purpose**: Ultimate autonomous development loop with semantic intelligence, context efficiency, Theory of Mind, and enhanced loop mode

---

## What's New in v4.0

| Feature | Description |
|---------|-------------|
| **Context Efficiency** | 92% token savings via lazy loading and strategic curation |
| **Theory of Mind** | Remember user preferences, detect collaboration drift |
| **Enhanced Loop Mode** | APEX_STATUS blocks, dual-condition exit, stagnation detection |
| **Code Simplification** | Auto-simplify complex code before commit |
| **OpenTelemetry Metrics** | Real token tracking and efficiency scores |

### v3.0 Features (Retained)
| Feature | Description |
|---------|-------------|
| **grepai Integration** | Semantic code search + call graph tracing |
| **Graph-Code Integration** | Knowledge graph RAG + surgical editing |
| **Auto-Documentation** | `/apex/docs` generates comprehensive docs |
| **Circuit Breakers** | Two-tier safety system (soft/hard limits) |

---

## Quick Start

```
/apex/yolo [task]   → Full autonomous run (Ralph-style)
                      Circuit breakers are your only guardrails

/apex/swarm [task]  → Parallel execution with worker swarm
                      Decompose → Spawn workers → Monitor → Merge

# Ralph loop mode (iterates until done)
/apex/yolo "Add comprehensive auth" --until --max-iterations 10

# Generate documentation
/apex/docs --full

# View/update user preferences
/apex/profile

# Simplify recently modified code
/apex/simplify

# Step-by-step workflow
/apex/discover   # Understand requirements (uses semantic search)
/apex/plan       # Create workflow files (uses knowledge graph)
/apex/task       # Decompose into todos
/apex/execute    # Implement with safety (surgical editing)
/apex/simplify   # Auto-simplify complex code (NEW)
/apex/review     # Validate quality (graph verification)
/apex/commit     # Git workflow
/apex/docs       # Auto-generate documentation
```

### Swarm Commands (v2)
```
/apex/swarm [task]         → Parallel autonomous execution
/apex/swarm --workers=N    → Specify worker count (default: 3)
/apex/swarm --dry-run      → Show decomposition without executing
/apex/swarm continue       → Resume interrupted swarm
/apex/swarm status         → Show swarm progress
```

---

## System Architecture

### Intelligence Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                        APEX v4.0 CORE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐   │
│  │  Context   │ │  Theory    │ │  Code      │ │  Enhanced  │   │
│  │ Efficiency │ │  of Mind   │ │ Simplify   │ │  Loop Mode │   │
│  │            │ │            │ │            │ │            │   │
│  │ • Lazy     │ │ • Profile  │ │ • Flatten  │ │ • STATUS   │   │
│  │   Load     │ │ • Drift    │ │ • Extract  │ │   Blocks   │   │
│  │ • Token    │ │   Detect   │ │ • Rename   │ │ • Dual     │   │
│  │   Budget   │ │ • Verify   │ │ • Clean    │ │   Exit     │   │
│  └─────┬──────┘ └─────┬──────┘ └─────┬──────┘ └─────┬──────┘   │
│        │              │              │              │           │
│        └──────────────┼──────────────┼──────────────┘           │
│                       │              │                          │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│   │   grepai    │    │ Graph-Code  │    │   DocGen    │        │
│   │             │    │             │    │             │        │
│   │ • Semantic  │    │ • Knowledge │    │ • README    │        │
│   │   Search    │    │   Graph     │    │ • API Docs  │        │
│   │ • Call      │    │ • Surgical  │    │ • Arch Docs │        │
│   │   Graph     │    │   Editing   │    │ • Changelog │        │
│   │ • MCP       │    │ • MCP       │    │             │        │
│   └──────┬──────┘    └──────┬──────┘    └──────┬──────┘        │
│          │                  │                  │                │
│          └──────────────────┼──────────────────┘                │
│                             │                                   │
│                    ┌────────▼────────┐                          │
│                    │  APEX Workflow  │                          │
│                    │                 │                          │
│                    │ DISCOVER→PLAN→  │                          │
│                    │ TASK→EXECUTE→   │                          │
│                    │ SIMPLIFY→REVIEW→│                          │
│                    │ COMMIT→DOCS     │                          │
│                    └────────┬────────┘                          │
│                             │                                   │
│                    ┌────────▼────────┐                          │
│                    │ Circuit Breakers│                          │
│                    │ (Ralph Safety)  │                          │
│                    └─────────────────┘                          │
└─────────────────────────────────────────────────────────────────┘
```

### PRISM Knowledge Layers
1. **This file (APEX.md)**: Routing and quick reference
2. **APEX_OPERATIONAL.md**: Step-by-step procedures
3. **APEX_REFERENCE.md**: Deep documentation and edge cases

### Core Systems

| System | Purpose | Key Files |
|--------|---------|-----------|
| **PRISM** | 3-layer knowledge architecture | APEX*.md |
| **Planning** | Persistent workflow state | task_plan.md, notes.md, deliverable.md |
| **AIDD** | Development lifecycle | /apex/* commands |
| **Ralph** | Execution safety | hooks/, state/ |
| **grepai** | Semantic intelligence | integrations/grepai/ |
| **Graph-Code** | Knowledge graph + editing | integrations/graph-code/ |
| **DocGen** | Auto-documentation | commands/docs.md |
| **Context** | Token efficiency | skills/apex-context.md |
| **ToM** | User preferences | skills/apex-profile.md |
| **Simplify** | Code clarity | commands/simplify.md |

---

## Tool Integration

### grepai (Semantic Layer)

```bash
# Semantic code search - find by intent
grepai search "user authentication flow" --json --compact

# Call graph analysis
grepai trace callers "Login" --json
grepai trace callees "HandleRequest" --json
grepai trace graph "ValidateToken" --depth 3 --json
```

**When to Use**:
- Finding code by what it does, not what it's called
- Understanding function relationships
- Quick context gathering during any phase

### Graph-Code (Knowledge Layer)

```bash
# Query knowledge graph
cgr start --repo-path . 
# Then natural language: "What functions call UserService?"

# Surgical code editing
# Via MCP: surgical_replace_code tool

# Real-time graph updates
make watch REPO_PATH=.
```

**When to Use**:
- Deep architectural understanding
- Impact analysis before changes
- Precise code modifications
- Cross-module dependency analysis

### Documentation Builder

```bash
/apex/docs                    # Auto-detect what needs docs
/apex/docs --readme           # Generate/update README
/apex/docs --api              # Generate API documentation
/apex/docs --architecture     # Generate architecture docs
/apex/docs --changelog        # Generate changelog from commits
/apex/docs --full             # All documentation
```

---

## Workflow States

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  DISCOVER   │ ──▶ │    PLAN     │ ──▶ │    TASK     │
│ +Semantic   │     │ +Graph      │     │ Decompose   │
│  Search     │     │  Analysis   │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    DOCS     │ ◀── │   COMMIT    │ ◀── │   REVIEW    │
│ Auto-Gen    │     │ Git Workflow│     │ +Graph      │
│             │     │             │     │  Verify     │
└─────────────┘     └─────────────┘     └─────────────┘
                           ▲                   ▲
                           │                   │
                    ┌─────────────┐     ┌─────────────┐
                    │  SIMPLIFY   │ ◀── │   EXECUTE   │
                    │ +Flatten    │     │ +Surgical   │
                    │ +Extract    │     │  Editing    │
                    └─────────────┘     └─────────────┘
```

---

## Context Efficiency (NEW in v4.0)

### Token Budget Strategy

| Phase | Loaded | Available |
|-------|--------|-----------|
| Start | ~6k tokens | ~194k tokens |
| Working | ~30k tokens | ~170k tokens |
| Peak | ~50k tokens | ~150k tokens |

### Loading Rules

- **Always**: APEX.md, current todos, active task
- **On-demand**: Command docs, integrations
- **Just-in-time**: Source files, search results
- **Unload**: Previous phase context, completed search results

### Efficiency Score

Target: >85% (peak < 30k tokens used)

---

## Theory of Mind (NEW in v4.0)

### User Profile

Stored at `~/.claude/apex/state/apex-profile.json`:
- Communication style (concise/verbose)
- Coding preferences (patterns, frameworks)
- Workflow settings (commit style, auto-docs)

### Collaboration Quality

- Track satisfaction signals
- Detect drift (repeated corrections)
- Trigger recalibration when needed

---

## Safety System (Ralph)

### Circuit Breakers
| Metric | Default | Safe | Fast |
|--------|---------|------|------|
| Tool calls (soft) | 50 | 25 | 100 |
| Tool calls (hard) | 200 | 100 | 400 |
| Errors (soft) | 5 | 3 | 10 |
| Errors (hard) | 15 | 10 | 30 |
| Same-file edits | 10 | 5 | 20 |
| Stuck loop threshold | 3 | 2 | 5 |

### When Limits Hit
1. **Pause** execution immediately
2. **Report** current state and what triggered limit
3. **Ask** human for guidance
4. **Resume** or **abort** based on response

---

## Commands

| Command | Description |
|---------|-------------|
| `/apex/yolo [task]` | Full autonomous run with all integrations |
| `/apex/yolo [task] --until` | Ralph loop mode with enhanced exit detection |
| `/apex/discover` | Requirements + semantic search |
| `/apex/plan` | Create workflow + graph analysis |
| `/apex/task` | Decompose into todos |
| `/apex/execute` | Implement with surgical editing |
| `/apex/simplify` | Auto-simplify complex code (NEW) |
| `/apex/review` | Validate with graph verification |
| `/apex/commit` | Git workflow |
| `/apex/docs` | Auto-generate documentation |
| `/apex/profile` | View/update user preferences (NEW) |
| `/apex/resume` | Continue after breaker trip |
| `/apex/status` | Show current state |

### YOLO Flags

| Flag | Effect |
|------|--------|
| `--safe` | Tighter circuit breaker limits |
| `--fast` | Looser circuit breaker limits |
| `--until` | Enable Ralph loop |
| `--max-iterations N` | Max loop iterations |
| `--no-commit` | Stop before commit phase |
| `--no-docs` | Skip documentation generation |
| `--no-simplify` | Skip code simplification |
| `--no-profile` | Ignore user preferences |
| `--pr` | Create PR after commit |

---

## MCP Configuration

Add to your MCP settings:

```json
{
  "mcpServers": {
    "grepai": {
      "command": "grepai",
      "args": ["mcp-serve"]
    },
    "graph-code": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/code-graph-rag", "graph-code", "mcp-server"],
      "env": {
        "TARGET_REPO_PATH": "${workspaceFolder}",
        "CYPHER_PROVIDER": "ollama",
        "CYPHER_MODEL": "codellama"
      }
    }
  }
}
```

---

## File Persistence

APEX maintains files that survive context resets:

### Project Root
- `task_plan.md` - Roadmap with phases
- `notes.md` - Session context and decisions
- `deliverable.md` - Outputs and validation
- `PROMPT.md` - (Ralph mode) Invariant task definition

### State
- `~/.claude/apex/state/apex-state.json` - Circuit breakers + session

---

## Philosophy

> **Ralph**: "Don't give up. Keep iterating until done."  
> **APEX**: "Don't thrash. Pause when stuck."  
> **grepai**: "Search by meaning, not keywords."  
> **Graph-Code**: "Understand before you change."  
> **v4.0**: "Load what you need. Remember how you work."  
> **Together**: Intelligent, efficient, persistent iteration WITH safety boundaries.

**Autonomy with understanding and efficiency.**

---

## Next Steps

For detailed procedures: `@APEX_OPERATIONAL.md`  
For reference material: `@APEX_REFERENCE.md`  
For grepai integration: `@integrations/grepai/README.md`  
For Graph-Code integration: `@integrations/graph-code/README.md`
For context efficiency: `@skills/apex-context.md`
For user profiles: `@skills/apex-profile.md`
