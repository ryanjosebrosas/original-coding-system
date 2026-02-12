# Command-Agent Mapping

Reference guide for which agents are integrated into each command, when they trigger, and fallback behavior.

## Quick Reference

| Command | Agents Used | Trigger Condition | Parallel |
|---------|-------------|-------------------|----------|
| `/rca` | ContextScout, ExternalScout | Always (if available) | Yes |
| `/implement-fix` | ContextScout, BuildAgent | Always (if available) | No |
| `/code-review-fix` | BuildAgent | After all fixes complete | No |
| `/create-prd` | Specialists (frontend/backend/devops) | Domain-specific (if available) | No |
| `/init-c` | ContextScout | Existing codebases only | No |
| `/end-to-end-feature` | TaskManager, BuildAgent, TestEngineer | >8 tasks triggers TaskManager | No |
| `/system-review` | ContextScout | Always (if available) | No |
| `/commit` | TestEngineer (suggestion) | feat/fix without tests | No |
| `/create-pr` | DocWriter | >5 files changed | No |
| `/execution-report` | ContextScout | Always (if available) | No |
| `/merge-worktrees` | BuildAgent | After all merges | No |
| `/prime` | None (inventory only) | Always reports agent count | N/A |
| `/planning` | Research agents | Already integrated | Yes |
| `/code-review` | Review agents | Already integrated | Yes |
| `/execute` | Plan-validator | Already integrated | No |

## No-Change Commands

These commands work better without agent overhead:

- `/quick-github-setup` — Script execution, no agent benefit
- `/activate-agents` — Meta-command for agent management
- `/agents` — Agent creation command

## Integration Patterns

### Optional Availability Pattern

All agent integrations use this pattern:

```markdown
**If {AgentName} available** (`ls .opencode/agents/{agent-file}.md`):
- Launch `@{agent-name}` with query: "{specific query}"
- Review findings before proceeding

**If agent not available**: Skip — proceed to {next step}.
```

**Key principle**: Commands MUST work without agents. Agents enhance, never block.

### Parallel Agent Pattern

Used in `/planning` and `/code-review`:

```markdown
Launch four Task agents simultaneously:
1. @agent-a — perspective A
2. @agent-b — perspective B
3. @agent-c — perspective C
4. @agent-d — perspective D

After completion: combine results, deduplicate, sort by severity.
```

### Specialist Delegation Pattern

Used in `/create-prd`:

```markdown
**If product involves {domain}** and `specialist-{domain}` exists:
- Consider `@specialist-{domain}` for {specific guidance}

Specialists are advisory — author makes final decisions.
```

## Agent Categories

### Core Agents (Always Available)
- Used by fundamental commands
- Should be activated in all projects

### Subagents (Task-Specific)
- `subagent-contextscout` — Internal context discovery
- `subagent-externalscout` — External documentation fetch
- `subagent-buildagent` — Build validation (read-only)
- `subagent-testengineer` — Test coverage
- `subagent-taskmanager` — Task decomposition
- `subagent-docwriter` — Documentation generation

### Specialists (Domain Experts)
- `specialist-frontend` — React, Vue, CSS, accessibility
- `specialist-backend` — API, database, auth
- `specialist-devops` — CI/CD, Docker, GitHub Actions

### Review Agents (Parallel)
- `code-review-type-safety`
- `code-review-security`
- `code-review-architecture`
- `code-review-performance`

### Research Agents (Parallel)
- `research-codebase`
- `research-external`

## Fallback Behavior

Every agent integration has explicit fallback:

1. **Check availability**: `ls .opencode/agents/{agent}.md`
2. **If exists**: Invoke agent, review findings
3. **If missing**: Skip agent step, proceed to next step
4. **Never block**: Commands complete regardless of agent availability

## Activation Guide

Example agents live in `.opencode/agents/_examples/`. To activate:

```bash
# Copy to active location
cp .opencode/agents/_examples/research-codebase.md .opencode/agents/

# Or run the activation command
/activate-agents
```

See `memory.md` gotcha: "Agent activation: Example agents in `_examples/` are dormant"
