# Sub-Plan 05: Documentation & Specialists

> **Parent Plan**: `requests/openagents-system-plan-overview.md`
> **Sub-Plan**: 05 of 5
> **Phase**: Documentation & Specialists
> **Tasks**: 6
> **Estimated Context Load**: Low

---

## Scope

This sub-plan implements **documentation and domain specialist agents** — agents for documentation generation and specialized domain expertise.

**What this sub-plan delivers**:
- `subagent-docwriter.md` — Documentation generator
- `specialist-frontend.md` — Frontend development specialist
- `specialist-backend.md` — Backend/API development specialist
- `specialist-devops.md` — DevOps and infrastructure specialist
- `specialist-data.md` — Data engineering and analytics specialist
- `specialist-copywriter.md` — Marketing and content copy specialist
- `specialist-technical-writer.md` — Technical documentation specialist

**Prerequisites from previous sub-plans**:
- Sub-plans 01-04: Core workflow agents created

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `templates/AGENT-TEMPLATE.md` (lines 115-170) — Why: Agent design framework
- `.opencode/agents/_examples/README.md` — Why: Current agent documentation structure
- `reference/subagents-overview.md` — Why: Where to add specialist references

### Files Created by Previous Sub-Plans

- `.opencode/agents/core-opencoder.md` — May delegate to specialists
- `.opencode/agents/subagent-taskmanager.md` — May route tasks to specialists
- `.opencode/agents/_examples/README.md` — Will add specialist sections

---

## STEP-BY-STEP TASKS

### Task 1: CREATE `.opencode/agents/subagent-docwriter.md`

- **IMPLEMENT**: Documentation generator:
  - Frontmatter: name `subagent-docwriter`, description for generating comprehensive documentation, model `sonnet`, tools `["Read", "Write", "Edit", "Glob", "Grep"]`
  - Role: Documentation specialist that generates and updates project documentation
  
  - **When to Use**:
    - After feature implementation to document changes
    - When creating README files, API docs, or guides
    - When updating existing documentation
  
  - **Documentation Types**:
    | Type | Template | Output Location |
    |------|----------|-----------------|
    | Feature docs | Inline | `docs/` or `reference/` |
    | API reference | JSDoc/Docstring extraction | `docs/api/` |
    | README | `templates/README-TEMPLATE.md` (if exists) | Project root |
    | Changelog | Conventional commits format | `CHANGELOG.md` |
  
  - **Workflow**:
    1. **Analyze scope** — what needs documentation
    2. **Read existing docs** — understand current style and structure
    3. **Gather context** — read code, comments, commit history
    4. **Generate documentation** following project conventions
    5. **Validate** — check for broken links, completeness
  
  - **Output Format**:
    ```markdown
    ## Documentation Report
    
    **Scope**: {what was documented}
    **Files Created/Modified**: {list}
    
    ### Changes Summary
    - `path/to/doc.md` — {what was added/changed}
    
    ### Validation
    - Links checked: {pass/fail}
    - Sections complete: {checklist}
    
    ### Notes
    - {anything the calling agent needs to know}
    ```
  
  - **Standards**:
    - Keep docs concise and high-signal
    - Use existing project terminology
    - Include code examples where helpful
    - Maintain consistent formatting

- **PATTERN**: Documentation specialist following project conventions

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Use Sonnet model — documentation synthesis requires quality
  - Read existing docs before writing to match style
  - Do NOT create unnecessary documentation

- **VALIDATE**: `ls -la .opencode/agents/subagent-docwriter.md && grep "documentation" .opencode/agents/subagent-docwriter.md`

---

### Task 2: CREATE `.opencode/agents/specialist-frontend.md`

- **IMPLEMENT**: Frontend development specialist:
  - Frontmatter: name `specialist-frontend`, description for frontend development (React, Vue, Svelte, CSS), model `sonnet`, tools `["Read", "Write", "Edit", "Glob", "Grep", "Bash"]`
  - Role: Frontend specialist for UI components, styling, and client-side logic
  
  - **Expertise Areas**:
    - React/Vue/Svelte component development
    - CSS/Tailwind/styled-components
    - State management (Redux, Zustand, Pinia)
    - Accessibility (a11y) best practices
    - Responsive design
    - Performance optimization (bundle size, lazy loading)
  
  - **When to Delegate**:
    - UI component implementation
    - Styling and theming
    - Frontend state management
    - Client-side form handling
    - Animation and transitions
  
  - **Standards to Follow**:
    - Component composition over inheritance
    - Proper prop typing (TypeScript)
    - Semantic HTML
    - Mobile-first responsive design
    - Accessibility requirements (ARIA, keyboard nav)

