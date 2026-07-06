# Troubleshooting, Best Practices & Advanced Topics

> Moved verbatim from SKILL.md (lines 256-521 + 558-589) in the 2026-07-06 restructure. Load on failure or deep-dive, not for routine config edits.

## Troubleshooting

### Error: Failed to run `config` for plugin

**Symptom:** Error during plugin config function execution

**Cause:** Lua error in plugin's `config = function()` block

**Solution:**
1. Look at the stack trace for file:line number
2. Read the specific line in the config file
3. Common issues:
   - Calling function that doesn't exist yet (dependency loading order)
   - Typo in module name
   - Missing `require()` statement

**Fix dependency loading:**
```lua
-- Add explicit dependencies and priority
{
  "my-plugin",
  dependencies = { "required-plugin" },
  priority = 900,  -- Lower number = loads later
}
```

### Error: Module not found

**Symptom:** `module 'xyz' not found`

**Cause:** Plugin not installed or wrong name

**Solution:**
```bash
# Check if plugin directory exists
ls ~/.local/share/nvim/lazy/

# Launch nvim normally to let lazy.nvim install
nvim

# Or force plugin sync
nvim --headless -c "lua require('lazy').sync()" -c "sleep 5" -c "quit"
```

### Error: Attempt to call field (a nil value)

**Symptom:** `attempt to call field 'setup' (a nil value)`

**Cause:**
- Function doesn't exist in that module
- Module not loaded yet
- Wrong module name

**Solution:**
1. Verify correct module name in plugin docs
2. Check if module needs to be required first
3. Ensure dependencies load before this plugin

### LSP Not Attaching

**Symptom:** LSP features don't work, no diagnostics

**Diagnosis:**
```bash
# Check if LSP clients exist
nvim some-file.lua -c "lua vim.defer_fn(function() print(vim.inspect(vim.lsp.get_clients())) end, 2000)" -c "sleep 3" -c "quit"
```

**Common causes:**
1. **Server not installed** - Run `:Mason` in nvim to install
2. **Server not configured** - Add to lspconfig setup
3. **File type not detected** - Check `:set filetype?` in nvim
4. **Server crashed** - Check `:LspInfo` for errors

**Solution:**
```bash
# Verify mason installed servers
ls ~/.local/share/nvim/mason/bin/

# Check server executable works
~/.local/share/nvim/mason/bin/lua-language-server --version
```

### Deprecation Warning: lspconfig framework deprecated

**Symptom:** Warning about `require('lspconfig')` being deprecated

**Cause:** Neovim 0.11+ has new LSP config API

**Impact:** Warning only - still works fine

**Future fix:** Migration guide will be available when nvim-lspconfig v3.0.0 releases

### Performance: Slow Startup

**Diagnosis:**
```bash
# Profile startup time
nvim --startuptime startup.log -c "quit"
cat startup.log | tail -20
```

**Common causes:**
- Too many plugins loading at startup
- Heavy plugins not lazy-loaded
- Expensive config functions

**Solution:**
```lua
-- Lazy load plugins
{
  "heavy-plugin",
  lazy = true,  -- Don't load at startup
  event = "VeryLazy",  -- Load after UI renders
  -- or
  cmd = "PluginCommand",  -- Load on command
  -- or
  ft = "python",  -- Load on filetype
}
```

## Best Practices

### Always Test Headlessly First

```bash
# GOOD: Test before manual launch
nvim --headless -c "echo 'OK'" -c "quit" 2>&1 && echo "Safe to launch nvim"

# BAD: Edit config, launch nvim, hit error, can't see anything
nvim  # Might crash immediately
```

### Use Explicit Loading Order

```lua
-- For plugins that depend on each other, set priorities
{
  "base-plugin",
  priority = 1000,  -- Loads first
}
{
  "dependent-plugin",
  priority = 900,   -- Loads second
  dependencies = { "base-plugin" },
}
```

### Keep Configs Modular

```
~/.config/nvim/
├── init.lua              # Entry point (minimal)
├── lua/
│   ├── config/
│   │   └── lazy.lua      # Plugin manager setup
│   ├── plugins/          # One file per plugin
│   │   ├── lsp.lua
│   │   ├── telescope.lua
│   │   └── treesitter.lua
│   └── user/             # User settings
│       ├── mappings.lua
│       └── settings.lua
```

**Benefits:**
- Easy to find/edit specific plugin config
- Can remove plugins by deleting one file
- Clear separation of concerns

### Document Your Configurations

```lua
-- Good: Explain why
{
  "williamboman/mason.nvim",
  priority = 1000,  -- Must load before mason-lspconfig
  lazy = false,     -- Required at startup for LSP
  config = function()
    require("mason").setup()
  end,
}

-- Bad: No context
{
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup()
  end,
}
```

### Test in Clean Environment

When debugging mysterious issues:

```bash
# Start nvim with no config
nvim -u NONE

# Start with minimal config
echo "vim.opt.number = true" > /tmp/minimal.lua
nvim -u /tmp/minimal.lua
```

### Back Up Before Major Changes

```bash
# Before restructuring LSP config
cp ~/.config/nvim/lua/plugins/lsp.lua ~/.config/nvim/lua/plugins/lsp.lua.backup

# Or use git
cd ~/.config/nvim
git diff  # Review changes
git checkout -- file.lua  # Revert if needed
```

## Common Patterns

### Testing a Complete Config Change

```bash
# 1. Make your changes
# 2. Test headlessly
nvim --headless -c "quit" 2>&1

# 3. If errors, see the stack trace and fix
# 4. When clean, test with a file
cd /tmp && echo 'test' > test.txt && nvim --headless test.txt -c "quit" 2>&1

# 5. Launch normally
nvim
```

### Adding a Language Server

```bash
# 1. Add to ensure_installed in lsp.lua
# 2. Add server config in lsp.lua
# 3. Test config loads
nvim --headless -c "quit" 2>&1

# 4. Launch nvim - mason auto-installs
nvim

# 5. Wait for mason to finish installing
# 6. Open a file of that language
# 7. Verify LSP attached: :LspInfo
```

### Removing a Plugin

```bash
# 1. Delete plugin file
rm ~/.config/nvim/lua/plugins/unwanted-plugin.lua

# 2. Test config loads
nvim --headless -c "quit" 2>&1

# 3. Launch nvim
nvim

# 4. Clean up plugin directory
# In nvim: :Lazy clean
```


## Advanced Topics

### Testing Specific Plugin Loading

```bash
# Test if specific plugin is loaded
nvim --headless -c "lua print('Telescope:', require('telescope') ~= nil)" -c "quit" 2>&1
```

### Debugging Plugin Load Order

```bash
# Add prints in config functions to trace loading
config = function()
  print("Loading plugin X...")
  require("plugin").setup()
  print("Plugin X loaded")
end
```

### Testing Keymaps Work

```bash
# Open file and try keymap programmatically
nvim --headless test.lua \
  -c "normal gd" \
  -c "echo 'Keymap executed'" \
  -c "quit" 2>&1
```

This pattern lets you verify keymaps trigger without manual testing.

