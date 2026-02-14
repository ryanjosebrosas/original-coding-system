# The 5-Level Validation Pyramid

> Canonical reference for validation levels. Each level gates the next.
> Don't proceed to the next level if the current one fails.

```
        Level 5: Human Review
              (Alignment with intent)
                    |
        Level 4: Integration Tests
              (System behavior)
                    |
        Level 3: Unit Tests
              (Isolated logic)
                    |
        Level 2: Type Safety
              (Type checking)
                    |
        Level 1: Syntax & Style
              (Linting, formatting)
```

---

## Level 1 — Syntax & Style

**What it catches**: Syntax errors, formatting inconsistencies, import issues, style violations.

**When to run**: After every file write. Most editors and AI tools do this automatically.

**Common commands**:
```bash
# Python
ruff check . --fix && ruff format .

# TypeScript/JavaScript
npx eslint . --fix && npx prettier --write .

# Go
go fmt ./... && golangci-lint run
```

**Why it matters**: Fastest, cheapest check. If code doesn't parse, nothing else matters.

---

## Level 2 — Type Safety

**What it catches**: Type mismatches, missing return types, incorrect function signatures, null/undefined handling.

**When to run**: After implementation, before tests. Type errors cause confusing test failures.

**Common commands**:
```bash
# Python
mypy app/ --strict || pyright

# TypeScript
npx tsc --noEmit

# Go (built into compiler)
go build ./...
```

**Why it matters**: Catches bugs tests might miss — especially subtle type issues in dynamic languages.

---

## Level 3 — Unit Tests

**What it catches**: Logic errors, edge cases, incorrect calculations, broken algorithms.

**When to run**: After type checking passes. Run focused tests first, then full suite.

**Common commands**:
```bash
# Python
pytest tests/unit/ -v

# TypeScript/JavaScript
npx jest --testPathPattern="feature-name"

# Go
go test ./... -v
```

**Critical pitfall**: AI sometimes writes tests that mock so heavily they test nothing real. Reject mocks without justification.

---

## Level 4 — Integration Tests

**What it catches**: Component interaction bugs, database issues, API contract violations, race conditions.

**When to run**: After unit tests pass. Uses more resources, takes longer.

**Common commands**:
```bash
# Python
pytest tests/integration/ -v

# TypeScript
npx jest --testPathPattern="integration"

# Docker-based
docker compose up -d test-db && pytest tests/integration/ && docker compose down
```

**Best practices**: Mock external services (Stripe, SendGrid) but not internal components. Use real test databases.

---

## Level 5 — Human Review

**What it catches**: Architectural drift, intent misalignment, pattern violations, security oversights, over-engineering.

**When to do it**: After levels 1-4 pass. Final gate before merge/commit.

**What to look for**:
- Does implementation match the plan?
- Are project patterns being followed?
- Is the approach architecturally sound?
- Are there security concerns?
- Is there unnecessary complexity (YAGNI violations)?

**The 80/20 of human review**: Focus on new files, public interfaces, database changes, and security-sensitive code.

---

## AI vs Human Responsibility

| Level | AI Validates | Human Validates |
|-------|--------------|-----------------|
| 1-4 | Syntax, types, unit tests, integration | — |
| 5 | — | Code review, manual testing, intent alignment |

AI handles mechanical validation. Humans judge strategic alignment — does this solve the right problem the right way?

---

## See Also

- `reference/validation-discipline.md` — Discipline and workflow guidance
- `reference/validation-strategy.md` — Strategy for choosing validation levels
- `reference/piv-loop-practice.md` — PIV Loop validation integration
