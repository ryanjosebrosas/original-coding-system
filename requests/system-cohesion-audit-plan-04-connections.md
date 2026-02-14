# Sub-Plan 04: Cross-System Connections

> **Parent Plan**: `requests/system-cohesion-audit-plan-overview.md`
> **Sub-Plan**: 04 of 05
> **Phase**: Cross-System Connections
> **Tasks**: 5
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan connects disconnected subsystems to the core methodology. The goal: GitHub workflows, Archon, and Worktrees feel integrated rather than adjacent.

**What this sub-plan delivers**:
- PIV Loop documentation includes worktrees
- Archon integration strengthened (not optional)
- GitHub workflow templates aligned with commands
- Worktree status in `/prime`

**Prerequisites from previous sub-plans**:
- Sub-plan 01-03 complete (token efficiency, agents, state tracking)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `sections/02_piv_loop.md` — PIV Loop doesn't mention worktrees
- `reference/git-worktrees-overview.md` — Parallel implementation documented here
- `.opencode/commands/prime.md` — Doesn't report worktree status
- `reference/archon-workflow.md:270-302` — Verbose violation examples
- `.github/workflows/prompts/` — 8 prompts mirroring commands
- `reference/github-workflows/` — Template files not actively used

### Files Created by Previous Sub-Plans

- `templates/PIV-STATE-TEMPLATE.md` — Cross-command state
- Agent integrations in 5 commands
- State tracking in planning/execute/code-review

---

## STEP-BY-STEP TASKS

### UPDATE `sections/02_piv_loop.md`

- **IMPLEMENT**: Add worktree section after the PIV Loop diagram:
  ```markdown
  ### Parallel Development with Worktrees

  For multiple simultaneous features, use git worktrees:

  ```
  /new-worktree feature/auth    # Creates ../project-feature-auth
  /new-worktree feature/api     # Creates ../project-feature-api
  ```

  Each worktree is an independent PIV Loop:
  - Plan → Implement → Validate → Commit in isolation
  - Merge back to main with `/merge-worktrees`

  See `reference/git-worktrees-overview.md` for full details.
  ```

- **PATTERN**: Pointer pattern — core mentions feature, reference has details
- **IMPORTS**: None
- **GOTCHA**: Keep this section short — it's auto-loaded content
- **VALIDATE**: `grep -c "worktree" sections/02_piv_loop.md` (should be ≥1)

### UPDATE `.opencode/commands/prime.md`

- **IMPLEMENT**: Add worktree status check after agent inventory:
  ```markdown
  ### Worktree Status (if worktrees exist)

  Check for active worktrees:
  ```bash
  git worktree list 2>/dev/null | grep -v "^$"
  ```

  Report format: "Worktrees: X active (use `/merge-worktrees` when complete)"
  ```

- **PATTERN**: Similar to agent inventory — quick count, not full details
- **IMPORTS**: None
- **GOTCHA**: Don't fail if not in a git repo or worktrees don't exist
- **VALIDATE**: `grep -c "worktree" .opencode/commands/prime.md` (should be ≥1)

### UPDATE `reference/archon-workflow.md`

- **IMPLEMENT**: Compress violation examples (lines 270-302) to 1-2 examples per pattern:
  ```markdown
  ### Common Violations

  **WRONG**: Long query with full sentence
  ```
  rag_search_knowledge_base(query="how do I implement user authentication with OAuth2 and JWT tokens in my application")
  ```

  **CORRECT**: Short, focused query
  ```
  rag_search_knowledge_base(query="OAuth2 JWT authentication")
  ```

  See `memory.md` gotcha: "Archon queries: Long RAG queries return poor results — Keep to 2-5 keywords"
  ```

- **PATTERN**: One example is enough — remove redundant examples
- **IMPORTS**: None
- **GOTCHA**: Keep the memory.md cross-reference
- **VALIDATE**: `wc -l reference/archon-workflow.md` (should decrease by ~20 lines)

### UPDATE `.opencode/commands/setup-github-automation.md`

- **IMPLEMENT**: Clarify template sources and add workflow sync note:
  ```markdown
  ## Workflow Templates

  This command copies workflows from `reference/github-workflows/` to `.github/workflows/`.

  **Note**: The `.github/workflows/prompts/` directory contains GitHub-adapted prompts
  that mirror local commands. These are NOT synchronized automatically. If a local
  command changes, update the corresponding prompt manually.

  Template files:
  - `reference/github-workflows/opencode-fix.yml` → `.github/workflows/opencode-fix.yml`
  - `reference/github-workflows/opencode-fix-coderabbit.yml` → `.github/workflows/opencode-fix-coderabbit.yml`
  ```

- **PATTERN**: Document the relationship between template and active files
- **IMPORTS**: None
- **GOTCHA**: Don't try to auto-sync — it's error-prone
- **VALIDATE**: `grep -c "github-workflows" .opencode/commands/setup-github-automation.md` (should be ≥2)

### UPDATE `memory.md`

- **IMPLEMENT**: Add gotcha about GitHub prompt drift:
  ```markdown
  - **GitHub prompts drift**: `.github/workflows/prompts/` mirrors commands but isn't auto-synced — Update manually when commands change
  ```

  Also add architecture pattern for worktrees:
  ```markdown
  - **Worktree integration**: Use `/new-worktree` for parallel features, `/merge-worktrees` to consolidate. Each worktree runs independent PIV Loop. Used in: parallel development
  ```

- **PATTERN**: Keep gotchas concise (1 line each)
- **IMPORTS**: None
- **GOTCHA**: Don't exceed 100 lines total in memory.md
- **VALIDATE**: `grep -c "GitHub prompts drift" memory.md` (should be 1)

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify worktree mention in PIV Loop
grep -i "worktree" sections/02_piv_loop.md

# Verify prime command has worktree check
grep -i "worktree" .opencode/commands/prime.md
```

### Content Verification
```bash
# Verify archon workflow compressed
wc -l reference/archon-workflow.md
# Should be <320 lines (was 320)

# Verify setup-github-automation mentions templates
grep "reference/github-workflows" .opencode/commands/setup-github-automation.md
```

### Cross-Reference Check
```bash
# Verify memory.md gotchas still under 100 lines
wc -l memory.md
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
- None (all updates to existing files)

### Files Modified
- `sections/02_piv_loop.md` — Added worktree section
- `.opencode/commands/prime.md` — Added worktree status check
- `reference/archon-workflow.md` — Compressed violation examples
- `.opencode/commands/setup-github-automation.md` — Clarified template sources
- `memory.md` — Added gotcha about GitHub prompt drift, worktree pattern

### Patterns Established
- **Worktree as PIV Extension**: Worktrees are first-class parallel PIV Loops
- **Template Source Clarity**: Document which directory is source of truth

### State for Next Sub-Plan
- Worktrees now part of core methodology documentation
- Subsystem connections documented
- Sub-plan 05 can assume all subsystems are integrated when adding persistence
