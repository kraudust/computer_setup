local function picker(name)
	return function() require("telescope.builtin")[name]() end
end

return {
	"nvim-telescope/telescope.nvim", version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	opts = {
		defaults = {
			mappings = {
				i = { ["<C-s>"] = "select_horizontal" },
				n = { ["<C-s>"] = "select_horizontal" },
			},
		},
		pickers = {
			find_files = {
				hidden = true,
				file_ignore_patterns = { "^%.git/", "/%.git/" },
			},
		},
	},
	config = function(_, opts)
		require("telescope").setup(opts)
		require("telescope").load_extension("fzf")
	end,
	keys = {
		{ "<leader><space>", picker("find_files"), desc = "Find files (cwd)" },
		{ "<leader>ff", picker("find_files"), desc = "Find files (cwd)" },
		{ "<leader>fg", picker("git_files"), desc = "Find Git files" },
		{ "<leader>/", picker("live_grep"), desc = "Grep (cwd)" },
		{ "<leader>sg", picker("live_grep"), desc = "Grep (cwd)" },
		{ "<leader>,", picker("buffers"), desc = "Buffers" },
		{ "<leader>fb", picker("buffers"), desc = "Buffers" },
		{ "<leader>fr", picker("oldfiles"), desc = "Recent files" },
		{ "<leader>sh", picker("help_tags"), desc = "Search help" },
		{ "<leader>sk", picker("keymaps"), desc = "Search keymaps" },
		{ "<leader>sd", picker("diagnostics"), desc = "Search diagnostics" },
	},
}
