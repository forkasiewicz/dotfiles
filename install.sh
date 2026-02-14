#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$HOME/dotfiles/.config"
TARGET="$HOME/.config"
TOML="$HOME/dotfiles/dotfiles.toml"

mkdir -p "$TARGET"

OS=""
case "$(uname)" in
    Linux*)  OS="linux";;
    Darwin*) OS="macos";;
    *)       echo "Unsupported OS: $(uname)"; exit 1;;
esac
echo "Detected OS: $OS"

OS_CONFIGS=()
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    if [[ "$line" =~ ^configs\ *= ]]; then
        arr="${line#*=}"
        arr="${arr#[}"
        arr="${arr%]}"
        arr="${arr//\"/}"
        IFS=',' read -ra items <<< "$arr"
        for item in "${items[@]}"; do
            item_trimmed="$(echo $item | xargs)"
            [[ -n "$item_trimmed" ]] && OS_CONFIGS+=("$item_trimmed")
        done
        break
    fi
done < <(grep -A 20 "\[$OS\]" "$TOML")

echo "OS-specific configs: ${OS_CONFIGS[*]}"

ALL_CONFIGS=()
for cfg in "$DOTFILES"/*; do
    ALL_CONFIGS+=("$(basename "$cfg")")
done

COMMON_CONFIGS=()
for cfg in "${ALL_CONFIGS[@]}"; do
    skip=0
    for os_cfg in "${OS_CONFIGS[@]}"; do
        [[ "$cfg" == "$os_cfg" ]] && skip=1 && break
    done
    [[ $skip -eq 0 ]] && COMMON_CONFIGS+=("$cfg")
done

echo "Common configs: ${COMMON_CONFIGS[*]}"

link_dir() {
    local src="$1"
    local dest="$2"
    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "Removing $dest"
        rm -rf "$dest"
    fi
    ln -s "$src" "$dest"
    echo "Linked $src -> $dest"
}

for cfg in "${COMMON_CONFIGS[@]}"; do
    link_dir "$DOTFILES/$cfg" "$TARGET/$cfg"
done

for cfg in "${OS_CONFIGS[@]}"; do
    link_dir "$DOTFILES/$cfg" "$TARGET/$cfg"
done

while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    if [[ "$line" =~ = ]]; then
        link_path=$(echo "$line" | cut -d'=' -f1 | xargs | tr -d '"')
        src_path=$(echo "$line" | cut -d'=' -f2 | xargs | tr -d '"')
        src_path="${src_path//\{\{OS\}\}/$OS}"
        full_src="$TARGET/$src_path"
        full_dest="$TARGET/$link_path"
        mkdir -p "$(dirname "$full_dest")"
        link_dir "$full_src" "$full_dest"
    fi
done < <(grep -A 100 "^\[symlinks\]" "$TOML")

echo "Dotfiles linking complete!"
