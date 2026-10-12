OS="$(uname)"

export PATH="$HOME/.local/bin:$PATH"
export SUDO_EDITOR="nvim"

alias man2html='man -Hfirefox'
alias clear='printf "\033[2J\033[3J\033[H"'

setopt SHARE_HISTORY
setopt PROMPT_SUBST
setopt AUTO_CD

bindkey -e

autoload -Uz colors && colors

HISTFILE="$HOME/.histfile"
HISTSIZE=10000
SAVEHIST=10000

git_branch() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    echo " %F{red}($branch)%f"
  fi
}

PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b%(!.#.$) '

zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:nvim:*' file-patterns '*(^*) *.*(*)'

autoload -Uz compinit
compinit

if [[ "$OS" == "Darwin" ]]; then
  # macos
  [[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"
  alias ls='ls -G'
  alias ll='ls -lFG'
elif [[ "$OS" == "Linux" ]]; then
  # linux
  alias open='xdg-open'
  alias ls='ls --color=auto'
  alias ll='ls -lF --color=auto'
fi
