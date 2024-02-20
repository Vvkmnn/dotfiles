-- Miscelaneous fun stuff
return {
	{
		"kwkarlwang/bufresize.nvim",
		config = function()
			require("bufresize").setup()
		end,
	},
	{
		-- light statusline
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			-- local colorscheme = require("helpers.colorscheme")
			-- local lualine_theme = colorscheme == "default" and "auto" or colorscheme
			require("lualine").setup({
				options = {
					icons_enabled = true,
					-- theme = lualine_theme,
					component_separators = "|",
					section_separators = "",
				},
			})
		end,
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
		"nvim-telescope/telescope.nvim",
		event = { "BufReadPost", "BufNewFile" },
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- fuzzy finder algorithm which requires local dependencies to be built. only load if `make` is available
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
			-- "ahmedkhalf/project.nvim",
			-- "desdic/telescope-rooter.nvim",
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
			-- map("n", "<leader><c-f>", require("telescope.builtin").find_files, "Files")

			map("n", "<leader><c-f>", function()
				require("telescope.builtin").find_files({
					cwd = (vim.v.shell_error == 0 and vim.fn.systemlist("git rev-parse --show-toplevel")[1])
						or vim.lsp.get_active_clients()[1].config.root_dir,
					hidden = true,
				})
			end, "Files")
			--
			map("n", "<leader><c-h>", require("telescope.builtin").help_tags, "Help")
			map("n", "<leader><c-w>", require("telescope.builtin").grep_string, "Current word")
			map("n", "<leader><c-g>", require("telescope.builtin").live_grep, "Grep")
			map("n", "<leader><c-d>", require("telescope.builtin").diagnostics, "Diagnostics")
			map("n", "<leader><c-k>", require("telescope.builtin").keymaps, "Search keymaps")

			-- Extensions
			-- require "telescope".load_extension("rooter")
			-- require('project_nvim').setup({})
			-- require('telescope').load_extension('projects')
			-- map("n", "<leader><c-p>", function ()
			-- 	require("telescope").extensions.projects.search_in_project_files
			-- 	end, "Search projects")

			-- require('telescope').load_extension('projects')
			-- map("n", "<leader><c-p>", require("telescope").extensions.projects.projects{}, "Show projects")

			-- 	local actions = require("telescope.actions")
			-- 	local trouble = require("trouble.providers.telescope")
			--
			-- 	require("telescope").setup({
			-- 		  defaults = {
			-- 			    mappings = {
			-- 				      i = { ["<c-t>"] = trouble.open_with_trouble },
			-- 				      n = { ["<c-t>"] = trouble.open_with_trouble },
			-- 				    },
			-- 			  },
			-- })
		end,
	},

	-- {
	-- 	"akinsho/bufferline.nvim",
	-- 	version = "v3.*",
	-- 	dependencies = "nvim-tree/nvim-web-devicons",
	-- 	opts = {
	-- 			-- separator_style = "padded_slant",
	-- 	},
	-- config = function()
	-- 	require("bufferline").setup({
	-- 		separator_style = "padded_slant"
	-- 		-- vim.cmd([[
	-- 		-- 	augroup MyColors
	-- 		-- 	autocmd!
	-- 		--
	-- 		-- 	autocmd ColorScheme * highlight BufferLineFill guibg=#191724
	-- 		--
	-- 		-- 	autocmd ColorScheme * highlight BufferLineSeparator guifg=#191724
	-- 		--
	-- 		-- 	autocmd ColorScheme * highlight BufferLineSeparatorSelected guifg=#191724
	-- 		--
	-- 		-- 	augroup END
	-- 		-- 	]])
	-- 	})
	-- end
	-- },
	-- Comment with haste
}
