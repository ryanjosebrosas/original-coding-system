# Agent Routing Guide

> **Load when**: Deciding which agent to use, designing multi-agent workflows, debugging delegation chains.

---

## Quick Reference Flowchart

```
┌─────────────────────────────────────────────────────────────┐
│                    AGENT ROUTING FLOWCHART                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  User Request                                               │
│       │                                                     │
│       ├── Research/Question? ──► OpenAgent                  │
│       │                                                     │
│       └── Implementation?                                   │
│               │                                             │
│               ├── 1-3 files ──► OpenAgent                   │
│               │                                             │
│               └── 4+ files ──► OpenCoder                    │
│                       │                                     │
│                       ├── ContextScout (always)             │
│                       ├── ExternalScout (if external libs)  │
│                       ├── TaskManager (if complex)          │
│                       │       └── BatchExecutor (5+ tasks)  │
│                       │               └── CoderAgent        │
│                       ├── BuildAgent (validate)             │
│                       ├── TestEngineer (tests)              │
│                       └── Specialist (if domain-specific)   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Primary Agent Selection

### Decision Rules

| Question | Answer | Agent |
|----------|--------|-------|
| How many files will change? | 1-3 | OpenAgent |
| How many files will change? | 4+ | OpenCoder |
| Is this production code? | Yes | OpenCoder (with session context) |
| Is this research/exploration? | Yes | OpenAgent |

### OpenAgent — When to Use

- Questions and explanations
- Research and exploration
- Simple implementations (1-3 files)
- Ad-hoc tasks without formal planning
- Quick fixes and one-off changes

**Workflow**: Analyze → Discover → Propose → Approve → Execute → Validate → Summarize

### OpenCoder — When to Use

- Complex coding (4+ files)
- Architecture changes
- Multi-file refactoring
- Production development with quality gates
- Features requiring session context

**Workflow**: Discover → Propose → Init Session → Plan → Execute → Validate & Handoff

---

## Subagent Delegation Matrix

| Subagent | Trigger Condition | Called By | Returns To |
|----------|-------------------|-----------|------------|
| **ContextScout** | Before ANY coding task | OpenCoder, TaskManager | Calling agent |
| **ExternalScout** | External library/framework mentioned | OpenCoder, OpenAgent | Calling agent |
| **TaskManager** | 4+ files OR >60 min estimate | OpenCoder | BatchExecutor or OpenCoder |
| **BatchExecutor** | 5+ parallel tasks in batch | TaskManager | OpenCoder |
| **CoderAgent** | Individual task execution | BatchExecutor, OpenCoder | BatchExecutor or OpenCoder |
| **BuildAgent** | After implementation complete | OpenCoder | OpenCoder |
| **TestEngineer** | After implementation, before commit | OpenCoder | OpenCoder |
| **DocWriter** | After feature complete | OpenCoder | OpenCoder |

### Delegation Chain

```
User Request
  └─ OpenCoder (orchestrator)
       │
       ├─► ContextScout ───► discovers internal standards
       │
       ├─► ExternalScout ──► fetches external docs (if libs involved)
       │
       ├─► TaskManager ────► breaks down work (if 4+ files)
       │       │
       │       └─► BatchExecutor ──► coordinates parallel tasks (if 5+)
       │               │
       │               └─► CoderAgent ──► implements individual tasks
       │
       ├─► BuildAgent ─────► validates build passes
       │
       ├─► TestEngineer ───► writes tests
       │
       └─► DocWriter ──────► creates documentation (optional)
```

### When to Skip Delegation

| Scenario | Skip These |
|----------|------------|
| Simple 1-3 file change | TaskManager, BatchExecutor |
| No external libraries | ExternalScout |
| No tests required | TestEngineer |
| No docs needed | DocWriter |
| Research only | All except ExternalScout |

---

## Specialist Selection

| Domain | Specialist | Trigger Keywords |
|--------|------------|------------------|
| Frontend | `specialist-frontend` | React, Vue, Angular, CSS, Tailwind, accessibility, WCAG, components |
| Backend | `specialist-backend` | API, REST, GraphQL, database, auth, OAuth, JWT, middleware |
| DevOps | `specialist-devops` | CI/CD, Docker, Kubernetes, GitHub Actions, deploy, infrastructure |
| Data | `specialist-data` | schema, migration, ETL, analytics, warehouse, query optimization |
| Copy | `specialist-copywriter` | UI text, microcopy, error messages, onboarding, UX writing |
| Docs | `specialist-technical-writer` | API docs, README, architecture docs, guide, documentation |

### When to Invoke Specialists

1. **User explicitly mentions domain** — "review the React components"
2. **Task requires domain expertise** — beyond general coding knowledge
3. **Quality review needs specialized perspective** — security, performance, accessibility

### Parallel Specialist Pattern

For cross-domain features, invoke multiple specialists simultaneously:

```
OpenCoder
  ├─► specialist-frontend ──► UI component analysis
  ├─► specialist-backend ───► API design review
  └─► specialist-data ──────► schema validation
       │
       └─► Results combined into unified recommendation
