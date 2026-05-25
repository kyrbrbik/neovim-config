return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	dependencies = {
		{
			"windwp/nvim-ts-autotag",
			config = function()
				require("nvim-ts-autotag").setup()
			end,
		},
	},

	config = function()
		local parsers = {
			"json",
			"yaml",
			"markdown",
			"markdown_inline",
			"lua",
			"vim",
			"vimdoc",
			"go",
			"powershell",
			"bash",
			"javascript",
			"typescript",
			"tsx",
			"python",
			"query",
		}

		require("nvim-treesitter").install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf = args.buf
				local ft = vim.bo[buf].filetype
				local lang = vim.treesitter.language.get_lang(ft) or ft
				if not pcall(vim.treesitter.start, buf, lang) then
					return
				end
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
