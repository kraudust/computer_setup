return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			theme = "auto",
			-- lualine polls a check timer every refresh_time ms forever (default 16ms
			-- = ~60 wakeups/s even when idle). 100ms keeps event-driven redraws
			-- feeling instant while cutting idle wakeups ~6x. Battery matters.
			refresh = { refresh_time = 100 },
		},
		sections = {
			lualine_b = { "branch", "diff" },
			lualine_c = {
				"filename",
			},
		},
		tabline = {
			lualine_a = {
				{
					"tabs",
					mode = 2,
					max_length = vim.o.columns,
				},
			},
			lualine_z = {},
		},
	},
}
