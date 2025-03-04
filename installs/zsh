#!/usr/bin/env bash
program="zsh"

# Check the OS type to determine the correct find command
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Unsupported OS for $program. Default shell for $OSTYPE is already $program"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux: Check if it's Ubuntu
  if grep -q "Ubuntu" /etc/os-release; then
    sudo apt install $program
    hash -r
    sudo chsh -s $(which $program)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "Unsupported OS for $program."
  fi
else
  echo "Unsupported OS for $program."
fi
