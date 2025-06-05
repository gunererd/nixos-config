#!/usr/bin/env bash

set -e  # Exit on any error

HOSTNAME="$1"
USERNAME="$2"

if [ -z "$HOSTNAME" ] || [ -z "$USERNAME" ]; then
    echo "Usage: $0 <hostname> <username>"
    exit 1
fi

DOTFILES_DIR="/home/$USERNAME/nixos-config/dotfiles"
CONFIG_DIR="/home/$USERNAME/.config"

echo "Linking dotfiles for $USERNAME on $HOSTNAME..."

# Create .config if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Function to link dotfiles
link_program() {
    local program="$1"
    local machine_path="$DOTFILES_DIR/$HOSTNAME/$program"
    local common_path="$DOTFILES_DIR/common/$program"
    
    # Use machine-specific if it exists, otherwise use common
    if [ -d "$machine_path" ]; then
        echo "Linking $program from $HOSTNAME directory"
        rm -rf "$CONFIG_DIR/$program"
        ln -sf "$machine_path" "$CONFIG_DIR/$program"
    elif [ -d "$common_path" ]; then
        echo "Linking $program from common directory"  
        rm -rf "$CONFIG_DIR/$program"
        ln -sf "$common_path" "$CONFIG_DIR/$program"
    fi
}

# Get unique list of all programs
declare -A programs
if [ -d "$DOTFILES_DIR/common" ]; then
    for dir in "$DOTFILES_DIR"/common/*; do
        if [ -d "$dir" ]; then
            program=$(basename "$dir")
            programs["$program"]=1
        fi
    done
fi

if [ -d "$DOTFILES_DIR/$HOSTNAME" ]; then
    for dir in "$DOTFILES_DIR/$HOSTNAME"/*; do
        if [ -d "$dir" ]; then
            program=$(basename "$dir")
            programs["$program"]=1
        fi
    done
fi

# Link all unique programs
for program in "${!programs[@]}"; do
    link_program "$program"
done

# Fix ownership
chown -R "$USERNAME:users" "/home/$USERNAME/.config/" 2>/dev/null || true

echo "Dotfiles linked successfully!"