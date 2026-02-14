# Sub-Plan 02: Template Completeness

> **Parent Plan**: `requests/system-alignment-plan-overview.md`
> **Sub-Plan**: 2 of 4
> **Phase**: Template Completeness
> **Tasks**: 6
> **Estimated Context Load**: Low

---

## Scope

This sub-plan creates missing templates and updates commands to use them instead of hardcoded formats.

**What this sub-plan delivers**:
- All referenced templates exist (including .coderabbit.yaml)
- 4 new templates for commands that hardcode output formats
- Commands updated to reference templates

**Prerequisites from previous sub-plans**:
- Sub-plan 01: reference/file-structure.md now lists all templates

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `.opencode/commands/rca.md` (lines 111-192) — Hardcoded RCA format
- `.opencode/commands/code-review.md` (lines 62-90) — Hardcoded review format
- `.opencode/commands/create-pr.md` (lines 63-80) — Hardcoded PR format
- `.opencode/commands/system-review.md` (lines 112-163) — Hardcoded review format
- `.opencode/commands/execution-report.md` (lines 31-84) — Hardcoded report format
- `templates/VALIDATION-REPORT-TEMPLATE.md` — Exists but unused

### Audit Findings to Address

| Issue | Location | Fix |
|-------|----------|-----|
| MISSING | /setup-github-automation:157 | Create templates/.coderabbit.yaml |
| HARDCODED | /rca:111-192 (82 lines) | Create RCA-TEMPLATE.md |
| HARDCODED | /code-review:62-90 (29 lines) | Create CODE-REVIEW-TEMPLATE.md |
| HARDCODED | /create-pr:63-80 (18 lines) | Create PR-DESCRIPTION-TEMPLATE.md |
| HARDCODED | /system-review:112-163 (52 lines) | Create SYSTEM-REVIEW-TEMPLATE.md |
| UNUSED | VALIDATION-REPORT-TEMPLATE.md | Reference from /execution-report |

---

## STEP-BY-STEP TASKS

### CREATE `templates/RCA-TEMPLATE.md`

- **IMPLEMENT**: Extract RCA format from `/rca:111-192` into template:
  ```markdown
  # Root Cause Analysis: {Issue Title}
  
  > **Date**: {YYYY-MM-DD}
  > **Severity**: Critical / High / Medium / Low
  > **Status**: Investigating / Identified / Fixing / Resolved
  
  ---
  
  ## Issue Summary
  
  {Brief description of the issue and its impact}
  
  ## Problem Description
  
  {Detailed explanation of what went wrong}
  
  ## Reproduction Steps
  
  1. {Step 1}
  2. {Step 2}
  3. {Step 3}
  
  ## Root Cause
  
  {Technical explanation of why this happened}
  
  ## Impact Assessment
  
  - **Users Affected**: {count or description}
  - **Systems Affected**: {list}
  - **Data Impact**: {description}
  
  ## Proposed Fix
  
  {Description of the fix approach}
  
  ## Prevention
  
  {How to prevent this in the future}
  
  ## Next Steps
  
  - [ ] {Action 1}
  - [ ] {Action 2}
  ```
- **PATTERN**: Follow existing template structure (SCREAMING-SNAKE-CASE.md)
- **IMPORTS**: N/A
- **GOTCHA**: Keep placeholders clear for AI to fill
- **VALIDATE**: `ls templates/RCA-TEMPLATE.md`

### CREATE `templates/CODE-REVIEW-TEMPLATE.md`

