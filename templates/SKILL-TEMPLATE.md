# Creating a New Skill

Skills define reusable behavior via `SKILL.md` definitions loaded on-demand through the native `skill` tool.

---

## Quick Start

```markdown
---
name: my-skill
description: Brief description (1-1024 chars) for agent decision-making
---

## What I Do
- Bullet point of capability
- Another capability

## When to Use Me
Use this skill when {specific scenario}.

## Instructions
1. Step 1 with validation
2. Step 2 with validation
3. Return results in {format}
```

---

## File Location

Create one folder per skill with a `SKILL.md` inside:

| Scope | Path |
|-------|------|
| Project (OpenCode) | `.opencode/skills/{name}/SKILL.md` |
| Global (OpenCode) | `~/.config/opencode/skills/{name}/SKILL.md` |
| Project (Claude-compatible) | `.claude/skills/{name}/SKILL.md` |
| Global (Claude-compatible) | `~/.claude/skills/{name}/SKILL.md` |
| Project (Agent-compatible) | `.agents/skills/{name}/SKILL.md` |
| Global (Agent-compatible) | `~/.agents/skills/{name}/SKILL.md` |

---

## Frontmatter Reference

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | **Yes** | 1-64 chars, lowercase alphanumeric, single hyphens, no leading/trailing/consecutive hyphens |
| `description` | **Yes** | 1-1024 characters |
| `license` | No | e.g., `MIT`, `Apache-2.0` |
| `compatibility` | No | e.g., `opencode`, `claude` |
| `metadata` | No | String-to-string map for custom data |

### Name Validation Rules

Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

| Valid | Invalid |
|-------|---------|
| `git-release` | `Git-Release` (uppercase) |
| `code-review` | `code_review` (underscore) |
| `api-docs` | `-api-docs` (leading hyphen) |
| `test-runner` | `test--runner` (consecutive hyphens) |
| `mcp-tools` | `mcp-tools-` (trailing hyphen) |

**Important**: The `name` in frontmatter must match the directory name containing `SKILL.md`.

---

## How Discovery Works

### Project Skills
OpenCode walks up from your current directory until it reaches the git worktree, loading any matching `skills/*/SKILL.md` files.

### Global Skills
Also loaded from `~/.config/opencode/skills/*/SKILL.md` and compatible paths.

---

## Tool Description

Skills appear in the `skill` tool description available to agents:

```xml
<available_skills>
  <skill>
    <name>git-release</name>
    <description>Create consistent releases and changelogs</description>
  </skill>
</available_skills>
```

Agents load skills via:
```
skill({ name: "git-release" })
```

---

## Permissions

### Global Permissions (opencode.json)

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

| Permission | Behavior |
|------------|----------|
| `allow` | Skill loads immediately |
| `deny` | Skill hidden from agent, access rejected |
| `ask` | User prompted before loading |

### Per-Agent Override

**For custom agents** (in agent frontmatter):
```yaml
permission:
  skill:
    "documents-*": allow
```

**For built-in agents** (in `opencode.json`):
```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```

### Disable Skill Tool

**For custom agents**:
```yaml
tools:
  skill: false
```

**For built-in agents**:
```json
{
  "agent": {
    "plan": {
      "tools": {
        "skill": false
      }
    }
  }
}
```

---

## Directory Structure (Optional Extensions)

```
.opencode/skills/
  git-release/
    SKILL.md              # Entry point (required)
    references/           # Detailed guides (optional)
      changelog-format.md
    examples/             # Usage examples (optional)
      example-release.md
    scripts/              # Executable scripts (optional)
      validate-version.sh
```

Reference supporting files in SKILL.md:
```markdown
See `references/changelog-format.md` for detailed formatting rules.
```

---

## Complete Example

`.opencode/skills/git-release/SKILL.md`:

```markdown
---
name: git-release
description: Create consistent releases and changelogs from merged PRs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github
---

## What I Do
- Draft release notes from merged PRs since last tag
- Propose semantic version bump based on changes
- Provide copy-pasteable `gh release create` command

## When to Use Me
Use this skill when preparing a tagged release. Ask clarifying questions if the target versioning scheme is unclear.

## Instructions

### 1. Gather Changes
```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline
gh pr list --state merged --limit 20
```

### 2. Categorize Changes
- **feat:** → Minor version bump
- **fix:** → Patch version bump
- **breaking:** → Major version bump

### 3. Generate Changelog
Group by type with PR links and author credits.

### 4. Propose Command
```bash
gh release create v{version} --title "v{version}" --notes-file RELEASE_NOTES.md
```

## Output
- Proposed version: `v{X.Y.Z}`
- Changelog content
- Ready-to-run release command
```

---

## Troubleshooting

| Issue | Check |
|-------|-------|
| Skill not appearing | `SKILL.md` spelled in all caps |
| Missing from tool | Frontmatter has `name` and `description` |
| Name conflict | Skill names must be unique across all locations |
| Access denied | Check `permission.skill` settings |
| Hidden skill | Skills with `deny` are hidden from agents |

---

## When to Use Skill vs Command

| Use Skill | Use Command |
|-----------|-------------|
| Auto-loading based on task context | User-only invocation |
| Supporting files (templates, examples) | Single-file workflow |
| Progressive disclosure (tiered loading) | Simple, under 200 lines |
| Reusable across projects | Project-specific workflow |
