.. _code_singlezone:

##################################################
Code Operation: Single-Zone Models
##################################################

This page describes how the four single-zone models (SS, CC, NC, PP) operate internally.
For user-facing inputs and outputs see :doc:`models` and :doc:`outputs`.  For the broader
code structure see :doc:`code_overview`.

Each of these models treats the gas as a single, spatially uniform parcel — there is no
zone-by-zone spatial integration.  The models differ in which physical processes are solved
and whether the gas conditions are swept over a parameter grid.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
SS — Single Slab (``src/slab.f``)
-------------------------------------------------

The SS model solves the emission from a single, optically thin slab of gas illuminated by
a radiation field.  It supports six computation modes covering the range from a fixed-
ionisation snapshot to fully time-dependent evolution.

Setup
=====

The setup sequence is unusual in that the **computation mode is chosen first**, before
anything else, because the mode determines the default initial ionisation state passed to
:doc:`popcha`:

1. **Mode selection** (A–F) — described in the table below.
2. :doc:`popcha` — initial ionisation balance (initial populations depend on the mode).
3. :doc:`photsou` — incident radiation field.
4. **Physical parameters** — read on one line: temperature T (K), hydrogen density
   n\ :sub:`H` (cm\ :sup:`−3`), slab thickness dr (cm), dilution factor wdil, and
   Case A/B recombination parameter cab.  Values ≤ 10 for T are interpreted as
   log\ :sub:`10`; values ≤ 100 for dr are interpreted as log\ :sub:`10`.

Computation modes
=================

.. list-table::
   :header-rows: 1
   :widths: 8 92

   * - Mode
     - Description
   * - A
     - **Fixed ionisation.** The ionisation state is held at the values from
       :doc:`popcha`.  ``localem`` + ``totphot`` + ``zetaeff`` compute the local
       emissivity and recombination balance.  No iteration; a pure snapshot emission
       spectrum at the specified T and n\ :sub:`H`.
   * - B
     - **Equilibrium ionisation at fixed T.** ``equion`` is called iteratively
       together with ``localem`` / ``totphot`` / ``zetaeff`` until the ionic
       populations converge (difpop < 10\ :sup:`−4`).  Temperature is not
       updated.
   * - C
     - **Full photoionisation equilibrium.** ``teequi`` (``nmod='EQUI'``) iterates
       both the ionisation balance and the electron temperature simultaneously to
       convergence.
   * - D
     - **Equilibrium then fixed-T time evolution.** First calls ``teequi`` to reach
       the equilibrium state.  Then calls ``timion`` to advance the ionisation
       balance forward in time at the equilibrium temperature.  The user supplies
       a timestep.
   * - E
     - **Fixed-T time evolution.** ``timion`` is called iteratively at the initial
       temperature.  The timestep grows by a factor of 1.05 each iteration until
       the fractional change in temperature dift < 10\ :sup:`−3`.
   * - F
     - **Full time-dependent.** Three phases: (1) ``teequi`` evolves the gas to
       equilibrium over a first interval tstep1; (2) ``evoltem`` integrates the
       temperature forward during the source lifetime tstep2; (3) a second
       ``evoltem`` call continues the evolution after the source switches off over
       tstep3.  The user supplies the total elapsed time and the source lifetime.

Output
======

Output is written to ``slab.txt`` (main structure), ``slso.sou`` (source spectrum),
``slfn.nfn`` (f-ν spectrum), and ``slbal`` (ionisation balance summary).

-------------------------------------------------
CC — Cooling Curves (``src/coolc.f``)
-------------------------------------------------

The CC model computes collisional ionisation equilibrium (CIE) cooling curves over a
user-specified temperature grid.  It does **not** call :doc:`popcha` or :doc:`photsou` —
there is no radiation field; ionisation is driven entirely by collisions.

Setup
=====

The user provides:

- Log T\ :sub:`min`, log T\ :sub:`max`, log T\ :sub:`step` — the temperature grid.
- Log n\ :sub:`H` — hydrogen density.
- Normalisation code for the cooling rate denominator (0–4):

  .. list-table::
     :header-rows: 1
     :widths: 10 90

     * - Code
       - Denominator
     * - 0
       - n\ :sub:`e` · n\ :sub:`H`
     * - 1
       - n\ :sub:`H`\ :sup:`2`
     * - 2
       - n\ :sub:`e` · n\ :sub:`i`
     * - 3
       - n\ :sup:`2` (total particle density squared)
     * - 4
       - n\ :sub:`e`\ :sup:`2`

- Flags for optional per-element cooling files (``jcoolelems``), per-element ionisation
  fraction files (``jsaveatoms``), and per-element emission spectrum files
  (``jsavespecs``).
- Run name.

An expert-mode flag ``jeqnenh='Y'`` forces n\ :sub:`e` = n\ :sub:`H`, omitting the
metals contribution to the electron density.

Computation
===========

For each temperature point in the grid:

1. ``equion`` computes the CIE ionisation balance at the current T.
2. An inner convergence loop (max 5 iterations) repeats ``equion`` until the
   fractional population change difpop < 10\ :sup:`−6`.
