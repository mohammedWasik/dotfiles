#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[dotfiles]${NC} $1"; }
warn() { echo -e "${YELLOW}[dotfiles]${NC} $1"; }

mkdir -p "$CONFIG"

# Config dirs → ~/.config/<dir>
CONFIG_DIRS=(ghostty i3 polybar rofi dunst picom)
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES/$dir" ]; then
        ln -sfn "$DOTFILES/$dir" "$CONFIG/$dir"
        log "linked $dir → ~/.config/$dir"
    fi
done

# starship.toml → ~/.config/starship.toml
if [ -f "$DOTFILES/starship.toml" ]; then
    ln -sf "$DOTFILES/starship.toml" "$CONFIG/starship.toml"
    log "linked starship.toml → ~/.config/starship.toml"
fi

# home/ files → ~/.<file>
declare -A HOME_FILES=(
    ["zshrc"]=".zshrc"
    ["tmux.conf"]=".tmux.conf"
    ["gitconfig"]=".gitconfig"
    ["vimrc"]=".vimrc"
    ["Xresources"]=".Xresources"
    ["zshenv"]=".zshenv"
)
for src in "${!HOME_FILES[@]}"; do
    dest="$HOME/${HOME_FILES[$src]}"
    if [ -f "$DOTFILES/home/$src" ]; then
        [ -f "$dest" ] && warn "backing up existing $dest → $dest.bak" && cp "$dest" "$dest.bak"
        ln -sf "$DOTFILES/home/$src" "$dest"
        log "linked home/$src → $dest"
    fi
done

log "done. reload shell: source ~/.zshrc"