- **PATTERN**: Domain specialist with focused expertise

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Must detect frontend framework from project files
  - Follow existing component patterns in codebase

- **VALIDATE**: `ls -la .opencode/agents/specialist-frontend.md && grep "React\|Vue\|component" .opencode/agents/specialist-frontend.md`

---

### Task 3: CREATE `.opencode/agents/specialist-backend.md`

- **IMPLEMENT**: Backend/API development specialist:
  - Frontmatter: name `specialist-backend`, description for backend development (APIs, databases, services), model `sonnet`, tools `["Read", "Write", "Edit", "Glob", "Grep", "Bash"]`
  - Role: Backend specialist for APIs, database operations, and server-side logic
  
  - **Expertise Areas**:
    - REST/GraphQL API design
    - Database operations (SQL, ORM)
    - Authentication and authorization
    - Input validation and sanitization
    - Error handling and logging
    - Performance optimization (caching, query optimization)
  
  - **When to Delegate**:
    - API endpoint implementation
    - Database schema and migrations
    - Service layer logic
    - Authentication flows
    - Background jobs and queues
  
  - **Standards to Follow**:
    - RESTful conventions
    - Proper error codes and messages
    - Input validation on all endpoints
    - Parameterized queries (SQL injection prevention)
    - Consistent response formats

- **PATTERN**: Domain specialist with focused expertise

- **IMPORTS**: N/A

- **GOTCHA**: Follow project's existing API patterns

- **VALIDATE**: `ls -la .opencode/agents/specialist-backend.md && grep "API\|database" .opencode/agents/specialist-backend.md`

---

### Task 4: CREATE specialist agents (DevOps, Data, Content)

- **IMPLEMENT**: Create three more specialist agents:

  **`specialist-devops.md`**:
  - Model: `sonnet`, Tools: `["Read", "Write", "Edit", "Glob", "Grep", "Bash"]`
  - Expertise: CI/CD pipelines, Docker, Kubernetes, infrastructure, monitoring
  - When to use: DevOps tasks, deployment configs, GitHub Actions
  
  **`specialist-data.md`**:
  - Model: `sonnet`, Tools: `["Read", "Write", "Edit", "Glob", "Grep", "Bash"]`
  - Expertise: Data pipelines, SQL queries, analytics, ETL, data visualization
  - When to use: Data engineering, database optimization, analytics features
  
  **`specialist-copywriter.md`**:
  - Model: `haiku`, Tools: `["Read", "Write", "Edit"]`
  - Expertise: Marketing copy, product descriptions, UI text, CTAs
  - When to use: Writing user-facing copy, marketing content, error messages
  
  **`specialist-technical-writer.md`**:
  - Model: `haiku`, Tools: `["Read", "Write", "Edit", "Glob"]`
  - Expertise: Technical documentation, tutorials, API guides, how-to articles
  - When to use: Writing technical docs that require domain expertise

- **PATTERN**: Domain specialists with focused roles

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Copywriter and technical-writer use Haiku — writing follows patterns
  - DevOps and Data use Sonnet — require synthesis and judgment

- **VALIDATE**: `ls -la .opencode/agents/specialist-*.md | wc -l` (should show 6)

---

### Task 5: UPDATE `.opencode/agents/_examples/README.md`

- **IMPLEMENT**: Add comprehensive documentation for all new agents:
  
  - Add "## Documentation Subagent" section for DocWriter
  - Add "## Domain Specialists" section with all 6 specialists:
    ```markdown
    ## Domain Specialists
    
    These agents provide specialized expertise for domain-specific tasks.
    They are delegated to by core agents when specialized knowledge is needed.
    
    | Agent | Model | Focus |
    |-------|-------|-------|
    | specialist-frontend | Sonnet | UI, React, CSS, accessibility |
    | specialist-backend | Sonnet | APIs, databases, services |
    | specialist-devops | Sonnet | CI/CD, Docker, infrastructure |
    | specialist-data | Sonnet | Data pipelines, SQL, analytics |
    | specialist-copywriter | Haiku | Marketing copy, UI text |
    | specialist-technical-writer | Haiku | Technical docs, tutorials |
    
    ### When to Use Specialists
    
    Specialists are delegated to when:
    - Task requires domain-specific expertise
    - Core agent identifies specialized knowledge needed
    - User explicitly requests specialist involvement
    
    Example delegation:
    ```
    Use the @specialist-frontend agent to implement the user dashboard component.
    ```
    ```
  
  - Add final "## Complete Agent Inventory" table summarizing all 21 agents

- **PATTERN**: Follow existing README structure

- **IMPORTS**: N/A

- **GOTCHA**: This is the final README update — make it comprehensive

- **VALIDATE**: `grep -c "specialist-" .opencode/agents/_examples/README.md` (should show 6+)

