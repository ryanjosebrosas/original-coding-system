---
description: Create git commit with conventional message format
argument-hint: [file1] [file2] ... (optional - commits all changes if not specified)
---

# Commit: Create Git Commit

## Files to Commit

Files specified: $ARGUMENTS

(If no files specified, commit all changes)

## Commit Process

### 1. Review Current State

```bash
git status
git diff HEAD
```

If staging specific files: `git diff HEAD -- $ARGUMENTS`

### 2. Analyze Changes

Determine type (feat/fix/refactor/docs/test/chore/perf/style/plan), scope, and description (imperative mood, 50 chars). Add body if significant context needed.

### 2.5. Pre-Commit Validation (Optional)

**If BuildAgent available** (`ls .opencode/agents/subagent-buildagent.md`):
- Launch `@subagent-buildagent` for pre-commit validation
- Fix any errors before proceeding
- Skip if agent not available

### 3. Stage and Commit

```bash
git add $ARGUMENTS  # or git add . if no files specified
git commit -m "type(scope): description"
```

### 3.5. Test Coverage Suggestion (Optional)

**If tests appear missing** (no test files in staged changes for `feat` or `fix` commits) AND commit type is `feat` or `fix`:
- Suggest: "Consider running `/code-review` or invoking `@subagent-testengineer` to add test coverage before finalizing."
- This is a **suggestion only** — don't block commits. Many commits legitimately have no tests.

### 4. Confirm Success

```bash
git log -1 --oneline
git show --stat
```

## Output Report

**Commit Hash**: [hash]
**Message**: [full message]
**Files**: [list with change stats]
**Summary**: X files changed, Y insertions(+), Z deletions(-)

**Next**: Push to remote (`git push`) or continue development.

### 5. Session Archival (if session exists)

**If `.tmp/sessions/{id}/context.md` exists**:
1. Read session context
2. Extract key decisions, blockers resolved, patterns discovered
3. Append 1-line summary to memory.md Session Notes: `- [{date}] Session {id}: {feature} — {summary}`
4. Update session status to `archived` in context.md

**If no session**: Skip — proceed to memory update.

### 6. Update Memory (if memory.md exists)

Append to memory.md: session note, any lessons/gotchas/decisions discovered. Keep entries 1-2 lines each. Don't repeat existing entries. Skip if memory.md doesn't exist.

### 7. Report Completion

**Archon** (if available): `manage_project("update", project_id="...", description="Feature complete, committed: {hash}")`

## Notes

- If no changes to commit, report clearly
- If commit fails (pre-commit hooks), report the error
- Follow by project's commit message conventions
- Do NOT include Co-Authored-By lines in commits
