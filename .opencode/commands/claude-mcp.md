---
description: List MCP servers and their status
argument-hint: [list|auth|add|remove|debug]
allowed-tools: Bash
---

# MCP: Manage MCP Servers

## Context (INPUT)

MCP (Model Context Protocol) servers provide external tools to OpenCode. This command wraps `claude mcp` for quick access.

## Process (PROCESS)

If `$ARGUMENTS` is empty or "list":
```bash
claude mcp list
```

If `$ARGUMENTS` starts with "auth":
```bash
claude mcp auth $2
```

If `$ARGUMENTS` starts with "add":
```bash
claude mcp add $2 $3 $4 $5 $6 $7 $8 $9
```

If `$ARGUMENTS` starts with "remove":
```bash
claude mcp remove $2
```

If `$ARGUMENTS` starts with "debug":
```bash
claude mcp debug $2
```

## Output (OUTPUT)

### Server Status
- Show connection status for each server
- Display transport type (local/HTTP)
- Show tool availability

### Quick Reference
- `/mcp` - List all servers
- `/mcp auth [server]` - Authenticate with server
- `/mcp add [args]` - Add new server (use `claude mcp add --help` for syntax)
- `/mcp remove [server]` - Remove server
- `/mcp debug [server]` - Debug connection
