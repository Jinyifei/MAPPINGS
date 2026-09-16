.. _models:

###############
Model Types
###############

After the startup initialisation described in :doc:`inputs`, MAPPINGS presents
the model selection menu.  The available model types are grouped into four
categories.  This page describes what each model computes and what
information it needs.

Before the model-specific prompts begin, most models ask two shared
questions: :doc:`setting the initial ionisation balance <popcha>` and
:doc:`defining the radiation field <photsou>`.  These are documented on
their own pages and cross-referenced below where they apply.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Photoionisation Multizone Models
-------------------------------------------------

These models compute the full radiative transfer through a stratified,
multi-zone nebula illuminated by a central ionising source.  At each zone
boundary the code iterates to ionisation and thermal equilibrium before
stepping outward.  The diffuse radiation field (re-emission by the nebula
itself) is tracked and fed forward through the model.

P6 — Photoionisation
=====================

``P6`` is the primary photoionisation model.  It computes a spherical or
plane-parallel nebula using an outward-only integration scheme in which zone
widths are determined adaptively from the local optical depth.  Radiation
pressure on the gas is included.  Both equilibrium and finite-age
(time-dependent) ionisation conditions are available.

The user is asked, in order, to:

1. Set the **initial ionisation state** of the gas
   (see :doc:`popcha`).
2. Specify the **ionising photon source** — spectral type, luminosity,
   and radiation field (see :doc:`photsou`).
3. Choose the **geometry** (spherical or plane-parallel).
4. Set the **density structure** (constant density, constant pressure, or
   a power-law density profile) and the initial density or pressure.
5. Define the **model stopping condition** — enter one letter. For most
   letters MAPPINGS immediately asks a follow-up question for the
   limit value; for ``A`` there is no follow-up and input moves
   straight on to output file setup:

   .. list-table::
      :header-rows: 1
      :widths: 8 40 52

      * - Code
        - Ends the model when...
        - What you're asked next
      * - A
        - H\ :sup:`+` fraction falls below a threshold (default 1%,
          shown inline in the menu)
        - Nothing — goes straight to output file setup.
      * - B
        - a specified ion of a specified element falls below a given
          fraction
        - ``Applies to element (Atomic number):`` then ``Give the
          final ionisation fraction of <elem> :``
      * - C
        - the temperature falls below a minimum
        - ``Give the final temperature (<10 as log):`` — **note:**
          despite the prompt text, values under 10 are *not* actually
          converted from log\ :sub:`10` in the current code; the
          number entered is used directly as Kelvin.  Enter the
          temperature in Kelvin outright (e.g. ``10000``, not ``4``)
          until this is resolved.
      * - D
        - the accumulated optical depth exceeds a threshold
        - ``Applies to element (Atomic number):`` then ``Give the
          final optical depth at threshold of <elem>:``
      * - E
        - the model reaches a fixed distance from the inner edge
        - ``Give the distance or radius at which the density
          drops:`` — enter a value in cm directly if ≥ 1e6; a
          smaller value is instead read as a fraction of the
          Strömgren radius.
      * - F
        - the column density of a specific atom/ion reaches a limit
        - ``Give the final column density (<100 as log):`` (values
          under 100 genuinely are read as log\ :sub:`10` here), then
          ``Applies to element (Atomic number):`` then ``Applies to
          ion stage :``
      * - H
        - the total hydrogen column density reaches a limit
        - ``Give the total H column density (<100 as log):`` — same
          genuine log\ :sub:`10` convention as ``F``.

   A model can also end before any of these letters are satisfied: a
   hard cap of 4096 zones, a file literally named ``terminate``
   appearing in the run directory, or the normalised electron density
   falling to its automatic recombination floor regardless of which
   letter was chosen.  See :doc:`code_photo`, "Stopping condition",
   for how all of these are evaluated internally.

Main output files are ``photn<N>.ph6`` and associated ``.csv`` and ``.sou``
files as described in :doc:`outputs`.  For a full worked example — an
actual script, the files it produces, and what is inside them — see
:doc:`walkthrough_p6`.

P7 — Photoionisation (Experimental)
=====================================

``P7`` runs the same physics as P6 but uses a separate common-block
structure (``p7blocks.inc``) and exposes additional experimental output
options and an API for batch scripting.  It is the recommended mode for
automated grid calculations.  Output files carry the ``.ph7`` extension.

