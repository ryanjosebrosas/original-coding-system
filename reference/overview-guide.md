# Writing Minimal Overview Guides

## Purpose

Overview files (e.g., `*-overview.md`) provide navigation, not content duplication. They help readers find the right deep-dive guide without burning tokens on duplicated content.

---

## Pattern

1. **Table of contents** — what sections exist in the deep-dive
2. **One-sentence summaries** — each section in 1 line
3. **Pointers to deep-dives** — "See X for full details on Y"
4. **NO code examples** — those belong in deep-dives
5. **NO full explanations** — just enough to navigate

---

## Anti-Pattern

Don't write a mini-version of the deep-dive. If overview is >30% of deep-dive length, it's too long.

**Bad**: Overview duplicates 50% of framework content → users read both and waste tokens
**Good**: Overview is 29% of framework length → users scan overview, then load deep-dive only when needed

---

## Ratio Guideline

| Deep-Dive Length | Max Overview Length |
|------------------|---------------------|
| 700 lines | 210 lines (30%) |
| 500 lines | 150 lines (30%) |
| 300 lines | 90 lines (30%) |

---

## Example

**Good**: `command-design-overview.md` (203 lines) → `command-design-framework.md` (699 lines)
- Ratio: 29%
- Overview has: section list, one-line summaries, pointer to framework
- Framework has: full explanations, code examples, detailed patterns

---

## When to Create an Overview

- Deep-dive guide exceeds 400 lines
- Multiple related guides that users need to navigate between
- Content is referenced frequently but not always needed in full

## When NOT to Create an Overview

- Guide is already <200 lines
- Content is unique (no duplication risk)
- Overview would add more files without reducing tokens

---

## See Also

- `validation-pyramid.md` — Example of canonical content that overviews point to
- `global-rules-optimization.md` — Deep-dive that layer1-guide points to
