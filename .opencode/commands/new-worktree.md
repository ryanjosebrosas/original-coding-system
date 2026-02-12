---
description: Create git worktrees with automatic terminal spawning
argument-hint: [branch1] [branch2] ... [branchN] (1-10 branches)
---

# New Worktree

Create worktrees using the `opencode-worktree` plugin for zero-friction parallel development.

## Parameters

- **Branches**: $ARGUMENTS (1-10 branch names, space-separated)
- Examples:
  - Single: `/new-worktree feature/search`
  - Two: `/new-worktree feature/search feature/export`
  - Many: `/new-worktree feature/search feature/export feature/analytics`

## Process

### Step 1: Parse Arguments

Parse $ARGUMENTS into list of branch names.

**Validation:**
- If N = 0: Error — "At least 1 branch name required"
- If N > 10: Error — "Maximum 10 worktrees supported"

### Step 2: Check Plugin Availability

**If `opencode-worktree` plugin available** (check for `worktree_create` tool):
- Proceed to Step 3 (Plugin Mode)

**If plugin not available** (fallback):
- Proceed to Step 3-Fallback (Manual Mode)

---

### Step 3: Create Worktrees (Plugin Mode)

For EACH branch, call the worktree plugin:

```
worktree_create:
  branch: "{branch-name}"
  baseBranch: "main"  # or current branch
```

**Plugin automatically handles:**
- Creates worktree at `~/.local/share/opencode/worktree/<project>/<branch>`
- Syncs files per `.opencode/worktree.jsonc` configuration
- Runs postCreate hooks (dependency installation)
- Spawns terminal with OpenCode running

**For multiple branches**: Launch all `worktree_create` calls in parallel.

### Step 4: Report Success

```
Worktrees Created (Plugin Mode):

[For each branch:]
  Branch: {branch-name}
  Path: ~/.local/share/opencode/worktree/<project>/{branch-name}
  Terminal: Spawned automatically

All worktrees ready! Terminals are running OpenCode in each worktree.

Next steps:
  In each terminal, run:
  /execute requests/{feature}-plan.md
```

---

### Step 3-Fallback: Create Worktrees (Manual Mode)

**If plugin not available**, use manual git commands:

For EACH branch:

```bash
# Create worktree
git worktree add worktrees/{branch} -b {branch}

# Navigate and sync dependencies (customize for your stack)
cd worktrees/{branch}
# npm install / pip install / uv sync
cd ../..
```

### Step 4-Fallback: Report Success

```
Worktrees Created (Manual Mode):

[For each branch:]
  Branch: {branch-name}
  Path: worktrees/{branch-name}

Install the opencode-worktree plugin for automatic terminal spawning:
  curl -fsSL https://ocx.kdco.dev/install.sh | sh
  ocx registry add https://registry.kdco.dev --name kdco
  ocx add kdco/worktree

Next steps:
  Open separate terminals and run:
  cd worktrees/{branch-name}
  opencode
  /execute requests/{feature}-plan.md
```

---

## Notes

**Plugin vs Manual:**
| Aspect | Plugin | Manual |
|--------|--------|--------|
| Terminal spawning | Automatic | Manual |
| File sync | Configured via `.opencode/worktree.jsonc` | Manual |
| Dependency hooks | Automatic | Manual |
| Cleanup | `worktree_delete` with auto-commit | `git worktree remove` |
| Storage location | `~/.local/share/opencode/worktree/` | `./worktrees/` |

**Plugin Installation:**
```bash
curl -fsSL https://ocx.kdco.dev/install.sh | sh
ocx registry add https://registry.kdco.dev --name kdco
ocx add kdco/worktree
```

**Configuration:**
See `.opencode/worktree.jsonc` for sync rules and hooks.

**Conflict Prevention:**
Each worktree is fully isolated. If features share registration points (routes, configs), handle those during merge — NOT during implementation.

---

## See Also

**tmux Integration**: Use `/tmux-worktrees` for organized parallel development with pane management, session persistence, and unified view. See `reference/tmux-integration.md`.
