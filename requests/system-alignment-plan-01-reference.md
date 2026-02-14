# Sub-Plan 01: Reference-Reality Alignment

> **Parent Plan**: `requests/system-alignment-plan-overview.md`
> **Sub-Plan**: 1 of 4
> **Phase**: Reference-Reality Alignment
> **Tasks**: 6
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan fixes discrepancies between `reference/` documentation and actual file structure.

**What this sub-plan delivers**:
- Accurate file-structure.md reflecting 23 commands, 16 agents, all templates
- Example agent files created in `_examples/` (or docs updated)
- memory.md counts updated to current reality
- All reference guides listing correct file counts

**Prerequisites from previous sub-plans**:
- None (first sub-plan)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `reference/file-structure.md` (full) — Contains outdated counts and missing entries
- `reference/subagents-overview.md` (lines 116, 169-191) — Agent count and example claims
- `memory.md` (lines 19, 53) — Outdated counts
- `.opencode/agents/_examples/README.md` — Lists example agents that should exist

### Audit Findings to Address

| File | Line | Issue | Fix |
|------|------|-------|-----|
| file-structure.md | 88-113 | Skills directory documented but doesn't exist | Remove or create |
| file-structure.md | 117-123 | 8 example agents documented, only README exists | Create agents |
| file-structure.md | 71-87 | 17 commands documented, 23 exist | Update list |
| file-structure.md | 13-40 | 4 reference files not listed | Add entries |
| file-structure.md | 51-67 | 2 templates not listed | Add entries |
| subagents-overview.md | 116 | "24 agents" claimed, 16 exist | Update count |
| memory.md | 19 | "12 commands" claimed, 23 exist | Update count |
| memory.md | 53 | "22 agents" claimed, 16 exist | Update count |

---

## STEP-BY-STEP TASKS

### UPDATE `reference/file-structure.md`

- **IMPLEMENT**: Update the entire file to reflect current reality:
  1. Lines 13-40: Add missing reference files: `tmux-integration.md`, `command-agent-mapping.md`, `agent-routing.md`, `handoff-protocol.md`
  2. Lines 41-49: Update GitHub workflow names to match actual files in `.github/workflows/` and `reference/github-workflows/`
  3. Lines 51-67: Add missing templates: `SESSION-CONTEXT-TEMPLATE.md`, `SKILL-TEMPLATE.md`
  4. Lines 71-87: Update command list to all 23 commands (add: tmux-worktrees, create-pr, activate-agents, claude-mcp, setup-github-automation, quick-github-setup)
  5. Lines 88-113: **DECISION**: Remove skills section since `.opencode/skills/` doesn't exist
  6. Lines 117-123: Update example agents list after Task 2 creates them
- **PATTERN**: Use existing list format in file-structure.md
- **IMPORTS**: N/A (markdown)
- **GOTCHA**: Verify each path actually exists before documenting
- **VALIDATE**: `grep -c "^\|.md\` reference/file-structure.md` should show correct counts

### CREATE `.opencode/agents/_examples/research-codebase.md`

- **IMPLEMENT**: Create example agent for codebase research:
  ```markdown
  # Research Agent: Codebase
  
  > **Type**: Subagent (discovery)
  > **Purpose**: Explore codebase to find relevant files, patterns, and integration points
  > **Activation**: Copy to `.opencode/agents/` to activate
  
  ## Mission
  
  You are a codebase exploration specialist. Given a feature request or query, you:
  1. Find relevant files with line-number references
  2. Extract patterns (naming, error handling, testing)
  3. Map integration points
  4. Document findings in structured format
  
  ## Output Format
  
  ### Relevant Files
  - `path/to/file` (lines X-Y) — Why: {reason}
  
  ### Patterns Found
  - **Pattern Name**: Description — Found in: `file:line`
  
  ### Integration Points
  - Files that need modification: {list}
  - New files to create: {list}
  ```
- **PATTERN**: Follow `AGENT-TEMPLATE.md` structure
- **IMPORTS**: N/A
- **GOTCHA**: These are example templates, not fully functional agents
- **VALIDATE**: `ls .opencode/agents/_examples/research-codebase.md`

### CREATE `.opencode/agents/_examples/research-external.md`

- **IMPLEMENT**: Create example agent for external research (library docs, best practices):
  ```markdown
  # Research Agent: External
  
  > **Type**: Subagent (discovery)
  > **Purpose**: Research external documentation, libraries, and best practices
  > **Activation**: Copy to `.opencode/agents/` to activate
  
  ## Mission
  
  You are an external research specialist. Given a feature or technology, you:
  1. Find official documentation
  2. Identify version compatibility notes
  3. Document best practices
  4. Flag gotchas and anti-patterns
  
  ## Output Format
  
  ### Relevant Documentation
  - [Title](URL) — Section: {name} — Why: {reason}
  
  ### Best Practices
  - {practice} — Source: {url}
  
  ### Gotchas
  - **Issue**: {description} — Mitigation: {how to avoid}
  ```
- **PATTERN**: Same structure as Task 02
- **IMPORTS**: N/A
- **GOTCHA**: Keep output concise (2-5 keywords for searches)
- **VALIDATE**: `ls .opencode/agents/_examples/research-external.md`

### CREATE `.opencode/agents/_examples/code-review-*.md` (4 files)

