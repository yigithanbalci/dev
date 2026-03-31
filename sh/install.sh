#!/usr/bin/env bash
#
# Modern installation orchestrator for Unix-based systems
# Usage:
#   ./install.sh                    # Interactive mode with category selection
#   ./install.sh --all              # Install everything
#   ./install.sh cli langs          # Install specific categories
#   ./install.sh --exclude docker   # Install everything except matching pattern
#   ./install.sh --dry-run cli      # Show what would be installed
#   ./install.sh --list             # List all available categories
#
# Environment variables:
#   DEV_ENV         - Path to devenv repository (auto-detected if not set)
#   INSTALL_NONINTERACTIVE=1  - Skip all prompts, use defaults

set -euo pipefail

# Auto-detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DEV_ENV="${DEV_ENV:-$(dirname "$SCRIPT_DIR")}"

# Configuration
DRY_RUN=0
EXCLUDE_MODE=0
INTERACTIVE=1
INSTALL_ALL=0
LIST_ONLY=0
FILTER_PATTERN=""

# Color output
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
else
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_dry() { echo -e "${YELLOW}[DRY-RUN]${NC} $*"; }

usage() {
  cat <<EOF
Modern Installation Orchestrator for Unix-based Systems

USAGE:
  $(basename "$0") [OPTIONS] [CATEGORIES...]

OPTIONS:
  -h, --help           Show this help message
  -l, --list          List all available installation categories
  -a, --all           Install all categories
  -e, --exclude       Exclude categories/scripts matching pattern (can be used multiple times)
  -d, --dry-run       Show what would be installed without actually installing
  -i, --interactive   Enable interactive mode (default)
  -y, --yes           Non-interactive mode, use defaults

CATEGORIES:
  cli                 CLI tools (fzf, ripgrep, bat, eza, etc.)
  langs               Programming languages (rust, go, node, etc.)
  editors             Text editors (neovim, emacs, zed)
  shells              Shell environments (fish, zsh)
  terminals           Terminal emulators (wezterm, kitty, ghostty)
  terminal-tools      Terminal programs (tmux, lazygit, yazi, etc.)
  devops              DevOps tools (docker, kubernetes, colima)
  build               Build tools (cmake, make)
  shell-utils         Shell utilities (direnv, doppler, fastfetch)
  ai                  AI tools (claude, copilot-cli)

EXAMPLES:
  $(basename "$0")                    # Interactive mode
  $(basename "$0") --all              # Install everything
  $(basename "$0") cli langs          # Install CLI tools and languages
  $(basename "$0") -e docker -e rust  # Install all except docker and rust
  $(basename "$0") --dry-run cli      # Preview CLI tools installation

EOF
}

list_categories() {
  log_info "Available installation categories:"
  echo ""
  echo "  cli            - Modern CLI tools"
  echo "  langs          - Programming language toolchains"
  echo "  editors        - Text editors and IDEs"
  echo "  shells         - Shell environments"
  echo "  terminals      - Terminal emulators"
  echo "  terminal-tools - Terminal-based programs"
  echo "  devops         - Container and orchestration tools"
  echo "  build          - Build systems and tools"
  echo "  shell-utils    - Shell enhancement utilities"
  echo "  ai             - AI and ML command-line tools"
  echo ""
}

