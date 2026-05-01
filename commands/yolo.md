---
description: "APEX YOLO Mode v4.0 - Full autonomous execution with context efficiency and enhanced loop mode"
---

# /apex/yolo

**Full autonomous execution with semantic intelligence, context efficiency, and enhanced loop mode.** Give APEX a task and let it run through the entire lifecycle with intelligent context management, Theory of Mind, and dual-condition exit signals.

## What YOLO v4.0 Does

```
User: "Build a REST API for user management"
         │
         ▼
    ┌─────────────────────────────────────────────────────────────┐
    │                    APEX YOLO v4.0 MODE                      │
    │                                                             │
    │  0. CONTEXT LOAD - Strategic lazy loading (NEW)            │
    │       │ + Load only APEX.md (~2k tokens)                   │
    │       │ + Check user profile preferences                   │
    │       │ + ~6k tokens baseline (92% savings)                │
    │       ↓                                                    │
    │  1. DISCOVER - Infer requirements                          │
    │       │ + grepai: search existing patterns                 │
    │       │ + graph-code: query architecture                   │
    │       ↓                                                    │
    │  2. PLAN - Create workflow files                           │
    │       │ + graph-code: dependency analysis                  │
    │       │ + grepai: find similar implementations             │
    │       ↓                                                    │
    │  3. TASK - Decompose into todos                            │
    │       ↓                                                    │
    │  4. EXECUTE - Implement (with breakers)                    │
    │       │ + grepai: real-time code lookup                    │
    │       │ + graph-code: surgical editing                     │
    │       ↓                                                    │
    │  5. VERIFY - Self-validate + simplify (NEW)                │
    │       │ + Auto-simplify complex code                       │
    │       │ + Reduce nesting, improve naming                   │
    │       ↓                                                    │
    │  6. REVIEW - Quality validation                            │
    │       │ + grepai: verify patterns                          │
    │       │ + graph-code: check relationships                  │
    │       ↓                                                    │
    │  7. COMMIT - Git commit (no push)                          │
    │       ↓                                                    │
    │  8. DOCS - Auto-generate documentation                     │
    │       │ + grepai: extract docstrings                       │
    │       │ + graph-code: API structure                        │
    │                                                             │
    │  🛡️ Circuit breakers active throughout                     │
    │  🧠 Semantic intelligence at every phase                   │
    │  📦 Context efficiency: lazy load, unload                  │
    │  🎯 Theory of Mind: adapt to user preferences              │
    └─────────────────────────────────────────────────────────────┘
         │
         ▼
    Done! (or paused at breaker)
```

## Usage

```bash
/apex/yolo Build a REST API for user management

/apex/yolo --safe Add payment processing with high security

/apex/yolo --fast Refactor the auth module to use JWT

/apex/yolo "Implement full auth system" --until --max-iterations 10

/apex/yolo Add dark mode --pr --no-docs
```

## Flags

| Flag | Effect |
|------|--------|
| (none) | Default limits: 50 calls, 5 errors, 10 same-file |
| `--safe` | Tighter limits: 25 calls, 3 errors, 5 same-file |
| `--fast` | Looser limits: 100 calls, 10 errors, 20 same-file |
| `--until` | Ralph loop mode (requires --max-iterations) |
| `--max-iterations N` | Max loop iterations |
| `--no-commit` | Stop before commit phase |
| `--no-docs` | Skip documentation generation |
| `--pr` | Create PR after commit |
| `--no-semantic` | Disable grepai (fallback to grep) |
| `--no-graph` | Disable graph-code |
| `--no-simplify` | Skip code simplification phase |
| `--no-profile` | Ignore user profile preferences |
| `--verbose` | Override profile, show detailed output |

## Enhanced Loop Mode (v4.0)

### APEX_STATUS Block

Merged from Navigator v6 loop mode and Pilot Signal Protocol v2: APEX uses visible status blocks plus machine-parseable `pilot-signal` code blocks for completion/handoff automation.

When running in `--until` mode, APEX outputs structured status:

```
APEX_STATUS
==================================================
Phase: EXECUTE
Iteration: 3/10
Progress: 65%

Completion Indicators:
  [x] Code implemented
  [x] Tests written
  [ ] Tests passing
  [ ] Lint clean
  [ ] Documentation updated

Exit Conditions:
  Heuristics: 2/4 (need 2+)
  EXIT_SIGNAL: false

Stagnation: 0/3 (safe)
State Hash: a7b3c9f2
==================================================
```

### Dual-Condition Exit

Loop mode exits ONLY when BOTH conditions met. Use `functions/exit_gate.py` for machine evaluation.

Example:

