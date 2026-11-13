local M = {}

function M.check()
	vim.health.start("Source definition navigation")
	if vim.fn.executable("rg") == 1 then
		vim.health.ok("ripgrep is available")
	else
		vim.health.error("Install ripgrep for source indexing")
	end
	if vim.fn.executable("ctags") == 1 then
		local version = vim.fn.system({ "ctags", "--version" })
		if version:find("Universal Ctags", 1, true) and version:find("+json", 1, true) then
			vim.health.ok("Universal Ctags with JSON support: " .. vim.fn.exepath("ctags"))
		else
			vim.health.error("Source navigation needs Universal Ctags with +json, not BSD/Exuberant ctags")
		end
	else
		vim.health.warn(
			"Install Universal Ctags: sudo apt install universal-ctags (Ubuntu), brew install universal-ctags (macOS)"
		)
	end
	vim.health.start("Language server toolchains")
	local ready, missing = require("config.lsp_tools").check()
	vim.health.ok("Ready for Mason installation: " .. table.concat(ready, ", "))
	for _, message in ipairs(missing) do
		vim.health.warn(message, {
			"Install Node.js 24 LTS (includes npm) and Go as needed; restart Neovim afterward.",
			"See ~/.config/nvim/README.md under Language server prerequisites.",
		})
	end
	for _, tool in ipairs({ "node", "npm", "go" }) do
		local path = vim.fn.exepath(tool)
		if path ~= "" then
			vim.health.info(tool .. ": " .. path)
		end
	end
end

return M
