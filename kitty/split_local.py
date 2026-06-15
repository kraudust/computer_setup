# Open a new split / tab in the active window's LOCAL working directory.
#
# Why this exists: kitty's built-in `launch --cwd=current` (and last_reported /
# oldest) CLONES an ssh-kitten session into the new window when the active
# window is ssh'd in -- so splits open on the remote, with a garbled bootstrap.
# There is NO config option to follow cwd locally without that clone; the kitty
# maintainer confirms it's by design (github discussion #6015).
#
# This kitten sidesteps it. It reads the window's local child cwd:
#   - local window -> the live shell's current dir (so cwd-following still works)
#   - ssh window   -> the LOCAL dir the ssh command was launched from
# and passes that to `launch` as an EXPLICIT path. Explicit paths never trigger
# the ssh clone, so the new window is always a plain local shell on the host.
#
# Wire-up in kitty.conf:
#   map ctrl+shift+p kitten split_local.py --location=vsplit
#   map ctrl+shift+o kitten split_local.py --location=hsplit
#   map ctrl+shift+t kitten split_local.py --type=tab

import os

from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    cwd = (window.cwd_of_child if window is not None else None) or os.path.expanduser('~')
    # Pass through the launch flags from the mapping (--location=... / --type=...)
    # and append our explicit, local cwd.
    passthrough = [a for a in args if a.startswith('--')]
    boss.launch(*passthrough, '--cwd=' + cwd)
