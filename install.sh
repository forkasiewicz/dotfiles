#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$HOME/dotfiles/.config"
TARGET="$HOME/.config"
TOML="$HOME/dotfiles/dotfiles.toml"

mkdir -p "$TARGET"

# Detect OS
OS=""
case "$(uname)" in
    Linux*)     OS="linux";;
    Darwin*)    OS="macos";;
    *)          echo "Unsupported OS: $(uname)"; exit 1;;
esac

echo "Detected OS: $OS"

OS_CONFIGS=()
in_section=0
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        [[ "${BASH_REMATCH[1]}" == "$OS" ]] && in_section=1 || in_section=0
        continue
    fi

    if [[ $in_section -eq 1 ]]; then
        OS_CONFIGS+=("$line")
    fi
done < "$TOML"

echo "OS-specific configs: ${OS_CONFIGS[*]}"

COMMON_CONFIGS=()
for cfg in "$DOTFILES"/*; do
    cfg_name=$(basename "$cfg")
    skip=0
    for os_cfg in "${OS_CONFIGS[@]}"; do
        [[ "$cfg_name" == "$os_cfg" ]] && skip=1 && break
    done
    [[ $skip -eq 0 ]] && COMMON_CONFIGS+=("$cfg_name")
done

echo "Common configs: ${COMMON_CONFIGS[*]}"

link_dir() {
    local src="$1"
    local dest="$2"

    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "removing $dest"
        rm -rf "$dest"
    fi

    ln -s "$src" "$dest"
    echo "linking $src -> $dest"
}

for cfg in "${COMMON_CONFIGS[@]}"; do
    link_dir "$DOTFILES/$cfg" "$TARGET/$cfg"
done

for cfg in "${OS_CONFIGS[@]}"; do
    link_dir "$DOTFILES/$cfg" "$TARGET/$cfg"
done

echo "complete!"
