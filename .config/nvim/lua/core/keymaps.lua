local map = require("helpers.keys").map

-- Escape via jj or jk in insert mode
-- map("i", "jj", "<ESC>")
-- map("i", "jk", "<esc>")

-- Quick access to some common actions
map("n", "<leader>fw", "<cmd>w<cr>", "Write")
map("n", "<leader>fa", "<cmd>wa<cr>", "Write all")
map("n", "<leader>qq", "<cmd>q<cr>", "Quit")
map("n", "<leader>qa", "<cmd>qa!<cr>", "Quit all")
map("n", "<leader>dw", "<cmd>close<cr>", "Window")

-- Diagnostic keymaps
map('n', 'gx', vim.diagnostic.open_float, "Show diagnostics under cursor")

-- Easier access to beginning and end of lines
map("n", "<M-h>", "^", "Go to beginning of line")
map("n", "<M-l>", "$", "Go to end of line")

-- Better window navigation
map("n", "<C-h>", "<C-w><C-h>", "Navigate windows to the left")
map("n", "<C-j>", "<C-w><C-j>", "Navigate windows down")
map("n", "<C-k>", "<C-w><C-k>", "Navigate windows up")
map("n", "<C-l>", "<C-w><C-l>", "Navigate windows to the right")

-- Move with shift-arrows
map("n", "<S-Left>", "<C-w><S-h>", "Move window to the left")
map("n", "<S-Down>", "<C-w><S-j>", "Move window down")
map("n", "<S-Up>", "<C-w><S-k>", "Move window up")
map("n", "<S-Right>", "<C-w><S-l>", "Move window to the right")

-- Resize with arrows
map("n", "<C-Up>", ":resize +2<CR>")
map("n", "<C-Down>", ":resize -2<CR>")
map("n", "<C-Left>", ":vertical resize +2<CR>")
map("n", "<C-Right>", ":vertical resize -2<CR>")

-- Deleting buffers
local buffers = require("helpers.buffers")
map("n", "<leader>db", buffers.delete_this, "Current buffer")
map("n", "<leader>do", buffers.delete_others, "Other buffers")
map("n", "<leader>da", buffers.delete_all, "All buffers")

-- Navigate buffers
map("n", "<S-l>", ":bnext<CR>")
map("n", "<S-h>", ":bprevious<CR>")
-- map("n", "<S-j>", ":bnext<CR>")
-- map("n", "<S-k>", ":bprevious<CR>")

-- Stay in indent mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Switch between light and dark modes
map("n", "<leader>ut", function()
	if vim.o.background == "dark" then
		vim.o.background = "light"
	else
		vim.o.background = "dark"
	end
end, "Toggle between light and dark themes")

-- Clear after search
map("n", "<leader>ur", "<cmd>nohl<cr>", "Clear highlights")



-- Ctrl+S to Save
map('n', '<C-S>', ':update!<CR>')
map('v', '<C-S>', '<C-C>:update!<CR>')
map('i', '<C-S>', '<C-O>:update!<CR>')

-- Ctrl+Q to Quit
-- map("n", "<C-Q>", ":exit<CR>")
-- map("v", "<C-Q>", "<C-C>:exit<CR>")
-- map("i", "<C-Q>", "<C-O>:exit<CR>")
map("n", "<C-Q>", ":q<CR>")
map("v", "<C-Q>", "<C-C>:q<CR>")
map("i", "<C-Q>", "<C-O>:q<CR>")

-- Ctrl Arrow Buffer Navigation
-- map('n', '<C-Right>', '<c-w>l')
-- map('n', '<C-Left>', '<c-w>h')
-- map('n', '<C-Up>', '<c-w>k')
-- map('n', '<C-Down>', '<c-w>j')

-- Ctrl HJKL Split Navigation
-- map('n', '<C-H>', '<C-W><C-H>')
-- map('n', '<C-J>', '<C-W><C-J>')
-- map('n', '<C-K>', '<C-W><C-K>')
-- map('n', '<C-L>', '<C-W><C-L>')

-- Sort in Visual Mode
map("v", "<Leader>s", ":sort<CR>")

-- Fix for Vim on WSL
-- https://stackoverflow.com/questions/51388353/vim-changes-into-replace-mode-on-startup
map("n", "<esc>^[", "<esc>^[")

-- W for sudo :w
vim.cmd("command W execute ':silent w !sudo tee % > /dev/null' | edit!")