```

---

## Research Agent Routing

| Agent | Model | When to Use | Example Queries |
|-------|-------|-------------|-----------------|
| `research-codebase` | Haiku | Internal patterns, file discovery | "auth middleware patterns", "test fixtures" |
| `research-external` | Sonnet | Library docs, version compatibility | "React 19 migration", "Stripe API v2024" |

### Decision Rule

```
Is the information in our codebase?
  ├─ Yes ──► research-codebase (Haiku, fast, cheap)
  └─ No ───► research-external (Sonnet, web fetch)
```

### Parallel Research Pattern

From `/planning` command — launch up to 10 agents simultaneously:

```
Main Agent (Sonnet)
  │
  ├─► research-codebase #1 ──► "auth patterns"
  ├─► research-codebase #2 ──► "test fixtures"
  ├─► research-codebase #3 ──► "model structure"
  │
  ├─► research-external #1 ──► "JWT best practices"
  ├─► research-external #2 ──► "bcrypt password hashing"
  └─► research-external #3 ──► "OAuth2 PKCE flow"
       │
       └─► Results combined into unified research report
```

**Scale guideline**:
- Simple features (Low complexity): 2-4 agents total
- Medium features: 4-6 agents total
- Complex features (High complexity): 6-10 agents total

---

## Code Review Agent Routing

| Agent | Focus | When to Use |
|-------|-------|-------------|
| `code-review-type-safety` | Type annotations, type checking | TypeScript/Python with type hints |
| `code-review-security` | Vulnerabilities, secrets, auth | Any user-facing code |
| `code-review-architecture` | Patterns, layering, DRY/YAGNI | Multi-file changes |
| `code-review-performance` | N+1 queries, algorithms, memory | Database code, loops, large data |

### Parallel Review Pattern

```
Main Agent
  ├─► code-review-type-safety ──► all changed files
  ├─► code-review-security ─────► all changed files
  ├─► code-review-architecture ─► all changed files
  └─► code-review-performance ──► all changed files
       │
       └─► Results combined, deduplicated, sorted by severity
```

### Selective Review

Not all features need all reviewers:

| Feature Type | Recommended Reviewers |
|--------------|----------------------|
| New API endpoint | security, architecture, performance |
| Frontend component | type-safety, architecture |
| Database migration | security, architecture, performance |
| Bug fix | type-safety, security |
| Documentation | Skip parallel review |

---

## Agent Activation

Example agents in `_examples/` are dormant by default. Activate them:

```bash
/activate-agents all        # All 8 example agents
/activate-agents research   # 2 research agents
/activate-agents review     # 4 code review agents
/activate-agents utility    # 2 utility agents
```

After activation, restart your session to load the new agents.

---

## Summary Table

| Category | Agents | Model | Purpose |
|----------|--------|-------|---------|
| **Core** | OpenAgent, OpenCoder | Sonnet | Primary orchestrators |
| **Discovery** | ContextScout, ExternalScout | Haiku/Sonnet | Context gathering |
| **Task Mgmt** | TaskManager, BatchExecutor | Sonnet | Work coordination |
| **Execution** | CoderAgent | Sonnet | Code implementation |
| **QA** | BuildAgent, TestEngineer | Haiku | Validation |
| **Documentation** | DocWriter | Sonnet | Docs creation |
| **Specialists** | frontend, backend, devops, data, copywriter, technical-writer | Sonnet/Haiku | Domain expertise |
| **Research** | research-codebase, research-external | Haiku/Sonnet | Information gathering |
| **Review** | type-safety, security, architecture, performance | Haiku | Code quality |
