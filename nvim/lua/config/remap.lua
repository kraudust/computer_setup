-- Global editing, window, buffer, and tab mappings.
-- Plugin-specific mappings live with their plugin specs; see README.md for the full guide.
-- Leader groups: f = files, s = search, b = buffers, w = windows,
-- c = code, g = Git, <Tab> = tabs, t = custom tasks.

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

vim.keymap.set("v", "J", function()
	local reindent = vim.bo.filetype ~= "markdown" and "=" or ""
	return ":m '>+1<CR>gv" .. reindent .. "gv"
end, { expr = true, desc = "Move selection down" })
vim.keymap.set("v", "K", function()
	local reindent = vim.bo.filetype ~= "markdown" and "=" or ""
	return ":m '<-2<CR>gv" .. reindent .. "gv"
end, { expr = true, desc = "Move selection up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (centered)" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
vim.keymap.set("n", "<leader>yf", ":let @+ = expand('%')<cr>", { desc = "Copy current buffer filepath" })

vim.keymap.set("n", "<leader>d", '"_d', { desc = "Delete to void register" })
vim.keymap.set("v", "<leader>d", '"_d', { desc = "Delete to void register" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert mode" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Disabled" })

vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
vim.keymap.set("n", "<C-n>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
vim.keymap.set("n", "<C-p>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })
vim.keymap.set("n", "<leader>n", "<cmd>lnext<CR>zz", { desc = "Next location list" })
vim.keymap.set("n", "<leader>p", "<cmd>lprev<CR>zz", { desc = "Prev location list" })

vim.keymap.set("n", "<leader>|", "<cmd>rightbelow vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>-", "<cmd>belowright split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize split sizes" })
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Resize split up" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Resize split down" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Resize split left" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize split right" })

-- Window navigation applies in Normal mode; Insert-mode signature help stays local.
for key, direction in pairs({ h = "Left", j = "Lower", k = "Upper", l = "Right" }) do
	vim.keymap.set("n", "<C-" .. key .. ">", "<C-w>" .. key, { desc = "Go to " .. direction .. " window" })
end
vim.keymap.set("n", "<leader>wd", "<cmd>close<CR>", { desc = "Close split" })

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", function() require("util.buffers").delete() end, { desc = "Delete buffer (keep splits)" })
vim.keymap.set("n", "<leader>bo", function() require("util.buffers").delete_others() end, { desc = "Delete other buffers (keep splits)" })
vim.keymap.set("n", "<leader><Tab><Tab>", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader><Tab>d", "<cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader><Tab>o", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
vim.keymap.set("n", "<leader><Tab>[", "<cmd>tabprevious<CR>", { desc = "Prev tab" })
vim.keymap.set("n", "<leader><Tab>]", "<cmd>tabnext<CR>", { desc = "Next tab" })
