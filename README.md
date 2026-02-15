# APEX: Autonomous Planning & EXecution v4.0

> Unified development workflow for Claude Code with semantic intelligence, context efficiency, Theory of Mind, persistent planning, structured lifecycle, execution safety, and auto-documentation.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-4.0.1-blue.svg)](https://github.com/sorcerai/apex-mode)

APEX v4.0 combines eight complementary systems into one cohesive Claude Code enhancement:

| System | Source | Contribution |
|--------|--------|-------------|
| **PRISM** | Methodology | 3-layer knowledge architecture |
| **Planning with Files** | [OthmanAdi](https://github.com/OthmanAdi/planning-with-files) | Persistent workflow state |
| **AIDD** | [paralleldrive](https://github.com/paralleldrive/aidd) | Structured development lifecycle |
| **Ralph** | [frankbria](https://github.com/frankbria/ralph-claude-code) | Circuit breaker safety + iterative loops |
| **grepai** | [yoanbernabeu](https://github.com/yoanbernabeu/grepai) | Semantic code search + call graph tracing |
| **Graph-Code** | [vitali87](https://github.com/vitali87/code-graph-rag) | Knowledge graph RAG + surgical editing |
| **Navigator** | [alekspetrov](https://github.com/alekspetrov/navigator) | Context efficiency + Theory of Mind |
| **Pilot** | [alekspetrov](https://github.com/alekspetrov/pilot) | Autonomous ticket-driven dev pipeline |

---

## Quick Start

```bash
# Install (core only)
curl -fsSL https://raw.githubusercontent.com/sorcerai/apex-mode/main/install.sh | bash

# Install with all semantic tools
./install.sh --all

# Or clone manually
git clone https://github.com/sorcerai/apex-mode.git
cd apex-mode && ./install.sh
```

Then in Claude Code:

```bash
# Semantic-powered autonomous mode
/apex/yolo Build a REST API for user management

# With auto-documentation
/apex/yolo "Add auth system" --docs

# Ralph loop mode (iterates until done)
/apex/yolo "Implement full auth" --until --max-iterations 10

# Or step-by-step
/apex/discover   # Understand requirements (+ semantic search)
/apex/plan       # Create workflow files (+ dependency analysis)
/apex/task       # Decompose into todos (+ call graph)
/apex/execute    # Implement with safety (+ surgical editing)
/apex/simplify   # Auto-simplify complex code (NEW)
/apex/review     # Validate quality (+ graph verification)
/apex/commit     # Git workflow
/apex/docs       # Generate documentation

# New v4.0 commands
/apex/profile    # View/update user preferences
/apex/simplify   # Simplify recently modified code

# Recovery commands
/apex/resume     # Continue after breaker trip
/apex/status     # View current state
/apex/help       # Quick reference
```

---

## What's New in v4.0

### 📦 Context Efficiency (92% Token Savings)
Strategic lazy loading for longer sessions:
- Start with ~6k tokens (vs 150k bulk loading)
- Load docs on-demand, unload when done
- Track token budget in state
- Sessions last 10x longer

### 🧠 Theory of Mind
Remember how you work:
- User profile stores preferences (verbosity, patterns, frameworks)
- Collaboration drift detection (repeated corrections → recalibrate)
- Verification checkpoints for high-stakes changes

### 🔄 Enhanced Loop Mode
Structured completion with dual-exit:
```
APEX_STATUS
==================================================
Phase: VERIFY
Iteration: 3/10
Progress: 75%

Completion Indicators:
  [x] Code implemented
  [x] Tests passing
  [ ] Documentation updated

Exit Conditions:
  Heuristics: 2/4 (need 2+)
  EXIT_SIGNAL: false

Stagnation: 0/3 (safe)
==================================================
```

### 🧹 Code Simplification
Auto-clean before commit:
- Flatten nested ternaries
- Extract deep nesting to helpers
- Use early returns
- Rename unclear variables
- Remove redundant boolean comparisons

---

## What's New in v3.0 (Retained)

### 🧠 Semantic Intelligence
Natural language code understanding powered by:
- **grepai**: "Find authentication logic" → relevant code chunks
- **Graph-Code**: "What functions call the database?" → precise answers

### 📖 Documentation Builder
Auto-generate documentation after implementation:
```bash
/apex/docs              # Generate README for current project
/apex/docs --api        # Generate API documentation
/apex/docs --all        # Generate all documentation types
/apex/yolo "task" --docs # Auto-docs after completion
```

### 🔍 Call Graph Tracing
Understand code relationships:
```bash
# Who calls this function?
grepai trace callers "UserService.authenticate"

# What does this function call?
grepai trace callees "handleLogin"

# Full dependency graph
grepai trace graph "AuthController" --depth 3
```

### ✂️ Surgical Editing
Precise code modifications without collateral damage:
- Replace function bodies by qualified name
- Update class methods without affecting others
- Maintain AST integrity

---

## Features

### 🚀 YOLO Mode
Full autonomous execution with semantic intelligence and circuit breakers.

```bash
/apex/yolo Add authentication to the app
/apex/yolo --safe Add payment processing     # Tighter limits
/apex/yolo --fast Refactor the codebase      # Looser limits
/apex/yolo --pr Fix the login bug            # Auto-create PR
/apex/yolo --docs Add user management        # Auto-generate docs
```

### 🔄 Ralph Loop Mode
For complex tasks that need multiple iterations:

```bash
/apex/yolo "Implement full auth system" --until --max-iterations 10
```

### 🛡️ Circuit Breakers
Two-tier counter system prevents runaway loops:

| Counter | Scope | Purpose |
|---------|-------|---------|
| **Soft** | Per-iteration | Warn/pause within execution |
| **Hard** | Entire cycle | Absolute resource limit |

#### Limit Values

| Breaker | Default | Safe | Fast |
|---------|---------|------|------|
| Tool calls (soft) | 50 | 25 | 100 |
| Tool calls (hard) | 200 | 100 | 400 |
| Errors (soft) | 5 | 3 | 10 |
| Errors (hard) | 15 | 10 | 30 |
| Same-file edits | 10 | 5 | 20 |
| Stuck loop | 3 patterns | 2 | 5 |

### 📁 Persistent Planning Files
Survives context resets:

```
your-project/
├── task_plan.md    # Roadmap with phases
├── notes.md        # Session context and decisions
├── deliverable.md  # Outputs and validation
└── PROMPT.md       # (Ralph mode) Invariant task definition
```

### 🔄 Structured Lifecycle (AIDD)

```
DISCOVER → PLAN → TASK → EXECUTE → SIMPLIFY → REVIEW → COMMIT → DOCS
    │                                                            │
    └───────────────────── or just ─────────────────────────────┘
                          /apex/yolo
```

---

## Installation

### Automatic (Recommended)

```bash
# Core installation
curl -fsSL https://raw.githubusercontent.com/sorcerai/apex-mode/main/install.sh | bash

# With semantic tools
./install.sh --all
```

### Installation Options

| Flag | Effect |
|------|--------|
| `--grepai` | Install grepai (semantic search) |
| `--graph-code` | Install graph-code (knowledge graph) |
| `--all` | Install all optional components |
| `--skip-optional` | Skip all optional prompts |

### Prerequisites

**Required:**
- [Claude Code](https://claude.ai/code) CLI
- Bash shell
- `jq` (for circuit breaker hooks)

**Optional (for semantic intelligence):**
- [Ollama](https://ollama.ai/download) (for grepai)
- [Docker](https://docs.docker.com/get-docker/) (for graph-code Memgraph)

### Hooks Integration

Add to `~/.claude/settings.json`:

```json
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
```

### MCP Server Configuration

For semantic tools, add to your MCP settings:

```json
{
  "mcpServers": {
    "grepai": {
      "command": "grepai",
      "args": ["mcp-serve"]
    },
    "graph-code": {
      "command": "python",
      "args": ["-m", "code_graph_rag.mcp_server"]
    }
  }
}
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/apex/yolo [task]` | Full autonomous run with semantic intelligence |
| `/apex/yolo [task] --until` | Ralph loop mode with enhanced exit |
| `/apex/discover` | Requirements elicitation |
| `/apex/plan` | Create workflow files |
| `/apex/task` | Decompose into todos |
| `/apex/execute` | Implement with safety |
| `/apex/simplify` | Auto-simplify complex code (NEW) |
| `/apex/review` | Validate quality |
| `/apex/commit` | Git workflow |
| `/apex/docs` | Generate documentation |
| `/apex/profile` | View/update user preferences (NEW) |
| `/apex/resume` | Continue after breaker trip |
| `/apex/status` | Show current state |
| `/apex/help` | Quick reference |

### YOLO Flags

| Flag | Effect |
|------|--------|
| `--safe` | Tighter circuit breaker limits |
| `--fast` | Looser circuit breaker limits |
| `--until` | Enable Ralph loop (requires --max-iterations) |
| `--max-iterations N` | Max loop iterations before timeout |
| `--no-commit` | Stop before commit phase |
| `--no-simplify` | Skip code simplification (NEW) |
| `--no-profile` | Ignore user preferences (NEW) |
| `--pr` | Create PR after commit |
| `--docs` | Generate documentation after completion |

---

## File Structure

```
~/.claude/apex/
├── APEX.md                 # Main entry point (Layer 1)
├── APEX_OPERATIONAL.md     # Procedures (Layer 2)
├── APEX_REFERENCE.md       # Deep docs (Layer 3)
├── commands/
│   ├── yolo.md             # Full autonomous mode
│   ├── discover.md         # Requirements phase
│   ├── plan.md             # Planning phase
│   ├── task.md             # Task decomposition
│   ├── execute.md          # Implementation
│   ├── simplify.md         # Code simplification (NEW)
│   ├── review.md           # Validation
│   ├── commit.md           # Git workflow
│   ├── docs.md             # Documentation builder
│   ├── profile.md          # User preferences
│   ├── resume.md           # Circuit breaker reset
│   ├── status.md           # Session state display
│   └── help.md             # Command quick reference
├── hooks/
│   ├── apex-circuit-breaker.sh   # Pre-execution check
│   ├── apex-metrics.sh           # Post-execution tracking (v4.0)
│   └── apex-session.sh           # Session persistence
├── integrations/
│   ├── grepai/             # Semantic search integration
│   └── graph-code/         # Knowledge graph integration
├── mcp/
│   ├── settings.json.template    # Full MCP config
│   ├── grepai.json               # grepai-only config
│   └── graph-code.json           # graph-code-only config
├── skills/
│   ├── apex-semantic.md    # Claude Code skill
│   ├── apex-context.md     # Context efficiency (NEW)
│   └── apex-profile.md     # Theory of Mind (NEW)
├── state/
│   ├── apex-state.json     # Circuit breaker + v4.0 state
│   └── apex-profile.json   # User preferences (NEW)
├── templates/
│   ├── task_plan.md        # Planning template
│   ├── notes.md            # Notes template
│   ├── deliverable.md      # Deliverables template
│   └── docs/               # Documentation templates
│       ├── readme.md.template
│       ├── api-module.md.template
│       ├── api-function.md.template
│       ├── architecture.md.template
│       ├── changelog.md.template
│       └── contributing.md.template
└── VERSION.md              # Version tracking
```

---

## Graceful Degradation

APEX v4.0 works even without all features configured:

| Features Available | Behavior |
|-------------------|----------|
| All (semantic + context + ToM) | Full v4.0 intelligence |
| Semantic only (grepai + Graph-Code) | v3.0 behavior |
| Context efficiency only | Token-efficient sessions |
| None | Standard APEX v2.0 behavior (grep + manual editing) |

Check your current status:
```bash
/apex/status
```

---

## Philosophy

> **Ralph**: "Don't give up. Keep iterating until done."
> **APEX**: "Don't thrash. Pause when stuck."
> **v3.0**: "Understand before acting. Document when done."
> **v4.0**: "Load what you need. Remember how you work."

APEX v4.0 adds efficiency and personalization:
- **CONTEXT**: Load 6k tokens, not 150k
- **PROFILE**: Remember your preferences
- **SIMPLIFY**: Leave code cleaner than you found it
- **LOOP**: Exit when done, not when stuck
- **DISCOVER**: Search existing code by intent
- **EXECUTE**: Edit surgically, verify relationships
- **DOCS**: Auto-generate from semantic understanding

**Autonomy with understanding, efficiency, and personalization.**

---

## Upstream Sources

APEX unifies:

- **[PRISM](https://example.com)** - Knowledge architecture methodology
- **[Planning with Files](https://github.com/OthmanAdi/planning-with-files)** - Persistent workflow pattern
- **[AIDD](https://github.com/paralleldrive/aidd)** - AI-Driven Development lifecycle
- **[Ralph](https://github.com/frankbria/ralph-claude-code)** - Iterative loop system with circuit breakers
- **[grepai](https://github.com/yoanbernabeu/grepai)** - Semantic code search + call graph tracing
- **[code-graph-rag](https://github.com/vitali87/code-graph-rag)** - Knowledge graph RAG
- **[Navigator](https://github.com/alekspetrov/navigator)** - Context efficiency + Theory of Mind
- **[Pilot](https://github.com/alekspetrov/pilot)** - Autonomous ticket-driven dev pipeline

### Updating

```bash
# Check all upstream sources for updates
~/.claude/apex/update-apex.sh all

# Update specific component
~/.claude/apex/update-apex.sh aidd
~/.claude/apex/update-apex.sh navigator
~/.claude/apex/update-apex.sh grepai

# Available: prism, planning, aidd, ralph, grepai, graph-code, navigator, pilot
```

---

## Changelog

### v4.0.1
- **Fix**: Hook-to-state schema mismatch - metrics/session hooks now use correct `iteration_current`/`cycle_current` fields (session end was silently reporting 0 tool calls)
- **Fix**: Semantic tools schema mismatch - installer and circuit breaker now use correct nested `available.grepai` path (tool detection was silently broken)
- **Fix**: Test fixtures updated from v3 to v4 schema (tests now validate actual behavior)
- **Fix**: All version strings updated from v3.0/v1.0.0 to v4.0
- **Fix**: Installer now copies repo's MCP settings template (includes `OLLAMA_MODEL`)
- **Fix**: APEX.md table syntax error corrected
- **New Commands**: `/apex/profile`, `/apex/resume`, `/apex/status`, `/apex/help`
- **New Templates**: 6 documentation templates in `templates/docs/`
- **Updated**: `update-apex.sh` now covers all 8 upstream sources (added grepai, graph-code, navigator, pilot)
- **Updated**: Test suite expanded from 42 to 48 tests
- **Upstream**: Added Pilot (alekspetrov/pilot) as tracked upstream source

### v4.0.0
- **Context Efficiency**: 92% token savings via lazy loading
- **Theory of Mind**: User profile + collaboration drift detection
- **Enhanced Loop Mode**: APEX_STATUS blocks, dual-exit, stagnation detection
- **Code Simplification**: Auto-simplify before commit
- **New Commands**: `/apex/simplify`, `/apex/profile`
- **New Flags**: `--no-simplify`, `--no-profile`
- **Extended State**: v4.0 schema with context budget, loop mode, ToM fields

### v3.0.0
- **Semantic Intelligence**: grepai + Graph-Code integration
- **Documentation Builder**: Auto-generate README, API, Architecture docs
- **Enhanced YOLO**: Full tool orchestration with semantic search
- **MCP Templates**: Pre-configured server settings
- **Graceful Degradation**: Works without semantic tools

### v2.0.0
- **Ralph Loop Mode**: `--until` flag for iterative execution
- **Two-tier counters**: Soft (per-iteration) and hard (per-cycle) limits
- **New commands**: `/apex/resume`, `/apex/status`, `/apex/help`

### v1.0.0
- Initial release with PRISM, Planning with Files, AIDD, and basic Ralph safety

---

## License

MIT License - see [LICENSE](LICENSE)

---

## Contributing

1. Fork the repo
2. Create a feature branch
3. Submit a PR

Issues and suggestions welcome!
