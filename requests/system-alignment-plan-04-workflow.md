# Sub-Plan 04: Workflow Continuity

> **Parent Plan**: `requests/system-alignment-plan-overview.md`
> **Sub-Plan**: 4 of 4
> **Phase**: Workflow Continuity
> **Tasks**: 6
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan fixes broken chains between workflow steps and adds explicit handoffs.

**What this sub-plan delivers**:
- All workflow steps output explicit next-step commands with file paths
- /end-to-end-feature includes code review step
- Feature name propagation consistent across commands
- /execution-report chains to /system-review

**Prerequisites from previous sub-plans**:
- Sub-plan 01: Documentation accurate
- Sub-plan 02: Templates exist for all output formats
- Sub-plan 03: Agent integration robust

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `.opencode/commands/planning.md` (lines 192-212) — Output section
- `.opencode/commands/execute.md` (lines 110-120) — Output section
- `.opencode/commands/code-review.md` (lines 85-95) — Output section
- `.opencode/commands/execution-report.md` (lines 80-95) — Output section
- `.opencode/commands/end-to-end-feature.md` (full) — Full workflow chain
- `.opencode/commands/create-pr.md` (line 154) — Circular reference issue

### Audit Findings to Address

| Break | Location | Fix |
|-------|----------|-----|
| BREAK | planning.md:212 → execute | Output explicit `/execute requests/{feature}-plan.md` |
| BREAK | execute.md:116 skips execution-report | Add optional step suggestion |
| BREAK | execute.md:116 skips code-review | Add recommended step before commit |
| BREAK | code-review.md:62 → code-review-fix | Output explicit next step with path |
| BREAK | execution-report → system-review | Add chain suggestion |
| BREAK | end-to-end-feature skips code-review | Insert between execute and commit |

---

## STEP-BY-STEP TASKS

### UPDATE `.opencode/commands/planning.md` — Add Explicit Handoff

- **IMPLEMENT**: Update output section to include explicit next step:
  
  At line ~210 (end of output section), add:
  ```markdown
  ## Output
  
  Save completed plan to: `requests/{feature-name}-plan.md`
  
  ## Next Step
  
  **Recommended command**:
  ```
  /execute requests/{feature-name}-plan.md
  ```
  
  Replace `{feature-name}` with the feature name from the plan.
  
  **For complex features** (4+ phases, 15+ tasks):
  - Plan is decomposed into sub-plans
  - Execute in order: `/execute requests/{feature}-plan-01-*.md`, then 02, etc.
  ```
- **PATTERN**: Explicit command with path, not just "next step"
- **IMPORTS**: N/A
- **GOTCHA**: Feature name must be knowable from output
- **VALIDATE**: `grep -A5 "Next Step" .opencode/commands/planning.md | grep -c "/execute"`

### UPDATE `.opencode/commands/execute.md` — Add Intermediate Steps

- **IMPLEMENT**: Update output section to suggest intermediate steps:
  
  At line ~110 (end of execution), replace with:
  ```markdown
  ## Output
  
  Implementation complete. Files modified: {list}
  
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
  ```
- **PATTERN**: Numbered steps with commands and descriptions
- **IMPORTS**: N/A
- **GOTCHA**: Don't skip steps — make the sequence clear
- **VALIDATE**: `grep -c "/code-review" .opencode/commands/execute.md`

### UPDATE `.opencode/commands/code-review.md` — Add Explicit Handoff

- **IMPLEMENT**: Update output section to chain to code-review-fix:
  
  At line ~90 (end of review output), add:
  ```markdown
  ## Next Step
  
  **If issues found**:
  ```
  /code-review-fix requests/code-reviews/{feature-name}-review.md
  ```
  
  **If review passed**:
  ```
  /commit
  ```
  
  Replace `{feature-name}` with the feature name from the plan.
  ```
- **PATTERN**: Conditional next step based on review result
- **IMPORTS**: N/A
- **GOTCHA**: Feature name must match plan's feature name
- **VALIDATE**: `grep -c "/code-review-fix" .opencode/commands/code-review.md`

### UPDATE `.opencode/commands/execution-report.md` — Add System Review Chain

- **IMPLEMENT**: Update output section to suggest system-review:
  
  At line ~85 (end of report), add:
  ```markdown
  ## Next Step
  
  **For process analysis**, compare execution against plan:
  ```
  /system-review requests/{feature-name}-plan.md requests/execution-reports/{feature-name}-report.md
  ```
  
  This analyzes divergence from plan and suggests process improvements.
  ```
