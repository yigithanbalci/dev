#!/usr/bin/env bash
#
# Shell Utilities Installation
# Installs: direnv, doppler, fastfetch, pass, etc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Shell Utilities..."

install_direnv() {
  if is_installed direnv; then return 0; fi
  if ! confirm_install "direnv (environment switcher)"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install direnv ;;
    ubuntu|arch) pkg_install direnv ;;
    *)
      # Platform-agnostic install
      curl -sfL https://direnv.net/install.sh | bash
      ;;
  esac
  
  log_success "direnv installed"
  log_info "Add direnv hook to your shell rc file. See: https://direnv.net/docs/hook.html"
}

install_doppler() {
  if is_installed doppler; then return 0; fi
  if ! confirm_install "Doppler (secrets manager)"; then return 0; fi
  
  case "$OS" in
    macos)
      brew install dopplerhq/cli/doppler
      ;;
    ubuntu)
      # Official install script
      curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add -
      echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list
      sudo apt-get update
      sudo apt-get install -y doppler
      ;;
    arch)
      # Install from AUR or use generic method
      if command_exists yay; then
        yay -S doppler-cli
      else
        log_warning "Doppler on Arch requires AUR helper or manual install"
        return 1
      fi
      ;;
    *)
      log_error "Unsupported OS for Doppler"
      return 1
      ;;
  esac
  
  log_success "Doppler installed"
}

install_fastfetch() {
  if is_installed fastfetch; then return 0; fi
  if ! confirm_install "fastfetch (system info)"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install fastfetch ;;
    ubuntu|arch) pkg_install fastfetch ;;
    *)
      log_error "Unsupported OS for fastfetch"
      return 1
      ;;
  esac
  
  log_success "fastfetch installed"
}

install_pass() {
  if is_installed pass; then return 0; fi
  if ! confirm_install "pass (password manager)"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install pass ;;
    ubuntu|arch) pkg_install pass ;;
    *)
      log_error "Unsupported OS for pass"
      return 1
      ;;
  esac
  
  log_success "pass installed"
}

install_neofetch() {
  if is_installed neofetch; then return 0; fi
  if ! confirm_install "neofetch (system info)"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install neofetch ;;
    ubuntu|arch) pkg_install neofetch ;;
    *)
      log_error "Unsupported OS for neofetch"
      return 1
      ;;
  esac
  
  log_success "neofetch installed"
}

install_thefuck() {
  if is_installed thefuck; then return 0; fi
  if ! confirm_install "thefuck (command corrector)"; then return 0; fi
  
  # thefuck requires Python
  if ! command_exists python3; then
    log_warning "thefuck requires Python 3"
    return 1
  fi
  
  case "$OS" in
    macos) pkg_install thefuck ;;
    ubuntu|arch) 
      pip3 install --user thefuck
      ;;
    *)
      pip3 install --user thefuck
      ;;
  esac
  
  log_success "thefuck installed"
}

# Main installation
main() {
  local utils=(
    "direnv"
    "doppler"
    "fastfetch"
    "pass"
    "neofetch"
    "thefuck"
  )
  
  for util in "${utils[@]}"; do
    "install_$util" || log_warning "Failed to install $util"
  done
  
  log_success "Shell utilities installation complete!"
}

main
