---
description: "APEX Context Efficiency v4.0 - Strategic context engineering for 92% token savings"
alwaysApply: false
---

# APEX Context Efficiency Skill

**Version**: 4.0.0  
**Purpose**: Load what you need, when you need it. 92% token savings through strategic curation.

---

## Philosophy

> "Context engineering beats bulk loading."

Traditional approach: Load everything upfront → 150k tokens consumed → Session dies in 5-7 exchanges

APEX v4.0 approach: Load strategically → 8k tokens active → 192k available for work

---

## Context Layers

### Layer 0: Core (Always Loaded)
```
APEX.md (routing, ~2k tokens)
Current task context (~3k tokens)
Active todo items (~500 tokens)
───────────────────────────────
Total: ~5.5k tokens baseline
```

### Layer 1: On-Demand (Lazy Load)
```
APEX_OPERATIONAL.md → Load when entering new phase
APEX_REFERENCE.md → Load when deep documentation needed
commands/*.md → Load only the current command
integrations/*.md → Load only when using that tool
```

### Layer 2: Just-In-Time (Per-Operation)
```
Code files → Load only files being modified
Patterns → Load only when pattern matching needed
Documentation → Load only during DOCS phase
```

---

## Loading Protocol

### Session Start
```
1. Load APEX.md (routing layer)
2. Load current task_plan.md (if exists)
3. Load active todos from state
4. That's it. ~6k tokens.
```

### Phase Transitions
```
DISCOVER:
  + Load APEX_OPERATIONAL.md#Phase1
  + Load project README, package.json
  - Unload previous phase context

PLAN:
  + Load APEX_OPERATIONAL.md#Phase2
  + Load templates/*.md
  - Unload discovery questions

EXECUTE:
  + Load relevant source files only
  + Load only command being used
  - Keep minimal operational context

DOCS:
  + Load templates/docs/*.md
  + Load changed files for docs
  - Unload execution context
```

### On-Demand Loading Rules

| Trigger | What to Load |
|---------|--------------|
| "How do I use grepai?" | integrations/grepai/README.md |
| "What's the commit format?" | commands/commit.md |
| Error during execution | APEX_REFERENCE.md#ErrorRecovery |
| Circuit breaker trip | APEX_OPERATIONAL.md#ErrorRecovery |
| Unknown command | APEX.md + specific command file |

---

## Token Budget

### Budget Allocation (Default: 200k context)

| Category | Budget | Notes |
|----------|--------|-------|
| System/Instructions | 5k | Fixed overhead |
| APEX Core | 5k | Always loaded |
| Active Context | 10k | Current phase + task |
| Working Memory | 80k | Code files, search results |
| Safety Buffer | 100k | Reserved for responses + thinking |

### Budget Tracking

Track in apex-state.json:
```json
{
  "context_budget": {
    "total": 200000,
    "used": 25000,
    "breakdown": {
      "system": 5000,
      "apex_core": 5000,
      "active_context": 10000,
      "working_memory": 5000
    },
    "last_check": "2026-01-22T10:00:00Z"
  }
}
```

### Warning Thresholds

| Usage | Action |
|-------|--------|
| < 50% | Normal operation |
| 50-70% | Consider unloading inactive context |
| 70-85% | Actively prune, summarize results |
| > 85% | WARNING: Limit searches, summarize aggressively |
| > 95% | CRITICAL: Complete current task, prepare handoff |

---

## Unloading Protocol

### What to Unload When

```
Phase completed → Unload phase-specific docs
Search completed → Keep summary, discard raw results
File edited → Keep filename + change summary, discard full content
Error resolved → Keep lesson learned, discard stack trace
```

### Context Compression

When approaching limits:
1. **Summarize** long outputs to key points
2. **Deduplicate** repeated information
3. **Prioritize** current task over historical
4. **Archive** to notes.md instead of keeping in context

---

## Progressive Refinement

### Metadata First Pattern

```
Step 1: Get overview
  grepai search "auth implementation" --compact --limit 5
  → Returns: file paths + function names + snippets

Step 2: Evaluate relevance
  → User/AI decides which results matter

Step 3: Load details on-demand
  get_code_snippet "AuthService.validate"
  → Returns: Only the specific code needed
```

### Cascading Detail

```
Low detail → index/list (5 tokens per result)
    ↓
Medium detail → metadata + preview (50 tokens per result)  
    ↓
High detail → full content (500+ tokens per result)

Only escalate when needed.
```

---

## Implementation Checklist

### At Session Start
- [ ] Load only APEX.md (not all layers)
- [ ] Check for existing task_plan.md
- [ ] Load active state from apex-state.json
- [ ] Total < 10k tokens

### During Execution
- [ ] Load command docs only when invoked
- [ ] Unload docs after phase complete
- [ ] Summarize long search results
- [ ] Track token usage in state

### At Phase Transitions
- [ ] Archive current phase context to notes.md
- [ ] Clear working memory
- [ ] Load new phase documentation
- [ ] Update budget tracking

### Before Handoff
- [ ] Summarize session to notes.md
- [ ] Save critical context to files
- [ ] Clear transient context
- [ ] Next session starts fresh

---

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Load all APEX docs at start | Load APEX.md only, others on-demand |
| Keep full search results | Keep summaries, load details as needed |
| Load all source files "for context" | Load only files being modified |
| Repeat long code blocks | Reference by file:line |
| Load full error traces | Extract key error message |

---

## Context Efficiency Metrics

Track these in apex-state.json:
```json
{
  "context_efficiency": {
    "session_start_tokens": 6000,
    "peak_tokens": 45000,
    "files_loaded": 12,
    "files_summarized": 8,
    "searches_performed": 5,
    "searches_fully_loaded": 2,
    "efficiency_score": 92
  }
}
```

**Efficiency Score** = (1 - peak_tokens/total_available) * 100

Target: > 85% efficiency (peak < 30k tokens)
