# APEX Upstream Sources

APEX unifies several upstream methodologies and tools. This file tracks where each dependency comes from, what APEX consumes, and what local integration assumptions must be preserved when syncing.

| Component | Source | Role in APEX | Local APEX Files |
|---|---|---|---|
| PRISM | local methodology artifact (`PRISM v3.3.zip`) | Knowledge architecture methodology | `APEX.md`, `APEX_OPERATIONAL.md`, `APEX_REFERENCE.md` |
| Planning with Files | `https://github.com/OthmanAdi/planning-with-files` | Persistent workflow pattern | `commands/plan.md`, `templates/*` |
| AIDD | `https://github.com/paralleldrive/aidd` | AI-Driven Development lifecycle | `commands/discover.md`, `commands/task.md`, `commands/execute.md`, `commands/review.md`, `commands/commit.md` |
| Ralph | `https://github.com/frankbria/ralph-claude-code` | Iterative loop system with circuit breakers | `hooks/*`, `commands/resume.md`, `commands/status.md`, `state/apex-state.json.template` |
| grepai | `https://github.com/yoanbernabeu/grepai` | Semantic code search + call graph tracing | `integrations/grepai/README.md`, `mcp/grepai.json`, `skills/apex-semantic.md` |
| code-graph-rag | `https://github.com/vitali87/code-graph-rag` | Knowledge graph RAG + surgical editing concepts | `integrations/graph-code/README.md`, `mcp/graph-code.json`, YOLO/execute docs |
| Navigator | `https://github.com/alekspetrov/navigator` | Context efficiency + Theory of Mind | `skills/apex-context.md`, `skills/apex-profile.md`, `commands/simplify.md`, `commands/yolo.md` |
| Pilot | `https://github.com/alekspetrov/pilot` | Autonomous ticket-driven dev pipeline | tracked for workflow integration/evaluation |

## Local semantic stack

Do **not** regress APEX back to Ollama/Nomic defaults when syncing grepai or graph-code docs.

Canonical local semantic services:

- Embedder: `http://127.0.0.1:8090/v1/embeddings`
  - model: `intfloat/e5-base-v2`
  - dimensions: `768`
  - health: `http://127.0.0.1:8090/health`
- Reranker: `http://127.0.0.1:8091/v1/rerank`
  - model: `jinaai/jina-reranker-v1-tiny-en`
  - health: `http://127.0.0.1:8091/health`

These defaults are mirrored in:

- `mcp/local-semantic.json`
- `mcp/grepai.json`
- `mcp/settings.json.template`
- `integrations/grepai/README.md`
- `install.sh`

## Sync workflow

```bash
# Check everything
./update-apex.sh all

# Check one upstream
./update-apex.sh grepai
./update-apex.sh graph-code
./update-apex.sh navigator
```

The updater clones upstreams to `/tmp/apex-update-*` for review. It does not auto-merge upstream changes; APEX is a curated synthesis layer.
