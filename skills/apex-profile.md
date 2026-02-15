---
description: "APEX Theory of Mind v4.0 - Remember user preferences, detect collaboration drift"
alwaysApply: false
---

# APEX Theory of Mind (ToM) Skill

**Version**: 4.0.0  
**Purpose**: Bilateral intelligence - understand the user, help the user understand you.

---

## What is Theory of Mind?

Understanding that others have different:
- Knowledge states (what they know)
- Beliefs (what they think is true)
- Preferences (how they like things done)
- Communication styles (how they express themselves)

APEX v4.0 builds a profile of user preferences and detects when collaboration is drifting.

---

## User Profile System

### Profile Storage

Location: `~/.claude/apex/state/apex-profile.json`

```json
{
  "version": "4.0.0",
  "user_profile": {
    "communication": {
      "verbosity": "concise",
      "explanation_depth": "minimal",
      "prefers_examples": true,
      "asks_before_acting": false
    },
    "coding": {
      "languages": ["typescript", "python", "go"],
      "frameworks": ["nextjs", "fastapi"],
      "patterns": ["functional", "immutable"],
      "test_style": "tdd",
      "comment_preference": "minimal"
    },
    "workflow": {
      "commit_style": "conventional",
      "branch_naming": "feature/ticket-description",
      "review_before_commit": true,
      "auto_docs": false
    },
    "corrections": [],
    "preferences_learned": []
  },
  "collaboration_state": {
    "satisfaction_score": 0.85,
    "recent_corrections": 0,
    "last_checkpoint": null,
    "drift_indicators": []
  },
  "updated": "2026-01-22T10:00:00Z"
}
```

---

## Profile Learning

### Implicit Learning (Automatic)

Detect preferences from user behavior:

| User Action | Inference |
|-------------|-----------|
| Frequently says "just do it" | `asks_before_acting: false` |
| Says "shorter please" | `verbosity: concise` |
| Uses arrow functions | `patterns: ["functional"]` |
| Writes tests first | `test_style: "tdd"` |
| Uses conventional commits | `commit_style: "conventional"` |

### Explicit Learning (From Corrections)

When user corrects output:
```json
{
  "corrections": [
    {
      "context": "Asked for verbose explanation",
      "correction": "Just show the code",
      "learned": "explanation_depth: minimal",
      "timestamp": "2026-01-22T10:00:00Z"
    }
  ]
}
```

After 2+ similar corrections → Update profile permanently.

### Proactive Preference Discovery

At session start (if profile sparse):
```
I notice I don't have your preferences saved yet.
Quick questions (answer or skip):
1. Verbose explanations or just code?
2. Ask before major changes or just do it?
3. Any frameworks/patterns you prefer?

(These are saved for future sessions)
```

---

## Collaboration Quality Detection

### Satisfaction Signals

**Positive** (increase score):
- User accepts output without changes
- User says "perfect", "thanks", "great"
- User proceeds to next task
- Output merged without modifications

**Negative** (decrease score):
- User edits output manually
- User asks for redo
- User expresses frustration
- Multiple attempts at same task

### Satisfaction Score

```
0.0 ─────────────────────────── 1.0
BAD        NEUTRAL         EXCELLENT

< 0.3  →  ALERT: Major recalibration needed
0.3-0.5 → WARNING: Check understanding
0.5-0.7 → OK: Normal variance
0.7-0.9 → GOOD: Well-calibrated
> 0.9  →  EXCELLENT: Strong alignment
```

### Drift Detection

**Drift Indicators**:
1. Satisfaction score dropping over 3+ interactions
2. User repeating same correction type
3. User switching to more explicit instructions
4. Increasing edit distance between output and what user wants

**When Drift Detected**:
```
I notice my last few outputs needed corrections.
Let me recalibrate:

My understanding: [summary of what I think you want]
Your corrections suggested: [patterns from corrections]

Am I on the right track now?
```

---

## Verification Checkpoints

### When to Verify

Trigger verification before high-stakes actions:

| Situation | Verification Type |
|-----------|-------------------|
| Destructive operation (delete, overwrite) | Explicit confirmation |
| Architectural decision | Summarize + ask |
| First task with new user | Check understanding |
| After 3+ low-satisfaction outputs | Recalibration |
| Task complexity: XL | Phased check-ins |

### Verification Patterns

**Understanding Check**:
```
Before I proceed:
- Task: [1 sentence summary]
- Approach: [key approach]
- Risk: [main risk if any]

Correct?
```

**Recalibration Check**:
```
I want to make sure I'm aligned with your preferences:
- You prefer [observed preference]
- For [task type], you usually want [pattern]

Should I adjust anything?
```

**High-Stakes Check**:
```
This will [irreversible action].
Files affected: [list]
Reversible: [yes/no]

Type "confirm" to proceed.
```

---

## Profile Application

### Automatic Style Adaptation

Based on profile, adjust:

```
verbosity: concise
→ Skip preambles, minimal explanations, just output

verbosity: detailed  
→ Explain reasoning, show alternatives, discuss tradeoffs

asks_before_acting: false
→ Proceed with reasonable defaults, report what was done

asks_before_acting: true
→ Present options, wait for selection
```

### Code Style Matching

```
patterns: ["functional", "immutable"]
→ Use map/filter/reduce, const, spread operators

patterns: ["oop", "mutable"]
→ Use classes, methods, instance variables

comment_preference: "jsdoc"
→ Add JSDoc comments to functions

comment_preference: "minimal"
→ Only comment non-obvious logic
```

---

## Profile Commands

### View Profile
```
/apex/profile
```

Shows current profile summary.

### Update Profile
```
/apex/profile set verbosity=concise
/apex/profile set test_style=tdd
```

### Reset Profile
```
/apex/profile reset
```

Clears learned preferences.

### Export Profile
```
/apex/profile export
```

Outputs JSON for backup/transfer.

---

## Integration with APEX Workflow

### Discovery Phase
- Check profile for preferred frameworks
- Adapt question verbosity to user preference

### Execute Phase
- Apply coding style preferences
- Match comment style
- Use preferred patterns

### Review Phase
- Adapt feedback verbosity
- Highlight issues in user's preferred format

### Commit Phase
- Use preferred commit message style
- Apply branch naming convention

---

## Privacy and Transparency

### What's Stored
- Communication preferences
- Coding style preferences
- Workflow preferences
- Recent corrections (last 10)
- Satisfaction score

### What's NOT Stored
- Actual code content
- Personal information
- Project details
- Conversation history

### User Control
- Profile is local to machine
- User can view anytime
- User can reset anytime
- Preferences are explicit (user sees what was learned)
