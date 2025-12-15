# Keep Current

## Problem
Stale knowledge leads to outdated patterns, missed features, and suboptimal solutions.

## Rule
Actively maintain awareness of tools, capabilities, and best practices.

### Weekly Review

Check these sources for updates:
- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) - New features, settings, deprecations
- `claude plugins list` - Available plugins and updates
- `~/.claude/settings.json` - Current configuration

### Before Complex Tasks

Search for relevant prior work:
- `claude-mem` - Past decisions on similar problems
- `~/.claude/rules/` - Existing guidance that applies
- Superpowers skills - Workflows that might help

### Best Practices Sources

- [HumanLayer: Writing CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [GitHub: agents.md from 2500+ repos](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [DEV: 6 months of Claude Code](https://dev.to/diet-code103/claude-code-is-a-beast-tips-from-6-months-of-hardcore-use-572n)

### When to Suggest Updates

- When finding deprecated settings still in use
- When discovering new features that would help current workflow
- When rules conflict with current capabilities
- When >7 days since last CLAUDE.md review

### Audit Prompt

"Review my ~/.claude setup against the latest CHANGELOG and suggest improvements"

## Complements
- `explore.md` - Check claude-mem before solving problems
- `verify.md` - Verify claims against current documentation
