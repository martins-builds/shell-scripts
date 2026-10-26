#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <target> [--clean] [--flash]" >&2
    exit 1
}

target=""
clean=0
flash=0

for arg in "$@"; do
    case "$arg" in
        --clean) clean=1 ;;
        --flash) flash=1 ;;
        -*)      echo "unknown option: $arg" >&2; usage ;;
        *)       target="$arg" ;;
    esac
done

[[ -n "$target" ]] || usage

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_dir="$script_dir/logs"
mkdir -p "$log_dir"
log="$log_dir/${target}_$(date +%Y%m%d_%H%M%S).log"
echo "log: $log"

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Documents/stm32-bare-metal}"
dir="$PROJECTS_DIR/$target"

[[ -d "$dir" ]] || { echo "error: no such project: $dir" >&2; exit 1; }

if (( clean )); then
    make -C "$dir" clean
fi

make -C "$dir"

if (( flash )); then
    command -v st-flash >/dev/null || { echo "error: st-flash not found" >&2; exit 1; }
    st-flash write "$dir/main.bin" 0x08000000
fi
echo "build ok: $target"