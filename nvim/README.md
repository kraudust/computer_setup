# Neovim Setup and User Guide

This is the guide to the configuration in `computer_setup/nvim`, symlinked to
`~/.config/nvim`. It covers installation, every configured plugin, maintenance,
custom shortcuts, Git workflows, and everyday Vim editing. Copilot is disabled.

## Contents

- [Installation](#installation)
- [How this setup fits together](#how-this-setup-fits-together)
- [Plugin catalog and default states](#plugin-catalog-and-default-states)
- [Installing, updating, enabling, and disabling plugins](#installing-updating-enabling-and-disabling-plugins)
- [Language servers, formatters, linters, and parsers](#language-servers-formatters-linters-and-parsers)
- [Configured keybindings](#configured-keybindings)
- [Tool workflows and their local keys](#tool-workflows-and-their-local-keys)
- [Vim fundamentals and everyday reference](#vim-fundamentals-and-everyday-reference)
- [Overrides and corrections to older notes](#overrides-and-corrections-to-older-notes)
- [Configuration files, data, and portability](#configuration-files-data-and-portability)
- [Troubleshooting](#troubleshooting)
- [Further help](#further-help)

## Installation

Complete **1A (Ubuntu)** or **1B (macOS)**, then **steps 2–3** on both systems.
Commands assume Bash on Ubuntu and zsh on macOS.

Minimum versions for this config:
[Neovim 0.12+ and tree-sitter CLI 0.26.1+](https://github.com/nvim-treesitter/nvim-treesitter/blob/5cb0114e6242625db56dd6440e945ed1ece10bc7/README.md#requirements),
[Node.js 22.22.2+](https://github.com/typescript-language-server/typescript-language-server/blob/v6.0.2/package.json),
and [Go 1.26+](https://github.com/golang/tools/blob/gopls/v0.23.0/gopls/go.mod).

### 1A. Ubuntu 24.04: install dependencies

Use apt for available packages. Neovim and tree-sitter come from official release
binaries; Node.js 24 comes from NodeSource's third-party apt repository.
If `nvim --version` already reports **0.12 or newer**, skip the three Neovim
download/extract/link commands below and keep your existing installation.
Skip font installation too if JetBrainsMono Nerd Font is already installed.

```bash
# Install build/download tools, search tools, delta, Python, Rust formatting,
# and clipboard providers (xclip for X11; wl-clipboard for Wayland).
sudo apt update
sudo apt install -y build-essential curl ca-certificates git unzip fontconfig \
  ripgrep fd-find fzf git-delta python3 python3-pip python3-venv rustfmt \
  xclip wl-clipboard golang-1.26-go

# Put local programs and Ubuntu's versioned Go toolchain on PATH now and in future shells.
mkdir -p ~/.local/bin ~/.local/opt
export PATH="$HOME/.local/bin:/usr/lib/go-1.26/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:/usr/lib/go-1.26/bin:$PATH"' >> ~/.bashrc

# Add NodeSource's Node.js 24 apt repository, then install Node.js and its bundled npm.
curl -fsSL https://deb.nodesource.com/setup_24.x -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh
sudo apt install -y nodejs

# Select the official release binaries for your CPU.
case "$(uname -m)" in
  x86_64) nvim_arch=x86_64; treesitter_arch=x64 ;;
  aarch64|arm64) nvim_arch=arm64; treesitter_arch=arm64 ;;
  *) echo "Unsupported CPU architecture"; exit 1 ;;
esac

# Install current Neovim under ~/.local/opt and link its executable.
# Skip these three commands if nvim --version already reports 0.12 or newer.
curl -fL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz" -o /tmp/nvim.tar.gz
tar -xzf /tmp/nvim.tar.gz -C ~/.local/opt
ln -sfn "$HOME/.local/opt/nvim-linux-${nvim_arch}/bin/nvim" ~/.local/bin/nvim

# Install the standalone tree-sitter CLI for building syntax parsers (not the npm package).
curl -fL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${treesitter_arch}.gz" -o /tmp/tree-sitter.gz
gzip -dc /tmp/tree-sitter.gz > ~/.local/bin/tree-sitter
chmod +x ~/.local/bin/tree-sitter

# Build/install lazygit with Go into the local executable directory.
GOBIN="$HOME/.local/bin" go install github.com/jesseduffield/lazygit@latest

# Install the Nerd Font used by the existing computer_setup/kitty config.
mkdir -p ~/.local/share/fonts/JetBrainsMono
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o /tmp/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -f

# Forget any cached path to an older nvim executable.
hash -r
```

Continue to step 2. Ubuntu calls `fd` `fdfind`; Telescope supports that name.
Sources: [Neovim releases](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-download),
[tree-sitter releases](https://github.com/tree-sitter/tree-sitter/releases/latest),
[NodeSource](https://github.com/nodesource/distributions/blob/master/DEV_README.md),
[lazygit Go install](https://github.com/jesseduffield/lazygit#go).

### 1B. macOS: install dependencies

```sh
# Install Apple's Git, C/C++ compiler, and make; wait for the dialog to finish.
# Skip this command if the Command Line Tools are already installed.
xcode-select --install

# Install Homebrew if brew --version does not already work.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Enable Homebrew now and in future zsh login terminals (Apple Silicon or Intel).
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
else
  eval "$(/usr/local/bin/brew shellenv)"
  echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
fi

# Install the Nerd Font used by the existing computer_setup/kitty config.
brew install --cask font-jetbrains-mono-nerd-font

# Refresh Homebrew's package list.
brew update

# Install the editor and the CLI that builds syntax-highlighting parsers.
brew install neovim tree-sitter-cli

# Install file/content search and fuzzy-finder tools.
brew install ripgrep fd fzf

# Install lazygit and its delta diff pager (opened in Neovim with Space lg).
brew install lazygit git-delta

# Install language toolchains: Node includes npm; Go includes gofmt; Rust includes rustfmt.
# Node/npm are also required by the Python language server (pyright).
brew install node go python rust

# Install GNU tar for Mason's archive extraction, including on macOS.
brew install gnu-tar

# Refresh cached command paths so this shell finds the new executables.
hash -r
```

Continue to step 2. [Homebrew installation](https://docs.brew.sh/Installation)

### 2. Both: link this config

Replace `/path/to/computer_setup` with the location of your checkout.

```sh
# Enter your computer_setup checkout.
cd /path/to/computer_setup

# Create the config parent directory.
mkdir -p ~/.config

# Back up any existing config directory or symlink before replacing it.
if [ -e ~/.config/nvim ] || [ -L ~/.config/nvim ]; then
  mv ~/.config/nvim "$HOME/.config/nvim.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Link this repo's nvim folder as Neovim's config directory.
ln -s "$(pwd)/nvim" ~/.config/nvim
```

Select **JetBrainsMono Nerd Font Mono** in your terminal. The existing
`computer_setup/kitty` config already selects it.

### 3. Both: launch and finish setup

Run these in the same terminal you will use for Neovim:

```sh
# Check that the editor and language tools are on PATH.
command -v nvim tree-sitter node npm go rustfmt

# Check versions against the minimums listed above.
nvim --version | head -n 1
tree-sitter --version
node --version
npm --version
go version

# Start Neovim; wait for plugin, syntax-parser, and language-server installs.
nvim
```

Inside Neovim, run each command and wait for installation to finish:

```vim
" Install the formatters and linter used by this config.
:MasonInstall stylua oxfmt oxlint clang-format

" Check that the Node/npm/Go prerequisites are visible to Neovim.
:checkhealth setup

" Check language-server installation progress; failed jobs have details in :MasonLog.
:Mason

" Check system clipboard support.
:checkhealth vim.provider
```

Quit and reopen Neovim once installation finishes. No Copilot account or
subscription is needed.

## How this setup fits together

| Tool | Open it with | What it manages |
| --- | --- | --- |
| **lazy.nvim** | `:Lazy` | Neovim plugins and their Git revisions in `lazy-lock.json` |
| **Mason** | `:Mason` | External language servers, formatters, and linters |
| **lazygit** | `Space lg` | Git changes, staging, commits, branches, and remotes for your project |
| **Treesitter** | `:TSInstall`, `:TSUpdate` | Language parsers used for highlighting, folding, and Markdown rendering |
| **apt / Homebrew** | Your shell | The editor, compilers, runtimes, and command-line programs; Homebrew is only used on macOS here |

Updating a plugin with lazy.nvim does not update Neovim itself or every Mason
package. Lazygit has no role in installing Neovim plugins.

### Modes, buffers, windows, and tabs

- **Normal mode:** navigation and editing commands. Press `Esc` to return here.
- **Insert mode:** type text. Enter with `i`, `a`, `o`, etc.; leave with `Esc` or `jk`.
- **Visual mode:** select text, then apply an operation.
- **Command-line mode:** press `:` in Normal mode, type a command, and press `Enter`.
- **Terminal mode:** keystrokes go to a terminal application such as lazygit.
  `Ctrl-\` followed by `Ctrl-n` returns to Neovim's Normal mode in that terminal.

A **buffer** holds a file's text, a **window/split** displays a buffer, and a
**tab** holds a window layout. A file can appear in multiple windows. Closing a
window or tab does not delete the file. The custom `Space bn/bc/bo` keys manage
**tabs**, despite the `b` in their names; `:bnext`/`:bprevious` change buffers.

### Default editor behavior

- Space is the leader; `\` is the local leader. `Space pf` means press Space,
  then `p`, then `f` in sequence. `Ctrl-n` means hold Control and press `n`.
- Current line numbers are absolute; surrounding line numbers are relative.
  Use counts such as `5j` or `3k` to move by the displayed distance.
- Indentation is two spaces; tabs expand to spaces. Lines wrap at word boundaries.
- Mouse support is on. Searches preview while typing, without persistent match highlighting.
- Treesitter folds start open. `zc`, `zo`, and `za` close, open, and toggle folds.
- Files are **not autosaved** generally. Formatting runs when you save.
  The TODO window saves its task file on close/leave.
- Swap and backup files are off. Persistent undo is on in `~/.vim/undodir`.
- Ordinary `y`, `d`, and `p` use Vim registers. They do not automatically use
  the system clipboard; use the explicit clipboard keys below.
- No Command-key mappings are configured. Terminal shortcuts come from Kitty.

## Plugin catalog and default states

**Enabled** means included in the configuration. An enabled plugin can appear
under **Not Loaded** in `:Lazy` until its key, event, filetype, or dependency
triggers it. That is different from being disabled.

There are **30 external plugins in the lockfile**: 29 enabled and Copilot disabled.
The local TODO manager is listed separately. The tables include dependencies,
not just plugins with their own configuration files.

### Plugin management, language support, and completion

| Plugin | Default loading/state | What it does; entry point |
| --- | --- | --- |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Enabled; startup bootstrap | Installs/updates plugins, reads the lockfile; `:Lazy`. Config: [lazy.lua](lua/config/lazy.lua). |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Enabled; startup | Server definitions for Neovim's built-in LSP client; `gd`, `K`, and LSP keys after attachment. Config: [lsp.lua](lua/plugins/lsp.lua). |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | Enabled; LSP dependency | Installs external development tools; `:Mason`. Config: `lsp.lua`. |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Enabled; LSP dependency | Maps server names to Mason packages, installs/activates configured servers when prerequisites exist. Config: `lsp.lua`. |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Enabled; first Insert mode | Completion menu; `Ctrl-Space`, `Ctrl-n/p`, `Enter`. Config: [cmp.lua](lua/plugins/cmp.lua). |
| [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | Enabled; cmp dependency | Supplies language-server completion items to nvim-cmp; no separate shortcut. |
| [cmp-buffer](https://github.com/hrsh7th/cmp-buffer) | Enabled; cmp dependency | Suggests words from buffer text; no separate shortcut. |
| [cmp-path](https://github.com/hrsh7th/cmp-path) | Enabled; cmp dependency | Suggests filesystem paths; no separate shortcut. |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Enabled; cmp dependency | Expands snippet completion items. No dedicated snippet-jump keys or additional snippet collection are configured. |
| [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) | Enabled; cmp dependency | Connects LuaSnip to nvim-cmp; no separate shortcut. |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Enabled; save or `Space f` | Formats on save or request, with an LSP fallback; `:ConformInfo`. Config: [conform.lua](lua/plugins/conform.lua). |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Enabled; file read/save | Runs available `oxlint` on JS/TS buffers and publishes diagnostics; no custom shortcut. Config: [lint.lua](lua/plugins/lint.lua). |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Enabled; startup | Installs parsers for syntax highlighting/folds; `:TSInstall`, `:TSUpdate`. Config: [treesitter.lua](lua/plugins/treesitter.lua). |
| [copilot.vim](https://github.com/github/copilot.vim) | **Disabled** (`enabled = false`) | Optional AI inline suggestions. If enabled, loads on Insert mode; `:Copilot setup/status`, `Tab` accepts. Markdown suggestions remain disabled. Config: [copilot.lua](lua/plugins/copilot.lua). |

### Navigation and Git

| Plugin | Default loading/state | What it does; entry point |
| --- | --- | --- |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Enabled; picker shortcut | File, text, buffer, and recent-file pickers; `Space pf/gf/pg/bf`, `Ctrl-e`. Config: [telescope.lua](lua/plugins/telescope.lua). |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Enabled; Telescope dependency | Lua utilities used by Telescope; no direct UI/key. |
| [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | Enabled; Telescope dependency | Compiled native fuzzy-sorter extension, built with `make`. The config includes it but does **not** call `load_extension("fzf")`; it is not explicitly activated. |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | Enabled; startup | Edit directories as buffers, including file operations; `Space pv`, `-`. Config: [oil.lua](lua/plugins/oil.lua). |
| [flash.nvim](https://github.com/folke/flash.nvim) | Enabled; `VeryLazy` or shortcut | Labeled jumps with **`s`**, enhanced character motions and searches; command-line `Ctrl-s` toggles search integration. Config: [flash.lua](lua/plugins/flash.lua). |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Enabled; Git shortcut | Git status/blame; `Space gs/gb`. The same file supplies `Space lg` for the separate lazygit program. Config: [fugitive.lua](lua/plugins/fugitive.lua). |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Enabled; before reading a file | Git change signs in the gutter and hunk actions through `:Gitsigns`; **no custom hunk mappings** are configured. Config: [gitsigns.lua](lua/plugins/gitsigns.lua). |
| [flatten.nvim](https://github.com/willothy/flatten.nvim) | Enabled; early startup | Opens files requested by terminal programs in the current Neovim session; manages the lazygit float during file/commit edits. No custom key. Config: [flatten.lua](lua/plugins/flatten.lua). |
| [undotree](https://github.com/mbbill/undotree) | Enabled; `Space u` | Shows branching undo history; `Space u`. Config: [undotree.lua](lua/plugins/undotree.lua). |

### Display, themes, and local tools

| Plugin/module | Default loading/state | What it does; entry point |
| --- | --- | --- |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Enabled; `VeryLazy` or shortcut | Shows pending key sequences and mapping hints; pause after a prefix or use `Ctrl-?`. Config: [which-key.lua](lua/plugins/which-key.lua). |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Enabled; startup | Status line and tab line with filenames and diagnostic counts; no custom keys. Config: [lualine.lua](lua/plugins/lualine.lua). |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | Enabled; Oil/lualine dependency | File-type icons; needs an installed Nerd Font, no custom key. |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Enabled; Markdown filetype | Decorates headings, lists, checkboxes, code, and tables inside Neovim; `:RenderMarkdown toggle`. Config: [render-markdown.lua](lua/plugins/render-markdown.lua). |
| [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) | Enabled; startup; **active in dark mode** | Dark palette. Config: [themes/gruvbox.lua](lua/plugins/themes/gruvbox.lua). |
| [github-nvim-theme](https://github.com/projekt0n/github-nvim-theme) (`github-theme` in Lazy) | Enabled; on demand; **active in light mode** | Supplies `github_light`. Config: [themes/github.lua](lua/plugins/themes/github.lua). |
| [everforest-nvim](https://github.com/neanias/everforest-nvim) | Enabled; startup; **alternative, not selected automatically** | Optional `:colorscheme everforest`. Declared in both [everforest.lua](lua/plugins/everforest.lua) and [themes/everforest.lua](lua/plugins/themes/everforest.lua); Lazy merges them into one plugin. |
| Local TODO manager | Enabled; module evaluated at startup | Floating Markdown task manager; `Space td/ta/ts`. Code: [todo.lua](lua/plugins/todo.lua), [core.lua](lua/todo/core.lua). This is local code, not a downloaded Lazy plugin. |

The active theme is chosen by [colorscheme.lua](lua/config/colorscheme.lua):
`:set background=dark` selects Gruvbox; `:set background=light` selects GitHub
Light. A later background change can replace a manually selected Everforest.

## Installing, updating, enabling, and disabling plugins

### Navigate lazy.nvim

From Normal mode, type `:Lazy` and press `Enter`. Move to a plugin with `j`/`k`
or arrow keys, then use the following **inside the Lazy window**:

| Key | Action |
| --- | --- |
| `Enter` | Expand/collapse details for the selected plugin |
| `?` | Show Lazy's help; useful when plugin versions change |
| `H` | Return to the plugin list |
| `I` / `i` | Install missing plugins / install selected plugin |
| `C` / `c` | Check updates for all / selected plugin; does not apply updates |
| `U` / `u` | Update all / selected plugin and write the new lockfile revisions |
| `S` | Install missing plugins, remove unused ones, and update |
| `X` | Remove plugins no longer required by the config |
| `R` / `r` | Restore all / selected plugin from the current lockfile |
| `L` | Show update history/log view |
| `K` | Follow a link/help/commit under the cursor |
| `q` | Close Lazy and return to editing |

Case matters. Selected-plugin `x` deletes the selected plugin's local checkout;
it does **not** disable its declaration, so Lazy may install it again later.
Use `enabled = false` for a lasting configuration change.

These commands also work from Neovim's command line:

| Command | Use |
| --- | --- |
| `:Lazy install` | Install missing configured plugins |
| `:Lazy check` | Fetch/check available plugin revisions |
| `:Lazy update` | Update configured plugins |
| `:Lazy update telescope.nvim` | Update one plugin by its Lazy name |
| `:Lazy sync` | Install + clean + update; this can change existing versions |
| `:Lazy restore` | Match the current `lazy-lock.json` |
| `:Lazy clean` | Remove unused plugin checkouts |
| `:Lazy build telescope-fzf-native.nvim` | Rebuild the native Telescope dependency |
| `:Lazy load undotree` | Load an enabled plugin before its normal trigger |
| `:Lazy log` / `:Lazy profile` | Inspect revisions / startup loading time |

Checks run in the background, with `notify = false` in `lua/config/lazy.lua`.
An update indicator means a revision is available; it is not an installation
failure and does not mean an update was applied. See [Lazy usage](https://lazy.folke.io/usage).

### Update and recover using the lockfile

1. Save your files and preserve the current `lazy-lock.json` in Git or a backup.
2. Run `:Lazy check`, inspect the entries, then `u` for one plugin or `U` for all.
3. Wait for downloads/builds, restart Neovim, and check editing, completion,
   formatting, and Git navigation.
4. Review `git diff -- nvim/lazy-lock.json` from `computer_setup` and save the
   lockfile with your config changes so the other computer can use the same versions.

On your other machine, pull the config changes and run `:Lazy restore`. This
uses the recorded plugin revisions; `:Lazy update` selects newer revisions instead.

If an update breaks something, restore the **previous lockfile** from Git or your
backup, then run `:Lazy restore` and restart. Running `:Lazy restore` against the
already-updated lockfile does not undo that update. For a tracked lockfile, the
shell command below restores one file from a known working commit:

```sh
# Run in computer_setup; replace KNOWN_GOOD_COMMIT with your working Git revision.
git restore --source=KNOWN_GOOD_COMMIT -- nvim/lazy-lock.json
```

The lockfile covers plugins, not Neovim, Mason packages, or your OS toolchains.
See [Lazy lockfiles](https://lazy.folke.io/usage/lockfile).

### Keep the other installation layers current

| Layer | Update method |
| --- | --- |
| Neovim plugins | `:Lazy update`, then review/save the changed lockfile |
| Mason-installed servers/tools | `:Mason`, `C` to check, `U` to update; inspect package logs |
| Treesitter parsers | `:TSUpdate` |
| Ubuntu apt packages, including NodeSource's Node.js | Normal apt package updates; the versioned Go package updates within its installed series |
| Ubuntu's manually downloaded Neovim/tree-sitter | Rerun the CPU-selection and corresponding download/extract/link commands in installation |
| Ubuntu's Go-installed lazygit | Rerun `GOBIN="$HOME/.local/bin" go install github.com/jesseduffield/lazygit@latest` |
| macOS Homebrew tools | `brew update`, then `brew upgrade` for the installed formulae |

Restart Neovim after updating its executable or plugins. A new plugin or server
version may require newer runtimes; inspect its log/requirements if an update fails.

### Enable, disable, add, or pin a plugin

Edit the plugin's declaration under `lua/plugins/` or `lua/plugins/themes/`.
For example, [copilot.lua](lua/plugins/copilot.lua) currently contains:

```lua
return {
  "github/copilot.vim",
  enabled = false, -- change to true to enable; keep the file's other settings
  -- ...
}
```

Save, restart Neovim, then use `:Lazy install` if needed. Enabling Copilot also
requires `:Copilot setup` to authenticate; `:Copilot status` diagnoses it.
Normal LSP/snippet completion needs no Copilot account. If enabled, Copilot uses
`Tab` for accepting suggestions and is still disabled for Markdown by its settings.

For another plugin, add `enabled = false` to its existing spec, save, and restart.
Use `:Lazy clean` to remove its now-unused files. To re-enable, remove that field
or set it to `true`, restart, and install missing plugins. `lazy = true` only
changes **when** a plugin loads; it does not disable it.

To add a plugin, create `lua/plugins/your_plugin.lua` returning its real GitHub
slug, then follow that plugin's setup documentation:

```lua
return {
  "owner/plugin.nvim", -- replace with the plugin you want
  enabled = true,
}
```

To retain a working revision, add `pin = true` to its spec before updating other
plugins, or set `commit = "FULL_COMMIT_HASH"` to explicitly select a revision.
Use the names shown in Lazy for commands, e.g. `github-theme`, not necessarily
the repository's final path component. See [plugin spec options](https://lazy.folke.io/spec).

Some declarations have dependencies or code that needs special handling:

- Do not disable a dependency while its parent still requires it; for example,
  `nvim-cmp` needs LuaSnip and the completion sources.
- Gruvbox and GitHub Light are referenced by `lua/config/colorscheme.lua`; change
  that selection before disabling a required theme. Everforest has two declarations.
- The TODO module executes when imported and returns an empty spec. To disable
  it, move `lua/plugins/todo.lua` to a location outside `lua/plugins/`, such as
  `disabled/todo.lua`, and restart. A field on its empty return value will not
  undo its already-created mappings. Restore the file to re-enable it; its task
  files in your home directory are preserved.

## Language servers, formatters, linters, and parsers

### Mason and language servers

The install/enable list comes from [lsp_tools.lua](lua/config/lsp_tools.lua),
used by [lsp.lua](lua/plugins/lsp.lua). Mason installs eligible missing servers
at interactive startup, then enables installed servers. They attach only to
matching files/projects. Missing prerequisites give a warning with
`:checkhealth setup` instructions, rather than repeated failed install jobs.

| Language/support | LSP name in config | Mason package name | External prerequisite |
| --- | --- | --- | --- |
| Lua | `lua_ls` | `lua-language-server` | Downloaded binary |
| TypeScript/JavaScript | `ts_ls` | `typescript-language-server` | Node.js and npm |
| ESLint | `eslint` | `eslint-lsp` | Node.js/npm; project ESLint configuration |
| Python | `pyright` | `pyright` | Node.js and npm, even though the edited language is Python |
| Go | `gopls` | `gopls` | Go toolchain |
| Rust | `rust_analyzer` | `rust-analyzer` | Downloaded binary; Rust toolchain for project work |
| C/C++ | `clangd` | `clangd` | Downloaded binary; project headers/build metadata such as `compile_commands.json` |

The optional `oxlint` LSP also enables when its project-root test finds both a
project and a global or project-local `oxlint` executable. It is not in Mason's
automatic server install list.

Open `:Mason`, move with `j/k`, and search with `/`. Its default controls are:

| Key/command | Action |
| --- | --- |
| `Enter` | Expand a package or inspect its install log |
| `i` / `u` | Install selected package / reinstall or update it |
| `C` / `U` | Check installed package updates / update installed packages |
| `X` | Uninstall selected package |
| `g?` / `q` | Help / close Mason |
| `:MasonUpdate` | Refresh registry metadata, not all installed tool binaries |
| `:MasonLog` | Open installation logs |
| `:MasonInstall pyright` | Install a package using its Mason name |
| `:MasonUninstall pyright` | Remove that package |

To retry the servers that previously failed:

```vim
:MasonInstall typescript-language-server eslint-lsp pyright gopls
```

If `npm`/`node`/`go` is missing, complete the OS installation steps and restart
Neovim from that shell. `:checkhealth setup` checks executable presence, not full
version compatibility; use the shell version checks too. If tools are installed
but a server does not attach, inspect `:checkhealth vim.lsp` and `:LspLog`.

To permanently disable one of the seven automatic servers, remove its entry from
`lua/config/lsp_tools.lua`, restart, and optionally uninstall it through Mason.
Otherwise a package removed with Mason is installed again when eligible at startup.
Disabling the `oxlint` LSP separately requires editing its enable call in `lsp.lua`.

### Formatting and diagnostics

`Space f` requests formatting; saving also formats, with a three-second timeout
and LSP formatting as a fallback. `:ConformInfo` shows which formatter was found.

| Filetype | Preferred formatter |
| --- | --- |
| Lua | `stylua` |
| JS/TS/JSX/TSX, JSON/JSONC, Markdown, YAML, CSS, GraphQL | `oxfmt` |
| Go | `gofmt` from Go |
| Rust | `rustfmt` |
| C/C++ | `clang-format` |
| Python | No external formatter configured; LSP fallback only if supported by the attached server |

Install `stylua`, `oxfmt`, `oxlint`, and `clang-format` through Mason as shown in
installation. Pyright is not a Python formatter. To turn off automatic formatting
but keep `Space f`, remove the `format_on_save` table in `lua/plugins/conform.lua`.

ESLint fix-all is requested before saves when its server is attached. nvim-lint
also runs available `oxlint` on reading/saving JS/TS files. The oxlint LSP can
provide additional diagnostics; this setup has both integrations. Gutter signs,
diagnostic floats, and the quickfix list are different views of diagnostics.

### Treesitter and Markdown

The configured parser list is `vimdoc`, `lua`, `typescript`, `tsx`, `go`,
`javascript`, `python`, `rust`, `c`, `cpp`, `markdown`, and `markdown_inline`.
Use `:TSInstall language` for an additional parser and `:TSUpdate` after relevant
updates. Add a parser to `treesitter.lua` if you want it in the configured build list.

Render Markdown decorates Markdown buffers in the terminal; it is not a browser
preview. `:RenderMarkdown toggle` switches it on/off after opening a Markdown file.
Markdown indentation stays at two spaces through `after/ftplugin/markdown.lua`.

## Configured keybindings

These mappings come from this repository. Plugin-window defaults are described
in the next section. A buffer-local mapping takes precedence over a global one.

### Editing, clipboard, and lists

| Key | Mode | Action |
| --- | --- | --- |
| `jk`, `Ctrl-c` | Insert | Return to Normal mode (`Esc`) |
| `J` | Normal | Join the next line and restore cursor position |
| `J` / `K` | Visual | Move selection down/up; reindent except in Markdown |
| `Ctrl-d` / `Ctrl-u` | Normal | Scroll half a screen, then center cursor |
| `n` / `N` | Normal | Repeat search forward/back relative to its direction; center/unfold result |
| `Space y` + motion | Normal | Yank to system clipboard; e.g. `Space y w` |
| `Space y` | Visual | Copy selection to system clipboard |
| `Space Y` | Normal | Copy the whole line to system clipboard |
| `Space yf` | Normal | Copy the buffer's path, possibly relative; in Oil, copy its current directory |
| `Space p` | Visual | Replace selection without overwriting the yank register |
| `Space d` + motion | Normal | Delete into the black-hole register; e.g. `Space d w` |
| `Space d` | Visual | Delete selection without changing registers |
| `Space dq` | Normal | Populate quickfix from diagnostics; open it with `:copen` |
| `Ctrl-n` / `Ctrl-p` | Normal | Next/previous quickfix item; center cursor |
| `Space n` / `Space p` | Normal | Next/previous location-list item |
| `Q` | Normal | Disabled |
| `Ctrl-?` | Normal | Show which-key mappings; terminal support for this combination varies |

`Space y` and `Space d` are operator prefixes in Normal mode, not immediate
copy/delete actions. They share prefixes with longer mappings, so Neovim may
wait briefly to determine the sequence. When an LSP is attached, `Space dd`
opens diagnostics; use `"_dd` to delete an entire line without saving it in a register.

### Files, search, and jumping

| Key | Mode | Action |
| --- | --- | --- |
| `Space pv`, `-` | Normal | Open Oil on the parent directory |
| `Space pf` | Normal | Telescope: find files |
| `Space gf` | Normal | Telescope: Git-tracked files |
| `Space pg` | Normal | Telescope: live grep of file contents |
| `Space bf` | Normal | Telescope: open buffers |
| `Ctrl-e` | Normal | Telescope: recent files |
| **`s`** | Normal/Visual/operator-pending | Flash: type a search, then its displayed jump label |
| `f` / `F` / `t` / `T`, `;` / `,` | Normal/Visual/operator-pending | Flash-enhanced character motions, including across lines by default |
| `/`, `?` | Normal | Regular searches enhanced by Flash |
| `Ctrl-s` | Command-line search | Toggle Flash search integration |

**`Space s` is not the configured Flash shortcut.** Use `s` directly.
The commented-out Telescope `Space ps` and `Space fh` examples are not active.

### Language-server actions and completion

Except for global `Space dq`, the LSP actions below are installed **when a server
attaches to a buffer**. Their availability depends on that server's capabilities.

| Key | Mode | Action |
| --- | --- | --- |
| `gd` | Normal | Go to definition through the LSP |
| `K` | Normal | Hover documentation |
| `Space ws` | Normal | Workspace-symbol search |
| `Space ca` | Normal | Code action |
| `Space rr` | Normal | References |
| `Space rn` | Normal | Rename symbol |
| `Space dd` | Normal | Diagnostic float |
| `[d` / `]d` | Normal | Previous/next diagnostic |
| `Ctrl-h` | Insert | Signature help; use `Backspace` to delete text |
| `Ctrl-Space` | Insert | Request completion |
| `Ctrl-n` / `Ctrl-p`, Down/Up | Insert | Select next/previous completion candidate |
| `Ctrl-e` | Insert | Abort completion |
| `Enter` | Insert | Accept completion; selects an item if none is selected |
| `Ctrl-y` | Insert | nvim-cmp preset: accept the selected completion |

`Tab` has no custom completion/snippet mapping with Copilot disabled. These are
completion keys, not the Normal-mode quickfix or recent-file commands.

### Splits, tabs, Git, and undo

| Key | Mode | Action |
| --- | --- | --- |
| `Space sv` / `Space sh` | Normal | Vertical / horizontal split |
| `Space sx` / `Space se` | Normal | Close split / equalize split sizes |
| `Ctrl-Up` / `Ctrl-Down` | Normal | Increase/decrease split height |
| `Ctrl-Left` / `Ctrl-Right` | Normal | Decrease/increase split width |
| `Shift-H` / `Shift-L` (`H` / `L`) | Normal | Previous/next tab |
| `Space bn` / `Space bc` / `Space bo` | Normal | New tab / close tab / close other tabs |
| `Space gs` | Normal | Fugitive Git status |
| `Space gb` | Normal | Fugitive Git blame |
| `Space lg` | Normal | Open the lazygit terminal |
| `Space u` | Normal | Toggle undo tree |
| `Space f` | Normal | Format buffer |

**`Space sh` opens a horizontal split; it does not search help.** For help use
`:help topic`. For moving between splits, use built-in `Ctrl-w h/j/k/l`.

## Tool workflows and their local keys

### Oil: files and directories

Open with `Space pv` or `-`, navigate with `j/k`, and press `Enter` to open an
entry. Hidden files are shown. Sorting starts with directories first, then newest
modification time. Oil's buffer is editable: change a filename to rename it,
add a line to create an entry (`name/` for a directory), or delete a line to
request removal. **`:w` applies the filesystem operations** after Oil's prompts;
editing the listing is not just changing a text document.

| Key in an Oil buffer | Action |
| --- | --- |
| `Enter` | Open entry |
| `-` / `_` | Parent directory / Neovim's working directory |
| `Ctrl-s` / `Ctrl-h` / `Ctrl-t` | Open entry in vertical split / horizontal split / tab |
| `Ctrl-p` | Preview entry |
| `Ctrl-c` | Close Oil in Normal mode |
| `Ctrl-l` | Refresh listing |
| `g.` | Toggle hidden files |
| `gx` | Open entry with the system's external application |
| `g\` | Toggle viewing the trash |
| A backtick / `g~` | Change Neovim's working directory / current tab's working directory to Oil's directory |
| `gs` | Choose sorting interactively |
| `Space st` | Custom toggle: name sort / newest modification time |
| `Space yf` | Custom copy of current directory to system clipboard |
| `g?` | Oil's local keybinding help |

If terminal flow control intercepts `Ctrl-s`, use `Enter` to open an entry and
then `Space sv` for a split, or adjust terminal flow control separately.
See [Oil help](https://github.com/stevearc/oil.nvim/blob/master/doc/oil.txt).

### Telescope: find a file or text

`Space pf` opens a file picker; type part of its name, move to a result, and
press `Enter`. `Space pg` searches file contents using ripgrep. These searches
use Neovim's current working directory; inspect it with `:pwd` and change it
with `:cd /path/to/project` if you are searching the wrong tree.

| Key in a picker | Action |
| --- | --- |
| `Ctrl-n/p` or arrows | Move through results while typing |
| `Enter` | Open selection |
| `Ctrl-x` / `Ctrl-v` / `Ctrl-t` | Open in horizontal split / vertical split / tab |
| `Ctrl-u/d` | Scroll preview up/down |
| `Tab` / `Shift-Tab` | Toggle a result's selection and advance/back up |
| `Ctrl-q` | Send results to quickfix and open the list |
| `Ctrl-/` | Show picker mappings in Insert mode |
| `Esc` | Enter the picker's Normal mode; press again to close |
| `Ctrl-c` | Close directly from Insert mode |
| `?` | Show picker mappings in Normal mode |

File enumeration follows Telescope/ripgrep's normal ignore behavior; Oil's
`show_hidden = true` does not make Telescope include all hidden/ignored files.

The native fzf dependency is installed but not explicitly loaded as an extension.
To activate it, add this field to the existing spec in `lua/plugins/telescope.lua`,
keeping its dependencies and keys, then restart:

```lua
config = function()
  require("telescope").setup({})
  require("telescope").load_extension("fzf")
end,
```

### Lazygit: Git navigation and commits

Start Neovim in your project directory and press `Space lg`. The float runs the
separately installed `lazygit` executable with [lazygit/config.yml](lazygit/config.yml).
Keystrokes now belong to lazygit; Neovim's Space mappings do not operate inside it.

| Key in lazygit | Action/context |
| --- | --- |
| `j/k` or Up/Down | Move within a list |
| `h/l` or Left/Right | Move between side panels |
| `1`–`5` | Focus a numbered side panel; read its heading |
| `[` / `]` | Change the focused panel's tab, such as branches/remotes/tags |
| `0` | Focus the main/diff view |
| `Enter` | Files: focus the selected file's diff; other panels: inspect the selected item |
| `Tab` | Switch between applicable diff panes |
| `/` | Search/filter the current list/view |
| `Space` | Files: stage/unstage selected file; diff: stage/unstage selection |
| `a` | Files: toggle staging all files; diff: toggle hunk/line selection |
| `v` | Begin/end a range selection where supported |
| `c` / `C` | Files: commit in the popup / commit using the external editor |
| `e` | Files/diff: edit the selected file in Neovim |
| `n` / `Space` | Local branches: create a branch / check out a branch |
| `f` | Files: fetch remote refs |
| `p` / `P` | Pull / push the current branch |
| `R` | Refresh local Git views; does not fetch |
| `Esc` | Back out of a diff, popup, or menu |
| `?` | Context-aware keybinding help |
| `q` | Quit lazygit and return to Neovim |

For a typical commit: choose Files, inspect a changed file with `Enter`, stage
what you want with `Space`, return with `Esc`, then `c` and submit the message.
Use `P` only when you intend to publish commits. Keys vary by context/version;
the footer and `?` describe the active operation, including discard/reset actions.
See [lazygit keybindings](https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md).

Flatten handles editor handoffs: `e` opens the file in this Neovim session and
closes the lazygit float. For a blocking commit-message edit, the float hides;
write the message and close its buffer/window to finish the handoff, after which
lazygit resumes. Use `:wq` for a simple one-window commit message. Reopen lazygit
with `Space lg` after a nonblocking file edit.

Diffs use [bin/delta-auto](bin/delta-auto), which calls the installed `delta`
program. The launcher adds this directory to the child PATH and sets
`EDITOR=VISUAL=nvim`; no extra lazygit symlink is needed inside Neovim.
The old custom `wt`/`wt-rm` worktree shortcuts are excluded; use lazygit's built-in
worktree commands and its `?` menu. To use the same config from an ordinary shell,
add the following to `~/.bashrc` (Ubuntu) or `~/.zshrc` (macOS):

```sh
# Use Neovim for command-line editing and the bundled lazygit configuration/pager.
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.config/nvim/bin:$PATH"
export LG_CONFIG_FILE="$HOME/.config/nvim/lazygit/config.yml"
```

### Fugitive, Gitsigns, and undo history

- `Space gs` opens Fugitive status. In that status buffer, `s` stages, `u`
  unstages, `=` expands a diff, and `cc` begins a commit. `g?` shows local help.
  `Space gb` opens blame. After loading Fugitive with a shortcut, `:Git ...`
  runs a Git command. See `:help fugitive` for the status workflow.
- Gitsigns shows additions/changes/deletions beside file text. Its commands
  include `:Gitsigns preview_hunk`, `:Gitsigns stage_hunk`, and
  `:Gitsigns reset_hunk` (discards that hunk's edits). No `]c`, `[c`, or hunk
  staging shortcuts have been added by this config; use its commands/help.

`Space u` opens/closes Undotree. Move focus into its split with `Ctrl-w w`.
Its local keys include:

| Key in Undotree | Action |
| --- | --- |
| `J` / `K` | Previous/next undo state |
| `<` / `>` | Previous/next saved state |
| `Tab` | Return focus to the file window |
| `D` | Toggle the diff pane |
| `?` / `q` | Show local help / close the undo panel |

Ordinary `u` and `Ctrl-r` remain undo/redo in file buffers. The history can
survive restarts, but persistent undo is not a backup or an autosave of unsaved files.

### TODO and Markdown notes

| Key | Context | Action |
| --- | --- | --- |
| `Space td` | Normal | Toggle the TODO window |
| `Space ta` | Normal | Open the archive |
| `Space ts` | Normal | Request a completed-work summary using the optional `claude` CLI |
| `q` | TODO/archive/summary window | Close; editable TODO/archive content saves on close |
| `Space d` | TODO window | Mark task done and move it under today's Done date |
| `Space b` | TODO window | Move to Blocked (`[!]`) or back to This Week (`[ ]`) |
| `Space p` | TODO window | Promote Backlog → This Week → Today |
| `Space m` | TODO window | Prompt for a meeting and log it under Done |
| `Space l` | TODO window | Log progress linked to the task under the cursor |
| `Space a` | TODO window | Insert a sibling task and enter Insert mode |
| `Space n` | TODO window | Insert an indented note bullet and enter Insert mode |

The task file is `~/.todo.md`, with Today, This Week, Backlog, Blocked, and Done
sections. Tasks use `[ ]`, `[!]`, and `[x]`; plain bullets can group subtasks.
Completed tasks are grouped by ISO date. Opening the TODO window archives Done
day-groups older than 30 days to `~/.todo-archive.md`. Native `dd`/`p` moves tasks
between sections; `u` undoes an edit.

Only AI summaries require an installed/authenticated `claude` CLI. They send the
Done section and archive as input to that command; you choose a timeframe and
whether to show the result or append it to `~/.todo-summaries.md`.

TODO keys are buffer-local: in this window `Space d/p/n` mean task operations,
not the global black-hole delete/location-list actions. Plain `q` closes this
window rather than starting macro recording.

## Vim fundamentals and everyday reference

This section covers built-in editing concepts. Where this config changes a key,
the table says so; the [override summary](#overrides-and-corrections-to-older-notes)
collects the main differences. Commands are case-sensitive. Ex commands below
include `:`; Normal-mode key sequences do not.

### Getting into and out of modes

| Key | From | Result |
| --- | --- | --- |
| `i` / `a` | Normal | Insert before / after cursor |
| `I` / `A` | Normal | Insert at first nonblank / end of line |
| `o` / `O` | Normal | Open a new line below / above and enter Insert mode |
| `Esc` | Insert/Visual | Return to Normal mode |
| `jk` | Insert, custom | Return to Normal mode; this sequence does not insert literal `jk` |
| `v` | Normal | Characterwise Visual selection |
| `V` | Normal | Linewise Visual selection |
| `Ctrl-v` | Normal | Rectangular/block Visual selection |
| `:` | Normal | Enter an Ex command |

Normal-mode edits commonly follow **count + operator + motion/text object**:
`3dw` deletes three words; `ciw` changes the word under the cursor.
Visual mode reverses that order: select with `v`/`V`/`Ctrl-v`, move to extend the
selection, then press `y`, `d`, `c`, `>`, or `<`. `gv` reselects the last selection;
`o` in Visual mode switches which end you extend. `J`/`K` move selected lines in
this config rather than performing their usual Visual actions.

### Motions, searching, and returning to locations

| Key | Action in Normal mode |
| --- | --- |
| `h`, `j`, `k`, `l` | Left, down, up, right; prefix a count such as `5j` |
| `gj` / `gk` | Down/up a displayed wrapped line |
| `w` / `b` / `e` | Next word start / previous word start / word end |
| `W` / `B` / `E` | Same using whitespace-separated WORDs |
| `0` / `^` / `$` | Start of line / first nonblank / end of line |
| `gg` / `G` | First / last line of the buffer, not just the visible screen |
| `42G` or `:42` | Go to line 42 |
| `Ctrl-f` / `Ctrl-b` | Forward/back one screen |
| `Ctrl-d` / `Ctrl-u` | Half-screen down/up; this config additionally centers the cursor |
| `zz` / `zt` / `zb` | Position current line at middle / top / bottom of screen |
| `M` | Middle visible line; default `H`/`L` screen motions are overridden by tab navigation |
| `{` / `}` | Previous/next paragraph boundary |
| `%` | Jump to matching delimiter such as `(` and `)` |
| `/word` then `Enter` | Search forward; the pattern can be a Vim regular expression |
| `?word` then `Enter` | Search backward |
| `n` / `N` | Repeat the search in its direction / reverse direction; centered here |
| `*` / `#` | Search forward/backward for the word under the cursor |
| `fx` / `Fx` | Find character `x` forward/backward; enhanced by Flash here |
| `tx` / `Tx` | Stop just before/after character `x`; enhanced by Flash here |
| `;` / `,` | Repeat / reverse the last character-search direction |
| `Ctrl-o` / `Ctrl-i` | Older/newer location in the jump list |
| `g;` / `g,` | Older/newer location in the change list |
| `ma`, `'a`, `` `a `` | Set mark `a`; return to its line / exact position |
| `gd` | With attached LSP: definition, possibly in another file; otherwise built-in local declaration search |
| `]m` / `[m` | Built-in next/previous method start for Java-like brace structures; not universal semantic function navigation |
| `zc` / `zo` / `za` | Close/open/toggle a fold |

Flash's character-motion mode is multiline here, so `f/F/t/T` are not restricted
to the current line as they are in plain Vim. `s` begins a labeled Flash jump.
For the exact built-in motion rules, use `:help motion.txt`.

### Operators, editing commands, and text objects

| Operator | Meaning | Examples |
| --- | --- | --- |
| `d` | Delete/cut the following motion/object | `dw`, `d$`, `diw`, `dd` |
| `c` | Change: delete then enter Insert mode | `cw`, `ciw`, `ci"`, `cc` |
| `y` | Yank/copy | `yw`, `yi{`, `yy` |
| `>` / `<` | Indent / unindent | `>>`, `<<`, Visual `>`/`<` |
| `=` | Reindent | `==`, `=ap`; distinct from `Space f` code formatting |
| `gu` / `gU` | Lowercase / uppercase | `guiw`, `gUiw` |

`p`, `x`, and `r` are useful editing commands, but they are not operators waiting
for a motion in the same way as `d/c/y`:

| Command | Action |
| --- | --- |
| `p` / `P` | Put after/below / before/above, depending on the register's type |
| `yy` / `dd` / `cc` | Copy line / delete line / change line |
| `x` / `X` | Delete character under / before cursor |
| `rx` | Replace character under cursor with `x` |
| `R` | Replace mode until `Esc` |
| `D` / `C` | Delete / change to end of line |
| `u` / `Ctrl-r` | Undo / redo |
| `.` | Repeat the last repeatable edit; not every movement or Ex command |

Text objects describe a unit around the cursor. Use
**operator + `i` (inner) or `a` (around) + object**. For words, “around” usually
includes adjacent whitespace; for delimiters it includes the delimiters.
Visual `iw`, `a{`, etc. can also adjust a selection.

| Object | Inner example | Around example |
| --- | --- | --- |
| `w` / `W` | `iw` / `iW`: word / WORD | `aw` / `aW`: include surrounding space as appropriate |
| `s` | `is`: sentence | `as`: sentence with surrounding space |
| `p` | `ip`: paragraph | `ap`: paragraph including adjacent blank lines as appropriate |
| `(` or `b` | `i(` / `ib`: inside parentheses | `a(` / `ab`: include parentheses |
| `{` or `B` | `i{` / `iB`: inside braces | `a{` / `aB`: include braces |
| `[` | `i[`: inside square brackets | `a[`: include brackets |
| `<` | `i<`: inside angle brackets | `a<`: include angle brackets |
| `'`, `"`, or a backtick | `i'`, `i"`, ``i` ``: contents of quotes | `a'`, `a"`, ``a` ``: include quotes |
| `t` | `it`: inside a matching tag | `at`: include the matching tags |

**`e` is a motion, not a text object.** Use `de` to delete to the end of a word,
or `diw` to delete the whole word around the cursor.

| Combination | Meaning |
| --- | --- |
| `yi{` / `ya{` | Copy inside braces / include braces |
| `ci{` / `ca{` | Change inside braces / include braces |
| `di{` / `da{` | Delete inside braces / include braces |
| `ciw` | Replace the current word without its surrounding whitespace |
| `ci"` | Replace the contents of double quotes |
| `dap` | Delete a paragraph using its “around” object |

See `:help operator` and `:help text-objects` for details.

### Registers, clipboard, and macros

| Register | Contents/use |
| --- | --- |
| `"` | Unnamed/default register used by ordinary copying, cutting, and putting |
| `a`–`z` | Explicit named storage; uppercase names append to the corresponding lowercase register |
| `0` | Most recent yank without an explicitly named destination; useful after subsequent deletes |
| `1`–`9` | Numbered deletion/change history, especially linewise/multiline changes |
| `-` | Small deletions, usually changes shorter than one line |
| `_` | Black hole: discard without changing the useful registers |
| `+` | System clipboard, through the OS clipboard provider |

Use `"{register}{operator}{motion}` to select a destination, and
`"{register}p` to put from it:

```text
"ayy    copy a line into register a
"ayas   copy a sentence into register a
"adw    cut a word into register a
"ap     put register a after the cursor
"0p     put the last ordinary yank, even after deleting other text
"_dd    delete a line without overwriting registers
"+p     put system clipboard contents
```

`:registers` (or `:reg`) displays registers; `:reg a` inspects one.
In Insert mode, **`Ctrl-r` followed by a register** inserts its contents:
`Ctrl-r "` uses the unnamed register, `Ctrl-r a` the named register, `Ctrl-r 0`
the yank register, and `Ctrl-r +` the clipboard. Normal-mode `Ctrl-r` is redo.

Putting over a Visual selection with ordinary `p` can replace the unnamed
register with the removed text; use custom `Space p` to preserve it.
Clipboard copying uses `Space y`/`Space Y`; Ubuntu needs `xclip` or `wl-clipboard`,
while macOS has built-in clipboard commands.

For a repeatable sequence, `qa` starts recording into register `a`, plain `q`
stops, `@a` plays it, and `@@` repeats the last playback. `3@a` runs it three
times. This config disables `Q`, but `@a`/`@@` still work. TODO's local `q` closes
the task window instead of starting/stopping a recording.

### Ex commands: saving, quitting, files, splits, and shell commands

Ex commands are the commands introduced by `:`. Press `Enter` to run them.
`:q` closes a **window**, not necessarily the buffer or the entire editor.

| Command | Action |
| --- | --- |
| `:w` | Save the current file |
| `:w other-name` | Write a copy under another name |
| `:q` | Close current window; refuses to abandon unsaved changes |
| `:q!` | Force-close current window, abandoning unsaved changes when leaving that buffer |
| `:wq` | Save and close current window |
| `:x` | Save if changed, then close current window |
| `:wa` | Write all modified writable file buffers |
| `:qa` / `:qa!` | Quit all windows / force quit and abandon unsaved changes |
| `:e file` | Open a file in the current window |
| `:e!` | Reload the current file from disk, discarding its unsaved edits |
| `:ls` / `:buffers` | List buffers |
| `:b number` or `:b name` | Switch to a listed buffer |
| `:bnext` / `:bprevious` | Next/previous buffer |
| `:bdelete` | Remove current buffer from the buffer list; does not delete the disk file |
| `:sp file` | Open file in a horizontal split |
| `:vsp file` | Open file in a vertical split |
| `:tabnew file` | Open file in a new tab |
| `:tabclose` / `:tabonly` | Close current tab / close other tabs |
| `:pwd` / `:cd directory` | Show/change the working directory |
| `:!command` | Run a shell command, e.g. `:!git status` |
| `:terminal` | Open an interactive terminal in a buffer |
| `:help topic` | Open built-in help, e.g. `:help registers` |

Built-in window navigation still works: `Ctrl-w h/j/k/l` focuses a neighboring
split, `Ctrl-w w` cycles splits, `Ctrl-w v`/`Ctrl-w s` splits vertically/horizontally,
and `Ctrl-w =` balances sizes. `gt`/`gT` move to the next/previous tab.
In help, `Ctrl-]` follows a help tag and `Ctrl-t` returns; `Ctrl-w w` returns
focus to another window.

### Ex ranges: operations on multiple lines

Many line-editing commands follow `:[range]command[options]`. For deletion:
`:[range]d [register]`. Ranges are inclusive; a comma separates the two ends.

| Example | Meaning |
| --- | --- |
| `:10,12d` | Delete lines 10–12 |
| `:10,12d a` | Delete lines 10–12 into register `a` |
| `:10,10+2d` | Delete lines 10–12 using an explicit offset |
| `:.,+2d` | Delete the current line and the next two |
| `:%d` | Delete the whole buffer |
| `:1,10d` | Delete the first ten lines |
| `:.,$d` | Delete from current line to the final line |
| `:10,12y a` | Copy lines 10–12 to register `a` |
| `:10,12m $` | Move lines 10–12 to the end |
| `:'<,'>d` | Delete the whole lines spanned by the last Visual selection |
| `:0put a` | Put register `a` before the first line |

`.` means current line, `$` the last line, and `%` all lines (`1,$`). `0` is a
special address **before** the first line for commands that accept it; use
`:1,10d` to delete the first ten lines, not `:0,+10d`.

An unqualified `+2` is relative to the current line. Therefore **`:10,+2d` is
not generally lines 10–12**. `:10,10+2d` is explicit; `:10;+2d` also works because
`;` makes line 10 the current address before evaluating `+2`.

Pressing `:` from Visual mode inserts `:'<,'>` automatically. These Ex ranges
normally operate on **whole lines**, even if the Visual selection was characterwise
or rectangular. Use Visual `d/c/y` when you want only the selected text.
See `:help :range`.

### Find and replace

The general form is `:[range]s/{pattern}/{replacement}/{flags}`. The default
range is the current line; `%` chooses the whole file. Patterns use Vim regex.

| Command | Action |
| --- | --- |
| `:s/led/gold/` | First occurrence on the current line |
| `:s/led/gold/g` | Every occurrence on the current line |
| `:%s/led/gold/g` | Every occurrence throughout the buffer |
| `:%s/led/gold/gc` | Throughout buffer, confirm each replacement |
| `:%s/led/gold/gci` | Same, ignoring case |
| `:'<,'>s/led/gold/g` | Replace on the selected lines |

Flags: `g` replaces multiple matches per line, `c` asks for confirmation, and
`i` ignores case (`I` forces case sensitivity). With confirmation, `y` accepts,
`n` skips, `a` accepts the rest, and `q` stops. The pattern `led` also matches
inside larger words; use `\<led\>` when you want word boundaries.

For an interactive change-and-repeat workflow:

1. Search with `/word` and press `Enter`.
2. Type `cgn`, enter the replacement, then `Esc`.
3. Press `.` to change the next match, or `n` to skip one.

Here `gn` selects the next/current search match; `cgn` changes that match.
Use `:help :substitute` and `:help gn` to explore the details.

## Overrides and corrections to older notes

These are changes to useful built-in keys, rather than the additional leader
shortcuts listed earlier. Local plugin windows can replace more keys with their
own actions; consult their local help before treating them as file-editing commands.

| Key/context | Built-in behavior | Behavior in this setup |
| --- | --- | --- |
| `s`, Normal/Visual | Substitute character/selection and enter Insert mode | Flash jump; use `cl`/`c` to perform the edit instead |
| `-`, Normal | Previous line's first nonblank | Open Oil / go to parent directory in Oil |
| `Ctrl-e`, Normal | Scroll view down | Recent-file picker |
| `Ctrl-n/p`, Normal | Move down/up | Quickfix next/previous |
| `H` / `L`, Normal | Top/bottom visible line | Previous/next tab |
| `J`, Normal | Join lines | Join while preserving cursor position |
| `J` / `K`, Visual | Join selection / keyword lookup | Move selected lines down/up |
| `Ctrl-d/u`, Normal | Half-screen scroll | Same, then center cursor |
| `n/N`, Normal | Repeat search | Same, then center/unfold result |
| `gd`, LSP buffer | Local declaration search | LSP definition lookup |
| `K`, LSP buffer | Keyword-program lookup | LSP hover documentation |
| `Ctrl-h`, Insert in LSP buffer | Delete previous character | Signature help |
| `Ctrl-n/p`, `Ctrl-e`, `Enter`, Insert | Keyword completion / copy character from line below / newline | nvim-cmp selection, abort, and accept when its menu applies |
| `jk`, Insert | Type two characters | Leave Insert mode |
| `Ctrl-c`, Insert | Abort Insert mode | Explicitly mapped to `Esc` |
| `Q`, Normal in Neovim | Replay the last recorded register | Disabled; use `@a` or `@@` |

Corrections to the older learning notes and README:

- Flash uses **`s`**, not `Space s`.
- **`Space sh` is a horizontal split**, not help search; use `:help`.
- `Space bn/bc/bo` operate on tabs, not buffers.
- `gd` is only LSP definition lookup after an LSP attaches; it is not limited to the current file.
- `gg`/`G` go to the buffer's beginning/end, not the visible page.
- `e` is a word-end motion, not an inner/around text object.
- Use `:10,10+2d` or `:10;+2d` for lines 10–12. Use `:1,10d` for the first ten lines.
- Neovim maps plain `Y` to `y$` by default. This config's nonrecursive `Space Y`
  mapping uses the underlying linewise `Y` command to copy a whole line to `+`;
  ordinary `yy` is also a whole-line yank.
- Copilot is disabled, so `Tab` does not accept AI suggestions unless you enable it.
- Gitsigns and LuaSnip are enabled, but this config does not add custom hunk or
  snippet-jump mappings. A plugin's presence does not imply every common internet example is mapped.

To inspect a mapping in the running editor, use `:verbose nmap s`,
`:verbose nmap <leader>sh`, or `:verbose imap <C-h>`. The output includes where
the current mapping was defined. `:map` lists Normal/Visual/operator mappings;
`:imap` lists Insert mappings. `:help key-notation`
explains angle-bracket notation. Built-in defaults do not all appear in `:map`.

## Configuration files, data, and portability

| Location relative to `~/.config/nvim` | Edit this for |
| --- | --- |
| `init.lua` | Leaders and startup order |
| `lua/config/remap.lua` | Global editor shortcuts |
| `lua/config/set.lua` | Options, indentation, undo, and Treesitter activation/folding |
| `lua/config/lazy.lua` | Plugin imports, update-check behavior, manager setup |
| `lua/config/colorscheme.lua` | Automatic dark/light theme selection |
| `lua/config/lsp_tools.lua` | Which automatic language servers need which toolchains |
| `lua/plugins/*.lua` | Plugin declarations/settings and their feature mappings |
| `lua/plugins/themes/*.lua` | Theme declarations |
| `lua/setup/health.lua` | `:checkhealth setup` diagnostics |
| `after/ftplugin/markdown.lua` | Markdown-specific indentation |
| `lua/util/lazygit.lua` | Terminal launch, pager PATH, and editor handoff |
| `lazygit/config.yml`, `bin/delta-auto` | Lazygit UI settings and diff pager |
| `lazy-lock.json` | Plugin revisions to share between computers |

The config directory is the symlink into `computer_setup/nvim`; editing either
path edits the same repository files. For the actual runtime directories, use:

```vim
:lua print(vim.fn.stdpath("config"))
:lua print(vim.fn.stdpath("data"))
:lua print(vim.fn.stdpath("state"))
:lua print(vim.fn.stdpath("cache"))
```

Installed plugins normally live under `stdpath("data")/lazy`, and Mason tools
under `stdpath("data")/mason`. Undo is configured separately at `~/.vim/undodir`.
TODO/archives/summaries are `~/.todo.md`, `~/.todo-archive.md`, and
`~/.todo-summaries.md`. These task files are not in the config repository.

Neovim inherits fonts from its terminal. On the Ubuntu computer inspected during
setup, JetBrainsMono Nerd Font was already installed in
`/usr/share/fonts/truetype/JetBrainsMono/`; no second font install was needed.
Use `fc-match 'JetBrainsMono Nerd Font Mono'` to inspect font selection on Ubuntu.

Keep the existing `computer_setup/kitty` config; the original dotfiles Kitty
config was not copied. Neovim rechecks macOS appearance on focus; Ubuntu uses
the terminal's startup background. The delta wrapper follows macOS appearance
and uses dark diffs on Linux. Use `:set background=light/dark` to choose an editor
scheme manually (replace `light/dark` with one value).

### Optional: replace an older manual Neovim install on Ubuntu

If you want the README's local installation even though an existing Neovim works,
install the new copy first and verify it directly:

```sh
# Check the replacement after completing the Ubuntu Neovim download/link commands.
"$HOME/.local/bin/nvim" --version
```

For the previously inspected **manual executable** at `/usr/local/bin/nvim`,
which was not owned by an apt package, remove that old file only after the new
one works:

```sh
# Remove that old manual executable; this does not remove your config or plugin data.
sudo rm /usr/local/bin/nvim

# Make the local executable take priority and forget cached command paths.
export PATH="$HOME/.local/bin:$PATH"
hash -r
command -v nvim
nvim --version
```

For a different machine, inspect `type -a nvim` and its installation method
first; an apt-managed installation should be removed through apt. The local
install method does not require deleting another working installation.

## Troubleshooting

| Symptom | Check and next action |
| --- | --- |
| `nvim` launches an unexpected/old version | Run `type -a nvim`, `command -v nvim`, and `nvim --version`; check PATH priority and `hash -r`. |
| Initial plugin installation fails | `:Lazy`, `Enter` on the failing plugin, `:checkhealth lazy`; check Git/network and build output. `:Lazy install` retries missing plugins. |
| Plugin update appears to break editing | Restore a known working lockfile, then `:Lazy restore`, and restart. |
| A plugin is “Not Loaded” | Trigger its documented key/filetype/event; check its load reason in Lazy. This does not mean disabled. |
| `npm`/`node`/`go` not found or Mason server fails | `:checkhealth setup`, `:MasonLog`, shell versions; install prerequisites, restart from that shell, retry the package. |
| LSP installed but definition/hover missing | `:checkhealth vim.lsp`, `:LspLog`; check filetype, project root, server capabilities, and language build dependencies. |
| No Python formatting | Pyright supplies analysis, not formatting; no external Python formatter is configured. Add one to Conform if wanted. |
| Missing/incorrect formatting | `:ConformInfo`; install the named formatter or inspect its project config. Check `gofmt`/`rustfmt` on PATH. |
| Treesitter or Markdown decoration errors | `:checkhealth nvim-treesitter`, CLI/editor versions, `:TSInstall markdown markdown_inline`, then `:TSUpdate` when appropriate. |
| Telescope grep finds nothing | Check `rg --version`, `:pwd`, and project ignore rules. |
| Clipboard copy fails | `:checkhealth vim.provider`; desktop providers include `xclip` (X11) and `wl-clipboard` (Wayland). Headless/SSH sessions may need terminal clipboard support instead. |
| Icons are boxes | Select an installed Nerd Font in Kitty; Neovim does not set the font itself. |
| Lazygit fails to launch or display diffs | Check `lazygit --version`, `delta --version`, and executable permissions on `bin/delta-auto`. |
| A key differs from this guide | Inspect mode/window context, `:verbose nmap ...` / `:verbose imap ...`, and local plugin help. |
| `Ctrl-s` freezes input | A terminal may intercept it for flow control; `Ctrl-q` resumes that terminal. |
| Copilot errors after you enable it | Check Node/npm, `:Copilot setup`, and `:Copilot status`; leave disabled if unused. |
| TODO summary reports missing `claude` | Install/authenticate that optional CLI, or use TODO without AI summaries. |

## Further help

- Built-in tutorial: `:Tutor`; general help: `:help`, `:help quickref`.
- Editing concepts: `:help motion.txt`, `:help text-objects`, `:help registers`,
  `:help :range`, `:help :substitute`, `:help windows`, `:help default-mappings`.
- [Neovim user manual](https://neovim.io/doc/user/),
  [Lazy usage](https://lazy.folke.io/usage),
  [Lazy specs](https://lazy.folke.io/spec),
  [Mason commands and setup](https://github.com/mason-org/mason.nvim),
  [lazygit keybindings](https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md).

The configured keys and states above follow this repository. Plugin defaults
were checked against the locally installed versions; after updates, the UI's
local help is the best place to check changes to those defaults.
