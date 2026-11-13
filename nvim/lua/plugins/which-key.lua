return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		spec = {
			{ "<leader>f", group = "files" },
			{ "<leader>s", group = "search" },
			{ "<leader>b", group = "buffers" },
			{ "<leader>w", group = "windows" },
			{ "<leader>c", group = "code" },
			{ "<leader>g", group = "Git" },
			{ "<leader>m", group = "Markdown" },
			{ "<leader><Tab>", group = "tabs" },
			{ "<leader>t", group = "tasks" },
		},
	},
	keys = {
		{ "<C-?>", function() require("which-key").show() end, desc = "Show all keybindings" },
	},
}
