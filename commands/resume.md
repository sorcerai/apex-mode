---
description: "APEX Resume - Reset circuit breakers and continue after a trip"
---

# /apex/resume

Reset circuit breakers and continue execution after a breaker trip or interruption.

---

## What It Does

When APEX circuit breakers trip (tool call limits, error limits, stuck loops), execution pauses for safety. This command:

1. Reads current state to understand what tripped
2. Resets iteration-level counters (keeps cycle-level totals)
3. Clears the tripped flag
4. Provides context on where to resume

---

## Usage

```bash
# Resume after iteration breaker trip
/apex/resume

# Resume and reset cycle-level counters too (full reset)
/apex/resume --reset-cycle

# Resume with a different mode
/apex/resume --mode safe
/apex/resume --mode fast
```

---

## What Gets Reset

### Standard Resume (`/apex/resume`)

| Counter | Action |
|---------|--------|
| `tool_calls.iteration_current` | Reset to 0 |
| `errors.iteration_current` | Reset to 0 |
| `errors.history` | Cleared |
| `same_file_edits.files` | Cleared |
| `stuck_loop.patterns` | Cleared |
| `stuck_loop.stagnation_count` | Reset to 0 |
| `tripped` | Set to false |
| `trip_reason` | Cleared |

### Cycle Reset (`/apex/resume --reset-cycle`)

All of the above, plus:

| Counter | Action |
|---------|--------|
| `tool_calls.cycle_current` | Reset to 0 |
| `errors.cycle_current` | Reset to 0 |

---

## Resume Procedure

```
User: /apex/resume

APEX: 🔄 Resuming APEX session...

Previous state:
- Trip reason: tool_calls_iteration (50/50)
- Phase: execute (task 3/5)
- Cycle progress: iteration 2/10

Counters reset:
- Tool calls: 50 → 0 (iteration), 120 retained (cycle)
- Errors: 2 → 0 (iteration), 5 retained (cycle)

Ready to continue from: execute phase, task 3/5
```

---

## When to Use

| Scenario | Command |
|----------|---------|
| Hit iteration tool call limit | `/apex/resume` |
| Hit iteration error limit | `/apex/resume` |
| Stuck loop detected | `/apex/resume` (try different approach) |
| Hit cycle-level hard limit | `/apex/resume --reset-cycle` |
| Want to switch to safer mode | `/apex/resume --mode safe` |

---

## Safety Notes

- Resume does NOT skip the breaker check on the next tool call
- If the same pattern continues, breakers will trip again
- Cycle-level limits are a hard safety boundary - resetting them should be intentional
- Consider changing approach if breakers trip repeatedly