---

### Task 6: UPDATE `reference/subagents-overview.md` with final inventory

- **IMPLEMENT**: Final documentation update:
  - Add DocWriter and all specialists to agent tables
  - Add "Complete Agent Inventory" section at the end:
    ```markdown
    ### Complete Agent Inventory
    
    **Core Orchestrators (2)**:
    - OpenAgent — Universal entry point
    - OpenCoder — Development orchestrator
    
    **Discovery (2)**:
    - ContextScout — Internal context discovery
    - ExternalScout — External docs fetcher
    
    **Task Management (2)**:
    - TaskManager — Archon task breakdown
    - BatchExecutor — Parallel execution
    
    **Code Execution (2)**:
    - CoderAgent — Atomic task executor
    - BuildAgent — Build validation
    
    **Quality Assurance (5)**:
    - TestEngineer — Test authoring
    - code-review-type-safety (existing)
    - code-review-security (existing)
    - code-review-architecture (existing)
    - code-review-performance (existing)
    
    **Documentation (1)**:
    - DocWriter — Documentation generator
    
    **Research (2 existing)**:
    - research-codebase
    - research-external
    
    **Specialists (6)**:
    - specialist-frontend
    - specialist-backend
    - specialist-devops
    - specialist-data
    - specialist-copywriter
    - specialist-technical-writer
    
    **Total: 22 agents** (14 new + 8 existing)
    ```
  
  - Update "Model Cost Comparison" table with full agent costs

- **PATTERN**: Final documentation polish

- **IMPORTS**: N/A

- **GOTCHA**: Ensure count matches reality — verify all agents exist

- **VALIDATE**: `grep -E "specialist-|subagent-|core-" reference/subagents-overview.md | wc -l`

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Count all agents
ls .opencode/agents/*.md 2>/dev/null | wc -l
ls .opencode/agents/_examples/*.md 2>/dev/null | wc -l

# Verify specialist agents exist
ls -la .opencode/agents/specialist-*.md
ls -la .opencode/agents/subagent-docwriter.md
```

### Content Verification
```bash
# Verify specialists have correct model assignments
grep "model:" .opencode/agents/specialist-frontend.md
grep "model:" .opencode/agents/specialist-copywriter.md

# Verify DocWriter has documentation focus
grep -E "(documentation|README|docs)" .opencode/agents/subagent-docwriter.md
```

### Final Inventory Check
```bash
# Full agent inventory
echo "=== Core Agents ===" && ls .opencode/agents/core-*.md 2>/dev/null
echo "=== Subagents ===" && ls .opencode/agents/subagent-*.md 2>/dev/null
echo "=== Specialists ===" && ls .opencode/agents/specialist-*.md 2>/dev/null
echo "=== Examples (existing) ===" && ls .opencode/agents/_examples/*.md 2>/dev/null
```

---

## SUB-PLAN CHECKLIST

- [ ] All 6 tasks completed in order
- [ ] Each task validation passed
- [ ] All validation commands executed successfully
- [ ] No broken references to other files
- [ ] Final agent inventory matches expected count

---

## HANDOFF NOTES

### Files Created
- `.opencode/agents/subagent-docwriter.md` — Documentation generator
- `.opencode/agents/specialist-frontend.md` — Frontend specialist
- `.opencode/agents/specialist-backend.md` — Backend specialist
- `.opencode/agents/specialist-devops.md` — DevOps specialist
- `.opencode/agents/specialist-data.md` — Data engineering specialist
- `.opencode/agents/specialist-copywriter.md` — Marketing copy specialist
- `.opencode/agents/specialist-technical-writer.md` — Technical docs specialist

### Files Modified
- `.opencode/agents/_examples/README.md` — Added DocWriter, Specialists, and final inventory
- `reference/subagents-overview.md` — Added complete agent inventory

### Patterns Established
- **Specialist Pattern**: Domain experts with focused knowledge, delegated to by core agents
- **Model Assignment**: Sonnet for synthesis/judgment tasks, Haiku for pattern-following tasks
- **Documentation Pattern**: DocWriter reads existing docs before writing to match style

### Final State
- **22 total agents** (14 new + 8 existing):
  - 2 core orchestrators
  - 2 discovery subagents
  - 2 task management subagents
  - 2 code execution subagents
  - 5 QA agents (1 new + 4 existing)
  - 1 documentation agent
  - 2 research agents (existing)
  - 6 domain specialists

### Ready for Commit
All sub-plans complete. Run final validation from overview:
```bash
# Final verification
ls .opencode/agents/*.md | wc -l
cat reference/subagents-overview.md | grep "Total"
```

Then `/commit` with message: "feat: implement comprehensive OpenAgents system (22 agents)"
