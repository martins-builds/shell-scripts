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

echo "target=$target clean=$clean"