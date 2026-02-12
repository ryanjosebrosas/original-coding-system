---
description: Create git worktrees in tmux panes for parallel development
argument-hint: [branch1] [branch2] ... [branchN] (1-10 branches)
---

# tmux Worktrees

Create worktrees with tmux session management for organized parallel development.

## Parameters

- **Branches**: $ARGUMENTS (1-10 branch names)
- Examples: `/tmux-worktrees feature/search feature/export`

## Process

1. Parse branch arguments (validate 1-10)
2. Verify tmux installed, in git repo
3. For each branch: create worktree at `worktrees/{branch}`
4. Create tmux session: `worktree-{project}-{HHMM}`
5. Split panes (horizontal for 2-4, tiled for 5+)
6. Launch opencode in each pane
7. Attach to session

## Output

Session name, worktree paths, tmux quick reference (detach, navigate, reattach)

## Notes

- Detach: `Ctrl+a, d` | Reattach: `tmux attach -t worktree-*`
- Layout: 2-4 branches = horizontal, 5+ = tiled
- Session persists after detach
