alias b='cd ..'

# Switches cd to cd and then ls automatically
function cd() { builtin cd "$@" && ls -larth; }

# ROS2 Aliases
alias sr2='source /opt/ros/humble/setup.bash'
alias cb='colcon build --symlink-install'
alias cbps='colcon build --symlink-install --packages-select '
alias ct='colcon test '
alias sws='. install/setup.bash' # source workspace

# Docker Aliases
alias dock='docker exec -it omniscience bash'

# Kitty aliases
alias ssh='kitty +kitten ssh'

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

