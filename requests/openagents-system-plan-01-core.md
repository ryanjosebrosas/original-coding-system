# Sub-Plan 01: Core Orchestrators

> **Parent Plan**: `requests/openagents-system-plan-overview.md`
> **Sub-Plan**: 01 of 5
> **Phase**: Core Orchestrators
> **Tasks**: 5
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan implements **core orchestrator agents** — the primary entry points for the agent system. These agents enforce context-first execution, approval gates, and coordinate delegation to specialized subagents.

**What this sub-plan delivers**:
- `core-openagent.md` — Universal agent for questions, tasks, workflow coordination
- `core-opencoder.md` — Development orchestrator with staged workflow
- Updated `_examples/README.md` with new agent section

**Prerequisites from previous sub-plans**:
- None (first sub-plan)

---

## CONTEXT FOR THIS SUB-PLAN

> Only the files and docs relevant to THIS sub-plan's tasks.

### Files to Read Before Implementing

- `templates/AGENT-TEMPLATE.md` (lines 1-200) — Why: Agent design framework to follow
- `.opencode/agents/_examples/README.md` (lines 1-50) — Why: Existing agent documentation pattern
- `reference/subagents-overview.md` (lines 27-53) — Why: When to use subagents, parallel execution guidance
- `sections/02_piv_loop.md` (lines 1-39) — Why: PIV Loop methodology these agents must follow
- `sections/05_decision_framework.md` (lines 1-16) — Why: Autonomous vs ask-user decision rules

### Files Created by Previous Sub-Plans

> N/A — this is sub-plan 01.

---

## STEP-BY-STEP TASKS

### Task 1: CREATE `.opencode/agents/core-openagent.md`

- **IMPLEMENT**: Universal agent with:
  - Frontmatter: name `core-openagent`, description for universal tasks, model `sonnet`, tools `["*"]`
  - Role: Universal AI agent for questions, tasks, workflow coordination
  - Critical rules: approval_gate (request approval before bash/write/edit), stop_on_failure, report_first
  - Workflow stages: Analyze → Discover (use ContextScout) → Propose → Approve → Execute → Validate → Summarize
  - Execution paths: Conversational (no approval) vs Task (approval required)
  - Delegation rules: When to delegate to specialists (4+ files, specialized knowledge, complex tasks)
  - Available subagents list with invocation syntax
  - Constraints section enforcing context-first execution

- **PATTERN**: Follow OAC's OpenAgent structure but adapt for PIV Loop:
  - Reference `sections/` for standards instead of OAC's `.opencode/context/`
  - Reference Archon for task management instead of JSON files
  - Keep approval gates but allow Read/Glob/Grep without approval

- **IMPORTS**: N/A (markdown file)

- **GOTCHA**: 
  - Do NOT include OAC's `<xml>` tags — use markdown headers instead
  - Keep under 300 lines — reference files for deep context
  - Include "instruct main agent to NOT auto-fix" in output guidance

- **VALIDATE**: `ls -la .opencode/agents/core-openagent.md && head -20 .opencode/agents/core-openagent.md`

---

### Task 2: CREATE `.opencode/agents/core-opencoder.md`

- **IMPLEMENT**: Development orchestrator with:
  - Frontmatter: name `core-opencoder`, description for complex coding/architecture/refactoring, model `sonnet`, tools `["*"]`
  - Role: Orchestration agent for complex coding, architecture, and multi-file refactoring
  - Critical context requirement: MUST load standards before any code implementation
  - Critical rules: approval_gate, stop_on_failure, report_first, incremental_execution
  - 6-stage workflow:
    1. **Discover**: Use ContextScout to find relevant patterns
    2. **Propose**: Present plan summary for approval (NOT full plan doc)
    3. **Init Session**: Create `.tmp/sessions/{id}/context.md` for subagent handoffs
    4. **Plan**: Delegate to TaskManager for complex features, direct execute for simple
    5. **Execute**: Use Archon tasks, parallel batches via BatchExecutor
    6. **Validate & Handoff**: Run tests, suggest TestEngineer/CodeReviewer
  - Available subagents: ContextScout, ExternalScout, TaskManager, BatchExecutor, CoderAgent, TestEngineer, DocWriter
  - Delegation rules: Simple (1-3 files) = direct, Complex (4+ files) = TaskManager
  - Execution philosophy emphasizing Archon integration

- **PATTERN**: Adapt OAC's OpenCoder workflow for PIV Loop:
  - Stage 3 (Init Session) creates session context for subagent handoffs
  - Stage 4 (Plan) uses Archon via TaskManager, not JSON files
  - Stage 5 (Execute) coordinates with Archon task statuses

- **IMPORTS**: N/A (markdown file)

- **GOTCHA**:
  - The workflow references subagents that don't exist yet (created in later sub-plans)
  - Include fallback instructions: "If TaskManager unavailable, break down manually"
  - Keep under 350 lines — this is the most complex agent

