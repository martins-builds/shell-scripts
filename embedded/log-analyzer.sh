#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "usage: $0 <recording.csv>" >&2
    exit 1
}

[[ $# -eq 1 ]] || usage
file="$1"
[[ -f "$file" ]] || { echo "error: no such file: $file" >&2; exit 1; }

rows=$(( $(wc -l < "$file") - 1 ))
echo "file:     $file"
echo "samples:  $rows"
duration=$(awk -F, 'NR==2{first=$1} NR>1{last=$1} END{print (last-first)/1000}' "$file")
echo "duration: $duration s"