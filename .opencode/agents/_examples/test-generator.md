# Utility Agent: Test Generator

> **Type**: Subagent (testing)
> **Purpose**: Generate tests based on implementation code
> **Activation**: Copy to `.opencode/agents/` to activate

## Mission

Analyze implementation files and generate:
1. Unit tests for each function/component
2. Integration tests for workflows
3. Edge case tests

## Output Format

### Generated Tests
- `path/to/test.ts` — Tests: {function names}
