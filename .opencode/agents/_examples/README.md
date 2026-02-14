# OpenCode Agents

This directory contains OpenCode agents for the development methodology. The `_examples/` subdirectory contains **8 example agents** demonstrating different subagent patterns.

---

## Quick Reference

**New to agents?** Start with these guides:
- `reference/agent-routing.md` — Decision tree for which agent to use
- `reference/handoff-protocol.md` — How agents communicate results
- `templates/SESSION-CONTEXT-TEMPLATE.md` — Session context for multi-agent workflows

**Activate agents quickly**: `/activate-agents [all|research|review|utility]`

---

## Core Orchestrator Agents

These are **primary agents** (always available, Tab-cyclable) that orchestrate development workflows. Unlike example agents (copy-to-activate), these are active by default.

| Agent | Model | Mode | Purpose |
|-------|-------|------|---------|
| **core-openagent** | Opus 4.5 | Primary | Universal agent for questions, tasks, workflow coordination |
| **core-opencoder** | Opus 4.5 | Primary | Development orchestrator for complex coding, architecture, refactoring |

### When to Use

- **core-openagent**: General tasks, research, questions, simple implementations. Follows Analyze → Discover → Propose → Approve → Execute → Validate → Summarize workflow.
- **core-opencoder**: Complex features, multi-file refactoring, production development. Uses 6-stage workflow with session context and Archon integration.

### Usage Examples

```
# OpenAgent handles most tasks
Ask OpenAgent: "Research the authentication flow and suggest improvements"

# OpenCoder for complex work
Ask OpenCoder: "Refactor the payment system to support multiple providers"
```

### Key Differences

| Aspect | OpenAgent | OpenCoder |
|--------|-----------|-----------|
| Scope | General tasks | Production development |
| Complexity | Any | 4+ files preferred |
| Session context | No | Yes (`.tmp/sessions/`) |
| Archon integration | Optional | Recommended |

**Note**: These agents are defined in `.opencode/agents/core-*.md` and are always active. The agents in `_examples/` are templates to copy and customize.

---

## Discovery Subagents

These agents handle **context discovery** — finding relevant internal patterns and fetching external documentation before coding begins. They are the "secret weapons" for quality output.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **subagent-contextscout** | Haiku | Read, Glob, Grep | Internal context discovery (sections/, reference/, templates/, memory.md) |
| **subagent-externalscout** | Sonnet | Read, WebFetch, WebSearch | External documentation fetcher for libraries/frameworks |

### When to Use

- **subagent-contextscout** (Haiku): Before ANY coding task — discovers internal patterns, standards, and relevant context files. Knows the task-to-context routing table. Returns paths only (caller reads files).
- **subagent-externalscout** (Sonnet): When working with external libraries/frameworks — fetches CURRENT documentation to avoid outdated AI training data. Includes version detection and breaking changes.

### Decision Matrix

| Scenario | ContextScout | ExternalScout | Both |
|----------|--------------|---------------|------|
| Project coding standards | Yes | No | - |
| External library setup | No | Yes | - |
| Feature with external lib | Yes (standards) | Yes (lib docs) | Yes |
| Pure internal refactoring | Yes | No | - |
| New framework adoption | Yes (patterns) | Yes (framework docs) | Yes |

### Usage Examples

```
Use the @subagent-contextscout agent to find context for planning a payment integration feature
```
```
Use the @subagent-externalscout agent to fetch current Stripe API documentation
```

### Context Discovery Pattern

The recommended pattern before any complex implementation:

```text
1. ContextScout discovers internal patterns (sections/, reference/, templates/)
2. ExternalScout fetches current docs for external dependencies
3. Core agent loads discovered context
4. Implementation proceeds with full context
```

**Key insight**: ContextScout runs on Haiku (pattern matching) while ExternalScout runs on Sonnet (synthesis and summarization require higher quality).

### Note on Usage

These are **SUBAGENTS** (called by core agents like OpenAgent and OpenCoder), not primary entry points. Core agents reference them in their workflow:
- `core-openagent.md` mentions ContextScout in its Discover stage
- `core-opencoder.md` references both ContextScout and ExternalScout

---

