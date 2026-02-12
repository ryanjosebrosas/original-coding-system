# tmux Integration for Parallel Development

## Quick Start

1. Configure tmux: Ensure `~/.tmux.conf` exists with recommended settings
2. Create worktrees: `/tmux-worktrees feature/a feature/b`
3. Work in panes: Each pane has OpenCode in its worktree
4. Detach: `Ctrl+a, d`
5. Reattach: `tmux attach -t worktree-*`

## tmux Concepts

- **Session**: Collection of windows, named (e.g., `worktree-myproject-1430`)
- **Window**: Full terminal screen, can have multiple panes
- **Pane**: Split section of window, runs one program

## Key Bindings (with C-a prefix)

| Key | Action |
|-----|--------|
| `d` | Detach session |
| `h/j/k/l` | Navigate panes |
| `\|` | Split horizontal |
| `-` | Split vertical |
| `z` | Zoom pane (toggle) |
| `W` | List worktree sessions |
| `r` | Reload config |

## Workflow

1. `/tmux-worktrees feature/search feature/export` — creates session with 2 panes
2. Each pane: worktree directory + opencode running
3. Work on features in parallel
4. Detach when done, reattach anytime
5. After merging: `tmux kill-session -t worktree-*`

## Troubleshooting

- **"tmux not found"**: Install with `apt install tmux` or `brew install tmux`
- **"opencode not found"**: Ensure opencode is in PATH for tmux shell
- **Nested sessions**: Script detects tmux and uses `switch-client` instead of `attach`
