#!/usr/bin/env bash
#
# Text Editors Installation
# Installs: Neovim, Emacs, Zed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Text Editors..."

install_neovim() {
  if is_installed nvim; then return 0; fi
  if ! confirm_install "Neovim"; then return 0; fi
  
  case "$OS" in
    macos)
      pkg_install neovim
      # Clipboard support
      pkg_install pbcopy || true
      ;;
    ubuntu)
      # Install latest stable from PPA
      sudo add-apt-repository -y ppa:neovim-ppa/stable
      sudo apt-get update
      sudo apt-get install -y neovim
      
      # Clipboard support
      sudo apt-get install -y xclip xsel wl-clipboard || true
      
      # Development dependencies if user wants to build plugins
      sudo apt-get install -y cmake gettext lua5.1 liblua5.1-0-dev || true
      ;;
    arch)
      pkg_install neovim
      # Clipboard support for Wayland/X11
      pkg_install wl-clipboard xclip xsel || true
      ;;
    *)
      log_error "Unsupported OS for Neovim"
      return 1
      ;;
  esac
  
  log_success "Neovim installed"
}

install_emacs() {
  if is_installed emacs; then return 0; fi
  if ! confirm_install "Emacs"; then return 0; fi
  
  case "$OS" in
    macos) 
      pkg_install emacs
      ;;
    ubuntu) 
      pkg_install emacs
      ;;
    arch) 
      pkg_install emacs
      ;;
    *)
      log_error "Unsupported OS for Emacs"
      return 1
      ;;
  esac
  
  log_success "Emacs installed"
}

install_zed() {
  if is_installed zed; then return 0; fi
  if ! confirm_install "Zed"; then return 0; fi
  
  case "$OS" in
    macos)
      # Install via Homebrew cask
      brew install --cask zed
      ;;
    ubuntu|arch)
      # Zed has a curl-based installer for Linux
      curl -f https://zed.dev/install.sh | sh || {
        log_warning "Official installer failed. Zed may not be available for your system yet."
        return 1
      }
      ;;
    *)
      log_error "Unsupported OS for Zed"
      return 1
      ;;
  esac
  
  log_success "Zed installed"
}

install_helix() {
  if is_installed hx; then return 0; fi
  if ! confirm_install "Helix"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install helix ;;
    ubuntu|arch) pkg_install helix ;;
    *)
      log_error "Unsupported OS for Helix"
      return 1
      ;;
  esac
  
  log_success "Helix installed"
}

# Main installation
main() {
  local editors=(
    "neovim"
    "emacs"
    "zed"
  )
  
  for editor in "${editors[@]}"; do
    "install_$editor" || log_warning "Failed to install $editor"
  done
  
  log_success "Text editors installation complete!"
}

main
