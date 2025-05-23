-- Bootstrap lazy.nvim
local vim = vim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	-- automatically check for plugin updates
	checker = { enabled = false },
})

vim.cmd([[
colorscheme nord
set number
set relativenumber
set smarttab
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
set noswapfile
set clipboard+=unnamedplus
]])

vim.cmd("let g:netrw_liststyle=3")

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        spacing = 0,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})
