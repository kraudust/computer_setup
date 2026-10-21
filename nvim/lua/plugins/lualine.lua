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
					fmt = function(name, context)
						local bufnr = vim.fn.tabpagebuflist(context.tabnr)[vim.fn.tabpagewinnr(context.tabnr)]
						local diags = vim.diagnostic.get(bufnr)
						local errors = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.ERROR end, diags)
						local warns = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.WARN end, diags)
						local parts = { name }
						if errors > 0 then table.insert(parts, " " .. errors) end
						if warns > 0 then table.insert(parts, " " .. warns) end
						return table.concat(parts, " ")
					end,
				},
			},
			lualine_z = {},
		},
	},
}
