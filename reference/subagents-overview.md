### Extending the PIV Loop with Parallel Workers

Subagents are isolated AI instances with custom system prompts that run in their own context window. They're not critical to the PIV Loop but are a powerful addition for parallelizing research, isolating context-heavy tasks, and building specialized AI workers. Think of them as "specialized employees" — each with a focused job description and their own workspace.

### What Subagents Are

- Isolated context windows with custom system prompts
- The main agent delegates work via the Task tool
- Each subagent works independently and returns results to the main agent
- Really just another markdown file — a prompt in your prompt toolbox
- Lives in `.opencode/agents/` (project) or `~/.opencode/agents/` (personal)

Subagents are not a new concept — the `/planning` command already uses them. Phases 2 and 3 launch Explore and general-purpose Task agents in parallel for research. The subagents deep dive guide makes this pattern explicit and teaches you to create your own.

### The Context Handoff Mental Model

```
You → Main Agent → Subagent → Main Agent → You
         ↓              ↓
    Handoff #1     Handoff #2
   (Can lose       (Can lose
    context)        context)
```

Two handoff points where context can be lost. The main agent summarizes YOUR request for the subagent (Handoff 1). The subagent summarizes ITS findings for the main agent (Handoff 2). Solution: obsessively control output formats to minimize information loss at both handoffs.

### When to Use Subagents

| Great For | Not Ideal For |
|-----------|---------------|
| Parallel research (codebase + docs simultaneously) | Simple sequential tasks |
| Parallel research (5-10 simultaneous explorations) | Priming (context gets lost in handoff) |
| Code review with controlled feedback | Tasks requiring ALL context, not summaries |
| System compliance checks across modules | Quick targeted changes |
| Plan vs execution analysis | Tasks needing iterative back-and-forth |
| Context-heavy tasks that would pollute main thread | Single-file focused edits |
| Context discovery (internal patterns + external docs) | Tasks with no external dependencies |

### Parallel Execution

Up to 10 concurrent subagents — this is the real power. Instead of one agent researching 5 aspects sequentially, launch 5 agents each researching one aspect simultaneously. Results return to the main conversation when complete.

**For large batches (5+ parallel tasks)**: Use `@subagent-batchexecutor` to coordinate parallel worker delegations. BatchExecutor handles error propagation, status tracking, and structured reporting.

Warning: many agents returning detailed results can consume significant main context. Keep agent outputs concise, or use file-based reports where agents save findings to disk instead of returning them inline.

### Output Format: The Primary Control Lever

The output format in your subagent's system prompt is the MOST critical part. It controls what the main agent sees and how it responds. Make outputs:

- **Structured and parsable** — headers, tables, severity levels
- **Include metadata** — files reviewed, line numbers, severity
- **Explicit about next steps** — what should the main agent do with results?
- **Easy to combine** — with other agents/commands downstream

Critical pattern: include "instruct the main agent to NOT start fixing issues without user approval" in your output format. Without this, the main agent may automatically act on all findings when you just wanted a report.

### Creating Custom Subagents

File location: `.opencode/agents/*.md` (project) or `~/.opencode/agents/*.md` (personal). Structure: YAML frontmatter + markdown body. The markdown body IS the system prompt.

Key frontmatter fields:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (lowercase-with-hyphens) |
| `description` | Yes | When to use — guides autonomous delegation |
| `model` | No | haiku, sonnet, opus (default: inherits from parent) |
| `tools` | No | Tool list or `["*"]` (default: inherits all) |

Two creation methods: manual (create the `.md` file yourself) or `/agents` command (Claude generates the agent for you). Use `templates/AGENT-TEMPLATE.md` for the full design guide.

### The Agent Design Framework

Five components every effective agent needs:

1. **Role Definition** — clear identity and specialized purpose
2. **Core Mission** — why this agent exists (singular focus)
3. **Context Gathering** — what files/info does it need?
4. **Analysis Approach** — specific steps to accomplish the mission
5. **Output Format** — structured, parsable results for downstream use

See `templates/AGENT-TEMPLATE.md` for the complete framework with starter template.

### Agents + Commands: Working Together

Two integration patterns:

- **Command invokes agent**: A slash command instructs the main agent to use a specific subagent, then acts on results (e.g., "use code-reviewer agent, then fix critical issues only")
- **Agent produces artifact for command**: A subagent saves a report file that a subsequent command consumes (e.g., agent writes review → `/code-review-fix` reads it)

The `/planning` command already uses this pattern — launching Explore and general-purpose agents in parallel for research. You can build the same pattern into your own commands.

