# Project Memory

> - AI reads at session start (`/prime`) and during planning (`/planning`)
> - AI appends after implementation (`/commit`)
> - Human can edit anytime — it's just a markdown file
> - Keep entries concise (1-2 lines each) to minimize context token usage

---

## Key Decisions
<!-- Format: - [YYYY-MM-DD] Decision — Reason -->
- [2026-02-12] Migrated from mem0 MCP to file-based memory.md — Simpler, no external dependency, version-controlled
- [2026-02-12] Slimmed CLAUDE.md by moving sections 06-14 to reference/ — Saves ~12,000 tokens per session
- [2026-02-12] Adopted 3-tier skills architecture (SKILL.md → references/) — Progressive disclosure for complex workflows
- [2026-02-12] Plan decomposition for complex features — `<!-- PLAN-SERIES -->` marker triggers series mode in `/execute`
- [2026-02-12] Moved Archon workflow to on-demand reference — Auto-loaded pointer is 5 lines, full guide at `reference/archon-workflow.md`
- [2026-02-13] Added agent orchestration layer — Session context, handoff protocol, routing guide enable multi-agent coordination
- [2026-02-13] Session context is optional for simple plans — Only 4+ tasks trigger session initialization in /execute

## Architecture Patterns
<!-- Format: - **Pattern name**: Description. Used in: location -->
- **Modular AGENTS.md**: Core rules in `sections/` (auto-loaded), deep context in `reference/` (on-demand). Used in: AGENTS.md
- **PIV Loop**: Plan → Implement → Validate, one feature slice per iteration. Used in: all development
- **Agents**: Agent files in `.opencode/agents/`, examples in `_examples/`. Used in: `.opencode/agents/`
- **Command chaining**: `/execute → /execution-report → /code-review → /code-review-fix → /commit`. Used in: validation workflow
- **Plan decomposition**: Overview + N sub-plans for High-complexity features. Trigger: Phase 4.5 in `/planning`. Used in: `planning.md`, `execute.md`
- **Flat agent naming**: Prefix convention (`core-`, `subagent-`, `specialist-`) instead of subdirectories. Used in: `.opencode/agents/`
- **Session Context Pattern**: `.tmp/sessions/{id}/context.md` provides shared state for multi-agent workflows. Used in: complex /execute
- **Handoff Protocol**: Standardized output format (Mission Echo, Findings, Summary) enables agent chaining. Used in: all subagents

## Gotchas & Pitfalls
<!-- Format: - **Area**: What goes wrong — How to avoid -->
- **EnterPlanMode**: Never use the built-in plan mode tool — Use `/planning` command instead
- **Archon queries**: Long RAG queries return poor results — Keep to 2-5 keywords
- **Archon tasks**: Only ONE task in "doing" status at a time — Update status before starting next
- **Context bloat**: Loading all reference guides wastes tokens — Only load on-demand guides when needed
- **Session context**: Only create for 4+ task plans — Simpler plans don't need the overhead
- **Agent activation**: Example agents in _examples/ are dormant — Use /activate-agents to copy to active location

## Lessons Learned
<!-- Format: - **Context**: Lesson — Impact on future work -->
- **Reference-to-System Alignment**: Audit found gaps between reference prose and actionable artifacts — Always create templates alongside reference guides
- **CLAUDE.md restructure**: Auto-loading 14 sections burned tokens on irrelevant context — Keep auto-loaded sections to essential rules only
- **Command compression**: Commands compressed 43-59% with no functionality loss — AI follows concise instructions as well as verbose ones
- **/prime token bloat**: Original /prime consumed 19% of context (37K tokens) — Optimized to ~8K by removing verbose output, Archon RAG, full git status

## Session Notes
<!-- Format: - [YYYY-MM-DD] Brief summary of what was done -->
- [2026-02-12] OpenAgents system plan created — 22 agents, 5 sub-plans, inspired by OpenAgentsControl but adapted for PIV Loop
- [2026-02-12] OpenCode migration COMPLETE — All 5 sub-plans executed: foundation, commands, agents, docs, validation
- [2026-02-12] OpenCode migration: Sub-plan 03 agents — 4 skills + 8 example agents converted to OpenCode format
- [2026-02-12] OpenCode migration: Sub-plan 01 foundation — AGENTS.md created, .opencode/ structure established
- [2026-02-12] Completed Reference-to-System Alignment project (Plans A-D): templates, commands, skills, memory migration
- [2026-02-12] Implemented plan decomposition & execution routing — 2 templates, 2 commands updated, 4 reference docs updated
- [2026-02-12] Token efficiency: compressed 5 commands (43-59%), slimmed auto-loaded context (66%), added README.md with Mermaid diagrams
- [2026-02-13] Agent orchestration layer — Added session context template, handoff protocol, agent routing guide, /activate-agents command
- [2026-02-13] Optimized /prime for token efficiency — 8 changes: slim output format, short git status, removed Archon RAG, top-3 memory only

---

> **Sizing guide**: Keep this file under 100 lines. Large files waste context tokens at session start. Archive old entries to `memory-archive.md` if needed.
