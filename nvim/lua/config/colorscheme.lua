-- 'background' is detected from the terminal (OSC 11) by Neovim itself before
-- this file runs, so we don't set it explicitly here -- doing so would make
-- Neovim drop its own detection handler at VimEnter.

local schemes = { dark = "gruvbox", light = "github_light" }

-- Make the editor background transparent (inherit the terminal's) while
-- keeping the scheme's foreground and other attributes.
local function apply_overrides()
	for _, group in ipairs({ "Normal", "NormalFloat" }) do
		local hl = vim.api.nvim_get_hl(0, { name = group })
		hl.bg = nil
		vim.api.nvim_set_hl(0, group, hl)
	end
end

local function apply_scheme()
	local name = schemes[vim.o.background]
	if vim.g.colors_name ~= name then
		vim.cmd.colorscheme(name)
	end
end

-- Reapply overrides whenever a scheme (re)loads.
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_overrides })

-- Swap schemes when 'background' flips (terminal detection, FocusGained
-- re-check below, or a manual :set bg=...). nested so ColorSchemePre fires,
-- which is how lazy.nvim loads the scheme's plugin on demand.
vim.api.nvim_create_autocmd("OptionSet", { pattern = "background", nested = true, callback = apply_scheme })

apply_scheme()

-- Neovim's TUI doesn't subscribe to terminal theme-change notifications, so
-- re-check macOS appearance whenever Neovim regains focus.
if vim.fn.has("mac") == 1 then
	vim.api.nvim_create_autocmd("FocusGained", {
		callback = function()
			vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, {}, function(r)
				-- key is absent (non-zero exit) in light mode
				local bg = (r.stdout or ""):match("Dark") and "dark" or "light"
				vim.schedule(function()
					if vim.o.background ~= bg then
						vim.o.background = bg
					end
				end)
			end)
		end,
	})
end