### Built-in Agents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| Explore | Haiku | Read-only | File discovery, codebase search |
| Plan | Inherits | Read-only | Codebase analysis for planning |
| General-purpose | Inherits | All | Complex research, multi-step tasks |
| **OpenAgent** | Sonnet | All | Universal primary agent, workflow coordination |
| **OpenCoder** | Sonnet | All | Development orchestrator, complex coding |

Already used in `/planning` command (Phases 2 & 3 launch Explore + general-purpose in parallel).

**Core Agents** (OpenAgent, OpenCoder) are primary agents with staged workflows:
- OpenAgent: Analyze → Discover → Propose → Approve → Execute → Validate → Summarize
- OpenCoder: Discover → Propose → Init Session → Plan → Execute → Validate & Handoff

**Model selection for agents**: When choosing `model` in frontmatter (haiku, sonnet, opus), see `reference/multi-model-strategy.md` for cost-performance trade-offs and task routing guidance.

**Multi-instance routing**: For teams or power users routing work across multiple Claude instances, see `reference/multi-instance-routing.md`.

### Complete Agent Inventory

24 agents total organized by category. Core agents are always active; others are in `.opencode/agents/` or `_examples/`.

#### Core Orchestrator Agents (Always Active)

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **core-openagent** | Sonnet | All | Universal primary agent, workflow coordination |
| **core-opencoder** | Sonnet | All | Development orchestrator, complex coding |

#### Discovery Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| subagent-contextscout | Haiku | Read, Glob, Grep | Internal context discovery (sections/, reference/, templates/) |
| subagent-externalscout | Sonnet | Read, WebFetch, WebSearch | External docs fetcher for libraries/frameworks |

#### Task Management Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| subagent-taskmanager | Sonnet | Read, Glob, Grep | Task breakdown with Archon integration |
| subagent-batchexecutor | Sonnet | Read, Glob | Parallel execution coordinator |

#### Code Execution Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| subagent-coderagent | Sonnet | Read, Write, Edit, Glob, Grep, Bash | Atomic coding task executor |

#### Quality Assurance Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| subagent-buildagent | Haiku | Read, Bash, Glob | Build validation runner (read-only) |
| subagent-testengineer | Haiku | Read, Write, Edit, Glob, Grep, Bash | Test authoring specialist |

#### Documentation Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| subagent-docwriter | Sonnet | Read, Write, Edit, Glob, Grep | Technical documentation specialist |

#### Domain Specialist Agents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| specialist-frontend | Sonnet | Read, Write, Edit, Glob, Grep, Bash | Frontend architecture, React/Vue, CSS, accessibility |
| specialist-backend | Sonnet | Read, Write, Edit, Glob, Grep, Bash | API design, database patterns, system architecture |
| specialist-devops | Sonnet | Read, Write, Edit, Glob, Grep, Bash | CI/CD, infrastructure, Docker, Kubernetes |
| specialist-data | Sonnet | Read, Write, Edit, Glob, Grep, Bash | Database design, ETL, analytics, data modeling |
| specialist-copywriter | Haiku | Read, Write, Edit, Glob, Grep | UI copy, microcopy, error messages |
| specialist-technical-writer | Haiku | Read, Write, Edit, Glob, Grep | Technical docs, API docs, developer guides |

#### Research Agents (Example)

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| research-codebase | Haiku | Read, Glob, Grep | File discovery, pattern extraction |
| research-external | Sonnet | Read, Glob, Grep, WebSearch, WebFetch | Documentation search, best practices |

#### Code Review Agents (Example)

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| code-review-type-safety | Haiku | Read, Glob, Grep, Bash | Type annotations, type checking |
| code-review-security | Haiku | Read, Glob, Grep, Bash | Security vulnerabilities |
| code-review-architecture | Haiku | Read, Glob, Grep | Architecture compliance |
| code-review-performance | Haiku | Read, Glob, Grep | Performance issues |

#### Utility Agents (Example)

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| plan-validator | Haiku | Read, Glob, Grep | Plan structure validation |
| test-generator | Haiku | Read, Glob, Grep | Test case suggestions |

### Agent Summary

| Category | Count | Models |
|----------|-------|--------|
| Core Orchestrators | 2 | 2 Sonnet |
| Discovery | 2 | 1 Haiku, 1 Sonnet |
| Task Management | 2 | 2 Sonnet |
| Code Execution | 1 | 1 Sonnet |
| Quality Assurance | 2 | 2 Haiku |
| Documentation | 1 | 1 Sonnet |
| Domain Specialists | 6 | 4 Sonnet, 2 Haiku |
| Research (Example) | 2 | 1 Haiku, 1 Sonnet |
| Code Review (Example) | 4 | 4 Haiku |
| Utility (Example) | 2 | 2 Haiku |
| **Total** | **24** | **11 Sonnet, 13 Haiku** |