- **VALIDATE**: `ls -la .opencode/agents/core-opencoder.md && wc -l .opencode/agents/core-opencoder.md`

---

### Task 3: CREATE `.tmp/sessions/.gitkeep`

- **IMPLEMENT**: Create the session directory structure for subagent context handoffs:
  - Create `.tmp/` directory if it doesn't exist
  - Create `.tmp/sessions/` directory
  - Add `.gitkeep` file to preserve directory in git
  - Add `.tmp/` to `.gitignore` if not already present

- **PATTERN**: Standard pattern for temporary directories that should exist but not be tracked

- **IMPORTS**: N/A

- **GOTCHA**: 
  - `.tmp/` should be gitignored (session files are temporary)
  - The `.gitkeep` file itself should be tracked so the directory structure exists

- **VALIDATE**: `ls -la .tmp/sessions/ && cat .gitignore | grep -E "^\.tmp"`

---

### Task 4: UPDATE `.opencode/agents/_examples/README.md`

- **IMPLEMENT**: Add new section documenting core orchestrator agents:
  - Add "## Core Orchestrator Agents" section after the intro
  - Document `core-openagent.md` and `core-opencoder.md`
  - Explain when to use each:
    - OpenAgent: General tasks, questions, simple implementations
    - OpenCoder: Complex features, multi-file refactoring, production development
  - Include invocation examples
  - Note that these are PRIMARY agents (always available), not examples to copy

- **PATTERN**: Follow existing README structure (table format, usage examples, multi-instance routing)

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Don't remove existing content — ADD new section
  - Core agents are different from example agents (always active vs copy-to-activate)

- **VALIDATE**: `grep -A 20 "Core Orchestrator" .opencode/agents/_examples/README.md`

---

### Task 5: UPDATE `reference/subagents-overview.md`

- **IMPLEMENT**: Add references to new core agents:
  - In "Built-in Agents" section, add OpenAgent and OpenCoder
  - Add note about staged workflow (Discover → Propose → Approve → Execute → Validate)
  - Reference the full agent files for detailed documentation
  - Update "Example Agents" section to clarify distinction (core agents always active, example agents copy-to-activate)

- **PATTERN**: Follow existing documentation style (tables, concise descriptions)

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Keep changes minimal — this is a reference update, not a rewrite
  - Don't duplicate agent content — just add pointers

- **VALIDATE**: `grep -E "(OpenAgent|OpenCoder)" reference/subagents-overview.md`

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify agents exist and have frontmatter
ls -la .opencode/agents/core-*.md
head -10 .opencode/agents/core-openagent.md
head -10 .opencode/agents/core-opencoder.md
```

### Content Verification
```bash
# Verify key sections exist in OpenAgent
grep -E "(approval_gate|ContextScout|Workflow|Delegation)" .opencode/agents/core-openagent.md

# Verify key sections exist in OpenCoder
grep -E "(approval_gate|TaskManager|Archon|Session)" .opencode/agents/core-opencoder.md

# Verify session directory exists
ls -la .tmp/sessions/
```

### Cross-Reference Check
```bash
# Verify README references new agents
grep -c "core-openagent" .opencode/agents/_examples/README.md
grep -c "core-opencoder" .opencode/agents/_examples/README.md

# Verify subagents-overview references new agents
grep -c "OpenAgent\|OpenCoder" reference/subagents-overview.md
```

---

## SUB-PLAN CHECKLIST

- [ ] All 5 tasks completed in order
- [ ] Each task validation passed
- [ ] All validation commands executed successfully
- [ ] No broken references to other files

---

## HANDOFF NOTES

> What the NEXT sub-plan needs to know about what was done here.

### Files Created
- `.opencode/agents/core-openagent.md` — Universal orchestrator, references ContextScout and other subagents
- `.opencode/agents/core-opencoder.md` — Development orchestrator, references TaskManager and Archon integration
- `.tmp/sessions/.gitkeep` — Session directory for subagent context handoffs

### Files Modified
- `.opencode/agents/_examples/README.md` — Added "Core Orchestrator Agents" section
- `reference/subagents-overview.md` — Added OpenAgent and OpenCoder references
- `.gitignore` — Added `.tmp/` if not present

### Patterns Established
- **Approval Gate Pattern**: All agents require approval before bash/write/edit (Read/Glob/Grep exempt)
- **Session Context Pattern**: Complex tasks create `.tmp/sessions/{id}/context.md` for subagent handoffs
- **Staged Workflow Pattern**: Discover → Propose → Approve → Execute → Validate (adapted from OAC)

### State for Next Sub-Plan
- Core agents reference `ContextScout` and `ExternalScout` — these must be created in sub-plan 02
- Core agents reference `TaskManager` and `BatchExecutor` — these must be created in sub-plan 03
- Core agents reference `CoderAgent`, `TestEngineer`, etc. — created in sub-plans 04-05
- The session directory `.tmp/sessions/` is ready for use by TaskManager
