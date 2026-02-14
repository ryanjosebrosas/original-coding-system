# Sub-Plan 03: Documentation Alignment

> **Parent Plan**: `requests/system-alignment-audit-plan-overview.md`
> **Sub-Plan**: 03 of 04
> **Phase**: Documentation Alignment
> **Tasks**: 6
> **Estimated Context Load**: Low

---

## Scope

This sub-plan fixes incorrect counts in documentation and aligns agent inventory across files.

**What this sub-plan delivers**:
- `reference/file-structure.md` counts corrected
- `reference/subagents-overview.md` agent categorization aligned
- `.opencode/agents/_examples/README.md` model references fixed
- Template stale references fixed (if any remaining)

**Prerequisites from sub-plan 02**:
- Command count may have changed (22 if claude-mcp removed)

---

## CONTEXT FOR THIS SUB-PLAN

### Files to Read Before Implementing

- `reference/file-structure.md` — Has incorrect command count and agent categorization
- `reference/subagents-overview.md` — Agent inventory differs from file-structure
- `.opencode/agents/_examples/README.md` — Model documentation mismatch
- `README.md` — May need count updates

---

## STEP-BY-STEP TASKS

### UPDATE `reference/file-structure.md` — Command Count

- **IMPLEMENT**: Fix command count:
  1. Count actual .md files in `.opencode/commands/` (excluding .gitkeep)
  2. Update line 83: "23 total" → actual count
  3. Verify command list matches actual files
- **PATTERN**: `ls .opencode/commands/*.md | wc -l`
- **GOTCHA**: Count changes if claude-mcp was removed in sub-plan 02
- **VALIDATE**: Count in file matches `ls .opencode/commands/*.md | wc -l`

### UPDATE `reference/file-structure.md` — Agent Inventory

- **IMPLEMENT**: Align agent categorization:
  1. Current: "16 active + 8 examples"
  2. Actual: 2 core + 8 subagent + 6 specialist = 16 active, plus 8 in _examples/
  3. Update to be explicit: "2 core, 8 subagent, 6 specialist (8 examples in _examples/)"
- **PATTERN**: Count files in each category
- **GOTCHA**: Don't count README.md in _examples/ as an agent
- **VALIDATE**: Categories sum to correct totals

### UPDATE `reference/subagents-overview.md` — Agent Inventory

- **IMPLEMENT**: Ensure agent inventory matches file-structure.md:
  1. Verify all 16 active agents are listed
  2. Ensure categorization is consistent (core/subagent/specialist)
  3. Update "16 agents total" breakdown if needed
- **PATTERN**: Cross-reference with `.opencode/agents/` directory
- **GOTCHA**: May need to recount after sub-plan 02 changes
- **VALIDATE**: Inventory matches file-structure.md

### UPDATE `.opencode/agents/_examples/README.md` — Model References

- **IMPLEMENT**: Fix model documentation mismatch:
  1. Lines 23-24 say OpenAgent/OpenCoder use "Sonnet"
  2. Actual agents use `model: anthropic/claude-opus-4-5`
  3. Update README to reflect actual model assignments
- **PATTERN**: Check actual agent files for model field
- **GOTCHA**: Model names may be OpenCode-specific aliases
- **VALIDATE**: `grep "OpenAgent\|OpenCoder" .opencode/agents/_examples/README.md` shows correct model

### UPDATE `README.md` — Command Count

- **IMPLEMENT**: If README.md references command count, update it:
  1. Check for "20 commands" or similar
  2. Update to actual count
- **PATTERN**: `grep -n "command" README.md`
- **GOTCHA**: README may be intentionally approximate ("20+" vs exact)
- **VALIDATE**: Count is accurate or clearly approximate

### VERIFY template references

- **IMPLEMENT**: Final check of template stale references:
  1. Check `templates/COMMAND-TEMPLATE.md` for outdated model references
  2. Check `templates/AGENT-TEMPLATE.md` for outdated model references
  3. Update if found
- **PATTERN**: `grep -i "claude-sonnet-4\|sonnet-4" templates/*.md`
- **GOTCHA**: Model names evolve — use current format from active agents
- **VALIDATE**: No obviously outdated model names in templates

---

## VALIDATION COMMANDS

### Syntax & Structure
```bash
# All counts match reality
echo "Commands: $(ls .opencode/commands/*.md | wc -l)"
echo "Core agents: $(ls .opencode/agents/core-*.md | wc -l)"
echo "Subagents: $(ls .opencode/agents/subagent-*.md | wc -l)"
echo "Specialists: $(ls .opencode/agents/specialist-*.md | wc -l)"
echo "Examples: $(ls .opencode/agents/_examples/*.md | grep -v README | wc -l)"
```

### Content Verification
```bash
# file-structure.md has correct count
grep -o "[0-9]* total" reference/file-structure.md | head -1

# Counts match
ACTUAL=$(ls .opencode/commands/*.md | wc -l)
grep "$ACTUAL total" reference/file-structure.md && echo "PASS" || echo "FAIL"
```

### Cross-Reference Check
```bash
# No model name inconsistencies
grep -r "claude-sonnet-4[^-]" .opencode/agents/ templates/ && echo "WARN: Potentially outdated model" || echo "PASS"
```

---

## SUB-PLAN CHECKLIST

- [x] Task 1: file-structure.md command count corrected
- [x] Task 2: file-structure.md agent inventory aligned
- [x] Task 3: subagents-overview.md inventory aligned
- [x] Task 4: _examples/README.md model references fixed
- [x] Task 5: README.md count updated (if needed)
- [x] Task 6: Template model references verified

---

## HANDOFF NOTES

### Files Modified
- `reference/file-structure.md` — Counts corrected
- `reference/subagents-overview.md` — Inventory aligned
- `.opencode/agents/_examples/README.md` — Model references fixed
- `README.md` — Count updated (if needed)
- `templates/*.md` — Model references verified

### State for Next Sub-Plan
- Documentation counts are accurate. Sub-plan 04 will make final decisions on gap closures (skills, missing workflows).
- All counts now reflect actual file state.
