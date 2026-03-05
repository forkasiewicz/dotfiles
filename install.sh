#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_SRC="$DOTFILES_DIR/.config"
CONFIG_DEST="$HOME/.config"
CONF_FILE="$DOTFILES_DIR/config"

OS_UNAME=$(uname -s)
case "$OS_UNAME" in
    Linux*)  OS="linux" ;;
    Darwin*) OS="macos" ;;
    *) echo "Error: Unknown OS: $OS_UNAME"; exit 1 ;;
esac

echo "Detected OS: $OS"

EXCLUDE_LIST=$(mktemp)

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
    fi

done < "$CONF_FILE"

echo "--- Syncing Directories ---"

mkdir -p "$CONFIG_DEST"

for src_dir in "$CONFIG_SRC"/*; do
    [ -d "$src_dir" ] || continue

    dirname=$(basename "$src_dir")

    if grep -Fxq "$dirname" "$EXCLUDE_LIST"; then
        echo "Skipping $dirname (Exclusive to other OS)"
        continue
    fi

    dest="$CONFIG_DEST/$dirname"

    if [ -e "$dest" ]; then
        rm -rf "$dest"
    fi

    echo "Copying: $dirname"
    cp -r "$src_dir" "$dest"
done

rm "$EXCLUDE_LIST"

echo "Done."