-------------------------------------------------
Shockwave and Precursor Models
-------------------------------------------------

S5 — Magnetised Shock Waves
============================

``S5`` computes steady-state, plane-parallel, magnetised radiative shock
waves and their photo-ionised precursors.  The post-shock cooling zone is
integrated with an adaptive mesh.  The precursor is the region ahead of the
shock front that is photo-ionised by the shock's own extreme ultraviolet and
X-ray emission.  S5 iterates the shock and precursor until the radiation
field and ionisation state are self-consistent.

The user is asked, in order, to:

1. Set the **initial ionisation state** (see :doc:`popcha`).
2. Specify an optional **ambient radiation field** (see :doc:`photsou` —
   set to zero with option ``Z`` then ``X`` for a pure shock with no
   external ionising background).
3. Choose the **shock jump parameter**:

   - ``V`` — shock velocity in km/s (most common)
   - ``T`` — post-shock temperature in K

4. Choose the **magnetic field parameterisation**:

   .. list-table::
      :header-rows: 1
      :widths: 10 90

      * - Code
        - Meaning
      * - B
        - Pre-shock field strength in μG at the shock front
      * - A
        - Magnetic alpha α₀ = P\ :sub:`mag`/P\ :sub:`gas` in the
          pre-shock (proto) state
      * - M
        - Alfvén Mach number M\ :sub:`A`
      * - C
        - α = P\ :sub:`mag`/P\ :sub:`gas` at the shock front
      * - R
        - Magnetic eta η = 2P\ :sub:`mag`/P\ :sub:`ram` = 1/M\ :sub:`A`\ ²

5. Specify the **shock velocity** (or temperature if ``T`` was chosen
   above) and **pre-shock hydrogen density**.
6. Choose the **diffuse field mode** — full (``F``) or zeroed (``Z``).
7. Define the **model ending condition** — enter one letter. For most
   letters MAPPINGS immediately asks a follow-up question for the
   limit value; for ``A``, ``F``, and ``G`` there is no follow-up and
   input moves straight on to step 8 (minimum iterations):

   .. list-table::
      :header-rows: 1
      :widths: 8 40 52

      * - Code
        - Ends the model when...
        - What you're asked next
      * - A
        - the mean weighted ionisation fraction drops below 1%
          (default)
        - Nothing — goes straight to step 8.
      * - B
        - a specific ion's population fraction drops below a limit
        - ``Give atom, ion and limit fraction:`` — one line, three
          numbers: the atom number (periodic order, H=1, He=2, …),
          the ion stage (1=neutral, 2=singly ionised, …), and the
          fraction. E.g. ``1 2 0.05`` stops the model when the HII
          fraction drops below 0.05.
      * - C
        - the temperature drops below a limit
        - ``Give final temperature (K > 10, log <= 10):`` — one
          number. Entered as-is (Kelvin) if it's above 10; if it's 10
          or below it's read as log\ :sub:`10`\ (K) and converted
          automatically (e.g. ``4`` means 10\ :sup:`4` K).
      * - S
        - the temperature drops below a limit **and** the gas is
          >95% neutral
        - Same ``Give final temperature...`` prompt and K/log
          convention as ``C``; both the temperature and the 95%
          neutral condition must hold together.
      * - D
        - the cumulative distance downstream of the shock front reaches
          a limit
        - ``Give final distance (cm > 100, log<=100):`` — one number.
          Entered as-is (cm) if above 100; if 100 or below it's read
          as log\ :sub:`10`\ (cm) and converted (e.g. ``17`` means
          10\ :sup:`17` cm).
      * - E
        - the elapsed post-shock flow time reaches a limit
        - ``Give time limit (s > 100, log<=100):`` — one number.
          Entered as-is (seconds of simulated flow time, not
          wall-clock runtime) if above 100; if 100 or below it's read
          as log\ :sub:`10`\ (s) and converted (e.g. ``10`` means
          10\ :sup:`10` s).
      * - F
        - heating and cooling come into thermal balance
        - Nothing — goes straight to step 8.
      * - G
        - the net cooling function goes negative
        - Nothing — goes straight to step 8.

   Whichever letter is chosen, and however its follow-up (if any) is
   answered, the very next prompt after this step is always step 8,
   minimum iterations.

   A model can also end before any of these letters are satisfied: a
   hard cap of 4096 zones (or the temperature dropping below 100 K
   regardless of ``jend``), or a file literally named ``terminate``
   appearing in the run directory.  These aren't inputs — nothing
   prompts for them — but they can end a run early regardless of what
   was chosen here.  In particular, a ``D`` or ``E`` limit set beyond
   what the shock will ever physically reach doesn't produce an
   unbounded run: the model still ends via the zone cap or temperature
   floor, just without ``jend`` itself ever being satisfied.  See
   :doc:`code_s5`, "Step 6 — Check stopping condition", for how all of
   these conditions, letter-based and not, are evaluated internally
   each zone, and for exactly what ``dist``/``timlps`` measure.
