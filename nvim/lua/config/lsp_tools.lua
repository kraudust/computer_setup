local M = {}

-- Mason installs servers, but their installers still need these toolchains.
local servers = {
	{ name = "lua_ls", tools = {} },
	{ name = "ts_ls", tools = { "node", "npm" } },
	{ name = "gopls", tools = { "go" } },
	{ name = "pyright", tools = { "node", "npm" } },
	{ name = "rust_analyzer", tools = {} },
	{ name = "eslint", tools = { "node", "npm" } },
	{ name = "clangd", tools = {} },
}

function M.check()
	local ready, missing = {}, {}
	for _, server in ipairs(servers) do
		local tools = {}
		for _, tool in ipairs(server.tools) do
			if vim.fn.executable(tool) == 0 then
				tools[#tools + 1] = tool
			end
		end
		if #tools == 0 then
			ready[#ready + 1] = server.name
		else
			missing[#missing + 1] = server.name .. " needs " .. table.concat(tools, ", ")
		end
	end
	return ready, missing
end

return M
