#!/bin/bash
# Wrapper for mcp-proxy LaunchAgent
# Kills stale processes holding port 9090 before starting proxy.
# Prevents the KeepAlive restart loop where child processes (npm exec)
# hold the port after the parent proxy dies.

PORT=9090

# Kill anything still holding the port from a previous instance
stale_pids=$(lsof -ti:"$PORT" 2>/dev/null)
if [ -n "$stale_pids" ]; then
    echo "Killing stale processes on port $PORT: $stale_pids"
    echo "$stale_pids" | xargs kill 2>/dev/null
    sleep 2
    # Force-kill any survivors
    stale_pids=$(lsof -ti:"$PORT" 2>/dev/null)
    if [ -n "$stale_pids" ]; then
        echo "Force-killing remaining processes: $stale_pids"
        echo "$stale_pids" | xargs kill -9 2>/dev/null
        sleep 1
    fi
fi

exec "$HOME/.claude/mcp/bin/mcp-proxy" --config "$HOME/.claude/mcp/config.json"
