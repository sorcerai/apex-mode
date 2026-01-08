# APEX: Autonomous Planning & EXecution

**Version**: 1.0.0
**Purpose**: Unified development workflow with persistent planning, structured lifecycle, and execution safety

---

## Quick Start

```
/apex/yolo [task]  → Full autonomous run (Ralph-style)
                     Circuit breakers are your only guardrails

# Or step-by-step:
/apex/discover  → Understand requirements and context
/apex/plan      → Create persistent 3-file workflow
/apex/task      → Decompose into actionable tasks
/apex/execute   → Execute with safety guardrails
/apex/review    → Validate implementation quality
/apex/commit    → Complete git workflow
```

---

## System Architecture

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

---

## Activation Triggers

### Automatic Activation
- Project initialization: "start new project", "begin development"
- Planning keywords: "plan this", "break down", "decompose"
- Safety concerns: "carefully", "don't break", "safely"
- Workflow keywords: "discover", "execute", "review", "commit"

### Manual Activation
```
/apex/[command]     # Specific phase
--apex              # Enable APEX for current task
--apex-safe         # Maximum safety (lower thresholds)
--apex-fast         # Reduced safety (higher thresholds)
```

---

## Workflow States

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  DISCOVER   │ ──▶ │    PLAN     │ ──▶ │    TASK     │
│ Requirements│     │ 3-File Setup│     │ Decompose   │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   COMMIT    │ ◀── │   REVIEW    │ ◀── │   EXECUTE   │
│ Git Workflow│     │   Validate  │     │ With Safety │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Safety System (Ralph)

### Circuit Breakers
| Metric | Default | Safe Mode | Fast Mode |
|--------|---------|-----------|-----------|
| Max tool calls/task | 50 | 25 | 100 |
| Max errors/task | 5 | 3 | 10 |
| Max same-file edits | 10 | 5 | 20 |
| Stuck loop threshold | 3 | 2 | 5 |

### When Limits Hit
1. **Pause** execution immediately
2. **Report** current state and what triggered limit
3. **Ask** human for guidance
4. **Resume** or **abort** based on response

---

## File Persistence (Planning with Files)

APEX maintains three files in project root:

### task_plan.md
- Current objective and success criteria
- Task breakdown with status
- Dependencies and blockers
- Estimated vs actual progress

### notes.md
- Discoveries during execution
- Technical decisions and rationale
- Problems encountered and solutions
- Context for future sessions

### deliverable.md
- Final outputs and artifacts
- Test results and validation
- Documentation updates
- Handoff checklist

---

## Integration

### With CLAUDE.md
```markdown
# In your CLAUDE.md or project CLAUDE.md:
@~/.claude/apex/APEX.md
```

### Standalone Usage
```bash
claude --import ~/.claude/apex/APEX.md
```

### With Hooks (Auto-enabled)
- **PreToolUse**: Circuit breaker check
- **PostToolUse**: Metrics update
- **Stop**: Session persistence

---

## Command Reference

| Command | Purpose | Input | Output |
|---------|---------|-------|--------|
| `/apex/yolo` | **Full autonomous run** | Task description | Complete implementation |
| `/apex/discover` | Requirements elicitation | Vague request | Structured requirements |
| `/apex/plan` | Create workflow files | Requirements | task_plan.md, notes.md, deliverable.md |
| `/apex/task` | Decompose into todos | task_plan.md | TodoWrite items |
| `/apex/execute` | Safe implementation | Todos | Code changes |
| `/apex/review` | Quality validation | Changes | Review report |
| `/apex/commit` | Git workflow | Validated changes | Commit + optional PR |

### YOLO Mode Flags
| Flag | Effect |
|------|--------|
| `--safe` | Tighter limits (25 calls, 3 errors) |
| `--fast` | Looser limits (100 calls, 10 errors) |
| `--no-commit` | Stop before commit |
| `--pr` | Create PR after commit |

---

## State Management

State persisted in `~/.claude/apex/state/apex-state.json`:
- Current phase and progress
- Circuit breaker counters
- Session history
- Error patterns for stuck detection

---

## Escalation Path

```
Normal execution
    │
    ▼ (limit approached)
Warning issued, continue
    │
    ▼ (limit hit)
Pause + ask human
    │
    ├──▶ Human says continue → Reset counter, proceed
    │
    └──▶ Human says stop → Save state, abort gracefully
```

---

## Next Steps

For detailed procedures: `@APEX_OPERATIONAL.md`
For reference material: `@APEX_REFERENCE.md`
