local M = {}

-- Refuse unsaved changes and running terminals rather than force deleting them.
-- Replace buffers in every window (including other tabs) before deleting them.
local function delete_buffers(targets, replacement)
	for _, buf in ipairs(targets) do
		if vim.bo[buf].modified or vim.bo[buf].buftype == "terminal" then
			vim.notify("Save modified buffers and close terminals before deleting buffers", vim.log.levels.WARN)
			return false
		end
	end
	if #targets == 0 then return true end
	replacement = replacement or vim.api.nvim_create_buf(true, false)
	local deleting = {}
	for _, buf in ipairs(targets) do deleting[buf] = true end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if deleting[vim.api.nvim_win_get_buf(win)] then
			vim.api.nvim_win_set_buf(win, replacement)
		end
	end
	for _, buf in ipairs(targets) do
		if vim.api.nvim_buf_is_valid(buf) then
			local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = false })
			if not ok then
				vim.notify(err, vim.log.levels.ERROR)
				return false
			end
		end
	end
	return true
end

function M.delete()
	local current = vim.api.nvim_get_current_buf()
	local replacement
	local alternate = vim.fn.bufnr("#")
	if alternate ~= current and vim.api.nvim_buf_is_valid(alternate) and vim.bo[alternate].buflisted then
		replacement = alternate
	else
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if buf ~= current and vim.bo[buf].buflisted then
				replacement = buf
				break
			end
		end
	end
	return delete_buffers({ current }, replacement)
end

function M.delete_others()
	local current = vim.api.nvim_get_current_buf()
	local targets = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.bo[buf].buflisted then
			table.insert(targets, buf)
		end
	end
	return delete_buffers(targets, current)
end

return M
