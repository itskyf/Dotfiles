local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git',
		lazypath
	}
end
vim.opt.rtp:prepend(lazypath)

vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.number = true
vim.opt.shiftwidth = 3
vim.opt.tabstop = 3
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
					mason = true
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
				highlight = {
					enable = true,
					disable = function(lang, buf)
						local max_filesize = 500 * 1024
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
							goto_next_usage = "<a-*>",
							goto_previous_usage = "<a-#>",
						},
					},
				},
			}
		end,
		dependencies = { 'nvim-treesitter/nvim-treesitter-refactor', 'windwp/nvim-ts-autotag' }
	},
	{ 'numToStr/Comment.nvim', config = true },
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
	{ 'folke/neodev.nvim',     config = true },
	{
		'neovim/nvim-lspconfig',
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			local lspconfig = require 'lspconfig'
			lspconfig.bashls.setup {}
			lspconfig.clangd.setup {}
			lspconfig.cmake.setup {}
			lspconfig.cssls.setup { capabilities = capabilities }
			lspconfig.docker_compose_language_service.setup {}
			lspconfig.dockerls.setup {}
			lspconfig.eslint.setup {}
			lspconfig.gradle_ls.setup {}
			lspconfig.html.setup { capabilities = capabilities }
			lspconfig.jsonls.setup { capabilities = capabilities }
			lspconfig.lua_ls.setup {}
			lspconfig.marksman.setup {}
			lspconfig.pyright.setup {}
			lspconfig.ruff_lsp.setup {}
			lspconfig.svelte.setup {}
			lspconfig.taplo.setup {}
			lspconfig.tsserver.setup {}
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
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			local fzf_lua = require 'fzf-lua'
			fzf_lua.setup { 'fzf-native' }
			local opts = { silent = true }
			vim.keymap.set({ 'n', 'v', 'i' }, '<C-x><C-f>', fzf_lua.complete_path, opts)
			vim.keymap.set('n', '<leader>ff', fzf_lua.files, opts)
			vim.keymap.set('n', '<leader>fg', fzf_lua.live_grep_native, opts)
			vim.keymap.set('n', '<leader>fr', fzf_lua.resume, opts)
			vim.keymap.set('n', '<leader>fw', fzf_lua.grep_cWORD, opts)
		end
	}
}, {
	install = { colorscheme = { 'catppuccin' } },
	checker = { enabled = true }
})

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		local opts = { buffer = ev.buf }
		vim.keymap.set('n', '<leader>g', '<cmd>tab split | lua vim.lsp.buf.definition()<CR>', opts)
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
	end,
})
