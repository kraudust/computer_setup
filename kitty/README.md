# Kitty Configuration

A keyboard-driven Kitty terminal configuration for macOS and Linux. It uses **splits and tabs** (no stack layout), manual color-theme switching, and a helper script for opening a local shell even when the current terminal is connected to a remote host over SSH.

## Files

| File | Purpose |
|---|---|
| `kitty.conf` | Main settings and custom keyboard shortcuts |
| `VSCode_Dark.conf` | Default dark theme |
| `day.conf` | Light theme |
| `gruvbox-dark-hard.conf` | Optional Gruvbox Dark Hard theme |
| `split_local.py` | Opens a new local shell in the current local working directory, including when the active pane is connected to a remote host over SSH |

## Installation

The repository is checked out at `~/git/computer_setup`, and this configuration lives in `~/git/computer_setup/kitty`.

If `~/.config/kitty` does not already exist, symlink the repository's `kitty` directory:

```sh
ln -s ~/git/computer_setup/kitty ~/.config/kitty
```

If `~/.config/kitty` already exists as a real directory, back it up or remove it before creating the directory symlink. For example, if it only contains an old `kitty.conf` symlink that you no longer need:

```sh
rm ~/.config/kitty/kitty.conf
rmdir ~/.config/kitty
ln -s ~/git/computer_setup/kitty ~/.config/kitty
```

Removing the old symlink does not delete the file it points to. Inspect the target first if you want to keep it.

With the directory symlink in place, new files added to the repository's `kitty` directory are available through `~/.config/kitty`.

The configured font is **JetBrainsMono Nerd Font Mono**, size **11**. Install that font on each machine for the intended appearance.

Reload the configuration with `Ctrl+Shift+F5`.

## Keyboard shortcut conventions

The custom workflow primarily uses **Ctrl+Shift** on both Linux and macOS. The tables below distinguish:

- **Custom mapping:** explicitly assigned in this repository's `kitty.conf`.
- **Kitty default:** a built-in shortcut that remains active unless this configuration assigns that same key combination to another action.
- **Overridden default:** a built-in shortcut replaced by a custom mapping. The original default action will no longer run from that key combination.

Kitty's defaults can vary somewhat by version and platform. This README lists the relevant standard defaults; use Kitty's built-in shortcut help or command palette to inspect the running installation.

## Custom keybindings

### Splits and pane navigation

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+P` | Open a vertical split (panes side by side) using `split_local.py` |
| `Ctrl+Shift+O` | Open a horizontal split (one pane above the other) using `split_local.py` |
| `Ctrl+Shift+T` | Open a new tab using `split_local.py` |
| `Ctrl+Shift+H` | Focus the pane to the left |
| `Ctrl+Shift+J` | Focus the pane below |
| `Ctrl+Shift+K` | Focus the pane above |
| `Ctrl+Shift+L` | Focus the pane to the right |
| `Ctrl+Shift+Alt+H` | Make the active pane narrower by 5 Kitty resize units |
| `Ctrl+Shift+Alt+L` | Make the active pane wider by 5 Kitty resize units |
| `Ctrl+Shift+Alt+K` | Make the active pane shorter by 5 Kitty resize units |
| `Ctrl+Shift+Alt+J` | Make the active pane taller by 5 Kitty resize units |
| `Ctrl+Shift+W` | Close the active pane/window |

Resize units are Kitty's pane sizing units, not pixels. Directional pane navigation is intended for the splits layout.

### Tabs

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+]` | Go to the next tab |
| `Ctrl+Shift+[` | Go to the previous tab |
| `Ctrl+Shift+Alt+]` | Move the current tab forward in the tab bar |
| `Ctrl+Shift+Alt+[` | Move the current tab backward in the tab bar |
| `Ctrl+Shift+Alt+1` through `Ctrl+Shift+Alt+9` | Go directly to tab 1 through tab 9 |
| `Ctrl+Shift+R` | Rename the current tab |

A tab can contain multiple panes. Pane navigation affects windows within the current tab; tab navigation changes which tab is active.

