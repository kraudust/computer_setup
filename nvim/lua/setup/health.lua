local M = {}

function M.check()
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
