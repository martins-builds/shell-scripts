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
rate=$(awk -v r="$rows" -v d="$duration" 'BEGIN { print (r - 1) / d }')
echo "rate: $rate"
gaps=$(awk -F',' '
  NR == 2 { prev = $1; next }
  NR > 2  {
    diff = $1 - prev
    if (diff < 9.99 || diff > 10.01) gaps++
    prev = $1
  }
  END { print gaps + 0 }
' "$file")
echo "gaps:     $gaps"
