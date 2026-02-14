# Sub-Plan 01: Foundation (Token Efficiency)

> **Parent Plan**: `requests/system-cohesion-audit-plan-overview.md`
> **Sub-Plan**: 01 of 05
> **Phase**: Foundation — Token Efficiency & Redundancy Cleanup
> **Tasks**: 6
> **Estimated Context Load**: Low

---

## Scope

This sub-plan eliminates token redundancy across reference guides and creates patterns for minimal overviews. The goal: stop burning context on duplicated content.

**What this sub-plan delivers**:
- Single canonical `validation-pyramid.md` (consolidates 3 files)
- Slimmed overviews that point instead of duplicate
- Removed redundancy from reference guides
- Pattern document for future overview writing

**Prerequisites from previous sub-plans**:
- None (first sub-plan)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `reference/validation-strategy.md` — Full 5-Level Validation Pyramid content
- `reference/validation-discipline.md:36-190` — Duplicate pyramid content
- `reference/piv-loop-practice.md:432-555` — Duplicate pyramid content
- `reference/global-rules-optimization.md` — Two-Question Framework, verbose sections
- `reference/layer1-guide.md:49-52` — Redundant Two-Question Framework
- `reference/command-design-overview.md` — Mini-version of command-design-framework
- `reference/command-design-framework.md` — Full deep-dive (699 lines)

### Files Created by Previous Sub-Plans

> Skip this section for sub-plan 01.

---

## STEP-BY-STEP TASKS

### CREATE `reference/validation-pyramid.md`

- **IMPLEMENT**: Create canonical 5-Level Validation Pyramid reference. Content:
  - Level 1: Syntax/Style (lint, format)
  - Level 2: Unit Tests
  - Level 3: Integration Tests
  - Level 4: Manual Validation
  - Level 5: Additional (MCP, CLI tools)
  - Each level: definition, when to use, example commands
  - Total: ~50-80 lines

- **PATTERN**: Pointer pattern from `AGENTS.md:37-54` (table format for on-demand)
- **IMPORTS**: None (markdown file)
- **GOTCHA**: Don't copy ALL content from 3 files — extract the unique canonical version
- **VALIDATE**: `wc -l reference/validation-pyramid.md` (should be 50-100 lines)

### UPDATE `reference/validation-strategy.md`

- **IMPLEMENT**: Replace full pyramid content with pointer to new canonical file:
  ```markdown
  ## 5-Level Validation Pyramid

  > See `validation-pyramid.md` for the canonical 5-level validation pyramid.
  > This file provides strategy guidance; the pyramid itself is documented separately.

  [Keep only strategy-specific content that isn't in the pyramid]
  ```

- **PATTERN**: Pointer pattern — see `sections/15_archon_workflow.md` for 5-line pointer example
- **IMPORTS**: None
- **GOTCHA**: Ensure strategy-specific content remains (when to choose which level)
- **VALIDATE**: `grep -c "validation-pyramid.md" reference/validation-strategy.md` (should be ≥1)

### UPDATE `reference/validation-discipline.md`

- **IMPLEMENT**: Replace lines 36-190 (duplicate pyramid) with pointer:
  ```markdown
  ## Validation Levels

  > The **5-Level Validation Pyramid** is documented at `validation-pyramid.md`.
  > This section covers discipline around validation, not the levels themselves.
  ```

- **PATTERN**: Same pointer pattern
- **IMPORTS**: None
- **GOTCHA**: Don't remove the discipline guidance that follows the pyramid section
- **VALIDATE**: `wc -l reference/validation-discipline.md` (should decrease by ~100 lines)

### UPDATE `reference/piv-loop-practice.md`

- **IMPLEMENT**: Replace lines 432-555 (duplicate pyramid) with pointer to canonical file
  Keep the PIV Loop practice context around it

- **PATTERN**: Pointer pattern
- **IMPORTS**: None
- **GOTCHA**: Ensure surrounding PIV Loop context remains intact
- **VALIDATE**: `grep -c "validation-pyramid.md" reference/piv-loop-practice.md` (should be ≥1)

### UPDATE `reference/layer1-guide.md`

- **IMPLEMENT**: Replace lines 49-52 (Two-Question Framework) with:
  ```markdown
  ### Two-Question Framework

  > See `global-rules-optimization.md` for the Two-Question Framework.
  > Use these questions to decide what belongs in auto-loaded vs on-demand context.
  ```

- **PATTERN**: Pointer pattern
- **IMPORTS**: None
- **GOTCHA**: Keep the rest of layer1-guide intact — it's needed for new project setup
- **VALIDATE**: `grep -c "global-rules-optimization.md" reference/layer1-guide.md` (should be ≥1)

### CREATE `reference/overview-guide.md`

- **IMPLEMENT**: Pattern document for writing minimal overviews:
  ```markdown
  # Writing Minimal Overview Guides

  ## Purpose

  Overview files (e.g., `*-overview.md`) provide navigation, not content duplication.

  ## Pattern

  1. **Table of contents** — what sections exist
  2. **One-sentence summaries** — each section in 1 line
  3. **Pointers to deep-dives** — "See X for full details on Y"
  4. **NO code examples** — those belong in deep-dives
  5. **NO full explanations** — just enough to navigate

  ## Anti-Pattern

  Don't write a mini-version of the deep-dive. If overview is >30% of deep-dive length, it's too long.

  ## Example

  Good: `command-design-overview.md` (203 lines) points to `command-design-framework.md` (699 lines) — 29% ratio
  Bad: If overview duplicated 50% of framework content, users would read both and waste tokens
  ```

- **PATTERN**: Self-documenting — this file IS the pattern
- **IMPORTS**: None
- **GOTCHA**: Keep it short — practice what it preaches
- **VALIDATE**: `wc -l reference/overview-guide.md` (should be 40-60 lines)

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify new file exists
ls -la reference/validation-pyramid.md reference/overview-guide.md

# Verify pointer files reference the new canonical files
grep -l "validation-pyramid.md" reference/*.md
```

### Content Verification
```bash
# Verify pyramid content moved (not just deleted)
grep -c "Level 1" reference/validation-pyramid.md
# Should be ≥1

# Verify pointers exist in updated files
grep -c "See.*validation-pyramid" reference/validation-strategy.md reference/validation-discipline.md reference/piv-loop-practice.md
# Each should be ≥1
```

### Cross-Reference Check
```bash
# Verify no broken references
grep -r "validation-strategy.md#level" reference/ 2>/dev/null || echo "No broken anchors"
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
- `reference/validation-pyramid.md` — Canonical 5-level pyramid (50-100 lines)
- `reference/overview-guide.md` — Pattern for minimal overviews (40-60 lines)

### Files Modified
- `reference/validation-strategy.md` — Replaced pyramid with pointer, kept strategy content
- `reference/validation-discipline.md` — Removed ~100 lines of duplicate pyramid
- `reference/piv-loop-practice.md` — Replaced pyramid with pointer
- `reference/layer1-guide.md` — Replaced Two-Question Framework with pointer

### Patterns Established
- **Pointer Pattern**: When content exists in multiple places, create ONE canonical file and pointers everywhere else
- **Overview Ratio**: Overviews should be ≤30% of deep-dive length

### State for Next Sub-Plan
- Token savings: ~200 lines removed from redundancy
- Foundation clean: Now safe to add agent integrations without token bloat
- Sub-plan 02 can assume cleaner reference structure
