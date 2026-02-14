---
description: Generate a PRD from vibe planning conversation
argument-hint: [product-name]
---

# Create PRD: Generate Product Requirements Document

## Product

**Product Name**: $ARGUMENTS

## Mission

Transform the current vibe planning conversation into a **structured PRD** using the project's PRD template. The PRD defines **what** to build (scope, features, architecture, success criteria) — it is Layer 1 planning.

**Key Rules**:
- We do NOT write code in this phase. We are defining product scope.
- Use the conversation context as the primary source of decisions and research.
- Fill every section of the template — no generic placeholders.

## Process

### 1. Review Conversation Context

Analyze everything discussed in this conversation:
- Product goals and vision
- Features discussed and agreed upon
- Architecture decisions made
- Technology choices and rationale
- Scope boundaries (what's in, what's out)
- User stories and personas explored

Ask the user to clarify anything that's ambiguous BEFORE writing the PRD.

### 1.5. Specialist Consultation (Optional)

Based on the product domain, consider consulting specialists for architectural guidance:

**Always check availability**:
```bash
ls .opencode/agents/specialist-*.md 2>/dev/null
```

**Core specialists** (invoke if available and relevant):
- `@specialist-frontend` — UI/UX implications, component architecture, accessibility
- `@specialist-backend` — API design, authentication patterns, data modeling
- `@specialist-devops` — Deployment architecture, CI/CD pipeline design

**Domain specialists** (invoke when applicable):
- `@specialist-copywriter` — If product has user-facing copy, CTAs, or microcopy
- `@specialist-technical-writer` — If product requires user documentation
- `@specialist-data` — If product involves data pipelines, warehouses, or analytics

**Specialists are advisory** — the PRD author makes final decisions. Skip if specialists not available or not relevant to the product domain.

### 2. Read PRD Template

Read the template structure:
@templates/PRD-TEMPLATE.md

### 3. Generate PRD

Fill every section of the template using:
- Decisions from vibe planning conversation
- Research findings discussed
- User requirements stated
- Technical constraints identified

**Be specific, not generic.** Every section should contain real project details, not template placeholders.

### 4. Save PRD

Save the completed PRD to: `reference/PRD.md`

This location makes it available as on-demand context — loaded when choosing the next feature to build.

## Output

After saving, report:
- Product name and PRD file path
- Number of features/user stories defined
- Key architectural decisions captured
- Suggested next steps:
  1. Review PRD for accuracy
  2. Use `/init-c` to generate AGENTS.md (global rules) informed by PRD
  3. Create on-demand reference guides from the PRD
  4. Start first PIV loop: pick a feature from PRD and run `/planning [feature]`
