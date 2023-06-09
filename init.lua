vim.cmd([[
autocmd InsertEnter * :LspStart
set number
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set mouse=a
set relativenumber
call plug#begin()

Plug 'arcticicestudio/nord-vim'
Plug 'https://github.com/vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'neovim/nvim-lspconfig'
Plug 'VonHeikemen/lsp-zero.nvim', { 'branch': 'v2.x' }
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'


call plug#end()

let g:airline_theme='base16_nord'
let g:copilot_filetypes = {
			\ 'yaml': v:true,
			\ }
]])

local lsp = require('lsp-zero').preset({})

lsp.set_preferences({
	sign_icons = {}
})

lsp.on_attach(function(client, bufnr)
	local opts = {buffer = bufnr, remap = false}

end)

lsp.setup()
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		virtual_text = true,
		signs = false,
		underline = false,
})

