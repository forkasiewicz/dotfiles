HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
zstyle :compinstall filename '/home/c/.zshrc'

autoload -Uz compinit
compinit

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

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
