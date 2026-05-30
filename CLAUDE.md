# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

MAPPINGS V (v5.2.1) is an astrophysical plasma modeling code for computing photoionized nebulae (HII regions, PNe, AGN) and magnetohydrodynamic shock waves. The main code is Fortran 77 legacy; the post-processing tools are C.

## Build Commands

All commands run from the repo root unless noted.

```bash
make build          # full: compile + install to ~/mappings520/ + clean (use for releases)
make -j build       # parallel build (faster)
make compile        # compile only, output to bin/map52
make clean          # remove .o files
make distclean      # remove .o files and executables
make install        # install after manual compile
make uninstall      # remove ~/mappings520/ install (preserves user files)
make tools          # build and install the C post-processing tools only
```

To rebuild just the C tools individually:
```bash
cd tools/blur  && make build
cd tools/lines && make build
cd tools/red   && make build
```

## Running Tests

Tests live in `scripts/testScripts/` and expect `~/mappings520/bin/map52` to exist (i.e., run after `make build`).

```bash
cd scripts/testScripts/MV52tests  && bash runtests.sh    # photoionization tests
cd scripts/testScripts/ShockTests && bash runshocks.sh   # shock model tests
```

Tests pipe `.mv` input scripts to the executable and validate output `.ph6`/`.sh5`/`.csv` files with AWK scripts. Results land in `MV52Results/` and `MV52ShockResults/`.

## Running the Code

```bash
cd ~/mappings520/lab
./map52 < model.mv          # run a model from a script
./map52                     # interactive mode
```

`map.prefs` must be present in the working directory (it is already in `lab/`). MAPPINGS searches for atomic data in `./data/`, then `~/mappings520/`, then the `$MAPDATA` environment variable.

After `make compile`, `for_bashrc.txt` is generated at the repo root with the shell setup lines (`MAPDATA`, `MAPBIN`, `PATH`, aliases). Source or paste these into `.bashrc`/`.zshrc`.

## Architecture

### Main Fortran code (`src/`)

Compiled with `gfortran -std=legacy -march=native -Ofast`. All global state lives in Fortran COMMON blocks declared in the `.inc` include files — every `.f` file that needs shared state does `include 'cblocks.inc'` (and others). The includes must be compiled with `-I src/`.

Key include files:
- `cblocks.inc` — master COMMON block (abundances, atomic data arrays, run parameters); includes `const.inc`
- `const.inc` — physical and mathematical constants (`implicit none` is set here)
- `p6blocks.inc`, `p7blocks.inc`, `s5blocks.inc` — photo and shock-specific arrays

Entry point is `src/mappings.f`. Initialization (`src/mapinit.f`) reads the atomic data files from disk at startup before any model runs. The main physics modules include:

| File | Role |
|---|---|
| `photo6.f`, `photo7.f` | Photoionization solver |
| `shock4.f`, `shock5.f` | Shock wave computation |
| `hydro.f`, `hydro2p.f` | Hydrodynamics |
| `cool.f`, `coloss.f` | Cooling functions |
| `recom.f`, `freebound.f`, `freefree.f` | Recombination and continuum emission |
| `output.f` | All file output |
| `mapinit.f` | Runtime data initialization (reads `data/` files) |

Output file extensions: `.ph6` (photoionization), `.sh5` (shock structure), `.nfn`, `.lam`, `.bln`, `.csv`.

### C post-processing tools (`tools/`)

Three standalone tools built with `gcc -O3`, each in its own subdirectory. They share two internal libraries:
- `zls/` — array, I/O, FFT, spline, and polynomial utilities
- `zlib/` — compression (reads `.txt.gz` input files)
- `ccl/` — binary search tree (used by `lines`/`listlines` only)

| Tool | Purpose |
|---|---|
| `blur` | Convolve and rebin spectra; optionally normalize by a continuum model |
| `lines` | Gaussian (or Lorentzian) line fitting on a two-column spectrum file using a patch list |
| `listlines` | Tabulate or renumber a `lines` patch file |
| `red` | Apply reddening corrections to spectra |

Installed to `~/mappings520/bin/`.

### Sphinx documentation (`docs/sphinx/`)

Built using the `ksl` conda environment (the system Python lacks the required packages):

```bash
cd docs/sphinx
conda run -n ksl python3 -m sphinx -b html source html
```

Open `docs/sphinx/html/index.html` to view the result.

### Compiler flags

The Makefile detects `Darwin` vs. Linux and switches the linker flag:
- macOS: `-isysroot $(xcrun --show-sdk-path)` (no explicit `-lm`)
- Linux: `-lm`

To enable warnings during development, uncomment a `WARN` line in the root `Makefile` before compiling (e.g., `-Wall` or `-Wunused-variable -fbounds-check`). For a debug build, swap the `LDR` line to `-g -O0 -fbounds-check -ffpe-summary='none'`.
