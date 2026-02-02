---
description: "APEX YOLO Mode - Autonomous execution with circuit breaker safety"
---

# /apex/yolo

**Full autonomous execution.** Give APEX a task and let it run through the entire lifecycle with circuit breakers as the only guardrails.

## What YOLO Mode Does

```
User: "Build a REST API for user management"
         │
         ▼
    ┌─────────────────────────────────────────────┐
    │              APEX YOLO MODE                 │
    │                                             │
    │  1. DISCOVER - Infer requirements           │
    │       ↓                                     │
    │  2. PLAN - Create workflow files            │
    │       ↓                                     │
    │  3. TASK - Decompose into todos             │
    │       ↓                                     │
    │  4. EXECUTE - Implement (with breakers)     │
    │       ↓                                     │
    │  5. REVIEW - Self-validate                  │
    │       ↓                                     │
    │  6. COMMIT - Git commit (no push)           │
    │                                             │
    │  🛡️ Circuit breakers active throughout      │
    └─────────────────────────────────────────────┘
         │
         ▼
    Done! (or paused at breaker)
```

## Usage

```
/apex/yolo Build a REST API for user management

/apex/yolo --safe Add dark mode toggle to the settings page

/apex/yolo --fast Refactor the auth module to use JWT
```

## Flags

| Flag | Effect |
|------|--------|
| (none) | Default limits: 50 calls, 5 errors, 10 same-file |
| `--safe` | Tighter limits: 25 calls, 3 errors, 5 same-file |
| `--fast` | Looser limits: 100 calls, 10 errors, 20 same-file |
| `--no-commit` | Stop before commit phase |
| `--pr` | Create PR after commit |

## Circuit Breaker Behavior

YOLO mode does NOT disable safety. It just automates the workflow.

**On Warning (80% of limit)**:
```
⚠️ APEX Warning: Tool calls at 40/50
Continuing autonomously...
```

**On Limit Hit**:
```
🚨 APEX CIRCUIT BREAKER TRIPPED

Autonomous execution paused.
Tool calls: 50/50

Progress saved:
- Phase: execute
- Tasks completed: 7/12
- Files modified: 4

Options:
1. "continue" - Reset counter, resume
2. "continue --fast" - Higher limits, resume
3. "stop" - Save and exit
4. "review" - Show what's been done

What would you like to do?
```

## Execution Flow

### Phase 1: Auto-Discover
- Read project context (package.json, README, existing code)
- Infer requirements from the task description
- Generate structured requirements WITHOUT asking questions
- If critical ambiguity → pause and ask ONE clarifying question

### Phase 2: Auto-Plan
- Create task_plan.md, notes.md, deliverable.md
- Break into phases based on complexity
- Estimate S/M/L for each phase

### Phase 3: Auto-Task
- Decompose current phase into atomic todos
- Prioritize by dependency order
- Load into TodoWrite

### Phase 4: Auto-Execute
- Work through todos sequentially
- Update notes.md with discoveries
- Circuit breakers active on every tool call
- On error: retry once, then continue to next task
- On stuck loop: pause and report

### Phase 5: Auto-Review
- Self-review all changes
- Run available quality checks (lint, test, build)
- Document findings in deliverable.md
- If P0/P1 issues found → attempt auto-fix → re-review

### Phase 6: Auto-Commit
- Stage all relevant changes
- Generate conventional commit message
- Create commit (NO push unless --pr flag)
- If --pr: push and create PR

## What YOLO Mode Does NOT Do

❌ Push to remote (unless --pr)
❌ Deploy to production
❌ Delete files outside project
❌ Modify system files
❌ Bypass circuit breakers
❌ Ignore critical errors

## Example Session

```
User: /apex/yolo Add pagination to the products API

APEX: 🚀 YOLO Mode activated

📋 Auto-discovering requirements...
   - Endpoint: GET /api/products
   - Need: page, limit params
   - Return: paginated response with metadata

📁 Auto-planning...
   - Created task_plan.md (3 phases, M complexity)
   - Created notes.md
   - Created deliverable.md

📝 Auto-decomposing Phase 1...
   - 5 tasks created

⚡ Auto-executing...
   [1/5] ✅ Add pagination params to route handler
   [2/5] ✅ Update service layer for offset/limit
   [3/5] ✅ Add total count query
   [4/5] ✅ Format paginated response
   [5/5] ✅ Add pagination tests

   ⚠️ Tool calls: 42/50

🔍 Auto-reviewing...
   - Lint: ✅ Pass
   - Tests: ✅ 8/8 passing
   - No P0/P1 issues

📦 Auto-committing...
   - Commit: feat(api): add pagination to products endpoint

✅ YOLO complete!
   - 5 tasks completed
   - 4 files modified
   - 47 tool calls used
   - Commit: abc123f

Files: task_plan.md, notes.md, deliverable.md updated
```

