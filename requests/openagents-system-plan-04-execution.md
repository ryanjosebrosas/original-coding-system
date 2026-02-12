# Sub-Plan 04: Code Execution & QA

> **Parent Plan**: `requests/openagents-system-plan-overview.md`
> **Sub-Plan**: 04 of 5
> **Phase**: Code Execution & QA
> **Tasks**: 6
> **Estimated Context Load**: Low

---

## Scope

This sub-plan implements **code execution and quality assurance subagents** — agents that do the actual coding work and validate the results.

**What this sub-plan delivers**:
- `subagent-coderagent.md` — Atomic coding task executor
- `subagent-buildagent.md` — Build and validation runner
- `subagent-testengineer.md` — Test authoring specialist

**Prerequisites from previous sub-plans**:
- Sub-plan 01: Core orchestrators (delegate to these agents)
- Sub-plan 02: Discovery agents (CoderAgent uses ContextScout patterns)
- Sub-plan 03: Task management (BatchExecutor delegates to CoderAgent)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `templates/AGENT-TEMPLATE.md` (lines 115-170) — Why: Agent design framework
- `reference/implementation-discipline.md` — Why: Implementation rules these agents must follow
- `reference/validation-strategy.md` — Why: Validation approach for BuildAgent and TestEngineer
- `.opencode/agents/_examples/code-review-*.md` — Why: Existing QA agent patterns (if they exist in _examples/)

### Files Created by Previous Sub-Plans

- `.opencode/agents/subagent-batchexecutor.md` — Delegates to CoderAgent
- `.opencode/agents/subagent-contextscout.md` — CoderAgent should use this pattern
- `.tmp/sessions/SESSION-CONTEXT-TEMPLATE.md` — Context file format CoderAgent reads

---

## STEP-BY-STEP TASKS

### Task 1: CREATE `.opencode/agents/subagent-coderagent.md`

- **IMPLEMENT**: Atomic coding task executor:
  - Frontmatter: name `subagent-coderagent`, description for executing individual coding subtasks, model `sonnet`, tools `["Read", "Write", "Edit", "Glob", "Grep", "Bash"]`
  - Role: Focused code implementation specialist for atomic, single-task execution
  
  - **When to Use**:
    - Delegated by BatchExecutor for parallel task execution
    - Delegated by OpenCoder for simple direct implementation
    - Single file or tightly coupled 2-3 file changes
  
  - **Workflow**:
    1. **Load context** from session file (`.tmp/sessions/{id}/context.md`)
    2. **Read standards** from context files listed in session
    3. **Understand task** from provided task description
    4. **Implement** following patterns and standards
    5. **Validate** — run task-specific validation command
    6. **Report** completion status
  
  - **Critical Rules** (from core agents):
    ```
    - Follow patterns from context files — do NOT invent new patterns
    - Validate after each file change
    - STOP on errors — do NOT auto-fix, report to calling agent
    - Keep changes atomic — one logical change per task
    ```
  
  - **Output Format**:
    ```markdown
    ## Task Completion Report
    
    **Task**: {task description}
    **Status**: {Completed | Failed}
    
    ### Changes Made
    - `path/to/file` — {what changed}
    
    ### Validation Results
    - {validation command}: {pass/fail}
    
    ### Issues (if any)
    - {issue description and location}
    
    ### Notes for Calling Agent
    - {anything the calling agent needs to know}
    ```
  
  - **Constraints**:
    - Do NOT make decisions outside task scope
    - Do NOT modify files not specified in task
    - Do NOT skip validation step

- **PATTERN**: Focused executor, not decision maker

- **IMPORTS**: N/A

- **GOTCHA**: 
  - CoderAgent is a WORKER, not an orchestrator — it follows instructions
  - Use Sonnet model — code quality matters
  - Must read session context file before implementing

- **VALIDATE**: `ls -la .opencode/agents/subagent-coderagent.md && grep "session" .opencode/agents/subagent-coderagent.md`

---

### Task 2: CREATE `.opencode/agents/subagent-buildagent.md`

