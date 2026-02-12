# Agent Handoff Protocol

> **Load when**: Designing subagent outputs, debugging agent chains, standardizing multi-agent communication.

---

## When to Use Handoffs

**Use standardized handoffs when:**
- Subagent returns results to calling agent
- Multi-agent workflow passes context between stages
- Specialist provides domain analysis
- Code review agents report findings

**Skip handoffs for:**
- Direct execution by main agent
- Simple file reads (Read/Glob/Grep)
- Single-purpose commands without chaining

---

## Standard Handoff Format

Every subagent output MUST include these 5 sections in order:

### 1. Mission Echo

```markdown
## Mission Understanding
I understood my task as: {restate the mission in your own words}
Scope: {what's included and excluded}
```

**Why**: Debugging tool — if the agent misunderstood, the prompt needs clarification.

### 2. Context Analyzed

```markdown
## Context Analyzed
- Files reviewed: {count}
- Lines examined: {approximate count}
- Scope: {what was included/excluded}
```

### 3. Findings

```markdown
## Findings

**[Critical] {Category} — `{file}:{line}`**
- **Issue**: {one-line description}
- **Evidence**: `{code snippet}`
- **Suggested Fix**: {how to resolve}

**[Major] {Category} — `{file}:{line}`**
- **Issue**: {description}
- **Evidence**: `{code snippet}`
- **Suggested Fix**: {how to resolve}

**[Minor] {Category} — `{file}:{line}`**
- **Issue**: {description}
- **Suggested Fix**: {how to resolve}
```

### 4. Summary

```markdown
## Summary
- **Total findings**: X (Critical: Y, Major: Z, Minor: W)
- **Files with issues**: {count}
- **Overall assessment**: {Pass | Needs fixes | Blocked}
```

### 5. Recommendations

```markdown
## Recommendations
1. **[P0]** {highest priority action} — {effort/impact}
2. **[P1]** {next priority} — {effort/impact}
3. **[P2]** {optional improvement} — {effort/impact}
```

---

## Severity Classification

| Severity | Definition | Action Required | Examples |
|----------|------------|-----------------|----------|
| **Critical** | Blocks commit — security, data loss, broken build | Must fix before proceeding | SQL injection, exposed secrets, syntax errors |
| **Major** | Should fix — logic errors, pattern violations | Fix before commit | Missing error handling, wrong return type |
| **Minor** | Optional fix — style, naming, documentation | Fix if time permits | Inconsistent naming, missing comments |
| **Info** | Observation only — no action needed | Note for future | Potential optimization, alternative approach |

---

## Calling Agent Instructions

Every agent MUST end with a control instruction:

```markdown
---
When done, instruct the calling agent to {specific action}.
Do NOT {prohibited action} without user approval.
```

### Common Patterns

| Agent Type | Instruction |
|------------|-------------|
| **Code Reviewer** | "...present findings to user and await decision on which to fix" |
| **Build Validator** | "...fix errors if Critical, otherwise proceed" |
| **Research Agent** | "...use findings to inform implementation, verify accuracy" |
| **Task Manager** | "...execute batch 1 tasks using BatchExecutor" |
| **Coder Agent** | "...validate changes and proceed to next task" |

---

## Error Handling

### Partial Completion

```markdown
## Status: Partial — {X} of {Y} tasks completed

### Completed
- {task 1 description}
- {task 2 description}

### Failed At
- **Task**: {description}
- **Error**: {message}
- **State**: {what was left incomplete}

### Recommendation
{retry | skip and continue | abort}
```

### Complete Failure

```markdown
## Status: Failed

### Last Successful Step
{description of last successful action}

### Error
- **Type**: {error type}
- **Message**: {error message}
- **Location**: {file:line if applicable}

### Recommendation
{fix and retry | escalate to user | abort}
```

---

## Example: Complete Handoff

```markdown
## Mission Understanding
I understood my task as: Review authentication module for security vulnerabilities.
Scope: `src/auth/` directory, excluding test files.

## Context Analyzed
- Files reviewed: 5
- Lines examined: ~450
- Scope: auth routes, middleware, JWT handling

## Findings

**[Critical] Security — `src/auth/login.py:45`**
- **Issue**: Password compared using `==` instead of constant-time comparison
- **Evidence**: `if password == stored_hash:`
- **Suggested Fix**: Use `secrets.compare_digest()` or bcrypt's built-in compare

**[Major] Security — `src/auth/jwt.py:23`**
- **Issue**: JWT secret loaded from environment without validation
- **Evidence**: `SECRET = os.getenv("JWT_SECRET")`
- **Suggested Fix**: Add `or raise ValueError("JWT_SECRET required")`

**[Minor] Security — `src/auth/middleware.py:12`**
- **Issue**: Verbose error message exposes internal path
- **Suggested Fix**: Return generic "Authentication failed" message

## Summary
- **Total findings**: 3 (Critical: 1, Major: 1, Minor: 1)
- **Files with issues**: 3
- **Overall assessment**: Blocked — 1 critical security issue

## Recommendations
1. **[P0]** Fix timing attack vulnerability in password comparison — Low effort, High impact
2. **[P1]** Add JWT_SECRET validation — Low effort, Medium impact
3. **[P2]** Sanitize error messages — Low effort, Low impact

---
When done, instruct the calling agent to present these findings to the user.
Do NOT auto-fix the critical issue without user approval — security changes need review.
```

---

## Integration with Session Context

When a session context exists (`.tmp/sessions/{id}/context.md`):

1. **Read session** at start of handoff
2. **Update Progress Tracking** with current status
3. **Include session ID** in handoff header
4. **Pass session path** to next agent in chain

This enables multi-agent workflows to maintain shared state across handoffs.

---

## Quick Reference

```
Handoff Structure:
1. Mission Echo — what I understood
2. Context Analyzed — what I reviewed
3. Findings — what I found (severity + location + fix)
4. Summary — totals and assessment
5. Recommendations — prioritized actions
6. Control Instruction — what calling agent should do
```
