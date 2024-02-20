local opts = {
	shiftwidth = 4,
	tabstop = 4,
	expandtab = true,
	wrap = false,
	termguicolors = true,
	-- termguicolors = false,
	number = true,
	relativenumber = true,
	autochdir = true,
	-- scrolloff = 7, -- +- 7 lines
	-- scrolloff = 999, -- center line
	lazyredraw = true, -- redraw after events
	-- loaded_netrw =1,
	-- loaded_netrwPlugin=1
	equalalways = true
}

-- Set options from table
for opt, val in pairs(opts) do
	vim.o[opt] = val
end

-- Set other options
local colorscheme = require("helpers.colorscheme")
vim.cmd.colorscheme(colorscheme)
