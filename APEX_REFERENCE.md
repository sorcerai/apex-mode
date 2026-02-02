# APEX Reference Documentation

**Layer**: 3 (Reference)
**Purpose**: Deep documentation, examples, edge cases, and technical details

---

## System Origins

APEX unifies four complementary systems:

### PRISM v3.3
- **Source**: Knowledge architecture framework
- **Contribution**: 3-layer decomposition pattern
- **Key insight**: AI performs better with tiered information access
- **APEX integration**: This 3-file structure (APEX.md → OPERATIONAL → REFERENCE)

### Planning with Files
- **Source**: github.com/OthmanAdi/planning-with-files
- **Contribution**: Persistent 3-file workflow
- **Key insight**: External files survive context resets
- **APEX integration**: task_plan.md, notes.md, deliverable.md templates

### AIDD (AI-Driven Development)
- **Source**: github.com/paralleldrive/aidd
- **Contribution**: Structured development lifecycle
- **Key insight**: Clear phase transitions improve quality
- **APEX integration**: /apex/discover → plan → task → execute → review → commit

### Ralph
- **Source**: github.com/frankbria/ralph-claude-code
- **Contribution**: Execution safety mechanisms
- **Key insight**: Autonomous agents need circuit breakers
- **APEX integration**: Hooks, state tracking, stuck loop detection

---

## Circuit Breaker Deep Dive

### Why Circuit Breakers?

Without limits, Claude can:
- Edit the same file 50+ times chasing a bug
- Make 100+ tool calls without progress
- Get stuck in error-fix-error loops
- Run for 10+ minutes without human check-in

Circuit breakers force human checkpoints at reasonable intervals.

### Breaker Types

#### Tool Call Breaker
```javascript
{
  "type": "tool_calls",
  "current": 0,
  "warning": 40,
  "limit": 50,
  "window": "per_task"
}
```
- Counts all tool invocations
- Resets when task completes
- Warning at 80%, limit at 100%

#### Error Breaker
```javascript
{
  "type": "errors",
  "current": 0,
  "warning": 4,
  "limit": 5,
  "window": "per_task",
  "pattern_detection": true
}
```
- Counts errors of any type
- Pattern detection: same error 3x = stuck
- Aggressive limit to prevent frustration loops

#### Same-File Edit Breaker
```javascript
{
  "type": "same_file_edits",
  "current": {},
  "warning": 8,
  "limit": 10,
  "window": "per_task"
}
```
- Tracks edits per file path
- Separate counter for each file
- Prevents obsessive file modification

#### Stuck Loop Breaker
```javascript
{
  "type": "stuck_loop",
  "patterns": [],
  "threshold": 3,
  "detection": "action_sequence"
}
```
- Detects repeated action sequences
- Triggers on 3 identical patterns
- Patterns: [action, target, result] tuples

### Mode Configurations

#### Default Mode
```javascript
{
  "tool_calls": { "warning": 40, "limit": 50 },
  "errors": { "warning": 4, "limit": 5 },
  "same_file": { "warning": 8, "limit": 10 },
  "stuck_loop": { "threshold": 3 }
}
```

#### Safe Mode (--apex-safe)
```javascript
{
  "tool_calls": { "warning": 20, "limit": 25 },
  "errors": { "warning": 2, "limit": 3 },
  "same_file": { "warning": 4, "limit": 5 },
  "stuck_loop": { "threshold": 2 }
}
```

#### Fast Mode (--apex-fast)
```javascript
{
  "tool_calls": { "warning": 80, "limit": 100 },
  "errors": { "warning": 8, "limit": 10 },
  "same_file": { "warning": 16, "limit": 20 },
  "stuck_loop": { "threshold": 5 }
}
```

---

## Planning Files Specification

### task_plan.md Format

```markdown
# Task Plan: [Title]

## Objective
[One-sentence description of what we're building]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Phases

### Phase 1: [Name]
**Status**: pending | in_progress | complete
**Estimate**: S | M | L | XL

Tasks:
- [ ] Task 1.1
- [ ] Task 1.2

### Phase 2: [Name]
...

## Dependencies
- Dependency 1: [description]
- Dependency 2: [description]

## Constraints
- Constraint 1
- Constraint 2

## Progress Log
| Date | Phase | Status | Notes |
|------|-------|--------|-------|
| YYYY-MM-DD | Phase 1 | Started | Initial setup |
```

