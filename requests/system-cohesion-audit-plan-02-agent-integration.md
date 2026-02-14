# Sub-Plan 02: Command-Agent Integration

> **Parent Plan**: `requests/system-cohesion-audit-plan-overview.md`
> **Sub-Plan**: 02 of 05
> **Phase**: Command-Agent Integration
> **Tasks**: 6
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan connects commands to agents that should invoke them. The goal: commands that discover context, validate builds, and manage tasks using the agent infrastructure.

**What this sub-plan delivers**:
- ContextScout added to 5 commands that need it
- BuildAgent added as validation gate
- command-agent-mapping.md updated to reflect reality
- Core agent delegation pattern documented

**Prerequisites from previous sub-plans**:
- Sub-plan 01 complete (token efficiency makes agent additions sustainable)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `.opencode/commands/planning.md` — Missing ContextScout in Phase 1
- `.opencode/commands/execute.md` — Missing ContextScout at start, BuildAgent at end
- `.opencode/commands/code-review-fix.md` — Missing ContextScout before fixes
- `.opencode/commands/end-to-end-feature.md` — Missing ContextScout in Step 1
- `.opencode/commands/commit.md` — Has TestEngineer as suggestion, could have BuildAgent
- `reference/command-agent-mapping.md` — Has `/quick-github-setup` which doesn't exist

### Files Created by Previous Sub-Plans

- `reference/validation-pyramid.md` — Canonical validation levels
- `reference/overview-guide.md` — Pattern for minimal overviews

---

## STEP-BY-STEP TASKS

### UPDATE `.opencode/commands/planning.md`

- **IMPLEMENT**: Add ContextScout invocation in Phase 1 (Feature Understanding), after memory.md check:
  ```markdown
  **If ContextScout available** (`ls .opencode/agents/subagent-contextscout.md`):
  - Launch `@subagent-contextscout` with query: "{feature area} patterns"
  - Review findings for existing patterns that should inform planning
  - Skip if agent not available
  ```

- **PATTERN**: Optional Agent Pattern from `command-agent-mapping.md:35-48`
- **IMPORTS**: None (markdown)
- **GOTCHA**: Insert BEFORE the "Parse feature request" step, not after
- **VALIDATE**: `grep -c "ContextScout" .opencode/commands/planning.md` (should be ≥1)

### UPDATE `.opencode/commands/execute.md`

- **IMPLEMENT**: Add two agent invocations:
  
  1. ContextScout at start (Step 1, after plan file read):
  ```markdown
  **If ContextScout available** (`ls .opencode/agents/subagent-contextscout.md`):
  - Launch `@subagent-contextscout` with query: "patterns for {plan topic}"
  - Cache findings for reference during execution
  - Skip if agent not available
  ```
  
  2. BuildAgent at end (after all tasks, before completion checklist):
  ```markdown
  **If BuildAgent available** (`ls .opencode/agents/subagent-buildagent.md`):
  - Launch `@subagent-buildagent` to validate integrated code
  - Fix any build errors before marking complete
  - Skip if agent not available
  ```

- **PATTERN**: Optional Agent Pattern
- **IMPORTS**: None
- **GOTCHA**: BuildAgent is for END of execution, not per-task (per-task validation stays)
- **VALIDATE**: `grep -c "BuildAgent" .opencode/commands/execute.md` (should be ≥1)

### UPDATE `.opencode/commands/code-review-fix.md`

- **IMPLEMENT**: Add ContextScout invocation at start (before examining issues):
  ```markdown
  **If ContextScout available** (`ls .opencode/agents/subagent-contextscout.md`):
  - Launch `@subagent-contextscout` with query: "{component from review} architecture"
  - Understanding existing patterns helps make better fix decisions
  - Skip if agent not available
  ```

- **PATTERN**: Optional Agent Pattern
- **IMPORTS**: None
- **GOTCHA**: Don't invoke ContextScout for trivial fixes (typos, formatting) — only architectural issues
- **VALIDATE**: `grep -c "ContextScout" .opencode/commands/code-review-fix.md` (should be ≥1)

### UPDATE `.opencode/commands/end-to-end-feature.md`