- **PATTERN**: Optional analysis step for learning
- **IMPORTS**: N/A
- **GOTCHA**: system-review requires both plan and report paths
- **VALIDATE**: `grep -c "/system-review" .opencode/commands/execution-report.md`

### UPDATE `.opencode/commands/end-to-end-feature.md` — Insert Code Review

- **IMPLEMENT**: Insert code review step between execute and commit:
  
  Current flow (lines 95-128):
  - Step 2: /planning
  - Step 3: /execute
  - Step 4: /commit (MISSING: code-review)
  - Step 5: /create-pr
  
  Update to:
  ```markdown
  ## Workflow
  
  ### Step 1: Prime
  ...
  
  ### Step 2: Planning
  ...
  
  ### Step 3: Execute
  ...
  
  ### Step 4: Code Review
  Run code review to validate implementation:
  ```bash
  /code-review
  ```
  
  If issues found:
  ```bash
  /code-review-fix requests/code-reviews/{feature}-review.md
  ```
  
  ### Step 5: Commit
  ...
  
  ### Step 6: Create PR
  ...
  ```
  
  Renumber all subsequent steps and update references.
- **PATTERN**: Full workflow includes validation before commit
- **IMPORTS**: N/A
- **GOTCHA**: Renumber all step references throughout file
- **VALIDATE**: `grep -c "Step 4: Code Review" .opencode/commands/end-to-end-feature.md`

### UPDATE `.opencode/commands/create-pr.md` — Fix Circular Reference

- **IMPLEMENT**: Fix circular reference at line 154:
  
  Current (problematic):
  ```markdown
  For the full automated workflow, use `/end-to-end-feature` instead.
  ```
  
  But `/end-to-end-feature:95` calls `/create-pr` as its last step.
  
  Fix:
  ```markdown
  ## Relationship to Other Commands
  
  - **Standalone**: Use `/create-pr` when you've already committed and want to create a PR
  - **End-to-end**: `/end-to-end-feature` includes PR creation as its final step
  
  If you're starting from a plan, `/end-to-end-feature` handles the full workflow.
  If you just need a PR for existing commits, use this command.
  ```
- **PATTERN**: Clear guidance on when to use which command
- **IMPORTS**: N/A
- **GOTCHA**: Avoid confusion about command relationships
- **VALIDATE**: `grep -c "Standalone" .opencode/commands/create-pr.md`

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify explicit handoffs added
grep -c "/execute requests" .opencode/commands/planning.md
grep -c "/code-review" .opencode/commands/execute.md
grep -c "/code-review-fix" .opencode/commands/code-review.md
grep -c "/system-review" .opencode/commands/execution-report.md
```

### Content Verification
```bash
# Verify code review in end-to-end
grep -c "Code Review" .opencode/commands/end-to-end-feature.md

# Verify step renumbering
grep "Step 5: Commit\|Step 6: Create PR" .opencode/commands/end-to-end-feature.md
```

### Cross-Reference Check
```bash
# Verify consistent feature name usage
grep -c "{feature-name}" .opencode/commands/planning.md .opencode/commands/execute.md .opencode/commands/code-review.md
```

---

## SUB-PLAN CHECKLIST

- [ ] Task 01: planning.md explicit handoff added
- [ ] Task 02: execute.md intermediate steps added
- [ ] Task 03: code-review.md explicit handoff added
- [ ] Task 04: execution-report.md system-review chain added
- [ ] Task 05: end-to-end-feature.md code review inserted
- [ ] Task 06: create-pr.md circular reference fixed
- [ ] All validation commands pass

---

## HANDOFF NOTES

### Files Modified
- `.opencode/commands/planning.md` — Explicit next step with path
- `.opencode/commands/execute.md` — Intermediate steps before commit
- `.opencode/commands/code-review.md` — Conditional handoff to fix or commit
- `.opencode/commands/execution-report.md` — System review suggestion
- `.opencode/commands/end-to-end-feature.md` — Code review step inserted, steps renumbered
- `.opencode/commands/create-pr.md` — Fixed circular reference

### Patterns Established
- All commands output explicit next-step commands with file paths
- Workflow is now: prime → planning → execute → [execution-report] → code-review → [code-review-fix] → commit → create-pr
- End-to-end includes full validation workflow

### State for Final Validation
- Run `/prime` to verify system is coherent
- Test workflow chain by running through a simple feature
- Update memory.md with completion note
