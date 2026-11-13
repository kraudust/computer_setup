return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre",
	opts = {},
	keys = {
		{
			"<leader>gb",
			function() require("gitsigns").blame() end,
			desc = "Git blame",
		},
		{
			"]c",
			function()
				if vim.wo.diff then
					vim.cmd.normal({ vim.v.count1 .. "]c", bang = true })
				else
					require("gitsigns").nav_hunk("next")
				end
			end,
			desc = "Next Git change",
		},
		{
			"[c",
			function()
				if vim.wo.diff then
					vim.cmd.normal({ vim.v.count1 .. "[c", bang = true })
				else
					require("gitsigns").nav_hunk("prev")
				end
			end,
			desc = "Previous Git change",
		},
		{
			"<leader>gp",
			function() require("gitsigns").preview_hunk_inline() end,
			desc = "Preview Git change inline",
		},
		{
			"<leader>gd",
			function() require("gitsigns").diffthis(nil, { vertical = true }) end,
			desc = "Git diff against index (side by side)",
		},
	},
}
