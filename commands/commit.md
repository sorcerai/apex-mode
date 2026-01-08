---
description: "APEX Commit - Finalize with clean git workflow"
---

# /apex/commit

You are entering APEX Commit phase. Create a clean commit and optionally a PR.

## Pre-flight Check

1. Verify review phase passed
2. Check git status for expected changes
3. Ensure no unintended files (secrets, temp files, logs)
4. Confirm working directory matches expectations

## Pre-commit Validation

```bash
# Check what's staged
git status

# Verify no secrets
git diff --cached | grep -iE "(password|secret|api_key|token)" && echo "⚠️ Possible secrets!"

# Check for temp files
git status | grep -E "\.(log|tmp|bak|swp)$" && echo "⚠️ Temp files detected!"
```

## Commit Message Generation

Read task_plan.md and notes.md to generate a meaningful commit message.

### Format
```
type(scope): subject

[body - what changed and why]

[footer - references]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes nor adds
- `test`: Adding tests
- `chore`: Maintenance tasks

### Example
```
feat(auth): add JWT token refresh mechanism

Implement automatic token refresh to prevent session expiration
during active use. Includes:
- RefreshToken service with configurable expiry
- Middleware to intercept 401 responses
- Token storage with secure HttpOnly cookies

Closes #123

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Commit Process

### Step 1: Stage Changes
```bash
# Add specific files (preferred)
git add [files from deliverable.md]

# Or stage all (verify first!)
git status  # Review carefully
git add -A
```

### Step 2: Create Commit
```bash
git commit -m "$(cat <<'EOF'
type(scope): subject

Body explaining what and why.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Step 3: Verify Commit
```bash
git log -1  # Check commit looks right
git show --stat  # Verify files included
```

## Optional: Create PR

If user requests or on feature branch:

### Check Branch Status
```bash
git branch  # Confirm not on main/master
git status  # Confirm up to date with remote
```

### Push Branch
```bash
git push -u origin $(git branch --show-current)
```

### Create PR
```bash
gh pr create --title "type(scope): subject" --body "$(cat <<'EOF'
## Summary
[From task_plan.md objective]

## Changes
[From deliverable.md code changes]

## Testing
[From deliverable.md validation]

## Checklist
- [x] Tests pass
- [x] Lint passes
- [x] Build succeeds
- [x] Documentation updated

---
🤖 Generated with APEX (Autonomous Planning & EXecution)
EOF
)"
```

## Update Planning Files

### task_plan.md
- Mark all phases complete
- Add final progress log entry
- Note commit hash

```markdown
## Progress Log
| Date | Phase | Status | Notes |
|------|-------|--------|-------|
| [date] | Commit | Complete | SHA: [hash], PR: #[number] |
```

### notes.md
- Add final session entry
- Document what was delivered
- Clear "Context for Next Session"

### deliverable.md
- Complete handoff checklist
- Add commit/PR references
- Mark as complete

## Reset APEX State

After successful commit:
```json
{
  "current_session": null,
  "circuit_breakers": {
    "tool_calls": { "current": 0 },
    "errors": { "current": 0 },
    "same_file_edits": { "files": {} },
    "stuck_loop": { "patterns": [] }
  }
}
```

## Output Format

### Commit Only
```
✅ APEX Commit Complete

Commit: [short hash]
Message: [type(scope): subject]
Files: [N] changed (+[additions]/-[deletions])

Planning files updated:
- task_plan.md: Marked complete
- notes.md: Session logged
- deliverable.md: Handoff complete

🎉 Task complete! Start a new task with /apex/discover
```

### With PR
```
✅ APEX Commit & PR Complete

Commit: [short hash]
Branch: [branch name]
PR: #[number] - [title]
URL: [PR URL]

Planning files updated and archived.

🎉 PR ready for review!
```

## Cleanup Options

### Archive Planning Files
```bash
mkdir -p .apex-archive/[date]
mv task_plan.md notes.md deliverable.md .apex-archive/[date]/
```

### Keep for Reference
Leave files in place but mark as complete.

### Delete
```bash
rm task_plan.md notes.md deliverable.md
```

Ask user preference if unclear.

## Error Handling

### Commit Fails (pre-commit hook)
```
❌ Commit rejected by pre-commit hook

Error: [hook output]

Fix the issues and run /apex/commit again.
If hook is wrong, user can: git commit --no-verify
```

### Push Fails
```
❌ Push failed

Error: [git error]

Common causes:
- Remote has new commits: git pull --rebase
- No upstream: git push -u origin [branch]
- Permission denied: Check credentials
```

### PR Creation Fails
```
❌ PR creation failed

Error: [gh error]

Manual alternative:
1. Visit: [repo URL]/compare/[branch]
2. Create PR manually
3. Use body from deliverable.md
```
