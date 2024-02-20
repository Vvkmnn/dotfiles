return {
	{
		"folke/tokyonight.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins

		opts = {
			-- style = "day",
			-- style = "night",
			transparent = true,
		},
	},
	-- {"w0ng/vim-hybrid",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- },
	-- {
	--     "catppuccin/nvim",
	--     name = "catppuccin",
	--     lazy = false, -- make sure we load this during startup if it is your main colorscheme
	--     priority = 1000, -- make sure to load this before all the other start plugins
	--     opts = {
	--         -- style = "day",
	--         -- style = "night",
	--         flavour = "mocha",
	--         term_colors = true,
	--         transparent_background = true,
	--     },
	-- },
	--   {"RRethy/nvim-base16",
	-- lazy = false, -- make sure we load this during startup if it is your main colorscheme
	-- priority = 1000, -- make sure to load this before all the other start plugins
	--   },
	-- {
	-- 	"bluz71/vim-moonfly-colors",
	-- 	name = "moonfly",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	--
	-- 		vim.cmd([[colorscheme moonfly]])
	-- 	end,
	-- },
	-- "typicode/bg.nvim",
	--
	-- "ellisonleao/gruvbox.nvim",
	--
	-- {
	-- 	"catppuccin/nvim",
	-- 	name = "catppuccin",
	-- },
	--
	-- {
	-- 	"rose-pine/nvim",
	-- 	name = "rose-pine",
	-- },
	--
	-- "sainnhe/everforest",
	--
	-- "savq/melange-nvim",
	--
}
