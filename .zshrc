autoload -Uz colors && colors
autoload -Uz compinit
compinit

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

bindkey -e

setopt PROMPT_SUBST
setopt AUTO_CD

git_branch() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    echo " %F{red}($branch)%f"
  fi
}

PROMPT='%F{cyan}%n@%m%f %~$(git_branch) %# '

alias ls='ls --color=auto'
alias ll='ls -lF --color=auto'
alias grep='grep -i'
alias man2html='man -Hfirefox'

zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:nvim:*' file-patterns '*(^*) *.*(*)'

if [[ "$(uname)" == "Darwin" ]]; then
  if [[ -d /opt/homebrew/bin ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi
fi

export PATH="$HOME/.local/bin:$PATH"

export SUDO_EDITOR="nvim"
