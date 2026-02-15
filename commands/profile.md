---
description: "APEX Profile - View and update user preferences for Theory of Mind"
---

# /apex/profile

Manage your APEX user profile for Theory of Mind personalization. APEX adapts its behavior based on your preferences.

---

## What It Does

The profile system tracks your preferences so APEX can:
- Match your communication style (concise vs verbose)
- Follow your coding conventions (naming, patterns, frameworks)
- Respect your workflow preferences (commit style, auto-docs, review depth)
- Detect collaboration drift and recalibrate

---

## Usage

```bash
# View current profile
/apex/profile

# Update a specific preference
/apex/profile --set communication=concise
/apex/profile --set commit_style=conventional

# Reset profile to defaults
/apex/profile --reset

# Show drift detection status
/apex/profile --drift
```

---

## Profile Location

Stored at `~/.claude/apex/state/apex-profile.json`

---

## Profile Fields

### Communication
| Field | Options | Default |
|-------|---------|---------|
| `style` | concise, verbose, balanced | balanced |
| `detail_level` | minimal, standard, comprehensive | standard |
| `emoji_usage` | none, minimal, frequent | minimal |

### Coding Preferences
| Field | Options | Default |
|-------|---------|---------|
| `naming_convention` | camelCase, snake_case, auto-detect | auto-detect |
| `preferred_patterns` | functional, oop, mixed | mixed |
| `framework_preferences` | (project-specific) | auto-detect |
| `test_style` | tdd, post-implementation, mixed | mixed |

### Workflow
| Field | Options | Default |
|-------|---------|---------|
| `commit_style` | conventional, descriptive, minimal | conventional |
| `auto_docs` | always, on-request, never | on-request |
| `review_depth` | quick, standard, thorough | standard |
| `simplify_on_commit` | always, suggest, never | suggest |

---

## Drift Detection

APEX monitors collaboration quality by tracking:
- **Satisfaction signals**: Positive/negative reactions to outputs
- **Correction frequency**: How often you correct APEX behavior
- **Style mismatches**: When output doesn't match your preferences

When drift is detected (repeated corrections in same area), APEX will:
1. Acknowledge the pattern
2. Ask for explicit preference update
3. Store the correction in your profile

---

## Viewing Profile

```
/apex/profile

📋 APEX User Profile
━━━━━━━━━━━━━━━━━━━

Communication: concise
Detail Level:  standard
Commit Style:  conventional
Auto Docs:     on-request

Satisfaction Score: 0.92
Recent Corrections: 0
Drift Detected:     No

Last Updated: 2026-01-22T10:30:00Z
```

---

## Integration

- Profile is loaded during YOLO mode startup (unless `--no-profile`)
- Used by all APEX commands to tune output style
- Updated automatically from collaboration signals
- Can be manually edited at the JSON file path
