# Feature: Plan Decomposition & Execution Routing

## Feature Description

Enhance the planning and execution system to handle complex features by decomposing large plans into
multiple smaller, context-window-friendly sub-plans. Each sub-plan is self-contained and executable
in a fresh conversation, preventing context overflow during implementation. Additionally, formalize
instance routing so execution distributes across claude2/3 (Sonnet) with claude1 (Sonnet) as fallback.

## User Story

As a developer using the PIV Loop, I want complex features to be automatically decomposed into
sequential sub-plans, so that execution agents can implement each piece without losing context
or quality due to context window limitations.

## Problem Statement

When planning complex features (multi-agent systems, full-stack features, large refactors), the
current `/planning` command produces a single 500-700 line plan. The execution agent must load
this plan + CLAUDE.md + read codebase files + write code — all competing for the ~200K token
context window. Quality degrades at ~70% context usage (~140K tokens). By the time the execution
agent reaches later tasks, it has lost context from earlier tasks, producing inconsistent or
incomplete implementations. This has been experienced multiple times.

## Solution Statement

- Decision 1: **Plan decomposition** — `/planning` gains a "complex mode" that produces an overview
  file + N sub-plan files (each 150-250 lines) instead of one 500-700 line file. Each sub-plan is
  self-contained with its own context references, tasks, and validation commands.
- Decision 2: **Sequential sub-plan execution** — `/execute` detects plan series (via overview file)
  and chains through sub-plans one at a time, starting fresh context per sub-plan.
- Decision 3: **Instance routing formalization** — Execution routes to claude2 → claude3 → claude1
  (Sonnet fallback). Planning stays on claude1 (Opus).
- Decision 4: **Backwards compatible** — Single-plan mode remains the default for Low/Medium
  complexity features. Decomposition only activates for High complexity or explicit user request.

## Feature Metadata

- **Feature Type**: Enhancement
- **Estimated Complexity**: Medium
- **Primary Systems Affected**: planning command, execute command, templates, multi-instance routing,
  multi-model strategy, PIV Loop documentation
- **Dependencies**: None (all changes are to markdown methodology files)

---

## CONTEXT REFERENCES

### Relevant Codebase Files

> IMPORTANT: The execution agent MUST read these files before implementing!

- `.claude/commands/planning.md` (lines 78-99) — Why: Phase 1 scoping with Feature Metadata
  (complexity field) where decomposition decision hooks in
- `.claude/commands/planning.md` (lines 293-350) — Why: Phase 4-5 where plan structure is decided
  and tasks are generated — decomposition logic inserts here
- `.claude/commands/planning.md` (lines 385-400) — Why: OUTPUT section that saves to single file —
  must support saving to N files
- `.claude/commands/execute.md` (lines 19-28) — Why: Step 1 where plan file is read — must detect
  plan series vs single plan
- `.claude/commands/execute.md` (lines 54-90) — Why: Step 2 task execution loop — must handle
  sub-plan boundaries
- `.claude/commands/parallel-e2e.md` (lines 76-93) — Why: Overlap detection pattern we'll mirror
  for sub-plan file conflict checking
- `templates/STRUCTURED-PLAN-TEMPLATE.md` (lines 1-17) — Why: Current template header with
  500-700 line target — sub-plan template derives from this
- `reference/multi-instance-routing.md` (lines 21-32) — Why: Instance table to update with
  execution routing rules
- `reference/multi-instance-routing.md` (lines 36-95) — Why: Routing strategies — add execution
  fallback chain strategy
- `reference/multi-model-strategy.md` (lines 7-20) — Why: Quick Start model table — add
  decomposition entry
- `reference/multi-model-strategy.md` (lines 161-177) — Why: Strategy 2 (Opus plan, Sonnet
  execute) — extend with decomposition variant
- `sections/02_piv_loop.md` (lines 1-10) — Why: Granularity Principle — add decomposition mention
- `memory.md` — Why: Will need to be updated with decomposition decision

### New Files to Create

- `templates/PLAN-OVERVIEW-TEMPLATE.md` — Master file for decomposed plan series (index, context,
  execution order)
- `templates/SUB-PLAN-TEMPLATE.md` — Template for each individual sub-plan (self-contained, smaller
  scope)

### Related Memories (from memory.md)

- Memory: "Slimmed CLAUDE.md by moving sections 06-14 to reference/ — Saves ~12,000 tokens per
  session" — Relevance: Same principle applies — large plans waste context, decomposition reduces
  per-session token load
