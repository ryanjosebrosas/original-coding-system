---
description: Prime agent with codebase understanding
---

# Prime: Load Project Context

## Objective

Quick handshake with codebase — understand project type, current state, and memory context. NOT a deep dive.

## Process

### 1. Analyze Project Structure

List all tracked files:
!`git ls-files`

### 2. Read Core Documentation

- Read project rules: @AGENTS.md (sections/ auto-load via @-references — do NOT read separately)
- Read README.md at project root only

### 3. Identify Key Files (Conditional)

**Application codebases**: Note entry points and config files (package.json, pyproject.toml, etc.) — don't read unless needed for immediate task.

**Methodology/config repos**: Skip — structure is documented in reference guides (load on-demand).

### 4. Understand Current State

Check recent activity:
!`git log -5 --oneline`

Check current state (slim):
!`git status --short | head -20`

Report as: "[branch] — X modified, Y untracked, Z deleted" (one line)
If >20 changes, note "... and N more files"

### 5. Read Project Memory (if memory.md exists)

If `memory.md` exists at project root, scan it and extract for output:
- Latest 1-2 key decisions (from ## Key Decisions)
- Top 1-2 gotchas relevant to likely next task (from ## Gotchas)
- Most recent session note (from ## Session Notes)

Do NOT copy full sections — extract only top entries.

## Output Report

**Token budget**: Keep output under 50 lines / ~1500 tokens. Prime is a handshake, not a deep dive.

### Quick Summary (3-5 bullets)
- Project type + purpose (1 line)
- Tech stack (1 line)
- Current branch + uncommitted status (1 line)
- Active development focus (1 line)

### Memory Highlights (top 3 only)
- Most recent key decision
- Most relevant gotcha for likely next task
- Latest session note

(If no memory.md found, note "No memory.md — consider `templates/MEMORY-TEMPLATE.md`")

### Ready State

"Context loaded. Ready for [planning|implementation|review]."

For deeper analysis, read specific reference guides on-demand.