- **IMPLEMENT**: Extract format from `/code-review:62-90`:
  ```markdown
  # Code Review: {Feature Name}
  
  > **Date**: {YYYY-MM-DD}
  > **Reviewer**: AI Code Review
  > **Files Changed**: {count}
  
  ---
  
  ## Review Summary
  
  {Overall assessment of the code changes}
  
  ## Findings by Severity
  
  ### Critical
  - `file:line` — {issue} — Fix: {recommendation}
  
  ### High
  - `file:line` — {issue} — Fix: {recommendation}
  
  ### Medium
  - `file:line` — {issue} — Fix: {recommendation}
  
  ### Low / Suggestions
  - `file:line` — {suggestion}
  
  ## Security Alerts
  
  - {Any security concerns found}
  
  ## Summary Assessment
  
  - **Overall Quality**: Excellent / Good / Needs Work / Critical Issues
  - **Ready for Merge**: Yes / No / With Minor Fixes
  - **Recommended Actions**: {list}
  ```
- **PATTERN**: Same structure as Task 01
- **IMPORTS**: N/A
- **GOTCHA**: Severity levels must match code-review.md output
- **VALIDATE**: `ls templates/CODE-REVIEW-TEMPLATE.md`

### CREATE `templates/PR-DESCRIPTION-TEMPLATE.md`

- **IMPLEMENT**: Extract format from `/create-pr:63-80`:
  ```markdown
  # {PR Title}
  
  ## Summary
  
  {1-3 bullet points summarizing the change}
  
  ## Changes
  
  - {Change 1}
  - {Change 2}
  
  ## Test Plan
  
  - [ ] {Test step 1}
  - [ ] {Test step 2}
  
  ## Related Issues
  
  - Closes #{issue number}
  - Related to #{issue number}
  ```
- **PATTERN**: Minimal structure for quick PRs
- **IMPORTS**: N/A
- **GOTCHA**: Used by both /create-pr and /end-to-end-feature
- **VALIDATE**: `ls templates/PR-DESCRIPTION-TEMPLATE.md`

### CREATE `templates/SYSTEM-REVIEW-TEMPLATE.md`

- **IMPLEMENT**: Extract format from `/system-review:112-163`:
  ```markdown
  # System Review: {Feature Name}
  
  > **Plan**: `requests/{feature}-plan.md`
  > **Execution Report**: `requests/execution-reports/{feature}-report.md`
  > **Date**: {YYYY-MM-DD}
  
  ---
  
  ## Alignment Score
  
  | Dimension | Score | Notes |
  |-----------|-------|-------|
  | Plan Adherence | X/10 | {notes} |
  | Pattern Compliance | X/10 | {notes} |
  | Code Quality | X/10 | {notes} |
  | Documentation | X/10 | {notes} |
  
  ## Divergence Analysis
  
  {Where implementation deviated from plan and why}
  
  ## Pattern Compliance
  
  - **Followed**: {patterns correctly applied}
  - **Violated**: {patterns not followed}
  
  ## System Improvement Actions
  
  - [ ] {Action 1}
  - [ ] {Action 2}
  
  ## Recommendations
  
  {Process or system improvements}
  ```
- **PATTERN**: Include reference to META-REASONING-CHECKLIST
- **IMPORTS**: N/A
- **GOTCHA**: This is meta-level review, not code review
- **VALIDATE**: `ls templates/SYSTEM-REVIEW-TEMPLATE.md`

### CREATE `templates/.coderabbit.yaml`

- **IMPLEMENT**: Create CodeRabbit configuration template:
  ```yaml
  # CodeRabbit Configuration
  # Generated by /setup-github-automation or /quick-github-setup
  
  language: en-US
  
  reviews:
    profile: chill  # Options: chill, assertive
  
    auto_review:
      enabled: true
      base_branches:
        - main
        - master
  
    poem: false
  
  chat:
    auto_reply: true
  
  # Customize review rules as needed
  # See: https://coderabbit.ai/docs/configuration
  ```
- **PATTERN**: Minimal config that works out of box
- **IMPORTS**: N/A
- **GOTCHA**: This is a YAML file, not markdown
- **VALIDATE**: `ls templates/.coderabbit.yaml`

### UPDATE Commands to Reference Templates