- **IMPLEMENT**: Build and validation runner:
  - Frontmatter: name `subagent-buildagent`, description for running builds and validation commands, model `haiku`, tools `["Read", "Bash", "Glob"]`
  - Role: Build validation specialist that runs type checking, linting, and build commands
  
  - **When to Use**:
    - After code implementation to verify build passes
    - Before committing to catch errors
    - As part of validation workflow
  
  - **Workflow**:
    1. **Detect project type** from files (package.json, pyproject.toml, Cargo.toml, etc.)
    2. **Identify build commands** based on project type:
       | Project Type | Commands |
       |--------------|----------|
       | Node/TS | `npm run lint`, `npm run typecheck`, `npm run build` |
       | Python | `ruff check`, `mypy`, `pytest --collect-only` |
       | Rust | `cargo check`, `cargo clippy` |
       | Go | `go vet`, `go build` |
    3. **Run validation commands** in order
    4. **Parse output** for errors and warnings
    5. **Report results** with actionable details
  
  - **Output Format**:
    ```markdown
    ## Build Validation Report
    
    **Project Type**: {detected type}
    **Status**: {Pass | Fail}
    
    ### Commands Run
    | Command | Status | Time |
    |---------|--------|------|
    | {cmd} | Pass/Fail | {duration} |
    
    ### Errors (if any)
    ```
    {error output with file:line references}
    ```
    
    ### Warnings
    - {warning count} warnings found
    
    ### Recommendations
    - {what to fix and how}
    ```
  
  - **Constraints**:
    - Do NOT fix errors — only report them
    - Do NOT modify any files
    - Always report full error output for debugging

- **PATTERN**: Read-only validation runner

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Use Haiku model — this is command execution and parsing, not synthesis
  - Tools should NOT include Write or Edit — this agent is read-only
  - Must handle different project types gracefully

- **VALIDATE**: `ls -la .opencode/agents/subagent-buildagent.md && grep "tools:" .opencode/agents/subagent-buildagent.md`

---

### Task 3: CREATE `.opencode/agents/subagent-testengineer.md`

- **IMPLEMENT**: Test authoring specialist:
  - Frontmatter: name `subagent-testengineer`, description for writing comprehensive tests, model `haiku`, tools `["Read", "Write", "Edit", "Glob", "Grep", "Bash"]`
  - Role: Testing specialist that writes unit, integration, and edge case tests
  
  - **When to Use**:
    - After implementation to add test coverage
    - When user requests test authoring
    - As part of code review follow-up
  
  - **Workflow**:
    1. **Load context** from session file or inline prompt
    2. **Analyze code** to understand functionality
    3. **Identify test cases**:
       - Happy path (expected behavior)
       - Error cases (invalid inputs, edge conditions)
       - Boundary conditions (empty, null, max values)
    4. **Follow project test patterns**:
       - Detect testing framework (Jest, Pytest, Vitest, etc.)
       - Mirror existing test file structure
       - Use project's assertion patterns
    5. **Write tests** following Arrange-Act-Assert pattern
    6. **Run tests** to verify they pass
  
  - **Output Format**:
    ```markdown
    ## Test Engineering Report
    
    **Module Tested**: {file/component}
    **Tests Written**: {N}
    
    ### Test Cases
    | Test | Type | Description |
    |------|------|-------------|
    | {name} | Unit/Integration | {what it tests} |
    
    ### Coverage Analysis
    - Functions covered: {list}
    - Edge cases covered: {list}
    - Gaps: {what's not tested and why}
    
    ### Test Results
    - {N} tests passing
    - {M} tests failing (if any, with details)
    
    ### Files Created/Modified
    - `path/to/test.ts` — {N} tests added
    ```
  
  - **Test Writing Standards**:
    ```
    - One assertion per test (when practical)
    - Descriptive test names: "should {expected behavior} when {condition}"
    - Mock external dependencies
    - Use fixtures for complex test data
    ```

- **PATTERN**: TDD-oriented test specialist

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Use Haiku model — test writing follows patterns
  - Must detect and follow existing test conventions
  - Include test execution to verify tests pass

- **VALIDATE**: `ls -la .opencode/agents/subagent-testengineer.md && grep "Arrange-Act-Assert" .opencode/agents/subagent-testengineer.md`

---

### Task 4: UPDATE `.opencode/agents/_examples/README.md`

