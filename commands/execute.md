---
description: "APEX Execute - Implement tasks with safety guardrails"
---

# /apex/execute

You are entering APEX Execution phase. Implement tasks with circuit breaker protection and progress tracking.

## Pre-flight Check

1. **Load State**: Read `~/.claude/apex/state/apex-state.json`
2. **Check Breakers**: Verify all circuit breakers are green
3. **Load Context**: Read task_plan.md and notes.md
4. **Verify Todos**: Confirm TodoWrite has pending tasks

If any breaker is tripped:
```
🚨 Cannot execute: [breaker] limit reached
Current: [N] / Limit: [M]
Run '/apex/resume' with explicit confirmation to continue.
```

## Initialize Session (if new)

```json
{
  "current_session": {
    "id": "[uuid]",
    "started": "[ISO8601]",
    "phase": "execute",
    "task_index": 0
  },
  "circuit_breakers": {
    "tool_calls": { "current": 0 },
    "errors": { "current": 0 },
    "same_file_edits": { "files": {} },
    "stuck_loop": { "patterns": [] }
  }
}
```

## Execution Loop

### For Each Task:

```
1. MARK IN PROGRESS
   - Update TodoWrite status to in_progress
   - Update task_plan.md task checkbox
   - Log start in notes.md

2. PRE-TASK CHECK
   - Circuit breakers green?
   - Dependencies complete?
   - Context sufficient?

3. EXECUTE
   - Perform the implementation
   - Track tool calls
   - Note any discoveries in notes.md

4. POST-TASK VALIDATION
   - Does output match task criteria?
   - Any errors or side effects?
   - Tests still passing?

5. MARK COMPLETE
   - Update TodoWrite to completed
   - Update task_plan.md checkbox
   - Increment task_index in state

6. CHECKPOINT
   - Save state to apex-state.json
   - Update notes.md with progress
   - If warnings present, report to user
```

## Circuit Breaker Behavior

### During Execution

Monitor these thresholds (default mode):

| Metric | Warning (80%) | Limit (100%) |
|--------|---------------|--------------|
| Tool calls | 40 | 50 |
| Errors | 4 | 5 |
| Same-file edits | 8 | 10 |
| Stuck patterns | 2 | 3 |

### On Warning
```
⚠️ APEX Warning: [metric] at [current]/[limit]
Continuing, but consider checkpointing.
```

### On Limit
```
🚨 APEX CIRCUIT BREAKER TRIPPED

Metric: [which breaker]
Current: [value]
Limit: [threshold]

Last 3 actions:
1. [action 1]
2. [action 2]
3. [action 3]

Options:
1. Continue with higher limits (risky)
2. Try different approach
3. Save progress and pause

What would you like to do?
```

## Progress Reporting

After each task completion:
```
✅ Task [N/M]: [task description]
   Files: [created/modified]
   Duration: [time]
   Tool calls: [count]

   Remaining: [M-N] tasks
   Breaker status: 🟢 [tool_calls]/[limit]
```

After phase completion:
```
🎉 Phase [N] Complete: [Phase Name]

Tasks completed: [X]
Files changed: [list]
Tool calls used: [N]
Errors encountered: [M]

Next: [Next phase or /apex/review]
```

## Error Handling

### On Tool Error
1. Increment error counter
2. Log error to notes.md
3. Check if same error repeated (stuck loop)
4. If recoverable, retry once
5. If not, pause and report

### On Stuck Loop Detection
```
🔄 APEX Stuck Loop Detected

Pattern repeated [N] times:
[action] → [target] → [result]

This usually means:
- Wrong approach
- Missing dependency
- Incorrect assumption

Stopping to prevent wasted effort.
What should I try instead?
```

## Updating Planning Files

### task_plan.md
- Check off completed tasks
- Update phase status (pending → in_progress → complete)
- Log actual vs estimated time

### notes.md
- Add discoveries and learnings
- Document any decisions made
- Note problems and solutions
- Update "Context for Next Session"

### deliverable.md
- Add completed outputs
- Update file change log
- Note test results

## Handoff

When all tasks for current phase complete:
```
Phase [N] execution complete.

Summary:
- [X] tasks completed
- [Y] files created/modified
- [Z] tool calls used

Next steps:
- More phases? Run /apex/task for next phase
- All phases done? Run /apex/review to validate
```

## Safety Commands

### /apex/pause
Manually trigger pause, save state, report status

### /apex/resume
Continue after breaker trip (requires explicit confirmation)

### /apex/status
Report current execution state without changing anything

### /apex/reset
Reset circuit breakers (use with caution, requires confirmation)
