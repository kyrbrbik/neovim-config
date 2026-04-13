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
                js = { "prettier" },
                terraform = { "terraform_fmt" },
                ["terraform.tfvars"] = { "terraform_fmt" },
			},
		})

        vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
            pattern = { "*.tfvars" },
            callback = function()
                vim.bo.filetype = "terraform.tfvars"
            end
        })
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format with conform" })
	end,
}
