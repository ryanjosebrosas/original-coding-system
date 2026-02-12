# Feature: tmux-worktree-integration

## Feature Description

Integrate tmux with OpenCode's worktree workflow to spawn parallel worktrees in tmux panes instead of separate terminal windows — enabling organized session management, persistence, and unified agent viewing.

## User Story

As a developer using OpenCode's parallel worktree workflow, I want worktrees to automatically spawn in tmux panes, so that I can manage multiple parallel agents in a single organized terminal session with persistence.

## Problem Statement

The current worktree plugin spawns separate terminal windows for each worktree, creating:
- Window clutter and difficult organization
- No session persistence (terminal close = session lost)
- No unified view of all parallel agents
- Manual window arrangement required

## Solution Statement

- Decision 1: **tmux as spawning target** — provides session persistence, pane management, unified viewing
- Decision 2: **New session per worktree batch** — groups related work, clean detach/reattach
- Decision 3: **Shell script + command** — maintains compatibility while adding tmux support

## Feature Metadata

- **Feature Type**: Enhancement
- **Estimated Complexity**: Medium
- **Primary Systems Affected**: `.opencode/commands/`, `~/.tmux.conf`, shell scripts
- **Dependencies**: tmux (installed), bash shell

---

## CONTEXT REFERENCES

### Relevant Codebase Files

- `.opencode/commands/new-worktree.md` (1-137) — Current worktree command to integrate with
- `.opencode/worktree.jsonc` (1-20) — Worktree sync configuration
- `reference/git-worktrees-overview.md` (1-100) — Plugin tools and workflow docs
- `tmux/example_tmux.conf` (1-72) — Example tmux configuration

### New Files to Create

- `~/.tmux.conf` — tmux configuration with OpenCode-optimized settings
- `.opencode/scripts/tmux-worktree.sh` — Shell script for tmux-integrated spawning
- `.opencode/commands/tmux-worktrees.md` — New command for tmux parallel worktrees
- `reference/tmux-integration.md` — Documentation for tmux workflow

### Relevant Documentation

