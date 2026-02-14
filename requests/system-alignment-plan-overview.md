# Plan Overview: System Alignment Audit

<!-- PLAN-SERIES -->

> **This is a decomposed plan overview.** It coordinates multiple sub-plans that together
> implement a comprehensive system alignment. Each sub-plan is self-contained and executable
> in a fresh conversation.
>
> **Total Sub-Plans**: 4
> **Total Estimated Tasks**: 24

---

## Feature Description

Full system audit and alignment across 4 dimensions: Command-Agent Integration, Reference-Reality Alignment, Template Completeness, and Workflow Continuity. This closes gaps between documentation and implementation, activates orphaned agents, creates missing templates, and chains workflow steps together.

## User Story

As a developer using My Coding System, I want all components connected and aligned, so that commands work correctly, documentation matches reality, and the PIV loop workflow flows smoothly.

## Problem Statement

After recent additions (agents, commands, tmux integration), the system has accumulated drift:
- 6 orphan agents not invoked by any command
- 11 documentation discrepancies (skills don't exist, counts outdated)
- 11 unused templates + 6 hardcoded formats
- 6 broken workflow chains between commands

## Solution Statement

- Decision 1: **Phase by dimension** — Each audit dimension gets its own sub-plan for focused execution
- Decision 2: **Documentation first** — Fix reference/ before commands so changes are documented correctly
- Decision 3: **Prioritize breaking issues** — Fix workflow breaks and missing files before optimizations
- Decision 4: **Defer non-critical** — Some orphans (utility commands) are intentional; don't force integration

## Feature Metadata

- **Feature Type**: Refactor / Enhancement
- **Estimated Complexity**: High
- **Plan Mode**: Decomposed (4 sub-plans)
- **Primary Systems Affected**: `.opencode/commands/`, `.opencode/agents/`, `templates/`, `reference/`, `memory.md`
- **Dependencies**: None

---

## CONTEXT REFERENCES

### Relevant Codebase Files

- `.opencode/commands/planning.md` (lines 72-88) — Agent availability check pattern
- `.opencode/commands/execute.md` (lines 29-40) — Plan-validator pattern
- `.opencode/commands/end-to-end-feature.md` (lines 95-128) — Full workflow chain
- `reference/file-structure.md` (lines 88-123) — Documented structure (needs updates)
- `reference/command-agent-mapping.md` (full) — Command-agent integration spec
- `memory.md` (lines 19-33) — Current architecture patterns

### New Files to Create (All Sub-Plans)

- `templates/RCA-TEMPLATE.md` — Sub-plan 02
- `templates/CODE-REVIEW-TEMPLATE.md` — Sub-plan 02
- `templates/PR-DESCRIPTION-TEMPLATE.md` — Sub-plan 02
- `templates/SYSTEM-REVIEW-TEMPLATE.md` — Sub-plan 02
- `templates/.coderabbit.yaml` — Sub-plan 02
- `.opencode/agents/_examples/research-codebase.md` — Sub-plan 01
- `.opencode/agents/_examples/research-external.md` — Sub-plan 01
- `.opencode/agents/_examples/code-review-type-safety.md` — Sub-plan 01
- `.opencode/agents/_examples/code-review-security.md` — Sub-plan 01
- `.opencode/agents/_examples/code-review-architecture.md` — Sub-plan 01
- `.opencode/agents/_examples/code-review-performance.md` — Sub-plan 01
- `.opencode/agents/_examples/plan-validator.md` — Sub-plan 01
- `.opencode/agents/_examples/test-generator.md` — Sub-plan 01

### Related Memories (from memory.md)

- Memory: "Reference-to-System Alignment audit found gaps" — Relevance: This is the follow-up to close those gaps
- Memory: "Command-agent integration — 12 commands enhanced" — Relevance: Need to verify and extend to all 23 commands
- Memory: "Agent activation: Example agents in _examples/ are dormant" — Relevance: Must create missing example agents

### Patterns to Follow

**Agent Availability Check** (from `.opencode/commands/rca.md:36`):
```markdown
1. **Check agent availability**:
   ```bash
   ls .opencode/agents/subagent-contextscout.md
   ```
   If file exists: Use `@subagent-contextscout` agent
   If not: Continue with manual context gathering
```
- Why this pattern: Graceful degradation when agents aren't activated
- Common gotchas: Don't assume agents exist; always check first

---

## PLAN INDEX

| # | Phase | Sub-Plan File | Tasks | Context Load |
|---|-------|---------------|-------|--------------|
| 01 | Reference-Reality | `requests/system-alignment-plan-01-reference.md` | 6 | Medium |
| 02 | Template-Completeness | `requests/system-alignment-plan-02-templates.md` | 6 | Low |
| 03 | Command-Agent | `requests/system-alignment-plan-03-agents.md` | 6 | Medium |
| 04 | Workflow-Continuity | `requests/system-alignment-plan-04-workflow.md` | 6 | Medium |

> Each sub-plan targets 5-8 tasks. Context load estimates help decide instance assignment.

---

## EXECUTION ROUTING

### Instance Assignment

| Sub-Plan | Instance | Model | Notes |
|----------|----------|-------|-------|
| 01 | opencode1 | Sonnet | Documentation fixes |
| 02 | opencode1 | Sonnet | Template creation |
| 03 | opencode1 | Sonnet | Agent integration |
| 04 | opencode1 | Sonnet | Workflow chains |

### Fallback Chain

```
Primary:   opencode1 (Sonnet) — main execution instance
Secondary: opencode2 (Sonnet) — if primary hits rate limit
Fallback:  opencode3 (Sonnet) — last resort
```

### Execution Instructions

**Manual execution** (recommended):
```bash
# Each sub-plan in order
> /execute requests/system-alignment-plan-01-reference.md
> /execute requests/system-alignment-plan-02-templates.md
> /execute requests/system-alignment-plan-03-agents.md
> /execute requests/system-alignment-plan-04-workflow.md
```

**Between sub-plans**:
- Each sub-plan runs in a fresh conversation
- Read HANDOFF NOTES from completed sub-plan before starting the next
- If a sub-plan fails, fix and re-run before proceeding

---

## ACCEPTANCE CRITERIA

- [ ] All documentation matches actual file structure
- [ ] All referenced templates exist
- [ ] All commands that should use agents check availability first
- [ ] Workflow chains explicitly pass file paths between steps
- [ ] No broken @-references in AGENTS.md or sections
- [ ] memory.md counts reflect current reality
- [ ] Example agents exist in `_examples/` (or docs updated to reflect removal)

---

## COMPLETION CHECKLIST

- [ ] Sub-plan 01 (Reference-Reality) — complete
- [ ] Sub-plan 02 (Template-Completeness) — complete
- [ ] Sub-plan 03 (Command-Agent) — complete
- [ ] Sub-plan 04 (Workflow-Continuity) — complete
- [ ] All acceptance criteria met
- [ ] Full `/prime` runs without issues
- [ ] Ready for `/commit`

---

## NOTES

### Key Design Decisions
- **Documentation first**: Fix reference/ so later changes are documented correctly
- **Create over delete**: Create missing example agents rather than removing documentation
- **Graceful degradation**: Commands check agent availability before using
- **Explicit handoffs**: Commands output explicit file paths for next step

### Risks
- **Scope creep**: 50+ findings could expand — Mitigation: Prioritize critical/medium, defer low
- **Breaking changes**: Updating command outputs could affect users — Mitigation: Additive changes only, no removal
- **Cascading updates**: One fix may reveal others — Mitigation: Run `/prime` after each sub-plan

### Confidence Score: 8/10
- **Strengths**: Audit is complete, findings are specific with file:line refs, patterns identified
- **Uncertainties**: Some orphan agents may be intentional design, not gaps
- **Mitigations**: Review each orphan case-by-case before integrating
