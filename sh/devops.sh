#!/usr/bin/env bash
#
# DevOps Tools Installation
# Installs: Docker, Docker Compose, Kubernetes tools, Colima

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing DevOps Tools..."

install_docker() {
  if is_installed docker; then return 0; fi
  if ! confirm_install "Docker"; then return 0; fi
  
  case "$OS" in
    macos)
      # On macOS, use Docker Desktop or Colima
      log_info "Installing Docker via Homebrew..."
      pkg_install docker
      log_info "Note: Consider installing Colima for a lightweight Docker runtime"
      ;;
    ubuntu)
      # Official Docker installation for Ubuntu
      log_info "Installing Docker from official repository..."
      
      # Install prerequisites
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg
      
      # Add Docker's official GPG key
      sudo install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg
      
      # Add the repository
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      
      # Install Docker Engine
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      
      # Add user to docker group
      sudo groupadd docker 2>/dev/null || true
      sudo usermod -aG docker $USER
      
      log_success "Docker installed. Log out and back in for group changes to take effect."
      ;;
    arch)
      pkg_install docker docker-compose
      
      # Enable and start Docker service
      sudo systemctl enable --now docker
      
      # Add user to docker group
      sudo groupadd docker 2>/dev/null || true
      sudo usermod -aG docker $USER
      
      log_success "Docker installed. Log out and back in for group changes to take effect."
      ;;
    *)
      log_error "Unsupported OS for Docker"
      return 1
      ;;
  esac
}

install_docker_compose() {
  if is_installed docker-compose || docker compose version >/dev/null 2>&1; then
    log_skip "Docker Compose is already installed"
    return 0
  fi
  
  if ! confirm_install "Docker Compose"; then return 0; fi
  
  case "$OS" in
    macos)
      # Usually comes with Docker Desktop
      log_info "Docker Compose is typically included with Docker Desktop on macOS"
      ;;
    ubuntu|arch)
      # Install Docker Compose v2 as a plugin (included in docker-ce-cli package)
      if ! docker compose version >/dev/null 2>&1; then
        log_info "Installing Docker Compose plugin..."
        sudo apt-get install -y docker-compose-plugin 2>/dev/null || \
        pkg_install docker-compose
      fi
      ;;
    *)
      return 1
      ;;
  esac
  
  log_success "Docker Compose installed"
}

install_colima() {
  if is_installed colima; then return 0; fi
  if ! confirm_install "Colima (lightweight Docker runtime)"; then return 0; fi
  
  case "$OS" in
    macos)
      pkg_install colima
      log_info "Start Colima with: colima start"
      ;;
    ubuntu|arch)
      # Colima works on Linux too
      pkg_install colima || {
        log_warning "Colima not available via package manager, using brew if available"
        if command_exists brew; then
          brew install colima
        else
          return 1
        fi
      }
      ;;
    *)
      log_error "Unsupported OS for Colima"
      return 1
      ;;
  esac
  
  log_success "Colima installed"
}

install_kubectl() {
  if is_installed kubectl; then return 0; fi
  if ! confirm_install "kubectl (Kubernetes CLI)"; then return 0; fi
  
  case "$OS" in
    macos)
      pkg_install kubectl
      ;;
    ubuntu)
      # Official Kubernetes repository
      curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
      sudo apt-get update
      sudo apt-get install -y kubectl
      ;;
    arch)
      pkg_install kubectl
      ;;
    *)
      # Platform-agnostic binary install
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      rm kubectl
      ;;
  esac
  
  log_success "kubectl installed"
}

install_helm() {
  if is_installed helm; then return 0; fi
  if ! confirm_install "Helm (Kubernetes package manager)"; then return 0; fi
  
  # Platform-agnostic installer
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  
  log_success "Helm installed"
}

install_k9s() {
  if is_installed k9s; then return 0; fi
  if ! confirm_install "k9s (Kubernetes TUI)"; then return 0; fi
  
  case "$OS" in
    macos) pkg_install k9s ;;
    ubuntu|arch) pkg_install k9s ;;
    *)
      # Install from GitHub releases
      curl -sS https://webinstall.dev/k9s | bash
      ;;
  esac
  
  log_success "k9s installed"
}

# Main installation
main() {
  local tools=(
    "docker"
    "docker_compose"
    "colima"
    "kubectl"
    "helm"
    "k9s"
  )
  
  for tool in "${tools[@]}"; do
    "install_$tool" || log_warning "Failed to install $tool"
  done
  
  log_success "DevOps tools installation complete!"
}

main
