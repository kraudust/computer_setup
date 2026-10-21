# Neovim Configuration

Symlink this folder to `~/.config/nvim`. It includes the editor config, TODO
manager, lazygit settings, and keybinding notes. Copilot is disabled.

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

## Optional features

- **Copilot:** disabled. To enable AI suggestions, set `enabled = true` in
  `lua/plugins/copilot.lua`, restart Neovim, and run `:Copilot setup` to sign in.
  `Tab` accepts suggestions. [Copilot setup](https://github.com/github/copilot.vim)
- **TODO AI summaries:** only `Space ts` needs an installed, authenticated
  `claude` CLI. The rest of the TODO manager works without it.
- **Lazygit from your shell:** `Space lg` already uses the bundled settings.
  To use them outside Neovim too, add this to `~/.bashrc` (Ubuntu) or `~/.zshrc`
  (macOS):

```sh
# Use Neovim as the editor for Git and other command-line programs.
export EDITOR=nvim
export VISUAL=nvim

# Use the bundled lazygit pager and configuration.
export PATH="$HOME/.config/nvim/bin:$PATH"
export LG_CONFIG_FILE="$HOME/.config/nvim/lazygit/config.yml"
```

## Compatibility notes

- No Command-key mappings are configured here. Keep using your existing Kitty config.
- Neovim follows macOS appearance on focus; Ubuntu uses the terminal's startup
  background. Use `:set background=light` or `:set background=dark` to switch manually.
  The lazygit pager follows macOS appearance and uses dark diffs on Ubuntu.
- Undo history lives in `~/.vim/undodir`; TODO data lives in `~/.todo*.md`.
- Dotfiles' Kitty config, broad Linux installer, and worktree shortcuts requiring
  missing `wt`/`wt-rm` helpers were excluded.

## Keybindings

Leader key is `Space`.

### General

| Key                 | Mode          | Action                             |
| ------------------- | ------------- | ---------------------------------- |
| `jk`                | Insert        | Exit insert mode                   |
| `Space pv`          | Normal        | Open file explorer (Oil)           |
| `-`                 | Normal        | Open parent directory (Oil)        |
| `J` / `K`           | Visual        | Move selection down / up           |
| `Ctrl-d` / `Ctrl-u` | Normal        | Scroll down / up (centered)        |
| `Space y`           | Normal/Visual | Yank to system clipboard           |
| `Space Y`           | Normal        | Yank line to system clipboard      |
| `Space yf`          | Normal        | Copy current filepath              |
| `Space p`           | Visual        | Paste without overwriting register |
| `Space d`           | Normal/Visual | Delete to void register            |
| `Space f`           | Normal        | Format buffer                      |
| `Space u`           | Normal        | Toggle undo tree                   |

### Task Management (TODO)

A built-in task manager (`lua/plugins/todo.lua`, stored in `~/.todo.md`). Five
sections — **Today → This Week → Backlog → Blocked → Done** — and three states:
`[ ]` to-do, `[!]` blocked, `[x]` done. Completed tasks move to Done under the day's
ISO date; day-groups older than 30 days roll into `~/.todo-archive.md` automatically.
Group subtasks under a plain-bullet header; finishing a child files it under Done
tagged with the group name. `Space l` logs end-of-day progress on the task under
your cursor into Done (carrying its link), so unfinished work still shows in your
daily record. `Space ts` asks for a timeframe and writes a `claude`-generated prose
summary of your completed work (float or `~/.todo-summaries.md`).

| Key        | Mode   | Action                                |
| ---------- | ------ | ------------------------------------- |
| `Space td` | Normal | Toggle the TODO float                 |
| `Space ta` | Normal | Open the archive                      |
| `Space ts` | Normal | AI summary of completed work (claude) |
| `q`        | Float  | Close (saves first)                   |
| `Space d`  | Float  | Mark task done → Done (today)         |
| `Space b`  | Float  | Toggle blocked                        |
| `Space p`  | Float  | Promote (Backlog → This Week → Today) |
| `Space m`  | Float  | Log a meeting into Done               |
| `Space l`  | Float  | Log progress on the task under cursor into Done (links it back) |
| `Space a`  | Float  | Add a sibling task                    |
| `Space n`  | Float  | Add a note bullet                     |

Move tasks between sections with native vim (`dd` / `p`); delete with `dd`.

### File Navigation (Telescope)

| Key        | Mode   | Action                   |
| ---------- | ------ | ------------------------ |
| `Ctrl-e`   | Normal | Recent files             |
| `Space pf` | Normal | Find files               |
| `Space gf` | Normal | Find git files           |
| `Space pg` | Normal | Live grep                |
| `Space bf` | Normal | Browse open buffers      |
| `Ctrl-x`   | Picker | Open in horizontal split |
| `Ctrl-v`   | Picker | Open in vertical split   |

### LSP

| Key         | Mode   | Action                       |
| ----------- | ------ | ---------------------------- |
| `gd`        | Normal | Go to definition             |
| `K`         | Normal | Hover documentation          |
| `Space ca`  | Normal | Code action                  |
| `Space rr`  | Normal | Find references              |
| `Space rn`  | Normal | Rename symbol                |
| `Space dd`  | Normal | Open diagnostic float        |
| `Space dq`  | Normal | Send diagnostics to quickfix |
| `[d` / `]d` | Normal | Prev / next diagnostic       |
| `Ctrl-h`    | Insert | Signature help               |

### Completion (nvim-cmp)

| Key                 | Mode   | Action                      |
| ------------------- | ------ | --------------------------- |
| `Ctrl-n` / `Ctrl-p` | Insert | Next / prev completion item |
| `Ctrl-Space`        | Insert | Trigger completion          |
| `Ctrl-e`            | Insert | Abort completion            |
| `Enter`             | Insert | Confirm selection           |

### Git

| Key        | Mode   | Action                |
| ---------- | ------ | --------------------- |
| `Space gs` | Normal | Git status (Fugitive) |
| `Space gb` | Normal | Git blame             |
| `Space lg` | Normal | Open lazygit          |

### Flash (Motion)

| Key                   | Mode   | Action                     |
| --------------------- | ------ | -------------------------- |
| `Space s`             | Normal | Flash jump                 |
| `f` / `F` / `t` / `T` | Normal | Enhanced with flash labels |
| `/`                   | Normal | Search with flash labels   |

### Splits

| Key               | Mode   | Action               |
| ----------------- | ------ | -------------------- |
| `Space sv`        | Normal | Vertical split       |
| `Space sh`        | Normal | Horizontal split     |
| `Space sx`        | Normal | Close split          |
| `Space se`        | Normal | Equalize split sizes |
| `Ctrl-Up/Down`    | Normal | Resize vertically    |
| `Ctrl-Left/Right` | Normal | Resize horizontally  |

### Tabs

| Key                   | Mode   | Action           |
| --------------------- | ------ | ---------------- |
| `Shift-H` / `Shift-L` | Normal | Prev / next tab  |
| `Space bn`            | Normal | New tab          |
| `Space bc`            | Normal | Close tab        |
| `Space bo`            | Normal | Close other tabs |

## Plugin List

| Plugin                                                                | Purpose               |
| --------------------------------------------------------------------- | --------------------- |
| [lazy.nvim](https://github.com/folke/lazy.nvim)                       | Plugin manager        |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)            | LSP configuration     |
| [mason.nvim](https://github.com/williamboman/mason.nvim)              | LSP/tool installer    |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                       | Autocompletion        |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip)                        | Snippet engine        |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)    | Fuzzy finder          |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting   |
| [conform.nvim](https://github.com/stevearc/conform.nvim)              | Code formatting       |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint)                | Linting               |
| [copilot.vim](https://github.com/github/copilot.vim)                  | Optional AI suggestions (disabled) |
| [oil.nvim](https://github.com/stevearc/oil.nvim)                      | File explorer         |
| [flash.nvim](https://github.com/folke/flash.nvim)                     | Enhanced motions      |
| [vim-fugitive](https://github.com/tpope/vim-fugitive)                 | Git integration       |
| [flatten.nvim](https://github.com/willothy/flatten.nvim)              | Open terminal-spawned files in this session |
| [gitsigns.nvim](https://github.com/lewis6458/gitsigns.nvim)           | Git gutter signs      |
| [undotree](https://github.com/mbbill/undotree)                        | Undo history          |
| [which-key.nvim](https://github.com/folke/which-key.nvim)             | Keybinding hints      |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)          | Status line           |
| [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim)           | Colorscheme           |
| [everforest-nvim](https://github.com/neanias/everforest-nvim)         | Colorscheme (alt)     |

## Troubleshooting

- **Icons look broken**: select an installed Nerd Font in your terminal.
- **Plugins fail to install**: check network access and run `:Lazy restore` to
  reinstall the versions recorded in `lazy-lock.json`. `:Lazy sync` can update them.
- **Plugin Updates notice**: this lists newer available plugin versions, not
  failures. Review them in `:Lazy`; use `:Lazy update` when you want to update.
- **Treesitter fails**: check Neovim/tree-sitter CLI versions and the C compiler,
  then run `:checkhealth nvim-treesitter` and `:TSUpdate`.
- **Lazygit diffs fail**: check `delta --version` and that `bin/delta-auto` is executable.
- **Telescope grep fails**: check `rg --version`.
- **LSP fails**: start with `:checkhealth setup`, then inspect `:Mason`,
  `:MasonLog`, and `:checkhealth vim.lsp`. Missing `npm` affects `ts_ls`, `eslint`,
  and `pyright`; missing `go` affects `gopls`. Complete installation steps 1–2
  above, then restart Neovim to retry. Other installation errors remain visible.
- **Formatter missing**: inspect `:ConformInfo`; this config uses `oxfmt`, `stylua`,
  `gofmt`, `rustfmt`, and `clang-format`.
- **Copilot fails after enabling it**: verify Node.js/npm are on PATH, then run
  `:Copilot setup` and check `:Copilot status`. Leave it disabled if unused.
