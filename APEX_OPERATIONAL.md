# APEX Operational Procedures v4.0

**Layer**: 2 (Operational)  
**Purpose**: Step-by-step procedures for each APEX phase with semantic intelligence, context efficiency, and Theory of Mind

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

2. SEMANTIC ANALYSIS (NEW in v3.0)
   □ grepai search for existing similar patterns
     grepai search "similar to user request" --json --compact
   
   □ Query knowledge graph for architecture
     query_code_graph "What are the main modules?"
     query_code_graph "How is similar functionality implemented?"
   
   □ Identify relevant existing code
     grepai trace graph "RelatedFunction" --depth 2 --json

3. ASK DISCOVERY QUESTIONS (if needed)
   □ What problem does this solve?
   □ Who are the users and what are their workflows?
   □ What are the success criteria?
   □ What constraints exist (time, tech, budget)?
   □ What's explicitly out of scope?

4. SYNTHESIZE REQUIREMENTS
   □ Functional requirements (what it must do)
   □ Non-functional requirements (how well)
   □ Existing patterns to follow (from semantic analysis)
   □ Constraints and assumptions
   □ Acceptance criteria

5. VALIDATE UNDERSTANDING
   □ Summarize back to user
   □ Include: "Found N similar implementations in codebase"
   □ Get explicit confirmation
   □ Document any remaining unknowns
```

### Output
- Structured requirements document
- Related existing code identified
- Ready for PLAN phase
- Clear handoff: "Requirements confirmed. Found 3 similar patterns. Run /apex/plan to create workflow."

---

## Phase 2: PLAN

### Entry Conditions
- Clear requirements from DISCOVER phase
- OR explicit task with defined scope

### Procedure

```
1. DEPENDENCY ANALYSIS (NEW in v3.0)
   □ Query graph for affected modules
     query_code_graph "What modules would be affected by this change?"
   
   □ Identify callers/callees of code to modify
     grepai trace callers "ExistingFunction" --json
   
   □ Map impact radius
     query_code_graph "Show dependency tree for ModuleToChange"

2. PATTERN DISCOVERY (NEW in v3.0)
   □ Find similar implementations
     grepai search "existing X implementation" --json
   
   □ Extract patterns from similar code
     get_code_snippet "SimilarModule.similarFunction"
   
   □ Note: "Will follow pattern from [file:line]"

3. CREATE TASK_PLAN.MD
   □ Copy template from ~/.claude/apex/templates/task_plan.md
   □ Fill in objective and success criteria
   □ Break down into phases/milestones
   □ Include: "Based on pattern from [existing code]"
   □ Estimate complexity (S/M/L/XL)

4. CREATE NOTES.MD
   □ Copy template from ~/.claude/apex/templates/notes.md
   □ Document initial context and decisions
   □ Include semantic analysis findings
   □ Note any assumptions made

5. CREATE DELIVERABLE.MD
   □ Copy template from ~/.claude/apex/templates/deliverable.md
   □ Define expected outputs
   □ Set up validation checklist
   □ Include graph verification steps

6. VALIDATE PLAN
   □ Does plan match requirements?
   □ Are dependencies identified (from graph)?
   □ Is complexity realistic?
   □ Get user confirmation
```

### Output
- Three files created in project root
- Dependency impact documented
- Similar patterns identified
- Ready for TASK phase
- Clear handoff: "Plan created with dependency analysis. N modules affected. Run /apex/task to decompose."

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

2. SEMANTIC TASK BREAKDOWN (NEW in v3.0)
   □ For each high-level task, find related code:
     grepai search "code for [task description]" --json
   
   □ Get specific functions to modify:
     query_code_graph "Functions related to [task]"
   
   □ Map each task to specific file:line

3. DECOMPOSE INTO TODOS
   □ Break each phase into atomic tasks
   □ Each task should be < 30 min work
   □ Include file:function targets from semantic analysis
   □ Define clear done criteria
   □ Identify parallelizable tasks

4. WRITE TO TODOWRITE
   □ Create TodoWrite entries with specific targets
   □ Format: "Modify src/auth/handler.go:Login() to add..."
   □ Set first task as in_progress
   □ Mark dependencies with notes

5. UPDATE TASK_PLAN.MD
   □ Add detailed task breakdown
   □ Include file:function targets
   □ Mark decomposition complete
   □ Note estimated order of execution
```

### Output
- TodoWrite populated with targeted items
- Each task has specific file:function target
- task_plan.md updated with breakdown
- Ready for EXECUTE phase
- Clear handoff: "Tasks decomposed with specific targets. Run /apex/execute to begin implementation."

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

2. TOOL AVAILABILITY CHECK (NEW in v3.0)
   □ Check grepai: grepai status
   □ Check graph-code: query_code_graph "ping"
   □ Log available tools

