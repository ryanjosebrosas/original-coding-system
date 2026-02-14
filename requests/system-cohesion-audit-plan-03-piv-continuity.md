# Sub-Plan 03: PIV Loop Continuity

> **Parent Plan**: `requests/system-cohesion-audit-plan-overview.md`
> **Sub-Plan**: 03 of 05
> **Phase**: PIV Loop Continuity
> **Tasks**: 5
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan fixes broken handoffs between PIV Loop phases. The goal: context flows naturally from Plan → Implement → Validate → iterate without loss.

**What this sub-plan delivers**:
- Cross-command state file (`.tmp/piv-state.json`)
- Explicit handoff steps in commands
- Contradictory guidance resolved
- Session context consumed by validation commands

**Prerequisites from previous sub-plans**:
- Sub-plan 01 complete (token efficiency)
- Sub-plan 02 complete (agents connected)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `sections/02_piv_loop.md:28-38` — Handoff guidance (contradicts execution-report)
- `.opencode/commands/execution-report.md:7` — "Run in SAME conversation" constraint
- `.opencode/commands/code-review.md:55-60` — Starts fresh from git diff, no session context
- `.opencode/commands/commit.md` — Doesn't read session context
- `templates/SESSION-CONTEXT-TEMPLATE.md` — Session structure that's currently orphaned

### Files Created by Previous Sub-Plans

- `reference/validation-pyramid.md` — Canonical validation levels
- `reference/overview-guide.md` — Pattern for minimal overviews
- Agent integrations in 5 commands

---

## STEP-BY-STEP TASKS

### CREATE `templates/PIV-STATE-TEMPLATE.md`

- **IMPLEMENT**: Create template for cross-command state file:
  ```markdown
  # PIV State Template

  > Store at `.tmp/piv-state.json`. Created by `/planning`, updated by `/execute`,
  > consumed by `/code-review` and `/commit`. Deleted after `/commit` completes.

  ```json
  {
    "feature_name": "string",
    "plan_file": "requests/{feature}-plan.md",
    "session_id": "string (from execute)",
    "archon_project_id": "string or null",
    "phase": "planning|executing|validating|committing",
    "started_at": "ISO timestamp",
    "updated_at": "ISO timestamp",
    "acceptance_criteria_met": ["list of met criteria"],
    "acceptance_criteria_pending": ["list of pending criteria"],
    "notes": "any cross-command notes"
  }
  ```

  ## Usage

  - `/planning`: Create file after plan saved
  - `/execute`: Update `phase` to "executing", add `session_id`
  - `/execution-report`: Read file for context
  - `/code-review`: Read file for feature name and plan path
  - `/code-review-fix`: Read file, update `notes` with skipped issues
  - `/commit`: Read file, verify `acceptance_criteria_pending` is empty, delete file
  ```

- **PATTERN**: JSON state file pattern (simple, parseable, gitignored)
- **IMPORTS**: None
- **GOTCHA**: Keep it minimal — this is for machine passing, not human reading
- **VALIDATE**: `ls templates/PIV-STATE-TEMPLATE.md`

### UPDATE `.opencode/commands/planning.md`

- **IMPLEMENT**: Add state file creation in Phase 6 (after plan saved):
  ```markdown
  ## State File Creation

  After saving the plan, create `.tmp/piv-state.json`:

  ```bash
  mkdir -p .tmp
  cat > .tmp/piv-state.json << EOF
  {
    "feature_name": "{feature-name}",
    "plan_file": "requests/{feature-name}-plan.md",
    "phase": "planning",
    "started_at": "$(date -Iseconds)",
    "updated_at": "$(date -Iseconds)",
    "acceptance_criteria_met": [],
    "acceptance_criteria_pending": ["list from plan"],
    "notes": ""
  }
  EOF
  ```

  This file enables subsequent commands to know the current PIV context.
  ```

- **PATTERN**: State file creation
- **IMPORTS**: None
- **GOTCHA**: Use exact feature name from plan filename
- **VALIDATE**: `grep -c "piv-state.json" .opencode/commands/planning.md` (should be ≥1)

