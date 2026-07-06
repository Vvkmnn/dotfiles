---
name: configure-neovim
author: Vvkmnn
description: This skill guides working with Neovim configuration including testing changes headlessly, managing plugins with lazy.nvim, configuring LSP servers, and troubleshooting startup errors. Use this when modifying nvim config files or debugging nvim issues.
allowed-tools: [Bash, Read, Write, Edit]
---

# Configuring Neovim

This skill provides patterns for modifying and testing Neovim configuration safely and efficiently.

## What This Skill Does

- Tests nvim configuration changes without manual launch
- Verifies plugins load correctly via headless testing
- Configures LSP servers with mason.nvim
- Debugs startup errors and plugin loading issues
- Tests LSP attachment and functionality
- Manages plugin configuration with lazy.nvim

## Key Technique: Headless Testing

The critical pattern for working with nvim configuration is **testing headlessly** before manually launching nvim. This catches errors immediately without disrupting your workflow.

### Basic Headless Test

```bash
# Test if nvim loads without errors
nvim --headless -c "echo 'Config loaded successfully'" -c "quit" 2>&1
```

**What this does:**
- `--headless`: Run without UI
- `-c "command"`: Execute vim command
- `-c "quit"`: Exit after commands
- `2>&1`: Capture stderr to see errors

**Success output:**
```
Config loaded successfully
```

**Error output shows:**
- File and line number where error occurred
- Stack trace
- Specific error message

### Testing Specific Features

```bash
# Test plugin loading
nvim --headless -c "lua print('Plugins loaded')" -c "sleep 2" -c "quit" 2>&1

# Test LSP configuration
nvim --headless -c "lua print('LSP config:', vim.inspect(vim.lsp))" -c "quit" 2>&1

# Test with a specific file type
cd /tmp && echo 'print("test")' > test.lua && \
  nvim --headless test.lua -c "lua print('Buffer filetype:', vim.bo.filetype)" -c "quit" 2>&1
```

### Testing LSP Server Attachment

```bash
# Test if LSP attaches to a buffer (requires servers installed)
cd /tmp && echo 'print("hello")' > test.lua && \
  nvim --headless test.lua \
    -c "lua vim.defer_fn(function() print('LSP clients:', vim.inspect(vim.lsp.get_clients())) end, 2000)" \
    -c "sleep 3" \
    -c "quit" 2>&1 | grep -A5 "LSP clients"
```

**Why defer_fn?** LSP servers need time to start and attach. The 2000ms delay allows initialization.

## Prerequisites

### Required Tools
- **nvim** - Neovim 0.9+
- **git** - For plugin installation

### Configuration Location
- Main config: `~/.config/nvim/init.lua`
- Plugins: `~/.config/nvim/lua/plugins/*.lua`
- User config: `~/.config/nvim/lua/user/*.lua`
- Plugin manager: `~/.config/nvim/lua/config/lazy.lua`

## Common Configuration Tasks

### Adding a New Plugin

1. **Create plugin file** in `~/.config/nvim/lua/plugins/`:

```lua
-- ~/.config/nvim/lua/plugins/my-plugin.lua
return {
  "username/plugin-name",
  lazy = false,  -- Load immediately (or set to true for lazy loading)
  config = function()
    require("plugin-name").setup({
      -- Plugin configuration here
    })
  end,
}
```

2. **Test the plugin loads** without errors:

```bash
nvim --headless -c "lua print('Testing plugin load')" -c "sleep 2" -c "quit" 2>&1
```

3. **Launch nvim normally** - lazy.nvim will auto-install the plugin

### Configuring LSP with Mason

The modern approach uses three plugins:
- `mason.nvim` - Installs language servers
- `mason-lspconfig.nvim` - Bridges mason and lspconfig
- `nvim-lspconfig` - Configures LSP clients

**Recommended structure** (`~/.config/nvim/lua/plugins/lsp.lua`):