**Key distinction**:
- **Core agents** (OpenAgent, OpenCoder) — Always active, primary workflow handlers
- **Subagents** — Workers called by core agents for specific tasks
- **Specialists** — Domain experts for architecture/design decisions
- **Example agents** — Copy-to-activate templates in `_examples/`

### Context Discovery Pattern

Before any coding task, the recommended pattern is:

```text
1. ContextScout discovers internal patterns (sections/, reference/, templates/, memory.md)
2. ExternalScout fetches current docs for external dependencies
3. Core agent loads discovered context
4. Implementation proceeds with full context
```

**Model selection rationale**:
- **ContextScout** uses Haiku: Pattern matching against known file structure is well-suited for fast, inexpensive model
- **ExternalScout** uses Sonnet: Synthesis and summarization of external docs requires higher quality reasoning

**Decision matrix**:

| Scenario | ContextScout | ExternalScout | Both |
|----------|--------------|---------------|------|
| Pure internal task | Yes | No | - |
| External library setup | No | Yes | - |
| Feature with external lib | Yes (standards) | Yes (lib docs) | Yes |

### Task Management Pattern (Archon Integration)

TaskManager and BatchExecutor integrate with Archon MCP for real-time task tracking:

```text
1. TaskManager breaks down feature into Archon tasks
2. BatchExecutor coordinates parallel batches (5+ tasks)
3. Worker agents implement individual tasks
4. Status updates visible in Archon Kanban
```

**Archon Integration Rules**:
- Tasks created via `manage_task(action="create", ...)`
- Status flow: `todo` → `doing` → `review` → `done`
- **CRITICAL**: Only ONE task in "doing" status at a time
- See `reference/archon-workflow.md` for full tool reference

**Decision matrix**:

| Feature Complexity | Approach |
|-------------------|----------|
| Simple (1-3 files) | Direct execution, skip TaskManager |
| Medium (4-6 files) | TaskManager creates Archon tasks |
| Complex (7+ files) | TaskManager + BatchExecutor for parallel batches |

**Session Context**: TaskManager and BatchExecutor use `.tmp/sessions/{id}/context.md` files for subagent handoffs. Template at `.tmp/sessions/SESSION-CONTEXT-TEMPLATE.md`.

### Code Execution & QA Pattern

Execution agents implement code; QA agents validate it. Both are workers, not orchestrators:

```text
1. CoderAgent implements atomic tasks following session context
2. BuildAgent runs lint/typecheck/build validation (read-only)
3. TestEngineer writes tests following project patterns
4. Code review agents analyze quality (complements TestEngineer)
```

**Agent Type Distinction**:

| Agent Type | Mode | Purpose |
|------------|------|---------|
| Code review agents | READ-ONLY | Analyze code for quality issues |
| BuildAgent | READ-ONLY | Run validation commands |
| TestEngineer | WRITE | Create test files |
| CoderAgent | WRITE | Implement code changes |

**Key difference from code review agents**:
- Code review agents (type-safety, security, architecture, performance) analyze existing code
- TestEngineer writes new tests to cover code
- BuildAgent runs build/lint commands and reports errors
- CoderAgent implements atomic coding tasks

**Model assignment rationale**:

| Agent | Model | Why |
|-------|-------|-----|
| CoderAgent | Sonnet | Code quality requires higher capability |
| BuildAgent | Haiku | Command execution is pattern matching |
| TestEngineer | Haiku | Test writing follows existing patterns |

### Agents vs Skills vs Commands

| Aspect | Commands | Skills | Subagents |
|--------|----------|--------|-----------|
| What | Saved prompts | Knowledge directories | Separate AI instances |
| Who invokes | User (`/command`) | User or auto-load | User or auto-delegate |
| Context | Main conversation | Main conversation | Own isolated context |
| Best for | Workflows, automation | Conventions, procedures | Parallel work, isolation |

Use ALL together: commands orchestrate, skills provide knowledge, agents do the work.

### Trust Progression (Complete)

```
Manual → Commands → Chained → Subagents → Remote Automation
  ↑ trust & verify ↑  ↑ trust & verify ↑  ↑ trust & verify ↑  ↑ trust & verify ↑
```

Before creating subagents: your manual prompts for the task work reliably. Before parallelizing: your single-agent workflow produces consistent results. Don't skip stages.

### Reference Files

- `templates/AGENT-TEMPLATE.md` — Design guide for creating subagents
- `reference/subagents-guide.md` — Detailed creation walkthrough, frontmatter reference, advanced patterns
- Load when: creating a new subagent, debugging agent handoffs, designing parallel workflows