3. ``localem`` + ``totphot2`` (mode ``LOCL``) compute the local emissivities at the
   converged state.
4. Per-element cooling contributions ``coolz`` are accumulated.
5. X-ray band fractions are computed for five bands (0–100 eV, 0.1–0.5 keV,
   0.5–1.0 keV, 1.0–2.0 keV, 2.0–10.0 keV) expressed as fractions of the total
   cooling.

Output
======

Main output: ``coolcv.csv``.  Optional per-element files: ``Ion*.csv`` (ionisation
fractions), ``Loss*.csv`` (cooling losses per element), ``xray*.emi`` (X-ray
emissivities), ``spec*.csv`` (emission spectra).

-------------------------------------------------
NC — Non-Equilibrium Cooling (``src/neqc.f``)
-------------------------------------------------

The NC model follows the time-dependent cooling and recombination of a gas parcel that
has passed through a shock front.  It is structurally a stripped-down S5: it computes
Rankine-Hugoniot jump conditions and then integrates the post-shock cooling zone using
the same ``compsh5`` routine as S5, but **without** a photo-ionised precursor and without
the global convergence loop.

Setup (``neqcsetup``)
=====================

Physical parameters are read on a **single input line**: initial temperature T (K),
hydrogen density n\ :sub:`H` (cm\ :sup:`−3`), Mach number, and magnetic field
parameter α.

The setup sequence then:

1. Calls ``ciepops`` — computes the CIE ionisation balance at the given T.  The result
   is copied to the proto-shock array ``pop_neu``, the precursor array ``pop_pre``, and
   their saved copies.
2. Calls ``shockcmpf`` — applies the Rankine-Hugoniot jump conditions to compute the
   immediate post-shock state (T\ :sub:`1`, n\ :sub:`1`, v\ :sub:`1`, B\ :sub:`1`).
3. Calls ``shocksummary`` — prints the pre- and post-shock state to the terminal.
4. Configures output file names and the stopping condition.

Integration
===========

After setup, ``compsh5`` is called with ``finalit=1`` (write all output on the first
pass).  The integrator is identical to the one documented in :doc:`code_s5` (Phase 2a):
it advances zone by zone using a predictor-corrector scheme with ``timion`` (ionisation
balance), ``rankhug`` (MHD flow equations), and ``flocallosses`` (net cooling rate),
until the stopping condition is met.

The key difference from S5 is that NC makes only one pass: there is no
``shock5precursor`` call and no global iteration loop.  The gas starts from the CIE
state, is jumped to the immediate post-shock conditions by Rankine-Hugoniot, and then
cools and recombines downstream without feedback from a precursor.

--------------------------------------------------------------
PP — Photoionisation Equilibrium Curves (``src/phocrv.f``)
--------------------------------------------------------------

The PP model computes photoionisation equilibrium for an optically thin single slab
swept over a grid of hydrogen densities or ionisation parameters.  It is effectively
the equilibrium-only mode of SS (mode C) automated over a parameter range.

Setup
=====

1. **Curve type**:

   - ``A`` — fixed radiation field, density swept from n\ :sub:`low` to n\ :sub:`high`
     with a logarithmic step factor.
   - ``B`` — fixed density, ionising photon rate Q swept from Q\ :sub:`low` to
     Q\ :sub:`high` with a logarithmic step factor.

   For mode A: initial density, final density, log step factor.
   For mode B: fixed density, initial Q, final Q, log step factor.  Values ≤ 10 for
   density are taken as log\ :sub:`10`; values ≤ 10 for Q are taken as log\ :sub:`10`.

2. **Normalisation** (same five codes 0–4 as CC).

3. **Per-element output** flag (``jsaveatoms``).

4. :doc:`popcha` — initial ionisation balance.

5. :doc:`photsou` — radiation field.  For mode B, the field is immediately rescaled to
   deliver the starting Q value.

6. **Initial conditions** — T (K) and slab thickness dr (cm) on one line.  Values ≤ 10
   for T and ≤ 100 for dr are interpreted as log\ :sub:`10`.

7. **Run name**.

Computation
===========

For each grid point the code:

1. Rescales the radiation field (mode B only) to the current Q.
2. Calls ``localem`` + ``totphot`` + ``zetaeff`` to evaluate local emissivities and
   recombination rates.
3. Calls ``teequi`` (``nmod='EQUI'``) to converge the ionisation balance and
   temperature.  Steps 2–3 are repeated three times in sequence to ensure robust
   convergence from an arbitrary starting state.
4. Computes the mean molecular weight and X-ray band fractions in the same five bands
   as CC.
5. Writes one record to each output file and, if enabled, appends to the per-element
   ``IonPIE*.csv`` files.

Output
======

- ``phocv.csv`` — main curve: log Q\ :sub:`H`, T\ :sub:`e`, n\ :sub:`e`, n\ :sub:`H`,
  normalised cooling/emission, H\ :sup:`0`/H\ :sup:`+` fractions, mean optical depth,
  free-free and total loss rates.
- ``phopb.csv`` — X-ray band breakdown per grid point.
- ``IonPIE<elem>.csv`` (optional) — per-element ionisation fractions as a function of Q
  and T\ :sub:`e`.
