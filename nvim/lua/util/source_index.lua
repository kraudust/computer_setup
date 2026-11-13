local M = {}
local states = {}
local cpp = { c = true, cpp = true, objc = true, objcpp = true }

local function include_paths(root)
	local paths, seen = {}, {}
	local function add(path)
		path = vim.fs.normalize(vim.fn.expand(path))
		if not seen[path] and vim.fn.isdirectory(path) == 1 then
			seen[path] = true
			table.insert(paths, path)
		end
	end
	for _, path in ipairs(vim.g.source_index_paths or {}) do
		add(path)
	end
	if vim.fn.isdirectory(root .. "/ros/src") == 1 or vim.uv.fs_stat(root .. "/package.xml") then
		local prefixes = vim.split(vim.env.AMENT_PREFIX_PATH or "", ":", { trimempty = true })
		if #prefixes == 0 then
			-- Prefer the selected ROS distribution; otherwise use installed headers.
			if vim.env.ROS_DISTRO then
				prefixes = { "/opt/ros/" .. vim.env.ROS_DISTRO }
			else
				prefixes = vim.fn.glob("/opt/ros/*", false, true)
			end
		end
		for _, prefix in ipairs(prefixes) do
			add(prefix .. "/include")
		end
	end
	return paths
end

local function root_for(buf)
	local file = vim.api.nvim_buf_get_name(buf)
	if file == "" or vim.bo[buf].buftype ~= "" then
		return
	end
	if vim.b[buf].source_index_root then
		return vim.b[buf].source_index_root
	end
	-- ROS packages can be Git submodules: include sibling packages by using
	-- the outer workspace repository, not only the nearest submodule.
	local root
	for dir in vim.fs.parents(file) do
		local git = vim.uv.fs_stat(dir .. "/.git")
		if git and (git.type == "file" or vim.uv.fs_stat(dir .. "/.git/HEAD")) then
			root = dir
		end
	end
	return root or vim.fs.dirname(file)
end

local function state_for(root)
	if not states[root] then
		states[root] = { callbacks = {}, updated = 0 }
	end
	return states[root]
end

local function decode(output)
	local symbols = {}
	for line in output:gmatch("[^\n]+") do
		local ok, tag = pcall(vim.json.decode, line)
		if ok and tag._type == "tag" and tag.line and tag.name then
			symbols[tag.name] = symbols[tag.name] or {}
			table.insert(symbols[tag.name], tag)
		end
	end
	return symbols
end

-- One background job per repository; requests share its result.
function M.refresh(root, callback)
	local state = state_for(root)
	if callback then
		table.insert(state.callbacks, callback)
	end
	if state.running then
		return
	end
	state.running = true
	local function finish(err, output)
		if not err then
			state.symbols = decode(output)
			state.updated = vim.uv.now()
			local dir = vim.fn.stdpath("cache") .. "/source-index"
			local path = dir .. "/" .. vim.fn.sha256(root) .. ".jsonl"
			local temp = path .. "." .. vim.fn.getpid()
			-- A read-only cache must not prevent navigation or leave a job stuck.
			pcall(function()
				vim.fn.mkdir(dir, "p")
				vim.fn.writefile(vim.split(output, "\n", { plain = true }), temp)
				vim.uv.fs_rename(temp, path)
			end)
		end
		state.running = false
		if state.dirty then
			state.dirty = false
			M.refresh(root)
			return
		end
		local callbacks = state.callbacks
		state.callbacks = {}
		for _, cb in ipairs(callbacks) do
			cb(err, state.symbols)
		end
	end
	if vim.fn.executable("ctags") == 0 or vim.fn.executable("rg") == 0 then
		finish("Source navigation needs Universal Ctags (with JSON support) and ripgrep.")
		return
	end
	local command = {
		"rg",
		"--files",
		"--hidden",
		"-g",
		"!.git",
		"-g",
		"!build",
		"-g",
		"!devel",
		"-g",
		"!install",
		"-g",
		"!node_modules",
		"-g",
		"!.venv",
		"-g",
		"!vendor",
		".",
	}
	vim.list_extend(command, include_paths(root))
	vim.system(
		command,
		{ cwd = root, text = true },
		vim.schedule_wrap(function(files)
			if files.code ~= 0 and files.code ~= 1 then
				finish(files.stderr)
				return
			end
			if files.stdout == "" then
				finish(nil, "")
				return
			end
			vim.system(
				{
					"ctags",
					"--options=NONE",
					"--output-format=json",
					"--fields=+nK",
					"--extras=-F",
					"--sort=no",
					"-f",
					"-",
					"-L",
					"-",
				},
				{ cwd = root, text = true, stdin = files.stdout },
				vim.schedule_wrap(function(result)
					if result.code ~= 0 then
						finish("Universal Ctags failed: " .. result.stderr)
					else
						finish(nil, result.stdout)
					end
				end)
			)
		end)
	)
end