parse_args() {
  local exclude_patterns=()
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      -l|--list)
        LIST_ONLY=1
        shift
        ;;
      -a|--all)
        INSTALL_ALL=1
        INTERACTIVE=0
        shift
        ;;
      -e|--exclude)
        EXCLUDE_MODE=1
        exclude_patterns+=("$2")
        shift 2
        ;;
      -d|--dry-run)
        DRY_RUN=1
        shift
        ;;
      -i|--interactive)
        INTERACTIVE=1
        shift
        ;;
      -y|--yes)
        INTERACTIVE=0
        export INSTALL_NONINTERACTIVE=1
        shift
        ;;
      -*)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
      *)
        # Category argument
        FILTER_PATTERN="${FILTER_PATTERN}${FILTER_PATTERN:+|}$1"
        INTERACTIVE=0
        shift
        ;;
    esac
  done
  
  # Build exclude pattern
  if [[ ${#exclude_patterns[@]} -gt 0 ]]; then
    FILTER_PATTERN=$(IFS='|'; echo "${exclude_patterns[*]}")
  fi
}

get_install_scripts() {
  local category="$1"
  local script_path="$SCRIPT_DIR/${category}.sh"
  
  if [[ -f "$script_path" ]]; then
    echo "$script_path"
  fi
}

should_run_category() {
  local category="$1"
  
  # If --all is set, install everything
  if [[ $INSTALL_ALL -eq 1 ]]; then
    return 0
  fi
  
  # If filter pattern is empty, run all (interactive will handle later)
  if [[ -z "$FILTER_PATTERN" ]]; then
    return 0
  fi
  
  # Check if matches filter
  if [[ $EXCLUDE_MODE -eq 1 ]]; then
    # Exclude mode: return 0 if NOT matching pattern
    if echo "$category" | grep -Eq "$FILTER_PATTERN"; then
      return 1
    fi
    return 0
  else
    # Include mode: return 0 if matching pattern
    if echo "$category" | grep -Eq "$FILTER_PATTERN"; then
      return 0
    fi
    return 1
  fi
}

run_install_script() {
  local script="$1"
  local category="$(basename "${script%.sh}")"
  
  if [[ $DRY_RUN -eq 1 ]]; then
    log_dry "Would run: $script"
    return 0
  fi
  
  log_info "Running installation: $category"
  if bash "$script"; then
    log_success "Completed: $category"
    return 0
  else
    log_error "Failed: $category"
    return 1
  fi
}

interactive_select() {
  log_info "Interactive Installation Mode"
  echo ""
  list_categories
  echo "Select categories to install (space-separated, or 'all' for everything):"
  read -r selection
  
  if [[ "$selection" == "all" ]]; then
    INSTALL_ALL=1
  else
    FILTER_PATTERN=$(echo "$selection" | sed 's/ /|/g')
  fi
}

main() {
  parse_args "$@"
  
  if [[ $LIST_ONLY -eq 1 ]]; then
    list_categories
    exit 0
  fi
  
  # Interactive mode
  if [[ $INTERACTIVE -eq 1 ]] && [[ -z "$FILTER_PATTERN" ]] && [[ $INSTALL_ALL -eq 0 ]]; then
    interactive_select
  fi
  
  # Find all category scripts
  local categories=(
    "cli"
    "langs"
    "editors"
    "shells"
    "terminals"
    "terminal-tools"
    "devops"
    "build"
    "shell-utils"
    "ai"
  )
  
  local scripts_to_run=()
  for category in "${categories[@]}"; do
    if should_run_category "$category"; then
      local script=$(get_install_scripts "$category")
      if [[ -n "$script" ]] && [[ -f "$script" ]]; then
        scripts_to_run+=("$script")
      fi
    fi
  done
  
  if [[ ${#scripts_to_run[@]} -eq 0 ]]; then
    log_warning "No installation scripts matched your criteria"
    exit 0
  fi
  
  # Show summary
  log_info "Will run ${#scripts_to_run[@]} installation script(s):"
  for script in "${scripts_to_run[@]}"; do
    echo "  - $(basename "${script%.sh}")"
  done
  echo ""
  
  # Confirm if not in non-interactive mode
  if [[ "${INSTALL_NONINTERACTIVE:-0}" != "1" ]] && [[ $DRY_RUN -eq 0 ]]; then
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "Installation cancelled"
      exit 0
    fi
  fi
  
  # Run installations
  local failed=0
  for script in "${scripts_to_run[@]}"; do
    if ! run_install_script "$script"; then
      ((failed++))
    fi
  done
  
  echo ""
  if [[ $failed -eq 0 ]]; then
    log_success "All installations completed successfully!"
  else
    log_error "$failed installation(s) failed"
    exit 1
  fi
}

main "$@"
