return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"windwp/nvim-ts-autotag",
	},

	config = function()
		local treesitter = require("nvim-treesitter.configs")
		treesitter.setup({
			highlight = {
				enable = true,
			},

			indent = {
				enable = true,
			},

			ensure_installed = {
				"json",
				"yaml",
				"markdown",
				"lua",
				"vim",
				"go",
				"powershell",
				"bash",
				"javascript",
				"typescript",
			},
		})
	end,
}
