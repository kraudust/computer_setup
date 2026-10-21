return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		require("mason").setup()
		local servers, missing = require("config.lsp_tools").check()
		require("mason-lspconfig").setup({
			ensure_installed = servers,
			-- Enable installed servers (including successful first-time installs)
			-- only when their prerequisites are available in this session.
			automatic_enable = servers,
		})
		if #missing > 0 then
			vim.schedule(function()
				vim.notify(
					"Some language servers need toolchains on PATH:\n"
						.. table.concat(missing, "\n")
						.. "\nRun :checkhealth setup for setup instructions; restart after installing them.",
					vim.log.levels.WARN
				)
			end)
		end

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
				},
			},
		})

		-- lspconfig's oxlint config attaches even with no project markers
		-- (single-file mode). Only attach when a project root was found AND
		-- there's a runnable binary -- global or in the project's node_modules.
		local oxlint_defaults = vim.lsp.config.oxlint
		vim.lsp.config("oxlint", {
			root_dir = function(bufnr, on_dir)
				oxlint_defaults.root_dir(bufnr, function(root)
					if
						root
						and (
							vim.fn.executable("oxlint") == 1
							or vim.fn.executable(vim.fs.joinpath(root, "node_modules/.bin/oxlint")) == 1
						)
					then
						on_dir(root)
					end
				end)
			end,
		})

		-- Mason enables its servers after installation. oxlint is provided by
		-- PATH or the project's node_modules and has its own root/binary check.
		vim.lsp.enable("oxlint")

		vim.diagnostic.config({
			float = { source = true },
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(ev)
				local clients = vim.lsp.get_clients({ bufnr = ev.buf, name = "eslint" })
				if #clients > 0 then
					vim.cmd("silent! EslintFixAll")
				end
			end,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(ev)
				local function opts(desc)
					return { buffer = ev.buf, remap = false, desc = desc }
				end
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
				vim.keymap.set("n", "K", function() vim.lsp.buf.hover({ border = "single" }) end, opts("Hover documentation"))
				vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts("Workspace symbol search"))
				vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, opts("Open diagnostic float"))
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
				vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references, opts("Find references"))
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename symbol"))
				vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts("Prev diagnostic"))
				vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts("Next diagnostic"))
				vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help({ border = "single" }) end, opts("Signature help"))
			end,
		})
	end,
}
