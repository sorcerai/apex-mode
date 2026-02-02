---
description: "APEX Swarm Mode - Parallel execution with orchestrated workers"
---

# /apex/swarm

**Parallel autonomous execution.** Decompose a task, spawn multiple workers in git worktrees, and merge results.

## What Swarm Mode Does

```
User: "/apex/swarm Build user management API with auth, CRUD, and tests"
         │
         ▼
    ┌─────────────────────────────────────────────┐
    │              APEX SWARM MODE                │
    │                                             │
    │  1. DECOMPOSE - Break into subtasks         │
    │       ↓                                     │
    │  2. SPAWN - Create worker worktrees         │
    │       ↓                                     │
    │  ┌─────────┬─────────┬─────────┐           │
    │  │Worker 1 │Worker 2 │Worker 3 │           │
    │  │  Auth   │  CRUD   │  Tests  │           │
    │  │(yolo)   │(yolo)   │(yolo)   │           │
    │  └────┬────┴────┬────┴────┬────┘           │
    │       │         │         │                 │
    │  3. MONITOR - Track progress, conflicts     │
    │       ↓                                     │
    │  4. MERGE - Sequential merge to main        │
    │       ↓                                     │
    │  5. CLEANUP - Remove worktrees              │
    │                                             │
    │  🛡️ Per-worker circuit breakers            │
    │  📊 Aggregated token/cost tracking          │
    └─────────────────────────────────────────────┘
         │
         ▼
    Done! Single merged result
```

## Usage

```
/apex/swarm Build a REST API with auth, users, and products

/apex/swarm --workers=3 Implement dashboard with charts, filters, and export

/apex/swarm --sequential Add validation to all form components
```

## Flags

| Flag | Effect |
|------|--------|
| `--workers=N` | Number of parallel workers (default: 3, max: 5) |
| `--sequential` | Force sequential execution (1 worker, no conflicts) |
| `--no-merge` | Stop before merge phase (keep branches separate) |
| `--dry-run` | Decompose and show plan without executing |

## Execution Flow

### Phase 1: Decompose Task

```bash
python functions/task_decomposer.py --task "$TASK_DESCRIPTION"
```

Output:
```json
{
  "subtasks": [
    {"id": "task-001", "description": "Implement auth endpoints", "dependencies": []},
    {"id": "task-002", "description": "Implement user CRUD", "dependencies": ["task-001"]},
    {"id": "task-003", "description": "Write integration tests", "dependencies": ["task-001", "task-002"]}
  ],
  "parallel_groups": [
    ["task-001"],
    ["task-002", "task-003"]
  ]
}
```

### Phase 2: Spawn Workers

For each parallel group, spawn workers in isolated worktrees:

```bash
python functions/worktree_manager.py create --id 1 --branch apex-swarm-1
python functions/worktree_manager.py create --id 2 --branch apex-swarm-2
```

Each worker runs `/apex/yolo` with its assigned subtask.

### Phase 3: Monitor

Real-time status display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
APEX SWARM STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Swarm: swarm-20260201-203000
Workers: 3 active

Worker 1 ████████░░ 80%  task-001 (VERIFY)   ✓
Worker 2 ██████░░░░ 60%  task-002 (IMPL)
Worker 3 ██░░░░░░░░ 20%  task-003 (RESEARCH) ⚠️ STUCK

Queue: 0 pending, 1 completed, 2 in-progress
Tokens: 145,234 input / 23,456 output
Est. Cost: ~$2.34

Conflicts: None
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Conflict Detection:**
```bash
python functions/conflict_detector.py --workers 1,2,3
```

If workers modify the same files, swarm pauses and asks for resolution.

### Phase 4: Merge

Sequential merge of worker branches:

```bash
git checkout main
git merge apex-swarm-1 --no-ff -m "swarm: merge worker 1 (auth)"
git merge apex-swarm-2 --no-ff -m "swarm: merge worker 2 (crud)"
git merge apex-swarm-3 --no-ff -m "swarm: merge worker 3 (tests)"
```

On conflict:
```
🚨 MERGE CONFLICT: Worker 2 conflicts with Worker 1

Conflicting files:
  - src/middleware/auth.js

Options:
1. [auto] - Attempt AI-assisted resolution
2. [manual] - Open in editor
3. [abort] - Keep branches separate
```

### Phase 5: Cleanup

```bash
python functions/worktree_manager.py destroy --all
git branch -D apex-swarm-1 apex-swarm-2 apex-swarm-3
```

## Swarm Queue

Persistent queue in `~/.claude/apex/state/swarm-queue.json`:

```json
{
  "swarm_id": "swarm-20260201-203000",
  "status": "running",
  "workers": {
    "1": {"status": "busy", "task": "task-001", "branch": "apex-swarm-1"},
    "2": {"status": "idle", "task": null, "branch": "apex-swarm-2"}
  },
  "queue": [],
  "completed": [{"id": "task-001", "worker": "1", "commit": "abc123"}],
  "conflicts": []
}
```

## Resuming Swarm

If interrupted:

```
/apex/swarm continue

APEX: 📂 Resuming swarm session...

Previous state:
- Swarm: swarm-20260201-203000
- Workers: 2/3 complete
- Remaining: task-003

Resuming Worker 3...
```

## Limitations

**Cannot parallelize:**
- Tasks with strict sequential dependencies
- Tasks modifying the same files
- Tasks requiring shared state

**Recommended for:**
- Independent feature branches
- Test suites (each test file parallel)
- Multi-component implementations
- Documentation + code + tests (naturally parallel)

## Example Session

```
User: /apex/swarm --workers=2 Add user profile with avatar upload and settings page

APEX: 🐝 SWARM MODE activated

📋 Decomposing task...
   Subtask 1: Avatar upload component + API
   Subtask 2: Settings page with preferences
   
   Parallel groups: [[1, 2]] (both can run simultaneously)

🔧 Spawning workers...
   Worker 1: apex-swarm-1 → Avatar upload
   Worker 2: apex-swarm-2 → Settings page

⚡ Executing...
   Worker 1 ████████░░ 80%  (VERIFY)
   Worker 2 ██████████ 100% (COMPLETE) ✓

   ⚠️ Worker 1: circuit breaker at 45/50 tools

🔀 Merging...
   ✓ apex-swarm-2 merged (settings)
   ✓ apex-swarm-1 merged (avatar)
   No conflicts!

🧹 Cleanup...
   Worktrees removed
   Branches deleted

✅ SWARM complete!
   - 2 subtasks completed
   - 8 files modified
   - 92 tool calls total
   - ~$1.85 estimated cost
   - Merge commit: def456

All changes on main branch.
```
