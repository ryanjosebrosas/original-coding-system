---
description: Activate example agents by copying from _examples/ to active directory
argument-hint: [all|research|review|utility]
---

# Activate Agents

Activate example agents from `.opencode/agents/_examples/` to make them available in your session.

## Arguments

Parse `$ARGUMENTS` for activation group:
- `all` (default if empty) — Activate all 8 example agents
- `research` — Activate 2 research agents
- `review` — Activate 4 code review agents  
- `utility` — Activate 2 utility agents

Optional flags:
- `--dry-run` — Show what would be copied without copying
- `--force` — Overwrite existing agents without prompting

---

## Agent Groups

### research (2 agents)
- `research-codebase.md` — Haiku, codebase exploration and pattern discovery
- `research-external.md` — Sonnet, external documentation fetcher

### review (4 agents)
- `code-review-type-safety.md` — Type annotation and type checking reviewer
- `code-review-security.md` — Security vulnerability scanner
- `code-review-architecture.md` — Pattern compliance and architecture reviewer
- `code-review-performance.md` — Performance and optimization analyzer

### utility (2 agents)
- `plan-validator.md` — Plan structure validator (used by /execute)
- `test-generator.md` — Test case suggester

---

## Execution

### Step 1: Determine Agent List

Based on `$ARGUMENTS`:

```
all      → all 8 agents
research → research-codebase.md, research-external.md
review   → code-review-type-safety.md, code-review-security.md, 
           code-review-architecture.md, code-review-performance.md
utility  → plan-validator.md, test-generator.md
```

### Step 2: Pre-Copy Checks

For each agent in the selected group:

1. Check if source exists: `.opencode/agents/_examples/{agent}.md`
2. Check if target exists: `.opencode/agents/{agent}.md`
3. If target exists AND not `--force`:
   - Report: "Agent `{agent}` already exists. Skipping. Use --force to overwrite."
   - Skip this agent
4. If `--dry-run`:
   - Report: "Would copy: `_examples/{agent}.md` → `{agent}.md`"
   - Don't actually copy

### Step 3: Copy Agents

For each agent not skipped:

```bash
cp .opencode/agents/_examples/{agent}.md .opencode/agents/{agent}.md
```

Report: "Activated: `{agent}`"

### Step 4: Summary

Report:
- **Activated**: [count] agents
- **Skipped**: [count] (already existed)
- **Total available**: [count] agents in `.opencode/agents/`

---

## Post-Activation

**Important**: Restart your OpenCode session or start a new conversation to load the newly activated agents.

Verify agents are loaded:
- Type `@` in your prompt and check if new agents appear in completion
- Or run `/prime` to see agent inventory in codebase context

---

## Usage Examples

```bash
# Activate all example agents
/activate-agents all

# Activate only research agents
/activate-agents research

# Preview what would be activated
/activate-agents review --dry-run

# Force overwrite existing agents
/activate-agents utility --force
```

---

## Related

- `reference/agent-routing.md` — Decision tree for when to use each agent
- `reference/handoff-protocol.md` — How agents communicate results
- `.opencode/agents/_examples/README.md` — Full agent documentation
