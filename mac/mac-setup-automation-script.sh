#!/usr/bin/env bash
set -euo pipefail

if command -v brew &> /dev/null; then
    echo "Homebrew is already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew install git cmake minicom jq tree
mkdir -p "$HOME/Documents/GitHub/cpp-systems" "$HOME/Documents/GitHub/python-edge-ai" "$HOME/Documents/GitHub/stm32-bare-metal" "$HOME/Documents/GitHub/shell-scripts" "$HOME/Documents/GitHub/embedded-gps-gsm-tracker"
#works