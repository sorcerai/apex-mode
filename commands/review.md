---
description: "APEX Review - Validate implementation quality before commit"
---

# /apex/review

You are entering APEX Review phase. Validate the implementation with fresh eyes before committing.

## Pre-flight Check

1. Verify execution phase is complete
2. Load task_plan.md to check all phases marked complete
3. Read notes.md for context on what was built
4. Check deliverable.md for expected outputs

## Review Dimensions

### 1. Correctness
- [ ] Does it work as intended?
- [ ] Are edge cases handled?
- [ ] Does it match the requirements from Discovery?
- [ ] Are there any obvious bugs?

### 2. Security
- [ ] No hardcoded secrets/credentials?
- [ ] Input validation present?
- [ ] No injection vulnerabilities?
- [ ] Proper authentication/authorization?

### 3. Performance
- [ ] No obvious bottlenecks?
- [ ] No N+1 queries?
- [ ] No unnecessary loops/operations?
- [ ] Resource cleanup (connections, files)?

### 4. Maintainability
- [ ] Code is readable?
- [ ] Functions are reasonably sized?
- [ ] No duplicated logic?
- [ ] Naming is clear?

### 5. Tests
- [ ] Tests exist for new functionality?
- [ ] Tests cover happy path?
- [ ] Tests cover error cases?
- [ ] All tests passing?

### 6. Documentation
- [ ] README updated if needed?
- [ ] Complex logic commented?
- [ ] API documentation current?

## Review Process

### Step 1: Gather Changes
```bash
git status
git diff --stat
git diff  # Full diff
```

### Step 2: Self-Review (Fresh Eyes Protocol)

Read the code as if you didn't write it:
1. Start from entry point
2. Trace the flow
3. Question every assumption
4. Look for what's missing, not just what's there

Questions to ask:
- "What would break this?"
- "What's not being validated?"
- "What happens on failure?"
- "Would I understand this in 6 months?"

### Step 3: Run Quality Checks

Execute available checks:
```bash
# If configured in project
npm run lint       # or equivalent
npm run typecheck  # or equivalent
npm run test       # or equivalent
npm run build      # or equivalent
```

Report results:
```
Quality Check Results:
- Lint: ✅ Pass / ❌ [N] issues
- Types: ✅ Pass / ❌ [N] errors
- Tests: ✅ Pass ([N] tests) / ❌ [M] failures
- Build: ✅ Pass / ❌ Failed
```

### Step 4: Update deliverable.md

```markdown
## Validation Results

### Automated Checks
- [x] Lint: Pass
- [x] Type check: Pass
- [x] Tests: 15/15 passing
- [x] Build: Success

### Manual Review
- [x] Feature works as specified
- [x] No regressions found
- [x] Performance acceptable
- [x] Security reviewed

### Issues Found
[List any issues and whether they're fixed]

### Code Quality
- Files changed: [N]
- Lines added: [N]
- Lines removed: [N]
- Test coverage: [if available]
```

## Review Output Format

```markdown
## APEX Review Report

### Summary
**Status**: ✅ Ready to commit / ⚠️ Issues to address / ❌ Needs rework

### Changes Reviewed
| File | Type | Lines | Assessment |
|------|------|-------|------------|
| path/to/file | modified | +50/-10 | ✅ Good |

### Findings

#### ✅ Strengths
- [What's done well]
- [Good patterns used]

#### ⚠️ Suggestions (non-blocking)
- [Minor improvements]
- [Style suggestions]

#### ❌ Issues (blocking)
- [Must fix before commit]
- [Security/correctness concerns]

### Quality Checks
- Lint: [status]
- Types: [status]
- Tests: [status]
- Build: [status]

### Recommendation
[Ready to commit / Fix issues first / Needs discussion]
```

## Handling Issues

### Minor Issues (non-blocking)
- Note in review report
- Fix if quick (<5 min)
- Otherwise document for later

### Major Issues (blocking)
1. Do NOT proceed to commit
2. Document the issue clearly
3. Go back to execute phase for fix
4. Re-review after fix

```
❌ Blocking issue found: [description]

This needs to be fixed before commit:
- File: [path]
- Problem: [what's wrong]
- Suggestion: [how to fix]

Run /apex/execute to fix, then /apex/review again.
```

## Update Planning Files

### task_plan.md
- Mark review phase complete
- Note any issues found
- Update progress log

### notes.md
- Document review findings
- Note any decisions made
- Add lessons learned

### deliverable.md
- Complete validation checklist
- Add final test results
- Document any manual testing done

## Handoff

### If Review Passes:
```
✅ APEX Review Complete

All checks passed:
- Correctness: Verified
- Security: No issues
- Performance: Acceptable
- Tests: [N] passing
- Build: Success

Ready for commit. Run /apex/commit to finalize.
```

### If Review Fails:
```
⚠️ APEX Review: Issues Found

Blocking issues:
1. [Issue 1] - [file:line]
2. [Issue 2] - [file:line]

Fix these before committing:
Run /apex/execute to address issues, then /apex/review again.
```
