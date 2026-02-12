# Sub-Plan 03: Task Management

> **Parent Plan**: `requests/openagents-system-plan-overview.md`
> **Sub-Plan**: 03 of 5
> **Phase**: Task Management
> **Tasks**: 6
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan implements **task management subagents** — agents that break down complex features into trackable tasks and coordinate parallel execution via Archon integration.

**What this sub-plan delivers**:
- `subagent-taskmanager.md` — Task breakdown via Archon API
- `subagent-batchexecutor.md` — Parallel task execution coordinator
- Session context template for subagent handoffs

**Prerequisites from previous sub-plans**:
- Sub-plan 01: Core orchestrators (reference TaskManager in workflow)
- Sub-plan 02: Discovery agents (TaskManager uses ContextScout)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `templates/AGENT-TEMPLATE.md` (lines 115-170) — Why: Agent design framework
- `reference/archon-workflow.md` — Why: **CRITICAL** — Archon MCP tool usage patterns
- `sections/15_archon_workflow.md` — Why: Archon integration rules (only ONE task in "doing" status)
- `.opencode/agents/core-opencoder.md` — Why: Understand how OpenCoder delegates to TaskManager

### Files Created by Previous Sub-Plans

- `.opencode/agents/core-opencoder.md` — References TaskManager and BatchExecutor
- `.opencode/agents/subagent-contextscout.md` — TaskManager should use this first
- `.tmp/sessions/.gitkeep` — Session directory ready for context files

---

## STEP-BY-STEP TASKS

### Task 1: READ `reference/archon-workflow.md`

- **IMPLEMENT**: Before creating TaskManager, read the full Archon workflow guide to understand:
  - Available MCP tools: `task_create`, `task_update`, `task_list`, `task_get`, `task_delete`
  - Task status values: `todo`, `doing`, `done`, `blocked`
  - Priority levels: `low`, `medium`, `high`, `critical`
  - The ONE task in "doing" rule
  - RAG search capabilities (if relevant for context discovery)

- **PATTERN**: Research before implementation

- **IMPORTS**: N/A

- **GOTCHA**: If Archon workflow guide doesn't exist or is incomplete, note what's missing for the agent to handle gracefully

