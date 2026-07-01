#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKIP=(".git" "install.sh")

log() { echo "[dotfiles] $*"; }

is_skipped() {
    local name="$1"
    for s in "${SKIP[@]}"; do
        [[ "$name" == "$s" ]] && return 0
    done
    return 1
}

link() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        log "replacing symlink: $dest"
        rm -f "$dest"
    elif [[ -e "$dest" ]]; then
        if [[ -d "$dest" ]]; then
            log "skipping real directory: $dest"
            return
        fi
        log "removing file: $dest"
        rm -f "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    log "linked $dest -> $src"
}

# .zshrc → ~/
if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
    link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
fi

# .config/*
if [[ -d "$DOTFILES_DIR/.config" ]]; then
    for item in "$DOTFILES_DIR/.config"/*; do
        [[ -e "$item" ]] || continue

        name="$(basename "$item")"

        if [[ -d "$item" ]]; then
            link "$item" "$HOME/.config/$name"
        else
            log "skipping non-directory config item: $item"
        fi
    done
fi

# root-level dotfiles
for item in "$DOTFILES_DIR"/.[!.]* "$DOTFILES_DIR"/*; do
    [[ -e "$item" ]] || continue

    name="$(basename "$item")"

    is_skipped "$name" && continue
    [[ "$name" == ".config" ]] && continue

    link "$item" "$HOME/$name"
done

log "done"
