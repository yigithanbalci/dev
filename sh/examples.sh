#!/usr/bin/env bash
# Quick Examples - Copy and run these commands

# =============================================================================
# BASIC USAGE
# =============================================================================

# Interactive mode - select what to install
./sh/install.sh

# Get help
./sh/install.sh --help

# List all categories
./sh/install.sh --list

# =============================================================================
# INSTALL SPECIFIC CATEGORIES
# =============================================================================

# Install CLI tools only
./sh/install.sh cli

# Install multiple categories
./sh/install.sh cli langs editors

# Install everything
./sh/install.sh --all

# =============================================================================
# EXCLUDE TOOLS/CATEGORIES
# =============================================================================

# Install everything except Docker
./sh/install.sh --all --exclude docker

# Multiple exclusions
./sh/install.sh --all -e docker -e kubernetes -e rust

# =============================================================================
# DRY RUN (PREVIEW)
# =============================================================================

# See what would be installed without actually installing
./sh/install.sh --dry-run cli

# Preview full installation
./sh/install.sh --dry-run --all

# Preview specific categories
./sh/install.sh --dry-run cli langs devops

# =============================================================================
# NON-INTERACTIVE MODE (for scripts/CI)
# =============================================================================

# Skip all prompts
./sh/install.sh --yes cli langs

# Or use environment variable
export INSTALL_NONINTERACTIVE=1
./sh/install.sh cli langs

# =============================================================================
# RUN INDIVIDUAL CATEGORY SCRIPTS
# =============================================================================

# Install just CLI tools
./sh/cli.sh

# Install programming languages
./sh/langs.sh

# Install editors
./sh/editors.sh

# Install DevOps tools
./sh/devops.sh

# =============================================================================
# COMMON WORKFLOWS
# =============================================================================

# New machine setup - interactive
./sh/install.sh

# Developer machine - essential tools
./sh/install.sh cli langs editors shells terminals

# Server setup - no GUI tools
./sh/install.sh cli langs devops build

# Quick test environment
./sh/install.sh cli langs --exclude rust --exclude zig

# CI/CD pipeline
INSTALL_NONINTERACTIVE=1 ./sh/install.sh --yes cli langs build

# =============================================================================
# ADVANCED USAGE
# =============================================================================

# Install all except heavy tools
./sh/install.sh --all -e docker -e kubernetes -e emacs

# Install specific category with preview first
./sh/install.sh --dry-run devops    # Preview
./sh/install.sh devops              # Install

# Check what's available before installing
./sh/install.sh --list
./sh/install.sh --dry-run --all

# =============================================================================
# CATEGORIES QUICK REFERENCE
# =============================================================================

# cli          - ripgrep, fzf, fd, bat, eza, jq, zoxide, atuin
# langs        - rust, go, node (nvm), python, zig, gcc, llvm
# editors      - neovim, emacs, zed
# shells       - fish, zsh, oh-my-zsh, starship
# terminals    - wezterm, kitty, ghostty, alacritty
# terminal-tools - tmux, lazygit, lazydocker, yazi, gh-dash
# devops       - docker, docker-compose, colima, kubectl, helm, k9s
# build        - cmake, make, ninja, meson
# shell-utils  - direnv, doppler, fastfetch, pass
# ai           - copilot-cli, claude-cli, ollama, aichat
