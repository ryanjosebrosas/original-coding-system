---
description: Parallel end-to-end development for multiple features using worktrees
argument-hint: feature A | feature B | feature C (pipe-separated, 2-10 features)
---

# Parallel End-to-End Feature Development

**Feature Descriptions**: $ARGUMENTS

This command chains the full PIV Loop for **multiple features simultaneously**. It primes once, plans each feature sequentially (with overlap detection), creates worktrees, spawns `opencode -p` background processes to execute plans in parallel, merges all branches with validation, commits, and creates a PR.

**WARNING**: Only use this command if `/end-to-end-feature`, `/new-worktree`, and `/merge-worktrees` are each proven reliable. This command combines all three — bugs in any one will compound. Features MUST be isolated (vertical slice architecture) for safe parallel execution.

**Cost Warning**: N parallel `opencode -p` processes = N times API costs. Each process uses significant RAM/CPU.

**Platform Note**: Background process management (`&`, `wait`) requires Unix-like systems (macOS/Linux). Windows users should use WSL.

---

## Step 0: Parse Arguments & Validate

1. Split `$ARGUMENTS` by `|` delimiter into a list of feature descriptions
2. Trim whitespace from each feature
3. Count features (N):
   - If N < 2: Error — "Use `/end-to-end-feature` for single features. This command requires 2+ features."
   - If N > 10: Error — "Maximum 10 parallel features supported (worktree/subagent limit)."
4. Generate kebab-case feature names from descriptions (e.g., "search functionality" → "search-functionality")
5. Generate branch names: `feature/{kebab-name}` for each
6. Display parsed features table:

```
Parsed Features (N total):
| # | Feature Name        | Branch                      | Plan Path                              |
|---|---------------------|-----------------------------|----------------------------------------|
| 1 | search-functionality| feature/search-functionality | requests/search-functionality-plan.md  |
| 2 | csv-export          | feature/csv-export           | requests/csv-export-plan.md            |
| ...                                                                                              |
```

**Error Handling**: If arguments can't be parsed (no `|` found, empty descriptions), show expected format and stop.

---

## Step 1: Prime — Load Codebase Context

Build comprehensive understanding by:

1. Analyzing project structure (files, directories)
2. Reading core documentation (AGENTS.md, README)
3. Identifying key files (entry points, configs, schemas)
4. Understanding current state (branch, recent commits)
5. Read memory.md for project context (if it exists)
6. Search Archon RAG for relevant documentation (if available)

Provide a brief summary before proceeding.

---

## Step 2: Plan All Features (Sequential)

For EACH feature (i = 1 to N), run the planning methodology:

### Feature {i} of N: {feature-description}

1. Create a comprehensive implementation plan using the `/planning` methodology:
   - Phase 1: Feature understanding & scoping
   - Phase 2: Codebase intelligence (patterns, integration points)
   - Phase 3: External research (docs, best practices)
   - Phase 4: Strategic design & synthesis
   - Phase 5: Step-by-step task generation
   - Phase 6: Quality validation & confidence score

2. Save plan to `requests/{feature-name}-plan.md`

3. **CRITICAL — File Overlap Detection** (after each plan except the first):
   - Read all plan files created so far
   - Compare "New Files to Create" and "STEP-BY-STEP TASKS" target files across all plans
   - If overlap detected beyond registration points (routes, configs):
     ```
      ⚠ FILE OVERLAP DETECTED

      Feature "{feature-A}" and Feature "{feature-B}" both modify:
        - path/to/shared/file.ext

      This is NOT a registration point overlap — these features are NOT isolated.

      Options:
      1. Remove the overlapping feature and continue with remaining features
      2. Stop and redesign features for better isolation
      3. Implement overlapping features sequentially (not in parallel)
      ```
     Use the question tool to let the user decide.

4. Report: "Plan {i}/{N} created: `requests/{feature-name}-plan.md`"

**Why sequential?** Overlap detection requires knowing previous plans. Coherent planning needs full context. Parallel planning risks two plans modifying the same files.

---

## Step 3: Commit Plans (Git Save Point)

```bash
git add requests/{feature-1}-plan.md requests/{feature-2}-plan.md ...
git commit -m "plan: parallel plans for {feature-1}, {feature-2}, ..."
```

This creates a save point. If execution fails, revert to this commit with `git checkout .` or `git stash`.

---