### UPDATE `.opencode/commands/execute.md`

- **IMPLEMENT**: Add state file update in Step 1 and acceptance tracking throughout:

  1. In Step 1, add:
  ```markdown
  **Read PIV state** (if `.tmp/piv-state.json` exists):
  - Load current context
  - Update `phase` to "executing"
  - Add `session_id` from session context creation
  ```

  2. In task completion, add:
  ```markdown
  After each task passes validation:
  - Move criterion from `acceptance_criteria_pending` to `acceptance_criteria_met` in `.tmp/piv-state.json`
  ```

- **PATTERN**: State file update
- **IMPORTS**: None
- **GOTCHA**: Don't fail if piv-state.json doesn't exist (backwards compatibility)
- **VALIDATE**: `grep -c "piv-state" .opencode/commands/execute.md` (should be ≥2)

### UPDATE `.opencode/commands/code-review.md`

- **IMPLEMENT**: Add state file read at start:
  ```markdown
  **Read PIV state** (if `.tmp/piv-state.json` exists):
  - Load feature name and plan file path
  - Update `phase` to "validating"
  - Read plan file for acceptance criteria context

  **If state file doesn't exist**: Ask user for feature name and plan file.
  ```

- **PATTERN**: State file read
- **IMPORTS**: None
- **GOTCHA**: Still work without state file (graceful degradation)
- **VALIDATE**: `grep -c "piv-state" .opencode/commands/code-review.md` (should be ≥1)

### UPDATE `sections/02_piv_loop.md`

- **IMPLEMENT**: Fix contradictory guidance about conversation context:

  Replace line 28 guidance with:
  ```markdown
  ### Implementation Context

  **Recommended**: Start implementation in a fresh conversation for clean context.

  **Critical**: Before switching conversations:
  1. Run `/execution-report` in the CURRENT conversation (while implementation context is active)
  2. This captures implementation reasoning for the validation phase
  3. Then switch to fresh conversation for `/code-review`

  The `.tmp/piv-state.json` file carries feature context between conversations.
  ```

- **PATTERN**: Explicit ordering prevents context loss
- **IMPORTS**: None
- **GOTCHA**: This is a core methodology file — changes affect all users
- **VALIDATE**: `grep -c "execution-report" sections/02_piv_loop.md` (should be ≥1)

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify template exists and is valid JSON structure
cat templates/PIV-STATE-TEMPLATE.md | grep -A20 '```json'

# Verify all modified commands reference state file
grep -l "piv-state" .opencode/commands/planning.md .opencode/commands/execute.md .opencode/commands/code-review.md
```

### Content Verification
```bash
# Verify phase tracking
grep '"phase"' templates/PIV-STATE-TEMPLATE.md

# Verify acceptance criteria tracking
grep "acceptance_criteria" templates/PIV-STATE-TEMPLATE.md
```

### Cross-Reference Check
```bash
# Verify state file in .gitignore
grep ".tmp" .gitignore || echo "WARNING: .tmp should be in .gitignore"
```

---

## SUB-PLAN CHECKLIST

- [x] All 5 tasks completed in order
- [x] Each task validation passed
- [x] All validation commands executed successfully
- [x] No broken references to other files

---

## HANDOFF NOTES

### Files Created
- `templates/PIV-STATE-TEMPLATE.md` — Cross-command state file template

### Files Modified
- `.opencode/commands/planning.md` — Creates state file after plan saved
- `.opencode/commands/execute.md` — Updates state file during execution
- `.opencode/commands/code-review.md` — Reads state file for context
- `sections/02_piv_loop.md` — Fixed contradictory context guidance

### Patterns Established
- **State File Pattern**: JSON file in `.tmp/` carries context between commands
- **Explicit Handoff Ordering**: execution-report MUST run before context switch

### State for Next Sub-Plan
- Cross-command state now possible
- PIV Loop phases connected via state file
- Sub-plan 04 can assume state tracking exists when connecting subsystems
