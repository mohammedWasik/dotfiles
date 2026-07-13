# dotfiles

Personal dotfiles for an Arch/EndeavourOS + i3wm setup.

## Stack

| Tool | Role |
|------|------|
| i3 | Window manager |
| Polybar | Status bar |
| Rofi | App launcher |
| Dunst | Notifications |
| Picom | Compositor |
| Ghostty | Terminal |
| tmux | Terminal multiplexer |
| Starship | Shell prompt |
| Zsh + Oh My Zsh | Shell |

**Theme:** Gruvbox Material throughout.

## Structure

```
dotfiles/
├── ghostty/        → ~/.config/ghostty/
├── i3/             → ~/.config/i3/
├── polybar/        → ~/.config/polybar/
├── rofi/           → ~/.config/rofi/
├── dunst/          → ~/.config/dunst/
├── picom/          → ~/.config/picom/
├── starship.toml   → ~/.config/starship.toml
├── home/
│   ├── zshrc       → ~/.zshrc
│   ├── tmux.conf   → ~/.tmux.conf
│   ├── gitconfig   → ~/.gitconfig
│   ├── vimrc       → ~/.vimrc
│   ├── Xresources  → ~/.Xresources
│   └── zshenv      → ~/.zshenv
└── install.sh
```

## Fresh Install

### 1. Prerequisites

```bash
# Arch / EndeavourOS
sudo pacman -S i3 polybar rofi dunst picom tmux zsh xclip feh starship

# Ghostty — install from https://ghostty.org
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Bun
curl -fsSL https://bun.sh/install | bash
```

### 2. Clone & Install

```bash
git clone https://github.com/mohammedWasik/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script symlinks everything into place and backs up any existing files as `.bak`.

### 3. Reload

```bash
source ~/.zshrc
tmux source ~/.tmux.conf   # if tmux is running
```

Log out and back in (or restart i3) for the full setup to take effect.

## tmux

| Keybind | Action |
|---------|--------|
| `Alt + 0-9` | Jump to window (creates if missing) |
| `Alt + ←/→` | Cycle windows (wraps around) |
| `Alt + s` | Prefix key |
| `Prefix + h/j/k/l` | Navigate panes (vim-style) |
| `Prefix + r` | Reload tmux config |

## Updating dotfiles

Since files are symlinked, editing `~/.zshrc` (or any linked file) edits the dotfiles repo directly.

```bash
cd ~/dotfiles
git add -A
git commit -m "update: <what changed>"
git push
```

## Notes

- `.gitconfig` has a personal identity set — update `user.name` and `user.email` on new machines.
- Ghostty auto-attaches to an existing tmux session on launch or creates a new one.
- `mwasik5050@gmail.com` personal account; work identity set per-repo.
