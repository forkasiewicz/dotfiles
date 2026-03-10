#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$REPO_DIR/config"
CURRENT_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

declare -A linux_set
declare -A macos_set
declare -A all_set
current_section=""

while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH[1]}"
        continue
    fi
    all_set["$line"]=1
    case "$current_section" in
        linux) linux_set["$line"]=1 ;;
        macos) macos_set["$line"]=1 ;;
    esac
done < "$CONFIG_FILE"

symlink_item() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" || -e "$dst" ]]; then
        rm -rf "$dst"
    fi
    ln -s "$src" "$dst"
    echo "linked $dst"
}

if [[ -d "$HOME/.config" ]]; then
    find "$HOME/.config" -type l -exec rm {} +
fi

shopt -s dotglob

for item in "$REPO_DIR"/*; do
    name="$(basename "$item")"
    [[ "$name" == ".git" || "$name" == ".gitignore" || "$name" == ".config" || "$name" == "config" || "$name" == "install.sh" ]] && continue

    if [[ -n "${all_set[$name]:-}" ]]; then
        case "$CURRENT_OS" in
            linux) [[ -n "${linux_set[$name]:-}" ]] && symlink_item "$item" "$HOME/$name" ;;
            macos) [[ -n "${macos_set[$name]:-}" ]] && symlink_item "$item" "$HOME/$name" ;;
        esac
    else
        symlink_item "$item" "$HOME/$name"
    fi
done

for dir in "$REPO_DIR/.config"/*; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"
    rel_path=".config/$name"

    if [[ -n "${all_set[$rel_path]:-}" ]]; then
        case "$CURRENT_OS" in
            linux) [[ -n "${linux_set[$rel_path]:-}" ]] && symlink_item "$dir" "$HOME/.config/$name" ;;
            macos) [[ -n "${macos_set[$rel_path]:-}" ]] && symlink_item "$dir" "$HOME/.config/$name" ;;
        esac
    else
        symlink_item "$dir" "$HOME/.config/$name"
    fi
done

shopt -u dotglob
