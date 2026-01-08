---
description: "APEX Discovery - Requirements elicitation and context gathering"
---

# /apex/discover

You are entering APEX Discovery phase. Your goal is to transform vague requests into structured requirements through Socratic dialogue.

## Context Check

First, check for existing context:
1. Look for `task_plan.md` in project root - if exists, ask if continuing or starting fresh
2. Check `~/.claude/apex/state/apex-state.json` for previous session
3. Read project files (package.json, README, etc.) for technical context

## Discovery Questions

Ask these questions to understand the full scope:

### Problem Space
1. **What problem does this solve?** Who experiences this problem and how often?
2. **Who are the users?** What are their technical levels and main workflows?
3. **What does success look like?** How will we measure if this works?

### Constraints
4. **What are the hard constraints?** (time, technology, budget, compatibility)
5. **What's explicitly out of scope?** What should we NOT build?
6. **What existing systems does this integrate with?**

### Technical
7. **What's the tech stack?** (Check package.json, go.mod, requirements.txt, etc.)
8. **Are there existing patterns to follow?** (Check codebase conventions)
9. **What's the testing strategy?** (unit, integration, e2e)

### Risk
10. **What could go wrong?** What's the rollback plan?
11. **Security/compliance requirements?**
12. **Performance expectations?**

## Output Format

After gathering answers, synthesize into this format:

```markdown
## Requirements Summary

### Objective
[One clear sentence describing what we're building]

### Functional Requirements
- [MUST] Critical requirement 1
- [MUST] Critical requirement 2
- [SHOULD] Important requirement 3
- [COULD] Nice-to-have requirement 4

### Non-Functional Requirements
- **Performance**: [constraints]
- **Security**: [requirements]
- **Scalability**: [expectations]
- **Compatibility**: [requirements]

### Constraints
- Technical: [stack, dependencies]
- Timeline: [deadline if any]
- Resources: [limitations]

### Assumptions
- Assumption 1 (confirm with user)
- Assumption 2

### Out of Scope
- Excluded: item 1
- Excluded: item 2

### Success Criteria
- [ ] Measurable criterion 1
- [ ] Measurable criterion 2
- [ ] Measurable criterion 3
```

## Handoff

Once requirements are confirmed:
1. Save requirements to `notes.md` in project root
2. State: "Requirements confirmed. Run `/apex/plan` to create the workflow structure."

## Anti-patterns to Avoid

❌ Starting implementation before discovery is complete
❌ Assuming requirements without explicit confirmation
❌ Ignoring non-functional requirements
❌ Scope creep during discovery (note for later, don't add)
❌ Accepting vague answers ("make it fast" → ask for specific metrics)
