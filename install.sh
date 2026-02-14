#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_SRC="$DOTFILES_DIR/.config"
CONFIG_DEST="$HOME/.config"
CONF_FILE="$DOTFILES_DIR/config"

OS_UNAME=$(uname -s)
case "$OS_UNAME" in
    Linux*)     OS="linux" ;;
    Darwin*)    OS="macos" ;;
    *)          echo "Error: Unknown OS: $OS_UNAME"; exit 1 ;;
esac
echo "Detected OS: $OS"

EXCLUDE_LIST=$(mktemp)
SYMLINKS_LIST=$(mktemp)

if [ "$OS" == "linux" ]; then
    IGNORE_SECTION="macos"
else
    IGNORE_SECTION="linux"
fi

current_section=""

while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    [[ -z "$line" || "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH[1]}"
        continue
    fi

    if [ "$current_section" == "$IGNORE_SECTION" ]; then
        echo "$line" >> "$EXCLUDE_LIST"
    
    elif [ "$current_section" == "symlinks" ]; then
        echo "$line" >> "$SYMLINKS_LIST"
    fi

done < "$CONF_FILE"

echo "--- Syncing Directories ---"

for src_dir in "$CONFIG_SRC"/*; do
    [ -d "$src_dir" ] || continue
    
    dirname=$(basename "$src_dir")
    
    if grep -Fxq "$dirname" "$EXCLUDE_LIST"; then
        echo "Skipping $dirname (Exclusive to other OS)"
        continue
    fi

    dest="$CONFIG_DEST/$dirname"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        rm -rf "$dest"
    fi

    echo "Linking: $dirname -> $src_dir"
    ln -s "$src_dir" "$dest"
done

echo "--- Syncing Custom Files ---"

while IFS= read -r line; do
    clean_line=$(echo "$line" | tr -d '"')
    link_path=$(echo "$clean_line" | awk -F ' = ' '{print $1}')
    target_pattern=$(echo "$clean_line" | awk -F ' = ' '{print $2}')

    target_path=${target_pattern//\{\{OS\}\}/$OS}

    full_link="$CONFIG_DEST/$link_path"
    full_target="$CONFIG_DEST/$target_path"

    link_dir=$(dirname "$full_link")
    
    link_base_dir=$(dirname "$link_path")
    target_base_dir=$(dirname "$target_path")

    if [ "$link_base_dir" == "$target_base_dir" ]; then
        final_target=$(basename "$target_path")
    else
        final_target="$full_target"
    fi

    echo "Symlinking file: $link_path -> $final_target"
    
    mkdir -p "$(dirname "$full_link")"
    rm -f "$full_link"
    ln -s "$final_target" "$full_link"

done < "$SYMLINKS_LIST"

rm "$EXCLUDE_LIST" "$SYMLINKS_LIST"
echo "Done."
