# Sub-Plan 05: Session & Memory Evolution

> **Parent Plan**: `requests/system-cohesion-audit-plan-overview.md`
> **Sub-Plan**: 05 of 05
> **Phase**: Session & Memory Evolution
> **Tasks**: 6
> **Estimated Context Load**: Low

---

## Scope

This sub-plan adds state persistence and memory discipline. The goal: sessions can resume, memory updates are explicit, and context survives across sessions.

**What this sub-plan delivers**:
- `/session-resume` command for interrupted work
- Session archival in `/commit`
- Memory update triggers in `/planning`
- Session lifecycle (create → active → paused → archived)

**Prerequisites from previous sub-plans**:
- Sub-plan 01-04 complete (all subsystems connected)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `templates/SESSION-CONTEXT-TEMPLATE.md` — Current session structure (ephemeral)
- `.opencode/commands/commit.md` — Updates memory.md but doesn't archive session
- `.opencode/commands/planning.md` — No memory update step in Phase 4
- `memory.md:69` — Mentions archival but no process
- `.opencode/commands/execute.md` — Creates session context, but no lifecycle

### Files Created by Previous Sub-Plans

- `templates/PIV-STATE-TEMPLATE.md` — Cross-command state file
- State tracking in planning/execute/code-review

---

## STEP-BY-STEP TASKS

### CREATE `.opencode/commands/session-resume.md`

