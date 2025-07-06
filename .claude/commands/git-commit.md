---
allowed-tools: Bash(git:*), Bash(ls:*)  
description: Create a well-formatted git commit for Neovim configuration changes
---

## Context
- Current status: !`git status`
- Current branch: !`git branch --show-current`
- Changed files: !`git diff --name-only`
- Staged changes: !`git diff --cached --name-only`

## Commit Message Format
Follow conventional commits for Neovim config:

```
type(scope): description

- Detailed changes
- Impact on functionality
- Any breaking changes
```

### Types
- **feat**: New plugin or feature
- **fix**: Bug fix or correction
- **config**: Configuration changes
- **refactor**: Code restructuring
- **docs**: Documentation updates
- **chore**: Maintenance tasks

### Scopes
- **plugin**: Plugin-related changes
- **config**: Core configuration
- **keymaps**: Keymap changes
- **lsp**: LSP configuration
- **ui**: Interface changes

## Examples
```
feat(plugin): add nvim-surround for text manipulation

- Configured nvim-surround with LazyVim integration
- Added keymaps following LazyVim conventions
- Lazy-loaded on text object usage

config(lsp): update TypeScript server settings

- Enabled inlay hints for better type visibility
- Configured auto-imports and code actions
- Updated Mason to install latest typescript-language-server
```

## Pre-commit Checklist
1. **Test configuration**: Ensure Neovim starts without errors
2. **Check syntax**: Validate Lua files with `luac -p`
3. **Review changes**: Use `:Lazy` to verify plugin status
4. **Update CLAUDE.md**: Document complex changes
5. **Stage relevant files**: Only commit intended changes