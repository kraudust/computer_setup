return {
	"github/copilot.vim",
	-- Optional AI suggestions. Requires Node.js/npm and GitHub Copilot access.
	-- Normal completion (nvim-cmp/LSP) works without this plugin.
	enabled = false,
	event = "InsertEnter",
	init = function()
		vim.g.copilot_filetypes = {
			markdown = false,
		}
	end,
}
