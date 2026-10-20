export PATH="/opt/homebrew/bin:$PATH"

# Better reverse search with fuzzy finding, install with `brew install fzf`
source <(fzf --zsh)

# ============================================================
# Prompt: colored directory and Git branch (Ubuntu-style)
# ============================================================

setopt PROMPT_SUBST

git_branch_prompt() {
    local branch
    branch=$(git branch --show-current 2>/dev/null) || return
    [[ -n "$branch" ]] && printf '[%s]' "$branch"
}

if [[ -n "$SSH_CLIENT" || -n "$SSH_CONNECTION" ]]; then
    PROMPT='%F{yellow}[%n]%f%F{blue}$(git_branch_prompt)%f%F{green}%1~ $ %f'
else
    PROMPT='%F{blue}$(git_branch_prompt)%f%F{green}%1~ $ %f'
fi

# ============================================================
# Colored command output and directory listing aliases
# ============================================================

export CLICOLOR=1
export LSCOLORS=ExGxFxdaCxDaDahbadacec

alias ls='ls -G'
alias ll='ls -laF'
alias la='ls -A'
alias l='ls -CF'

# ============================================================
# Useful cross-platform aliases
# ============================================================

alias b='cd ..'
alias ssh='kitty +kitten ssh'

# Change directory and automatically list contents
function cd() {
    builtin cd "$@" && ls -larth
}
