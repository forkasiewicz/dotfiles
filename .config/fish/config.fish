if status is-interactive
# Commands to run in interactive sessions can go here
end

set -g fish_greeting

# if macos
if test (uname) = Darwin; and test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

bind super-backspace backward-kill-line
bind alt-backspace backward-kill-word

bind super-left beginning-of-line
bind super-right end-of-line

alias python python3
alias pip pip3
alias ls "ls -G"
alias ll "ls -lhG"
