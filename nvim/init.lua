vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Keep language intelligence without automatic diagnostic decorations.
vim.diagnostic.enable(false)

require("config.remap")
require("config.lazy")
require("config.set")
require("util.source_index").setup()
