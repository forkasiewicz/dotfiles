HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
zstyle :compinstall filename '/home/c/.zshrc'

setopt PROMPT_SUBST

git_branch() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    echo "%F{red}($branch)%f "
  fi
}

PROMPT='$(git_branch)%~ %# '

autoload -Uz colors && colors
alias ls='ls --color=auto'
alias ll='ls -lF --color=auto'
alias la='ls -A --color=auto'
alias grep='grep -i'
alias man2html='man -Hfirefox'

autoload -Uz compinit
compinit

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