```bash
python functions/exit_gate.py \
  --indicators '{"code_implemented":true,"tests_passing":true,"code_simplified":true}' \
  --exit-signal true
```

Loop mode exits ONLY when BOTH conditions met:

1. **Heuristics** (2+ indicators true):
   - Code implemented and committed
   - Tests passing
   - Lint clean
   - Documentation updated

2. **EXIT_SIGNAL** (explicit completion signal):
   - All todos marked complete
   - User confirmation (if high-stakes)
   - No pending errors
   - A `pilot-signal` block may be emitted:

```pilot-signal
{"v":2,"type":"exit","success":true,"reason":"All criteria met"}
```

### Stagnation Detection

Prevents infinite loops:

```
State Hash = hash(todos + files_modified + last_3_actions)

If same hash for 3 consecutive iterations:
  → STAGNATION DETECTED
  → Pause and report
  → Suggest alternative approach
```

### Progress Phases

```
INIT → RESEARCH → IMPLEMENT → VERIFY → COMPLETE
  │        │          │         │         │
  └────────┴──────────┴─────────┴─────────┘
              Can loop back on failure
```

## Execution Flow

### Phase 1: Intelligent Discovery

```bash
# 1. Read project context
cat package.json README.md

# 2. Semantic search for existing patterns
grepai search "similar to user request" --json --compact

# 3. Query knowledge graph for architecture
query_code_graph "What are the main modules?"
query_code_graph "How is the codebase structured?"

# 4. Generate requirements WITHOUT asking
# If critical ambiguity → pause and ask ONE question
```

**Output**: Structured requirements with codebase context

### Phase 2: Intelligent Planning

```bash
# 1. Create task_plan.md, notes.md, deliverable.md

# 2. Analyze dependencies via graph
query_code_graph "What would be affected by these changes?"
grepai trace callers "ExistingFunction" --json

# 3. Find similar implementations
grepai search "existing implementation of X" --json

# 4. Break into phases based on graph analysis
```

**Output**: Plan informed by actual codebase structure

### Phase 3: Task Decomposition

```bash
# 1. Decompose current phase into atomic todos
# 2. Each task < 30 min, specific file/function named
# 3. Load into TodoWrite
```

### Phase 4: Intelligent Execution

```bash
# For each task:

# 1. Find relevant code
grepai search "code related to current task" --json

# 2. Get specific function to modify
get_code_snippet "Module.functionName"

# 3. Make changes with surgical precision
surgical_replace_code(
    file_path="path/to/file",
    target_code="exact code to replace",
    replacement_code="new implementation"
)

# 4. Verify no broken dependencies
grepai trace callees "ModifiedFunction" --json
query_code_graph "Check relationships of modified code"

# 5. Circuit breakers check after each tool call
```

**Safety Features**:
- On error: retry once with semantic search for solutions
- On stuck loop: use graph to find alternative approach
- On approaching limit: warn and continue

### Phase 5: Auto-Simplification (NEW in v4.0)

```bash
# After implementation, before review:

# 1. Identify complex code in changed files
git diff --name-only | xargs analyze_complexity

# 2. Apply simplification rules
# - Flatten nested ternaries
# - Extract deep nesting to helper functions
# - Use early returns
# - Rename unclear variables
# - Remove redundant boolean comparisons

# 3. Verify tests still pass
npm run test

# 4. Report improvements
# "Reduced complexity by 35%, extracted 2 helpers"
```

### Phase 6: Intelligent Review

```bash
# 1. Self-review all changes
git diff

# 2. Verify patterns match codebase style
grepai search "similar patterns" --json

# 3. Check no unintended dependencies
query_code_graph "What depends on changed code?"
grepai trace callers "ChangedFunction" --json

# 4. Run quality checks
npm run lint && npm run test && npm run build

# 5. If P0/P1 issues → auto-fix → re-review
```

### Phase 7: Commit

```bash
# 1. Stage changes
git add .

# 2. Generate conventional commit
git commit -m "feat(scope): description"

# 3. Optional: push and create PR
git push && gh pr create
```

### Phase 8: Documentation (unless --no-docs)

```bash
# 1. Analyze changes
grepai search "new functions and classes" --json
query_code_graph "What was added/modified?"

# 2. Generate/update docs
# - README if significant
# - API docs for new endpoints
# - Changelog entry

# 3. Commit docs separately
git add docs/ README.md CHANGELOG.md
git commit -m "docs: update for <feature>"
```

## Circuit Breaker Behavior