## Task Management Subagents

These agents handle **task coordination** — breaking down complex features into trackable tasks via Archon and coordinating parallel execution.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **subagent-taskmanager** | Sonnet | Read, Glob, Grep | Task breakdown with Archon integration, calls ContextScout |
| **subagent-batchexecutor** | Sonnet | Read, Glob | Parallel execution coordinator, delegates to workers |

### When to Use

- **subagent-taskmanager** (Sonnet): For complex features (4+ files). Breaks down features into Archon tasks with dependency tracking, identifies parallel batches, provides execution order. Uses ContextScout first to discover standards.
- **subagent-batchexecutor** (Sonnet): For batches of 5+ parallel tasks. Coordinates multiple worker delegations, handles errors, reports batch completion status.

### Decision Matrix

| Feature Complexity | Recommended Approach | Notes |
|-------------------|---------------------|-------|
| Simple (1-3 files) | Direct execution | Skip TaskManager |
| Medium (4-6 files) | TaskManager | Creates Archon tasks, sequential or small batches |
| Complex (7+ files) | TaskManager + BatchExecutor | Full breakdown with parallel batches |

### Archon Integration

TaskManager creates tasks in Archon MCP, not JSON files. This provides:
- Real-time tracking visible on Kanban board
- Integration with existing task workflow
- Cross-session context via task/project history

**CRITICAL Archon Rule**: Only ONE task in "doing" status at a time.

```python
# TaskManager uses these Archon tools:
manage_task(action="create", project_id="...", title="...", description="...")
manage_task(action="update", task_id="...", status="doing"|"review"|"done")
find_tasks(filter_by="status", filter_value="doing")  # Must return 0 or 1
```

### Usage Examples

```
Use the @subagent-taskmanager agent to break down the payment integration feature into trackable tasks
```
```
Use the @subagent-batchexecutor agent to execute batch 1 tasks in parallel
```

### Workflow Pattern

The recommended pattern for complex features:

```text
1. ContextScout discovers standards (always first)
2. TaskManager breaks down feature into Archon tasks
3. BatchExecutor coordinates parallel batches (if 5+ parallel tasks)
4. Worker agents implement individual tasks
5. Core agent validates and commits
```

### Session Context Pattern

TaskManager and BatchExecutor use session context files for subagent handoffs:

```
.tmp/sessions/{session-id}/context.md
```