```lua
return {
  -- Mason for installing language servers
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("mason").setup()
    end,
  },

  -- LSP configuration (load early as dependency)
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },

  -- Mason-lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Setup mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",      -- Lua
          "pyright",     -- Python
          "ts_ls",       -- TypeScript/JavaScript
          "rust_analyzer", -- Rust
          -- Add more servers as needed
        },
      })

      -- Define on_attach for keymaps
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Navigation
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gr", vim.lsp.buf.references, "Go to references")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")
      end

      -- Get capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure each server
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      -- Add more server configs as needed
    end,
  },
}
```

**Test LSP config loads:**

```bash
nvim --headless -c "lua print('Testing LSP')" -c "sleep 2" -c "quit" 2>&1
```

**Common errors:**
- `attempt to call field 'setup_handlers'` - Don't use `setup_handlers`, configure servers manually
- `module 'cmp_nvim_lsp' not found` - Add nvim-cmp as dependency
- Priority issues - Set explicit `priority` values (1000, 900, 800)

### Modifying Existing Configuration

1. **Read the current config:**

```bash
cat ~/.config/nvim/lua/plugins/target-plugin.lua
```

2. **Make your changes** using the Edit tool

3. **Test headlessly immediately:**

```bash
nvim --headless -c "lua print('Config updated')" -c "quit" 2>&1
```

4. **If errors appear**, fix them before launching nvim normally

5. **Launch nvim** to verify behavior

## Verification Workflows

### After Plugin Changes

```bash
# Check plugin loads
nvim --headless -c "lua print('Plugins OK')" -c "sleep 2" -c "quit" 2>&1

# Check for errors (should be empty)
nvim --headless -c "quit" 2>&1 | grep -i error
```

### After LSP Changes

```bash
# Verify LSP config loads
nvim --headless -c "lua print('LSP:', vim.inspect(vim.lsp))" -c "quit" 2>&1

# Test with actual file (after servers installed)
cd /tmp && echo 'def hello(): pass' > test.py && \
  nvim --headless test.py -c "sleep 3" -c "lua print('Clients:', #vim.lsp.get_clients())" -c "quit" 2>&1
```

### After Keymap Changes

```bash
# Check specific keymap exists
nvim --headless -c "lua print('Leader key:', vim.g.mapleader)" -c "quit" 2>&1
```

## Troubleshooting, Best Practices, Patterns & Advanced Topics

Moved to `references/deep-dive.md` — troubleshooting flows, best-practice guidance, common patterns, and advanced topics. Read when a config change fails or when designing something non-trivial.

## Quick Reference Commands

```bash
# Test config loads
nvim --headless -c "quit" 2>&1

# Test with delay for async operations
nvim --headless -c "sleep 2" -c "quit" 2>&1

# Test LSP configuration
nvim --headless -c "lua print(vim.inspect(vim.lsp))" -c "quit" 2>&1

# Test with specific file type
nvim --headless test.lua -c "quit" 2>&1

# Check plugin installation
ls ~/.local/share/nvim/lazy/

# Check LSP servers installed
ls ~/.local/share/nvim/mason/bin/

# Profile startup time
nvim --startuptime startup.log -c "quit" && tail -20 startup.log

# Launch with no config (debugging)
nvim -u NONE

# Force plugin sync
nvim --headless -c "lua require('lazy').sync()" -c "sleep 10" -c "quit"
```

## Related Skills

- **Creating Claude Code Skills** - For documenting reusable nvim patterns as skills
- **Git Workflows** - For version controlling nvim config changes

## Summary

The most important practice: **always test nvim config changes headlessly before launching nvim manually**. This catches errors immediately and shows you exactly where the problem is.

The basic workflow:
1. Edit config
2. `nvim --headless -c "quit" 2>&1`
3. Fix any errors shown
4. Repeat until clean
5. Launch nvim normally

This saves enormous amounts of time and frustration compared to trial-and-error with manual launches.
