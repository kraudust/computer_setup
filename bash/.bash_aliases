alias b='cd ..'

# Replace Bash's cd builtin with a wrapper that lists the destination after a
# successful directory change. Use `builtin cd` inside to avoid recursion.
cd() { builtin cd "$@" && ls -larth; }

# Format C/C++ files with the newest clang-format bundled by VS Code's C/C++
# extension. The helper reports an error when that optional extension is absent.
clang_format_dir() {
    if [[ $# -ne 1 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
        echo "Usage: ${FUNCNAME[0]} TARGET_DIR"
        echo "Recursively apply clang-format formatting to all C++ files in a target directory."
        return 0
    elif [[ ! -d $1 ]]; then
        echo "ERROR: '$1' not a valid directory" >&2
        return 1
    fi

    local target_dir=$1
    local format_cmd

    format_cmd=$(
        find "$HOME/.vscode/extensions" \
            -path '*/ms-vscode.cpptools-*/LLVM/bin/clang-format' \
            -type f -perm -u+x 2>/dev/null \
        | sort -V \
        | tail -1
    )

    if [[ -x "$format_cmd" ]]; then
        (
            builtin cd "$target_dir" || exit 1
            find . -type f \( \
                -name '*.cpp' -o \
                -name '*.hpp' -o \
                -name '*.h' \
            \) \
            -not -path './build/*' \
            -not -path './install/*' \
            -not -path './log/*' \
            -exec "$format_cmd" -i --style=file {} +
        )
    else
        echo "ERROR: No VS Code clang-format found" >&2
        return 1
    fi
}

# ROS2 Aliases
alias sr2='source /opt/ros/humble/setup.bash'
alias cb='colcon build --symlink-install'
alias cbps='colcon build --symlink-install --packages-select '
alias ct='colcon test '
alias sws='. install/setup.bash' # source workspace

# Docker Aliases
alias dock='docker exec -it omniscience bash'

# Use Kitty's SSH integration only when this shell is running inside Kitty.
if [[ -n "${KITTY_WINDOW_ID:-}" ]] && command -v kitty >/dev/null 2>&1; then
    alias ssh='kitty +kitten ssh'
fi

# Vector Aliases
alias sknd='ssh root@10.41.1.1'
alias aind='ssh -p 2222 root@10.41.1.1'

# S Drive
# alias mnts='sudo mount -t cifs //192.168.10.7/SDrive ~/Documents/SDrive -o username="dustan.kraus1",domain=OKSI-HQ.oksi.ai,iocharset=utf8'
# alias mnts='sudo mount -t cifs //192.168.10.7/SDrive ~/Documents/SDrive -o username="dustan.kraus1",domain=OKSI-HQ.oksi.ai,iocharset=utf8,uid=$(id -u),gid=$(id -g),file_mode=0660,dir_mode=0770'
# alias mnts='sudo mount -t cifs //10.10.60.3/SDrive ~/Documents/SDrive -o username=dustan.kraus1,domain=OKSI-HQ,iocharset=utf8,vers=3.0,sec=ntlmssp,uid=$(id -u),gid=$(id -g),file_mode=0664,dir_mode=0775'
alias mnts='sudo mount -t cifs //SDrive.oksi.ai/SDrive ~/Documents/SDrive -o username=dustan.kraus1,domain=OKSI-HQ,iocharset=utf8,vers=3.0,sec=ntlmssp'

# Check storage
alias mystorage="df -h | grep -E '/$|/media/dustan-kraus/dustan_linux_ssd'"

# SSH to jetson
# alias jetson="ssh jetson@192.168.55.1"
# alias jetson="ssh jetson@192.168.89.200"
alias jetson="ssh jetson@192.168.55.2" # ethernet
alias jetson01="ssh dustan@10.10.60.60"
alias jetson04="ssh dustan@10.10.60.75"

# Do the old school more detailed docker image ls
alias di='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"'

