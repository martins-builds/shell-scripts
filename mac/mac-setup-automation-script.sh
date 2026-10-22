#!/usr/bin/env bash
set -euo pipefail

if command -v brew &> /dev/null; then
    echo "Homebrew is already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! grep -qE '^[[:space:]]*flash\(\)' "$HOME/.zshrc"; then
  cat >> "$HOME/.zshrc" <<'EOF'

flash() {
  local project_dir

  read "project_dir?Enter project directory name: "

  local base_dir="$HOME/Documents/GitHub"
  local target_dir="$base_dir/$project_dir"

  if [[ ! -d "$target_dir" ]]; then
    echo "Error: Directory not found: $target_dir"
    return 1
  fi

  if [[ ! -f "$target_dir/main.bin" ]]; then
    echo "Error: main.bin not found in $target_dir"
    return 1
  fi

  cd "$target_dir" || return 1
  st-flash write main.bin 0x08000000
}
EOF
fi

if ! grep -q "alias gh=" "$HOME/.zshrc"; then
    echo "alias gh='cd $HOME/Documents/GitHub'" >> "$HOME/.zshrc"
fi

brew install git cmake minicom jq tree
mkdir -p "$HOME/Documents/GitHub/cpp-systems" "$HOME/Documents/GitHub/python-edge-ai" "$HOME/Documents/GitHub/stm32-bare-metal" "$HOME/Documents/GitHub/shell-scripts" "$HOME/Documents/GitHub/embedded-gps-gsm-tracker"
#can successfully navigate