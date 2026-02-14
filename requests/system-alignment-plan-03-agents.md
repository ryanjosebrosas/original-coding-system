# Sub-Plan 03: Command-Agent Integration

> **Parent Plan**: `requests/system-alignment-plan-overview.md`
> **Sub-Plan**: 3 of 4
> **Phase**: Command-Agent Integration
> **Tasks**: 6
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan closes gaps between commands and agents, ensuring commands check agent availability before using them.

**What this sub-plan delivers**:
- All commands that use agents check availability first
- Orphan specialists integrated where appropriate
- Consistent agent invocation pattern across commands
- Missing agent files created (@explore, @general) or references removed

**Prerequisites from previous sub-plans**:
- Sub-plan 01: Example agents exist in `_examples/`
- Sub-plan 02: Templates ready for agent output

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `reference/command-agent-mapping.md` (full) — Documented integration spec
- `.opencode/commands/planning.md` (lines 72-88) — Needs availability check
- `.opencode/commands/code-review.md` (lines 22-25) — Assumes agents exist
- `.opencode/commands/execute.md` (lines 29-40) — Plan-validator pattern
- `.opencode/commands/parallel-e2e.md` (full) — Missing agent integration
- `.opencode/commands/create-prd.md` (lines 40-46) — Incomplete specialist coverage
- `.opencode/agents/core-opencoder.md` (lines 77-78) — References non-existent @explore/@general

### Audit Findings to Address

| Issue | Location | Fix |
|-------|----------|-----|
| GAP | planning.md:88 | Add availability check for research agents |
| GAP | code-review.md:22-25 | Add availability check for review agents |
| GAP | parallel-e2e.md | Add TaskManager/BuildAgent integration |
| GAP | create-prd.md:40-46 | Add copywriter/technical-writer/data specialists |
| GAP | commit.md:39 | Detect test absence, suggest TestEngineer |
| ORPHAN | core-opencoder.md:77-78 | Remove or create @explore/@general references |

---

## STEP-BY-STEP TASKS

### UPDATE `.opencode/commands/planning.md` — Add Availability Check

- **IMPLEMENT**: Add availability check before referencing research agents:
  
  At line ~72 (before Phase 2):
  ```markdown
  ### Research Mode Selection
  
  **Check agent availability**:
  ```bash
  ls .opencode/agents/research-*.md 2>/dev/null | wc -l
  ```
  
  - If count >= 2: Use **Parallel Research Mode** (Task agents for codebase + external)
  - If count < 2: Use **Standard Research Mode** (built-in exploration)
  
  > Note: Research agents are in `_examples/` by default. Run `/activate-agents` to enable.
  ```
  
  Update line 88 to reference the check instead of assuming agents exist.
- **PATTERN**: Same as `.opencode/commands/rca.md:36` availability check
- **IMPORTS**: N/A
- **GOTCHA**: Don't break if agents don't exist — must fall back gracefully
- **VALIDATE**: `grep -A5 "Research Mode Selection" .opencode/commands/planning.md | grep -c "ls .opencode"`

### UPDATE `.opencode/commands/code-review.md` — Add Availability Check

- **IMPLEMENT**: Add availability check for review agents:
  
  At line ~22 (before review process):
  ```markdown
  ### Review Agent Check
  
  **Check specialist availability**:
  ```bash
  ls .opencode/agents/code-review-*.md 2>/dev/null | wc -l
  ```
  
  - If count >= 4: Use **Parallel Review Mode** (type-safety, security, architecture, performance)
  - If count < 4: Use **Standard Review Mode** (comprehensive single-pass review)
  
  > Note: Review specialists are in `_examples/` by default. Run `/activate-agents` to enable.
  ```
  
  Update review process to conditionally use agents based on check.
- **PATTERN**: Same as Task 01
- **IMPORTS**: N/A
- **GOTCHA**: Standard review mode must be complete without agents
- **VALIDATE**: `grep -c "code-review-.*.md" .opencode/commands/code-review.md`

### UPDATE `.opencode/commands/parallel-e2e.md` — Add Agent Integration

- **IMPLEMENT**: Add TaskManager and BuildAgent integration:
  
  At line ~20 (after prerequisites):
  ```markdown
  ### Agent Integration
  
  **Check agent availability**:
  ```bash
  ls .opencode/agents/subagent-taskmanager.md .opencode/agents/subagent-buildagent.md 2>/dev/null | wc -l
  ```
  
  - If count == 2: Use **Enhanced Mode** with TaskManager for dependency analysis, BuildAgent for validation
  - If count < 2: Use **Standard Mode** (manual coordination)
  ```
  
  In the workflow steps, add optional agent invocations:
  - After plan generation: "If TaskManager available, validate dependency ordering"
  - After execution: "If BuildAgent available, run validation suite"
- **PATTERN**: Follow `/end-to-end-feature.md` agent integration pattern
- **IMPORTS**: N/A
- **GOTCHA**: parallel-e2e coordinates multiple features — agent coordination is helpful
- **VALIDATE**: `grep -c "subagent-taskmanager" .opencode/commands/parallel-e2e.md`

### UPDATE `.opencode/commands/create-prd.md` — Expand Specialist Coverage

