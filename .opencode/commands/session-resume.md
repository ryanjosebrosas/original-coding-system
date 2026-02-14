---
description: Resume interrupted execution by loading session context
argument-hint: [session-id]
---

# Resume: Session Continuation

Resume interrupted execution by loading session context.

## Usage

```
/session-resume [session-id]
```

If no session-id provided, list available sessions.

---

## Step 1: List Sessions (if no ID)

```bash
ls -lt .tmp/sessions/*/context.md 2>/dev/null | head -10
```

Report: "Found X sessions. Run `/session-resume {id}` to resume."

**If no sessions found**: "No sessions found. Start with `/execute` to create one."

---

## Step 2: Load Session Context

If session-id provided:

1. Read `.tmp/sessions/{session-id}/context.md`
2. Display:
   - Feature name and plan file
   - Current phase (from PIV state if exists)
   - Completed tasks
   - In-progress task
   - Blockers (if any)
3. Ask: "Resume from {in-progress task}?"

---

## Step 3: Resume Execution

If user confirms:
1. Read the plan file
2. Find the in-progress task in step-by-step tasks
3. Continue from that task

---

## Output

```
Session {id} resumed. Continuing from task: {task name}

Feature: {feature}
Plan: {plan-file}
Phase: {phase}
```

---

## Notes

- Sessions are stored in `.tmp/sessions/` which is gitignored
- For long-term persistence, use `/commit` which archives session to memory.md
- Sessions persist until manually deleted or disk cleanup
