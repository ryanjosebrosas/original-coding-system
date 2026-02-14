# PIV State Template

> Store at `.tmp/piv-state.json`. Created by `/planning`, updated by `/execute`,
> consumed by `/code-review` and `/commit`. Deleted after `/commit` completes.

```json
{
  "feature_name": "string",
  "plan_file": "requests/{feature}-plan.md",
  "session_id": "string (from execute)",
  "archon_project_id": "string or null",
  "phase": "planning|executing|validating|committing",
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "acceptance_criteria_met": ["list of met criteria"],
  "acceptance_criteria_pending": ["list of pending criteria"],
  "notes": "any cross-command notes"
}
```

---

## Usage

| Command | Action |
|---------|--------|
| `/planning` | Create file after plan saved |
| `/execute` | Update `phase` to "executing", add `session_id` |
| `/execution-report` | Read file for context |
| `/code-review` | Read file for feature name and plan path |
| `/code-review-fix` | Read file, update `notes` with skipped issues |
| `/commit` | Read file, verify criteria met, delete file |

---

## Phase Transitions

```
planning → executing → validating → committing → (deleted)
     ↑           ↑           ↑            ↑
  /planning   /execute   /code-review   /commit
```

---

## Example

```json
{
  "feature_name": "user-authentication",
  "plan_file": "requests/user-authentication-plan.md",
  "session_id": "user-auth-20260215-1200",
  "archon_project_id": null,
  "phase": "executing",
  "started_at": "2026-02-15T12:00:00Z",
  "updated_at": "2026-02-15T12:30:00Z",
  "acceptance_criteria_met": [
    "User model created",
    "Registration endpoint works"
  ],
  "acceptance_criteria_pending": [
    "Login returns valid JWT",
    "Protected routes reject invalid tokens"
  ],
  "notes": ""
}
```
