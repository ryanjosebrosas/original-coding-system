#!/usr/bin/env bash
set -euo pipefail

WORKTREE_BASE="${WORKTREE_BASE:-worktrees}"
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)" 2>/dev/null || echo "project")
SESSION_NAME="worktree-${PROJECT_NAME}-$(date +%H%M)"

[[ $# -eq 0 ]] && { echo "Usage: $0 branch1 [branch2 ...]"; exit 1; }
[[ $# -gt 10 ]] && { echo "Max 10 branches"; exit 1; }
command -v tmux &>/dev/null || { echo "tmux not installed"; exit 1; }
git rev-parse --git-dir &>/dev/null || { echo "Not a git repo"; exit 1; }

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
mkdir -p "$WORKTREE_BASE"

BRANCHES=("$@")
PATHS=()

for branch in "${BRANCHES[@]}"; do
    dir="${branch//\//-}"
    path="${WORKTREE_BASE}/${dir}"
    [[ -d "$path" ]] || git worktree add "$path" -b "$branch" 2>/dev/null || \
                        git worktree add "$path" "$branch"
    PATHS+=("$REPO_ROOT/$path")
done

tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
tmux new-session -d -s "$SESSION_NAME" -c "${PATHS[0]}"
tmux send-keys -t "$SESSION_NAME" "opencode" Enter

for ((i=1; i<${#BRANCHES[@]}; i++)); do
    if [[ ${#BRANCHES[@]} -le 4 ]]; then
        tmux split-window -t "$SESSION_NAME" -h -c "${PATHS[$i]}"
    else
        tmux split-window -t "$SESSION_NAME" -c "${PATHS[$i]}"
    fi
    tmux send-keys "opencode" Enter
done

[[ ${#BRANCHES[@]} -le 4 ]] && tmux select-layout -t "$SESSION_NAME" even-horizontal \
                            || tmux select-layout -t "$SESSION_NAME" tiled
tmux select-pane -t "$SESSION_NAME:1.0"

echo "Session: $SESSION_NAME"
echo "Detach: Ctrl+a, d | Reattach: tmux attach -t $SESSION_NAME"
[[ -z "${TMUX:-}" ]] && tmux attach-session -t "$SESSION_NAME" \
                     || tmux switch-client -t "$SESSION_NAME"