function M.lookup(root, name, callback)
	local state = state_for(root)
	local function deliver(err, symbols)
		local matches = {}
		for _, tag in ipairs((symbols or {})[name] or {}) do
			local path = vim.fs.normalize(tag.path:sub(1, 1) == "/" and tag.path or root .. "/" .. tag.path)
			if vim.uv.fs_stat(path) then
				table.insert(matches, {
					filename = path,
					lnum = tag.line,
					col = 1,
					text = (tag.scope and tag.scope .. "::" or "") .. tag.name .. " [" .. (tag.kind or "symbol") .. "]",
				})
			end
		end
		table.sort(matches, function(a, b)
			if a.filename == b.filename then
				return a.lnum < b.lnum
			end
			return a.filename < b.filename
		end)
		callback(err, matches)
	end
	if not state.symbols or state.running or vim.uv.now() - state.updated > 30000 then
		M.refresh(root, deliver)
	else
		deliver(nil, state.symbols)
	end
end

local function show(matches, root)
	if #matches == 1 then
		-- show_document records the previous location for Ctrl-o.
		local item = matches[1]
		vim.lsp.util.show_document({
			uri = vim.uri_from_fname(item.filename),
			range = {
				start = { line = item.lnum - 1, character = 0 },
				["end"] = { line = item.lnum - 1, character = 0 },
			},
		}, "utf-8", { focus = true })
		-- Keep the workspace context while following definitions into dependencies.
		vim.b.source_index_root = root
	else
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		require("telescope.pickers")
			.new({}, {
				prompt_title = "Source definitions",
				finder = require("telescope.finders").new_table({
					results = matches,
					entry_maker = require("telescope.make_entry").gen_from_quickfix({}),
				}),
				sorter = require("telescope.config").values.generic_sorter({}),
				previewer = require("telescope.config").values.qflist_previewer({}),
				attach_mappings = function(buf)
					actions.select_default:replace(function()
						local selected = action_state.get_selected_entry()
						actions.close(buf)
						if selected then
							show({ selected.value }, root)
						end
					end)
					return true
				end,
			})
			:find()
	end
end

function M.definition(source_only)
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(win)
	local name = vim.fn.expand("<cword>")
	local root = root_for(buf)
	local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/definition" })
	local function current()
		return vim.api.nvim_get_current_win() == win
			and vim.api.nvim_get_current_buf() == buf
			and vim.deep_equal(vim.api.nvim_win_get_cursor(win), cursor)
	end
	local function source(fallback)
		if not root then
			if fallback then
				fallback()
			end
			return
		end
		M.lookup(root, name, function(err, matches)
			if not current() then
				return
			end
			if #matches > 0 then
				show(matches, root)
			elseif fallback then
				fallback()
			else
				vim.notify(err or ("No source definition found for " .. name), vim.log.levels.WARN)
			end
		end)
	end
	-- C/C++ browsing works even when container build paths are unavailable.
	-- Set g:source_index_cpp_first=false to prefer clangd's semantic results.
	if source_only or (cpp[vim.bo[buf].filetype] and vim.g.source_index_cpp_first ~= false) then
		source(not source_only and #clients > 0 and function()
			vim.lsp.buf.definition()
		end or nil)
	elseif #clients == 0 then
		source()
	else
		-- LSP first for other languages, then source indexing on an empty result.
		vim.lsp.buf_request_all(buf, "textDocument/definition", function(client)
			return vim.lsp.util.make_position_params(win, client.offset_encoding)
		end, function(results)
			if not current() then
				return
			end
			for _, result in pairs(results) do
				if result.result and next(result.result) then
					vim.lsp.buf.definition()
					return
				end
			end
			source()
		end)
	end
end

function M.setup()
	vim.keymap.set("n", "gd", function()
		M.definition()
	end, { desc = "Go to definition (source/LSP)" })
	vim.keymap.set("n", "<leader>cD", function()
		M.definition(true)
	end, { desc = "Find source definition" })
	vim.api.nvim_create_user_command("SourceIndexRefresh", function()
		local root = root_for(0)
		if root then
			M.refresh(root, function(err)
				vim.notify(err or "Source index refreshed", err and vim.log.levels.ERROR or vim.log.levels.INFO)
			end)
		end
	end, {})
	local group = vim.api.nvim_create_augroup("SourceIndex", { clear = true })
	local generation = {}
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
		group = group,
		callback = function(ev)
			local root = root_for(ev.buf)
			if not root then
				return
			end
			local state = state_for(root)
			if ev.event == "BufEnter" and state.symbols and vim.uv.now() - state.updated < 30000 then
				return
			end
			-- Debounce saves and focus changes, including edits by external tools.
			generation[root] = (generation[root] or 0) + 1
			local token = generation[root]
			vim.defer_fn(function()
				if generation[root] ~= token then
					return
				end
				if state.running then
					state.dirty = true
					return
				end
				M.refresh(root)
			end, 750)
		end,
	})
end

return M