- **IMPLEMENT**: Create new command for resuming interrupted work:
  ```markdown
  # Resume: Session Continuation

  Resume interrupted execution by loading session context.

  ## Usage

  ```
  /session-resume [session-id]
  ```

  If no session-id provided, list available sessions.

  ## Process

  ### Step 1: List Sessions (if no ID)

  ```bash
  ls -lt .tmp/sessions/*/context.md 2>/dev/null | head -10
  ```

  Report: "Found X sessions. Run `/session-resume {id}` to resume."

  ### Step 2: Load Session Context

  If session-id provided:
  1. Read `.tmp/sessions/{session-id}/context.md`
  2. Display:
     - Feature name and plan file
     - Current phase (from PIV state)
     - Completed tasks
     - In-progress task
     - Blockers (if any)
  3. Ask: "Resume from {in-progress task}?"

  ### Step 3: Resume Execution

  If user confirms:
  1. Read the plan file
  2. Find the in-progress task in step-by-step tasks
  3. Continue from that task

  ## Output

  Report: "Session {id} resumed. Continuing from task: {task name}"

  ## Notes

  - Sessions are stored in `.tmp/sessions/` which is typically gitignored
  - For long-term persistence, use `/commit` which archives session to memory.md
  ```

- **PATTERN**: Command template from `templates/COMMAND-TEMPLATE.md`
- **IMPORTS**: None
- **GOTCHA**: Keep command simple — it's for recovery, not primary workflow
- **VALIDATE**: `ls .opencode/commands/session-resume.md`

### UPDATE `templates/SESSION-CONTEXT-TEMPLATE.md`

- **IMPLEMENT**: Add session status field and lifecycle:
  ```markdown
  ## Session Status

  - **Status**: [initializing | active | paused | completed | archived]
  - **Last Updated**: {timestamp}

  ## Lifecycle

  1. `initializing` → Session created
  2. `active` → Execution in progress
  3. `paused` → Execution interrupted (user stopped, error)
  4. `completed` → All tasks done, awaiting commit
  5. `archived` → Session archived to memory.md

  Commands update status:
  - `/execute` creates at `initializing`, sets `active` when running
  - `/execution-report` sets `paused` if incomplete
  - `/commit` sets `archived` after archiving
  ```

- **PATTERN**: State machine pattern
- **IMPORTS**: None
- **GOTCHA**: Don't make status changes automatic — explicit is better
- **VALIDATE**: `grep -c "Session Status" templates/SESSION-CONTEXT-TEMPLATE.md` (should be ≥1)

### UPDATE `.opencode/commands/commit.md`

- **IMPLEMENT**: Add session archival step before memory update:
  ```markdown
  ## Session Archival

  Before updating memory.md:

  **If `.tmp/sessions/{id}/context.md` exists**:
  1. Read session context
  2. Extract:
     - Key decisions made during implementation
     - Blockers resolved
     - Patterns discovered
  3. Append structured summary to memory.md:
     ```markdown
     - [{date}] Session {id}: {feature} — {1-line summary of decisions/findings}
     ```
  4. Update session status to `archived`
  ```

- **PATTERN**: Archive before forget
- **IMPORTS**: None
- **GOTCHA**: Don't archive everything — just decisions and findings
- **VALIDATE**: `grep -c "Session Archival" .opencode/commands/commit.md` (should be ≥1)

### UPDATE `.opencode/commands/planning.md`

- **IMPLEMENT**: Add memory update step in Phase 4 (Strategic Design):
  ```markdown
  ## Memory Update (Key Decisions)

  After Phase 4 (Strategic Design), capture key decisions:

  **Prompt user**: "Key architectural decisions made. Add to memory.md? (y/n)"

  If yes, append:
  ```markdown
  - [{date}] Decision: {decision} — Reason: {rationale}
  ```

  This captures decisions BEFORE implementation, when rationale is fresh.
  ```

- **PATTERN**: Proactive memory capture
- **IMPORTS**: None
- **GOTCHA**: Make it optional — some plans don't have notable decisions
- **VALIDATE**: `grep -c "Memory Update" .opencode/commands/planning.md` (should be ≥1)

### UPDATE `memory.md`

- **IMPLEMENT**: Add explicit memory entry criteria:
  ```markdown
  ## Entry Criteria

  Log to memory.md if:
  - New dependency introduced
  - Architectural decision made
  - Gotcha discovered during implementation
  - Pattern deviation from established norms
  - Non-obvious fix applied
  - Session completed with learnings

  Don't log:
  - Routine changes (formatting, typos)
  - Decisions that might be reversed
  - Information already in reference guides
  ```

- **PATTERN**: Explicit criteria reduces guesswork
- **IMPORTS**: None
- **GOTCHA**: Keep criteria concise
- **VALIDATE**: `grep -c "Entry Criteria" memory.md` (should be 1)

### UPDATE `memory.md`

- **IMPLEMENT**: Add session archival pattern:
  ```markdown
  ## Session Archival

  When `/commit` completes:
  1. Read `.tmp/sessions/{id}/context.md`
  2. Extract key decisions and findings
  3. Append 1-line summary to Session Notes section
  4. Set session status to `archived`

  Archived sessions are not deleted — they remain in `.tmp/sessions/` for `/session-resume`.
  ```

- **PATTERN**: Document the archival process
- **IMPORTS**: None
- **GOTCHA**: This is documentation, not code
- **VALIDATE**: `grep -c "Session Archival" memory.md` (should be 1)

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify session-resume command exists
head -10 .opencode/commands/session-resume.md

# Verify session template has lifecycle
grep -A5 "Session Status" templates/SESSION-CONTEXT-TEMPLATE.md
```

### Content Verification
```bash
# Verify commit has archival step
grep "Session Archival" .opencode/commands/commit.md

# Verify planning has memory update step
grep "Memory Update" .opencode/commands/planning.md

# Verify memory.md has entry criteria
grep -A5 "Entry Criteria" memory.md
```

### Cross-Reference Check
```bash
# Verify memory.md still under 100 lines
wc -l memory.md
```

---

## SUB-PLAN CHECKLIST

- [x] All 6 tasks completed in order
- [x] Each task validation passed
- [x] All validation commands executed successfully
- [x] No broken references to other files

---

## HANDOFF NOTES

### Files Created
- `.opencode/commands/session-resume.md` — Resume interrupted work

### Files Modified
- `templates/SESSION-CONTEXT-TEMPLATE.md` — Added status and lifecycle
- `.opencode/commands/commit.md` — Added session archival step
- `.opencode/commands/planning.md` — Added memory update step
- `memory.md` — Added entry criteria and session archival process

### Patterns Established
- **Session Lifecycle**: initializing → active → paused → completed → archived
- **Proactive Memory Capture**: Ask during planning, not just after commit
- **Explicit Entry Criteria**: Clear rules for what belongs in memory.md

### State for Next Sub-Plan
- None (this is the final sub-plan)
- All 5 sub-plans complete
- Ready for `/commit` of entire system-cohesion-audit feature

---

## FINAL NOTES

This sub-plan completes the System Cohesion Audit. After executing:

1. Run `/prime` to verify system loads correctly
2. Test `/session-resume` with a paused session
3. Test a full PIV Loop: `/planning` → `/execute` → `/code-review` → `/commit`
4. Verify memory.md updates appear correctly
5. Run `/commit` to save all 5 sub-plans' work
