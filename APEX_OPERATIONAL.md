# APEX Operational Procedures

**Layer**: 2 (Operational)
**Purpose**: Step-by-step procedures for each APEX phase

---

## Phase 1: DISCOVER

### Entry Conditions
- Vague or incomplete requirements
- New project or feature request
- Uncertainty about scope or approach

### Procedure

```
1. GATHER CONTEXT
   □ Read existing project files (package.json, README, etc.)
   □ Check for existing task_plan.md from previous sessions
   □ Identify stakeholders and constraints mentioned

2. ASK DISCOVERY QUESTIONS
   □ What problem does this solve?
   □ Who are the users and what are their workflows?
   □ What are the success criteria?
   □ What constraints exist (time, tech, budget)?
   □ What's explicitly out of scope?

3. SYNTHESIZE REQUIREMENTS
   □ Functional requirements (what it must do)
   □ Non-functional requirements (how well)
   □ Constraints and assumptions
   □ Acceptance criteria

4. VALIDATE UNDERSTANDING
   □ Summarize back to user
   □ Get explicit confirmation
   □ Document any remaining unknowns
```

### Output
- Structured requirements document
- Ready for PLAN phase
- Clear handoff: "Requirements confirmed. Run /apex/plan to create workflow."

---

## Phase 2: PLAN

### Entry Conditions
- Clear requirements from DISCOVER phase
- OR explicit task with defined scope

### Procedure

```
1. CREATE TASK_PLAN.MD
   □ Copy template from ~/.claude/apex/templates/task_plan.md
   □ Fill in objective and success criteria
   □ Break down into phases/milestones
   □ Estimate complexity (S/M/L/XL)

2. CREATE NOTES.MD
   □ Copy template from ~/.claude/apex/templates/notes.md
   □ Document initial context and decisions
   □ Note any assumptions made

3. CREATE DELIVERABLE.MD
   □ Copy template from ~/.claude/apex/templates/deliverable.md
   □ Define expected outputs
   □ Set up validation checklist

4. VALIDATE PLAN
   □ Does plan match requirements?
   □ Are dependencies identified?
   □ Is complexity realistic?
   □ Get user confirmation
```

### Output
- Three files created in project root
- Ready for TASK phase
- Clear handoff: "Plan created. Run /apex/task to decompose into actionable items."

---

## Phase 3: TASK

### Entry Conditions
- task_plan.md exists with phases defined
- Plan confirmed by user

### Procedure

```
1. READ CURRENT STATE
   □ Parse task_plan.md for phases
   □ Check notes.md for context
   □ Identify current phase focus

2. DECOMPOSE INTO TODOS
   □ Break each phase into atomic tasks
   □ Each task should be <30 min work
   □ Define clear done criteria
   □ Identify parallelizable tasks

3. WRITE TO TODOWRITE
   □ Create TodoWrite entries
   □ Set first task as in_progress
   □ Mark dependencies with notes

4. UPDATE TASK_PLAN.MD
   □ Add detailed task breakdown
   □ Mark decomposition complete
   □ Note estimated order of execution
```

### Output
- TodoWrite populated with actionable items
- task_plan.md updated with breakdown
- Ready for EXECUTE phase
- Clear handoff: "Tasks decomposed. Run /apex/execute to begin implementation."

---

## Phase 4: EXECUTE

### Entry Conditions
- Todos exist in TodoWrite
- Circuit breaker state is green

### Procedure

```
1. PRE-EXECUTION CHECK (Ralph)
   □ Load apex-state.json
   □ Verify circuit breakers are green
   □ Check for stuck loop patterns
   □ If any red → pause and report

2. EXECUTE CURRENT TASK
   □ Mark task as in_progress
   □ Perform the work
   □ Update notes.md with discoveries
   □ Track tool calls and errors

3. POST-EXECUTION UPDATE (Ralph)
   □ Increment tool call counter
   □ Check for error patterns
   □ If approaching limit → warn user
   □ If limit hit → pause execution

4. VALIDATE TASK COMPLETION
   □ Does output match task criteria?
   □ Any side effects or issues?
   □ Mark task complete in TodoWrite
   □ Update task_plan.md progress

5. LOOP OR COMPLETE
   □ If more tasks → goto step 1
   □ If all complete → ready for REVIEW
```

### Safety Thresholds (Default)
| Metric | Warning | Limit |
|--------|---------|-------|
| Tool calls | 40 | 50 |
| Errors | 4 | 5 |
| Same-file edits | 8 | 10 |
| Repeated patterns | 2 | 3 |