## Step 4: Create Worktrees

**If `opencode-worktree` plugin available** (check for `worktree_create` tool):

For EACH feature, call the worktree plugin:

```
worktree_create:
  branch: "feature/{kebab-name}"
  baseBranch: "main"
```

**Plugin automatically handles:**
- Creates worktree at `~/.local/share/opencode/worktree/<project>/feature/{kebab-name}`
- Syncs files per `.opencode/worktree.jsonc`
- Runs postCreate hooks (dependency installation)
- Spawns terminal with OpenCode already running

**Launch all `worktree_create` calls in parallel** — each terminal spawns independently.

---

**If plugin not available** (fallback):

Use manual worktree creation per original `/new-worktree` logic — launch N Task agents with bash commands.

---

**If any worktree fails**: Report which failed, offer retry or continue with successful ones.

---

## Step 5: Instruct Terminals

**If using plugin** (terminals already running OpenCode):

Plans are accessible from the main repo at `requests/{feature}-plan.md`.

Instruct users: "In each spawned terminal, run: `/execute requests/{feature}-plan.md`"

**If manual mode**: Copy plans to worktrees:
```bash
mkdir -p worktrees/{kebab-name}/requests/
cp requests/{feature-name}-plan.md worktrees/{kebab-name}/requests/
```

---

## Step 6: Execute in Parallel

**Plugin Mode (Simplified):**

Terminals are already running OpenCode. Each terminal receives the instruction to execute its plan.

User workflow:
1. In each spawned terminal, run: `/execute requests/{feature}-plan.md`
2. Terminals work in parallel — each implements its feature independently
3. Signal completion when all terminals finish (user manually confirms)

**Manual Mode (Background Processes):**

If plugin not available, use `opencode -p` background processes (original approach):
- Launch background processes with `--dangerously-skip-permissions`
- Store PIDs, wait for completion, parse JSON logs

---

### 6a. Wait for Completion

**Plugin Mode**: User signals when all terminals have completed their work.

**Manual Mode**: `wait $PID_0 $PID_1 ...` then parse log files.

### 6b. Handle Failures

- If ALL features succeeded: continue to Step 7
- If SOME features failed: offer "Continue with successful features" or "Stop and investigate"
- If ALL features failed: stop, provide diagnostic info

---

## Step 7: Merge All Features

Embed the `/merge-worktrees` logic for successful features.

### 7a. Verify preconditions

- Verify we're in repo root (not inside `worktrees/`)
- Verify all successful feature branches have commits
- Store current branch: `CURRENT_BRANCH=$(git branch --show-current)`

### 7b. Create integration branch

```bash
git checkout -b integration-{first-feature}-to-{last-feature}
```

### 7c. Sequential merge with testing

For each successful feature branch:

```bash
git merge feature/{kebab-name} --no-ff -m "merge: integrate {feature-name}"
```

**If conflicts**: Stop, report conflicted files, provide resolution steps and rollback instructions.

After each merge, run tests:
```bash
pytest -v
```

**Note**: Replace `pytest` with your project's test command.

If tests fail: stop, report which feature's merge caused the failure, provide rollback instructions.

### 7d. Full validation suite

After all branches merged:

```bash
pytest -v
mypy app/
```

**Note**: Customize validation commands for your project (npm test, tsc, cargo test, etc.)

### 7e. Merge to original branch

```bash
git checkout $CURRENT_BRANCH
git merge integration-{first-to-last} --no-ff -m "merge: integrate features {first} to {last}"
```

### 7f. Cleanup

```bash
git branch -d integration-{first-to-last}
```

**Rollback instructions** (on ANY failure):
```
git checkout $CURRENT_BRANCH
git branch -D integration-{first-to-last}
```

---

## Step 8: Commit All Changes

1. Review git status and diff
2. Create conventional commit:
   ```
   feat: parallel implementation of {feature-1}, {feature-2}, ...

   Implemented N features in parallel using git worktrees + opencode:
   - {feature-1}: {brief description}
   - {feature-2}: {brief description}
   ...
   ```
3. Update memory.md with lessons learned (if it exists):
   - What worked well in parallel execution
   - Any gotchas encountered
   - Feature isolation observations

---

## Step 9: Create Pull Request

1. Push branch to remote:
   ```bash
   git push -u origin $CURRENT_BRANCH
   ```

