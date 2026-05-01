---
description: "APEX Pilot Integration - Ticket-driven autonomous pipeline patterns"
---

# /apex/pilot

**Ticket-driven long-job orchestration.** This command documents how APEX should interoperate with Pilot-style task pipelines: issue → branch/worktree → plan → implement → quality gates → review → PR/handoff.

APEX does not vendor Pilot. It borrows the proven workflow primitives and can hand off to an installed `pilot` binary when available.

---

## What Pilot Adds to APEX

From upstream Pilot:

- **Ticket-first execution**: work starts from a GitHub/Linear/Jira/Asana/Plane issue or a structured task file.
- **Branch/worktree isolation**: each task gets its own execution branch.
- **Quality gates**: test/lint/build/security checks before completion.
- **Self-review**: agent reviews its own diff before user review.
- **Sequential/parallel modes**: sequential prevents conflicts; parallel uses independent worktrees.
- **Budget controls**: cost/time caps for long-running autonomous work.
- **Signal Protocol v2**: structured completion messages in `pilot-signal` code blocks.

---

## Usage

```bash
# Create a Pilot-style task handoff file for APEX
/apex/pilot Create a GitHub issue handoff for this task

# If pilot CLI is installed, run a task with opencode backend
pilot task "Implement caching" --backend opencode --budget

# Run an issue directly through Pilot
pilot github run 123 --backend opencode

# Start issue polling safely
pilot start --github --autopilot=prod
```

---

## APEX Native Flow

When Pilot itself is not installed, use the APEX-native equivalent:

1. **Intake**
   - Capture title, description, acceptance criteria, constraints, linked files.
   - Write to `task_plan.md` or `.agent/tasks/<id>.md`.

2. **Isolation**
   - Use `git worktree` for large/parallel work.
   - Branch naming: `apex/<ticket-id>-<slug>` or `pilot/<ticket-id>`.

3. **Plan**
   - Use `/apex/plan`.
   - Include quality gates and acceptance criteria.

4. **Execute**
   - Use `/apex/yolo --safe --no-docs` for safe autonomous execution.
   - Use `/apex/swarm --dry-run` before parallel execution.

5. **Quality Gates**
   - Run project tests, lint, typecheck, build.
   - Retry once with failure output; trip breaker if repeated.

6. **Self Review**
   - Compare ticket requirements with changed files.
   - Verify every acceptance criterion.
   - Check for missing tests/docs.

7. **Signal Completion**
   - Emit `pilot-signal` JSON block.
   - Update `deliverable.md` and/or PR body.

---

## Signal Protocol v2

Completion must be explicit and machine-parseable:

```pilot-signal
{"v":2,"type":"exit","success":true,"reason":"All acceptance criteria met; tests pass"}
```

Failure/blocker:

```pilot-signal
{"v":2,"type":"blocked","success":false,"reason":"Cannot proceed without API credentials"}
```

Supported signal types:

| Type | Meaning |
|---|---|
| `exit` | Task complete; exit loop if heuristics also pass |
| `blocked` | Human/external dependency required |
| `stagnant` | Loop is repeating without progress |
| `handoff` | Stop and hand off with current state |

Use `functions/signal_parser.py` to extract signals from logs or deliverables.

---

## Quality Gate Template

```yaml
quality_gates:
  test: npm test || pytest || cargo test || go test ./...
  lint: npm run lint || ruff check . || cargo clippy || golangci-lint run
  build: npm run build || cargo build || go build ./...
  security: optional
retry_policy:
  gate_retries: 1
  agent_retries: 1
budget:
  max_minutes: 60
  max_tool_calls: 200
  max_cost_usd: null
```

---

## APEX Completion Checklist

Before completion:

- [ ] Branch/worktree isolated if task is large.
- [ ] Acceptance criteria copied into plan.
- [ ] Code implemented.
- [ ] Tests/lint/build pass or failures documented.
- [ ] Code simplified for clarity.
- [ ] Self-review completed.
- [ ] `pilot-signal` emitted.
- [ ] `deliverable.md` updated.
- [ ] User can review the diff.

---

## When To Use Real Pilot vs APEX

Use **real Pilot** when:

- You want GitHub/Linear/Jira/Asana/Plane polling.
- You want automatic PR creation and autopilot modes.
- You want 24/7 backlog processing.

Use **APEX** when:

- You want an interactive long-job harness from opencode.
- You want manual review before PR/push.
- You want local worktree execution without external ticket integration.

---

## Safety Defaults

- Default autopilot mode should be `prod` unless explicitly changed.
- Do not auto-merge from APEX.
- Do not push unless user asks.
- Prefer budgeted, isolated worktrees for long jobs.
