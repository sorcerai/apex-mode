# APEX Version Tracking

## Current Version: 4.0.1
**Built**: 2026-02-15
**Builder**: Claude Opus 4.6

## Upstream Sources

| Component | Source | Version/Commit | Last Synced |
|-----------|--------|----------------|-------------|
| PRISM | /Users/ariapramesi/Downloads/PRISM v3.3.zip | v3.3 | 2026-01-08 |
| Planning with Files | github.com/OthmanAdi/planning-with-files | main | 2026-01-08 |
| AIDD | github.com/paralleldrive/aidd | main | 2026-01-08 |
| Ralph | github.com/frankbria/ralph-claude-code | main | 2026-01-08 |
| grepai | github.com/yoanbernabeu/grepai | main | 2026-01-21 |
| code-graph-rag | github.com/vitali87/code-graph-rag | main | 2026-01-21 |
| Navigator | github.com/alekspetrov/navigator | v5.8.0 | 2026-01-22 |
| Pilot | github.com/alekspetrov/pilot | main | 2026-02-15 |

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

### grepai (v3.0) → APEX Files
- Integration guide → integrations/grepai/README.md
- MCP config → mcp/grepai.json
- Semantic skill → skills/apex-semantic.md

### code-graph-rag (v3.0) → APEX Files
- Integration guide → integrations/graph-code/README.md
- MCP config → mcp/graph-code.json
- Surgical editing → integrated into YOLO mode

### Navigator (v4.0) → APEX Files
- Context Efficiency → skills/apex-context.md
- Theory of Mind → skills/apex-profile.md
- Code Simplification → commands/simplify.md
- Enhanced Loop Mode → commands/yolo.md (APEX_STATUS block)
- State Schema → state/apex-state.json.template (expanded)
- Profile Schema → state/apex-profile.json.template (new)

### Pilot (v4.0.1) → APEX Files
- Tracked as upstream source for evaluation
- Autonomous ticket-driven dev pipeline (companion to Navigator)
- Signal Protocol v2 integration with Navigator v6.2.1+

## Changelog

### 4.0.1 (2026-02-15)
- **Fix**: Hook-to-state schema mismatch - removed phantom `.current` fields, hooks now use `iteration_current`/`cycle_current`
- **Fix**: Semantic tools schema mismatch - installer/circuit-breaker now use nested `available.grepai` path
- **Fix**: Test fixtures updated from v3 to v4 schema (42→48 tests)
- **Fix**: Version strings updated from v3.0/v1.0.0 to v4.0 across all files
- **Fix**: Installer copies repo MCP template instead of inline (preserves `OLLAMA_MODEL`)
- **Fix**: APEX.md table syntax corrected
- **Fix**: APEX_REFERENCE.md code examples updated to v4 schema
- **New**: Commands `profile.md`, `resume.md`, `status.md`, `help.md`
- **New**: `templates/docs/` with 6 documentation templates
- **New**: Pilot tracked as upstream source (alekspetrov/pilot)
- **Updated**: `update-apex.sh` covers all 8 components (added grepai, graph-code, navigator, pilot)

### 4.0.0 (2026-01-22)
- **Context Efficiency**: 92% token savings via lazy loading (from Navigator)
- **Theory of Mind**: User profile + collaboration drift detection (from Navigator)
- **Enhanced Loop Mode**: APEX_STATUS blocks, dual-condition exit, stagnation detection (from Navigator)
- **Code Simplification**: Auto-simplify complex code before commit (from Navigator)
- **OpenTelemetry Metrics**: Token tracking, efficiency scores (from Navigator)
- **New Commands**: `/apex/simplify`, `/apex/profile`
- **New Flags**: `--no-simplify`, `--no-profile`, `--verbose`
- **Enhanced State**: Extended apex-state.json with loop mode, context budget, ToM fields

### 3.0.0 (2026-01-21)
- **Semantic Intelligence**: grepai + Graph-Code integration
- **Documentation Builder**: Auto-generate README, API, Architecture docs
- **Enhanced YOLO**: Full tool orchestration with semantic search
- **MCP Templates**: Pre-configured server settings for all tools
- **Graceful Degradation**: Works without semantic tools
- **Updated Hooks**: Track semantic tool usage in metrics

### 2.0.0 (2026-01-10)
- **Ralph Loop Mode**: `--until` flag for iterative execution
- **Two-tier counters**: Soft (per-iteration) and hard (per-cycle) limits
- **New commands**: `/apex/resume`, `/apex/status`, `/apex/help`
- **Coordinator hook**: Unified Stop hook with exit code 2 magic
- **PROMPT.md template**: Invariant task definition for loops

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