2. Create PR:
   ```bash
   gh pr create --title "feat: parallel implementation of {feature-1}, {feature-2}, ..." --body "$(cat <<'EOF'
   ## Summary
   Parallel implementation of N features:
   - {feature-1}: {brief description}
   - {feature-2}: {brief description}

   ## Implementation Details
   Features were planned sequentially (with overlap detection) and implemented in parallel using git worktrees + opencode.

   ## Plans
   - requests/{feature-1}-plan.md
   - requests/{feature-2}-plan.md

   ## Test Plan
   - [x] Each feature validated individually in worktree
   - [x] Integration tests passed after merge
   - [x] Full validation suite passed

   🤖 Generated with [OpenCode](https://opencode.ai) via `/parallel-e2e`
   EOF
   )"
   ```

3. Capture PR URL and number

**Error Handling**:
- If `gh` CLI is not available: provide manual PR creation instructions
- If already on master/main: skip PR creation and warn the user
- If PR already exists: show the existing PR URL

---

## Final Summary

```
✅ Parallel Feature Implementation Complete

Features: N features implemented in parallel

| Feature              | Status  | Branch                      | Commit  | Files Changed |
|----------------------|---------|-----------------------------|---------|---------------|
| search-functionality | SUCCESS | feature/search-functionality | abc1234 | 5             |
| csv-export           | SUCCESS | feature/csv-export           | def5678 | 3             |

Total Time: Xm (vs ~{N*X}m sequential = {savings}% faster)

Outputs:
- Plans: requests/{feature-*}-plan.md
- PR: #{number} - {url}
- Commit: {hash}
- Logs: logs/{feature-*}.json

Cleanup:
- Worktrees removed: [yes/no]
- Feature branches deleted: [yes/no]
```

After displaying summary, use the question tool to ask about worktree cleanup:
- "Yes, clean up worktrees and branches" — remove worktrees and delete feature branches
- "No, keep them for now" — provide manual cleanup instructions

**If user chooses cleanup with plugin available:**

For EACH completed feature:
```
worktree_delete:
  reason: "Feature {name} merged to {target-branch}"
```

Plugin handles: auto-commit uncommitted changes (with "snapshot" message), git worktree remove, session cleanup.

**If manual cleanup needed:**
```bash
git worktree remove worktrees/{kebab-name}
git branch -d feature/{kebab-name}
```

---

## Error Handling Summary

| Failure Point | Action |
|---------------|--------|
| Parse failure | Show expected format: `feature A \| feature B \| feature C` |
| Planning overlap | Stop, show conflicting files, let user decide |
| Worktree creation failure | Report which failed, offer retry or continue with others |
| `opencode -p` failure | Show exit code + log path, offer partial merge or stop |
| Merge conflict | Rollback instructions, resolution steps |
| Test failure after merge | Rollback instructions, identify which feature caused it |
| PR creation failure | Provide manual instructions |

**Partial merge failure** (e.g., branch 3 of 5 fails):
- Branches 1-2 already merged to integration branch
- Branch 3 failed (conflicts or test failure)
- Branches 4-5 not yet attempted
- Provide rollback to clean state OR continue-after-fix instructions

---

## Notes

- **Trust Progression**: This is the highest-automation command. Only use when individual commands are proven reliable:
   ```
   Manual → Commands → Chained → Subagents → Worktrees → Parallel Chained → Remote
     ↑ trust & verify ↑  ↑ trust & verify ↑  ↑ trust & verify ↑  ↑ trust & verify ↑
   ```

- **Project Customization**: Replace these for your project:
   - Dependency sync: `uv sync` → `npm install`, `pip install`, `bundle install`
   - Test runner: `pytest` → `npm test`, `cargo test`, `go test`
   - Type checker: `mypy` → `tsc`, `pyright`, `flow`
   - Port base: 8124 → your project's port convention

- **Vertical Slice Requirement**: Features MUST be isolated for safe parallel execution. If features share significant code paths, implement them sequentially with `/end-to-end-feature`.

- **MCP in `opencode -p`**: Archon is NOT included in the `opencode -p` execution prompt. MCP tools may not be available in subprocess mode. The main conversation handles all MCP integration before and after parallel execution. memory.md is available since it's a repo file.

- **Resource Usage**: Each `opencode -p` process runs independently. Monitor system resources when running 5+ parallel processes. Reduce parallel count if hitting memory or rate limits.
