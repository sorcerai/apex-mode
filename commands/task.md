---
description: "APEX Task - Decompose phases into atomic, actionable todos"
---

# /apex/task

You are entering APEX Task Decomposition phase. Break down phases from task_plan.md into atomic, trackable todos.

## Pre-flight Check

1. Read `task_plan.md` from project root - REQUIRED
2. Read `notes.md` for context
3. Check current phase status
4. Load APEX state for session continuity

## Decomposition Rules

### Good Task Characteristics
✅ Completable in < 30 minutes
✅ Single clear outcome
✅ Testable/verifiable completion
✅ Independent where possible
✅ Specific file/function/component named

### Bad Task Examples
❌ "Implement the feature" (too vague)
❌ "Fix all the bugs" (unbounded)
❌ "Make it better" (no criteria)
❌ "Refactor everything" (too broad)
❌ "Handle edge cases" (which ones?)

### Good Task Examples
✅ "Create UserService class in src/services/user.ts"
✅ "Add email validation to LoginForm component"
✅ "Write unit test for calculateTotal() in cart.test.ts"
✅ "Update README with new API endpoint documentation"
✅ "Add error handling for network timeout in fetchUser()"

## Decomposition Process

### Step 1: Identify Current Phase
```
Read task_plan.md
Find first phase with status: pending or in_progress
Focus on that phase only
```

### Step 2: Break Down Tasks
For each high-level task in the phase:
1. What files need to be created/modified?
2. What functions/components are involved?
3. What's the dependency order?
4. What can be parallelized?

### Step 3: Create TodoWrite Entries
```
For each atomic task:
- content: Imperative action ("Create X", "Add Y", "Update Z")
- status: pending (or in_progress for first task)
- activeForm: Present participle ("Creating X", "Adding Y")
```

### Step 4: Update task_plan.md
Mark the phase as `in_progress` and add detailed breakdown:

```markdown
### Phase 1: [Name]
**Status**: in_progress  ← Update this
**Estimate**: M

Detailed Tasks:
- [ ] 1.1: Create src/services/user.ts with UserService class
- [ ] 1.2: Add getUser(), createUser(), updateUser() methods
- [ ] 1.3: Write unit tests in tests/user.service.test.ts
- [ ] 1.4: Integrate UserService into existing UserController
```

## Output Format

After decomposition, report:

```
📋 Task Decomposition Complete

Phase: [Phase Name]
Total Tasks: [N]
Parallelizable: [M] tasks can run independently

Tasks:
1. [Task description] - [S/M estimate]
2. [Task description] - [S/M estimate]
...

Dependencies:
- Task 3 depends on Task 1, 2
- Task 5 depends on Task 4

Starting with: [First task description]
```

## TodoWrite Integration

Create TodoWrite entries for the current phase:

```javascript
TodoWrite({
  todos: [
    {
      content: "Create UserService class in src/services/user.ts",
      status: "in_progress",  // First task starts immediately
      activeForm: "Creating UserService class"
    },
    {
      content: "Add CRUD methods to UserService",
      status: "pending",
      activeForm: "Adding CRUD methods to UserService"
    },
    {
      content: "Write unit tests for UserService",
      status: "pending",
      activeForm: "Writing unit tests for UserService"
    }
  ]
})
```

## Update APEX State

```json
{
  "current_session": {
    "phase": "task",
    "task_index": 0,
    "total_tasks": [N]
  }
}
```

## Handoff

"Tasks decomposed for Phase [N]: [Phase Name]

[X] atomic tasks created in TodoWrite
[Y] can be parallelized
Estimated: [time range]

Run `/apex/execute` to begin implementation with safety guardrails."

## Edge Cases

### Phase Already Has Detailed Tasks
- Ask user: Use existing breakdown or re-decompose?
- If keeping, just create TodoWrite entries from existing

### Too Many Tasks (>15)
- Consider splitting the phase
- Or group into sub-phases
- Flag to user for confirmation

### Unclear Dependencies
- Default to sequential if uncertain
- Note in notes.md for future reference
- Ask user if critical path unclear
