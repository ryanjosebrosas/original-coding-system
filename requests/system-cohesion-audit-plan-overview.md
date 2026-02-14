# Plan Overview: System Cohesion Audit

<!-- PLAN-SERIES -->

> **This is a decomposed plan overview.** It coordinates 5 sub-plans that together
> evolve the methodology system to be more cohesive, connected, and PIV-Loop-aligned.
>
> **Total Sub-Plans**: 5
> **Total Estimated Tasks**: 28

---

## Feature Description

A comprehensive audit and evolution of the My Coding System methodology to close gaps between commands, agents, references, templates, and workflows. The goal: make every component feel like part of one unified system where the PIV Loop (Plan → Implement → Validate → iterate) is the beating heart.

## User Story

As a developer using this methodology, I want all components (commands, agents, references, templates) to feel interconnected and mutually reinforcing, so that I can focus on building features instead of wondering which tool to use or why things don't connect.

## Problem Statement

The system has grown organically with strong documentation but weak connections:
- **Commands don't fully leverage agents** (ContextScout missing from 5 commands, core agents never invoked)
- **References repeat content** (5-Level Validation Pyramid in 3 files, overviews that duplicate deep-dives)
- **PIV Loop handoffs are broken** (context lost between phases, contradictory guidance)
- **Subsystems are disconnected** (GitHub workflows autonomous, skills not implemented, Archon optional)
- **State evaporates** (sessions not persisted, memory updates voluntary, no WIP tracking)

## Solution Statement

- Decision 1: Decompose into 5 phases (Foundation → Integration → Continuity → Connections → Persistence) — because each phase is independently valuable and dependencies flow naturally
- Decision 2: Prioritize token efficiency first — because cleaner context makes all later work easier
- Decision 3: Use existing patterns (pointer files, on-demand guides) rather than new abstractions — because consistency reduces cognitive load
- Decision 4: Keep changes surgical and incremental — because large refactorings break more than they fix

## Feature Metadata

- **Feature Type**: Enhancement / Refactor
- **Estimated Complexity**: High
- **Plan Mode**: Decomposed (5 sub-plans)
- **Primary Systems Affected**: `.opencode/commands/`, `.opencode/agents/`, `reference/`, `templates/`, `memory.md`, `sections/`
- **Dependencies**: None (self-contained methodology)

---

## CONTEXT REFERENCES

### Relevant Codebase Files

