# MAPPINGS Example Scripts

Self-contained, runnable `.mv` input scripts demonstrating specific
model types or mechanisms. Each one can be run directly with:

```
map52 < <script>.mv
```

from this directory (or copy the script plus any files it references
— noted below — anywhere else and run it from there).

## Shock and photoionisation walkthroughs

- **`s5_shock200.mv`** (+ `s5_shock_abund.txt`) — a 200 km/s, α = 1
  magnetised radiative shock with auto-iterated photo-ionised
  precursor, minimal standard output. Fully explained line by line in
  the Sphinx docs: *Walkthrough: An S5 Shock Model*.
- **`s5_shock200_linemonitor.mv`** (uses the same `s5_shock_abund.txt`)
  — the same shock, with the `L` "monitor lines" option added to track
  Hβ, Hα, and [O III] 5007 as a function of position through the
  precursor and cooling zone. Uses a different output prefix
  (`v200sl_` vs. the base script's `v200s_`) so both can be run in the
  same directory, even concurrently, without their output files
  colliding.
- **`p6_hii_atlas9.mv`** (+ `p6_hii_abund.txt`) — an isochoric HII
  region ionised by a 45,000 K ATLAS9 stellar atmosphere. Also fully
  explained in the Sphinx docs: *Walkthrough: A P6 Photoionisation
  Model*.

These three are also downloadable directly from those two docs pages,
for anyone who wants just the script without a full MAPPINGS checkout.

## `.sou` file chaining demonstration

- **`bbt.mv`** — a plane-parallel P6 model with an internally-generated
  100,000 K blackbody source.
- **`bbt-sou.mv`** — the identical model, but reading the same field
  back in from **`bb100k.sou`** (a saved photon-source file) instead of
  generating it internally.
- **`bbt.sh`** — the same script as `bbt.mv`, wrapped as a shell
  heredoc (`./map52<<EOF ... EOF`) instead of piped from a file — a
  second way of invoking it, not a different example.

Together `bbt.mv`/`bbt-sou.mv` are a round-trip check: they confirm
that reading a previously saved `.sou` field reproduces the same model
as generating it directly, which is the mechanism behind chaining
models (e.g. feeding one model's output field as another's input
source).

## Single-zone cooling/curve models

**`cooling/`** is a self-contained bundle (own `map.prefs`, own
`solar.txt`) for the three single-zone "curve" model types:

- **`cie_sol.mv`** — CC, equilibrium (CIE) cooling curve
- **`neq_sol.mv`** — NC, non-equilibrium cooling
- **`pie_sol.mv`** — PP, photoionisation-equilibrium curves
- **`runcurves.sh`** — runs all three in sequence and times them,
  the same pattern as the regression tests in
  `scripts/testScripts/*/runtests.sh`

Running any script in this directory writes its usual output files
(`.ph6`/`.sh5`/`.csv`/etc.) alongside it — those aren't checked in and
are safe to delete.
