# Plan: Optimize /prime Command for Token Efficiency

## Problem Statement

Current `/prime` execution consumed **37,986 tokens (19% of context)** before any work began. This violates the system's own principles:
- memory.md advises "Keep this file under 100 lines. Large files waste context tokens at session start."
- The system was designed around ~2K auto-loaded context, leaving maximum room for implementation

**Impact on PIV Loop:**
- `/prime` (19%) + `/planning` (~10-15%) + `/execute` context = 40-50% consumed before coding starts
- Reduces effective context for implementation by half
- May force unnecessary plan decomposition for medium-complexity features
- Undermines "fresh conversation" benefit

## Root Causes

1. **Command asks for "comprehensive" analysis** — encourages thoroughness over economy
2. **Full git status output** — 53 deleted + 23 modified + 10 untracked = massive output
3. **Full memory.md inclusion** — all sections read instead of top entries
4. **Archon RAG scan** — sources list + search results add ~2K tokens for minimal value during prime
5. **Output format requests tables and full sections** — not optimized for scanning
6. **No token budget guidance** — command doesn't specify target output size

## Solution Design

### Principle: Prime is a Handshake, Not a Deep Dive

Prime should answer: "What project is this? What's the current state? What should I remember?"
It should NOT answer: "What are all the files? What does every reference guide say?"

### Target Token Budget

| Component | Current | Target | Savings |
|-----------|---------|--------|---------|
| Command execution (reads) | ~15K | ~5K | 10K |
| Output report | ~20K | ~3K | 17K |
| **Total** | ~35K | ~8K | **27K (77%)** |

## Tasks

### Task 1: Redesign Output Format (High Impact)
**File**: `.opencode/commands/prime.md` — Output Report section

Replace verbose sections with bullet-only format:
```markdown
## Output Report (Target: <50 lines)

### Quick Summary (3-5 bullets)
- Project type + purpose (1 line)
- Tech stack (1 line)  
- Current branch + uncommitted status (1 line)
- Active development focus (1 line)

### Memory Highlights (top 3 only)
- Most recent key decision
- Most relevant gotcha
- Latest session note

### Ready State
"Context loaded. Ready for [planning|implementation|review]."
```

**Delete these verbose sections:**
- Architecture (full directory purposes)
- Tech Stack (full list with versions)
- Core Principles (redundant — already in AGENTS.md)
- Knowledge Base Context (not needed at prime time)

### Task 2: Slim Git Status Output
**File**: `.opencode/commands/prime.md` — Step 4

Replace:
```
!`git status`
```

With instruction:
```markdown
Check current state:
!`git status --short | head -20`

Report as: "[branch] — X modified, Y untracked, Z deleted" (one line)
If >20 changes, note "... and N more files"
```

### Task 3: Remove Archon RAG from Prime
**File**: `.opencode/commands/prime.md` — Step 5b

Delete entire section "5b. Search Archon Knowledge Base"

**Rationale**: RAG search is valuable during `/planning` when you know what tech you're working with. During prime, it's speculative and wastes tokens. The sources list alone is ~500 tokens.

### Task 4: Limit Memory.md Reading
**File**: `.opencode/commands/prime.md` — Step 5

Replace:
```markdown
read it and include relevant entries in the output report:
- Key decisions that affect current work
- Known gotchas for the project's tech stack
- Architecture patterns established in past sessions
- Recent session notes for continuity
```

With:
```markdown
Scan memory.md and include in output:
- Latest 1-2 key decisions (from ## Key Decisions)
- Top 1-2 gotchas relevant to likely next task (from ## Gotchas)
- Most recent session note (from ## Session Notes)

Do NOT copy full sections — extract only top entries.
```

### Task 5: Remove "Read All Section Files" Instruction
**File**: `.opencode/commands/prime.md` — Step 2

Current behavior reads all 6 section files explicitly. But AGENTS.md already uses `@sections/` includes which auto-load.

Replace:
```markdown
- If `sections/` directory exists, read the section files referenced in AGENTS.md
```

With:
```markdown
- AGENTS.md @-references auto-load sections — do NOT read them separately
```

### Task 6: Skip Reference File Reads
**File**: `.opencode/commands/prime.md` — Step 2

Remove:
```markdown
- Read any architecture documentation
```

Reference guides are on-demand. Prime shouldn't read them.

### Task 7: Add Token Budget Reminder
**File**: `.opencode/commands/prime.md` — top of Output Report section

Add:
```markdown
## Output Report

**Token budget**: Keep output under 50 lines / ~1500 tokens. Prime is a handshake, not a deep dive.
```

### Task 8: Simplify "Identify Key Files" to Conditional
**File**: `.opencode/commands/prime.md` — Step 3

Current instruction reads entry points, configs, models, services — this is expensive for large codebases.

Replace with:
```markdown
### 3. Identify Key Files (Conditional)

For **application codebases**: Note entry points and key config files (don't read unless needed for immediate task).

For **methodology repos** (like this one): Skip — structure is documented in file-structure.md (read on-demand only).
```

## Validation

After implementing, test with:
```bash
# Start fresh conversation
/prime
```

**Success criteria:**
- Total tokens < 10K (ideally ~8K)
- Output fits in one screen (~40-50 lines)
- Still provides enough context to proceed with `/planning`

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Too slim — miss important context | Memory.md top entries + git status summary should catch active work |
| User expects verbose output | Add note in output: "For deeper analysis, read specific reference guides" |
| Different projects need different depth | Conditional logic in Step 3 handles app vs methodology repos |

## Estimated Impact

- **Token savings**: ~27K per session (77% reduction)
- **PIV Loop improvement**: Implementation phase gets 27K more tokens
- **Complexity threshold**: Medium features stay medium (no forced decomposition)

---

**Complexity**: Low (single file edit, 8 small changes)
**Files affected**: 1 (`.opencode/commands/prime.md`)
**Estimated time**: 15-20 minutes
