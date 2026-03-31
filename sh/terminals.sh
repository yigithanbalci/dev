#!/usr/bin/env bash
#
# Terminal Emulators Installation
# Installs: WezTerm, Kitty, Ghostty, Alacritty

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Terminal Emulators..."

install_wezterm() {
  if is_installed wezterm; then return 0; fi
  if ! confirm_install "WezTerm"; then return 0; fi
  
  case "$OS" in
    macos)
      brew install --cask wezterm
      ;;
    ubuntu)
      curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
      echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
      sudo apt-get update
      sudo apt-get install -y wezterm
      ;;
    arch)
      pkg_install wezterm
      ;;
    *)
      log_error "Unsupported OS for WezTerm"
      return 1
      ;;
  esac
  
  log_success "WezTerm installed"
}

install_kitty() {
  if is_installed kitty; then return 0; fi
  if ! confirm_install "Kitty"; then return 0; fi
  
  case "$OS" in
    macos)
      brew install --cask kitty
      ;;
    ubuntu|arch)
      # Platform-agnostic installer
      curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
      
      # Create desktop shortcuts
      ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty || true
      cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/ || true
      
      # Update icon path
      sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop || true
      ;;
    *)
      log_error "Unsupported OS for Kitty"
      return 1
      ;;
  esac
  
  log_success "Kitty installed"
}

install_ghostty() {
  if is_installed ghostty; then return 0; fi
  if ! confirm_install "Ghostty"; then return 0; fi
  
  case "$OS" in
    macos)
      brew install --cask ghostty
      ;;
    ubuntu|arch)
      log_warning "Ghostty installation on Linux requires building from source"
      log_info "Visit: https://github.com/ghostty-org/ghostty"
      return 1
      ;;
    *)
      log_error "Unsupported OS for Ghostty"
      return 1
      ;;
  esac
  
  log_success "Ghostty installed"
}

install_alacritty() {
  if is_installed alacritty; then return 0; fi
  if ! confirm_install "Alacritty"; then return 0; fi
  
  case "$OS" in
    macos)
      brew install --cask alacritty
      ;;
    ubuntu)
      pkg_install alacritty
      ;;
    arch)
      pkg_install alacritty
      ;;
    *)
      log_error "Unsupported OS for Alacritty"
      return 1
      ;;
  esac
  
  log_success "Alacritty installed"
}

# Main installation
main() {
  local terminals=(
    "wezterm"
    "kitty"
    "ghostty"
    "alacritty"
  )
  
  for terminal in "${terminals[@]}"; do
    "install_$terminal" || log_warning "Failed to install $terminal"
  done
  
  log_success "Terminal emulators installation complete!"
}

main
