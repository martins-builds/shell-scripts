#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <target> [--clean]"
    exit 1
}

[[ $# -ge 1 ]] || usage

target="$1"
clean=0
if [[ "${2}" == "--clean" ]]; then
    clean=1
fi

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Documents/stm32-bare-metal}"
dir="$PROJECTS_DIR/$target"

[[ -d "$dir" ]] || { echo "error: no such project: $dir" >&2; exit 1; }

if (( clean )); then
    make -C "$dir" clean
fi

make -C "$dir"
echo "build ok: $target"