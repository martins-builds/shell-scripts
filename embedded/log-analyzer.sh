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
if (( rows < 2 )); then
    echo "error: need at least 2 samples, found $rows" >&2
    exit 1
fi
echo "file:     $file"
echo "samples:  $rows"

# a gap is any step between timestamps that is not about 10 ms
gaps=$(awk -F, '
  NR == 2 { prev = $1; next }
  NR > 2  {
    diff = $1 - prev
    if (diff < 9.99 || diff > 10.01) gaps++
    prev = $1
  }
  END { print gaps + 0 }
' "$file")
segments=$(( gaps + 1 ))
echo "gaps:     $gaps"
echo "segments: $segments"

# duration of the continuous stretches only (gaps and resets are not counted)
duration=$(awk -F, '
  NR == 2 { start = $1; prev = $1; next }
  NR > 2  {
    diff = $1 - prev
    if (diff < 9.99 || diff > 10.01) { total += prev - start; start = $1 }
    prev = $1
  }
  END { total += prev - start; print total / 1000 }
' "$file")
echo "duration: $duration s"

rate=$(awk -v r="$rows" -v s="$segments" -v d="$duration" 'BEGIN { print (r - s) / d }')
echo "rate:     $rate Hz"