### notes.md Format

```markdown
# Development Notes

## Session: [Date]

### Discoveries
- Discovery 1
- Discovery 2

### Decisions
| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| Decision 1 | Why | What else |

### Problems & Solutions
#### Problem: [Description]
- Attempted: [What we tried]
- Solution: [What worked]
- Lesson: [What we learned]

### Context for Next Session
- Currently working on: [task]
- Blocked by: [blocker]
- Next steps: [steps]
```

### deliverable.md Format

```markdown
# Deliverables

## Outputs

### Code Changes
| File | Change Type | Description |
|------|-------------|-------------|
| path/to/file | created/modified/deleted | What changed |

### Tests
| Test File | Coverage | Status |
|-----------|----------|--------|
| path/to/test | What it tests | pass/fail |

### Documentation
| Doc | Updated | Notes |
|-----|---------|-------|
| README.md | Yes/No | What changed |

## Validation

### Automated Checks
- [ ] Lint: [status]
- [ ] Type check: [status]
- [ ] Tests: [status]
- [ ] Build: [status]

### Manual Verification
- [ ] Feature works as intended
- [ ] No regressions in related features
- [ ] Performance acceptable
- [ ] Security reviewed

## Handoff Checklist
- [ ] Code committed
- [ ] PR created (if applicable)
- [ ] Documentation updated
- [ ] Stakeholders notified
```

---

## AIDD Lifecycle Details

### Phase: DISCOVER

**Purpose**: Transform vague requests into structured requirements

**Socratic Questions**:
1. What problem does this solve for users?
2. Who are the primary users and their workflows?
3. What does success look like? How will we measure it?
4. What are the hard constraints (time, tech, budget)?
5. What's explicitly out of scope?
6. What existing systems does this integrate with?
7. What are the security/compliance requirements?
8. What's the rollback plan if this fails?

**Anti-patterns to Avoid**:
- Assuming requirements without confirmation
- Starting implementation before discovery complete
- Ignoring non-functional requirements
- Scope creep during discovery

**Output Template**:
```markdown
## Requirements Summary

### Functional Requirements
1. [MUST] Requirement 1
2. [MUST] Requirement 2
3. [SHOULD] Requirement 3
4. [COULD] Requirement 4

### Non-Functional Requirements
- Performance: [constraints]
- Security: [requirements]
- Scalability: [expectations]

### Constraints
- Technical: [constraints]
- Timeline: [deadline]
- Resources: [limitations]

### Assumptions
- Assumption 1
- Assumption 2

### Out of Scope
- Excluded item 1
- Excluded item 2
```

### Phase: PLAN

**Purpose**: Create persistent workflow structure

**Planning Principles**:
1. Break into phases, not just tasks
2. Each phase should have clear completion criteria
3. Identify dependencies upfront
4. Plan for validation at each stage
5. Include buffer for unknowns

**Estimation Guidelines**:
| Size | Description | Typical Time |
|------|-------------|--------------|
| S | Single file, simple change | < 30 min |
| M | Multiple files, moderate complexity | 30 min - 2 hr |
| L | Multiple components, significant work | 2 - 4 hr |
| XL | Architectural change, major feature | 4+ hr, consider decomposition |

### Phase: TASK

**Purpose**: Decompose phases into atomic, actionable items

**Good Task Characteristics**:
- Completable in < 30 minutes
- Single clear outcome
- Testable/verifiable
- Independent (where possible)
- Ordered by dependency

**Bad Task Examples**:
- "Implement the feature" (too vague)
- "Fix all the bugs" (unbounded)
- "Make it better" (no criteria)
- "Refactor everything" (too broad)

**Good Task Examples**:
- "Create UserService class with getUser() method"
- "Add input validation for email field"
- "Write unit test for calculateTotal function"
- "Update README with new API endpoint"

### Phase: EXECUTE

**Purpose**: Implement with safety guardrails

**Execution Best Practices**:
1. One task at a time (focus)
2. Update notes.md with discoveries
3. Commit after each significant change
4. Run tests frequently
5. Watch circuit breaker warnings

**When to Pause**:
- Uncertainty about approach
- Discovering requirement gaps
- Performance or security concerns
- Circuit breaker warnings
- Feeling "stuck"

### Phase: REVIEW

**Purpose**: Validate quality before commit

