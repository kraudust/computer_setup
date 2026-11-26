return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		-- Shared across machines; startup installs only missing parsers.
		parsers = {
			"vimdoc",
			"lua",
			"typescript",
			"tsx",
			"go",
			"javascript",
			"python",
			"rust",
			"c",
			"cpp",
			"markdown",
			"markdown_inline",
			"html",
			"css",
			"scss",
			"json",
			"json5",
			"yaml",
			"toml",
			"bash",
			"dockerfile",
			"sql",
			"regex",
		},
	},
	config = function(_, opts)
		-- This Treesitter version has no separate jsonc parser.
		vim.treesitter.language.register("json5", "jsonc")
		require("nvim-treesitter").install(opts.parsers)
	end,
}
