return {
	-- {
	-- 	"HampusHauffman/block.nvim",
	-- 	config = function()
	-- 		require("block").setup({
	-- 			percent = 0.8,
	-- 			depth = 4,
	-- 			colors = nil,
	-- 			automatic = false,
	-- 			bg = nil,
	-- 		})
	-- 	end,
	-- },
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.clang_format,
					null_ls.builtins.formatting.black,
					null_ls.builtins.formatting.isort,
					null_ls.builtins.formatting.shfmt,
					null_ls.builtins.formatting.prettier,
					-- null_ls.builtins.diagnostics.shellcheck,
					-- null_ls.builtins.code_actions.shellcheck,
				},
			})
		end,
	},
	{
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		-- event = "VeryLazy",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip", -- NOTE very slow
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},

		build = (not jit.os:find("Windows"))
				and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
			or nil,

		config = function()
			local cmp = require("cmp")

			local luasnip = require("luasnip")
			require("luasnip/loaders/from_vscode").lazy_load()

			local kind_icons = {
				Text = "",
				Method = "m",
				Function = "",
				Constructor = "",
				Field = "",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "",
				Value = "",
				Enum = "",
				Keyword = "",
				Snippet = "",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "",
				Event = "",
				Operator = "",
				TypeParameter = "",
			}

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						-- Kind icons
						vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip", option = { show_autosnippets = true } },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},
	{
		-- LSP for Neovim
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"j-hui/fidget.nvim",
			"folke/neodev.nvim",
			-- "RRethy/vim-illuminate",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Set up Mason before anything else
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pylsp",
					"tsserver",
					"clangd",
					"bashls",
				},
				automatic_installation = true,
			})

			-- Quick access via keymap
			require("helpers.keys").map("n", "<leader>M", "<cmd>Mason<cr>", "Show Mason")

			-- Neodev setup before LSP config
			require("neodev").setup()

			-- Turn on LSP status information
			require("fidget").setup()

			-- Set up cool signs for diagnostics
			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			-- Diagnostic config
			local config = {
				virtual_text = false,
				signs = {
					active = signs,
				},
				update_in_insert = true,
				underline = true,
				severity_sort = true,
				float = {
					focusable = true,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			}
			vim.diagnostic.config(config)

			-- This function gets run when an LSP connects to a particular buffer.
			local on_attach = function(client, bufnr)
				local lsp_map = require("helpers.keys").lsp_map

				lsp_map("<leader>lr", vim.lsp.buf.rename, bufnr, "Rename symbol")
				lsp_map("<leader>la", vim.lsp.buf.code_action, bufnr, "Code action")
				lsp_map("<leader>ld", vim.lsp.buf.type_definition, bufnr, "Type definition")
				lsp_map("<leader>ls", require("telescope.builtin").lsp_document_symbols, bufnr, "Document symbols")

				lsp_map("gd", vim.lsp.buf.definition, bufnr, "Goto Definition")
				lsp_map("gr", require("telescope.builtin").lsp_references, bufnr, "Goto References")
				lsp_map("gI", vim.lsp.buf.implementation, bufnr, "Goto Implementation")
				lsp_map("K", vim.lsp.buf.hover, bufnr, "Hover Documentation")
				lsp_map("gD", vim.lsp.buf.declaration, bufnr, "Goto Declaration")

				-- Create a command `:Format` local to the LSP buffer
				vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
					vim.lsp.buf.format()
				end, { desc = "Format current buffer with LSP" })

				lsp_map("<leader>ff", "<cmd>Format<cr>", bufnr, "Format")

				-- Attach and configure vim-illuminate
				-- require("illuminate").on_attach(client)
			end

			-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- Lua
			require("lspconfig")["lua_ls"].setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							checkThirdParty = false,
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})

			-- Python
			require("lspconfig")["pylsp"].setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					pylsp = {
						plugins = {
							flake8 = {
								enabled = true,
								maxLineLength = 88, -- Black's line length
							},
							-- Disable plugins overlapping with flake8
							pycodestyle = {
								enabled = false,
							},
							mccabe = {
								enabled = false,
							},
							pyflakes = {
								enabled = false,
							},
							-- Use Black as the formatter
							autopep8 = {
								enabled = false,
							},
						},
					},
				},
			})
		end,
	},
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
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		opts = {},
	},
	-- {
	--   "echasnovski/mini.surround",
	--   keys = function_, keys
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
	{
		-- Comment with haste
		"numToStr/Comment.nvim",
		opts = {},
	},
	{
		-- Move stuff with <M-j> and <M-k> in both normal and visual mode
		"echasnovski/mini.move",
		config = function()
			require("mini.move").setup()
		end,
	},
	{
		-- Better buffer closing actions. Available via the buffers helper.
		"kazhala/close-buffers.nvim",
		opts = {
			preserve_window_layout = { "this", "nameless" },
		},
	},
	{
		-- Vimscript to hold window at specific line - usually center
		"vim-scripts/scrollfix",
		config = function()
			vim.g["scrollfix"] = 50
		end,
	},
	"tpope/vim-surround", -- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	"tpope/vim-surround", -- Surround stuff with the ys-, cs-, ds- commands
}
