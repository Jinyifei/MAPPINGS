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
5. Define the **model stopping condition** — inner and outer radius, column
   density, ionisation fraction, or temperature limit.

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
6. Choose the **output file prefix** (up to 8 characters, e.g. ``v100s``).
7. Select which optional output tables to write (rates, dynamics, ion
   fractions, individual element files, line lists, bands, cooling).

Output files use the ``.sh5`` and ``.csv`` extensions as described in
:doc:`outputs`.  For a full worked example — an actual script, the files
it produces, and what is inside them, including position-resolved line
monitoring — see :doc:`walkthrough_s5`.


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
