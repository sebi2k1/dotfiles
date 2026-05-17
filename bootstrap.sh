#!/bin/bash
set -e

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# --- zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

THEMES_DIR="${ZSH:-$HOME/.oh-my-zsh}/custom/themes"
if [ ! -f "$THEMES_DIR/dracula.zsh-theme" ]; then
  TMP=$(mktemp -d)
  git clone --depth=1 https://github.com/dracula/zsh.git "$TMP"
  cp "$TMP/dracula.zsh-theme" "$THEMES_DIR/"
  cp -r "$TMP/lib" "$THEMES_DIR/"
  rm -rf "$TMP"
fi

ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/zsh/zprofile" "$HOME/.zprofile"

# --- tmux ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

ln -sf "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/tmux"
ln -sf "$DOTFILES/tmux/network-status.sh" "$HOME/.config/tmux/network-status.sh"

# --- nvim ---
mkdir -p "$HOME/.config"
NVIM_CONF="$HOME/.config/nvim"
if [ "$DOTFILES" != "$NVIM_CONF" ]; then
  [ -d "$NVIM_CONF" ] && mv "$NVIM_CONF" "$NVIM_CONF.bak"
  ln -sf "$DOTFILES" "$NVIM_CONF"
fi

echo "Done. Reload your shell and run tmux, then prefix + I to install tmux plugins."