- [tmux Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started) — Core concepts
- [tmux Manual](https://man.openbsd.org/tmux) — new-session, split-window, send-keys commands

### Patterns to Follow

**Command Structure** (from `new-worktree.md:1-10`):
```markdown
---
description: Create git worktrees with automatic terminal spawning
argument-hint: [branch1] [branch2] ... [branchN]
---
```

**tmux Config** (from `example_tmux.conf:29-31`):
```bash
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```

---

## IMPLEMENTATION PLAN

### Phase 1: Foundation — tmux Configuration
Create `~/.tmux.conf` with sensible defaults (prefix key, mouse, status line, pane navigation)

### Phase 2: Core — Worktree Script  
Create `tmux-worktree.sh` handling single/multi worktree modes with session naming

### Phase 3: Integration — OpenCode Command
Create `/tmux-worktrees` command wrapping script with plugin awareness

### Phase 4: Documentation
Create reference guide and update existing worktree docs

---

## STEP-BY-STEP TASKS

### CREATE ~/.tmux.conf

- **IMPLEMENT**: tmux config with: `C-a` prefix, mouse enabled, 256-color, vim-style pane navigation (`h/j/k/l`), easy splits (`|` and `-`), status bar showing session name
- **PATTERN**: `tmux/example_tmux.conf:1-72`
- **IMPORTS**: N/A
- **GOTCHA**: Backup existing config. Use `set -g` for global options.
- **VALIDATE**: `tmux source ~/.tmux.conf && echo "OK"`

```bash
# Core settings
set -g default-terminal "tmux-256color"
set -g history-limit 10000
set -g base-index 1
set -g mouse on
set -sg escape-time 10

# Prefix: C-a instead of C-b
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Split panes
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Navigate panes (vim keys)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Status bar
set -g status-position bottom
set -g status-left '#[bold] #S '
set -g status-right ' %H:%M %d-%b '

# Pane borders
set -g pane-active-border-style 'fg=green'

# Copy mode with vim keys
setw -g mode-keys vi

# Reload config
bind r source-file ~/.tmux.conf \; display "Reloaded!"

# List worktree sessions
bind W choose-tree -s -f '#{?#{m:worktree-*,#{session_name}},1,0}'
```

---

### CREATE .opencode/scripts/tmux-worktree.sh

- **IMPLEMENT**: Script that accepts branch names, creates worktrees, spawns tmux session with panes, launches opencode in each pane
- **PATTERN**: Standard bash with `set -euo pipefail`
- **IMPORTS**: tmux, git, opencode
- **GOTCHA**: Handle existing worktrees, check tmux installed, detect if already in tmux
- **VALIDATE**: `bash -n .opencode/scripts/tmux-worktree.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

WORKTREE_BASE="${WORKTREE_BASE:-worktrees}"
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)" 2>/dev/null || echo "project")
SESSION_NAME="worktree-${PROJECT_NAME}-$(date +%H%M)"

# Validate args
[[ $# -eq 0 ]] && { echo "Usage: $0 branch1 [branch2 ...]"; exit 1; }
[[ $# -gt 10 ]] && { echo "Max 10 branches"; exit 1; }
command -v tmux &>/dev/null || { echo "tmux not installed"; exit 1; }
git rev-parse --git-dir &>/dev/null || { echo "Not a git repo"; exit 1; }

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
mkdir -p "$WORKTREE_BASE"

BRANCHES=("$@")
PATHS=()

# Create worktrees
for branch in "${BRANCHES[@]}"; do
    dir="${branch//\//-}"
    path="${WORKTREE_BASE}/${dir}"
    [[ -d "$path" ]] || git worktree add "$path" -b "$branch" 2>/dev/null || \
                        git worktree add "$path" "$branch"
    PATHS+=("$REPO_ROOT/$path")
done

# Create tmux session
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
tmux new-session -d -s "$SESSION_NAME" -c "${PATHS[0]}"
tmux send-keys -t "$SESSION_NAME" "opencode" Enter

# Add panes for additional worktrees
for ((i=1; i<${#BRANCHES[@]}; i++)); do
    if [[ ${#BRANCHES[@]} -le 4 ]]; then
        tmux split-window -t "$SESSION_NAME" -h -c "${PATHS[$i]}"
    else
        tmux split-window -t "$SESSION_NAME" -c "${PATHS[$i]}"
    fi
    tmux send-keys "opencode" Enter
done

# Set layout
[[ ${#BRANCHES[@]} -le 4 ]] && tmux select-layout -t "$SESSION_NAME" even-horizontal \
                            || tmux select-layout -t "$SESSION_NAME" tiled
tmux select-pane -t "$SESSION_NAME:1.0"

# Output and attach
echo "Session: $SESSION_NAME"
echo "Detach: Ctrl+a, d | Reattach: tmux attach -t $SESSION_NAME"
[[ -z "${TMUX:-}" ]] && tmux attach-session -t "$SESSION_NAME" \
                     || tmux switch-client -t "$SESSION_NAME"
```

---

### CREATE .opencode/commands/tmux-worktrees.md

- **IMPLEMENT**: OpenCode command that invokes the shell script, documents usage
- **PATTERN**: `.opencode/commands/new-worktree.md`
- **IMPORTS**: References `.opencode/scripts/tmux-worktree.sh`
- **GOTCHA**: Document both plugin and manual modes
- **VALIDATE**: `test -f .opencode/commands/tmux-worktrees.md`

```markdown
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
```

---

### CREATE reference/tmux-integration.md

- **IMPLEMENT**: Guide covering tmux basics, worktree integration, key bindings, troubleshooting
- **PATTERN**: `reference/git-worktrees-overview.md`
- **IMPORTS**: N/A
- **GOTCHA**: Keep beginner-friendly (user is new to tmux)
- **VALIDATE**: `test -f reference/tmux-integration.md`

```markdown
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
```

---

### UPDATE .opencode/commands/new-worktree.md

- **IMPLEMENT**: Add "See Also" section pointing to `/tmux-worktrees`
- **PATTERN**: Existing structure
- **IMPORTS**: N/A
- **GOTCHA**: Additive only — don't break existing
- **VALIDATE**: `grep -q "tmux" .opencode/commands/new-worktree.md`

**Add at end:**
```markdown
---

## See Also

**tmux Integration**: Use `/tmux-worktrees` for organized parallel development with pane management, session persistence, and unified view. See `reference/tmux-integration.md`.
```

---

### UPDATE reference/git-worktrees-overview.md

- **IMPLEMENT**: Add tmux section after "Plugin vs Manual"
- **PATTERN**: Existing structure
- **IMPORTS**: N/A
- **GOTCHA**: Insert in logical location
- **VALIDATE**: `grep -q "tmux" reference/git-worktrees-overview.md`

**Add after line 43:**
```markdown
### tmux Integration

For session persistence and unified viewing: `/tmux-worktrees feature/a feature/b`

Benefits: All worktrees in one terminal, detach/reattach, keyboard navigation. See `reference/tmux-integration.md`.
```

---

### CREATE .opencode/scripts directory

- **IMPLEMENT**: `mkdir -p .opencode/scripts`
- **VALIDATE**: `ls -la .opencode/scripts/`

---

## TESTING STRATEGY

### Integration Tests

1. **Single worktree**: `/tmux-worktrees test-single` — verify session, worktree, opencode
2. **Multiple worktrees**: `/tmux-worktrees a b c` — verify 3 panes, layout
3. **Persistence**: Detach, verify `tmux ls`, reattach
4. **Cleanup**: Kill session, remove worktrees

### Edge Cases

- Worktree exists — should reuse/warn
- Branch missing — should create or error
- tmux not installed — clear error
- Already in tmux — switch client, not nest
- 5+ worktrees — tiled layout

---

## VALIDATION COMMANDS

### Level 1: Syntax
```bash
bash -n .opencode/scripts/tmux-worktree.sh
tmux source ~/.tmux.conf
```

### Level 3: Integration
```bash
.opencode/scripts/tmux-worktree.sh test-branch
tmux ls | grep worktree
tmux kill-session -t $(tmux ls | grep worktree | cut -d: -f1)
git worktree remove worktrees/test-branch
git branch -d test-branch
```

### Level 4: Manual
1. Run `/tmux-worktrees feature/test`
2. Verify opencode starts
3. Detach (`Ctrl+a, d`)
4. Verify session persists (`tmux ls`)
5. Reattach (`tmux attach`)
6. Cleanup

---

## ACCEPTANCE CRITERIA

- [x] tmux config created with OpenCode-optimized settings
- [x] Shell script creates worktrees + tmux session correctly
- [x] `/tmux-worktrees` command documented and functional
- [x] Existing docs updated with tmux references
- [x] Reference guide created for new users
- [ ] Session persistence works (detach/reattach)
- [ ] Multiple worktrees display organized layout

---

## COMPLETION CHECKLIST

- [x] All tasks completed in order
- [x] tmux config loads without errors
- [x] Shell script runs without errors
- [ ] Command creates session correctly
- [x] Documentation clear and complete
- [ ] Manual testing confirms feature works

---

## NOTES

### Key Design Decisions

- **Session per batch** — groups related work, easy to see all agents
- **C-a prefix** — easier to reach than C-b
- **Horizontal for 2-4, tiled for 5+** — optimal readability at each count
- **Timestamp in session name** — prevents collisions

### Risks

- **Existing tmux config** — backup before overwriting
- **opencode not in PATH in tmux** — document PATH requirements
- **WSL paths** — test portable path handling

### Confidence Score: 8/10

- **Strengths**: Clear requirements, documented tmux patterns, existing worktree infrastructure
- **Uncertainties**: Plugin detection, WSL behavior, user's existing setup
- **Mitigations**: Graceful fallbacks, clear errors, documentation

---

## APPENDIX: tmux Quick Reference for New Users

### Basic Concepts

tmux is a **terminal multiplexer** — it lets you:
- Run multiple terminals in one window (split into panes)
- Detach sessions and reattach later (even after SSH disconnects)
- Organize work into named sessions

### Hierarchy

```
tmux server
  └── Session (worktree-myproject-1430)
        └── Window (can have multiple)
              └── Pane (split sections, each runs a program)
```

### Essential Commands (Outside tmux)

```bash
tmux                           # Start new session
tmux new -s mysession          # Start named session
tmux ls                        # List sessions
tmux attach -t mysession       # Attach to session
tmux kill-session -t mysession # Kill session
```

### Essential Key Bindings (Inside tmux, after C-a prefix)

| Action | Keys |
|--------|------|
| Detach | `d` |
| New window | `c` |
| Next window | `n` |
| Previous window | `p` |
| Split horizontal | `\|` |
| Split vertical | `-` |
| Navigate panes | `h/j/k/l` |
| Zoom pane | `z` |
| Kill pane | `x` |
| Reload config | `r` |

### Workflow Example

```bash
# Terminal 1: Start parallel development
/tmux-worktrees feature/auth feature/api

# You're now in tmux with 2 panes, opencode running in each
# Work on features...

# Need to leave? Detach (session keeps running)
# Press: Ctrl+a, then d

# Later, from any terminal:
tmux attach -t worktree-myproject-1430

# Done with features? After merging:
tmux kill-session -t worktree-myproject-1430
git worktree remove worktrees/feature-auth
git worktree remove worktrees/feature-api
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "tmux: command not found" | `apt install tmux` or `brew install tmux` |
| Can't scroll | Mouse is enabled by default, or use `C-a [` for copy mode |
| Weird colors | Ensure `$TERM` is `xterm-256color` before starting tmux |
| Prefix doesn't work | Our config uses `C-a`, not default `C-b` |
| Nested tmux | Script handles this — uses switch-client |

---

## APPENDIX: Full tmux Config Explanation

```bash
# === Terminal Settings ===
set -g default-terminal "tmux-256color"  # Enable 256 colors
set -sa terminal-features ",xterm*:RGB"  # True color support
set -g history-limit 10000               # Scrollback buffer
set -g base-index 1                      # Windows start at 1
setw -g pane-base-index 1                # Panes start at 1
set -g renumber-windows on               # Renumber on close
set -g mouse on                          # Enable mouse
set -sg escape-time 10                   # Faster key response

# === Prefix Key ===
set -g prefix C-a                        # Use Ctrl+a
unbind C-b                               # Unbind default Ctrl+b
bind C-a send-prefix                     # Send C-a with C-a C-a

# === Window/Pane Creation ===
bind c new-window -c "#{pane_current_path}"      # New window in same dir
bind | split-window -h -c "#{pane_current_path}" # Horizontal split
bind - split-window -v -c "#{pane_current_path}" # Vertical split

# === Navigation ===
bind h select-pane -L                    # Left
bind j select-pane -D                    # Down
bind k select-pane -U                    # Up
bind l select-pane -R                    # Right

# === Resizing ===
bind -r H resize-pane -L 5               # Grow left
bind -r J resize-pane -D 5               # Grow down
bind -r K resize-pane -U 5               # Grow up
bind -r L resize-pane -R 5               # Grow right

# === Status Bar ===
set -g status-position bottom
set -g status-left '#[bold] #S '         # Session name
set -g status-right ' %H:%M %d-%b '      # Time and date

# === Appearance ===
set -g pane-active-border-style 'fg=green'

# === Copy Mode ===
setw -g mode-keys vi                     # Vim keys in copy mode

# === Utilities ===
bind r source-file ~/.tmux.conf \; display "Reloaded!"
bind W choose-tree -s -f '#{?#{m:worktree-*,#{session_name}},1,0}'
```

---

## APPENDIX: Integration with Existing Worktree Plugin

If the `opencode-worktree` plugin is installed (`ocx add kdco/worktree`):

### Plugin Behavior

The plugin's `worktree_create` tool:
- Creates worktrees at `~/.local/share/opencode/worktree/<project>/<branch>`
- Automatically syncs files per `.opencode/worktree.jsonc`
- Runs `postCreate` hooks (dependency installation)
- Spawns a new terminal with opencode

### tmux Integration with Plugin

The `/tmux-worktrees` command can detect plugin availability:

1. If plugin available: Use plugin for worktree creation, then create tmux session pointing to plugin paths
2. If plugin not available: Fall back to `git worktree add` with local `./worktrees/` directory

### Hybrid Approach

For users who want plugin benefits + tmux organization:

```bash
# Option A: Use tmux command (manual worktrees + tmux)
/tmux-worktrees feature/a feature/b

# Option B: Use plugin, then organize in tmux manually
# 1. Plugin creates worktrees and spawns terminals
# 2. User manually attaches them to tmux session
```

The shell script handles both cases transparently based on where worktrees exist.