### Manual theme switching

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+1` | Switch to VS Code Dark |
| `Ctrl+Shift+2` | Switch to the light theme (`day.conf`) |
| `Ctrl+Shift+3` | Switch to Gruvbox Dark Hard (`gruvbox-dark-hard.conf`) |

VS Code Dark is loaded at startup. Theme switching is manual; the configuration does not automatically follow the operating system's light/dark appearance. Kitty's `set_colors` action changes colors for the active Kitty window, so apply the theme to each window that should use it.

## Kitty defaults that remain useful

These are built-in Kitty shortcuts, not custom mappings added by this repository. The key combinations listed here are the standard Ctrl+Shift defaults, unless noted otherwise.

| Shortcut | Default action |
|---|---|
| `Ctrl+Shift+F1` | Show Kitty keyboard-shortcut help |
| `Ctrl+Shift+F2` | Open/edit Kitty's configuration |
| `Ctrl+Shift+F3` | Open Kitty's command palette |
| `Ctrl+Shift+F5` | Reload Kitty configuration |
| `Ctrl+Shift+F6` | Show/debug the current configuration |
| `Ctrl+Shift+C` | Copy selection to the clipboard |
| `Ctrl+Shift+V` | Paste from the clipboard |
| `Ctrl+Shift+Enter` | Open a new Kitty pane/window |
| `Ctrl+Shift+N` | Open a new OS window |
| `Ctrl+Shift+B` | Move the active pane backward in Kitty's window order (swap it with the previous pane) |
| `Ctrl+Shift+F` | Move the active pane forward in Kitty's window order (swap it with the next pane) |
| `Ctrl+Shift+`` | Move the active pane to the top of Kitty's window order |
| `Ctrl+Shift+4` through `Ctrl+Shift+9` | Focus pane/window 4 through 9, respectively |
| `Ctrl+Shift+Alt+T` | Rename the current tab (Kitty's default; this config also adds `Ctrl+Shift+R`) |

The default pane-number shortcuts `Ctrl+Shift+1`, `Ctrl+Shift+2`, and `Ctrl+Shift+3` are overridden by the theme shortcuts in this configuration. Use `Ctrl+Shift+Alt+1` through `Ctrl+Shift+Alt+9` for direct tab selection instead.

## Overridden Kitty defaults

The following custom mappings replace built-in Kitty actions on the same key combinations:

| Shortcut | Kitty default action | Action in this configuration |
|---|---|---|
| `Ctrl+Shift+P` | Starts Kitty's multi-key hints shortcuts (for example, selecting a path, line, or URL, depending on the next key) | Opens a vertical split via `split_local.py` |
| `Ctrl+Shift+O` | Passes the current selection to a program / selection-handling action | Opens a horizontal split via `split_local.py` |
| `Ctrl+Shift+T` | Opens a new tab | Opens a new tab via `split_local.py`, to preserve the intended local-shell behavior |
| `Ctrl+Shift+H` | Shows scrollback | Focuses the pane to the left |
| `Ctrl+Shift+J` | Scrolls down one line | Focuses the pane below |
| `Ctrl+Shift+K` | Scrolls up one line | Focuses the pane above |
| `Ctrl+Shift+L` | Cycles to the next layout | Focuses the pane to the right |
| `Ctrl+Shift+[` | Focuses the previous pane/window in the current tab | Goes to the previous tab |
| `Ctrl+Shift+]` | Focuses the next pane/window in the current tab | Goes to the next tab |
| `Ctrl+Shift+1` | Focuses pane/window 1 | Switches to VS Code Dark |
| `Ctrl+Shift+2` | Focuses pane/window 2 | Switches to the light theme |
| `Ctrl+Shift+3` | Focuses pane/window 3 | Switches to Gruvbox Dark Hard |
| `Ctrl+Shift+R` | Starts interactive pane resizing | Renames the current tab |

`Ctrl+Shift+W` is explicitly mapped to `close_window`, which is also Kitty's standard default action for closing the active pane/window, so its behavior is unchanged.

**Important:** `Ctrl+Shift+F` is no longer mapped in this configuration. The old custom stack-layout toggle has been removed, and Kitty's default action—moving the active pane forward in the window order—remains available. This configuration enables only the `splits` layout.

## Local shells from SSH sessions

The custom split and tab shortcuts use `split_local.py`:

- `Ctrl+Shift+P` — vertical split
- `Ctrl+Shift+O` — horizontal split
- `Ctrl+Shift+T` — new tab

When the active terminal is local, the new terminal starts in the current local working directory. When the active terminal is connected to a remote host over SSH, the script opens a **new local shell** using the local directory associated with the Kitty window, rather than cloning the remote SSH session.

This is intentional: use these mapped shortcuts when you want a new local terminal from an SSH terminal.

## Layout and appearance

- **Layout:** `splits` only; there is no stack-layout toggle.
- **Font:** JetBrainsMono Nerd Font Mono, 11.
- **Pane borders:** Minimal borders; blue active-pane border; dimmed inactive-pane text.
- **Window margins/padding:** Zero.
- **Cursor:** Cursor trail enabled; blinking disabled.
- **Scrollback:** Unlimited (`scrollback_lines -1`).
- **Shell integration:** Enabled.
- **Copy behavior:** Selecting text does not automatically copy it.
- **Whitespace:** Smart stripping of trailing spaces when copying.
- **URLs:** Detection enabled; opened with the system's default handler.
- **Tabs:** Powerline tab bar, index/title labels, and a dot indicator for a bell in an unfocused tab.
- **Audio bell:** Disabled; the tab indicator is used instead.
- **Window closing:** Confirmation enabled when closing a Kitty OS window.
- **Background:** No transparency setting is configured.

## Remote control

The configuration enables socket-only remote control:

```conf
allow_remote_control socket-only
listen_on unix:/tmp/kitty-{kitty_pid}
```

Kitty's remote-control interface allows trusted local programs to send commands to a running Kitty instance, including querying or managing windows. The socket path includes the Kitty process ID, so integrations may need to identify the correct socket.

Keep access to the socket limited to trusted local processes. This setting can support integrations and automation; it is not required for ordinary shell use.

## macOS Option key

The configuration includes:

```conf
macos_option_as_alt yes
```

This makes the macOS Option key act as Alt/Meta for terminal applications, which can make shell and editor shortcuts more consistent with Linux. It can also affect Option-based special characters. Adjust this setting if you rely on Option to type those characters.

## Troubleshooting

### A theme or script cannot be found

Confirm that the repository's `kitty` directory is linked to `~/.config/kitty` and that the expected files exist there.

### A new split opens on the remote host instead of locally

Confirm the split shortcut uses `kitten split_local.py ...` and that `split_local.py` is in the linked config directory.

### A remote-control integration cannot connect

Confirm Kitty is running with the socket settings above and that the integration supports Kitty's socket-based remote-control interface. The socket path is unique to each Kitty process.

### The font looks different

Install JetBrainsMono Nerd Font Mono on the machine, then restart Kitty or reload its configuration.

## References

- [Kitty documentation](https://sw.kovidgoyal.net/kitty/)
- [Kitty configuration reference](https://sw.kovidgoyal.net/kitty/conf/)
- [Kitty keyboard shortcuts and actions](https://sw.kovidgoyal.net/kitty/actions/)
- [Kitty remote control](https://sw.kovidgoyal.net/kitty/remote-control/)
