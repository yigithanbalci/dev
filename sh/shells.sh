#!/usr/bin/env bash
#
# Shell Environments Installation
# Installs: Fish, Zsh with Oh My Zsh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Shell Environments..."

install_fish() {
  if is_installed fish; then return 0; fi
  if ! confirm_install "Fish Shell"; then return 0; fi
  
  case "$OS" in
    macos)
      pkg_install fish
      ;;
    ubuntu)
      sudo apt-add-repository -y ppa:fish-shell/release-3
      sudo apt-get update
      sudo apt-get install -y fish
      ;;
    arch)
      pkg_install fish
      ;;
    *)
      log_error "Unsupported OS for Fish"
      return 1
      ;;
  esac
  
  # Add fish to valid login shells if not already added
  if ! grep -q "$(which fish)" /etc/shells; then
    echo "$(which fish)" | sudo tee -a /etc/shells
  fi
  
  log_success "Fish shell installed"
  log_info "To set as default shell: chsh -s \$(which fish)"
}

install_zsh() {
  if is_installed zsh; then return 0; fi
  if ! confirm_install "Zsh"; then return 0; fi
  
  case "$OS" in
    macos)
      # Zsh comes pre-installed on modern macOS
      if ! is_installed zsh; then
        pkg_install zsh
      fi
      ;;
    ubuntu|arch)
      pkg_install zsh
      ;;
    *)
      log_error "Unsupported OS for Zsh"
      return 1
      ;;
  esac
  
  # Add zsh to valid login shells if not already added
  if ! grep -q "$(which zsh)" /etc/shells 2>/dev/null; then
    echo "$(which zsh)" | sudo tee -a /etc/shells
  fi
  
  log_success "Zsh installed"
  log_info "To set as default shell: chsh -s \$(which zsh)"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log_skip "Oh My Zsh is already installed"
    return 0
  fi
  
  if ! confirm_install "Oh My Zsh"; then return 0; fi
  
  # Ensure zsh is installed first
  if ! is_installed zsh; then
    log_info "Installing Zsh first..."
    install_zsh
  fi
  
  log_info "Installing Oh My Zsh (platform-agnostic)..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  
  log_success "Oh My Zsh installed"
}

install_starship() {
  if is_installed starship; then return 0; fi
  if ! confirm_install "Starship Prompt"; then return 0; fi
  
  log_info "Installing Starship (platform-agnostic)..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  
  log_success "Starship installed"
  log_info "Add 'eval \"\$(starship init bash)\"' to your .bashrc or equivalent for your shell"
}

# Main installation
main() {
  local shells=(
    "fish"
    "zsh"
    "oh_my_zsh"
    "starship"
  )
  
  for shell in "${shells[@]}"; do
    "install_$shell" || log_warning "Failed to install $shell"
  done
  
  log_success "Shell environments installation complete!"
}

main
