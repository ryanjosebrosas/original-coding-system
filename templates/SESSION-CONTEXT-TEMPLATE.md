# Session Context Template

> Use for complex multi-agent workflows (4+ files). Created by `/execute`, consumed by subagents.
> Keep under 100 lines to minimize token overhead at agent startup.

---

## Session Metadata

- **Session ID**: {feature-name}-{YYYYMMDD-HHMM}
- **Created**: {timestamp}
- **Parent Command**: /execute requests/{feature}-plan.md
- **Archon Project ID**: {project_id or "N/A"}

## Session Status

- **Status**: [initializing | active | paused | completed | archived]
- **Last Updated**: {timestamp}

### Lifecycle

1. `initializing` → Session created
2. `active` → Execution in progress
3. `paused` → Execution interrupted (user stopped, error)
4. `completed` → All tasks done, awaiting commit
5. `archived` → Session archived to memory.md

Commands update status:
- `/execute` creates at `initializing`, sets `active` when running
- `/execution-report` sets `paused` if incomplete
- `/commit` sets `archived` after archiving

---

## Objective

### Original Request
{Copy from plan's Feature Description — what are we building?}

### Target Outcome
{What "done" looks like — measurable, specific}

### Exit Criteria
- [ ] {Criterion 1 from plan's Acceptance Criteria}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

---

## Context Files

> Standards the agent MUST follow. Read before implementing.

- `AGENTS.md` — Project conventions and rules
- `{path/to/file}` — {Why relevant}
- `{path/to/file}` — {Why relevant}

---

## Reference Files

> Existing code to reference for patterns. Include line ranges.

- `{path/to/file}` (lines X-Y) — {Pattern to mirror}
- `{path/to/file}` (lines X-Y) — {Naming convention to follow}

---

## Archon Integration

- **Project ID**: {project_id}
- **Current Task**: {task_id} — {task_title}
- **Task Queue**: 
  - [ ] {task_id}: {title} (todo)
  - [ ] {task_id}: {title} (todo)

---

## Progress Tracking

### Completed
- (none yet)

### In Progress
- {current task description}

### Remaining
- {next task}
- {following task}

### Blockers
- None

---

## Example (Filled)

```markdown
## Session Metadata
- **Session ID**: user-auth-20260213-1430
- **Created**: 2026-02-13 14:30 UTC
- **Parent Command**: /execute requests/user-auth-plan.md
- **Archon Project ID**: 75d85d61-6ac8-4bcb-8660-b13ae1d4a8d8

## Objective
### Original Request
Implement user authentication with JWT tokens and session management.

### Target Outcome
Users can register, login, and access protected routes with valid JWT.

### Exit Criteria
- [ ] Registration endpoint works
- [ ] Login returns valid JWT
- [ ] Protected routes reject invalid tokens
- [ ] Tests pass

## Context Files
- `AGENTS.md` — Project conventions
- `reference/validation-strategy.md` — Testing requirements

## Reference Files
- `src/routes/health.py` (lines 1-25) — Route handler pattern
- `src/models/base.py` (lines 1-50) — Model structure

## Archon Integration
- **Project ID**: 75d85d61-6ac8-4bcb-8660-b13ae1d4a8d8
- **Current Task**: task-001 — Create User model
- **Task Queue**:
  - [x] task-001: Create User model (done)
  - [ ] task-002: Create auth routes (doing)
  - [ ] task-003: Add JWT middleware (todo)

## Progress Tracking
### Completed
- Created User model — 2026-02-13 14:35

### In Progress
- Implementing auth routes

### Remaining
- Add JWT middleware
- Write tests

### Blockers
- None
```
