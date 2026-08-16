.. _code_s5:

##################################
Code Operation: S5 Shock Model
##################################

This page describes how the S5 shock model operates internally.  For the
user-facing inputs and outputs see :doc:`models` and :doc:`outputs`, or
:doc:`walkthrough_s5` for a full worked example.  For the broader code
structure see :doc:`code_overview`.  For how the radiative processes used
here compare to the photoionisation models, see :doc:`physics_shocks`.

The S5 model computes a steady-state, plane-parallel, magnetised radiative
shock wave and its photo-ionised precursor.  The implementation lives in
``src/shock5.f``, which is a single file of ~4600 lines containing the
main dispatcher and all supporting subroutines.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Top-level structure
-------------------------------------------------

The entry point is ``subroutine shock5()``, which is only ~70 lines.  It
orchestrates three phases:

1. **Setup** — ``shock5setup`` collects all user input and computes the
   initial Rankine-Hugoniot jump conditions.
2. **Iteration loop** — alternates between integrating the post-shock
   cooling zone and recomputing the precursor, repeating until convergence.
3. **Final output pass** — one last run with the ``finalit`` flag set to
   write all output files at full detail.

The default minimum number of global iterations is 3.  The loop
continues until the convergence flag is set or ``mxshockits`` is reached.

-------------------------------------------------
Phase 1 — Setup (``shock5setup``)
-------------------------------------------------

``shock5setup`` is the longest routine (~1000 lines).  It handles all
user interaction and prepares the initial conditions.

1. Calls :doc:`popcha` — the user sets the initial ionisation balance
   of the upstream (proto-shock) gas.  The result is copied into four
   population arrays: ``pop_neu`` (neutral/proto-shock), ``pop_pre``
   (precursor), and their saved copies ``pop0`` and ``pop_pre0``.
2. Calls :doc:`photsou` — the user defines any ambient radiation field
   (can be set to zero for a pure shock).  The field is stored as
   ``prefield`` and added to the shock's own radiation in later steps.
3. Prompts for the shock parameters in order:

   - Shock jump type: velocity ``V`` (most common) or post-shock
     temperature ``T``
   - Magnetic field parameterisation: ``B``, ``A``, ``M``, ``C``, or
     ``R`` (see :doc:`models`)
   - Pre-shock velocity and hydrogen density (or pre- and post-shock
     temperature for ``T`` mode)
   - Diffuse field mode: full or zeroed
   - Stopping condition and limit value
   - Minimum number of iterations
   - Output file prefix and which optional output tables to write

4. Calls ``shockcmpf`` — applies the **Rankine-Hugoniot jump
   conditions** to compute the immediate post-shock state (T\ :sub:`1`,
   n\ :sub:`1`, v\ :sub:`1`, B\ :sub:`1`) from the pre-shock state.
   This becomes the starting point for the cooling zone integration.
5. Calls ``shocksummary`` to print the pre- and post-shock state to
   the terminal and output files.

-------------------------------------------------
Phase 2a — Cooling zone integration (``compsh5``)
-------------------------------------------------

``compsh5`` integrates the post-shock cooling zone zone by zone,
marching downstream (away from the shock front).  Before the main loop
it writes three header rows to the output file recording the proto-shock
state (step −2), the precursor state (step −1), and the immediate
post-shock state (step 0).

The main step loop then advances from step 1 onward.  Each step:

Step 1 — Save initial state
============================

The temperature, density, ionisation populations (``pop0``), distance,
velocity, and magnetic field at the start of the step are saved.  These
will be used to restart the step if needed.

Step 2 — Choose the timestep
==============================

``fdynamictimestep`` returns the smallest of the atomic recombination
timescale, the cooling timescale, and the photon absorption timescale.
This is then multiplied by a scale factor (0.04 × step²) that ramps up
slowly for the first five steps, preventing instabilities immediately
behind the shock front, before reaching the full adaptive step size.

Step 3 — Half-step predictor
==============================

A half-step (``hdt = dt/2``) is taken to obtain mid-step estimates:

- ``timion`` advances the ionisation balance by ``hdt`` at the initial
  temperature.
- ``rankhug`` integrates the MHD flow equations (Rankine-Hugoniot in
  differential form) by ``hdt`` to get a mid-step temperature.

Step 4 — Full-step corrector
==============================

The mid-step net cooling rate is evaluated with ``flocallosses`` using
the improved mid-step ionisation state.  Then:

- ``rankhug`` integrates the full flow step ``dt`` from the start of
  the step using the mid-point loss rate (a second-order
  predictor-corrector scheme).
- ``timion`` advances the ionisation balance over the full ``dt`` at
  the mean temperature of the step.

Step 5 — Record the step
=========================

Start and end values are averaged to give zone-centred quantities:
temperature ``te``, electron density ``deel``, hydrogen density ``dhy``,
magnetic field ``bmg``, flow velocity ``veloc``.  Cumulative distance
``dist`` and elapsed time ``timlps`` are updated.

Structural markers are recorded at the distances where the temperature
passes through 10\ :sup:`7`, 10\ :sup:`6`, 10\ :sup:`5`, …, 10\ :sup:`2` K.

If ``finalit`` is set, the step is written to the main structure file
(``.sh5``) and to any optional output tables (rates, dynamics, cooling,
ion fractions, line monitor) that were selected at setup.

Step 6 — Check stopping condition
===================================

