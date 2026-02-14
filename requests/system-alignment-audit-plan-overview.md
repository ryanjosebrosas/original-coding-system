# Plan Overview: System Alignment Audit

<!-- PLAN-SERIES -->

> **This is a decomposed plan overview.** It coordinates 4 sub-plans that together
> align all system artifacts. Each sub-plan is self-contained and executable.
>
> **Total Sub-Plans**: 4
> **Total Estimated Tasks**: 22

---

## Feature Description

Comprehensive system-wide audit to align all documentation, commands, agents, templates, and memory.md. Eliminates dead references, consolidates overlapping commands, fixes stale documentation, and closes gaps between what's documented vs what exists.

## User Story

As a system maintainer, I want all documentation to accurately reflect the codebase, so that commands work reliably and references don't point to missing files.

## Problem Statement

Multiple audits revealed:
- **12 broken references** (files/directories that don't exist)
- **6 stale documentation entries** (Claude→OpenCode renames incomplete, counts wrong)
- **3 redundant commands** (overlap, naming conflicts, thin wrappers)
- **4 missing implementations** documented but not created (skills/, scripts/, workflows)

This wastes tokens on dead paths and causes confusion.

## Solution Statement

- **Decision 1: Remove over create** — Delete dead references rather than create unused infrastructure
- **Decision 2: Consolidate over duplicate** — Merge overlapping commands, rename conflicts
- **Decision 3: Single source of truth** — Align memory.md and file-structure.md counts

## Feature Metadata

- **Feature Type**: Refactor
- **Estimated Complexity**: High
- **Plan Mode**: Decomposed (4 sub-plans)
- **Primary Systems Affected**: `.opencode/commands/`, `reference/`, `templates/`, `memory.md`
- **Dependencies**: None

---

## CONTEXT REFERENCES

### Relevant Codebase Files

- `memory.md` — Cross-session memory, needs stale entry updates
- `reference/file-structure.md` — File inventory, has incorrect counts
- `reference/subagents-overview.md` — Agent documentation, categorization differs from file-structure
- `templates/GITHUB-SETUP-CHECKLIST.md` — Has stale "Claude" references
- `.opencode/commands/agents.md` — Naming conflict with root AGENTS.md
- `.opencode/commands/quick-github-setup.md` — Overlaps with setup-github-automation.md
- `.opencode/commands/tmux-worktrees.md` — Too minimal, needs expansion
- `.opencode/commands/claude-mcp.md` — Thin wrapper, minimal value
- `.opencode/agents/_examples/README.md` — Model documentation mismatch

### New Files to Create

None (removing dead references, not adding infrastructure)

### Related Memories

- Memory: "Slimmed CLAUDE.md" — Relevance: Entry is stale, now AGENTS.md
- Memory: "3-tier skills architecture" — Relevance: Documented but not implemented
- Memory: "Command-Agent Integration: 12 commands" — Relevance: Actual count is 13

### Patterns to Follow

**Reference cleanup pattern** (from existing cleanups):
- Search for all references to removed path
- Update or remove each reference
- Verify no orphaned mentions remain

---

## PLAN INDEX

| # | Phase | Sub-Plan File | Tasks | Context Load |
|---|-------|---------------|-------|--------------|
| 01 | Reference Cleanup | `requests/system-alignment-audit-plan-01-reference-cleanup.md` | 5 | Low |
| 02 | Command Consolidation | `requests/system-alignment-audit-plan-02-command-consolidation.md` | 6 | Medium |
| 03 | Documentation Alignment | `requests/system-alignment-audit-plan-03-documentation-alignment.md` | 6 | Low |
| 04 | Gap Closure | `requests/system-alignment-audit-plan-04-gap-closure.md` | 5 | Low |

---

## EXECUTION ROUTING

### Instance Assignment

| Sub-Plan | Instance | Model | Notes |
|----------|----------|-------|-------|
| 01 | opencode2 | Sonnet | Light cleanup tasks |
| 02 | opencode2 | Sonnet | Command restructuring |
| 03 | opencode2 | Sonnet | Documentation updates |
| 04 | opencode2 | Sonnet | Decision-heavy final pass |

### Fallback Chain

```
Primary:   opencode2 (Sonnet) — main execution instance
Secondary: opencode3 (Sonnet) — if primary hits rate limit
Fallback:  opencode1 (Sonnet) — last resort
```

### Execution Instructions

```bash
# Execute in order, fresh conversation per sub-plan
> /execute requests/system-alignment-audit-plan-01-reference-cleanup.md
> /execute requests/system-alignment-audit-plan-02-command-consolidation.md
> /execute requests/system-alignment-audit-plan-03-documentation-alignment.md
> /execute requests/system-alignment-audit-plan-04-gap-closure.md
```

**Between sub-plans**:
- Read HANDOFF NOTES from completed sub-plan before starting next
- Each sub-plan runs in fresh context

---

## ACCEPTANCE CRITERIA

- [x] All dead references removed or replaced with valid paths
- [x] No stale "Claude" references remain (all "OpenCode" or neutral)
- [x] Overlapping commands consolidated
- [x] memory.md entries verified against codebase
- [x] file-structure.md counts match actual files
- [x] Agent inventory documentation consistent
- [x] No broken template references

---

## COMPLETION CHECKLIST

- [x] Sub-plan 01 (Reference Cleanup) — complete
- [x] Sub-plan 02 (Command Consolidation) — complete
- [x] Sub-plan 03 (Documentation Alignment) — complete
- [x] Sub-plan 04 (Gap Closure) — complete
- [x] All acceptance criteria met
- [x] Ready for `/commit`

---

## NOTES

### Key Design Decisions

- **Remove over create**: Skills system, scripts/, and missing workflows will have their references REMOVED rather than creating unused infrastructure. The system should be lean.
- **Preserve essence**: Core PIV loop, command structure, agent patterns remain unchanged. Only fixing misalignment.

### Risks

- **Risk 1**: Removing skill references may confuse if skills are planned — Mitigation: Add note in memory.md that skills are "documented pattern, not yet implemented"
- **Risk 2**: Merging commands may break user muscle memory — Mitigation: Keep quick-github-setup as alias/redirect to setup-github-automation

### Confidence Score: 8/10

- **Strengths**: Comprehensive audit data, clear fixes identified, low-risk changes
- **Uncertainties**: Whether skills/ should exist (user decision) — addressed in sub-plan 04
- **Mitigations**: All changes are reversible via git
