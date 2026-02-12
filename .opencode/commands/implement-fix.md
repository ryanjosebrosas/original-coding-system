---
description: Implement fix from RCA document for GitHub issue
argument-hint: [github-issue-id]
---

# Implement Fix: GitHub Issue #$ARGUMENTS

## Prerequisites

**This command implements fixes based on RCA documents:**
- RCA document exists at `docs/rca/issue-$ARGUMENTS.md`
- If it doesn't exist, run `/rca $ARGUMENTS` first

## RCA Document to Reference

Read RCA: `docs/rca/issue-$ARGUMENTS.md`

## Implementation Instructions

### 0.5. Agent-Assisted Context Discovery (Optional)

**If ContextScout available** (`ls .opencode/agents/subagent-contextscout.md`):
- Launch `@subagent-contextscout` to discover project standards relevant to the fix
- Query: "coding patterns for {affected component from RCA}"
- This ensures the fix follows established patterns, not just resolves the symptom

**If agent not available**: Skip — proceed to read RCA document.

### 1. Read and Understand RCA

- Read the ENTIRE RCA document thoroughly
- Understand the root cause
- Review the proposed fix strategy
- Note all files to modify
- Review testing requirements

### 2. Verify Current State

Before making changes:
- Confirm the issue still exists
- Check current state of affected files
- Review any recent changes to those files

### 3. Implement the Fix

Following the "Proposed Fix" section of the RCA:

**For each file to modify:**

#### a. Read the existing file
- Understand current implementation
- Locate specific code mentioned in RCA

#### b. Make the fix
- Implement the change as described in RCA
- Follow the fix strategy exactly
- Maintain code style and conventions
- Add comments if the fix is non-obvious

#### c. Handle related changes
- Update any related code affected by the fix
- Ensure consistency across the codebase
- Update imports if needed

### 4. Add/Update Tests

Following the "Testing Requirements" from the RCA:

**Create test cases for:**
1. Verify the fix resolves the issue
2. Test edge cases related to the bug
3. Ensure no regression in related functionality

### 5. Run Validation

Execute validation commands from the RCA.

**If validation fails:**
- Fix the issues
- Re-run validation
- Don't proceed until all pass

### 5.5. Agent-Assisted Build Validation (Optional)

**If BuildAgent available** (`ls .opencode/agents/subagent-buildagent.md`):
- Launch `@subagent-buildagent` for comprehensive validation beyond project defaults
- BuildAgent runs: lint → typecheck → build (in pyramid order)
- Review any issues found — BuildAgent reports but doesn't fix

**If agent not available**: Skip — rely on validation commands from RCA.

### 6. Verify Fix

**Manually verify:**
- Follow reproduction steps from RCA
- Confirm the issue no longer occurs
- Check for unintended side effects

### 7. Update Documentation

If needed:
- Update code comments
- Update API documentation
- Update README if user-facing
- Add notes about the fix

## Output Report

### Fix Implementation Summary

**GitHub Issue #$ARGUMENTS**: [Brief title]

### Changes Made

**Files Modified:**
1. **[file-path]** - Change: [What was changed]

### Tests Added

**Test Files Created/Modified:**
1. **[test-file-path]** - Test cases: [List test functions added]

### Validation Results

```bash
# Show validation output
```

### Ready for Commit

All changes complete and validated. Ready for:
```bash
/commit
```

**Suggested commit message:**
```
fix(scope): resolve GitHub issue #$ARGUMENTS - [brief description]

[Summary of what was fixed and how]

Fixes #$ARGUMENTS
```

**Note:** Using `Fixes #$ARGUMENTS` in the commit message will automatically close the GitHub issue when merged.

### Optional: Update GitHub Issue

**Add implementation comment to the issue:**
```bash
gh issue comment $ARGUMENTS --body "Fix implemented in commit [commit-hash]. Ready for review."
```

**Update issue labels (if needed):**
```bash
gh issue edit $ARGUMENTS --add-label "fixed" --remove-label "bug"
```

**Close the issue (if not using auto-close via commit message):**
```bash
gh issue close $ARGUMENTS --comment "Fixed and merged."
```

## Notes

- If the RCA document is missing or incomplete, request it be created first with `/rca $ARGUMENTS`
- If you discover the RCA analysis was incorrect, document findings and update the RCA
- If additional issues are found during implementation, note them for separate GitHub issues
- Follow project coding standards exactly
- Ensure all validation passes before declaring complete
