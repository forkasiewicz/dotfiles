#!/bin/bash

set -e

OS_TYPE=""
case "$(uname)" in
    "Darwin")
        OS_TYPE="macos"
        ;;
    "Linux")
        OS_TYPE="linux"
        ;;
    *)
        OS_TYPE="unknown"
        ;;
esac

echo "detected $OS_TYPE"

IGNORED=("README" ".gitignore" ".git" "config" "install.sh" "install.py" ".geminiignore")

is_ignored() {
    local item="$1"
    for ignored in "${IGNORED[@]}"; do
        if [[ "$item" == "$ignored" ]]; then
            return 0
        fi
    done
    return 1
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$DOTFILES_DIR/config"

get_config_section() {
    local section="\[$1\]"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        return
    fi
    awk "/$section/{flag=1;next}/\[/{flag=0}flag" "$CONFIG_FILE" | sed '/^[[:space:]]*$/d'
}

LINUX_PATHS=($(get_config_section "linux"))
MACOS_PATHS=($(get_config_section "macos"))
IGNORED_PATHS=($(get_config_section "ignored"))

is_in_array() {
    local item="$1"
    shift
    local arr=("$@")
    for i in "${arr[@]}"; do
        if [[ "${item%/}" == "${i%/}" ]]; then
            return 0
        fi
    done
    return 1
}

link_item() {
    local src="$1"
    local dest="$2"
    local rel_path="$3"

    if is_in_array "$rel_path" "${IGNORED_PATHS[@]}"; then
        return
    fi

    if [[ "$OS_TYPE" == "linux" ]]; then
        if is_in_array "$rel_path" "${MACOS_PATHS[@]}"; then
            return
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        if is_in_array "$rel_path" "${LINUX_PATHS[@]}"; then
            return
        fi
    else
        if is_in_array "$rel_path" "${LINUX_PATHS[@]}" || is_in_array "$rel_path" "${MACOS_PATHS[@]}"; then
            return
        fi
    fi

    echo "linking $rel_path to $dest"

    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ -d "$dest" && ! -L "$dest" ]]; then
            echo "$dest is a directory. exiting" >&2
            exit 1
        fi
        
        rm -rf "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    
    ln -s "$src" "$dest"
}

for item in "$DOTFILES_DIR"/* "$DOTFILES_DIR"/.[!.]*; do
    [[ -e "$item" ]] || continue

    filename=$(basename "$item")
    
    if [[ "$filename" == ".config" ]] || is_ignored "$filename"; then
        continue
    fi
    
    link_item "$item" "$HOME/$filename" "$filename"
done

if [[ -d "$DOTFILES_DIR/.config" ]]; then
    for item in "$DOTFILES_DIR/.config"/*; do
        [[ -e "$item" ]] || continue
        
        dirname=$(basename "$item")
        rel_path=".config/$dirname"
        
        link_item "$item" "$HOME/.config/$dirname" "$rel_path"
    done
fi

echo "success"
