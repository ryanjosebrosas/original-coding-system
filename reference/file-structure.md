```
AGENTS.md                              # Layer 1: Global rules (slim, @references)
README.md                              # Public-facing project README with PIV Loop diagrams
memory.md                              # Cross-session memory (optional, from MEMORY-TEMPLATE.md)
.coderabbit.yaml                       # CodeRabbit config template (copy to project root)
sections/                              # Auto-loaded rule sections (every session)
  01_core_principles.md                #   YAGNI, KISS, DRY, Limit AI Assumptions, ABP
  02_piv_loop.md                       #   Plan, Implement, Validate methodology (slim)
  03_context_engineering.md            #   4 Pillars: Memory, RAG, Prompts, Tasks
  04_git_save_points.md                #   Commit plans before implementing
  05_decision_framework.md             #   When to proceed vs ask
  15_archon_workflow.md                #   Archon integration pointer (slim — loads reference/archon-workflow.md)
reference/                             # On-demand guides (loaded when needed)
  archon-workflow.md                   #   Archon task management & RAG workflow
  layer1-guide.md                      #   How to build AGENTS.md for real projects
  validation-strategy.md               #   5-level validation pyramid, linting, tests
  file-structure.md                    #   This file — project directory layout
  command-design-overview.md           #   Slash commands & INPUT→PROCESS→OUTPUT
  command-design-framework.md          #   Slash commands deep dive
  command-agent-mapping.md             #   Which commands use which agents
  agent-routing.md                     #   Decision tree for agent selection
  handoff-protocol.md                  #   How agents communicate results
  github-integration.md                #   GitHub Actions, remote agents, orchestration
  github-orchestration.md              #   GitHub Actions, 3 approaches, review-fix loop
  remote-system-overview.md            #   Remote Agentic Coding System, orchestrator
  remote-system-guide.md               #   Setup & deployment guide for remote coding agent
  remote-agentic-system.md             #   Remote system, orchestrator, cloud deployment
  mcp-skills-overview.md               #   MCP protocol, cloud skills, progressive loading
  mcp-skills-archon.md                 #   MCP servers, Cloud Skills, Archon integration
  subagents-overview.md                #   Subagents, parallel execution, context isolation
  subagents-guide.md                   #   Subagent creation, frontmatter, output patterns
  subagents-deep-dive.md               #   Subagents, context handoff, agent design framework
  git-worktrees-overview.md            #   Git worktrees, parallel implementation
  git-worktrees-parallel.md            #   Git worktrees, parallel implementation, vertical slices
  tmux-integration.md                  #   tmux session management for worktrees
  system-foundations.md                #   System gap, mental models, self-assessment
  piv-loop-practice.md                 #   PIV Loop in practice, 4 Pillars, validation
  global-rules-optimization.md         #   Modular AGENTS.md, Two-Question Framework
  planning-methodology-guide.md        #   6-phase planning, PRD, Vertical Slice
  implementation-discipline.md         #   Execute command, meta-reasoning, save states
  validation-discipline.md             #   5-level pyramid, code review, system review
  multi-model-strategy.md              #   When to use Haiku/Sonnet/Opus for cost optimization
  multi-instance-routing.md            #   Route tasks to different Claude accounts (claude1/2/3/zai)
  github-workflows/                    #   Example GitHub Action YAML files
    opencode-fix.yml                   #     OpenCode issue fix/create workflow
    opencode-fix-coderabbit.yml        #     OpenCode auto-fix from CodeRabbit reviews
    README.md                          #     Workflow setup instructions
.github/workflows/                     # GitHub Action workflows & prompt templates
  claude-fix.yml                       #   Issue fix workflow (copy to project)
  coderabbit-auto-merge.yml            #   Auto-merge on CodeRabbit approval
  coderabbit-approval-notify.yml       #   Notify on CodeRabbit approval
  prompts/                             #   GitHub-adapted prompt templates
    prime-github.md                    #     Prime for GitHub Actions context
    end-to-end-feature-github.md       #     Full PIV Loop for enhancement issues
    bug-fix-github.md                  #     RCA + fix for bug issues
    rca-github.md                      #     Root cause analysis
    plan-feature-github.md             #     Feature planning
    execute-github.md                  #     Implementation from plan
    implement-fix-github.md            #     Fix implementation
    code-review-github.md              #     Code review for GitHub PRs
templates/
  PRD-TEMPLATE.md                      # Template for Layer 1 PRD (what to build)
  STRUCTURED-PLAN-TEMPLATE.md          # Template for Layer 2 plans (per feature)
  SUB-PLAN-TEMPLATE.md                 # Individual sub-plan template (150-250 lines)
  PLAN-OVERVIEW-TEMPLATE.md            # Master file for decomposed plan series
  SESSION-CONTEXT-TEMPLATE.md          # Session context for multi-agent workflows
  VIBE-PLANNING-GUIDE.md               # Example prompts for vibe planning
  IMPLEMENTATION-PROMPT.md             # Reusable prompt for implementation phase
  VALIDATION-PROMPT.md                 # Reusable prompt for validation phase
  VALIDATION-REPORT-TEMPLATE.md        # Standard format for validation output
  NEW-PROJECT-CHECKLIST.md             # Step-by-step guide for new projects
  CREATE-REFERENCE-GUIDE-PROMPT.md     # Prompt to generate on-demand reference guides
  MEMORY-TEMPLATE.md                   # Template for project memory (cross-session context)
  COMMAND-TEMPLATE.md                  # How to design new slash commands
  AGENT-TEMPLATE.md                    # How to design new subagents
  SKILL-TEMPLATE.md                    # How to design MCP skills
  BASELINE-ASSESSMENT-TEMPLATE.md      # Self-assessment for measuring PIV Loop improvement
  GITHUB-SETUP-CHECKLIST.md            # Step-by-step GitHub Actions setup
  META-REASONING-CHECKLIST.md          # 5-step meta-reasoning + WHERE-to-fix framework
  TOOL-DOCSTRING-TEMPLATE.md           # 7-element template for agent tool documentation
requests/
  {feature}-plan.md                    # Layer 2: Feature plans go here
.opencode/commands/                    # Slash commands (21 total)
  create-agent.md                      #   /create-agent — generate subagent definition files
  activate-agents.md                   #   /activate-agents — copy example agents to active
  init-c.md                            #   /init-c — generate AGENTS.md for a new project
  prime.md                             #   /prime — load codebase context
  planning.md                          #   /planning — create implementation plan
  execute.md                           #   /execute — implement from plan
  commit.md                            #   /commit — conventional git commit
  rca.md                               #   /rca — root cause analysis (GitHub issues)
  implement-fix.md                     #   /implement-fix — fix from RCA document
  end-to-end-feature.md                #   /end-to-end-feature — autonomous workflow
  parallel-e2e.md                      #   /parallel-e2e — parallel end-to-end with worktrees
  create-prd.md                        #   /create-prd — generate PRD from conversation
  create-pr.md                         #   /create-pr — create GitHub PR
  code-review.md                       #   /code-review — technical code review
  code-review-fix.md                   #   /code-review-fix — fix issues from code review
  execution-report.md                  #   /execution-report — implementation report
  system-review.md                     #   /system-review — divergence analysis
  new-worktree.md                      #   /new-worktree — create git worktrees
  merge-worktrees.md                   #   /merge-worktrees — safely merge feature branches
  tmux-worktrees.md                    #   /tmux-worktrees — tmux session management
  setup-github-automation.md           #   /setup-github-automation — GitHub setup (includes quick mode)
.opencode/agents/                      # Custom subagents (2 core, 8 subagent, 6 specialist + 8 examples)
  core-openagent.md                    #   Primary universal agent
  core-opencoder.md                    #   Development orchestrator
  subagent-contextscout.md             #   Internal context discovery
  subagent-externalscout.md            #   External docs fetcher
  subagent-taskmanager.md              #   Task breakdown with Archon
  subagent-batchexecutor.md            #   Parallel execution coordinator
  subagent-coderagent.md               #   Atomic coding executor
  subagent-buildagent.md               #   Build validation runner
  subagent-testengineer.md             #   Test authoring specialist
  subagent-docwriter.md                #   Documentation specialist
  specialist-frontend.md               #   Frontend domain expert
  specialist-backend.md                #   Backend domain expert
  specialist-devops.md                 #   DevOps domain expert
  specialist-data.md                   #   Data domain expert
  specialist-copywriter.md             #   Copy/UX writing expert
  specialist-technical-writer.md       #   Technical docs expert
  _examples/                           #   Example agents (copy to activate)
    README.md                          #     How to use and customize examples
    research-codebase.md               #     Codebase exploration agent
    research-external.md               #     External docs research agent
    code-review-type-safety.md         #     Type safety reviewer
    code-review-security.md            #     Security vulnerability reviewer
    code-review-architecture.md        #     Architecture & patterns reviewer
    code-review-performance.md         #     Performance & optimization reviewer
    plan-validator.md                  #     Plan structure validator
    test-generator.md                  #     Test case suggestion agent
```
