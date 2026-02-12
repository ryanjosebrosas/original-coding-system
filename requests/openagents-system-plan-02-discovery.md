# Sub-Plan 02: Discovery Subagents

> **Parent Plan**: `requests/openagents-system-plan-overview.md`
> **Sub-Plan**: 02 of 5
> **Phase**: Discovery Subagents
> **Tasks**: 5
> **Estimated Context Load**: Low

---

## Scope

This sub-plan implements **discovery subagents** — specialized agents that find relevant context before coding begins. These are the "secret weapons" for quality output.

**What this sub-plan delivers**:
- `subagent-contextscout.md` — Smart internal context discovery (sections/, reference/, templates/)
- `subagent-externalscout.md` — External documentation fetcher for libraries/frameworks
- Updated README with discovery agents section

**Prerequisites from previous sub-plans**:
- Sub-plan 01: Core orchestrators created (they reference these discovery agents)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `templates/AGENT-TEMPLATE.md` (lines 115-170) — Why: Starter template structure
- `.opencode/agents/_examples/research-codebase.md` — Why: Similar pattern for internal exploration (if exists, check _examples/)
- `reference/file-structure.md` — Why: Understanding where context files live
- `AGENTS.md` (lines 37-54) — Why: On-demand guides list that ContextScout should know

### Files Created by Previous Sub-Plans

- `.opencode/agents/core-openagent.md` — References ContextScout in workflow
- `.opencode/agents/core-opencoder.md` — References both ContextScout and ExternalScout

---

## STEP-BY-STEP TASKS

### Task 1: CREATE `.opencode/agents/subagent-contextscout.md`

- **IMPLEMENT**: Internal context discovery agent with:
  - Frontmatter: name `subagent-contextscout`, description for finding relevant internal context files, model `haiku`, tools `["Read", "Glob", "Grep"]`
  - Role: Context discovery specialist that finds relevant patterns, standards, and guides BEFORE coding
  - Core mission: Discover and return paths to relevant context files from sections/, reference/, templates/
  
  - **Context Mapping** (hardcoded knowledge):
    ```
    sections/           → Core rules (auto-loaded, always relevant)
    reference/          → Deep guides (load on-demand based on task type)
    templates/          → Reusable templates for structured outputs
    memory.md           → Past decisions and lessons learned
    ```
  
  - **Task-to-Context Routing**:
    | Task Type | Context Files to Return |
    |-----------|------------------------|
    | Code implementation | reference/implementation-discipline.md, templates/STRUCTURED-PLAN-TEMPLATE.md |
    | Planning | reference/planning-methodology-guide.md, templates/VIBE-PLANNING-GUIDE.md |
    | Validation | reference/validation-strategy.md, templates/VALIDATION-PROMPT.md |
    | Subagent creation | templates/AGENT-TEMPLATE.md, reference/subagents-guide.md |
    | GitHub/CI | reference/github-integration.md, templates/GITHUB-SETUP-CHECKLIST.md |
    | Git worktrees | reference/git-worktrees-overview.md |
  
  - **Approach**:
    1. Parse the task description for keywords
    2. Map keywords to relevant context directories
    3. Glob for matching files
    4. Read file headers to confirm relevance
    5. Return ranked list of context file paths with relevance scores
  
  - **Output Format**:
    ```markdown
    ## Context Discovery Results
    
    **Task**: {parsed task description}
    **Keywords identified**: {list}
    
    ### Critical Context (load immediately)
    - `path/to/file` — {why relevant}
    
    ### Supporting Context (load if needed)
    - `path/to/file` — {why relevant}
    
    ### Memories (from memory.md)
    - {relevant memory entry} — {why it matters}
    ```
  
  - Include instruction: "Return paths only — do NOT read full file contents"

- **PATTERN**: Similar to OAC's ContextScout but adapted for our file structure

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Use Haiku model — this is pattern matching, not synthesis
  - Return PATHS, not contents — the calling agent reads the files
  - Include memory.md in discovery scope

- **VALIDATE**: `ls -la .opencode/agents/subagent-contextscout.md && grep "sections/" .opencode/agents/subagent-contextscout.md`

---

### Task 2: CREATE `.opencode/agents/subagent-externalscout.md`

- **IMPLEMENT**: External documentation fetcher with:
  - Frontmatter: name `subagent-externalscout`, description for fetching current library/framework docs, model `sonnet`, tools `["Read", "WebFetch", "WebSearch"]`
  - Role: External documentation specialist that fetches CURRENT docs for libraries and frameworks
  
  - **Why This Matters** (include in agent prompt):
    ```
    AI training data is OUTDATED for external libraries.
    Example: Next.js 13 uses pages/ directory, but Next.js 15 uses app/ directory
    Using outdated training data = broken code
    Using ExternalScout = working code with current APIs
    ```
  
  - **Trigger Conditions** (when to use this agent):
    - User mentions library/framework by name
    - package.json/requirements.txt contains unfamiliar dependencies
    - Build errors mention external packages
    - Working with external APIs
  
  - **Approach**:
    1. Identify the library/framework and version (if specified)
    2. Construct search queries for official documentation
    3. Fetch current documentation from:
       - Official docs sites (docs.*.com, *.readthedocs.io)
       - GitHub README and wiki
       - npm/PyPI package pages
    4. Extract relevant sections based on task context
    5. Summarize key information (installation, setup, API usage, gotchas)
  
  - **Output Format**:
    ```markdown
    ## External Documentation: {Library Name}
    
    **Version**: {detected or latest}
    **Source**: {URL}
    
    ### Installation
    {current installation steps}
    
    ### Setup Requirements
    {environment variables, prerequisites}
    
    ### Relevant API
    {specific APIs/methods for the task}
    
    ### Gotchas
    {common issues, breaking changes from previous versions}
    ```
  
  - Include instruction: "Always include source URLs for verification"