**On Warning (80% of limit)**:
```
⚠️ APEX Warning: Tool calls at 40/50
🧠 Consulting semantic search for optimization opportunities...
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

🧠 Semantic Analysis:
- Similar issues found in codebase: 2 patterns
- Suggested approach: [from grepai]

Options:
1. "continue" - Reset counter, resume
2. "continue --fast" - Higher limits, resume
3. "try alternative" - Use suggested approach
4. "stop" - Save and exit
5. "review" - Show what's been done

What would you like to do?
```

## What YOLO v4.0 Does NOT Do

❌ Push to remote (unless --pr)
❌ Deploy to production
❌ Delete files outside project
❌ Modify system files
❌ Bypass circuit breakers
❌ Ignore critical errors
❌ Make changes without understanding context
❌ Load unnecessary context (token efficient)

## Example Session

```
User: /apex/yolo Add pagination to the products API

APEX: 🚀 YOLO v4.0 Mode activated

📦 Context Load...
   Baseline: 6k tokens (92% available)
   Profile: concise verbosity, conventional commits

🧠 Semantic Analysis...
   grepai: Found 3 similar pagination implementations
   graph-code: Products API in src/api/products.ts

📋 Auto-discovering requirements...
   - Endpoint: GET /api/products
   - Need: page, limit params
   - Pattern: Match existing pagination in src/api/users.ts

📁 Auto-planning...
   - Dependencies: ProductService, ProductController
   - Similar impl: src/api/users.ts:getPaginated()
   - Created task_plan.md (2 phases, S complexity)

📝 Auto-decomposing Phase 1...
   - 4 tasks created (informed by existing patterns)

⚡ Auto-executing...
   [1/4] ✅ Add pagination types (copied from users)
   [2/4] ✅ Update ProductService.list() with offset/limit
         📍 surgical_replace_code applied
   [3/4] ✅ Update ProductController with query params
   [4/4] ✅ Add pagination tests (based on user tests)

   ⚠️ Tool calls: 38/50

🧹 Auto-simplifying...
   - src/api/products.ts: Complexity 12→7 (-42%)
   - Flattened: 1 nested conditional

🔍 Auto-reviewing...
   - Lint: ✅ Pass
   - Tests: ✅ 12/12 passing
   - Graph check: ✅ No broken dependencies
   - Pattern match: ✅ Consistent with codebase

APEX_STATUS
==================================================
Phase: COMPLETE
Iteration: 1/1
Progress: 100%

Completion Indicators:
  [x] Code implemented
  [x] Tests passing
  [x] Lint clean
  [x] Simplified

Exit Conditions:
  Heuristics: 4/4 ✓
  EXIT_SIGNAL: true ✓
==================================================

📦 Auto-committing...
   - Commit: feat(api): add pagination to products endpoint

📚 Auto-documenting...
   - Updated: docs/api/products.md
   - Added: Changelog entry

✅ YOLO v4.0 complete!
   - 4 tasks completed
   - 3 files modified
   - 1 doc updated
   - 42 tool calls used
   - Context efficiency: 89%
   - Commit: abc123f

Files: task_plan.md, notes.md, deliverable.md updated
```

## Recovery from Breaker Trip

```
User: /apex/yolo continue

APEX: 📂 Resuming YOLO v4.0 session...

Previous state:
- Task: "Add pagination to products API"
- Phase: execute (task 3/4)
- Breaker: tool_calls hit 50/50

🧠 Semantic context restored:
- Last working on: ProductController
- Similar completed: 2/4 tasks
- Suggested next: Update controller with query params

Resuming with fresh limits (50 more calls).
```

## Tool Availability Check

At startup, YOLO checks for available tools:

```
🔧 Tool Check:
   ✅ grepai: Available (index current)
   ✅ graph-code: Available (Memgraph connected)
   ✅ Circuit breakers: Armed (default mode)
   
Proceeding with full intelligence stack.
```

If tools unavailable:

```
🔧 Tool Check:
   ❌ grepai: Not found (falling back to grep)
   ✅ graph-code: Available
   ✅ Circuit breakers: Armed
   
⚠️ Proceeding with reduced semantic capability.
   Install grepai for better results: curl -sSL ... | sh
```

## Safety Philosophy

> "YOLO v4.0 is autonomous, intelligent, AND efficient."

The combination of:
- **grepai**: Understand before you search
- **graph-code**: Understand before you change
- **Circuit breakers**: Pause before you break
- **Context efficiency**: Load only what you need
- **Theory of Mind**: Adapt to user preferences
- **Simplification**: Clean before you commit

Creates an agent that:
1. Learns from existing code patterns
2. Understands impact before making changes
3. Stops when stuck rather than thrashing
4. Manages context for long sessions
5. Adapts to how you work
6. Leaves code cleaner than it found it
7. Documents what it does

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
