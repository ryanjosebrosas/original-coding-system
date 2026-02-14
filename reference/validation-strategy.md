### The 5-Level Validation Pyramid

> See `validation-pyramid.md` for the canonical 5-level validation pyramid.
> This file provides strategy guidance; the pyramid itself is documented separately.

### Validation as Feedback

When validation fails, it reveals missing context in the plan, unclear requirements, patterns to document, or commands to improve.

**Don't just fix the bug. Fix the system that allowed the bug.** When you see the same validation failures repeatedly, that's a signal to improve your system — not just your code. Use `/system-review` for this.

### Validation Commands

Beyond embedded validation in plans, these commands provide on-demand validation:
- `/code-review` — Technical code review on changed files (run before commit)
- `/code-review-fix [review] [scope]` — Fix issues from code review
- `/execution-report` — Generate implementation report (run in same context as execute)
- `/system-review [plan] [report]` — Divergence analysis for process improvement

See section 09 for full command descriptions.