8. Set the **minimum number of global iterations** for the
   precursor↔shock convergence loop (``<=1`` means no further
   iteration; default 3).
9. Choose the **output file prefix** (up to 8 characters, e.g. ``v100s``).
10. Work through the **Output Multi-Option Menu** to select optional
    output files, one letter per line, ending with ``X`` to accept the
    current selection and move on:

    .. list-table::
       :header-rows: 1
       :widths: 10 90

       * - Code
         - Adds
       * - A
         - Standard output only, and resets any options chosen so far
           (the menu is then shown again)
       * - B
         - Ion balance files — prompts for which elements to track
       * - C
         - All-rates file
       * - D
         - Flow dynamics file
       * - E
         - Final downstream radiation field
       * - F
         - All upstream radiation fields, at every step
       * - H
         - Cooling in X-ray bands
       * - K
         - Cooling components by element file
       * - L
         - Line monitor — prompts for how many lines (up to the
           compiled-in maximum) and their wavelengths, then tracks
           each one's flux at every zone
       * - R
         - Reset all options back to standard output
       * - X
         - Exit the menu with the currently selected options

11. Choose the **runtime screen display** verbosity:

    .. list-table::
       :header-rows: 1
       :widths: 10 90

       * - Code
         - Meaning
       * - A
         - Standard display
       * - B
         - Detailed slab display
       * - C
         - Full display (slab display plus timescales)
       * - M
         - Minimal display (batch mode)

12. Give a **name or code** for this model run — free text, written into
    the output file headers.

Output files use the ``.sh5`` and ``.csv`` extensions as described in
:doc:`outputs`.  For a full worked example — an actual script
(including a ``jend='A'``, line-monitor run), the files it produces,
and what is inside them — see :doc:`walkthrough_s5`.


-------------------------------------------------
Single Zone Models
-------------------------------------------------

These models treat a single parcel of gas without radiative transfer.  They
are useful for exploring the sensitivity of emission to temperature, density,
and ionisation state, and for computing grids of equilibrium curves.

SS — Single Slab
=================

``SS`` solves for a single gas parcel with a full diffuse radiation field
but without zone-to-zone transfer.  Before selecting a mode, MAPPINGS
asks for the :doc:`initial ionisation balance <popcha>` and the
:doc:`radiation field <photsou>`.  Six calculation modes are then
available:

.. list-table::
   :header-rows: 1
   :widths: 10 90

   * - Mode
     - Description
   * - A
     - Fixed degree of ionisation at a user-specified temperature.  The
       ionisation fractions are held constant and the emissivity is
       computed.
   * - B
     - Equilibrium ionisation at a fixed temperature.  The ionisation
       balance is iterated to convergence at constant T.
   * - C
     - Equilibrium ionisation **and** equilibrium temperature.  Both the
       ionisation balance and temperature are iterated until both converge.
       This is the standard thermal equilibrium single-zone model.
   * - D
     - Time-dependent ionisation at equilibrium temperature.  The
       ionisation state evolves in time while the temperature is held at
       its equilibrium value.
   * - E
     - Time-dependent ionisation at a fixed (user-supplied) temperature.
   * - F
     - Time-dependent ionisation and temperature.  Both evolve in time.

CC — CIE Cooling Curves
========================

``CC`` computes the **collisional ionisation equilibrium** (CIE) cooling
function Λ(T) over a user-specified temperature range.  At each temperature
step the ionisation balance is solved self-consistently for the given
abundance set (set during startup), then the total and element-by-element
cooling rates are computed.

Inputs:

