# Custom LaunchAgents

macOS LaunchAgents that start background services at login. Templates use `__HOME__` placeholder since launchd doesn't expand `~` or `$HOME`.

## Agents

| File | Service | What it does |
|------|---------|-------------|
| `com.user.tmux.plist` | tmux server | Starts tmux at login with crash recovery via `~/.config/tmux/tmux-server.sh`. Sessions auto-restore via tmux-resurrect + tmux-continuum. |
| `com.claude.mcp-proxy.plist` | MCP proxy | Shared MCP server proxy (TBXark/mcp-proxy) so all Claude Code sessions connect via HTTP instead of spawning duplicate processes. |

## Install

```sh
# Replace __HOME__ with actual home dir and copy to ~/Library/LaunchAgents/
for f in ~/.config/launchagents/*.plist; do
    sed "s|__HOME__|$HOME|g" "$f" > ~/Library/LaunchAgents/$(basename "$f")
done

# Load them
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.tmux.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.claude.mcp-proxy.plist
```

## Verify

```sh
launchctl list | grep -E "tmux|mcp-proxy"
# Should show PIDs for both services
```

## Unload

```sh
launchctl bootout gui/$(id -u)/com.user.tmux
launchctl bootout gui/$(id -u)/com.claude.mcp-proxy
```

## Dependencies

- `com.user.tmux` requires: `/opt/homebrew/bin/tmux`, `~/.config/tmux/tmux-server.sh`, `exit-empty off` in tmux.conf
- `com.claude.mcp-proxy` requires: `~/.claude/mcp/bin/mcp-proxy`, `~/.claude/mcp/bin/start-proxy.sh`, `~/.claude/mcp/config.json`

## Logs

- tmux: `/tmp/tmux-launchd.log`
- MCP proxy: `~/.claude/mcp/proxy.log` and `proxy-error.log`
