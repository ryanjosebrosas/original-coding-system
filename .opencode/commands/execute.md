---
description: Execute an implementation plan
argument-hint: [path-to-plan]
---

# Execute: Implement from Plan

## Plan to Execute

Read plan file: `$ARGUMENTS`

## Execution Instructions

### 0.5. Detect Plan Type

Read the plan file.

**If file contains `<!-- PLAN-SERIES -->`**: Extract sub-plan paths from PLAN INDEX. Report: "Detected plan series with N sub-plans." Proceed to Series Mode (Step 2.5).

**If no marker**: Standard single plan — proceed normally, skip series-specific steps.

### 1. Read and Understand

- Read the ENTIRE plan carefully — all tasks, dependencies, validation commands, testing strategy
- Check `memory.md` for gotchas related to this feature area

**If ContextScout available** (`ls .opencode/agents/subagent-contextscout.md`):
- Launch `@subagent-contextscout` with query: "patterns for {plan topic}"
- Cache findings for reference during execution
- Skip if agent not available

**Read PIV state** (if `.tmp/piv-state.json` exists):
- Load current context (feature name, phase, acceptance criteria)
- Update `phase` to "executing"
- If session initialized, add `session_id` to state

**If state file doesn't exist**: Continue without it (backwards compatible).

### 1.25. Plan Validation (optional)

**If plan-validator agent exists** in `.opencode/agents/`: Use the @plan-validator agent to validate the plan structure. Review findings. If Critical issues found, report to user before proceeding. If no critical issues, continue.

**If agent not available**: Skip — proceed to Archon setup.

### 1.3. Initialize Session Context (for complex plans)

**If plan has 4+ tasks OR involves multiple agents**:

1. Generate session ID: `{feature-name}-{YYYYMMDD-HHMM}`
2. Create session directory: `mkdir -p .tmp/sessions/{session-id}`
3. Create context file from `templates/SESSION-CONTEXT-TEMPLATE.md`
4. Populate sections:
   - Objective: from plan's Feature Description
   - Context Files: from plan's Relevant Codebase Files
   - Reference Files: from plan's Patterns to Follow
   - Archon: project_id and task_ids (from Step 1.5)
5. Report: "Session initialized at `.tmp/sessions/{session-id}/context.md`"

**If simple plan (1-3 tasks)**: Skip session initialization — direct execution is simpler.

### 1.5. Archon Setup (if available)

Create project and tasks: `manage_project("create", ...)`, then `manage_task("create", ...)` for each plan task with dependency-based task_order. Skip if Archon unavailable.

### 2. Execute Tasks in Order

For EACH task in "Step by Step Tasks":

**a.** Read the task and any existing files being modified.

**b.** **Archon** (if available): `manage_task("update", task_id="...", status="doing")` — only ONE task in "doing" at a time.

**c.** Implement the task following specifications exactly. Maintain consistency with existing patterns. If session context exists, update Progress Tracking section with current task.

**d.** Verify: check syntax, imports, types after each change.

**e.** **Archon** (if available): `manage_task("update", task_id="...", status="review")`

**f.** **Update PIV state** (if `.tmp/piv-state.json` exists): Move completed criterion from `acceptance_criteria_pending` to `acceptance_criteria_met`.

### 2.5. Series Mode Execution (if plan series detected)

For each sub-plan in PLAN INDEX order:

1. Read sub-plan file and shared context from overview
2. Execute tasks using Step 2 process (a → e)
3. Run sub-plan's validation commands
4. Read HANDOFF NOTES for state to carry forward
5. Report: "Sub-plan {N}/{total} complete."

**If a sub-plan fails**: Stop, report which sub-plan/task failed. Don't continue — failed state propagates.

### 3. Implement Testing Strategy

Create all test files specified in the plan. Implement test cases. Ensure edge case coverage.

### 4. Run Validation Commands

Execute ALL validation commands from the plan in order. Fix failures before continuing.

### 5. Final Verification

- All tasks completed
- All tests passing
- All validations pass
- Code follows project conventions

**If BuildAgent available** (`ls .opencode/agents/subagent-buildagent.md`):
- Launch `@subagent-buildagent` to validate integrated code
- Fix any build errors before marking complete
- Skip if agent not available

**Archon** (if available): `manage_task("update", task_id="...", status="done")` for all tasks. `manage_project("update", ..., description="Implementation complete, ready for commit")`

### 6. Update Plan Checkboxes

Check off met items in ACCEPTANCE CRITERIA (`- [ ]` → `- [x]`) and COMPLETION CHECKLIST. Note unmet criteria in Output Report.

## Output Report

### Completed Tasks
- List all tasks completed, files created, files modified

### Tests Added
- Test files, test cases, results

### Validation Results
```bash
# Output from each validation command
```

### Ready for Commit
- Confirm all changes complete and validations pass

---

## Next Steps (in order)

**1. Review execution** (optional):
```
/execution-report
```
Generates summary at `requests/execution-reports/{feature-name}-report.md`

**2. Code review** (recommended):
```
/code-review
```
Reviews implementation quality. Output at `requests/code-reviews/{feature-name}-review.md`

**3. Commit**:
```
/commit
```
Saves work with conventional commit message.

**4. Create PR** (if applicable):
```
/create-pr
```

---

## Notes

- Document issues not addressed in the plan
- Explain any deviations from the plan
- Fix failing tests before completing
- Don't skip validation steps
