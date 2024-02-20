return {
	-- {
	-- 	"rcarriga/nvim-notify",
	-- 	-- keys = {
	-- 	-- 	{
	-- 	-- 		"<leader>un",
	-- 	-- 		function()
	-- 	-- 			require("notify").dismiss({ silent = true, pending = true })
	-- 	-- 		end,
	-- 	-- 		desc = "dismiss all notifications",
	-- 	-- 	},
	-- 	-- },
	-- 	opts = {
	-- 		timeout = 3000,
	-- 		max_height = function()
	-- 			return math.floor(vim.o.lines * 0.75)
	-- 		end,
	-- 		max_width = function()
	-- 			return math.floor(vim.o.columns * 0.75)
	-- 		end,
	-- 	},
	-- 	-- init = function()
	-- 	-- 	-- when noice is not enabled, install notify on verylazy
	-- 	-- 	local util = require("lazyvim.util")
	-- 	-- 	if not util.has("noice.nvim") then
	-- 	-- 		util.on_very_lazy(function()
	-- 	-- 			vim.notify = require("notify")
	-- 	-- 		end)
	-- 	-- 	end
	-- 	-- end,
	-- },
	{
		"notjedi/nvim-rooter.lua",
		config = function()
			require("nvim-rooter").setup({})
		end,
	},
	-- {
	-- -- TODO doesn't do much?
	-- 	"declancm/cinnamon.nvim",
	-- 	config = function()
	-- 		require("cinnamon").setup()
	-- 	end,
	-- },
	-- {
	-- 	"nvim-tree/nvim-tree.lua",
	-- 	config = function()
	-- 		require("nvim-tree").setup({
	-- 			sort_by = "case_sensitive",
	-- 			-- view = { width = 30, },
	-- 			-- renderer = { group_empty = true, },
	-- 			filters = { dotfiles = true },
	--
	-- 			update_cwd = true,
	-- 			update_focused_file = {
	-- 				enable = true,
	-- 				update_cwd = true,
	-- 			},
	-- 		})
	-- 	end,
	-- },
	-- {
	-- 	"ahmedkhalf/project.nvim",
	-- 	dependencies = {
	-- 		"nvim-telescope/telescope.nvim"
	-- 	},
	-- 	config = function()
	-- 		require("project_nvim").setup({})
	-- 		require('telescope').load_extension('projects')
	-- 	end,
	-- },
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- fuzzy finder algorithm which requires local dependencies to be built. only load if `make` is available
			{ "nvim-telescope/telescope-fzf-native.nvim", 
				build = "make", 
				cond = vim.fn.executable("make") == 1 },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<c-u>"] = false,
							["<c-d>"] = false,
						},
					},
				},
			})

			-- Enable telescope fzf native, if installed
			-- pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "fzf_native")

			local map = require("helpers.keys").map

			map("n", "<leader>/", function()
				-- You can pass additional configuration to telescope to change theme, layout, etc.
				require("telescope.builtin").current_buffer_fuzzy_find(
					require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
				)
			end, "Search in current buffer")

			-- TODO do you use this enough?
			map("n", "<leader><space>", require("telescope.builtin").buffers, "Open buffers")
			map("n", "<leader><c-r>", require("telescope.builtin").oldfiles, "Recently opened")
			map("n", "<leader><c-f>", require("telescope.builtin").find_files, "Files") -- ({ hidden = true}) causes crash
			map("n", "<leader><c-h>", require("telescope.builtin").help_tags, "Help")
			map("n", "<leader><c-w>", require("telescope.builtin").grep_string, "Current word")
			map("n", "<leader><c-g>", require("telescope.builtin").live_grep, "Grep")
			map("n", "<leader><c-d>", require("telescope.builtin").diagnostics, "Diagnostics")

			map("n", "<C-p>", require("telescope.builtin").keymaps, "Search keymaps")
		end,
	},
	-- {
	-- 	"prichrd/netrw.nvim",
	-- 	dependencies = {
	-- 		"nvim-tree/nvim-web-devicons",
	-- 	},
	-- },
	{
		"stevearc/oil.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			keymaps = {
				["?"] = "actions.show_help",
			},
			view_options = {
				show_hidden = true,
			},
		},
		-- config = function()
		-- 	require("oil").setup({})
		-- end,
	},

	{
		"tpope/vim-repeat",
		event = "VeryLazy",
	},

	-- PERF
	-- NOTE
	-- FIXME
	-- TODO Neither does any higlighting
	-- {
	--   "folke/todo-comments.nvim",
	--   dependencies = { "nvim-lua/plenary.nvim" },
	--   opts = {
	--     -- your configuration comes here
	--     -- or leave it empty to use the default settings
	--     -- refer to the configuration section below
	--   }
	-- },
	-- {
	-- 	"folke/todo-comments.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- 	cmd = { "TodoTrouble", "TodoTelescope" },
	-- 	event = { "BufReadPost", "BufNewFile" },
	-- 	-- config = true,
	-- 	-- stylua: ignore
	-- 	keys = {
	-- 		{ "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
	-- 		{
	-- 			"[t",
	-- 			function() require("todo-comments").jump_prev() end,
	-- 			desc =
	-- 			"Previous todo comment"
	-- 		},
	-- 		{ "<leader>xt", "<cmd>TodoTrouble<cr>",                              desc = "Todo (Trouble)" },
	-- 		{
	-- 			"<leader>xT",
	-- 			"<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",
	-- 			desc =
	-- 			"Todo/Fix/Fixme (Trouble)"
	-- 		},
	-- 		{ "<leader>st", "<cmd>TodoTelescope<cr>",                         desc = "Todo" },
	-- 		{ "<eader>sT",  "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
	-- 	},
	-- },
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"folke/which-key.nvim",
		config = function()
			local wk = require("which-key")
			wk.setup()
			wk.register({
				["<leader>"] = {
					f = { name = "File" },
					d = { name = "Delete/Close" },
					q = { name = "Quit" },
					s = { name = "Search" },
					l = { name = "LSP" },
					u = { name = "UI" },
					b = { name = "Debugging" },
					g = { name = "Git" },
				},
			})
		end,
	},
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		opts = {},
	},
	-- {
	--   "echasnovski/mini.surround",
	--   keys = function(_, keys)
	--     -- Populate the keys based on the user's options
	--     local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
	--     local opts = require("lazy.core.plugin").values(plugin, "opts", false)
	--     local mappings = {
	--       { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
	--       { opts.mappings.delete, desc = "Delete surrounding" },
	--       { opts.mappings.find, desc = "Find right surrounding" },
	--       { opts.mappings.find_left, desc = "Find left surrounding" },
	--       { opts.mappings.highlight, desc = "Highlight surrounding" },
	--       { opts.mappings.replace, desc = "Replace surrounding" },
	--       { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
	--     }
	--     mappings = vim.tbl_filter(function(m)
	--       return m[1] and #m[1] > 0
	--     end, mappings)
	--     return vim.list_extend(mappings, keys)
	--   end,
	--   opts = {
	--     mappings = {
	--       add = "gza", -- Add surrounding in Normal and Visual modes
	--       delete = "gzd", -- Delete surrounding
	--       find = "gzf", -- Find surrounding (to the right)
	--       find_left = "gzF", -- Find surrounding (to the left)
	--       highlight = "gzh", -- Highlight surrounding
	--       replace = "gzr", -- Replace surrounding
	--       update_n_lines = "gzn", -- Update `n_lines`
	--     },
	--   },
	-- }
	-- {
	-- 	"nvim-neo-tree/neo-tree.nvim",
	-- 	branch = "v2.x",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-tree/nvim-web-devicons",
	-- 		"MunifTanjim/nui.nvim",
	-- 	},
	-- 	config = function()
	-- 		require("neo-tree").setup({
	-- 			filesystem = {
	-- 				hijack_netrw_behavior = "open_current",
	-- 				-- hijack_netrw_behavior = "disabled",
	-- 			},
	-- 		})
	-- 		require("helpers.keys").map(
	-- 			{ "n", "v" },
	-- 			"<leader>e",
	-- 			"<cmd>NeoTreeRevealToggle<cr>",
	-- 			"Toggle file explorer"
	-- 		)
	-- 	end,
	-- },
}
