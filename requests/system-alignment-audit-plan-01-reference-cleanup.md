# Sub-Plan 01: Reference Cleanup

> **Parent Plan**: `requests/system-alignment-audit-plan-overview.md`
> **Sub-Plan**: 01 of 04
> **Phase**: Reference Cleanup
> **Tasks**: 5
> **Estimated Context Load**: Low

---

## Scope

This sub-plan removes or fixes all dead references across the codebase.

**What this sub-plan delivers**:
- All `scripts/` references removed (directory doesn't exist)
- All stale Claude→OpenCode references fixed
- memory.md stale entries updated
- Template stale references fixed

**Prerequisites**: None (first sub-plan)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `memory.md` — Lines with stale entries to update
- `templates/GITHUB-SETUP-CHECKLIST.md` — Has 6+ stale references
- `.opencode/commands/setup-github-automation.md` — References scripts/ and missing workflows
- `.opencode/commands/quick-github-setup.md` — References scripts/
- `reference/mcp-skills-overview.md` — References .opencode/skills/
- `reference/mcp-skills-archon.md` — References .opencode/skills/

---

## STEP-BY-STEP TASKS

### UPDATE `memory.md`

- **IMPLEMENT**: Fix stale entries:
  1. Line 13: Change "Slimmed CLAUDE.md" → "Slimmed AGENTS.md"
  2. Line 14: Add note "(not yet implemented)" after "3-tier skills architecture"
  3. Line 19: Change "12 commands" → "13 commands" for command-agent integration
- **PATTERN**: Standard markdown edit
- **GOTCHA**: Keep entry format consistent (date prefix)
- **VALIDATE**: `grep -E "(CLAUDE\.md|skills.*architecture|12 commands)" memory.md` returns empty or corrected

### UPDATE `templates/GITHUB-SETUP-CHECKLIST.md`

- **IMPLEMENT**: Replace all "Claude" references with "OpenCode":
  1. `claude-fix-coderabbit.yml` → `opencode-fix-coderabbit.yml`
  2. `claude-fix.yml` → `opencode-fix.yml`
  3. `@claude-create` → `@opencode-create`
  4. `@claude-fix` → `@opencode-fix`
  5. `[claude-fix]` → `[opencode-fix]`
- **PATTERN**: Find and replace
- **GOTCHA**: Check context — some "Claude" may refer to Claude AI, not the workflow name
- **VALIDATE**: `grep -i "claude" templates/GITHUB-SETUP-CHECKLIST.md` returns only Claude AI references (not workflow names)

### UPDATE `.opencode/commands/setup-github-automation.md`

- **IMPLEMENT**: Remove references to non-existent files:
  1. Remove `scripts/setup-codex-secrets.sh` references
  2. Remove `scripts/setup-git-hooks.sh` references
  3. Remove `.github/workflows/multi-agent-fix.yml` references
  4. Remove `.github/workflows/opencode-fix-coderabbit.yml` references (only exists in reference/)
- **PATTERN**: Remove dead path references, keep working content
- **GOTCHA**: Don't break command structure — replace with note or alternative
- **VALIDATE**: `grep -E "(scripts/|multi-agent-fix)" .opencode/commands/setup-github-automation.md` returns empty

### UPDATE `.opencode/commands/quick-github-setup.md`

- **IMPLEMENT**: Remove references to non-existent scripts:
  1. Remove `scripts/setup-codex-secrets.sh` references (lines ~51)
  2. Remove `scripts/setup-git-hooks.sh` references (lines ~87)
- **PATTERN**: Remove dead path references
- **GOTCHA**: Keep command functional — may need to add manual steps instead
- **VALIDATE**: `grep "scripts/" .opencode/commands/quick-github-setup.md` returns empty

### UPDATE `reference/mcp-skills-overview.md` and `reference/mcp-skills-archon.md`

- **IMPLEMENT**: Add clarification that skills are documented pattern, not yet implemented:
  1. Add note at top: "> **Note**: The skills system is a documented pattern. Skills are created on-demand, not pre-populated."
  2. This preserves the documentation without misleading users
- **PATTERN**: Add clarification header
- **GOTCHA**: Don't remove the documentation — it's useful for creating skills when needed
- **VALIDATE**: `head -5 reference/mcp-skills-overview.md` shows clarification note

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# All modified files are valid markdown
wc -l memory.md templates/GITHUB-SETUP-CHECKLIST.md .opencode/commands/setup-github-automation.md .opencode/commands/quick-github-setup.md
```

### Content Verification
```bash
# No dead references remain
grep -r "scripts/" .opencode/commands/ || echo "PASS: No scripts/ references"
grep -i "claude-fix\|claude-create" templates/GITHUB-SETUP-CHECKLIST.md || echo "PASS: No stale Claude workflow names"
```

### Cross-Reference Check
```bash
# memory.md entries accurate
grep "CLAUDE.md" memory.md && echo "FAIL: Stale CLAUDE.md reference" || echo "PASS"
```

---

## SUB-PLAN CHECKLIST

- [ ] Task 1: memory.md updated (3 entries)
- [ ] Task 2: GITHUB-SETUP-CHECKLIST.md Claude→OpenCode
- [ ] Task 3: setup-github-automation.md dead refs removed
- [ ] Task 4: quick-github-setup.md dead refs removed
- [ ] Task 5: Skills docs clarified

---

## HANDOFF NOTES

### Files Modified
- `memory.md` — Stale entries fixed
- `templates/GITHUB-SETUP-CHECKLIST.md` — Claude→OpenCode rename complete
- `.opencode/commands/setup-github-automation.md` — Dead references removed
- `.opencode/commands/quick-github-setup.md` — Dead references removed
- `reference/mcp-skills-overview.md` — Clarification added
- `reference/mcp-skills-archon.md` — Clarification added

### State for Next Sub-Plan
- Dead references removed. Sub-plan 02 will consolidate overlapping commands (quick-github-setup + setup-github-automation).
- The skills system is now documented as "pattern not yet implemented" — sub-plan 04 may revisit this decision.