## Recovery from Breaker Trip

If you come back to a paused YOLO session:

```
User: /apex/yolo continue

APEX: 📂 Resuming YOLO session...

Previous state:
- Task: "Add pagination to products API"
- Phase: execute (task 8/12)
- Breaker: tool_calls hit 50/50

Resuming with fresh limits (50 more calls).
```

## Safety Philosophy

> "YOLO mode is autonomous, not reckless."

The circuit breakers exist because autonomous agents can:
- Get stuck in loops
- Make the same mistake repeatedly
- Burn through resources without progress

YOLO mode trusts the breakers to catch these issues. When they trip, a human decides whether to continue or course-correct.

This is Ralph's philosophy: **"Autonomy with guardrails."**

---

## Loop Mode & EXIT_SIGNAL (v2)

YOLO mode now includes Navigator-style structured completion with dual-condition exit.

### APEX_STATUS Block

After each major phase, YOLO displays structured status:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
APEX_STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase: EXECUTE
Iteration: 3/5
Progress: 60%

Completion Indicators:
  [x] Code changes made
  [x] Tests passing
  [ ] Code reviewed
  [ ] Documentation updated

Exit Conditions:
  Heuristics: 2/4 (need 2+)
  EXIT_SIGNAL: false

State Hash: abc123def456
Stagnation: 0/3

Next Action: Continue implementation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### EXIT_SIGNAL

YOLO uses a **dual-condition exit gate** (from Navigator):

1. **Heuristics**: At least 2 completion indicators must be met
2. **EXIT_SIGNAL**: Explicit declaration that task is complete

```
# Set EXIT_SIGNAL when done:
EXIT_SIGNAL: true

# Exit decision logic:
IF heuristics >= 2 AND EXIT_SIGNAL == true:
  → EXIT: Task complete
ELIF heuristics >= 2 AND EXIT_SIGNAL == false:
  → CONTINUE: Awaiting explicit completion
ELIF EXIT_SIGNAL == true AND heuristics < 2:
  → BLOCKED: Cannot exit with insufficient indicators
ELSE:
  → CONTINUE: More work needed
```

This prevents premature exits when metrics are met but work remains.

### Completion Indicators

| Indicator | How It's Detected |
|-----------|-------------------|
| `code_changed` | Git shows modified files |
| `tests_passing` | Test command exits with code 0 |
| `code_reviewed` | Review phase completed without P0/P1 issues |
| `docs_updated` | .md files in diff |
| `committed` | Git commit created |

### Stagnation Detection (Improved)

YOLO now uses hash-based stagnation detection via `functions/stagnation_detector.py`:

- **Immediate repetition**: A→A→A (same state 3+ times)
- **Short cycles**: A→B→A→B (repeating pattern)
- **Oscillation**: A→B→A→B→A (stuck between two states)

```bash
# Check for stagnation
python functions/stagnation_detector.py check \
  --history '["abc123", "def456", "abc123", "def456"]' \
  --threshold 3

# Output:
{
  "stagnant": true,
  "pattern_type": "cycle_2",
  "pattern": ["abc123", "def456"],
  "suggestion": "Detected repeating cycle of length 2. Break the loop."
}
```

### Loop Mode Flag

```
/apex/yolo --loop Build feature X

# Enables:
# - Structured APEX_STATUS after each phase
# - EXIT_SIGNAL requirement for completion
# - Enhanced stagnation detection
# - Max iterations limit (default: 5)
```

### Knowledge Graph Integration

YOLO can leverage the knowledge graph for context:

```bash
# Query relevant knowledge before starting
python functions/graph_manager.py query "auth"

# Add learnings after completion
python functions/graph_manager.py memory \
  --type pitfall \
  --summary "Auth middleware must be added before route handlers" \
  --concepts "auth,middleware,routing"
```

Knowledge persists across sessions, helping future YOLO runs.