The user-chosen stopping criterion is tested:

- ``A`` — 1% weighted ionisation fraction (default)
- ``B`` — specific ion fraction below a threshold
- ``C`` or ``S`` — temperature below a limit (``S`` also requires >95%
  neutral)
- ``D`` — distance limit reached
- ``E`` — elapsed time limit reached
- ``F`` — thermal balance reached
- ``G`` — heating limit

When the condition is met the loop exits and the emission spectrum,
line fluxes, and other integrated quantities are assembled and written.

Key physics routines called each step
======================================

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Routine
     - Role
   * - ``rankhug``
     - Solves the Rankine-Hugoniot MHD conservation equations in
       differential form; advances T, ρ, v, B given the net cooling rate.
   * - ``timion``
     - Time-dependent multi-species ionisation balance solver; evolves
       all ion fractions over a timestep at a given temperature and density.
   * - ``flocallosses``
     - Net cooling rate = total radiative losses − photoionisation
       heating − all other heating terms.
   * - ``localem`` / ``totphot2``
     - Compute the local emissivity and the radiation field at the
       current position; ``totphot2`` propagates photons in the
       downstream (``DW``) direction.
   * - ``averinto``
     - Averages start and end ionisation populations to give the
       zone-centred mean.


-------------------------------------------------------
Phase 2b — Precursor computation (``shock5precursor``)
-------------------------------------------------------

After each cooling-zone integration, ``shock5precursor`` computes the
**photo-ionised precursor** — the upstream gas that is pre-ionised by
UV and X-ray radiation escaping forward from the shock.

1. Takes the accumulated downstream radiation field from ``compsh5``
   and calls ``totphot2`` in upstream (``UP``) mode to propagate it
   into the neutral pre-shock gas.  A factor of 0.5 is applied to the
   source field to account for the half-space geometry: only half the
   photons leaving the shock face travel in the upstream direction.
2. Computes the **precursor parameter** ψ = Q(ions) / v\ :sub:`shock`
   — the ratio of the ionising photon flux to the shock velocity.
   ψ ≫ 1 indicates a fully radiation-dominated precursor; ψ < 1
   means only partial pre-ionisation.
3. Integrates the precursor zone, evolving the ionisation state of the
   upstream gas step by step using the same ``timion`` + ``rankhug``
   machinery as the cooling zone.
4. Updates ``pop_pre`` (the precursor ionisation balance) and the
   precursor thermodynamic state (``te_pre``, ``de_pre``, ``dh_pre``,
   ``bm_pre``), which become the new pre-shock boundary condition for
   the next ``compsh5`` call.

The convergence tolerance ``rmslimit`` is set loosely (5%) on early
iterations and tightened to 0.05% on the final pass.

.. note::

   **Radiation transport in the precursor: absorption only.**
   Within the precursor zone the radiation field at each upstream step
   is computed as:

   .. code-block:: none

      tphot(ν) = src(ν) × attcol(ν)

   where ``src`` is the field at the shock face and ``attcol`` is the
   Beer-Lambert photoelectric attenuation through the integrated column
   ``popintfr`` (ion populations × dr, accumulated from the shock face
   outward).  **No geometrical dilution factor is applied.**  The
   ``fdilu`` function, which computes the proper dilution factor
   W = ½(1 − √(1 − (r\ :sub:`source`/r)\ :sup:`2`)) and is used by
   the photoionisation models for spherical geometry, is present in the
   code but explicitly commented out in ``shock5precursor``.

   The plane-parallel shock geometry makes this self-consistent for an
   infinite planar shock sweeping through uniform gas: in that limit a
   uniform emitting sheet produces a constant-intensity field at all
   upstream distances and there is no beam spreading.  However,
   geometrical dilution can be significant in practice.  When the
   emitting region (the cooling zone) subtends a small solid angle as
   seen from a distant precursor zone — for instance in fast shocks
   with compact cooling zones, or when modelling the bow shock around
   an isolated object — the 1/r\ :sup:`2` fall-off of the radiation
   field is neglected.  This leads to an overestimate of the ionising
   flux reaching the outer precursor, and therefore an overestimate of
   the degree of pre-ionisation at large upstream distances.

-------------------------------------------------
Phase 2c — Convergence check (``shock5check``)
-------------------------------------------------

After each ``shock5precursor`` + ``compsh5`` pair, ``shock5check``
computes the RMS fractional change in the radiation field and ionisation
state relative to the previous iteration.  If the change is within
``rmslimit`` the flag ``converged`` is set, which exits the iteration
loop.  Otherwise another iteration begins.

When the loop exits, one final pass runs with ``finalit=1`` so that all
output tables are written at the tightened tolerance.

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   proto-shock gas (pop_neu, T, nH, v, B)
           |
           | shock5setup: shockcmpf (Rankine-Hugoniot jump)
           v
   post-shock state (T1, n1, v1, B1)
           |
           | compsh5: step-by-step cooling zone integration
           |   each step:
           |     rankhug  (MHD flow)
           |     timion   (ionisation balance)
           |     flocallosses (net cooling)
           v
   shock structure + emission spectrum
           |
           | radiation field escaping upstream
           v
   shock5precursor: ionises upstream gas
           |
           v
   updated pop_pre → new pre-shock state
           |
           +----( iterate until converged )----+
           |
           v
   final pass (finalit=1) → write all output files
