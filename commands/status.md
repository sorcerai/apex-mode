---
description: "APEX Status - Show current session state and circuit breaker metrics"
---

# /apex/status

Display the current APEX session state, circuit breaker metrics, and system health.

---

## What It Shows

1. **Session Info**: Current phase, active task, session duration
2. **Circuit Breakers**: All counter values vs limits, trip status
3. **Semantic Tools**: Availability and usage stats
4. **Loop Mode**: Iteration progress (if Ralph mode active)
5. **Context Efficiency**: Token usage and efficiency score
6. **Theory of Mind**: Satisfaction score and drift status

---

## Usage

```bash
# Full status display
/apex/status

# Show only circuit breaker state
/apex/status --breakers

# Show only loop mode progress
/apex/status --loop

# Show raw JSON state
/apex/status --json
```

---

## Output Format

```
📊 APEX v4.0 Status
━━━━━━━━━━━━━━━━━━━

Session: abc-123
Phase:   execute
Started: 2026-02-14T10:30:00Z
Mode:    default

Circuit Breakers:
  Tool calls:    23/50  (iteration)  │  87/200 (cycle)
  Errors:        1/5    (iteration)  │  3/15   (cycle)
  Same-file:     auth.ts: 4/10
  Stuck loop:    0/3 patterns
  Status:        ✅ OK

Semantic Tools:
  grepai:        ✅ Available (12 searches)
  graph-code:    ❌ Not available
  Last used:     grepai_search

Loop Mode:       ✅ Active
  Iteration:     3/10
  Phase:         EXECUTE
  Progress:      60%
  Stagnation:    0/3

Context:
  Tokens used:   28,000/200,000 (14%)
  Files loaded:  12
  Efficiency:    92%

Profile:
  Satisfaction:  0.88
  Drift:         No
```

---

## Reading the Output

### Circuit Breaker Colors
- Values below 80% of limit: normal
- Values at 80-99% of limit: warning (yellow)
- Values at limit: tripped (red)

### Semantic Tool Status
- Available: MCP server responding
- Not available: Using fallback (grep/AST)

### Loop Mode
- INIT → DISCOVER → PLAN → TASK → EXECUTE → SIMPLIFY → REVIEW → COMMIT
- Progress percentage based on completed phases

---

## State File

Raw state is stored at `~/.claude/apex/state/apex-state.json`

Use `--json` flag to dump the raw state for debugging.
