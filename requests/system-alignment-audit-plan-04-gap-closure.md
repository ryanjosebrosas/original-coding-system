# Sub-Plan 04: Gap Closure

> **Parent Plan**: `requests/system-alignment-audit-plan-overview.md`
> **Sub-Plan**: 04 of 04
> **Phase**: Gap Closure
> **Tasks**: 5
> **Estimated Context Load**: Low

---

## Scope

This sub-plan makes final decisions on documented-but-not-implemented features and verifies system integrity.

**What this sub-plan delivers**:
- Final decision on skills system (document or remove)
- Final decision on missing GitHub workflows
- Final verification pass
- memory.md lesson learned entry

**Prerequisites from sub-plan 03**:
- All counts accurate
- All references fixed

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `reference/mcp-skills-overview.md` — Skills documentation (clarified in sub-plan 01)
- `reference/github-workflows/README.md` — Workflow documentation
- `reference/github-integration.md` — May reference missing workflows
- `memory.md` — To add lesson learned

---

## STEP-BY-STEP TASKS

### DECIDE: Skills System

- **IMPLEMENT**: Skills were clarified in sub-plan 01 as "documented pattern, not yet implemented".
  - **Decision**: KEEP documentation, add memory.md entry noting this is intentional
  - No changes needed to reference/mcp-skills-overview.md or reference/mcp-skills-archon.md
- **PATTERN**: Document decision in memory.md
- **GOTCHA**: Don't create .opencode/skills/ directory — adds unused infrastructure
- **VALIDATE**: Decision documented

### DECIDE: Missing GitHub Workflows

- **IMPLEMENT**: Check if these are still referenced:
  - `.github/workflows/opencode-fix-coderabbit.yml` — exists in reference/github-workflows/ but not .github/workflows/
  - **Decision**: Move from reference/ to .github/workflows/ OR remove references
  - Check `reference/github-integration.md` and `reference/github-workflows/README.md` for references
- **PATTERN**: Either copy file or remove reference
- **GOTCHA**: .github/workflows/ may be intentionally minimal (only essential workflows)
- **VALIDATE**: No references to non-existent workflow files

### VERIFY: All Dead References Removed

- **IMPLEMENT**: Final sweep for any remaining dead references:
  1. Search for `scripts/` in all .md files
  2. Search for `.opencode/skills/` references
  3. Search for any paths that don't exist
- **PATTERN**: `grep -r "scripts/\|.opencode/skills/" --include="*.md" .`
- **GOTCHA**: Some references may be in code blocks as examples
- **VALIDATE**: All path references point to existing files or are clearly examples

### VERIFY: Command Template Compliance

- **IMPLEMENT**: Quick check that all commands have basic structure:
  1. Each .md file in .opencode/commands/ has frontmatter or INPUT/PROCESS/OUTPUT
  2. No extremely short commands (<30 lines without good reason)
- **PATTERN**: `wc -l .opencode/commands/*.md | sort -n`
- **GOTCHA**: Some commands are intentionally minimal
- **VALIDATE**: All commands >= 30 lines or have documented reason for brevity

### UPDATE `memory.md` — Add Lesson Learned

- **IMPLEMENT**: Add entry to Lessons Learned section:
  ```
  - **System Alignment Audit**: Comprehensive audit found 12 dead refs, 6 stale docs, 3 redundant commands. Fixed by removing dead refs, consolidating commands, aligning counts. Lesson: Audit quarterly to prevent drift.
  ```
- **PATTERN**: Standard memory.md lesson format
- **GOTCHA**: Keep under 100 lines total
- **VALIDATE**: Entry added to Lessons Learned section

---

## VALIDATION COMMANDS

### Final Dead Reference Check
```bash
# No scripts/ references
grep -r "scripts/" --include="*.md" . 2>/dev/null | grep -v "node_modules" | grep -v ".git" && echo "WARN: scripts/ found" || echo "PASS"

# No dead workflow references
grep -r "opencode-fix-coderabbit" reference/ --include="*.md" && echo "CHECK: verify this workflow exists" || echo "PASS"
```

### System Integrity
```bash
# All referenced templates exist
grep -roh "templates/[A-Z-]*\.md" .opencode/ reference/ 2>/dev/null | sort -u | while read t; do
  [ -f "$t" ] && echo "OK: $t" || echo "MISSING: $t"
done
```

### Memory Updated
```bash
grep "System Alignment Audit" memory.md && echo "PASS: Lesson learned added" || echo "FAIL: Add lesson"
```

---

## SUB-PLAN CHECKLIST

- [x] Task 1: Skills decision documented (keep as pattern)
- [x] Task 2: Workflow decision made (copy or remove) — Fixed refs in github-integration.md
- [x] Task 3: Final dead reference sweep
- [x] Task 4: Command template compliance verified
- [x] Task 5: memory.md lesson learned added

---

## HANDOFF NOTES

### Files Modified
- `memory.md` — Lesson learned added
- `.github/workflows/` — (if workflow copied)
- OR `reference/github-integration.md` — (if reference removed)

### Final State
- All 4 sub-plans complete
- System is aligned: documentation matches codebase
- No dead references
- Ready for `/commit`

### Next Steps
1. Run `/commit` to save all changes
2. Consider quarterly audits to prevent drift
3. New features should include reference guide alignment check
