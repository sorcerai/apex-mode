# APEX Version Tracking

## Current Version: 1.0.0
**Built**: 2026-01-08
**Builder**: Claude Opus 4.5

## Upstream Sources

| Component | Source | Version/Commit | Last Synced |
|-----------|--------|----------------|-------------|
| PRISM | /Users/ariapramesi/Downloads/PRISM v3.3.zip | v3.3 | 2026-01-08 |
| Planning with Files | github.com/OthmanAdi/planning-with-files | main | 2026-01-08 |
| AIDD | github.com/paralleldrive/aidd | main | 2026-01-08 |
| Ralph | github.com/frankbria/ralph-claude-code | main | 2026-01-08 |

## Component Mapping

### PRISM → APEX Files
- 3-layer architecture → APEX.md, APEX_OPERATIONAL.md, APEX_REFERENCE.md

### Planning with Files → APEX Files
- 3-file workflow → templates/task_plan.md, templates/notes.md, templates/deliverable.md
- Plan command → commands/plan.md

### AIDD → APEX Files
- /discover → commands/discover.md
- /task → commands/task.md
- /execute → commands/execute.md
- /review → commands/review.md
- /commit → commands/commit.md

### Ralph → APEX Files
- Circuit breakers → hooks/apex-circuit-breaker.sh
- Metrics tracking → hooks/apex-metrics.sh
- Session persistence → hooks/apex-session.sh
- State schema → state/apex-state.json

## Changelog

### 1.0.0 (2026-01-08)
- Initial unified release
- Combined all 4 systems
- Added hooks integration with settings.json
- Created update script

## Update Instructions

```bash
# Check for upstream changes
~/.claude/apex/update-apex.sh all

# Update specific component
~/.claude/apex/update-apex.sh aidd

# Then ask Claude to merge changes
"Update APEX commands from /tmp/apex-update-*/aidd"
```
