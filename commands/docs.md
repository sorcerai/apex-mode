---
description: "APEX Documentation Builder - Auto-generate comprehensive documentation"
---

# /apex/docs

You are entering APEX Documentation phase. Automatically generate and update project documentation based on codebase analysis.

## What It Does

```
/apex/docs
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│                    APEX DOCUMENTATION BUILDER                   │
│                                                                 │
│  1. ANALYZE - Scan codebase structure                          │
│       ↓     (grepai search + graph-code query)                 │
│                                                                 │
│  2. EXTRACT - Pull code signatures, docstrings, comments       │
│       ↓     (AST parsing via graph-code)                       │
│                                                                 │
│  3. GENERATE - Create documentation artifacts                  │
│       ↓     (README, API docs, architecture)                   │
│                                                                 │
│  4. VALIDATE - Check coverage and accuracy                     │
│       ↓                                                        │
│                                                                 │
│  📚 Documentation complete                                     │
└─────────────────────────────────────────────────────────────────┘
```

## Usage

```bash
# Auto-detect what needs documentation
/apex/docs

# Specific documentation types
/apex/docs --readme           # README.md
/apex/docs --api              # API documentation
/apex/docs --architecture     # Architecture decision records
/apex/docs --changelog        # Changelog from git history
/apex/docs --contributing     # Contributing guide
/apex/docs --full             # All of the above

# Options
/apex/docs --format markdown  # Output format (markdown, rst, html)
/apex/docs --output ./docs    # Output directory
/apex/docs --update           # Update existing docs (don't overwrite)
```

## Documentation Types

### 1. README.md (`--readme`)

Generates/updates README with:
- Project title and description
- Features list (from code analysis)
- Installation instructions (from package files)
- Quick start examples (from tests/examples)
- Configuration options (from config files)
- API overview (from exports)
- Contributing section
- License info

**Analysis Sources**:
```bash
# Semantic search for key patterns
grepai search "main entry point" --json
grepai search "configuration options" --json
grepai search "public API exports" --json

# Graph query for structure
query_code_graph "What are the main modules and their purposes?"
query_code_graph "What are the exported functions and classes?"
```

### 2. API Documentation (`--api`)

Generates comprehensive API docs:
- Module/package overview
- Function signatures with types
- Class hierarchies
- Method documentation
- Parameter descriptions
- Return value documentation
- Usage examples

**Structure**:
```
docs/
├── api/
│   ├── index.md           # API overview
│   ├── modules/
│   │   ├── auth.md        # Per-module docs
│   │   ├── users.md
│   │   └── ...
│   ├── classes/
│   │   ├── UserService.md
│   │   └── ...
│   └── functions/
│       ├── validateToken.md
│       └── ...
```

**Analysis Sources**:
```bash
# Get all functions and their signatures
grepai search "function definitions" --json
query_code_graph "List all public functions with their parameters"

# Get call relationships
grepai trace callees "MainFunction" --json
query_code_graph "What functions are called by each public API?"
```

### 3. Architecture Documentation (`--architecture`)

Generates architecture docs:
- System overview diagram (ASCII/Mermaid)
- Component relationships
- Data flow descriptions
- Dependency analysis
- Design decisions (ADRs)

**Structure**:
```
docs/
├── architecture/
│   ├── overview.md        # High-level architecture
│   ├── components.md      # Component breakdown
│   ├── data-flow.md       # How data moves
│   ├── dependencies.md    # External dependencies
│   └── decisions/
│       ├── 001-auth-approach.md
│       └── ...
```

**Analysis Sources**:
```bash
# Module relationships
query_code_graph "Show all module import/export relationships"
query_code_graph "What are the main architectural layers?"

# Dependencies
grepai trace graph "EntryPoint" --depth 5 --json
query_code_graph "What external packages are used and why?"
```

### 4. Changelog (`--changelog`)

Generates changelog from git history:
- Grouped by version/date
- Categorized (Added, Changed, Fixed, Removed)
- Links to commits/PRs
- Breaking change highlights

**Format (Keep a Changelog)**:
```markdown
# Changelog

## [Unreleased]

### Added
- New authentication middleware (#123)

### Changed
- Refactored user service for better performance

### Fixed
- Login timeout issue (#456)
```

**Analysis Sources**:
```bash
# Git history
git log --oneline --since="last tag"

# Semantic grouping
grepai search "new feature" --json
grepai search "bug fix" --json
```

### 5. Contributing Guide (`--contributing`)

Generates contributor documentation:
- Development setup
- Code style guidelines
- Testing requirements
- PR process
- Issue templates

## Documentation Generation Process

### Step 1: Analyze Codebase

```bash
# 1. Get project structure
query_code_graph "List all modules and their primary purpose"

# 2. Identify public API
grepai search "exported functions and classes" --json

# 3. Find existing documentation
grepai search "docstrings and comments" --json

# 4. Analyze dependencies
query_code_graph "What are all external dependencies?"
```

### Step 2: Extract Information

For each documented item:
1. Get source code via `get_code_snippet`
2. Parse docstrings/comments
3. Extract type information
4. Find usage examples in tests

### Step 3: Generate Documentation

Template-based generation with:
- Consistent formatting
- Cross-references
- Code examples
- Mermaid diagrams where applicable

### Step 4: Validate

Check for:
- Missing documentation
- Outdated information
- Broken links
- Code example accuracy

## Output Format

```markdown
## APEX Documentation Report

### Generated Files
| File | Type | Lines | Status |
|------|------|-------|--------|
| README.md | readme | 150 | ✅ Created |
| docs/api/index.md | api | 200 | ✅ Created |
| docs/architecture/overview.md | arch | 100 | ✅ Created |
| CHANGELOG.md | changelog | 50 | ✅ Created |

### Coverage
- Functions documented: 45/52 (87%)
- Classes documented: 12/12 (100%)
- Modules documented: 8/10 (80%)

### Warnings
- Missing docstring: `src/utils/helpers.ts:calculateHash()`
- Outdated example: `docs/api/auth.md` (references removed function)

### Next Steps
- Add docstrings to undocumented functions
- Update examples in API docs
- Review architecture diagram for accuracy
```

## Integration with YOLO Mode

When running `/apex/yolo` without `--no-docs`:

1. After COMMIT phase, automatically run DOCS phase
2. Document new/changed code
3. Update README if significant changes
4. Generate changelog entry

```bash
# Full cycle including docs
/apex/yolo Add user authentication --pr

# Skip docs
/apex/yolo Quick fix --no-docs
```

## Templates

Documentation templates in `~/.config/opencode/apex/templates/docs/`:

- `readme.md.template`
- `api-module.md.template`
- `api-function.md.template`
- `architecture.md.template`
- `changelog.md.template`
- `contributing.md.template`

## Configuration

In `task_plan.md` or `notes.md`:

```yaml
# Documentation preferences
docs:
  output_dir: ./docs
  format: markdown
  include_private: false
  include_tests: false
  diagram_format: mermaid
  auto_examples: true
```

## Handoff

After documentation generation:

```
📚 APEX Documentation Complete

Generated:
- README.md (150 lines)
- docs/api/ (12 files)
- docs/architecture/ (4 files)
- CHANGELOG.md (updated)

Coverage: 92% of public API documented
Warnings: 3 items need attention

Run /apex/commit to include documentation in commit.
```