**Review Dimensions**:

| Dimension | Questions |
|-----------|-----------|
| Correctness | Does it work? Edge cases? |
| Security | Vulnerabilities? Secrets? |
| Performance | Bottlenecks? N+1? |
| Maintainability | Clean code? Comments? |
| Tests | Coverage? Quality? |
| Docs | Updated? Accurate? |

**Self-Review Technique**:
1. Read code as if you didn't write it
2. Simulate being on-call when this breaks
3. Ask "what could go wrong?"
4. Check error handling paths
5. Verify happy AND unhappy paths

### Phase: COMMIT

**Purpose**: Finalize with clean git workflow

**Commit Message Format**:
```
type(scope): subject

[optional body]

[optional footer]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Types**: feat, fix, docs, style, refactor, test, chore
**Scope**: Component or area affected

---

## State File Specification

### apex-state.json Structure

```json
{
  "version": "1.0.0",
  "current_session": {
    "id": "uuid",
    "started": "ISO8601",
    "phase": "execute",
    "task_index": 3
  },
  "circuit_breakers": {
    "tool_calls": {
      "current": 15,
      "warning": 40,
      "limit": 50
    },
    "errors": {
      "current": 1,
      "warning": 4,
      "limit": 5,
      "history": ["error message 1"]
    },
    "same_file_edits": {
      "files": {
        "/path/to/file.js": 3
      },
      "warning": 8,
      "limit": 10
    },
    "stuck_loop": {
      "patterns": [
        ["edit", "file.js", "error"],
        ["edit", "file.js", "error"]
      ],
      "threshold": 3
    }
  },
  "mode": "default",
  "session_history": [
    {
      "id": "previous-uuid",
      "started": "ISO8601",
      "ended": "ISO8601",
      "outcome": "complete",
      "tasks_completed": 5
    }
  ]
}
```

### State Operations

**Initialize Session**:
```javascript
{
  "current_session": {
    "id": generateUUID(),
    "started": new Date().toISOString(),
    "phase": "discover",
    "task_index": 0
  },
  "circuit_breakers": resetBreakers(mode)
}
```

**Update Breakers**:
```javascript
// After each tool call
state.circuit_breakers.tool_calls.current++

// After each error
state.circuit_breakers.errors.current++
state.circuit_breakers.errors.history.push(errorMessage)

// After each file edit
state.circuit_breakers.same_file_edits.files[filePath]++
```

**Check Breakers**:
```javascript
function checkBreakers(state) {
  const breakers = state.circuit_breakers

  for (const [type, config] of Object.entries(breakers)) {
    if (config.current >= config.limit) {
      return { tripped: true, type, current: config.current, limit: config.limit }
    }
    if (config.current >= config.warning) {
      console.warn(`Warning: ${type} at ${config.current}/${config.limit}`)
    }
  }

  return { tripped: false }
}
```

---

## Edge Cases & Troubleshooting

### Planning Files Already Exist

**Scenario**: User runs /apex/plan but files exist

**Resolution**:
1. Check file timestamps
2. Ask user:
   - Continue previous work?
   - Archive and start fresh?
   - Merge with new requirements?

### Circuit Breaker False Positive

**Scenario**: Breaker trips but work is progressing

**Resolution**:
1. User can override with explicit confirmation
2. Increase limits for current task only
3. Log override for audit trail

### Session Interrupted Mid-Task

**Scenario**: Claude session ends unexpectedly

**Resolution**:
1. State auto-saved on each tool call
2. Next session reads state
3. Offers to resume from last checkpoint
4. User can choose to restart

### Conflicting Planning Files

**Scenario**: Local and template files differ

**Resolution**:
1. Always prefer local files if they exist
2. Only use templates for new initialization
3. Never overwrite without user confirmation

### Rate Limit During Execute

**Scenario**: API rate limits hit

**Resolution**:
1. Pause execution
2. Save current state
3. Report to user with estimated wait
4. Offer to resume later

---

## Integration Examples

### With SuperClaude

```markdown
# In ~/.claude/CLAUDE.md

## APEX Integration
@~/.claude/apex/APEX.md