- **IMPLEMENT**: Add ContextScout invocation in Step 1 (Prime):
  ```markdown
  **If ContextScout available** (`ls .opencode/agents/subagent-contextscout.md`):
  - Launch `@subagent-contextscout` with query: "{feature description} patterns"
  - Context discovery informs autonomous planning
  - Skip if agent not available
  ```

- **PATTERN**: Optional Agent Pattern
- **IMPORTS**: None
- **GOTCHA**: e2e runs autonomously — agent findings should inform planning, not block it
- **VALIDATE**: `grep -c "ContextScout" .opencode/commands/end-to-end-feature.md` (should be ≥1)

### UPDATE `.opencode/commands/commit.md`

- **IMPLEMENT**: Enhance validation gate with BuildAgent:
  ```markdown
  **Before committing**, validate:

  **If BuildAgent available** (`ls .opencode/agents/subagent-buildagent.md`):
  - Launch `@subagent-buildagent` for pre-commit validation
  - Fix any errors before proceeding
  - Skip if agent not available

  **If TestEngineer available and no tests exist** (`ls .opencode/agents/subagent-testengineer.md`):
  - Suggest running `@subagent-testengineer` to add tests
  ```

- **PATTERN**: Optional Agent Pattern
- **IMPORTS**: None
- **GOTCHA**: Keep TestEngineer as suggestion (not blocking) for feat/fix commits
- **VALIDATE**: `grep -c "BuildAgent" .opencode/commands/commit.md` (should be ≥1)

### UPDATE `reference/command-agent-mapping.md`

- **IMPLEMENT**: Fix the mapping to reflect reality:
  
  1. Replace `/quick-github-setup` with `/setup-github-automation` (line 29)
  2. Update the Quick Reference table with new agent integrations:
  ```markdown
  | `/planning` | ContextScout | Phase 1 (if available) | No |
  | `/execute` | ContextScout, BuildAgent | Start + End (if available) | No |
  | `/code-review-fix` | ContextScout, BuildAgent | Start + End (if available) | No |
  | `/end-to-end-feature` | ContextScout | Step 1 (if available) | No |
  | `/commit` | BuildAgent, TestEngineer | Pre-commit (if available) | No |
  ```

- **PATTERN**: Keep table format consistent with existing entries
- **IMPORTS**: None
- **GOTCHA**: Don't remove the No-Change Commands section, just fix the name
- **VALIDATE**: `grep "setup-github-automation" reference/command-agent-mapping.md` (should exist)

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify all modified commands still have valid markdown structure
for f in planning execute code-review-fix end-to-end-feature commit; do
  head -5 .opencode/commands/$f.md
done
```

### Content Verification
```bash
# Verify ContextScout added to all 5 target commands
grep -l "ContextScout" .opencode/commands/planning.md .opencode/commands/execute.md .opencode/commands/code-review-fix.md .opencode/commands/end-to-end-feature.md

# Verify BuildAgent added to execute and commit
grep -l "BuildAgent" .opencode/commands/execute.md .opencode/commands/commit.md

# Verify mapping file fixed
grep "setup-github-automation" reference/command-agent-mapping.md
```

### Cross-Reference Check
```bash
# Verify all agent files referenced actually exist
for agent in contextscout buildagent testengineer; do
  ls .opencode/agents/subagent-$agent.md && echo "$agent exists"
done
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
- None (all updates to existing files)

### Files Modified
- `.opencode/commands/planning.md` — Added ContextScout in Phase 1
- `.opencode/commands/execute.md` — Added ContextScout at start, BuildAgent at end
- `.opencode/commands/code-review-fix.md` — Added ContextScout at start
- `.opencode/commands/end-to-end-feature.md` — Added ContextScout in Step 1
- `.opencode/commands/commit.md` — Added BuildAgent to validation gate
- `reference/command-agent-mapping.md` — Fixed `/quick-github-setup` → `/setup-github-automation`, updated table

### Patterns Established
- **ContextScout as Universal First Step**: Commands that analyze or implement should start with context discovery
- **BuildAgent as Validation Gate**: Commands that complete work should validate the build

### State for Next Sub-Plan
- 5 commands now have ContextScout integration
- 3 commands now have BuildAgent integration
- Mapping document accurate for first time
- Sub-plan 03 can assume agents are connected when fixing PIV Loop handoffs
