local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
			{ out,                            'WarningMsg' },
			{ '\nPress any key to exit...' },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.showtabline = 2
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.updatetime = 222
--
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
--
vim.opt.cindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
--
vim.opt.cursorline = true
vim.opt.relativenumber = true

require 'lazy'.setup({
	{
		'catppuccin/nvim',
		name = 'catppuccin',
		priority = 1000,
		config = function()
			require 'catppuccin'.setup {
				dim_inactive = { enabled = true },
				integrations = {
					aerial = true,
					fidget = true,
					mason = true,
				}
			}
			vim.cmd.colorscheme 'catppuccin'
		end
	},
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			require 'nvim-treesitter.configs'.setup {
				auto_install = true,
				autotag = { enable = true },
				ensure_installed = 'all',
				highlight = {
					enable = true,
					disable = function(lang, buf)
						local max_filesize = 222 * 1024
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
				},
				indent = { enable = true },
				refactor = {
					highlight_definitions = { enable = true },
					navigation = {
						enable = true,
						keymaps = {
							goto_definition = 'gnd',
							goto_next_usage = '<a-*>',
							goto_previous_usage = '<a-#>',
						},
					},
				},
			}
		end,
		dependencies = {
			-- Highlight definitions, Navigation
			'nvim-treesitter/nvim-treesitter-refactor',
			'windwp/nvim-ts-autotag'
		},
	},
	{
		'stevearc/aerial.nvim',
		config = function()
			require 'aerial'.setup {
				on_attach = function(bufnr)
					vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
					vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
				end,
			}
			vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')
		end,
		dependencies = {
			'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons'
		},
	},
	{
		'utilyre/barbecue.nvim',
		config = true,
		dependencies = { 'SmiteshP/nvim-navic', 'nvim-tree/nvim-web-devicons' },
	},
	{
		'numToStr/Comment.nvim', config = true
	},
	{
		'j-hui/fidget.nvim',
		opts = {
			notification = {
				override_vim_notify = true,
				window = { winblend = 0 },
			},
		},
	},
	{
		'andrewferrier/wrapping.nvim', config = true
	},
	{
		'neovim/nvim-lspconfig',
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			local lspconfig = require 'lspconfig'
			lspconfig.astro.setup {}
			lspconfig.bashls.setup {}
			lspconfig.biome.setup {}
			lspconfig.clangd.setup {}
			lspconfig.cmake.setup {}
			lspconfig.cssls.setup { capabilities = capabilities }
			lspconfig.docker_compose_language_service.setup {}
			lspconfig.dockerls.setup {}
			lspconfig.eslint.setup {}
			lspconfig.gradle_ls.setup {}
			lspconfig.grammarly.setup {}
			lspconfig.html.setup { capabilities = capabilities }
			lspconfig.jsonls.setup { capabilities = capabilities }
			lspconfig.lua_ls.setup {
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
							return
						end
					end

					client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
						runtime = {
							-- Tell the language server which version of Lua you're using
							-- (most likely LuaJIT in the case of Neovim)
							version = 'LuaJIT'
						},
						-- Make the server aware of Neovim runtime files
						workspace = {
							checkThirdParty = false,
							library = { vim.env.VIMRUNTIME }
						}
					})
				end,
				settings = {
					Lua = {}
				}
			}
			lspconfig.marksman.setup {}
			lspconfig.pyright.setup {
				settings = {
					pyright = {
						-- Using Ruff's import organizer
						disableOrganizeImports = true,
					},
					python = {
						analysis = {
							-- Ignore all files for analysis to exclusively use Ruff for linting
							ignore = { '*' },
						},
					},
				},
			}
			lspconfig.ruff.setup {}
			lspconfig.svelte.setup {}
			lspconfig.taplo.setup {}
			lspconfig.tinymist.setup {
				settings = {
					formatterMode = "typstyle",
				}
			}
			lspconfig.ts_ls.setup {}
			lspconfig.yamlls.setup {}
		end,
		dependencies = {
			{
				'williamboman/mason-lspconfig.nvim',
				opts = { automatic_installation = true },
				dependencies = {
					{
						'williamboman/mason.nvim',
						build = function()
							require 'mason-registry'.refresh()
						end,
						opts = { pip = { upgrade_pip = true } }
					}
				}
			}
		}
	},
	{
		'ibhagwan/fzf-lua',
		config = function()
			local fzf_lua = require 'fzf-lua'
			fzf_lua.setup { 'fzf-native' }

			vim.keymap.set('n', '<C-\\>', fzf_lua.buffers, {})
			vim.keymap.set('n', '<C-k>', fzf_lua.builtin, {})
			vim.keymap.set('n', '<C-p>', fzf_lua.files, {})
			vim.keymap.set('n', '<C-l>', fzf_lua.live_grep_glob, {})
			-- vim.keymap.set('n', '<C-g>', fzf_lua.grep_project, {}) # Use default keymap for the filename
		end,
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	},
	{
		'chomosuke/typst-preview.nvim',
		opts = {
			dependencies_bin = { ['tinymist'] = 'tinymist' }
		}
	}
}, {
	install = { colorscheme = { 'catppuccin' } },
	checker = { enabled = true }
})

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client == nil then
			return
		end

		if client.name == 'ruff' then
			-- Disable hover in favor of Pyright
			client.server_capabilities.hoverProvider = false
		elseif client.name == 'yamlls' then
			client.server_capabilities.documentFormattingProvider = true
		end
	end,
})

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		if require 'lazy.status'.has_updates then
			require 'lazy'.update({ show = false, })
		end
	end,
})