- **IMPLEMENT**: Update commands to reference templates instead of hardcoding:
  
  In `.opencode/commands/rca.md` (around line 111):
  - Add: `> Output format: templates/RCA-TEMPLATE.md`
  - Keep brief inline summary, reference template for full structure
  
  In `.opencode/commands/code-review.md` (around line 62):
  - Add: `> Output format: templates/CODE-REVIEW-TEMPLATE.md`
  
  In `.opencode/commands/create-pr.md` (around line 63):
  - Add: `> PR description format: templates/PR-DESCRIPTION-TEMPLATE.md`
  
  In `.opencode/commands/system-review.md` (around line 112):
  - Add: `> Output format: templates/SYSTEM-REVIEW-TEMPLATE.md`
  - Add reference: `Reference: templates/META-REASONING-CHECKLIST.md for analysis prompts`
  
  In `.opencode/commands/execution-report.md` (around line 31):
  - Add: `> Output format: templates/VALIDATION-REPORT-TEMPLATE.md`
  
  In `.opencode/commands/end-to-end-feature.md` (around line 111):
  - Update PR step to reference: `templates/PR-DESCRIPTION-TEMPLATE.md`
- **PATTERN**: Add template reference at start of output section
- **IMPORTS**: N/A
- **GOTCHA**: Don't remove all inline guidance — keep essential structure visible
- **VALIDATE**: `grep -l "templates/RCA-TEMPLATE" .opencode/commands/*.md`

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# Verify all templates created
ls templates/RCA-TEMPLATE.md templates/CODE-REVIEW-TEMPLATE.md \
   templates/PR-DESCRIPTION-TEMPLATE.md templates/SYSTEM-REVIEW-TEMPLATE.md \
   templates/.coderabbit.yaml

# Count should now be 24 templates
ls templates/*.md templates/*.yaml 2>/dev/null | wc -l
```

### Content Verification
```bash
# Verify template references in commands
grep -c "RCA-TEMPLATE" .opencode/commands/rca.md
grep -c "CODE-REVIEW-TEMPLATE" .opencode/commands/code-review.md
grep -c "PR-DESCRIPTION-TEMPLATE" .opencode/commands/create-pr.md
```

### Cross-Reference Check
```bash
# Verify VALIDATION-REPORT-TEMPLATE now referenced
grep -l "VALIDATION-REPORT-TEMPLATE" .opencode/commands/*.md
```

---

## SUB-PLAN CHECKLIST

- [x] Task 01: RCA-TEMPLATE.md created
- [x] Task 02: CODE-REVIEW-TEMPLATE.md created
- [x] Task 03: PR-DESCRIPTION-TEMPLATE.md created
- [x] Task 04: SYSTEM-REVIEW-TEMPLATE.md created
- [x] Task 05: .coderabbit.yaml created
- [x] Task 06: Commands updated to reference templates
- [x] All validation commands pass

---

## HANDOFF NOTES

### Files Created
- `templates/RCA-TEMPLATE.md` — RCA document structure
- `templates/CODE-REVIEW-TEMPLATE.md` — Code review output format
- `templates/PR-DESCRIPTION-TEMPLATE.md` — PR description format
- `templates/SYSTEM-REVIEW-TEMPLATE.md` — System review format
- `templates/.coderabbit.yaml` — CodeRabbit configuration template

### Files Modified
- `.opencode/commands/rca.md` — Added template reference
- `.opencode/commands/code-review.md` — Added template reference
- `.opencode/commands/create-pr.md` — Added template reference
- `.opencode/commands/system-review.md` — Added template reference
- `.opencode/commands/execution-report.md` — Added template reference
- `.opencode/commands/end-to-end-feature.md` — Updated PR step

### Patterns Established
- Commands now reference templates instead of hardcoding formats
- Template reference pattern: `> Output format: templates/{TEMPLATE}.md`

### State for Next Sub-Plan
- Sub-plan 03 will integrate agents with commands
- Templates are ready for agent integration (some agents reference templates)