### Output
- Implementation complete
- notes.md updated with execution log
- Ready for REVIEW phase
- Clear handoff: "Execution complete. Run /apex/review to validate."

---

## Phase 5: REVIEW

### Entry Conditions
- Execute phase complete
- Code changes exist to review

### Procedure

```
1. GATHER CHANGES
   □ git diff to see all changes
   □ List new files created
   □ Identify modified files

2. SELF-REVIEW (Fresh Eyes)
   □ Read each change as if first time
   □ Check for obvious bugs
   □ Verify error handling exists
   □ Look for security issues

3. VALIDATE AGAINST CRITERIA
   □ Does it meet task_plan.md objectives?
   □ Does it pass acceptance criteria?
   □ Are tests included/passing?
   □ Is documentation updated?

4. RUN QUALITY CHECKS
   □ Lint (if configured)
   □ Type check (if configured)
   □ Tests (if configured)
   □ Build (if configured)

5. DOCUMENT RESULTS
   □ Update deliverable.md with outcomes
   □ Note any issues found
   □ Mark review status
```

### Review Checklist
```
□ Correctness - Does it work as intended?
□ Security - Any vulnerabilities introduced?
□ Performance - Any obvious bottlenecks?
□ Maintainability - Is code clean and documented?
□ Tests - Are changes covered?
□ Docs - Is documentation updated?
```

### Output
- Review report with findings
- deliverable.md updated
- Ready for COMMIT phase
- Clear handoff: "Review complete. Run /apex/commit to finalize."

---

## Phase 6: COMMIT

### Entry Conditions
- Review passed
- Changes ready to commit

### Procedure

```
1. PRE-COMMIT CHECK
   □ git status - verify expected changes
   □ No unintended files staged
   □ No secrets or temp files included

2. CREATE COMMIT
   □ Generate conventional commit message
   □ Include scope and description
   □ Reference task/issue if applicable
   □ Add Co-Authored-By trailer

3. OPTIONAL: CREATE PR
   □ If on feature branch
   □ If user requests PR
   □ Generate PR description from deliverable.md

4. CLEANUP
   □ Archive or update planning files
   □ Reset apex-state.json counters
   □ Update session history

5. HANDOFF
   □ Report what was committed
   □ Provide PR link if created
   □ Summarize completed work
```

### Output
- Git commit created
- Optional PR created
- Planning files updated
- Session complete

---

## Error Recovery Procedures

### Circuit Breaker Tripped

```
1. STOP immediately
2. SAVE current state to apex-state.json
3. REPORT:
   - Which breaker tripped
   - Current counts vs limits
   - Last 3 actions taken
   - Suspected cause
4. ASK user:
   - Continue with higher limit?
   - Try different approach?
   - Abort and save progress?
5. WAIT for explicit response
6. PROCEED based on response
```

### Stuck Loop Detected

```
1. IDENTIFY the pattern:
   - Same error 3+ times
   - Same file edited 10+ times
   - Alternating between two states
2. STOP and reflect:
   - What am I trying to achieve?
   - Why isn't it working?
   - What's fundamentally wrong?
3. REPORT findings to user
4. PROPOSE alternatives:
   - Different approach
   - Ask for help
   - Skip and continue
5. WAIT for guidance
```

### Session Interrupted

```
On next session start:
1. CHECK for existing planning files
2. LOAD apex-state.json
3. REPORT session state:
   - Last completed task
   - Current task in progress
   - Remaining tasks
4. ASK: Resume from where we left off?
5. CONTINUE or reset based on response
```

---

## State Transitions

```
DISCOVER ─────────────────────────────────────▶ PLAN
   │                                              │
   │ (user provides clear requirements)           │
   └──────────────────────────────────────────────┘

PLAN ─────────────────────────────────────────▶ TASK
   │                                              │
   │ (planning files already exist)               │
   └──────────────────────────────────────────────┘

TASK ─────────────────────────────────────────▶ EXECUTE
   │                                              │
   │ (todos already decomposed)                   │
   └──────────────────────────────────────────────┘

EXECUTE ──────────────────────────────────────▶ REVIEW
   │                                              │
   │ (circuit breaker trip) ─▶ PAUSE ─▶ RESUME    │
   └──────────────────────────────────────────────┘

REVIEW ───────────────────────────────────────▶ COMMIT
   │                                              │
   │ (issues found) ─▶ EXECUTE (fix)              │
   └──────────────────────────────────────────────┘

COMMIT ───────────────────────────────────────▶ COMPLETE
   │                                              │
   │ (more work needed) ─▶ DISCOVER               │
   └──────────────────────────────────────────────┘
```