- Initial and final temperature (log\ :sub:`10` T)
- Temperature step size (log\ :sub:`10`)
- Hydrogen number density (log\ :sub:`10`)
- Cooling normalisation: n\ :sub:`e`\ n\ :sub:`H`, n\ :sub:`H`\ ²,
  n\ :sub:`e`\ n\ :sub:`i`, n², or n\ :sub:`e`\ ²
- Whether to save per-element cooling files, ion fraction files, and
  emissivity (``.emi``) files

Output files use the ``.csv`` extension.

NC — Non-Equilibrium Cooling
==============================

``NC`` follows the **time-dependent** cooling of a gas parcel from a given
initial state without imposing a shock jump.  It uses the same integrator
as S5 (``compsh5``) but without a discontinuity at the front.

Inputs (all on a single line):

- Initial temperature T (K; values ≤ 10 are treated as log\ :sub:`10`)
- Hydrogen number density n\ :sub:`H` (values < 0 treated as
  log\ :sub:`10`)
- Mach number M (≥ 0; used to set the bulk flow velocity)
- Magnetic alpha α = P\ :sub:`mag`/P\ :sub:`gas` (≥ 0; negative values
  are interpreted as a field strength in μG)

The ionisation balance at the initial conditions is computed by iterating
to CIE before the time integration begins.  Output files carry the ``.neq``
and ``.csv`` extensions.

PP — PIE Photoionisation Curves
=================================

``PP`` computes a grid of **photoionisation equilibrium** (PIE) single-slab
models over a range of either density or radiation intensity.  Each point
in the grid is an optically thin, single-zone model in ionisation and
thermal equilibrium under the specified radiation field.  Before the grid
parameters are entered, MAPPINGS asks for the :doc:`initial ionisation
balance <popcha>` and the :doc:`radiation field <photsou>`.

Two modes:

- **A** (fixed radiation, variable density): specify a density range and
  step; the ionising source is held constant.
- **B** (fixed density, variable radiation): specify a radiation intensity
  range and step; the density is held constant.

Output files are ``phocv<N>.csv`` (main curves) and
``phopb<N>.csv`` (broadband fluxes).


-------------------------------------------------
Test Atom Models
-------------------------------------------------

These models operate on a single ion in isolation.  They do not compute a
full nebular model but are useful for checking atomic data, exploring line
diagnostics, and computing emissivities for theoretical comparisons.

MM — Multi-Level Ion Emissivity
=================================

``MM`` subjects a single ion to a range of temperatures and/or densities
and computes the line emissivities from the multi-level population solver.

Two calculation axes:

.. list-table::
   :header-rows: 1
   :widths: 10 90

   * - Mode
     - Description
   * - A
     - Fixed temperature, vary density
   * - B
     - Fixed density, vary temperature
   * - P
     - Fixed pressure P/k, vary density
   * - Q
     - Fixed pressure P/k, vary temperature

Three emission types are available:

- **Collisional, regular multi-level ions** — uses the full multi-level
  collisional excitation solver for the selected species.
- **Collisional, massively multi-level iron ions** — uses the extended
  iron-specific solver with up to hundreds of levels.
- **Recombination spectra** — computes recombination line emissivities for
  H, He, and He-like species.

Output is a ``.csv`` file (``ion<N>.csv``) containing the emissivity grid.

CD — Critical Densities
========================

``CD`` computes the **critical density** for two user-selected lines of a
chosen ion as a function of density at a fixed temperature.  The output
tabulates the collisional excitation and de-excitation rates alongside the
line fluxes and their ratio, making the density at which collisional
de-excitation equals radiative decay (the critical density n\ :sub:`crit`)
easy to identify.

TE — Temperature Ratios
=========================

``TE`` computes the flux ratio of three user-selected lines of a chosen ion
as a function of temperature at a fixed density.  This is the standard
method for deriving the electron temperature T\ :sub:`e` from observed line
ratios (e.g. [O III] 4363/(4959+5007)).  The output tabulates all three
line fluxes and their ratios over the specified temperature range.


-------------------------------------------------
Session Control
-------------------------------------------------

Two additional options appear in the model menu:

.. list-table::
   :header-rows: 1
   :widths: 10 90

   * - Option
     - Action
   * - R
     - **Reinitialise** — return to the start of the abundance and dust
       setup (Step 1 of :doc:`inputs`) without reloading atomic data.
       Useful for running a second model with different abundances in the
       same session.
   * - E, X, Q
     - **Exit** MAPPINGS and end the session.