- Memory: "Context bloat: Loading all reference guides wastes tokens — Only load on-demand guides
  when needed" — Relevance: Sub-plans should only include context relevant to their specific tasks
- Memory: "CLAUDE.md restructure: Auto-loading 14 sections burned tokens on irrelevant context"
  — Relevance: Validates the approach — smaller, focused plans = better execution quality

### Relevant Documentation

- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices.md)
  - Specific section: Context management and plan-then-implement pattern
  - Why: Official guidance on separating planning from implementation

- [Building /deep-plan: Comprehensive Planning Plugin](https://pierce-lamb.medium.com/building-deep-plan-a-claude-code-plugin-for-comprehensive-planning-30e0921eb841)
  - Specific section: Splitting plan approach
  - Why: Pattern for creating a "splitting plan" that breaks large plans into chunks

- [Context Window Management](https://www.turboai.dev/blog/claude-code-context-window-management)
  - Specific section: Quality degradation thresholds
  - Why: Documents that quality degrades at 70% context usage (~140K tokens)

- [Task Decomposition for AI Coding](https://blog.continue.dev/task-decomposition/)
  - Specific section: "One clearly defined task at a time"
  - Why: Validates the approach — smaller scoped tasks produce better results

### Patterns to Follow

**Plan file naming pattern** (from `parallel-e2e.md:36-39`):
```markdown
| # | Feature Name        | Plan Path                              |
|---|---------------------|-----------------------------------------|
| 1 | search-functionality| requests/search-functionality-plan.md   |
```
- Why this pattern: Consistent naming convention already used for plan files
- Adaptation for decomposition: `requests/{feature}-plan-overview.md`,
  `requests/{feature}-plan-01-{phase}.md`, `requests/{feature}-plan-02-{phase}.md`

**Overlap detection pattern** (from `parallel-e2e.md:76-93`):
```markdown
**CRITICAL — File Overlap Detection** (after each plan except the first):
   - Read all plan files created so far
   - Compare "New Files to Create" and "STEP-BY-STEP TASKS" target files
   - If overlap detected beyond registration points (routes, configs):
     ⚠ FILE OVERLAP DETECTED
```
- Why this pattern: Sub-plans should also check for overlapping file modifications
- Common gotchas: Registration points (routes, configs) are expected overlaps — don't flag

**Feature Metadata complexity field** (from `planning.md:94`):
```markdown
- **Estimated Complexity**: {Low / Medium / High}
```
- Why this pattern: Already captures complexity — use as decomposition trigger
- Common gotchas: Medium features may need decomposition if they cross many systems

**Execution task loop** (from `execute.md:54-90`):
```markdown
For EACH task in "Step by Step Tasks":
  a. Navigate to the task
  a.5. Update Archon status (if available)
  b. Implement the task
  c. Verify as you go
  d. Mark for review (if Archon available)
```
- Why this pattern: Same loop works within each sub-plan — just scoped smaller

---

## IMPLEMENTATION PLAN

### Phase 1: Foundation — Templates

Create the two new templates that define the structure for decomposed plans.

**Tasks:**
- Create `templates/PLAN-OVERVIEW-TEMPLATE.md` — master file with plan index
- Create `templates/SUB-PLAN-TEMPLATE.md` — individual sub-plan template (150-250 lines)

### Phase 2: Core — Planning Command Enhancement

Add decomposition logic to `/planning` so it produces multiple files for complex features.

**Tasks:**
- Add Phase 4.5 (Decomposition Decision) to `planning.md`
- Update OUTPUT section to support multi-file output
- Add sub-plan generation loop after Phase 5

### Phase 3: Core — Execution Command Enhancement

Enhance `/execute` to detect and handle plan series.

**Tasks:**
- Add plan series detection to Step 1 of `execute.md`
- Add sequential sub-plan execution loop
- Add instance routing instructions

### Phase 4: Integration — Documentation Updates

Update reference guides and system docs to document the new capability.

**Tasks:**
- Update `reference/multi-instance-routing.md` with execution fallback chain
- Update `reference/multi-model-strategy.md` with decomposition strategy
- Update `sections/02_piv_loop.md` with brief decomposition mention
- Update `reference/file-structure.md` with new template entries

---

## STEP-BY-STEP TASKS

> Execute every task in order, top to bottom. Each task is atomic and independently testable.

### CREATE `templates/PLAN-OVERVIEW-TEMPLATE.md`

- **IMPLEMENT**: Create master overview template for decomposed plan series. Must include:
  1. Header with feature name, total sub-plan count, estimated total tasks
  2. Feature Description section (same as STRUCTURED-PLAN-TEMPLATE.md lines 22-45)
  3. User Story, Problem Statement, Solution Statement (same structure)
  4. Feature Metadata with added field: `Plan Mode: Decomposed (N sub-plans)`
  5. CONTEXT REFERENCES section — shared context that ALL sub-plans need (Relevant Codebase Files,
     Relevant Documentation, Related Memories, Patterns to Follow)
  6. PLAN INDEX section — table listing each sub-plan with:
     - Sub-plan number (01, 02, ...)
     - Phase name (Foundation, Core, Integration, etc.)
     - File path (`requests/{feature}-plan-{NN}-{phase}.md`)
     - Task count per sub-plan
     - Estimated context load (Low/Medium)
  7. EXECUTION ROUTING section:
     - Primary instance: claude2 (Sonnet)
     - Secondary instance: claude3 (Sonnet)
     - Fallback instance: claude1 (Sonnet)
     - Instructions: "Execute each sub-plan in a fresh conversation. If primary instance hits rate
       limit, switch to secondary. If secondary also limited, fall back to claude1 Sonnet."
  8. ACCEPTANCE CRITERIA section (feature-wide, not per-sub-plan)
  9. COMPLETION CHECKLIST section (feature-wide)
  10. Notes section with Confidence Score, Key Design Decisions, Risks
  Target: 150-200 lines for overview file
- **PATTERN**: Mirror header structure from `templates/STRUCTURED-PLAN-TEMPLATE.md:1-45`
- **IMPORTS**: N/A (markdown file)
- **GOTCHA**: The overview file must NOT contain step-by-step tasks — those live in sub-plans only.
  It's a coordination document, not an implementation document.
- **VALIDATE**: `powershell -Command "if (Test-Path 'templates/PLAN-OVERVIEW-TEMPLATE.md') { $c = Get-Content 'templates/PLAN-OVERVIEW-TEMPLATE.md'; Write-Host ('Lines: ' + $c.Count); if ($c.Count -ge 100 -and $c.Count -le 250) { Write-Host 'OK' } else { Write-Host 'FAIL: wrong size' } } else { Write-Host 'FAIL: file missing' }"`

### CREATE `templates/SUB-PLAN-TEMPLATE.md`

- **IMPLEMENT**: Create individual sub-plan template. Must include:
  1. Header linking back to overview: `Parent Plan: requests/{feature}-plan-overview.md`
  2. Sub-plan metadata: number, phase name, task count, context load estimate
  3. CONTEXT FOR THIS SUB-PLAN section — only the files/docs relevant to THIS sub-plan's tasks
     (not the entire feature's context — that's in the overview)
  4. Brief scope statement: "This sub-plan implements {phase description}. For full feature
     context, see the overview file."
  5. STEP-BY-STEP TASKS section — same 7-field format as STRUCTURED-PLAN-TEMPLATE.md
     (ACTION, TARGET, IMPLEMENT, PATTERN, IMPORTS, GOTCHA, VALIDATE)
  6. VALIDATION COMMANDS section — only validations for THIS sub-plan's tasks
  7. SUB-PLAN CHECKLIST — did all tasks pass, all validations pass
  8. HANDOFF NOTES — what the next sub-plan needs to know about what was done here
     (files created, patterns established, state left behind)
  Target: 150-250 lines per sub-plan (5-8 tasks each)
  Core principle: "This sub-plan must be executable by an agent that has ONLY read this file
  and the overview's CONTEXT REFERENCES section."
- **PATTERN**: Mirror task format from `templates/STRUCTURED-PLAN-TEMPLATE.md:143-166`
- **IMPORTS**: N/A (markdown file)
- **GOTCHA**: The sub-plan must be self-contained. Don't reference "see task 3 in sub-plan 01" —
  instead, include the relevant state/output from that task directly. Each sub-plan = fresh context.
- **VALIDATE**: `powershell -Command "if (Test-Path 'templates/SUB-PLAN-TEMPLATE.md') { $c = Get-Content 'templates/SUB-PLAN-TEMPLATE.md'; Write-Host ('Lines: ' + $c.Count); if ($c.Count -ge 80 -and $c.Count -le 200) { Write-Host 'OK' } else { Write-Host 'FAIL: wrong size' } } else { Write-Host 'FAIL: file missing' }"`

### UPDATE `.claude/commands/planning.md`

- **IMPLEMENT**: Add three sections to the planning command:

  **1. Phase 4.5: Plan Decomposition Decision** (insert between Phase 4 and Phase 5, ~40 lines):
  After Phase 4's strategic design, assess whether to decompose:

  ```
  ## PHASE 4.5: Plan Decomposition Decision

  **Goal**: Determine if this feature needs decomposition into sub-plans.

  **Trigger criteria** (ANY of these → decompose):
  - Estimated Complexity is High (from Phase 1 metadata)
  - Phase 4 design has 4+ implementation phases
  - Projected task count exceeds 15 tasks
  - Feature touches 3+ distinct systems/layers
  - User explicitly requested decomposition

  **If decomposing**:
  1. Read `templates/PLAN-OVERVIEW-TEMPLATE.md` and `templates/SUB-PLAN-TEMPLATE.md`
  2. Split Phase 4's implementation phases into sub-plans (1 phase = 1 sub-plan, max 8 tasks each)
  3. Assign shared context to overview, per-phase context to each sub-plan
  4. Proceed to Phase 5 in "decomposed mode" (generate tasks per sub-plan)
  5. Output: overview file + N sub-plan files

  **If NOT decomposing** (Low/Medium complexity, <15 tasks):
  - Proceed to Phase 5 normally (single plan file, 500-700 lines)
  - This is the default — backwards compatible

  **Validation**: Is the decomposition decision justified? Would a single plan exceed
  the execution agent's effective context? Does each sub-plan have 5-8 tasks?
  ```

  **2. Phase 5 update** (~20 lines added): Add a conditional branch:
  ```
  **If decomposed mode (from Phase 4.5)**:
  - For each sub-plan, generate tasks using the same 7-field format
  - Each sub-plan gets 5-8 tasks maximum
  - Include HANDOFF NOTES at the end of each sub-plan
  - Cross-check: no task in sub-plan N depends on reading output from sub-plan N-1
    without that output being documented in the HANDOFF NOTES
  ```

  **3. OUTPUT section update** (~25 lines added): Add multi-file output:
  ```
  **If decomposed mode**:
  Save to:
  - `requests/{feature}-plan-overview.md` (overview + context + plan index)
  - `requests/{feature}-plan-01-{phase}.md` (sub-plan 1)
  - `requests/{feature}-plan-02-{phase}.md` (sub-plan 2)
  - ... (one per implementation phase)

  Include in each sub-plan's header:
  - Parent Plan: `requests/{feature}-plan-overview.md`
  - Sub-plan: {N} of {total}
  - Phase: {phase name}

  Include EXECUTION ROUTING in overview:
  - Primary: claude2 (Sonnet) — main execution instance
  - Secondary: claude3 (Sonnet) — if primary hits rate limit
  - Fallback: claude1 (Sonnet) — last resort
  ```

- **PATTERN**: Phase structure from `planning.md:293-350` (Phase 4-5 boundary)
- **IMPORTS**: N/A (markdown file)
- **GOTCHA**: Must remain backwards compatible. The default path (Low/Medium complexity) must
  produce identical output to the current command. Only High complexity or explicit request
  triggers decomposition.
- **VALIDATE**: `powershell -Command "$c = Get-Content '.claude/commands/planning.md'; $has45 = $c | Select-String 'PHASE 4.5'; $hasDecomp = $c | Select-String 'decomposed mode'; if ($has45 -and $hasDecomp) { Write-Host 'OK: decomposition sections found' } else { Write-Host 'FAIL: missing sections' }"`

### UPDATE `.claude/commands/execute.md`

- **IMPLEMENT**: Enhance the execute command to handle plan series. Add three sections:

  **1. Step 0.5: Plan Series Detection** (insert before Step 1, ~30 lines):
  ```
  ### 0.5. Detect Plan Type

  Read the plan file from `$ARGUMENTS`.

  **If the file contains "PLAN INDEX" section** (decomposed plan overview):
  - This is a plan series — extract the sub-plan file paths from the PLAN INDEX table
  - Read EXECUTION ROUTING for instance assignment
  - Report: "Detected plan series with N sub-plans. Executing sequentially."
  - Proceed to Step 1 (Series Mode)

  **If the file does NOT contain "PLAN INDEX"** (standard single plan):
  - This is a standard plan — proceed with existing execution flow unchanged
  - Skip all series-specific steps

  **Instance Routing** (series mode only):
  - Read the EXECUTION ROUTING section from overview
  - Primary: claude2 (Sonnet) — attempt execution here first
  - Secondary: claude3 (Sonnet) — if primary returns rate limit error
  - Fallback: claude1 (Sonnet) — if secondary also limited
  - Report which instance is being used for each sub-plan
  ```

  **2. Step 2 enhancement for series mode** (~25 lines added):
  ```
  ### Series Mode Execution

  For each sub-plan in PLAN INDEX order:

  1. **Load sub-plan**: Read `requests/{feature}-plan-{NN}-{phase}.md`
  2. **Load shared context**: Read CONTEXT REFERENCES from overview file
  3. **Execute tasks**: Follow same Step 2 process (a → b → c → d) for this sub-plan's tasks
  4. **Run sub-plan validations**: Execute VALIDATION COMMANDS from this sub-plan
  5. **Read handoff notes**: Check HANDOFF NOTES section for state to carry forward
  6. **Report progress**: "Sub-plan {N}/{total} complete. {tasks_done} tasks implemented."

  **Between sub-plans**:
  - Note: In manual mode, the user should start a fresh conversation for each sub-plan
    to reset context. In automated mode (claude -p), each sub-plan runs independently.
  - The HANDOFF NOTES from sub-plan N become additional context for sub-plan N+1.

  **If a sub-plan fails**:
  - Stop execution, report which sub-plan and which task failed
  - Provide: "Resume from sub-plan {N} after fixing the issue"
  - Don't continue to next sub-plan — failed state propagates
  ```

  **3. Step 5.5 enhancement** (~10 lines added):
  ```
  **If series mode**: Mark ALL tasks across all sub-plans as done in Archon.
  Update project description: "Plan series complete ({N} sub-plans executed)."
  ```

- **PATTERN**: Existing Step 1-2 structure from `execute.md:23-90`
- **IMPORTS**: N/A (markdown file)
- **GOTCHA**: Series detection must be reliable. The "PLAN INDEX" string is the signal — if
  someone puts "PLAN INDEX" in a regular plan comment, it would trigger series mode. Use a
  specific marker like `<!-- PLAN-SERIES -->` in the overview template as a more reliable signal.
- **VALIDATE**: `powershell -Command "$c = Get-Content '.claude/commands/execute.md'; $hasSeries = $c | Select-String 'Plan Series Detection|PLAN-SERIES'; $hasRouting = $c | Select-String 'Instance Routing'; if ($hasSeries -and $hasRouting) { Write-Host 'OK: series and routing sections found' } else { Write-Host 'FAIL: missing sections' }"`

### UPDATE `reference/multi-instance-routing.md`

- **IMPLEMENT**: Add a new "Strategy 5: Execution Fallback Chain" section and update the routing
  rules. Insert after Strategy 4 (Combined Multi-Model + Multi-Instance), around line 95:

  ```
  ### Strategy 5: Execution Fallback Chain (for Plan Decomposition)

  When executing decomposed plans, distribute sub-plans across instances with fallback:

  ​```
  Planning (claude1, Opus)
    → Produces: overview + N sub-plans

  Execution Fallback Chain:
    Sub-plan 01 → claude2 (Sonnet, primary)
    Sub-plan 02 → claude3 (Sonnet, secondary)
    Sub-plan 03 → claude2 (Sonnet, round-robin back)
    ...
    If claude2 rate-limited → switch to claude3
    If claude3 rate-limited → fall back to claude1 (Sonnet)
  ​```

  **Routing rules**:
  - `claude2` → Primary execution instance (odd-numbered sub-plans)
  - `claude3` → Secondary execution instance (even-numbered sub-plans)
  - `claude1` (Sonnet) → Fallback if both primary and secondary hit rate limits
  - Round-robin distribution keeps both instances active

  **Rate limit detection**:
  - If `claude -p` exits with error containing "rate_limited" or "429"
  - Or if process exceeds expected duration by 3x (indicates throttling)
  - Switch to next instance in chain

  **Manual execution** (recommended for complex features):
  ​```bash
  # Sub-plan 1 on claude2
  claude2 --model sonnet
  > /execute requests/{feature}-plan-01-foundation.md

  # Sub-plan 2 on claude3
  claude3 --model sonnet
  > /execute requests/{feature}-plan-02-core.md

  # If rate-limited, fall back to claude1
  claude1 --model sonnet  # Note: Sonnet, not Opus
  > /execute requests/{feature}-plan-03-integration.md
  ​```
  ```

  Also update the **Recommended Routing Rules** section (around line 154) to add:
  ```
  ### Route to `claude2` + `claude3` (Execution - Load Balanced):
  - ✅ Sub-plan execution from decomposed plans (round-robin)
  - ✅ `/execute` for standard plans (overflow from claude1)
  - ✅ Any Sonnet implementation work
  - ✅ Integration testing and validation
  ```

- **PATTERN**: Strategy sections from `multi-instance-routing.md:36-95`
- **IMPORTS**: N/A (markdown file)
- **GOTCHA**: Don't change existing Strategy 1-4 content — only add Strategy 5.
  The "Recommended Routing Rules" update should ADD to existing rules, not replace them.
- **VALIDATE**: `powershell -Command "$c = Get-Content 'reference/multi-instance-routing.md'; $has5 = $c | Select-String 'Strategy 5'; $hasFallback = $c | Select-String 'Execution Fallback Chain'; if ($has5 -and $hasFallback) { Write-Host 'OK' } else { Write-Host 'FAIL' }"`

### UPDATE `reference/multi-model-strategy.md`

- **IMPLEMENT**: Add decomposition context to two sections:

  **1. Add row to Quick Start table** (line 15 area):
  ```
  | `/execute` (decomposed) | Sonnet 4.5 | `claude2` or `claude3` (fallback: `claude1 sonnet`) |
  ```

  **2. Add Strategy 5** after Strategy 4 (Escalation Pattern), around line 200:
  ```
  ### Strategy 5: Plan Decomposition (Complex Features)

  ​```
  Planning (claude1, Opus):
    claude --model opus
    > /planning complex-feature
    → Detects High complexity
    → Produces: overview + N sub-plans

  Sequential Execution (claude2/3, Sonnet):
    claude2
    > /execute requests/complex-feature-plan-01-foundation.md

    claude3
    > /execute requests/complex-feature-plan-02-core.md

    claude2
    > /execute requests/complex-feature-plan-03-integration.md
  ​```

  **Why this works**: Each sub-plan is 150-250 lines (vs 500-700 for a single plan). The
  execution agent loads less plan context, leaving more room for codebase files and
  implementation. Context quality stays high throughout execution.

  **When to use**: Features with 15+ tasks, 4+ implementation phases, or 3+ systems affected.
  The `/planning` command detects this automatically at Phase 4.5.

  **Cost impact**: Same total work, but distributed across instances. No cost increase — just
  better context utilization per session.
  ```

- **PATTERN**: Strategy sections from `multi-model-strategy.md:143-200`
- **IMPORTS**: N/A (markdown file)
- **GOTCHA**: Keep the existing "Strategy 2: Opus for Planning, Sonnet for Everything Else" as
  the RECOMMENDED strategy. Strategy 5 is an extension, not a replacement.
- **VALIDATE**: `powershell -Command "$c = Get-Content 'reference/multi-model-strategy.md'; $has5 = $c | Select-String 'Strategy 5'; $hasDecomp = $c | Select-String 'Plan Decomposition'; if ($has5 -and $hasDecomp) { Write-Host 'OK' } else { Write-Host 'FAIL' }"`

### UPDATE `sections/02_piv_loop.md`

- **IMPLEMENT**: Add a brief mention of plan decomposition to the Granularity Principle section.
  After the existing text "Each loop picks ONE feature slice and builds it completely before
  moving on." (around line 5), add:

  ```
  For complex features (High complexity, 15+ tasks, 4+ phases), `/planning` automatically
  decomposes into multiple sub-plans — each executable in a fresh conversation with minimal
  context overhead. See `templates/PLAN-OVERVIEW-TEMPLATE.md` for the decomposed plan structure.
  ```

  This is a 3-line addition — keeps the auto-loaded section lean per our memory.md principle.

- **PATTERN**: Existing granularity text at `sections/02_piv_loop.md:3-5`
- **IMPORTS**: N/A (markdown file)
- **GOTCHA**: Keep it brief — this is an auto-loaded section. The deep detail lives in the
  templates and reference guides (on-demand).
- **VALIDATE**: `powershell -Command "$c = Get-Content 'sections/02_piv_loop.md'; $hasDecomp = $c | Select-String 'decomposes into multiple sub-plans'; if ($hasDecomp) { Write-Host 'OK' } else { Write-Host 'FAIL' }"`

### UPDATE `reference/file-structure.md`

- **IMPLEMENT**: Add the two new template files to the file structure reference. In the
  `templates/` section, add entries alphabetically:

  ```
  - `templates/PLAN-OVERVIEW-TEMPLATE.md` — Master file for decomposed plan series
  - `templates/SUB-PLAN-TEMPLATE.md` — Individual sub-plan template (150-250 lines)
  ```

- **PATTERN**: Existing template entries in `reference/file-structure.md`
- **IMPORTS**: N/A (markdown file)
- **GOTCHA**: Maintain alphabetical order within the templates section.
- **VALIDATE**: `powershell -Command "$c = Get-Content 'reference/file-structure.md'; $has1 = $c | Select-String 'PLAN-OVERVIEW-TEMPLATE'; $has2 = $c | Select-String 'SUB-PLAN-TEMPLATE'; if ($has1 -and $has2) { Write-Host 'OK' } else { Write-Host 'FAIL' }"`

---

## TESTING STRATEGY

### Unit Tests

N/A — this is a methodology/documentation project with no runtime code.

### Integration Tests

**Manual integration test**: After all files are updated, run through a simulated decomposition:
1. Read the updated `planning.md` and verify Phase 4.5 triggers correctly for a hypothetical
   High-complexity feature
2. Verify the PLAN-OVERVIEW-TEMPLATE has all required sections
3. Verify the SUB-PLAN-TEMPLATE has all 7 task fields
4. Read the updated `execute.md` and verify plan series detection logic
5. Read the updated `multi-instance-routing.md` and verify Strategy 5 fallback chain
6. Verify cross-references between files are consistent

### Edge Cases

- Single-plan mode must still work unchanged (backwards compatibility)
- A 1-sub-plan decomposition should be treated as a single plan (no overhead)
- Overlap between sub-plans (same file modified in plan-01 and plan-02) — should be documented
  in HANDOFF NOTES, not flagged as an error (sequential execution handles this)

---

## VALIDATION COMMANDS

### Level 1: Syntax & Style

```bash
# Verify all new/updated files exist
powershell -Command "foreach ($f in @('templates/PLAN-OVERVIEW-TEMPLATE.md', 'templates/SUB-PLAN-TEMPLATE.md')) { if (Test-Path $f) { Write-Host \"OK: $f\" } else { Write-Host \"FAIL: $f missing\" } }"
```

### Level 2: Content Validation

```bash
# Verify planning.md has decomposition sections
powershell -Command "$c = Get-Content '.claude/commands/planning.md'; $checks = @('PHASE 4.5', 'decomposed mode', 'PLAN-SERIES'); foreach ($check in $checks) { if ($c | Select-String $check) { Write-Host \"OK: $check found\" } else { Write-Host \"FAIL: $check missing\" } }"

# Verify execute.md has series detection
powershell -Command "$c = Get-Content '.claude/commands/execute.md'; $checks = @('Plan Series Detection', 'PLAN-SERIES', 'Instance Routing', 'Fallback'); foreach ($check in $checks) { if ($c | Select-String $check) { Write-Host \"OK: $check found\" } else { Write-Host \"FAIL: $check missing\" } }"
```

### Level 3: Cross-Reference Validation

```bash
# Verify all template references in planning.md point to files that exist
powershell -Command "$c = Get-Content '.claude/commands/planning.md' -Raw; if ($c -match 'PLAN-OVERVIEW-TEMPLATE' -and $c -match 'SUB-PLAN-TEMPLATE') { Write-Host 'OK: template references found in planning.md' } else { Write-Host 'FAIL: missing template references' }"

# Verify multi-instance-routing has Strategy 5
powershell -Command "$c = Get-Content 'reference/multi-instance-routing.md'; if (($c | Select-String 'Strategy 5') -and ($c | Select-String 'Execution Fallback Chain')) { Write-Host 'OK' } else { Write-Host 'FAIL' }"

# Verify multi-model-strategy has Strategy 5
powershell -Command "$c = Get-Content 'reference/multi-model-strategy.md'; if (($c | Select-String 'Strategy 5') -and ($c | Select-String 'Plan Decomposition')) { Write-Host 'OK' } else { Write-Host 'FAIL' }"
```

### Level 4: Manual Validation

1. Read each updated file end-to-end and verify:
   - No broken markdown formatting
   - All cross-references point to correct files
   - Backwards compatibility: standard planning flow is unchanged
   - Decomposition flow is clear and unambiguous
2. Simulate: "If I had a 20-task High-complexity feature, would this system produce clean
   sub-plans that an execution agent could implement independently?"
3. Verify instance routing instructions are actionable (claude2/3 commands work)

### Level 5: Additional Validation

```bash
# Count total lines changed across all files
powershell -Command "git diff --stat"
```

---

## ACCEPTANCE CRITERIA

- [x] `templates/PLAN-OVERVIEW-TEMPLATE.md` exists with all required sections (plan index,
      execution routing, shared context)
- [x] `templates/SUB-PLAN-TEMPLATE.md` exists with self-contained task format and handoff notes
- [x] `planning.md` has Phase 4.5 with clear decomposition trigger criteria
- [x] `planning.md` OUTPUT section supports multi-file output
- [x] `execute.md` detects plan series via `<!-- PLAN-SERIES -->` marker
- [x] `execute.md` handles sequential sub-plan execution with fresh context guidance
- [x] `execute.md` includes instance routing with fallback chain
- [x] `multi-instance-routing.md` has Strategy 5 (Execution Fallback Chain)
- [x] `multi-model-strategy.md` has Strategy 5 (Plan Decomposition)
- [x] `sections/02_piv_loop.md` mentions decomposition briefly (3 lines max)
- [x] `reference/file-structure.md` lists both new templates
- [x] Backwards compatibility: Low/Medium complexity features produce single plan as before
- [x] All validation commands pass

---

## COMPLETION CHECKLIST

- [x] All 8 tasks completed in order
- [x] Each task validation passed
- [x] All validation commands executed successfully (Level 1-5)
- [x] Manual validation confirms coherent system
- [x] No broken cross-references
- [x] Backwards compatibility verified
- [x] Acceptance criteria all met

---

## NOTES

### Key Design Decisions

- **Decomposition trigger is automatic but conservative**: Only High complexity, 15+ tasks, or 4+
  phases triggers decomposition. This prevents unnecessary splitting of simple features while
  ensuring complex ones are handled properly.
- **Sub-plans are self-contained, not just split**: Each sub-plan includes its own context
  references, not just a subset of tasks. This means the execution agent can work with ONLY the
  sub-plan + overview context, without needing to read other sub-plans.
- **HANDOFF NOTES bridge sub-plans**: Instead of requiring the execution agent to read previous
  sub-plans, each sub-plan documents what the next one needs to know. This keeps context minimal.
- **Instance routing is documented, not automated**: We use command prefixes (claude2, claude3)
  rather than trying to automate instance switching. The user or orchestrating script controls
  which instance runs each sub-plan. This matches the current "Supported" methods in
  multi-instance-routing.md.
- **`<!-- PLAN-SERIES -->` marker over string matching**: More reliable detection than checking
  for "PLAN INDEX" text — prevents false positives from regular plan comments.

### Risks

- **Risk 1**: Sub-plan boundaries may split related work. Mitigation: Phase 4.5 groups tasks by
  implementation phase (Foundation → Core → Integration → Testing), keeping related work together.
- **Risk 2**: HANDOFF NOTES may be incomplete, causing sub-plan N+1 to miss context. Mitigation:
  Planning command validates that every output from sub-plan N that's needed by N+1 is documented.
- **Risk 3**: Instance fallback adds manual complexity. Mitigation: Clear bash commands in the
  overview file make switching instances a copy-paste operation.

### Confidence Score: 8/10

- **Strengths**: Clear decomposition criteria, self-contained sub-plans, backwards compatible,
  builds on proven patterns (overlap detection from parallel-e2e, task format from existing
  template), addresses a real experienced problem
- **Uncertainties**: Optimal sub-plan size (150-250 lines) is estimated — may need tuning.
  HANDOFF NOTES quality depends on planning agent thoroughness. Instance fallback is manual.
- **Mitigations**: Sub-plan size is configurable (just change the template guidance). HANDOFF
  NOTES template includes explicit required fields. Instance routing has clear step-by-step
  commands.
