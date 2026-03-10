# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/c/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


## Enable color support for ls
autoload -U colors && colors

# Use GNU ls with --color (Linux) or BSD ls with -G (macOS)
if command -v gdircolors >/dev/null 2>&1; then
    # GNU coreutils
    eval "$(dircolors -b)"    # sets LS_COLORS automatically
    alias ls='ls --color=auto'
else
    # BSD/macOS
    alias ls='ls -G'
fi

# Optional: add flags for human-readable sizes and listing
alias ll='ls -lhF'    # -F appends / for dirs, * for executables, @ for symlinks
alias la='ls -lhaF'

# LS_COLORS example for directories, symlinks, executables
# Only needed if you want to override defaults
export LS_COLORS="di=34:ln=36:ex=32"  
# di=directories=blue, ln=symlinks=cyan, ex=executables=green