- **IMPLEMENT**: Add "Code Execution Subagents" and "Quality Assurance Subagents" sections:
  - Document CoderAgent, BuildAgent, TestEngineer
  - Explain execution flow:
    ```
    OpenCoder → TaskManager → BatchExecutor → CoderAgent (parallel)
                                           → BuildAgent (validation)
                                           → TestEngineer (tests)
    ```
  - Include model assignment rationale:
    | Agent | Model | Why |
    |-------|-------|-----|
    | CoderAgent | Sonnet | Code quality requires higher capability |
    | BuildAgent | Haiku | Command execution is pattern matching |
    | TestEngineer | Haiku | Test writing follows existing patterns |
  - Note integration with existing code-review-* agents

- **PATTERN**: Follow existing README structure

- **IMPORTS**: N/A

- **GOTCHA**: Place after "Task Management Subagents" section

- **VALIDATE**: `grep -A 10 "Code Execution" .opencode/agents/_examples/README.md`

---

### Task 5: UPDATE `reference/subagents-overview.md`

- **IMPLEMENT**: Add execution and QA agents to documentation:
  - Add CoderAgent, BuildAgent, TestEngineer to agent tables
  - Note distinction from existing code-review agents:
    ```
    Code Review Agents: READ-ONLY analysis of existing code
    Execution Agents: WRITE code and tests
    
    Code review agents (existing): Analyze code quality issues
    TestEngineer (new): Writes tests to cover code
    BuildAgent (new): Runs build/lint/typecheck validation
    CoderAgent (new): Implements atomic coding tasks
    ```

- **PATTERN**: Follow existing documentation style

- **IMPORTS**: N/A

- **GOTCHA**: Clarify relationship to existing code-review agents

- **VALIDATE**: `grep -E "(CoderAgent|BuildAgent|TestEngineer)" reference/subagents-overview.md`

---

### Task 6: VERIFY existing code-review agents compatibility

- **IMPLEMENT**: Check that existing code-review-* agents in `_examples/` are compatible with new system:
  - Read each code-review agent file
  - Verify they follow AGENT-TEMPLATE.md framework
  - Verify output format includes severity levels and file:line references
  - Note any adjustments needed (but don't modify — just document)
  - Add compatibility notes to README if needed

- **PATTERN**: Audit and document, not modify

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Do NOT modify existing agents — they're already tuned
  - Just verify they work with the new orchestration flow
  - Document any integration notes

- **VALIDATE**: `ls .opencode/agents/_examples/code-review-*.md 2>/dev/null || echo "No code-review agents in _examples/"`

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify agents exist
ls -la .opencode/agents/subagent-coderagent.md
ls -la .opencode/agents/subagent-buildagent.md
ls -la .opencode/agents/subagent-testengineer.md
```

### Content Verification
```bash
# Verify CoderAgent reads session context
grep -E "(session|context)" .opencode/agents/subagent-coderagent.md

# Verify BuildAgent is read-only (no Write/Edit tools)
grep "tools:" .opencode/agents/subagent-buildagent.md | grep -v "Write\|Edit"

# Verify TestEngineer has write access
grep "tools:" .opencode/agents/subagent-testengineer.md | grep "Write"
```

### Cross-Reference Check
```bash
# Verify BatchExecutor can delegate to CoderAgent
grep "CoderAgent" .opencode/agents/subagent-batchexecutor.md

# Verify core agents know about BuildAgent
grep "BuildAgent\|TestEngineer" .opencode/agents/core-opencoder.md
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
- `.opencode/agents/subagent-coderagent.md` — Atomic coding executor, reads session context
- `.opencode/agents/subagent-buildagent.md` — Read-only build validation runner
- `.opencode/agents/subagent-testengineer.md` — Test authoring specialist

### Files Modified
- `.opencode/agents/_examples/README.md` — Added "Code Execution" and "QA" sections
- `reference/subagents-overview.md` — Added CoderAgent, BuildAgent, TestEngineer references

### Patterns Established
- **Worker Pattern**: CoderAgent follows instructions, doesn't make decisions outside scope
- **Read-Only Validation Pattern**: BuildAgent runs commands but doesn't modify files
- **Test Writing Pattern**: TestEngineer detects framework and mirrors existing test conventions

### State for Next Sub-Plan
- Execution chain is complete: TaskManager → BatchExecutor → CoderAgent → BuildAgent
- Existing code-review-* agents remain unchanged — they complement TestEngineer
- Sub-plan 05 (Docs & Specialists) will create DocWriter and domain specialists
- All core workflow agents are now in place