- **IMPLEMENT**: Add missing specialists to product planning:
  
  At line ~40 (specialist invocation section), expand to:
  ```markdown
  ### Specialist Consultation
  
  Based on product domain, invoke relevant specialists:
  
  **Always**:
  - `@specialist-frontend` — UI/UX implications
  - `@specialist-backend` — API/data architecture
  - `@specialist-devops` — Infrastructure needs
  
  **When applicable**:
  - `@specialist-copywriter` — If product has user-facing copy, CTAs, or microcopy
  - `@specialist-technical-writer` — If product requires user documentation
  - `@specialist-data` — If product involves data pipelines, warehouses, or analytics
  
  **Check availability before using**:
  ```bash
  ls .opencode/agents/specialist-*.md 2>/dev/null
  ```
  ```
- **PATTERN**: Conditional specialist invocation based on product type
- **IMPORTS**: N/A
- **GOTCHA**: Don't require all specialists — product may not need all domains
- **VALIDATE**: `grep -c "specialist-copywriter" .opencode/commands/create-prd.md`

### UPDATE `.opencode/commands/commit.md` — Add TestEngineer Detection

- **IMPLEMENT**: Detect missing tests and suggest TestEngineer:
  
  At line ~35 (before commit message), add:
  ```markdown
  ### Test Coverage Check
  
  **Detect if tests exist for changed code**:
  ```bash
  # Check if any test files were modified or exist for changed modules
  git diff --name-only HEAD~1 | grep -E "(test|spec)" || echo "No test changes"
  ```
  
  - If test changes exist: Proceed with commit
  - If no test changes but source changes exist:
    - Suggest: "Consider adding tests. Run `/execute` with `@subagent-testengineer` for test generation."
    - Note in commit: "(no test changes)"
  ```
- **PATTERN**: Non-blocking suggestion, not requirement
- **IMPORTS**: N/A
- **GOTCHA**: Don't block commits — just suggest tests
- **VALIDATE**: `grep -c "testengineer" .opencode/commands/commit.md`

### UPDATE `.opencode/agents/core-opencoder.md` — Fix Orphan References

- **IMPLEMENT**: Either create @explore/@general agents or remove references:
  
  **Option A** (preferred): Remove references since built-in agents work:
  - Line 77-78: Remove `@explore` and `@general` from delegation targets
  - Update comment to say: "Use Task tool with subagent_type: explore for codebase research"
  
  **Option B**: Create minimal agent files if needed for consistency:
  - Create `.opencode/agents/subagent-explore.md` that wraps Task tool
  - Create `.opencode/agents/subagent-general.md` for general tasks
  
  Implement **Option A** — remove references:
  ```markdown
  ## Delegation Targets
  
  When tasks exceed scope, delegate to:
  - **Codebase research**: Use Task tool with `subagent_type: explore`
  - **General tasks**: Use Task tool with `subagent_type: general`
  - **Specialized work**: Use specialist agents (`@specialist-*`)
  ```
- **PATTERN**: Prefer built-in Task agents over custom files
- **IMPORTS**: N/A
- **GOTCHA**: Ensure documentation matches actual tool usage
- **VALIDATE**: `grep -c "@explore" .opencode/agents/core-opencoder.md` → 0

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify availability checks added
grep -l "ls .opencode/agents" .opencode/commands/planning.md .opencode/commands/code-review.md

# Verify new integrations
grep -c "subagent-taskmanager" .opencode/commands/parallel-e2e.md
grep -c "specialist-copywriter" .opencode/commands/create-prd.md
```

### Content Verification
```bash
# Verify orphan references removed
grep "@explore\|@general" .opencode/agents/core-*.md || echo "No orphan references"

# Verify graceful degradation
grep -A3 "If count" .opencode/commands/planning.md | grep -c "Standard"
```

### Cross-Reference Check
```bash
# Verify consistency with mapping doc
grep -c "TaskManager" reference/command-agent-mapping.md
grep -c "TaskManager" .opencode/commands/parallel-e2e.md
```

---

## SUB-PLAN CHECKLIST

- [x] Task 01: planning.md availability check added
- [x] Task 02: code-review.md availability check added
- [x] Task 03: parallel-e2e.md agent integration added
- [x] Task 04: create-prd.md specialist coverage expanded
- [x] Task 05: commit.md TestEngineer detection added
- [x] Task 06: core-opencoder.md orphan references fixed
- [x] All validation commands pass

---

## HANDOFF NOTES

### Files Modified
- `.opencode/commands/planning.md` — Added research agent availability check
- `.opencode/commands/code-review.md` — Added review agent availability check
- `.opencode/commands/parallel-e2e.md` — Added TaskManager/BuildAgent integration
- `.opencode/commands/create-prd.md` — Expanded specialist coverage
- `.opencode/commands/commit.md` — Added TestEngineer suggestion
- `.opencode/agents/core-opencoder.md` — Removed orphan @explore/@general references

### Patterns Established
- All commands now check agent availability before using
- Graceful fallback to standard mode when agents unavailable
- Conditional specialist invocation based on context

### State for Next Sub-Plan
- Sub-plan 04 will chain commands together
- Agent integration is now robust (graceful degradation)
- command-agent-mapping.md may need update to reflect changes
