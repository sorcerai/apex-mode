---
description: "APEX Code Simplification v4.0 - Automatic clarity improvements before commit"
---

# /apex/simplify

**Post-implementation clarity pass.** Automatically simplifies recently modified code for readability and maintainability.

---

## What Simplify Does

Runs during the VERIFY phase (before COMMIT) to:

1. **Flatten Complexity** - Reduce nesting, simplify conditionals
2. **Improve Naming** - Rename unclear variables/functions
3. **Extract Logic** - Break large functions into focused ones
4. **Remove Clutter** - Eliminate redundant code

---

## Usage

```bash
# Simplify all recently modified files
/apex/simplify

# Simplify specific file
/apex/simplify src/auth/handler.ts

# Simplify with preview (no changes)
/apex/simplify --dry-run

# Simplify with aggressive transformations
/apex/simplify --aggressive
```

---

## Simplification Rules

### Rule 1: Flatten Nested Ternaries

**Before**:
```typescript
const result = condition1 
  ? (condition2 ? value1 : value2) 
  : (condition3 ? value3 : value4);
```

**After**:
```typescript
let result: string;
if (condition1) {
  result = condition2 ? value1 : value2;
} else {
  result = condition3 ? value3 : value4;
}
```

### Rule 2: Extract Deeply Nested Code

**Before**:
```typescript
function processData(data: Data) {
  if (data.valid) {
    if (data.type === 'user') {
      if (data.permissions.length > 0) {
        for (const perm of data.permissions) {
          if (perm.active) {
            // 20 lines of logic
          }
        }
      }
    }
  }
}
```

**After**:
```typescript
function processData(data: Data) {
  if (!data.valid) return;
  if (data.type !== 'user') return;
  if (data.permissions.length === 0) return;
  
  const activePermissions = data.permissions.filter(p => p.active);
  activePermissions.forEach(perm => processPermission(perm));
}

function processPermission(perm: Permission) {
  // 20 lines of logic (extracted)
}
```

### Rule 3: Use Early Returns

**Before**:
```typescript
function validate(input: Input): Result {
  let result: Result;
  if (input) {
    if (input.isValid) {
      if (input.hasPermission) {
        result = { success: true, data: input.data };
      } else {
        result = { success: false, error: 'No permission' };
      }
    } else {
      result = { success: false, error: 'Invalid input' };
    }
  } else {
    result = { success: false, error: 'No input' };
  }
  return result;
}
```

**After**:
```typescript
function validate(input: Input): Result {
  if (!input) {
    return { success: false, error: 'No input' };
  }
  if (!input.isValid) {
    return { success: false, error: 'Invalid input' };
  }
  if (!input.hasPermission) {
    return { success: false, error: 'No permission' };
  }
  return { success: true, data: input.data };
}
```

### Rule 4: Rename Unclear Variables

**Before**:
```typescript
const d = new Date();
const u = getUser();
const r = u.permissions.filter(p => p.active);
const x = r.map(p => p.name);
```

**After**:
```typescript
const currentDate = new Date();
const user = getUser();
const activePermissions = user.permissions.filter(perm => perm.active);
const permissionNames = activePermissions.map(perm => perm.name);
```

### Rule 5: Remove Redundant Boolean Comparisons

**Before**:
```typescript
if (isValid === true) { ... }
if (hasError === false) { ... }
return condition ? true : false;
```

**After**:
```typescript
if (isValid) { ... }
if (!hasError) { ... }
return condition;
```

### Rule 6: Consolidate Duplicate Logic

**Before**:
```typescript
function handleSuccess(data: Data) {
  console.log('Success');
  analytics.track('success');
  notify('Operation completed');
  updateUI(data);
}

function handlePartialSuccess(data: Data) {
  console.log('Success');
  analytics.track('success');
  notify('Operation completed');
  updateUI(data);
  showWarning('Partial data');
}
```

**After**:
```typescript
function handleSuccess(data: Data, showPartialWarning = false) {
  console.log('Success');
  analytics.track('success');
  notify('Operation completed');
  updateUI(data);
  if (showPartialWarning) {
    showWarning('Partial data');
  }
}
```

---

## Execution Flow

```
┌─────────────────────────────────────────────┐
│            /apex/simplify                   │
├─────────────────────────────────────────────┤
│                                             │
│  1. IDENTIFY FILES                          │
│     □ Get recently modified files (git)     │
│     □ Filter to code files only             │
│     □ Exclude test files (unless asked)     │
│                                             │
│  2. ANALYZE COMPLEXITY                      │
│     □ Calculate cyclomatic complexity       │
│     □ Identify deep nesting (>3 levels)     │
│     □ Find large functions (>50 lines)      │
│     □ Detect duplicate patterns             │
│                                             │
│  3. GENERATE SUGGESTIONS                    │
│     □ Apply simplification rules            │
│     □ Preserve functionality                │
│     □ Maintain test coverage                │
│                                             │
│  4. APPLY CHANGES                           │
│     □ Make atomic changes                   │
│     □ Verify tests still pass               │
│     □ Report improvements                   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Complexity Metrics

### Before/After Tracking

```json
{
  "simplification": {
    "file": "src/auth/handler.ts",
    "before": {
      "cyclomatic_complexity": 15,
      "max_nesting_depth": 5,
      "lines": 120,
      "functions": 3
    },
    "after": {
      "cyclomatic_complexity": 8,
      "max_nesting_depth": 2,
      "lines": 95,
      "functions": 5
    },
    "improvements": [
      "Reduced complexity by 47%",
      "Extracted 2 helper functions",
      "Reduced nesting from 5 to 2 levels"
    ]
  }
}
```

---

## Integration with YOLO

In YOLO mode, simplification runs automatically during REVIEW:

```
⚡ Auto-executing...
   [1/4] ✅ Implement auth handler
   [2/4] ✅ Add validation logic
   [3/4] ✅ Update tests
   [4/4] ✅ Integration tests pass

🔍 Auto-reviewing...
   - Lint: ✅ Pass
   - Tests: ✅ Pass
   
🧹 Auto-simplifying...
   - src/auth/handler.ts: Complexity 15→8 (-47%)
   - Extracted: validateInput(), processAuth()
   - Flattened: 2 nested ternaries
   
✅ Simplified 1 file, improved readability
```

---

## Flags

| Flag | Effect |
|------|--------|
| `--dry-run` | Preview changes without applying |
| `--aggressive` | Apply all rules including controversial ones |
| `--conservative` | Only apply safe transformations |
| `--include-tests` | Also simplify test files |
| `--no-extract` | Don't create new functions |
| `--report` | Generate detailed complexity report |

---

## Skip Simplification

Add comment to skip a section:
```typescript
// apex:no-simplify
const complexButNecessary = condition1 
  ? (condition2 ? a : b) 
  : (condition3 ? c : d);
// apex:end-no-simplify
```

---

## What Simplify Does NOT Do

- ❌ Change functionality
- ❌ Modify public APIs
- ❌ Break existing tests
- ❌ Remove intentional complexity (performance optimizations)
- ❌ Simplify already-simple code
- ❌ Touch code marked with `// apex:no-simplify`
