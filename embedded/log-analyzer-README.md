# log-analyzer

A bash script that checks a recording from `sensor-receiver` (CSV) and prints a short health report: sample count, timing gaps, duration, sample rate and per-channel min, max and mean.

Built as the Phase 3 project of my shell course (text and pipelines). Uses only `wc`, `awk` and shell arithmetic.

## Usage

```bash
chmod +x embedded/log-analyzer.sh
./embedded/log-analyzer.sh path/to/recording.csv
```

Run it on every recording in a folder:

```bash
for f in data/*.csv; do ./embedded/log-analyzer.sh "$f"; echo; done
```

Exit codes: `0` on success, `1` on a missing argument, a missing file, or fewer than 2 samples (errors go to stderr).

## Input format

CSV with a header row. The first column is `timestamp_ms`, the other columns are the channels:

```
timestamp_ms,ax,ay,az,gx,gy,gz
```

Both `\n` and `\r\n` line endings work.

## Example output

Real board, 100 Hz, no gaps:

```
file:     data/hw_test_20261107_090018.csv
samples:  3185
gaps:     0
segments: 1
duration: 31.84 s
rate:     100 Hz
channels:
  ax  min  -1000  max    990  mean     -6.11
  ay  min      0  max      0  mean      0.00
  az  min    980  max    980  mean    980.00
  gx  min      0  max      0  mean      0.00
  gy  min      0  max      0  mean      0.00
  gz  min      0  max      0  mean      0.00
```

Recording with the data cable unplugged and replugged once:

```
samples:  1653
gaps:     1
segments: 2
duration: 16.51 s
rate:     100 Hz
```

## How it works

- **Samples**: `wc -l` minus the header line.
- **Gaps**: one `awk` pass compares each timestamp with the previous one. Any step that is not about 10 ms (9.99 to 10.01) counts as a gap. Segments are gaps + 1.
- **Duration**: only the continuous stretches are added up. The time lost in a gap, or a timestamp reset after a board restart, is not counted.
- **Rate**: (samples − segments) / duration. Each segment has one fewer interval than samples.
- **Channels**: one `awk` pass keeps sum, min and max per column. The names come from the header, and min and max are seeded from the first data row.

## Lessons from building it

- A naive duration (last timestamp − first) gave 2.61 s and 667 Hz on the reconnect file. The segment-aware version fixed it.
- Python's `csv` writer produces `\r\n`. The `\r` stuck to the last header name and overwrote the start of its output line. Fix: `sub(/\r$/, "")` first in the `awk` program.
- `awk` programs go in single quotes so the shell does not touch `$1`, `$i`.
- With `set -euo pipefail`, a failing step stops the script instead of printing wrong numbers.

## Limitations

- Assumes a 100 Hz stream (10 ms steps). Other rates need the thresholds changed.
- Does not say where the gaps are. To locate them:

```bash
awk -F, 'NR==1 { next } NR==2 { prev=$1; next }
  { d=$1-prev; if (d<9.99 || d>10.01) print "line " NR ": " prev " -> " $1 " (step " d " ms)"; prev=$1 }' FILE
```

  A large positive step means the cable was unplugged. A negative step means the board restarted.
- The min and max shown above are from a board without a real IMU attached, so most channels are constant.