- `.opencode/commands/*.md` — All 21 commands need review for agent integration
- `.opencode/agents/*.md` — All 24 active agents need command connections
- `reference/command-agent-mapping.md` — Current mapping has gaps (`/quick-github-setup` listed but doesn't exist)
- `sections/02_piv_loop.md:1-55` — PIV Loop methodology (handoff guidance at lines 28-38)
- `memory.md:35-42` — Gotchas section (agent activation, Archon constraints)

### New Files to Create (All Sub-Plans)

- `reference/validation-pyramid.md` — Canonical 5-level validation — Sub-plan: 01
- `templates/PIV-STATE-TEMPLATE.md` — Cross-command state file — Sub-plan: 03
- `.opencode/commands/session-resume.md` — Resume interrupted work — Sub-plan: 05
- `reference/overview-guide.md` — Pattern for minimal overviews — Sub-plan: 01

### Related Memories (from memory.md)

- Memory: "Reference-to-System Alignment: Audit found gaps between reference prose and actionable artifacts — Always create templates alongside reference guides" — Relevance: Avoid creating reference without corresponding action
- Memory: "Command compression: Commands compressed 43-59% with no functionality loss" — Relevance: Compression pattern proven
- Memory: "/prime token bloat: Original /prime consumed 19% of context (37K tokens) — Optimized to ~8K" — Relevance: Token efficiency matters

### Relevant Documentation

- [Anthropic Engineering: Context Engineering](https://www.anthropic.com/engineering/)
  - Specific section: Context management patterns
  - Why: Best practices for managing AI context windows

### Patterns to Follow

**Pointer Pattern** (from `AGENTS.md:37-54`):
```markdown
## On-Demand Guides
| Guide | Load when... |
|-------|-------------|
| `reference/file.md` | Condition |
```
- Why this pattern: Keeps auto-loaded context minimal, loads detail on-demand
- Common gotchas: Don't duplicate content in pointer and target

**Optional Agent Pattern** (from `reference/command-agent-mapping.md:35-48`):
```markdown
**If {AgentName} available** (`ls .opencode/agents/{agent-file}.md`):
- Launch `@{agent-name}` with query: "{specific query}"
- Review findings before proceeding

**If agent not available**: Skip — proceed to {next step}.
```
- Why this pattern: Commands work without agents, agents enhance but never block
- Common gotchas: Always include fallback, never make agent required

---

## PLAN INDEX

| # | Phase | Sub-Plan File | Tasks | Context Load |
|---|-------|---------------|-------|--------------|
| 01 | Foundation | `requests/system-cohesion-audit-plan-01-foundation.md` | 6 | Low |
| 02 | Command-Agent Integration | `requests/system-cohesion-audit-plan-02-agent-integration.md` | 6 | Medium |
| 03 | PIV Loop Continuity | `requests/system-cohesion-audit-plan-03-piv-continuity.md` | 5 | Medium |
| 04 | Cross-System Connections | `requests/system-cohesion-audit-plan-04-connections.md` | 5 | Medium |
| 05 | Session & Memory Evolution | `requests/system-cohesion-audit-plan-05-persistence.md` | 6 | Low |

> Each sub-plan targets 5-8 tasks and 150-250 lines. Context load estimates
> help decide instance assignment (Low = minimal codebase reads, Medium = several files).

---

## EXECUTION ROUTING

### Instance Assignment

| Sub-Plan | Instance | Model | Notes |
|----------|----------|-------|-------|
| 01 | opencode | Default | Foundation — token cleanup |
| 02 | opencode | Default | Agent integration — multiple command reads |
| 03 | opencode | Default | PIV continuity — core methodology |
| 04 | opencode | Default | Cross-system — diverse files |
| 05 | opencode | Default | Persistence — state patterns |

### Fallback Chain

```
Primary:   opencode (default) — main execution instance
Fallback:  Run sequentially in same session if needed
```

### Execution Instructions

**Manual execution** (recommended for complex features):
```bash
# Sub-plan 1
> /execute requests/system-cohesion-audit-plan-01-foundation.md

# Verify foundation before proceeding
> git status

# Sub-plan 2
> /execute requests/system-cohesion-audit-plan-02-agent-integration.md

# Continue for remaining sub-plans...
```

**Between sub-plans**:
- Each sub-plan runs in a fresh conversation (context reset)
- Read HANDOFF NOTES from completed sub-plan before starting the next
- If a sub-plan fails, fix and re-run it before proceeding

---

## ACCEPTANCE CRITERIA

- [x] Token redundancy reduced (no content in 3+ files)
- [x] All commands with agent potential have agent integration
- [x] PIV Loop handoffs have explicit state passing
- [x] Cross-command state file created and used by 3+ commands
- [x] Session context has lifecycle (create → active → archived)
- [x] Memory update triggers are explicit, not voluntary
- [x] All sub-plans executed successfully
- [x] No broken references between files
- [x] Backwards compatibility maintained

---

## COMPLETION CHECKLIST

- [x] Sub-plan 01 (Foundation) — complete
- [x] Sub-plan 02 (Agent Integration) — complete
- [x] Sub-plan 03 (PIV Continuity) — complete
- [x] Sub-plan 04 (Connections) — complete
- [x] Sub-plan 05 (Persistence) — complete
- [x] All acceptance criteria met
- [x] Ready for `/commit`

---

## NOTES

### Key Design Decisions
- Decomposition over single plan: 5 phases with clear boundaries, each independently testable
- Foundation first: Token cleanup makes everything else easier
- Existing patterns: Use pointer files and optional agent patterns rather than inventing new ones

### Risks
- Risk: Changes to core files (sections/, AGENTS.md) may break auto-loading — Mitigation: Test `/prime` after changes
- Risk: Agent integration changes may conflict with existing command behavior — Mitigation: Keep all agent invocations optional with fallbacks
- Risk: State file introduces new complexity — Mitigation: Start with minimal state, expand only if proven useful

### Confidence Score: 8/10
- **Strengths**: Comprehensive research (6 parallel agents), clear gap identification, existing patterns to follow
- **Uncertainties**: Exact token savings from consolidation, user preference for new commands
- **Mitigations**: Validate each sub-plan independently, commit after each phase
