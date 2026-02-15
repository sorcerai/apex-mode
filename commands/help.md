---
description: "APEX Help - List all available APEX commands and quick reference"
---

# /apex/help

Quick reference for all APEX commands and their usage.

---

## Commands

| Command | Description | Phase |
|---------|-------------|-------|
| `/apex/yolo [task]` | Full autonomous run with all integrations | All |
| `/apex/discover` | Requirements elicitation and codebase analysis | 1. Discover |
| `/apex/plan` | Create persistent 3-file workflow | 2. Plan |
| `/apex/task` | Decompose phases into atomic todos | 3. Task |
| `/apex/execute` | Implement tasks with safety boundaries | 4. Execute |
| `/apex/simplify` | Auto-simplify complex code | 5. Simplify |
| `/apex/review` | Validate implementation quality | 6. Review |
| `/apex/commit` | Git workflow with clean commits | 7. Commit |
| `/apex/docs` | Auto-generate project documentation | 8. Docs |
| `/apex/profile` | View/update user preferences | Utility |
| `/apex/resume` | Reset circuit breakers, continue after trip | Utility |
| `/apex/status` | Show current state and metrics | Utility |
| `/apex/help` | This help page | Utility |

---

## YOLO Mode Flags

| Flag | Effect |
|------|--------|
| `--safe` | Tighter circuit breaker limits |
| `--fast` | Looser circuit breaker limits |
| `--until` | Enable Ralph loop (iterate until done) |
| `--max-iterations N` | Max loop iterations (default: 10) |
| `--no-commit` | Stop before commit phase |
| `--no-docs` | Skip documentation generation |
| `--no-simplify` | Skip code simplification |
| `--no-profile` | Ignore user preferences |
| `--pr` | Create PR after commit |

---

## Workflow

```
/apex/discover → /apex/plan → /apex/task → /apex/execute
                                                  ↓
            /apex/docs ← /apex/commit ← /apex/review ← /apex/simplify
```

Or use `/apex/yolo [task]` to run the entire pipeline autonomously.

---

## Circuit Breaker Limits

| Metric | Default | Safe | Fast |
|--------|---------|------|------|
| Tool calls (iteration) | 50 | 25 | 100 |
| Tool calls (cycle) | 200 | 100 | 400 |
| Errors (iteration) | 5 | 3 | 10 |
| Errors (cycle) | 15 | 10 | 30 |
| Same-file edits | 10 | 5 | 20 |
| Stuck loop threshold | 3 | 2 | 5 |

---

## Files

| File | Purpose |
|------|---------|
| `task_plan.md` | Roadmap with phases (project root) |
| `notes.md` | Session context and decisions (project root) |
| `deliverable.md` | Outputs and validation (project root) |
| `~/.claude/apex/state/apex-state.json` | Circuit breakers + session state |
| `~/.claude/apex/state/apex-profile.json` | User preferences |

---

## Quick Start

```bash
# Install
git clone https://github.com/sorcerai/apex-mode.git
cd apex-mode && bash install.sh

# Full autonomous mode
/apex/yolo Build a REST API for user management

# Loop mode (iterate until done)
/apex/yolo "Add auth system" --until --max-iterations 10

# Step by step
/apex/discover
/apex/plan
/apex/task
/apex/execute
/apex/simplify
/apex/review
/apex/commit
```