3. FOR EACH TASK:

   a. SEMANTIC CONTEXT (NEW in v3.0)
      □ Get surrounding code context
        grepai search "context for [task]" --json
      
      □ Get exact code to modify
        get_code_snippet "Module.function"
      
      □ Understand callers (what might break)
        grepai trace callers "FunctionToModify" --json

   b. EXECUTE TASK
      □ Mark task as in_progress
      □ Prefer surgical_replace_code for modifications
      □ Use Write/Edit for new files
      □ Track tool calls

   c. VERIFY CHANGES (NEW in v3.0)
      □ Check relationships still valid
        query_code_graph "Verify Module.function relationships"
      
      □ Check no broken calls
        grepai trace callees "ModifiedFunction" --json
      
      □ Update notes.md with discoveries

   d. POST-TASK UPDATE (Ralph)
      □ Increment tool call counter
      □ Check for error patterns
      □ If approaching limit → warn user
      □ If limit hit → pause execution

4. VALIDATE TASK COMPLETION
   □ Does output match task criteria?
   □ Any side effects or issues?
   □ Graph relationships valid?
   □ Mark task complete in TodoWrite
   □ Update task_plan.md progress

5. LOOP OR COMPLETE
   □ If more tasks → goto step 3
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
- Graph relationships verified
- notes.md updated with execution log
- Ready for REVIEW phase
- Clear handoff: "Execution complete. Graph verified. Run /apex/review to validate."

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

2. GRAPH VERIFICATION (NEW in v3.0)
   □ Check all relationships intact
     query_code_graph "Verify all CALLS relationships for changed files"
   
   □ Check no orphaned dependencies
     query_code_graph "Find any broken references"
   
   □ Verify impact radius as planned
     grepai trace callers "ChangedFunction" --json

3. PATTERN VERIFICATION (NEW in v3.0)
   □ Check changes follow existing patterns
     grepai search "similar code for comparison" --json
   
   □ Compare with original pattern source
     get_code_snippet "OriginalPattern.function"
   
   □ Note any pattern deviations

4. SELF-REVIEW (Fresh Eyes)
   □ Read code as if you didn't write it
   □ Check for obvious bugs
   □ Verify error handling exists
   □ Look for security issues

5. VALIDATE AGAINST CRITERIA
   □ Does it meet task_plan.md objectives?
   □ Does it pass acceptance criteria?
   □ Are tests included/passing?
   □ Is documentation updated?

6. RUN QUALITY CHECKS
   □ Lint (if configured)
   □ Type check (if configured)
   □ Tests (if configured)
   □ Build (if configured)

7. DOCUMENT RESULTS
   □ Update deliverable.md with outcomes
   □ Include graph verification results
   □ Note any issues found
   □ Mark review status
```

### Review Checklist
```
□ Correctness - Does it work as intended?
□ Graph Valid - All relationships intact?
□ Pattern Match - Follows codebase conventions?
□ Security - Any vulnerabilities introduced?
□ Performance - Any obvious bottlenecks?
□ Maintainability - Is code clean and documented?
□ Tests - Are changes covered?
□ Docs - Is documentation updated?
```

### Output
- Review report with findings
- Graph verification passed
- deliverable.md updated
- Ready for COMMIT phase
- Clear handoff: "Review complete. Graph verified. Run /apex/commit to finalize."

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
   □ Ask about documentation: "Run /apex/docs?"
```

### Output
- Git commit created
- Optional PR created
- Planning files updated
- Ready for DOCS phase (optional)

---

## Phase 7: DOCS (NEW in v3.0)

### Entry Conditions
- Commit phase complete (or standalone invocation)
- Changes to document

### Procedure

```
1. ANALYZE CHANGES
   □ Query graph for new/modified entities
     query_code_graph "What was added/modified recently?"
   
   □ Get function signatures
     grepai search "new functions" --json
   
   □ Extract docstrings
     query_code_graph "Get docstrings for Module"

2. DETERMINE DOCUMENTATION NEEDS
   □ New public API? → API docs
   □ Significant feature? → README update
   □ Architecture change? → Architecture docs
   □ Bug fix/feature? → Changelog entry

3. GENERATE DOCUMENTATION
   □ Use templates from ~/.claude/apex/templates/docs/
   □ Include code examples from tests
   □ Generate diagrams if applicable
   □ Cross-reference related docs

4. VALIDATE DOCUMENTATION
   □ Check all public functions documented
   □ Check examples compile/run
   □ Check links valid
   □ Check consistent style

5. COMMIT DOCUMENTATION
   □ git add docs/ README.md CHANGELOG.md
   □ git commit -m "docs: update for [feature]"
```

### Output
- Documentation generated/updated
- Coverage report
- Separate docs commit

---

## Error Recovery Procedures

### Circuit Breaker Tripped

```
1. STOP immediately
2. SAVE current state to apex-state.json
3. SEMANTIC ANALYSIS (NEW in v3.0):
   □ Search for similar errors in codebase
     grepai search "how [error] is handled" --json
   □ Query graph for alternative approaches
     query_code_graph "Alternative implementations of X"
4. REPORT:
   - Which breaker tripped
   - Current counts vs limits
   - Last 3 actions taken
   - Suspected cause
   - Semantic suggestions (from analysis)
5. ASK user:
   - Continue with higher limit?
   - Try alternative approach (from semantic)?
   - Abort and save progress?
6. WAIT for explicit response
7. PROCEED based on response
```

