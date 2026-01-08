# APEX: Autonomous Planning & EXecution

> Unified development workflow for Claude Code with persistent planning, structured lifecycle, and execution safety.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

APEX combines four complementary systems into one cohesive Claude Code enhancement:

| System | Contribution |
|--------|-------------|
| **PRISM** | 3-layer knowledge architecture |
| **Planning with Files** | Persistent workflow state |
| **AIDD** | Structured development lifecycle |
| **Ralph** | Circuit breaker safety |

---

## Quick Start

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/sorcerai/apex-mode/main/install.sh | bash

# Or clone manually
git clone https://github.com/sorcerai/apex-mode.git
cd apex-mode && ./install.sh
```

Then in Claude Code:

```bash
# Full autonomous mode (recommended)
/apex/yolo Build a REST API for user management

# Or step-by-step
/apex/discover   # Understand requirements
/apex/plan       # Create workflow files
/apex/task       # Decompose into todos
/apex/execute    # Implement with safety
/apex/review     # Validate quality
/apex/commit     # Git workflow
```

---

## Features

### 🚀 YOLO Mode
Full autonomous execution with circuit breakers as your only guardrails.

```bash
/apex/yolo Add authentication to the app
/apex/yolo --safe Add payment processing     # Tighter limits
/apex/yolo --fast Refactor the codebase      # Looser limits
/apex/yolo --pr Fix the login bug            # Auto-create PR
```

### 🛡️ Circuit Breakers (Ralph)
Prevent runaway loops and wasted effort:

| Breaker | Default | Safe | Fast |
|---------|---------|------|------|
| Tool calls | 50 | 25 | 100 |
| Errors | 5 | 3 | 10 |
| Same-file edits | 10 | 5 | 20 |
| Stuck loop | 3 patterns | 2 | 5 |

When limits hit → Claude pauses and asks you what to do.

### 📁 Persistent Planning Files
Survives context resets:

```
your-project/
├── task_plan.md    # Roadmap with phases
├── notes.md        # Session context and decisions
└── deliverable.md  # Outputs and validation
```

Close Claude, reopen later → picks up exactly where you left off.

### 🔄 Structured Lifecycle (AIDD)

```
DISCOVER → PLAN → TASK → EXECUTE → REVIEW → COMMIT
    │                                           │
    └─────────────── or just ──────────────────┘
                    /apex/yolo
```

---

## Installation

### Automatic (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/sorcerai/apex-mode/main/install.sh | bash
```

This will:
1. Copy APEX files to `~/.claude/apex/`
2. Add hooks to your `settings.json`
3. Optionally add import to your `CLAUDE.md`

### Manual

```bash
# Clone
git clone https://github.com/sorcerai/apex-mode.git

# Copy to Claude config
cp -r apex-mode/* ~/.claude/apex/

# Add to your CLAUDE.md
echo '@apex/APEX.md' >> ~/.claude/CLAUDE.md
```

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

---

## Commands

| Command | Description |
|---------|-------------|
| `/apex/yolo [task]` | Full autonomous run |
| `/apex/discover` | Requirements elicitation |
| `/apex/plan` | Create workflow files |
| `/apex/task` | Decompose into todos |
| `/apex/execute` | Implement with safety |
| `/apex/review` | Validate quality |
| `/apex/commit` | Git workflow |

### YOLO Flags

| Flag | Effect |
|------|--------|
| `--safe` | Tighter circuit breaker limits |
| `--fast` | Looser circuit breaker limits |
| `--no-commit` | Stop before commit phase |
| `--pr` | Create PR after commit |

---

## File Structure

```
~/.claude/apex/
├── APEX.md                 # Main entry point (Layer 1)
├── APEX_OPERATIONAL.md     # Procedures (Layer 2)
├── APEX_REFERENCE.md       # Deep docs (Layer 3)
├── commands/
│   ├── yolo.md            # Full autonomous mode
│   ├── discover.md        # Requirements phase
│   ├── plan.md            # Planning phase
│   ├── task.md            # Task decomposition
│   ├── execute.md         # Implementation
│   ├── review.md          # Validation
│   └── commit.md          # Git workflow
├── hooks/
│   ├── apex-circuit-breaker.sh  # Pre-execution check
│   ├── apex-metrics.sh          # Post-execution tracking
│   └── apex-session.sh          # Session persistence
├── state/
│   └── apex-state.json    # Circuit breaker state
├── templates/
│   ├── task_plan.md       # Planning template
│   ├── notes.md           # Notes template
│   └── deliverable.md     # Deliverables template
├── update-apex.sh         # Update from upstream
└── VERSION.md             # Version tracking
```

---

## Upstream Sources

APEX unifies:

- **[PRISM](https://example.com)** - Knowledge architecture methodology
- **[Planning with Files](https://github.com/OthmanAdi/planning-with-files)** - Persistent workflow pattern
- **[AIDD](https://github.com/paralleldrive/aidd)** - AI-Driven Development lifecycle
- **[Ralph](https://github.com/frankbria/ralph-claude-code)** - Execution safety mechanisms

### Updating

```bash
# Check for upstream changes
~/.claude/apex/update-apex.sh all

# Update specific component
~/.claude/apex/update-apex.sh aidd
```

---

## Philosophy

> "YOLO mode is autonomous, not reckless."

The circuit breakers exist because autonomous agents can:
- Get stuck in loops
- Make the same mistake repeatedly
- Burn through resources without progress

APEX trusts the breakers to catch these issues. When they trip, a human decides whether to continue or course-correct.

**Autonomy with guardrails.**

---

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- Bash shell
- `jq` (for circuit breaker hooks)

---

## License

MIT License - see [LICENSE](LICENSE)

---

## Contributing

1. Fork the repo
2. Create a feature branch
3. Submit a PR

Issues and suggestions welcome!
