---
name: temp-tmux
author: Vvkmnn
description: Create an isolated tmux session for testing apps (nvim, TUI, etc.) without affecting existing sessions. Uses a separate tmux server socket so test sessions never appear in the user's session list.
version: 0.3.0
---

# Isolated tmux Testing

Run real applications in a completely isolated tmux server. Test like a human -- no headless, no mocks, no pollution of existing sessions.

## Key Concept: Separate tmux Server

Use `tmux -L <socket>` to create a **separate tmux server** with its own socket. This is completely independent from the user's tmux -- it never shows up in their session list, never affects their windows/panes.

```bash
# This is INVISIBLE to the user's tmux
tmux -L claude-test new-session -d -s test -x 160 -y 50

# User's tmux sees nothing:
tmux list-sessions  # does NOT show "test"
```

## Workflow (all via Bash tool, NOT tmux MCP tools)

The tmux MCP tools use the user's default server. Always use **Bash** with `-L claude-test` flag instead.

### 1. Create isolated session

```bash
tmux -L claude-test kill-server 2>/dev/null  # clean slate
tmux -L claude-test new-session -d -s test -x 160 -y 50
```

### 2. Run app

```bash
tmux -L claude-test send-keys -t test "your-app --flags" Enter
sleep 3  # wait for app to initialize
```

### 3. Capture output

```bash
tmux -L claude-test capture-pane -t test -p
```

### 4. Send keystrokes

```bash
# Send a command (with Enter)
tmux -L claude-test send-keys -t test ":some-command" Enter
sleep 1
tmux -L claude-test capture-pane -t test -p

# Send raw keys (no Enter) for TUI navigation
tmux -L claude-test send-keys -t test "q"
tmux -L claude-test send-keys -t test Space
tmux -L claude-test send-keys -t test Escape
tmux -L claude-test send-keys -t test Up
tmux -L claude-test send-keys -t test C-c  # Ctrl+C
```

### 5. Cleanup (ALWAYS do this)

```bash
tmux -L claude-test kill-server
```

## Rules

- **NEVER use tmux MCP tools** (create-session, execute-command, etc.) -- those use the user's server
- **ALWAYS use Bash** with `tmux -L claude-test` for full isolation
- **ALWAYS kill-server when done** -- no orphaned servers
- **sleep after launch** -- give apps time to initialize before capturing
- **`-x 160 -y 50`** -- set explicit dimensions so TUI apps render properly

## Common Patterns

### Test a TUI app

```bash
tmux -L claude-test kill-server 2>/dev/null
tmux -L claude-test new-session -d -s test -x 160 -y 50
tmux -L claude-test send-keys -t test "your-app" Enter
sleep 4
tmux -L claude-test capture-pane -t test -p
# interact...
tmux -L claude-test send-keys -t test " "  # Space
sleep 2
tmux -L claude-test capture-pane -t test -p
# cleanup
tmux -L claude-test kill-server
```

### Run a command and capture output

```bash
tmux -L claude-test kill-server 2>/dev/null
tmux -L claude-test new-session -d -s test -x 200 -y 50
tmux -L claude-test send-keys -t test "some-command --with-flags 2>&1" Enter
sleep 3
tmux -L claude-test capture-pane -t test -p
tmux -L claude-test kill-server
```

### Multi-pane testing (e.g., server + client)

```bash
tmux -L claude-test kill-server 2>/dev/null
tmux -L claude-test new-session -d -s test -x 200 -y 50
# Start server in first pane
tmux -L claude-test send-keys -t test "server-command" Enter
sleep 3
# Split and run client in second pane
tmux -L claude-test split-window -h -t test
tmux -L claude-test send-keys -t test "client-command" Enter
sleep 2
# Capture each pane
tmux -L claude-test capture-pane -t test.0 -p  # left pane (server)
tmux -L claude-test capture-pane -t test.1 -p  # right pane (client)
# cleanup
tmux -L claude-test kill-server
```

### Long-running process with periodic checks

```bash
tmux -L claude-test kill-server 2>/dev/null
tmux -L claude-test new-session -d -s test -x 160 -y 50
tmux -L claude-test send-keys -t test "long-running-build" Enter
# Check progress later (separate Bash calls)
sleep 10
tmux -L claude-test capture-pane -t test -p
# Check again...
sleep 10
tmux -L claude-test capture-pane -t test -p
# cleanup when done
tmux -L claude-test kill-server
```