- **PATTERN**: Similar to OAC's ExternalScout

- **IMPORTS**: N/A

- **GOTCHA**: 
  - Use Sonnet model — synthesis and summarization requires higher quality
  - WebFetch may fail on some sites — include fallback to WebSearch
  - Always cite sources so user can verify

- **VALIDATE**: `ls -la .opencode/agents/subagent-externalscout.md && grep "WebFetch" .opencode/agents/subagent-externalscout.md`

---

### Task 3: CREATE test file `.tmp/test-contextscout.md`

- **IMPLEMENT**: Create a test prompt to verify ContextScout works:
  ```markdown
  # ContextScout Test
  
  Use the @subagent-contextscout agent to find relevant context for:
  "I need to create a new slash command for code optimization"
  
  Expected results should include:
  - templates/COMMAND-TEMPLATE.md
  - reference/command-design-overview.md
  - Possibly memory.md entries about commands
  ```

- **PATTERN**: Simple test file pattern

- **IMPORTS**: N/A

- **GOTCHA**: This is a manual test file, not automated testing

- **VALIDATE**: `cat .tmp/test-contextscout.md`

---

### Task 4: UPDATE `.opencode/agents/_examples/README.md`

- **IMPLEMENT**: Add "Discovery Subagents" section:
  - Document `subagent-contextscout.md` and `subagent-externalscout.md`
  - Explain when to use each:
    - ContextScout: Before ANY coding task — finds internal patterns and standards
    - ExternalScout: When working with external libraries — gets current docs
  - Include the decision matrix:
    | Scenario | ContextScout | ExternalScout | Both |
    |----------|--------------|---------------|------|
    | Project coding standards | Yes | No | - |
    | External library setup | No | Yes | - |
    | Feature with external lib | Yes (standards) | Yes (lib docs) | Yes |
  - Note: These are SUBAGENTS (called by core agents), not primary entry points

- **PATTERN**: Follow existing README table format

- **IMPORTS**: N/A

- **GOTCHA**: Place after "Core Orchestrator Agents" section added in sub-plan 01

- **VALIDATE**: `grep -A 15 "Discovery Subagents" .opencode/agents/_examples/README.md`

---

### Task 5: UPDATE `reference/subagents-overview.md`

- **IMPLEMENT**: Add discovery agents to documentation:
  - Add ContextScout and ExternalScout to the agent tables
  - Add note about "Context Discovery Pattern":
    ```
    Before any coding task, the recommended pattern is:
    1. ContextScout discovers internal patterns (sections/, reference/, templates/)
    2. ExternalScout fetches current docs for external dependencies
    3. Core agent loads discovered context
    4. Implementation proceeds with full context
    ```
  - Update "When to Use Subagents" table to include discovery use case

- **PATTERN**: Follow existing documentation style

- **IMPORTS**: N/A

- **GOTCHA**: Keep additions concise — this is a reference update

- **VALIDATE**: `grep -E "(ContextScout|ExternalScout)" reference/subagents-overview.md`

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify agents exist and have frontmatter
ls -la .opencode/agents/subagent-context*.md .opencode/agents/subagent-external*.md
head -10 .opencode/agents/subagent-contextscout.md
head -10 .opencode/agents/subagent-externalscout.md
```

### Content Verification
```bash
# Verify ContextScout knows about our file structure
grep -E "(sections/|reference/|templates/|memory.md)" .opencode/agents/subagent-contextscout.md

# Verify ExternalScout has web tools
grep -E "(WebFetch|WebSearch)" .opencode/agents/subagent-externalscout.md

# Verify correct models assigned
grep "model: haiku" .opencode/agents/subagent-contextscout.md
grep "model: sonnet" .opencode/agents/subagent-externalscout.md
```

### Cross-Reference Check
```bash
# Verify README documents both agents
grep -c "contextscout\|externalscout" .opencode/agents/_examples/README.md

# Verify core agents can reference these
grep "ContextScout" .opencode/agents/core-openagent.md
grep "ExternalScout" .opencode/agents/core-opencoder.md
```

---

## SUB-PLAN CHECKLIST

- [ ] All 5 tasks completed in order
- [ ] Each task validation passed
- [ ] All validation commands executed successfully
- [ ] No broken references to other files

---

## HANDOFF NOTES

### Files Created
- `.opencode/agents/subagent-contextscout.md` — Internal context discovery, knows sections/reference/templates structure
- `.opencode/agents/subagent-externalscout.md` — External docs fetcher with WebFetch/WebSearch
- `.tmp/test-contextscout.md` — Manual test file for verifying ContextScout

### Files Modified
- `.opencode/agents/_examples/README.md` — Added "Discovery Subagents" section
- `reference/subagents-overview.md` — Added ContextScout and ExternalScout references

### Patterns Established
- **Context Discovery Pattern**: ContextScout → ExternalScout → Load context → Implement
- **Task-to-Context Routing**: Mapping task types to relevant context files
- **Model Assignment**: Haiku for pattern matching (ContextScout), Sonnet for synthesis (ExternalScout)

### State for Next Sub-Plan
- Discovery agents are ready — core agents can now use them
- Sub-plan 03 (Task Management) will create TaskManager that coordinates with these discovery agents
- TaskManager should call ContextScout as first step before breaking down tasks