- **VALIDATE**: `cat reference/archon-workflow.md | head -50` (or note if file doesn't exist)

---

### Task 2: CREATE `.opencode/agents/subagent-taskmanager.md`

- **IMPLEMENT**: Task breakdown agent with Archon integration:
  - Frontmatter: name `subagent-taskmanager`, description for breaking down complex features into Archon tasks, model `sonnet`, tools `["Read", "Glob", "Grep", "Bash"]` (Bash for Archon MCP if needed)
  - Role: Task breakdown specialist that creates dependency-aware tasks in Archon
  
  - **When to Use** (include in agent):
    - Complex features requiring 4+ files
    - Multi-step implementations with dependencies
    - Features estimated at >60 minutes
    - User explicitly requests task planning
  
  - **Workflow**:
    1. **Receive context** from calling agent (via session context file or inline)
    2. **Call ContextScout** to discover relevant patterns and standards
    3. **Analyze feature** for components, dependencies, and complexity
    4. **Create tasks in Archon**:
       ```
       For each task:
       - task_create(title="...", description="...", status="todo", priority="...")
       - Track task_id for dependency management
       ```
    5. **Identify parallel tasks** — tasks with no inter-dependencies
    6. **Return task breakdown** to calling agent
  
  - **Output Format**:
    ```markdown
    ## Task Breakdown: {Feature Name}
    
    **Total Tasks**: {N}
    **Parallel Batches**: {M}
    
    ### Batch 1 (Parallel)
    | Task ID | Title | Priority | Dependencies |
    |---------|-------|----------|--------------|
    | {id} | {title} | {priority} | None |
    
    ### Batch 2 (Sequential)
    | Task ID | Title | Priority | Dependencies |
    |---------|-------|----------|--------------|
    | {id} | {title} | {priority} | Batch 1 |
    
    ### Execution Order
    1. Execute Batch 1 tasks in parallel
    2. Wait for Batch 1 completion
    3. Execute Batch 2 tasks
    ...
    
    ### Context Files Discovered
    - {path} — {relevance}
    ```
  
  - **Archon Integration Rules** (include prominently):
    ```
    CRITICAL: Only ONE task can be in "doing" status at a time.
    When starting a task: task_update(task_id, status="doing")
    When completing: task_update(task_id, status="done")
    Check current: task_list(status="doing") — must return 0 or 1 task
    ```
  
  - **Fallback** (if Archon unavailable):
    ```
    If Archon MCP tools unavailable:
    1. Create manual task list in session context file
    2. Use .tmp/tasks/{feature}/ directory structure
    3. Inform calling agent to track tasks manually
    ```

- **PATTERN**: Adapt OAC's TaskManager for Archon

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Archon MCP tool names may differ — verify actual names from reference/archon-workflow.md
  - Include fallback for when Archon is unavailable
  - Use Sonnet model — task breakdown requires judgment

- **VALIDATE**: `ls -la .opencode/agents/subagent-taskmanager.md && grep -E "(task_create|Archon)" .opencode/agents/subagent-taskmanager.md`

---

### Task 3: CREATE `.opencode/agents/subagent-batchexecutor.md`

- **IMPLEMENT**: Parallel execution coordinator:
  - Frontmatter: name `subagent-batchexecutor`, description for coordinating parallel task execution, model `sonnet`, tools `["Read", "Glob", "Bash"]`
  - Role: Parallel execution specialist that manages multiple CoderAgent delegations
  
  - **When to Use**:
    - Batch has 5+ parallel tasks (for 1-4 tasks, direct delegation is simpler)
    - Complex error handling needed across parallel tasks
    - Explicit coordination required between parallel workers
  
  - **Workflow**:
    1. **Receive batch** from calling agent (list of task IDs or task details)
    2. **Verify parallel safety** — no inter-dependencies within batch
    3. **Update Archon** — mark batch tasks as "doing" (one at a time per Archon rules, or batch update if supported)
    4. **Delegate to CoderAgents** — launch parallel delegations:
       ```
       For each task in batch:
         task(subagent_type="CoderAgent", 
              description="Execute {task_title}",
              prompt="Session context: .tmp/sessions/{id}/context.md
                      Task: {task_details}
                      Standards: {context_files}")
       ```
    5. **Monitor completion** — wait for all CoderAgents to return
    6. **Update Archon** — mark completed tasks as "done"
    7. **Report results** — return batch completion status
  
  - **Output Format**:
    ```markdown
    ## Batch Execution Report
    
    **Batch**: {batch_number}
    **Tasks**: {N}
    **Status**: {Completed | Partial | Failed}
    
    ### Results
    | Task ID | Title | Status | Notes |
    |---------|-------|--------|-------|
    | {id} | {title} | Completed | {summary} |
    | {id} | {title} | Failed | {error} |
    
    ### Next Steps
    - {what calling agent should do next}
    ```
  
  - **Error Handling**:
    - If any task fails: STOP, report error, do NOT continue batch
    - Partial completion: report which tasks succeeded vs failed
    - Calling agent decides whether to retry or abort

- **PATTERN**: Adapt OAC's BatchExecutor

- **IMPORTS**: N/A

- **GOTCHA**: 
  - BatchExecutor coordinates but doesn't implement — CoderAgent does the work
  - Respect Archon's one-task-doing rule (may need sequential status updates)
  - Include clear handoff to calling agent

- **VALIDATE**: `ls -la .opencode/agents/subagent-batchexecutor.md && grep "CoderAgent" .opencode/agents/subagent-batchexecutor.md`

---

### Task 4: CREATE `.tmp/sessions/SESSION-CONTEXT-TEMPLATE.md`

- **IMPLEMENT**: Template for session context files:
  ```markdown
  # Task Context: {Task Name}
  
  Session ID: {YYYY-MM-DD}-{task-slug}
  Created: {ISO timestamp}
  Status: in_progress
  
  ## Current Request
  {What user asked for — verbatim or close paraphrase}
  
  ## Context Files (Standards to Follow)
  {Paths discovered by ContextScout — these are the standards}
  - {path} — {why relevant}
  
  ## Reference Files (Source Material)
  {Project files relevant to this task — NOT standards}
  - {path} — {what it contains}
  
  ## External Docs Fetched
  {Summary of what ExternalScout returned, if anything}
  
  ## Components
  {The functional units identified}
  
  ## Constraints
  {Technical constraints, preferences, compatibility notes}
  
  ## Archon Task IDs
  {Task IDs created for this feature}
  - {task_id}: {title} — {status}
  
  ## Exit Criteria
  - [ ] {specific completion condition}
  - [ ] {specific completion condition}
  ```

- **PATTERN**: Adapted from OAC's session context pattern

- **IMPORTS**: N/A

- **GOTCHA**: This is a TEMPLATE — actual session files are created at runtime with real values

- **VALIDATE**: `cat .tmp/sessions/SESSION-CONTEXT-TEMPLATE.md`

---

### Task 5: UPDATE `.opencode/agents/_examples/README.md`

- **IMPLEMENT**: Add "Task Management Subagents" section:
  - Document `subagent-taskmanager.md` and `subagent-batchexecutor.md`
  - Explain the Archon integration:
    ```
    TaskManager creates tasks in Archon, not JSON files.
    This provides real-time tracking and integrates with existing task workflow.
    ```
  - Include decision matrix:
    | Feature Complexity | Agent | Notes |
    |-------------------|-------|-------|
    | Simple (1-3 files) | Direct execution | Skip TaskManager |
    | Medium (4-6 files) | TaskManager | Creates Archon tasks |
    | Complex (7+ files) | TaskManager + BatchExecutor | Parallel batches |
  - Note Archon constraint: Only ONE task in "doing" status at a time

- **PATTERN**: Follow existing README structure

- **IMPORTS**: N/A

- **GOTCHA**: Place after "Discovery Subagents" section

- **VALIDATE**: `grep -A 15 "Task Management" .opencode/agents/_examples/README.md`

---

### Task 6: UPDATE `reference/subagents-overview.md`

- **IMPLEMENT**: Add task management agents to documentation:
  - Add TaskManager and BatchExecutor to agent tables
  - Add note about Archon integration:
    ```
    Task Management agents integrate with Archon MCP for real-time task tracking.
    See reference/archon-workflow.md for Archon tool usage.
    ```
  - Update "Parallel Execution" section to reference BatchExecutor

- **PATTERN**: Follow existing documentation style

- **IMPORTS**: N/A

- **GOTCHA**: Keep additions concise

- **VALIDATE**: `grep -E "(TaskManager|BatchExecutor)" reference/subagents-overview.md`

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify agents exist
ls -la .opencode/agents/subagent-taskmanager.md .opencode/agents/subagent-batchexecutor.md

# Verify session template exists
ls -la .tmp/sessions/SESSION-CONTEXT-TEMPLATE.md
```

### Content Verification
```bash
# Verify TaskManager has Archon integration
grep -E "(task_create|task_update|Archon)" .opencode/agents/subagent-taskmanager.md

# Verify BatchExecutor references CoderAgent
grep "CoderAgent" .opencode/agents/subagent-batchexecutor.md

# Verify TaskManager calls ContextScout
grep "ContextScout" .opencode/agents/subagent-taskmanager.md
```

### Cross-Reference Check
```bash
# Verify core agents can reference these
grep "TaskManager" .opencode/agents/core-opencoder.md
grep "BatchExecutor" .opencode/agents/core-opencoder.md
```

---

## SUB-PLAN CHECKLIST

- [ ] All 6 tasks completed in order
- [ ] Each task validation passed
- [ ] All validation commands executed successfully
- [ ] No broken references to other files

---

## HANDOFF NOTES

### Files Created
- `.opencode/agents/subagent-taskmanager.md` — Task breakdown with Archon integration, calls ContextScout
- `.opencode/agents/subagent-batchexecutor.md` — Parallel execution coordinator, delegates to CoderAgent
- `.tmp/sessions/SESSION-CONTEXT-TEMPLATE.md` — Template for session context files

### Files Modified
- `.opencode/agents/_examples/README.md` — Added "Task Management Subagents" section
- `reference/subagents-overview.md` — Added TaskManager and BatchExecutor references

### Patterns Established
- **Archon Task Pattern**: TaskManager creates/updates tasks via Archon MCP, respects one-task-doing rule
- **Session Context Pattern**: `.tmp/sessions/{id}/context.md` files persist context for subagent handoffs
- **Batch Execution Pattern**: BatchExecutor coordinates parallel CoderAgent delegations

### State for Next Sub-Plan
- TaskManager and BatchExecutor reference `CoderAgent` — must be created in sub-plan 04
- Session context template ready — CoderAgent will read these files
- Sub-plan 04 (Code Execution & QA) will create CoderAgent, BuildAgent, TestEngineer