### Stuck Loop Detected

```
1. IDENTIFY the pattern
2. SEMANTIC SEARCH for solutions (NEW in v3.0):
   grepai search "how to solve [pattern]" --json
   query_code_graph "Similar code that works"
3. STOP and reflect
4. REPORT findings + semantic suggestions
5. PROPOSE alternatives from semantic analysis
6. WAIT for guidance
```

---

## State Transitions

```
DISCOVER ──[+semantic]──▶ PLAN ──[+graph]──▶ TASK
    │                        │                  │
    └────(user provides clear requirements)─────┘

TASK ─────────────────────▶ EXECUTE ──[+surgical]──▶ SIMPLIFY
    │                          │                        │
    └──(todos already exist)───┘                        │
                                                        │
SIMPLIFY ──[+flatten]──▶ REVIEW ──[+graph verify]──▶ COMMIT
    │                       │                          │
    │                       │ (issues found)           │
    │                       └──▶ EXECUTE (fix) ────────┘
    │                                                  │
COMMIT ─────────────────────────────────────▶ DOCS ──▶ COMPLETE
```

---

## Phase 0: CONTEXT LOAD (NEW in v4.0)

### Purpose
Strategic lazy loading for token efficiency. Load ~6k tokens, not 150k.

### Procedure

```
1. LOAD CORE ONLY
   □ Load APEX.md (routing layer, ~2k tokens)
   □ Check for existing task_plan.md
   □ Load active todos from apex-state.json
   □ Total baseline: ~6k tokens

2. CHECK USER PROFILE
   □ Load apex-profile.json if exists
   □ Apply communication preferences
   □ Apply coding style preferences
   □ Note any drift indicators

3. TOOL AVAILABILITY
   □ Check grepai available
   □ Check graph-code available
   □ Log available stack

4. DO NOT LOAD YET
   □ APEX_OPERATIONAL.md (load per-phase)
   □ APEX_REFERENCE.md (load on-demand)
   □ Command docs (load when invoked)
   □ Integration docs (load when using tool)
```

### Context Budget

| Category | Budget |
|----------|--------|
| System | 5k |
| APEX Core | 5k |
| Active Context | 10k |
| Working Memory | 80k |
| Safety Buffer | 100k |

### Output
- Minimal context loaded
- ~194k tokens available for work
- User preferences active

---

## Phase 4.5: SIMPLIFY (NEW in v4.0)

### Entry Conditions
- Execute phase complete
- Code changes exist
- Not skipped with --no-simplify

### Procedure

```
1. IDENTIFY CHANGED FILES
   □ git diff --name-only
   □ Filter to code files (.ts, .js, .py, etc.)
   □ Exclude test files (unless --include-tests)

2. ANALYZE COMPLEXITY
   □ Calculate cyclomatic complexity
   □ Identify deep nesting (>3 levels)
   □ Find large functions (>50 lines)
   □ Detect unclear variable names

3. APPLY SIMPLIFICATIONS
   □ Flatten nested ternaries → if-else
   □ Extract deep nesting → helper functions
   □ Use early returns → reduce nesting
   □ Rename unclear variables → descriptive names
   □ Remove redundant boolean comparisons

4. VERIFY CHANGES
   □ Run tests (must still pass)
   □ Check lint (must be clean)
   □ No functionality changes

5. REPORT IMPROVEMENTS
   □ "Reduced complexity by X%"
   □ "Extracted N helper functions"
   □ "Renamed M unclear variables"
```

### Simplification Rules

| Rule | Before | After |
|------|--------|-------|
| Flatten ternary | `a ? (b ? c : d) : e` | if-else block |
| Early return | 5-level nesting | Guard clauses |
| Extract helper | 50-line function | 3x focused functions |
| Rename unclear | `const x = ...` | `const userData = ...` |
| Remove redundant | `if (x === true)` | `if (x)` |

### Skip Simplification

Add comment to preserve:
```typescript
// apex:no-simplify
const intentionallyComplex = ...;
// apex:end-no-simplify
```

### Output
- Cleaner code with preserved functionality
- Complexity metrics (before/after)
- Ready for REVIEW phase

---

## Theory of Mind Checkpoints (NEW in v4.0)

### When to Verify Understanding

| Situation | Action |
|-----------|--------|
| First task with new user | Summarize + ask |
| Satisfaction score < 0.5 | Recalibration check |
| 3+ corrections same type | Drift detection |
| Destructive operation | Explicit confirmation |
| XL complexity task | Phased check-ins |

### Verification Pattern

```
Before I proceed:
- Task: [1 sentence summary]
- Approach: [key approach]
- Based on your preference: [relevant preference]

Correct?
```

### Recalibration Pattern

```
I notice my last few outputs needed corrections.
Let me recalibrate:

My understanding: [what I think you want]
Your corrections suggested: [patterns]

Am I on the right track now?
```

### Satisfaction Tracking

Update apex-state.json after each interaction:
- Accepted without changes → score +0.05
- Minor edits → score unchanged
- Redo requested → score -0.1
- Frustration expressed → score -0.2

---