Template available at `.tmp/sessions/SESSION-CONTEXT-TEMPLATE.md`. Contains:
- Current request (user's original ask)
- Context files (standards to follow)
- Reference files (existing code)
- Archon task IDs with status
- Exit criteria checklist

### Note on Usage

These are **SUBAGENTS** typically called by OpenCoder for complex features. OpenCoder's workflow references them in its Plan and Execute stages.

---

## Code Execution Subagents

These agents handle **implementation** — executing atomic coding tasks with strict adherence to standards and patterns.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **subagent-coderagent** | Sonnet | Read, Write, Edit, Glob, Grep, Bash | Atomic coding task executor, reads session context |

### When to Use

- **subagent-coderagent** (Sonnet): For implementing individual tasks from a structured plan. Reads session context for standards, implements following patterns, validates after each change. Delegated by BatchExecutor for parallel execution or by OpenCoder for direct implementation.

### Worker Pattern

CoderAgent is a **WORKER**, not an orchestrator:
- Follows instructions precisely
- Does NOT make decisions outside task scope
- Does NOT modify files not specified in task
- Reads session context before implementing

### Critical Rules

```
1. Follow patterns from context files — do NOT invent new patterns
2. Validate after each file change
3. STOP on errors — do NOT auto-fix, report to calling agent
4. Keep changes atomic — one logical change per task
```

### Usage Example

```
Use the @subagent-coderagent agent to implement the user authentication module following the session context at .tmp/sessions/auth-2024-01-15/context.md
```

### Model Assignment Rationale

| Agent | Model | Why |
|-------|-------|-----|
| CoderAgent | Sonnet | Code quality requires higher capability model |

---

## Quality Assurance Subagents

These agents handle **validation** — verifying code quality through builds, type checking, and testing.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **subagent-buildagent** | Haiku | Read, Bash, Glob | Build validation runner (lint, typecheck, build) |
| **subagent-testengineer** | Haiku | Read, Write, Edit, Glob, Grep, Bash | Test authoring specialist |

### When to Use

- **subagent-buildagent** (Haiku): After implementation to verify build passes. Detects project type, runs appropriate validation commands (npm run lint/typecheck/build, ruff/mypy, cargo check/clippy). Read-only — reports errors, doesn't fix them.
- **subagent-testengineer** (Haiku): After implementation to add test coverage. Detects testing framework, writes tests following project patterns, runs tests to verify they pass.

### Model Assignment Rationale

| Agent | Model | Why |
|-------|-------|-----|
| BuildAgent | Haiku | Command execution and output parsing is pattern matching |
| TestEngineer | Haiku | Test writing follows existing project patterns |

### Read-Only Validation Pattern

BuildAgent is strictly **read-only**:
- Tools do NOT include Write or Edit
- Only runs commands and reports results
- Never auto-fixes errors — that's CoderAgent's job

### Usage Examples

```
Use the @subagent-buildagent agent to verify the build passes after recent changes
```
```
Use the @subagent-testengineer agent to write tests for the payment processing module
```

### Integration with Code Review Agents

**Important distinction**:

| Agent Type | Mode | Purpose |
|------------|------|---------|
| Code review agents | READ-ONLY | Analyze code quality, find issues |
| BuildAgent | READ-ONLY | Run lint/typecheck/build commands |
| TestEngineer | WRITE | Create test files |
| CoderAgent | WRITE | Implement code changes |

Code review agents (type-safety, security, architecture, performance) analyze existing code for issues. TestEngineer writes new tests. BuildAgent runs validation commands. They complement each other in the quality workflow.

### Execution Flow

The complete workflow from planning to validation:

```text
OpenCoder → TaskManager → BatchExecutor → CoderAgent (parallel implementation)
                                       → BuildAgent (build validation)
                                       → TestEngineer (test authoring)
                                       → Code Review Agents (quality analysis)
```

---

## Research Agents

These agents handle **parallel research** — exploring your codebase and external documentation simultaneously. They're designed to be invoked from commands like `/planning` or used directly for ad-hoc research.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **research-codebase** | Haiku | Read, Glob, Grep | File discovery, pattern extraction, codebase exploration |
| **research-external** | Sonnet | Read, Glob, Grep, WebSearch, WebFetch | Documentation search, best practices, version compatibility |

### When to Use

- **research-codebase** (Haiku): Parallel codebase exploration during planning, finding files and patterns, extracting code examples with line numbers. Read-only tools keep it safe. Cost-optimized for high-volume exploration.
- **research-external** (Sonnet): Documentation search, best practices research, version compatibility checks, migration guides. Higher quality model for synthesis tasks that require judgment.

### Usage Examples

Invoke from a prompt or command:
```
Use the research-codebase agent to find all authentication-related files and patterns.
```
```
Use the research-external agent to find the React 19 migration guide and breaking changes.
```

### Multi-Instance Routing

Research agents use **cost-optimized routing** to `claude-zai`:

| Agent | Instance | Model | Why |
|-------|----------|-------|-----|
| **research-codebase** | `claude-zai` | Haiku | Non-critical: Phase 3b validation catches errors |
| **research-external** | `claude-zai` | Sonnet | Non-critical: validation catches errors; synthesis quality kept via Sonnet model |

**Routing Philosophy for Research**:
- Research is non-critical — wrong results get caught by Phase 3b research validation
- Unlike code review (where security findings are VITAL), research findings are always validated
- Both agents route to `claude-zai` for maximum cost savings

If you don't have multiple instances, remove the `instance:` lines and all agents will use your default.

### Parallel Research in /planning

When custom research agents are activated, the `/planning` command can launch **5-10 parallel agents** instead of 2:

```text
Main Agent (Sonnet)
  |-> research-codebase #1 (claude-zai, Haiku) --- "auth patterns middleware"
  |-> research-codebase #2 (claude-zai, Haiku) --- "session model schema"
  |-> research-codebase #3 (claude-zai, Haiku) --- "auth test fixtures"
  |-> research-external #1 (claude-zai, Sonnet) -- "JWT token refresh"
  |-> research-external #2 (claude-zai, Sonnet) -- "bcrypt password hashing"
  |-> research-external #3 (claude-zai, Sonnet) -- "OAuth2 PKCE flow"
       | (results return in parallel)
Main Agent combines findings into unified research report
```

**Speed improvement**: 3-5x faster than 2-agent standard mode for complex features.
**Cost optimization**: claude-zai instance + Haiku model = maximum savings for codebase exploration.

**Scale guideline**:
- Simple features (Low complexity): 2-4 agents total
- Medium features: 4-6 agents total
- Complex features (High complexity): 6-10 agents total (max 10 concurrent)

### Basic Parallel Research

Launch both agents simultaneously for comprehensive research (codebase patterns + external docs):
```
Launch two Task agents in parallel:
1. research-codebase agent: "Find all payment-related files, models, and API patterns"
2. research-external agent: "Find Stripe API v2024 documentation and migration guide"
```

### Activation

Copy agents from `_examples/` to `.opencode/agents/` in your project:
```bash
cp .opencode/agents/_examples/research-*.md .opencode/agents/
```

Once activated, the `/planning` command automatically detects them and switches to Parallel Research Mode (5-10 agents) instead of Standard Research Mode (2 built-in agents).

---

## Code Review Agents

These agents demonstrate **parallel code review** using the Pattern A approach from `reference/subagents-guide.md`.

## What These Agents Do

Instead of one agent reviewing everything sequentially, these four agents work **in parallel** — each focusing on a specific aspect:

| Agent | Focus | What It Checks |
|-------|-------|----------------|
| **code-review-type-safety** | Type annotations & type checking | Missing types, incorrect types, type errors |
| **code-review-security** | Security vulnerabilities | SQL injection, XSS, exposed secrets, auth issues |
| **code-review-architecture** | Design patterns & conventions | Layer violations, DRY, YAGNI, naming, structure |
| **code-review-performance** | Performance & scalability | N+1 queries, inefficient algorithms, memory leaks |

## Multi-Instance Routing

These agents use **smart routing** based on criticality:

| Agent | Instance | Model | Why |
|-------|----------|-------|-----|
| **Type Safety** | `claude-zai` | Haiku | Pattern matching — type checks follow known rules |
| **Security** | `claude-zai` | Haiku | Pattern matching — OWASP checks, secret scanning patterns |
| **Architecture** | `claude-zai` | Haiku | Pattern matching — convention compliance, layer checks |
| **Performance** | `claude-zai` | Haiku | Pattern matching — N+1 detection, complexity analysis |

**Routing Philosophy**:
All review agents use Haiku + claude-zai. Code review is fundamentally pattern matching
against documented standards — Haiku benchmarks at 90%+ quality for this task type
(Qodo: 6.55/10 vs Sonnet 6.20/10). The cost savings are significant: 4 Haiku agents
cost ~40% of 1 Sonnet doing sequential review.

If you don't have multiple instances, remove the `instance:` lines and all agents will use your default.

## How to Use

### Option 1: Copy and Customize (Recommended)

1. Copy the agents you need from `_examples/` to `.opencode/agents/`:
   ```bash
   cp .opencode/agents/_examples/code-review-*.md .opencode/agents/
   ```

2. Customize for your project:
   - Update `Context Gathering` section to reference your project files
   - Add project-specific patterns to check
   - Adjust severity thresholds based on your standards
   - Modify output format if needed

3. Restart your OpenCode session to load the agents

4. Use with `/code-review` command (which will invoke them automatically)

### Option 2: Use As-Is for Testing

The examples work out-of-the-box but are generic. They'll read `AGENTS.md` and adapt to your project, but won't be as targeted as customized agents.

## Parallel Execution

When you run `/code-review`, all four agents launch simultaneously:

```text
Main Agent
  ├─> Type Safety Agent (reviews all files for type issues)
  ├─> Security Agent (reviews all files for vulnerabilities)
  ├─> Architecture Agent (reviews all files for pattern compliance)
  └─> Performance Agent (reviews all files for efficiency)
       ↓ (results return in parallel)
Main Agent combines findings into unified report
```

**Speed improvement**: 40-50% faster than sequential review (same as `/planning` parallel research).

## When NOT to Use All Four

You don't always need all four agents. Pick based on your feature:

| Feature Type | Agents to Use |
|--------------|---------------|
| **New API endpoint** | Security + Architecture + Performance |
| **Frontend component** | Type Safety + Architecture |
| **Database migration** | Security + Architecture + Performance |
| **Bug fix** | Type Safety + Security (usually sufficient) |
| **Documentation** | Skip parallel review, use basic `/code-review` |

To use only specific agents, modify the `/code-review` command to launch fewer agents.

## Output Format

Each agent returns structured findings:
- **Severity**: Critical / Major / Minor
- **Location**: file:line
- **Issue**: What's wrong
- **Evidence**: Code snippet
- **Fix**: How to resolve

The main agent combines all findings into a single report saved to `requests/code-reviews/{feature}-review.md`.

## Customization Ideas

### For Python Projects
- Add `mypy` or `pyright` integration to type-safety agent
- Add `bandit` security scanner integration to security agent
- Check for `pytest` coverage in architecture agent

### For TypeScript Projects
- Add `tsc --noEmit` to type-safety agent
- Check for `React` hook rules in architecture agent
- Add bundle size analysis to performance agent

### For API Projects
- Add OpenAPI/Swagger spec validation to architecture agent
- Add rate-limiting checks to security agent
- Add query plan analysis to performance agent

## Trust Progression

**Before using parallel agents**:
1. Use the basic `/code-review` command manually 3+ times
2. Verify it catches the issues you care about
3. Understand what good output looks like

**Before customizing agents**:
1. Run the example agents as-is on a few features
2. Note what they miss vs what's noise
3. Adjust based on your project's actual needs

**Before full automation**:
1. Use `/code-review` → `/code-review-fix` manually 5+ times
2. Verify fixes are correct and safe
3. Only then integrate into automated workflows (GitHub Actions, etc.)

Don't skip stages. Parallel agents are powerful but can generate a lot of noise if not tuned to your project.

## Integration with Commands

The updated `/code-review` command automatically uses these agents when they exist in `.opencode/agents/`.

You can also invoke them from other commands:
```markdown
Use the @code-review-security agent to check for vulnerabilities in the authentication module.
```

See `reference/command-design-overview.md` for command + agent integration patterns.

## Reference

- **Pattern source**: `reference/subagents-guide.md` lines 175-185 (Pattern A)
- **Agent design guide**: `templates/AGENT-TEMPLATE.md`
- **Full subagent docs**: `reference/subagents-guide.md`

---

## Utility Agents

These agents provide **workflow optimization** — validating plans before execution
and suggesting test cases for changed code.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **plan-validator** | Haiku | Read, Glob, Grep | Validates plan structure before /execute |
| **test-generator** | Haiku | Read, Glob, Grep | Suggests test cases from changed code |

### When to Use

- **plan-validator**: Before running `/execute` on a new plan. Catches missing sections,
  incomplete tasks, broken file references. Integrated as optional Step 1.25 in `/execute`.
- **test-generator**: After implementation, before or during `/code-review`. Identifies
  untested code paths and suggests structured test cases following project patterns.

### Usage Examples
```
Use the plan-validator agent to validate requests/my-feature-plan.md
```
```
Use the test-generator agent to suggest tests for the files changed in the last commit
```

### Multi-Instance Routing

| Agent | Instance | Model | Why |
|-------|----------|-------|-----|
| **plan-validator** | `claude-zai` | Haiku | Advisory — structural validation is pattern matching |
| **test-generator** | `claude-zai` | Haiku | Advisory — test suggestions follow existing patterns |

### Activation

Copy agents from `_examples/` to `.opencode/agents/` in your project:
```bash
cp .opencode/agents/_examples/plan-validator.md .opencode/agents/
cp .opencode/agents/_examples/test-generator.md .opencode/agents/
```

---

## Documentation Subagents

These agents handle **documentation creation** — generating technical and non-technical content following project standards.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **subagent-docwriter** | Sonnet | Read, Write, Edit, Glob, Grep | Technical documentation specialist |

### When to Use

- **subagent-docwriter** (Sonnet): After implementation to create documentation. Generates API docs, guides, architecture decisions, changelogs. Follows project doc standards discovered via ContextScout.

### Documentation Types

DocWriter creates structured documentation based on type:

| Doc Type | When Used | Output Location |
|----------|-----------|-----------------|
| API Reference | New/changed endpoints | `docs/api/` |
| User Guide | New features | `docs/guides/` |
| Architecture Decision | Major design choices | `docs/adr/` |
| Changelog | Any release | `CHANGELOG.md` |
| README | New modules | Module root |

### Model Assignment Rationale

| Agent | Model | Why |
|-------|-------|-----|
| DocWriter | Sonnet | Documentation synthesis requires higher quality reasoning |

### Usage Example

```
Use the @subagent-docwriter agent to create API documentation for the payment processing module
```

### Integration Pattern

DocWriter is typically called after implementation:

```text
1. CoderAgent implements feature
2. BuildAgent validates build
3. TestEngineer writes tests
4. DocWriter creates documentation
5. Core agent commits all changes
```

---

## Domain Specialist Agents

These agents provide **domain expertise** — deep knowledge for specific technology areas. They are advisory agents that analyze, recommend, and can implement within their domain.

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **specialist-frontend** | Sonnet | Read, Write, Edit, Glob, Grep, Bash | Frontend architecture, React/Vue/Angular, CSS, accessibility |
| **specialist-backend** | Sonnet | Read, Write, Edit, Glob, Grep, Bash | API design, database patterns, system architecture |
| **specialist-devops** | Sonnet | Read, Write, Edit, Glob, Grep, Bash | CI/CD, infrastructure, Docker, Kubernetes, monitoring |
| **specialist-data** | Sonnet | Read, Write, Edit, Glob, Grep, Bash | Database design, ETL, analytics, data modeling |
| **specialist-copywriter** | Haiku | Read, Write, Edit, Glob, Grep | UI copy, microcopy, error messages, user-facing text |
| **specialist-technical-writer** | Haiku | Read, Write, Edit, Glob, Grep | Technical documentation, API docs, developer guides |

### When to Use

- **specialist-frontend**: React/Vue/Angular architecture, component design, CSS systems, accessibility audits, bundle optimization
- **specialist-backend**: API design reviews, database schema design, authentication patterns, performance optimization
- **specialist-devops**: CI/CD pipeline setup, Docker/Kubernetes configs, monitoring dashboards, infrastructure as code
- **specialist-data**: Schema migrations, query optimization, ETL pipelines, data warehouse design
- **specialist-copywriter**: UI text, error messages, onboarding copy, microcopy consistency
- **specialist-technical-writer**: API documentation, developer guides, architecture docs, migration guides

### Decision Matrix

| Task Type | Primary Specialist | Supporting |
|-----------|-------------------|------------|
| New React component library | frontend | - |
| REST API redesign | backend | frontend (consumer perspective) |
| Database migration | data | backend |
| Kubernetes deployment | devops | backend |
| User onboarding flow | copywriter | frontend |
| API documentation | technical-writer | backend |

### Model Assignment Rationale

| Agent | Model | Why |
|-------|-------|-----|
| frontend | Sonnet | Architecture decisions require synthesis |
| backend | Sonnet | System design requires higher reasoning |
| devops | Sonnet | Infrastructure decisions are complex |
| data | Sonnet | Data modeling requires deep analysis |
| copywriter | Haiku | Text follows established patterns |
| technical-writer | Haiku | Docs follow project conventions |

### Usage Examples

```
Use the @specialist-frontend agent to review the component architecture and suggest improvements
```
```
Use the @specialist-backend agent to design the authentication system following OAuth2 best practices
```
```
Use the @specialist-devops agent to set up GitHub Actions CI/CD pipeline
```

### Specialist vs Subagent Pattern

**Key distinction**:
- **Subagents** (CoderAgent, BuildAgent, etc.) are **workers** — they execute specific tasks
- **Specialists** are **advisors** — they bring domain expertise to analysis and implementation

Specialists CAN implement code within their domain, but their primary value is domain-specific knowledge and recommendations.

### Parallel Specialist Pattern

For cross-domain features, launch multiple specialists in parallel:

```text
Main Agent (Sonnet)
  |-> specialist-frontend --- "Analyze component architecture"
  |-> specialist-backend --- "Review API design"
  |-> specialist-data --- "Evaluate database schema"
       | (results return in parallel)
Main Agent combines domain perspectives into unified recommendation
```

---

## Complete Agent Inventory

### Summary by Category

| Category | Count | Agents |
|----------|-------|--------|
| Core Orchestrators | 2 | OpenAgent, OpenCoder |
| Discovery | 2 | ContextScout, ExternalScout |
| Task Management | 2 | TaskManager, BatchExecutor |
| Code Execution | 1 | CoderAgent |
| Quality Assurance | 2 | BuildAgent, TestEngineer |
| Documentation | 1 | DocWriter |
| Domain Specialists | 6 | frontend, backend, devops, data, copywriter, technical-writer |
| Research | 2 | research-codebase, research-external |
| Code Review | 4 | type-safety, security, architecture, performance |
| Utility | 2 | plan-validator, test-generator |
| **Total** | **24** | |

### Model Distribution

| Model | Count | Agents |
|-------|-------|--------|
| Sonnet | 11 | OpenAgent, OpenCoder, ExternalScout, TaskManager, BatchExecutor, CoderAgent, DocWriter, frontend, backend, devops, data |
| Haiku | 13 | ContextScout, BuildAgent, TestEngineer, copywriter, technical-writer, research-codebase, 4 code-review, plan-validator, test-generator |

### Agent Files Location

All agents live in `.opencode/agents/`:

```
.opencode/agents/
├── core-openagent.md          # Primary universal agent
├── core-opencoder.md          # Development orchestrator
├── subagent-contextscout.md   # Internal context discovery
├── subagent-externalscout.md  # External docs fetcher
├── subagent-taskmanager.md    # Archon task breakdown
├── subagent-batchexecutor.md  # Parallel execution coordinator
├── subagent-coderagent.md     # Atomic coding executor
├── subagent-buildagent.md     # Build validation runner
├── subagent-testengineer.md   # Test authoring specialist
├── subagent-docwriter.md      # Documentation specialist
├── specialist-frontend.md     # Frontend domain expert
├── specialist-backend.md      # Backend domain expert
├── specialist-devops.md       # DevOps domain expert
├── specialist-data.md         # Data domain expert
├── specialist-copywriter.md   # Copy/UX writing expert
├── specialist-technical-writer.md  # Technical docs expert
└── _examples/
    ├── README.md              # This file
    ├── research-codebase.md   # Codebase exploration
    ├── research-external.md   # External docs research
    ├── code-review-type-safety.md
    ├── code-review-security.md
    ├── code-review-architecture.md
    ├── code-review-performance.md
    ├── plan-validator.md
    └── test-generator.md
```

---

## Model Cost Comparison

| Agent Type | Count | Model | Approx. Cost per Run |
|-----------|-------|-------|---------------------|
| Core orchestrators | 2 | Sonnet | ~$0.60 total |
| Discovery (2 agents) | 2 | Haiku + Sonnet | ~$0.35 total |
| Task management (2 agents) | 2 | Sonnet | ~$0.60 total |
| Code execution (1 agent) | 1 | Sonnet | ~$0.30 total |
| QA (2 agents) | 2 | Haiku | ~$0.08 total |
| Documentation (1 agent) | 1 | Sonnet | ~$0.30 total |
| Domain specialists (6 agents) | 6 | 4 Sonnet + 2 Haiku | ~$1.28 total |
| Code review (4 agents parallel) | 4 | Haiku | ~$0.16 total |
| Research (2 agents parallel) | 2 | Haiku + Sonnet | ~$0.44 total |
| Utility (2 agents) | 2 | Haiku | ~$0.08 total |
| **Total (all 24)** | **24** | **11 Sonnet + 13 Haiku** | **~$4.19** |
