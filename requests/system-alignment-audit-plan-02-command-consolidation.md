# Sub-Plan 02: Command Consolidation

> **Parent Plan**: `requests/system-alignment-audit-plan-overview.md`
> **Sub-Plan**: 02 of 04
> **Phase**: Command Consolidation
> **Tasks**: 6
> **Estimated Context Load**: Medium

---

## Scope

This sub-plan consolidates overlapping commands, resolves naming conflicts, and improves minimal commands.

**What this sub-plan delivers**:
- `agents.md` renamed to `create-agent.md` (resolves AGENTS.md conflict)
- `quick-github-setup.md` merged into `setup-github-automation.md`
- `tmux-worktrees.md` expanded to follow command template
- `claude-mcp.md` evaluated (enhance or remove)

**Prerequisites from sub-plan 01**:
- Dead references in setup-github-automation.md and quick-github-setup.md already removed

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `.opencode/commands/agents.md` — To rename
- `.opencode/commands/quick-github-setup.md` — To merge
- `.opencode/commands/setup-github-automation.md` — Target for merge
- `.opencode/commands/tmux-worktrees.md` — To expand
- `.opencode/commands/claude-mcp.md` — To evaluate
- `.opencode/commands/prime.md` — Template example for structure

---

## STEP-BY-STEP TASKS

### RENAME `.opencode/commands/agents.md` → `create-agent.md`

- **IMPLEMENT**: 
  1. Rename file from `agents.md` to `create-agent.md`
  2. Update internal title from "# Agents" to "# Create Agent"
- **PATTERN**: `mv .opencode/commands/agents.md .opencode/commands/create-agent.md`
- **GOTCHA**: Check if any other files reference this command by name
- **VALIDATE**: `ls .opencode/commands/create-agent.md` succeeds

### UPDATE references to renamed command

- **IMPLEMENT**: Search for and update any references to `/agents` command:
  1. Check `.opencode/commands/*.md` for `/agents` references
  2. Update to `/create-agent`
  3. Check `AGENTS.md` on-demand guides table
- **PATTERN**: `grep -l "/agents" .opencode/commands/*.md`
- **GOTCHA**: Don't change references to `AGENTS.md` (root file) or agent files
- **VALIDATE**: `grep -r '"/agents"' .opencode/commands/` returns only AGENTS.md references

### MERGE `quick-github-setup.md` into `setup-github-automation.md`

- **IMPLEMENT**:
  1. Add "Quick Mode" section to setup-github-automation.md
  2. Add note: "For quick setup, skip to Quick Mode section"
  3. Extract unique value from quick-github-setup.md (if any) and add to setup-github-automation.md
  4. Replace quick-github-setup.md with redirect: "See `/setup-github-automation` — this command is now consolidated"
- **PATTERN**: Consolidation with redirect
- **GOTCHA**: Don't lose any unique functionality from quick-github-setup
- **VALIDATE**: `grep "Quick Mode" .opencode/commands/setup-github-automation.md` succeeds

### REMOVE `quick-github-setup.md`

- **IMPLEMENT**:
  1. Verify merge is complete
  2. Delete `.opencode/commands/quick-github-setup.md`
- **PATTERN**: `rm .opencode/commands/quick-github-setup.md`
- **GOTCHA**: Ensure no other files reference this command
- **VALIDATE**: `ls .opencode/commands/quick-github-setup.md` fails

### EXPAND `tmux-worktrees.md`

- **IMPLEMENT**: Expand from 34 lines to follow command template:
  1. Add standard frontmatter (description, argument-hint if applicable)
  2. Add INPUT section (what user provides)
  3. Add PROCESS section (steps the command follows)
  4. Add OUTPUT section (what user sees)
  5. Add error handling and agent integration notes
- **PATTERN**: See `.opencode/commands/prime.md` or `commit.md` for structure
- **GOTCHA**: Keep it concise — target ~80-100 lines, not 200+
- **VALIDATE**: `wc -l .opencode/commands/tmux-worktrees.md` shows 80+ lines

### EVALUATE `claude-mcp.md`

- **IMPLEMENT**: Decide: enhance or remove?
  - If enhance: Add agent integration, better error handling, clear workflow
  - If remove: Delete file, note in memory.md that `claude mcp` is direct CLI usage
  - **Recommendation**: REMOVE — thin wrapper with minimal value over direct CLI
- **PATTERN**: Decision-based action
- **GOTCHA**: Check if referenced elsewhere
- **VALIDATE**: Either enhanced to 60+ lines with clear value, or file deleted

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# All command files follow naming convention
ls .opencode/commands/*.md | grep -v "^[a-z-]*\.md$" && echo "FAIL: Non-kebab-case" || echo "PASS"
```

### Content Verification
```bash
# setup-github-automation has quick mode
grep -q "Quick Mode" .opencode/commands/setup-github-automation.md && echo "PASS" || echo "FAIL"

# tmux-worktrees has proper structure
grep -q "## INPUT\|## PROCESS\|## OUTPUT" .opencode/commands/tmux-worktrees.md && echo "PASS" || echo "FAIL"
```

### Cross-Reference Check
```bash
# No broken command references
for cmd in agents quick-github-setup; do
  grep -r "/$cmd" .opencode/commands/ 2>/dev/null && echo "WARN: /$cmd still referenced"
done
```

---

## SUB-PLAN CHECKLIST

- [ ] Task 1: agents.md renamed to create-agent.md
- [ ] Task 2: References updated
- [ ] Task 3: quick-github-setup merged into setup-github-automation
- [ ] Task 4: quick-github-setup.md deleted
- [ ] Task 5: tmux-worktrees.md expanded
- [ ] Task 6: claude-mcp.md decided (enhanced or removed)

---

## HANDOFF NOTES

### Files Modified
- `.opencode/commands/agents.md` → renamed to `create-agent.md`
- `.opencode/commands/setup-github-automation.md` — now includes quick mode
- `.opencode/commands/tmux-worktrees.md` — expanded to follow template

### Files Deleted
- `.opencode/commands/quick-github-setup.md` — merged into setup-github-automation
- `.opencode/commands/claude-mcp.md` — (if removed)

### State for Next Sub-Plan
- Commands consolidated. Sub-plan 03 will fix documentation counts and align agent inventory.
- New command count: 22 (if claude-mcp removed) or 23 (if enhanced)
