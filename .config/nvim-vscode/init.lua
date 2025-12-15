-- Minimal LazyVim setup meant for the VSCode Neovim extension profile
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.vscode" },
    -- Turn off Flash overlays inside VSCode to keep native motions.
    { "folke/flash.nvim", enabled = false },
  },
  defaults = {
    -- lazy = true,
    version = false,
  },
  checker = {
    enabled = false,
    notify = false,
  },
})
