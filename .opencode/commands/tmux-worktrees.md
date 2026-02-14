---
description: Create git worktrees in tmux panes for parallel development
argument-hint: [branch1] [branch2] ... [branchN] (1-10 branches)
---

# tmux Worktrees

Create worktrees with tmux session management for organized parallel development.

---

## INPUT

**Branches**: $ARGUMENTS (1-10 branch names)

**Examples**:
```
/tmux-worktrees feature/search
/tmux-worktrees feature/search feature/export feature/reports
```

**Prerequisites**:
- tmux installed (`tmux -V`)
- Inside a git repository
- Branches can be new or existing

---

## PROCESS

### Step 1: Validate Arguments

```bash
BRANCHES=($ARGUMENTS)
COUNT=${#BRANCHES[@]}

if [ $COUNT -lt 1 ] || [ $COUNT -gt 10 ]; then
  echo "❌ Error: Provide 1-10 branch names"
  echo "Usage: /tmux-worktrees branch1 branch2 ..."
  exit 1
fi

echo "📋 Creating $COUNT worktrees: ${BRANCHES[*]}"
```

### Step 2: Verify Environment

```bash
# Check tmux
if ! command -v tmux &> /dev/null; then
  echo "❌ tmux not installed"
  echo "Install: brew install tmux (macOS) or apt install tmux (Linux)"
  exit 1
fi

# Check git repo
if [ ! -d ".git" ]; then
  echo "❌ Not in a git repository"
  exit 1
fi

PROJECT=$(basename $(git rev-parse --show-toplevel))
SESSION="worktree-${PROJECT}-$(date +%H%M)"
```

### Step 3: Create Worktrees

```bash
mkdir -p worktrees

for BRANCH in "${BRANCHES[@]}"; do
  WORKTREE_PATH="worktrees/${BRANCH}"
  
  if [ -d "$WORKTREE_PATH" ]; then
    echo "⚠️  Worktree exists: $WORKTREE_PATH"
    continue
  fi
  
  if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git worktree add "$WORKTREE_PATH" "$BRANCH"
    echo "✅ Added existing branch: $BRANCH"
  else
    git worktree add -b "$BRANCH" "$WORKTREE_PATH"
    echo "✅ Created new branch: $BRANCH"
  fi
done
```

### Step 4: Create tmux Session

```bash
tmux new-session -d -s "$SESSION" -c "worktrees/${BRANCHES[0]}"

# Add panes for remaining worktrees
for i in "${!BRANCHES[@]}"; do
  if [ $i -eq 0 ]; then continue; fi
  
  if [ ${#BRANCHES[@]} -le 4 ]; then
    tmux split-window -h -t "$SESSION" -c "worktrees/${BRANCHES[$i]}"
  else
    tmux split-window -t "$SESSION" -c "worktrees/${BRANCHES[$i]}"
  fi
done

# Set layout
if [ ${#BRANCHES[@]} -ge 5 ]; then
  tmux select-layout -t "$SESSION" tiled
fi

# Launch opencode in each pane
for i in "${!BRANCHES[@]}"; do
  tmux send-keys -t "$SESSION:$i" "cd worktrees/${BRANCHES[$i]} && opencode" Enter
done
```

### Step 5: Attach

```bash
tmux attach -t "$SESSION"
```

---

## OUTPUT

```
✅ tmux Worktrees Created

Session: worktree-{project}-{HHMM}
Branches: {count}

Worktrees:
  worktrees/{branch1} → tmux pane 0
  worktrees/{branch2} → tmux pane 1
  ...

tmux Quick Reference:
  Detach:     Ctrl+a, d
  Navigate:   Ctrl+a, ←/→ (or o for next)
  Reattach:   tmux attach -t {session}
  Kill:       tmux kill-session -t {session}
  List:       tmux ls

Cleanup when done:
  git worktree remove worktrees/{branch}
```

---

## VALIDATION

- ✅ tmux session created (`tmux ls | grep worktree`)
- ✅ Worktree directories exist (`ls worktrees/`)
- ✅ opencode running in each pane

---

## ERROR HANDLING

**Branch already checked out elsewhere:**
```
❌ Branch '{branch}' is already checked out at '{path}'
Solution: git worktree remove {path} first, or use a different branch name
```

**tmux session exists:**
```
❌ Session '{session}' already exists
Solution: tmux kill-session -t {session} or tmux attach -t {session}
```

---

## NOTES

- Layout: 2-4 branches = horizontal split, 5+ = tiled
- Session persists after detach — reattach anytime
- Cleanup: `git worktree remove worktrees/{branch}` when done
- See `reference/tmux-integration.md` for advanced configuration