## When to Use APEX
- Multi-step features
- Projects requiring persistence
- When safety is priority
- Complex refactoring
```

### With Existing Hooks

APEX hooks can coexist with other hooks:

```json
{
  "hooks": {
    "PreToolUse": [
      { "command": "existing-hook.sh" },
      { "command": "~/.claude/apex/hooks/apex-circuit-breaker.sh" }
    ]
  }
}
```

### With MCP Servers

APEX works alongside MCP servers:
- **Serena**: Symbol operations during EXECUTE
- **Playwright**: E2E testing during REVIEW
- **Context7**: Documentation lookup during DISCOVER

---

## Version History

### v1.0.0 (Current)
- Initial unified release
- PRISM 3-layer knowledge architecture
- Planning with Files persistence
- AIDD lifecycle commands
- Ralph safety mechanisms

---

## Knowledge Graph (v2)

APEX v2 introduces a persistent knowledge graph for context engineering.

### Purpose

The knowledge graph stores:
- **Concepts**: Project components, directories, features
- **Memories**: Patterns, pitfalls, decisions, learnings
- **Files**: Important project files and their roles
- **Relationships**: Connections between concepts

### Location

`~/.claude/apex/state/knowledge-graph.json`

### Commands

```bash
# Initialize graph for current project
python functions/graph_manager.py init --project .

# Query knowledge
python functions/graph_manager.py query "auth"

# Add a memory
python functions/graph_manager.py memory \
  --type pitfall \
  --summary "Never edit package.json and code in same commit" \
  --concepts "npm,commits" \
  --confidence 0.9

# Add relationship
python functions/graph_manager.py relate \
  --from auth \
  --to users \
  --type depends_on

# View stats
python functions/graph_manager.py stats
```

### Memory Types

| Type | Purpose | Example |
|------|---------|---------|
| `pattern` | Successful approaches | "Use factory functions for test data" |
| `pitfall` | Things to avoid | "Auth changes break session tests" |
| `decision` | Architectural choices | "Chose JWT over sessions for scaling" |
| `learning` | General insights | "TypeScript generics improve DX" |

### Context Loading

On YOLO/swarm start, APEX can query relevant knowledge:

```
1. Parse task description for concepts
2. Query knowledge graph for each concept
3. Load relevant memories (patterns, pitfalls)
4. Include in execution context
```

This enables cross-session learning without bloating the prompt.

### Graph Schema

```json
{
  "version": "1.0.0",
  "project": "/path/to/project",
  "concepts": {
    "auth": {
      "type": "feature",
      "path": "src/auth",
      "memories": ["mem_001", "mem_002"],
      "related_files": ["src/auth/index.ts"]
    }
  },
  "memories": [
    {
      "id": "mem_001",
      "type": "pitfall",
      "summary": "Auth changes break session tests",
      "concepts": ["auth", "testing"],
      "confidence": 0.9,
      "created_at": "2024-01-15T..."
    }
  ],
  "relationships": [
    {
      "from": "auth",
      "to": "users",
      "type": "depends_on"
    }
  ]
}
```

---

## Improved Stagnation Detection (v2)

APEX v2 replaces simple repetition detection with hash-based pattern matching.

### Detection Types

| Pattern | Description | Example |
|---------|-------------|---------|
| Immediate | Same state N times | A→A→A |
| Cycle | Repeating sequence | A→B→A→B |
| Oscillation | Alternating states | A→B→A→B→A |

### State Hash

Each state is hashed from:
- Current phase (DISCOVER, PLAN, EXECUTE, etc.)
- Completion indicators (code_changed, tests_passing, etc.)
- Recent files modified (last 5)
- Recent actions (last 3)

### Usage

```bash
# Check history for patterns
python functions/stagnation_detector.py check \
  --history '["hash1", "hash2", "hash1", "hash2"]' \
  --threshold 3 \
  --max-cycle 5

# Update history and check
python functions/stagnation_detector.py update \
  --state '{"phase": "EXECUTE", "indicators": {"code_changed": true}}' \
  --history-file /tmp/apex-history.json
```

### Integration

Circuit breakers now use stagnation detection:

```bash
# In apex-circuit-breaker.sh
STAGNATION=$(python functions/stagnation_detector.py check ...)
if [[ $(echo "$STAGNATION" | jq -r '.stagnant') == "true" ]]; then
  echo "🚨 STAGNATION DETECTED"
  echo "Pattern: $(echo "$STAGNATION" | jq -r '.pattern_type')"
  echo "Suggestion: $(echo "$STAGNATION" | jq -r '.suggestion')"
  exit 1
fi
```
