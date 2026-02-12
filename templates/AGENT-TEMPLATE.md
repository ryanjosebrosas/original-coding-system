# Agent Design Template

> Use this guide when creating new agents for `.opencode/agents/` (project) or `~/.config/opencode/agents/` (global).
> The filename becomes the agent name (e.g., `review.md` → `@review` agent).

---

## Quick Start

```markdown
---
description: Use this agent when {triggering scenario}. {What it does}.
mode: subagent
model: anthropic/claude-sonnet-4-20250514
tools:
  write: false
  edit: false
---

You are a {role} specializing in {domain}. Your mission: {singular purpose}.

## Context Gathering
- Read: {files needed}
- Provided by caller: {what main agent gives you}

## Approach
1. {First step}
2. {Second step}
3. {Third step}

## Output Format
{Structured output with metadata}

---
When done, instruct the main agent to {what happens next}.
```

---

## File Location

| Scope | Path |
|-------|------|
| Project | `.opencode/agents/{name}.md` |
| Global | `~/.config/opencode/agents/{name}.md` |

The filename becomes the agent identifier (e.g., `code-reviewer.md` creates `@code-reviewer`).

---

## Frontmatter Reference

| Field | Required | Values | Description |
|-------|----------|--------|-------------|
| `description` | **Yes** | text (1-1024 chars) | When to use — guides autonomous delegation and `@` autocomplete |
| `mode` | No | `primary` / `subagent` / `all` | Default: `all`. Primary = Tab-cyclable, Subagent = `@` invokable |
| `model` | No | `provider/model-id` | Default: inherits from parent or global config |
| `temperature` | No | `0.0` - `1.0` | Default: model-specific (typically 0, Qwen uses 0.55) |
| `top_p` | No | `0.0` - `1.0` | Alternative to temperature for randomness |
| `steps` | No | number | Max agentic iterations before text-only response |
| `tools` | No | object | Enable/disable specific tools (see below) |
| `permission` | No | object | Control `ask`/`allow`/`deny` for actions |
| `hidden` | No | `true` / `false` | Hide from `@` autocomplete (subagents only) |
| `color` | No | hex or theme color | Visual indicator (e.g., `#FF5733`, `accent`) |
| `disable` | No | `true` / `false` | Disable the agent entirely |

---

## Tools Configuration

```yaml
tools:
  write: false      # Disable file creation
  edit: false       # Disable file editing
  bash: false       # Disable shell commands
  skill: false      # Disable skill loading
  mymcp_*: false    # Disable all tools from MCP server (wildcard)
```

---

## Permissions Configuration

```yaml
permission:
  edit: deny                    # Disable all edits
  bash: ask                     # Prompt before any bash command
  webfetch: deny                # Disable web fetching
  skill:
    "*": deny                   # Deny all skills by default
    "internal-*": allow         # Allow specific pattern
  task:
    "*": deny                   # Deny all subagent invocations
    "code-reviewer": allow      # Allow specific subagent
```

For bash, use specific commands or glob patterns:
```yaml
permission:
  bash:
    "*": ask                    # Ask for everything by default
    "git status *": allow       # Allow git status
    "git diff": allow           # Allow git diff
    "git *": ask                # Ask for other git commands
```

---

## Agent Types

### Primary Agents
- Cyclable via **Tab** key during session
- Handle main conversation
- Examples: `build` (default, all tools), `plan` (restricted)

### Subagents
- Invoked via **@ mention** or by primary agents via Task tool
- Specialized for specific tasks
- Examples: `general` (full tools, no todo), `explore` (read-only)

---

## Design Framework: Role → Mission → Context → Approach → Output

### 1. Role Definition
- Clear identity and specialized expertise
- What makes it different from general-purpose agents?

### 2. Core Mission
- Singular purpose in one sentence
- Agents that try to do everything do nothing well

### 3. Context Gathering
- What files/info must it read?
- What does the caller provide vs what must the agent fetch?

### 4. Analysis Approach
- Numbered, specific instructions
- Include evaluation criteria and depth

### 5. Output Format
- Structured, parsable, includes metadata
- Explicit about what happens next

---

## Output Patterns

| Pattern | Consumer | Includes |
|---------|----------|----------|
| **Report** | Another command or human | File path, findings, severity, line refs |
| **Summary** | Main agent decision-making | Key findings, action items, metrics |
| **Action** | System + human | What was done, what changed, verification steps |

---

## Complete Example: Security Auditor

```markdown
---
description: Performs security audits and identifies vulnerabilities in code
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: false
  edit: false
  bash: false
permission:
  skill:
    "security-*": allow
color: "#ff6b6b"
---

You are a security expert specializing in code vulnerability assessment.

## Mission
Identify security issues without making direct changes to the codebase.

## Context Gathering
Read the following based on scope:
- Entry points: API routes, form handlers, file uploads
- Auth: Session management, password handling, tokens
- Data: Database queries, file operations, external APIs

## Approach
1. Map attack surface (all user inputs, external integrations)
2. Check input validation at each entry point
3. Review authentication and authorization flows
4. Scan for common vulnerabilities (injection, XSS, CSRF)
5. Check dependency security (package.json, requirements.txt)

## Output Format

### Scope Analyzed
- Files reviewed: [list with line counts]
- Entry points: [count and types]

### Findings
For each issue:
- **Severity**: Critical / High / Medium / Low
- **Type**: [OWASP category]
- **Location**: `file:line`
- **Description**: [what's vulnerable]
- **Remediation**: [how to fix]

### Summary
- Total issues: X (Critical: Y, High: Z, Medium: W, Low: V)
- Risk level: [Critical/High/Medium/Low]

---
When done, instruct the main agent to present findings to the user without making changes. Require user approval before any remediation.
```

---

## When to Create an Agent

**Create when:**
- Context-heavy task done 3+ times manually
- Need parallelization (multiple aspects simultaneously)
- Specialized review against documented standards
- Want controlled output format

**Don't create for:**
- One-off tasks (prompt directly)
- Simple operations without isolation needs
- Tasks needing full conversation context

---

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Missing `description` | Required field — guides delegation |
| Vague description | Include triggering scenarios ("Use when...") |
| No output format | Define explicit structure |
| No main agent instructions | Tell it what to do (or not do) with results |
| Tool overreach | Reviewers don't need write — restrict tools |
| Missing metadata | Include files reviewed, line numbers, severity |