- **IMPLEMENT**: Create 4 code review specialist example agents:
  - `code-review-type-safety.md` — TypeScript type checking, generics, type guards
  - `code-review-security.md` — Input validation, auth, injection prevention
  - `code-review-architecture.md` — SOLID, patterns, module boundaries
  - `code-review-performance.md` — Complexity, caching, async patterns
  
  Each file follows this structure:
  ```markdown
  # Code Review Agent: {Specialty}
  
  > **Type**: Specialist (review)
  > **Purpose**: Review code for {specialty} issues
  > **Activation**: Copy to `.opencode/agents/` to activate
  
  ## Focus Areas
  
  - {Area 1}: {what to check}
  - {Area 2}: {what to check}
  
  ## Output Format
  
  ### Findings
  - **Severity**: Critical/High/Medium/Low
  - **File**: `path:line`
  - **Issue**: {description}
  - **Fix**: {recommended solution}
  ```
- **PATTERN**: Follow AGENT-TEMPLATE.md
- **IMPORTS**: N/A
- **GOTCHA**: Keep each focused on single specialty
- **VALIDATE**: `ls .opencode/agents/_examples/code-review-*.md | wc -l` → 4

### CREATE `.opencode/agents/_examples/plan-validator.md` AND `test-generator.md`

- **IMPLEMENT**: Create 2 utility example agents:
  
  `plan-validator.md`:
  ```markdown
  # Utility Agent: Plan Validator
  
  > **Type**: Subagent (validation)
  > **Purpose**: Validate implementation plans before execution
  > **Activation**: Copy to `.opencode/agents/` to activate
  
  ## Mission
  
  Review plan files for:
  1. All template sections filled
  2. File paths exist (or will be created)
  3. Task dependencies are ordered correctly
  4. Validation commands are executable
  
  ## Output Format
  
  ### Validation Result
  - **Status**: Valid / Needs Revision
  - **Issues**: {list if any}
  - **Recommendations**: {list if any}
  ```
  
  `test-generator.md`:
  ```markdown
  # Utility Agent: Test Generator
  
  > **Type**: Subagent (testing)
  > **Purpose**: Generate tests based on implementation code
  > **Activation**: Copy to `.opencode/agents/` to activate
  
  ## Mission
  
  Analyze implementation files and generate:
  1. Unit tests for each function/component
  2. Integration tests for workflows
  3. Edge case tests
  
  ## Output Format
  
  ### Generated Tests
  - `path/to/test.ts` — Tests: {function names}
  ```
- **PATTERN**: Follow AGENT-TEMPLATE.md
- **IMPORTS**: N/A
- **GOTCHA**: Keep focused on single responsibility
- **VALIDATE**: `ls .opencode/agents/_examples/{plan-validator,test-generator}.md`

### UPDATE `reference/subagents-overview.md` AND `memory.md`

- **IMPLEMENT**: Update counts to reflect reality:
  
  In `reference/subagents-overview.md`:
  - Line 116: Change "24 agents total" to "16 agents total (2 core, 8 subagent, 6 specialist)"
  - Lines 169-191: Update example agents list to match files created in Tasks 02-05
  
  In `memory.md`:
  - Line 19: Change "12 commands enhanced" to "23 commands available, selective agent integration"
  - Line 53: Change "22 agents" to "16 agents"
- **PATTERN**: N/A
- **IMPORTS**: N/A
- **GOTCHA**: Double-check actual counts with `ls | wc -l`
- **VALIDATE**: `grep -E "(24 agents|22 agents|12 commands)" reference/subagents-overview.md memory.md` → no matches

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify all example agents created
ls .opencode/agents/_examples/*.md | wc -l  # Should be 9 (8 agents + README)

# Verify reference file updated
grep -c "tmux-integration.md" reference/file-structure.md  # Should be 1
grep -c "create-pr.md" reference/file-structure.md  # Should be 1
```

### Content Verification
```bash
# Verify counts updated
grep "16 agents" reference/subagents-overview.md
grep "23 commands" memory.md
```

### Cross-Reference Check
```bash
# Verify no broken references
grep -r "\.opencode/skills/" reference/  # Should be empty after removing skills section
```

---

## SUB-PLAN CHECKLIST

- [x] Task 01: file-structure.md updated
- [x] Task 02: research-codebase.md created
- [x] Task 03: research-external.md created
- [x] Task 04: 4 code-review agents created
- [x] Task 05: plan-validator and test-generator created
- [x] Task 06: subagents-overview.md and memory.md updated
- [x] All validation commands pass

---

## HANDOFF NOTES

### Files Created
- `.opencode/agents/_examples/research-codebase.md` — Codebase exploration agent
- `.opencode/agents/_examples/research-external.md` — External research agent
- `.opencode/agents/_examples/code-review-type-safety.md` — Type safety reviewer
- `.opencode/agents/_examples/code-review-security.md` — Security reviewer
- `.opencode/agents/_examples/code-review-architecture.md` — Architecture reviewer
- `.opencode/agents/_examples/code-review-performance.md` — Performance reviewer
- `.opencode/agents/_examples/plan-validator.md` — Plan validation agent
- `.opencode/agents/_examples/test-generator.md` — Test generation agent

### Files Modified
- `reference/file-structure.md` — Updated to reflect actual file structure
- `reference/subagents-overview.md` — Updated agent counts
- `memory.md` — Updated command and agent counts

### Patterns Established
- Example agents now exist for reference by commands
- Documentation counts match reality

### State for Next Sub-Plan
- Sub-plan 02 will create templates that commands reference
- Example agents can now be activated via `/activate-agents`
