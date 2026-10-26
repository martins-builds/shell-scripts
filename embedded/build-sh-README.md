# STM32 Build and Flash Script

A bash script that builds an STM32 bare-metal project with `make`, optionally cleans first, optionally flashes the result with `st-flash`, and writes a timestamped log of every run.

```
./embedded/build.sh usb-cdc --clean --flash
```

## Features

- One command to clean, build and flash a project
- Options can be given in any order
- Stops immediately on the first failure, so a broken build is never reported as OK
- Every run is logged to a timestamped file, including compiler errors
- Clear errors for a missing target, an unknown option, or a missing `st-flash`

## Requirements

- bash (works with the bash 3.2 that ships with macOS)
- `make` and `arm-none-eabi-gcc` for building
- `st-flash` (from stlink) for flashing
- Project folders that each contain a `Makefile` that produces `main.bin`

## Usage

```
./embedded/build.sh <target> [--clean] [--flash]
```

| Argument    | Meaning                                                      |
|-------------|--------------------------------------------------------------|
| `<target>`  | name of the project folder inside `PROJECTS_DIR`             |
| `--clean`   | run `make clean` before building                             |
| `--flash`   | after a successful build, flash `main.bin` to `0x08000000`   |

The folder that contains the projects is `PROJECTS_DIR`, which defaults to `$HOME/Documents/stm32-bare-metal`. Override it for one run:

```
PROJECTS_DIR=~/other ./embedded/build.sh usb-cdc
```

Examples:

```
./embedded/build.sh usb-cdc                  # build only
./embedded/build.sh usb-cdc --clean          # clean, then build
./embedded/build.sh --clean usb-cdc --flash  # clean, build, flash (any order)
```

## Logs

Each run writes `embedded/logs/<target>_<YYYYMMDD_HHMMSS>.log`, containing the make output (stdout and stderr) and, with `--flash`, the flash output. The path is printed at the start of every run. The `logs/` folder is ignored by git.

## Exit codes

| Code | Meaning                                                              |
|------|----------------------------------------------------------------------|
| 0    | everything requested succeeded (`build ok: <target>` is printed)     |
| 1    | bad usage, unknown option, missing project, or missing `st-flash`    |
| other| a failing build or flash command's own exit status (script stops)    |

## How it works

- `set -euo pipefail` at the top: exit on the first error, treat unset variables as errors, and make a pipeline fail if any stage fails. That last one matters because make's output is piped to `tee`, and without `pipefail` a failed build would look successful.
- Arguments are parsed with a `for` loop and a `case` statement, so options work in any order and unknown options are rejected.
- The script finds its own folder with `BASH_SOURCE`, so `logs/` is always next to the script, wherever it is run from.
- Output goes to the terminal and the log at once with `2>&1 | tee -a "$log"`.
- All variables are quoted.

## Tested

| Case                                           | Result                                    |
|------------------------------------------------|-------------------------------------------|
| No arguments                                   | prints usage, exits 1                     |
| Build with `--clean`                           | cleans, builds, prints `build ok`         |
| Nonexistent project                            | `error: no such project`, exits 1         |
| Unknown option                                 | `unknown option`, prints usage            |
| Deliberate syntax error in a C file            | make fails, script stops, no `build ok`   |
| `--flash` on a real Nucleo-64 F446RE           | not yet tested                            |

Trace a run with `bash -x ./embedded/build.sh usb-cdc` to see every command as it executes.

## Known limitations

- Flashing assumes the output file is `main.bin` at address `0x08000000`, which is true for this repo's STM32F4 projects but not for every target.
- There is no `--help` flag. Any unknown option prints the usage line.
- The default `PROJECTS_DIR` is specific to one machine.
- It uses `make` only. A CMake project would need a different build step.

## What I would change

- Add `-h` / `--help`
- Read the flash address and binary name from a small per-project config
- Print how long the build took
- Add a `--monitor` option that opens the serial port after flashing
