return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")
		conform.setup({
			format_on_save = {
				async = false,
				timeout_ms = 1000,
			},
			formatters_by_ft = {
				go = { "gofmt" },
				lua = { "stylua" },
				json = { "jq" },
				yaml = { "prettier" },
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format with conform" })
	end,
}
