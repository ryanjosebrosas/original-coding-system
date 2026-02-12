# Plan Overview: OpenAgents System

<!-- PLAN-SERIES -->

> **This is a decomposed plan overview.** It coordinates multiple sub-plans that together
> implement a comprehensive agent framework inspired by OpenAgentsControl. Each sub-plan
> is self-contained and executable in a fresh conversation. Do NOT implement from this
> file — use `/execute` on each sub-plan in order.
>
> **Total Sub-Plans**: 5
> **Total Estimated Tasks**: 28

---

## Feature Description

Create a comprehensive agent system (21+ agents) for My Coding System that adopts OpenAgentsControl patterns (context-first execution, approval gates, parallel task execution via Archon, session management) while staying within the existing PIV Loop methodology, sections/reference structure, and Archon integration.

## User Story

As a developer using My Coding System, I want a comprehensive agent framework inspired by OpenAgentsControl, so that I can leverage context-first execution, approval gates, parallel task execution, and specialized subagents while staying within my existing PIV Loop methodology and Archon integration.

## Problem Statement

The current system has 8 example agents but lacks:
- Core orchestrator agents that enforce context-first execution
- ContextScout for smart pattern discovery before coding
- TaskManager integration with Archon for parallel task execution
- Comprehensive subagent coverage (code execution, QA, documentation, specialized domains)
- Session management for subagent context handoffs

## Solution Statement

Create a comprehensive agent system organized in `.opencode/agents/` with flat naming convention:
- Decision 1: **Flat structure with prefixes** — because it's simpler than subdirectories and aligns with existing `_examples/` pattern
- Decision 2: **Direct Archon API integration** — because real-time task tracking is more valuable than JSON files
- Decision 3: **Adapt OAC patterns to PIV Loop** — because wholesale adoption would conflict with existing methodology
- Decision 4: **Keep existing 8 example agents** — because they're already tuned for research + code review patterns

## Feature Metadata

- **Feature Type**: New Capability
- **Estimated Complexity**: High
- **Plan Mode**: Decomposed (5 sub-plans)
- **Primary Systems Affected**: `.opencode/agents/`, `templates/AGENT-TEMPLATE.md`, `reference/subagents-overview.md`
- **Dependencies**: Archon MCP tools (task_create, task_update, task_list), existing PIV Loop methodology

---

## CONTEXT REFERENCES

> Shared context that ALL sub-plans need. Each sub-plan also has its own
> per-phase context section. The execution agent reads BOTH this section
> and the sub-plan's context before implementing.

### Relevant Codebase Files

> IMPORTANT: The execution agent MUST read these files before implementing any sub-plan!

- `templates/AGENT-TEMPLATE.md` (lines 1-200) — Why: The canonical agent design framework (Role → Mission → Context → Approach → Output)
- `.opencode/agents/_examples/README.md` (lines 1-100) — Why: Existing agent patterns, multi-instance routing, activation instructions
- `reference/subagents-overview.md` (lines 1-147) — Why: Subagent architecture, context handoff model, parallel execution
- `sections/15_archon_workflow.md` (lines 1-6) — Why: Archon integration pointer, task management rules
- `reference/archon-workflow.md` — Why: Full Archon MCP usage (load on-demand for TaskManager sub-plan)

### New Files to Create (All Sub-Plans)

**Sub-plan 01 — Core Orchestrators**:
- `.opencode/agents/core-openagent.md` — Universal agent for questions, tasks, workflow coordination
- `.opencode/agents/core-opencoder.md` — Development orchestrator with approval gates

**Sub-plan 02 — Discovery Subagents**:
- `.opencode/agents/subagent-contextscout.md` — Smart internal context discovery
- `.opencode/agents/subagent-externalscout.md` — External documentation fetcher

**Sub-plan 03 — Task Management**:
- `.opencode/agents/subagent-taskmanager.md` — Task breakdown via Archon API
- `.opencode/agents/subagent-batchexecutor.md` — Parallel task execution coordinator

**Sub-plan 04 — Code Execution & QA**:
- `.opencode/agents/subagent-coderagent.md` — Atomic coding task executor
- `.opencode/agents/subagent-buildagent.md` — Build and validation runner
- `.opencode/agents/subagent-testengineer.md` — Test authoring specialist

**Sub-plan 05 — Documentation & Specialists**:
- `.opencode/agents/subagent-docwriter.md` — Documentation generator
- `.opencode/agents/specialist-frontend.md` — Frontend development
- `.opencode/agents/specialist-backend.md` — Backend/API development
- `.opencode/agents/specialist-devops.md` — DevOps and infrastructure
- `.opencode/agents/specialist-data.md` — Data engineering and analytics
- `.opencode/agents/specialist-copywriter.md` — Marketing and content copy
- `.opencode/agents/specialist-technical-writer.md` — Technical documentation

### Related Memories (from memory.md)

