---
description: "APEX Plan - Create persistent 3-file workflow structure"
---

# /apex/plan

You are entering APEX Planning phase. Create the 3-file persistent workflow structure that survives context resets.

## Pre-flight Check

1. Verify requirements exist (from `/apex/discover` or explicit user input)
2. Check if planning files already exist in project root:
   - `task_plan.md` - If exists, ask: Continue, Archive & restart, or Merge?
   - `notes.md` - If exists, preserve and append
   - `deliverable.md` - If exists, archive previous

## Create Planning Files

### 1. task_plan.md

Create in project root with this structure:

```markdown
# Task Plan: [Descriptive Title]

## Objective
[One sentence: what we're building and why]

## Success Criteria
- [ ] Criterion 1 (measurable)
- [ ] Criterion 2 (measurable)
- [ ] Criterion 3 (measurable)

## Phases

### Phase 1: [Foundation/Setup/Analysis]
**Status**: pending
**Estimate**: [S|M|L|XL]
**Description**: [What this phase accomplishes]

Tasks:
- [ ] Task 1.1: [specific action]
- [ ] Task 1.2: [specific action]

**Done when**: [Clear completion criteria]

### Phase 2: [Core Implementation]
**Status**: pending
**Estimate**: [S|M|L|XL]
**Description**: [What this phase accomplishes]

Tasks:
- [ ] Task 2.1: [specific action]
- [ ] Task 2.2: [specific action]

**Done when**: [Clear completion criteria]

### Phase 3: [Integration/Testing]
**Status**: pending
**Estimate**: [S|M|L|XL]
**Description**: [What this phase accomplishes]

Tasks:
- [ ] Task 3.1: [specific action]
- [ ] Task 3.2: [specific action]

**Done when**: [Clear completion criteria]

## Dependencies
- [ ] Dependency 1: [description and status]
- [ ] Dependency 2: [description and status]

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Risk 1 | Low/Med/High | Low/Med/High | How to handle |

## Progress Log
| Date | Phase | Status | Notes |
|------|-------|--------|-------|
| [today] | Planning | Complete | Initial plan created |
```

### 2. notes.md

Create in project root:

```markdown
# Development Notes

## Project Context
- **Created**: [date]
- **Last Updated**: [date]
- **Current Phase**: Planning

## Requirements (from Discovery)
[Paste requirements summary here if available]

---

## Session Log

### [Date] - Planning Session
**Goal**: Create project structure
**Discoveries**: [any findings during planning]
**Decisions**: [any decisions made]
**Next**: Run /apex/task to decompose

---

## Technical Decisions
| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| [decision] | [why] | [what else] |

## Problems & Solutions
<!-- Add entries as they occur -->

## Context for Next Session
- Currently: Planning complete
- Next step: /apex/task for decomposition
- Blockers: None
```

### 3. deliverable.md

Create in project root:

```markdown
# Deliverables

## Expected Outputs

### Code Changes
| File | Type | Description | Status |
|------|------|-------------|--------|
| [planned] | create/modify | [what] | pending |

### Tests
| Test | Coverage | Status |
|------|----------|--------|
| [planned] | [what it tests] | pending |

### Documentation
| Doc | Updates Needed | Status |
|-----|----------------|--------|
| README.md | [if any] | pending |

---

## Validation Checklist

### Automated
- [ ] Lint passes
- [ ] Type check passes
- [ ] Tests pass
- [ ] Build succeeds

### Manual
- [ ] Feature works as specified
- [ ] No regressions
- [ ] Performance acceptable
- [ ] Security reviewed

---

## Handoff Checklist
- [ ] Code committed with descriptive message
- [ ] PR created (if applicable)
- [ ] Documentation updated
- [ ] Stakeholders notified
- [ ] Planning files archived/updated
```

## Initialize APEX State

Update `~/.claude/apex/state/apex-state.json`:

```json
{
  "current_session": {
    "id": "[generate-uuid]",
    "started": "[ISO8601-now]",
    "phase": "plan",
    "task_index": 0
  }
}
```

## Validation

Before completing:
1. All three files created in project root
2. Phases are realistic and achievable
3. Success criteria are measurable
4. User confirms plan makes sense

## Handoff

"Planning complete. Three workflow files created:
- `task_plan.md` - Your roadmap with [N] phases
- `notes.md` - Session context and decisions
- `deliverable.md` - Expected outputs and validation

Run `/apex/task` to decompose phases into actionable todos."
