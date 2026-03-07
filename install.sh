#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$REPO_DIR/config"
SRC_CONFIG_DIR="$REPO_DIR/.config"
DEST_CONFIG_DIR="$HOME/.config"

mkdir -p "$DEST_CONFIG_DIR"

case "$(uname -s)" in
    Linux) CURRENT_OS="linux" ;;
    Darwin) CURRENT_OS="macos" ;;
    *)
        echo "Unsupported OS: $(uname -s)"
        exit 1
        ;;
esac

declare -A linux_set
declare -A macos_set
declare -A restricted_set

current_section=""

while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    [[ -z "$line" ]] && continue

    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH[1]}"
        continue
    fi

    case "$current_section" in
        linux)
            linux_set["$line"]=1
            restricted_set["$line"]=1
            ;;
        macos)
            macos_set["$line"]=1
            restricted_set["$line"]=1
            ;;
    esac
done < "$CONFIG_FILE"

for dir in "$SRC_CONFIG_DIR"/*; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"

    should_link=false

    if [[ -n "${restricted_set[$name]:-}" ]]; then
        if [[ "$CURRENT_OS" == "linux" && -n "${linux_set[$name]:-}" ]]; then
            should_link=true
        elif [[ "$CURRENT_OS" == "macos" && -n "${macos_set[$name]:-}" ]]; then
            should_link=true
        fi
    else
        should_link=true
    fi

    [[ "$should_link" == true ]] || continue

    src="$dir"
    dst="$DEST_CONFIG_DIR/$name"

    if [[ -L "$dst" ]]; then
        current_target="$(readlink "$dst")"
        if [[ "$current_target" == "$src" ]]; then
            continue
        else
            rm "$dst"
        fi
    elif [[ -e "$dst" ]]; then
        rm -rf "$dst"
    fi

    ln -s "$src" "$dst"
    echo "linked $name"
done