- Memory: "Adopted 3-tier skills architecture (SKILL.md → references/)" — Relevance: Agent files should follow similar progressive disclosure pattern
- Memory: "NEVER use EnterPlanMode — use /planning command instead" — Relevance: Core agents should reference /planning, not built-in plan mode
- Memory: "Archon tasks: Only ONE task in 'doing' status at a time" — Relevance: TaskManager must enforce this constraint
- Memory: "Keep auto-loaded context minimal (~2K tokens)" — Relevance: Agent prompts should be concise, reference files for deep context

### Relevant Documentation

- [OpenAgentsControl Repository](https://github.com/darrenhinde/OpenAgentsControl)
  - Specific section: `.opencode/agent/core/opencoder.md`
  - Why: Reference implementation for staged workflow (Discover → Propose → Approve → Execute → Validate)

- [OpenAgentsControl Context System](https://github.com/darrenhinde/OpenAgentsControl/tree/main/.opencode/context)
  - Specific section: `navigation.md`
  - Why: Context organization patterns to adapt for our sections/reference structure

### Patterns to Follow

**Agent Frontmatter Pattern** (from `templates/AGENT-TEMPLATE.md:45-58`):
```markdown
---
name: {agent-name}
description: Use this agent when {triggering scenario}. {What it does and why}.
model: sonnet
tools: ["Read", "Glob", "Grep"]
---
```
- Why this pattern: Standard OpenCode agent format
- Common gotchas: `name` must be lowercase-with-hyphens; `description` guides autonomous delegation

**Output Format Control Pattern** (from `templates/AGENT-TEMPLATE.md:105-111`):
```markdown
When done, instruct the main agent to NOT start fixing any issues without the user's approval.
```
- Why this pattern: Prevents main agent from auto-acting on findings
- Common gotchas: Must be in BOTH agent system prompt AND calling command for safety

**OAC Critical Rules Pattern** (from OpenAgentsControl opencoder.md):
```xml
<critical_rules priority="absolute" enforcement="strict">
  <rule id="approval_gate" scope="all_execution">
    Request approval before ANY implementation (write, edit, bash).
  </rule>
  <rule id="stop_on_failure" scope="validation">
    STOP on test fail/build errors - NEVER auto-fix without approval
  </rule>
</critical_rules>
```
- Why this pattern: Enforces human control over AI execution
- Common gotchas: Read-only operations (Read, Glob, Grep, list) should NOT require approval

**Archon Task Pattern** (from `reference/archon-workflow.md`):
```
task_create(title="Task name", description="...", status="todo", priority="high")
task_update(task_id="...", status="doing")
task_list(status="doing")  # Should return only 1 task
```
- Why this pattern: TaskManager must use Archon API, not JSON files
- Common gotchas: Only ONE task in "doing" status at a time

---

## PLAN INDEX

| # | Phase | Sub-Plan File | Tasks | Context Load |
|---|-------|---------------|-------|--------------|
| 01 | Core Orchestrators | `requests/openagents-system-plan-01-core.md` | 5 | Medium |
| 02 | Discovery Subagents | `requests/openagents-system-plan-02-discovery.md` | 5 | Low |
| 03 | Task Management | `requests/openagents-system-plan-03-tasks.md` | 6 | Medium |
| 04 | Code Execution & QA | `requests/openagents-system-plan-04-execution.md` | 6 | Low |
| 05 | Docs & Specialists | `requests/openagents-system-plan-05-specialists.md` | 6 | Low |

> Each sub-plan targets 5-6 tasks and 200-300 lines. Context load estimates
> help decide instance assignment (Low = minimal codebase reads, Medium = several files).

---

## EXECUTION ROUTING

### Instance Assignment

| Sub-Plan | Instance | Model | Notes |
|----------|----------|-------|-------|
| 01 | opencode2 | Sonnet | Core agents need highest quality |
| 02 | opencode3 | Sonnet | Discovery agents, medium complexity |
| 03 | opencode2 | Sonnet | Archon integration needs care |
| 04 | opencode3 | Sonnet | Straightforward agent creation |
| 05 | opencode2 | Sonnet | Final polish, specialists |

### Fallback Chain

```
Primary:   opencode2 (Sonnet) — main execution instance
Secondary: opencode3 (Sonnet) — if primary hits rate limit
Fallback:  opencode1 (Sonnet) — last resort
```

### Execution Instructions

**Manual execution** (recommended for this feature):
```bash
# Sub-plan 1 on primary instance
opencode2 --model sonnet
> /execute requests/openagents-system-plan-01-core.md

# Sub-plan 2 on secondary instance
opencode3 --model sonnet
> /execute requests/openagents-system-plan-02-discovery.md

# Continue alternating...
```

**Between sub-plans**:
- Each sub-plan runs in a fresh conversation (context reset)
- Read HANDOFF NOTES from completed sub-plan before starting the next
- If a sub-plan fails, fix and re-run it before proceeding

---

## AGENT INVENTORY

### Final Agent Count: 21 Agents

**Core Orchestrators (2)**:
| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| OpenAgent | `core-openagent.md` | Sonnet | Universal agent, entry point |
| OpenCoder | `core-opencoder.md` | Sonnet | Development orchestrator |

**Discovery Subagents (2)**:
| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| ContextScout | `subagent-contextscout.md` | Haiku | Internal context discovery |
| ExternalScout | `subagent-externalscout.md` | Sonnet | External docs fetcher |

**Task Management (2)**:
| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| TaskManager | `subagent-taskmanager.md` | Sonnet | Task breakdown via Archon |
| BatchExecutor | `subagent-batchexecutor.md` | Sonnet | Parallel task coordinator |

**Code Execution (2)**:
| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| CoderAgent | `subagent-coderagent.md` | Sonnet | Atomic task executor |
| BuildAgent | `subagent-buildagent.md` | Haiku | Build validation |

**Quality Assurance (5 — 4 existing + 1 new)**:
| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| TestEngineer | `subagent-testengineer.md` | Haiku | Test authoring |
| (existing) | `code-review-type-safety.md` | Haiku | Type checking |
| (existing) | `code-review-security.md` | Haiku | Security review |
| (existing) | `code-review-architecture.md` | Haiku | Architecture review |
| (existing) | `code-review-performance.md` | Haiku | Performance review |

**Documentation (1)**:
| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| DocWriter | `subagent-docwriter.md` | Sonnet | Documentation generator |

**Specialists (6)**:
| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| FrontendSpecialist | `specialist-frontend.md` | Sonnet | Frontend development |
| BackendSpecialist | `specialist-backend.md` | Sonnet | Backend/API development |
| DevOpsAgent | `specialist-devops.md` | Sonnet | DevOps and infrastructure |
| DataAnalyst | `specialist-data.md` | Sonnet | Data engineering |
| Copywriter | `specialist-copywriter.md` | Haiku | Marketing copy |
| TechnicalWriter | `specialist-technical-writer.md` | Haiku | Technical docs |

**Research Agents (2 existing)**:
| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| (existing) | `research-codebase.md` | Haiku | Codebase exploration |
| (existing) | `research-external.md` | Sonnet | External research |

---

## ACCEPTANCE CRITERIA

- [ ] All 21 agents created with correct frontmatter and structure
- [ ] Core agents (OpenAgent, OpenCoder) enforce approval gates
- [ ] ContextScout discovers context from sections/ and reference/ directories
- [ ] TaskManager integrates with Archon MCP tools (not JSON files)
- [ ] All agents follow templates/AGENT-TEMPLATE.md framework
- [ ] Existing 8 example agents remain functional
- [ ] No broken cross-references between agents
- [ ] README.md in .opencode/agents/ updated with full inventory
- [ ] All sub-plans executed successfully
- [ ] All validation commands pass

---

## COMPLETION CHECKLIST

- [ ] Sub-plan 01 (Core Orchestrators) — complete
- [ ] Sub-plan 02 (Discovery Subagents) — complete
- [ ] Sub-plan 03 (Task Management) — complete
- [ ] Sub-plan 04 (Code Execution & QA) — complete
- [ ] Sub-plan 05 (Docs & Specialists) — complete
- [ ] All acceptance criteria met
- [ ] Feature-wide manual validation passed
- [ ] Ready for `/commit`

---

## NOTES

### Key Design Decisions

- **Why decomposition over single plan**: 21 agents with deep context is too large for one conversation. Each sub-plan focuses on one category (5-6 agents) with clear handoffs.
- **Why flat structure with prefixes**: Simpler than OAC's nested directories. Prefixes (`core-`, `subagent-`, `specialist-`) provide visual organization without directory complexity.
- **Why Archon over JSON files**: Your system already has Archon integration. JSON files would duplicate functionality and add maintenance burden.
- **Why keep existing agents**: The 8 example agents (research + code review) are already tuned. Adding new agents extends rather than replaces them.

### Risks

- **Risk 1: Agent prompt size** — OAC agents are 500+ lines. Our agents should be more concise (200-300 lines) per memory.md guidance. Mitigation: Focus on essential rules, reference files for deep context.
- **Risk 2: Archon API availability** — TaskManager depends on Archon MCP. Mitigation: Include fallback instructions if Archon unavailable.
- **Risk 3: Context discovery complexity** — ContextScout needs to understand sections/ and reference/ structure. Mitigation: Hardcode key paths in agent prompt.

### Confidence Score: 8/10

- **Strengths**: Clear OAC reference implementation, well-defined agent categories, existing patterns to follow
- **Uncertainties**: Exact Archon API surface (need to verify tool names), optimal agent prompt length
- **Mitigations**: Test TaskManager with Archon early, iterate on prompt length based on results
