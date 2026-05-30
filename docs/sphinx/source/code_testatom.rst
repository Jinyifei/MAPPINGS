.. _code_testatom:

####################################
Code Operation: Test-Atom Models
####################################

This page describes how the three test-atom models (MM, CD, TE) operate internally.
For user-facing inputs and outputs see :doc:`models` and :doc:`outputs`.  For the
broader code structure see :doc:`code_overview`.

All three models are implemented in ``src/ionemit.f``.  They isolate a single ion in
a gas of specified T and n, set its population to unity, and call the ``cool``
subroutine to evaluate collisional excitation rates and line emissivities.  There is no
ionisation balance, no radiation field, and no multi-element plasma.  The purpose is to
inspect and validate atomic data — collision strengths, Einstein A coefficients, critical
densities, and line ratios — for any of the ~170 multi-level ions in the MAPPINGS atomic
database.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
MM — Single-Ion Emission Model (``ionemit``)
-------------------------------------------------

The MM model sweeps line emissivities for one ion over a grid of temperatures,
densities, or pressures.

Setup
=====

1. **Model type** — what physical quantity varies:

   .. list-table::
      :header-rows: 1
      :widths: 10 90

      * - Code
        - Description
      * - A
        - Fixed temperature, variable density.  T is held constant; n\ :sub:`H` steps
          through a logarithmic density grid.
      * - B
        - Fixed density, variable temperature.  n\ :sub:`H` (= n\ :sub:`e`) is held
          constant; T steps through a logarithmic temperature grid.
      * - P
        - Fixed pressure P/k, variable density.  At each density step,
          T = (P/k) / n\ :sub:`H`.
      * - Q
        - Fixed pressure P/k, variable temperature.  At each temperature step,
          n\ :sub:`H` = (P/k) / T.

2. **Line type** — what atomic process to report:

   .. list-table::
      :header-rows: 1
      :widths: 10 90

      * - Code
        - Description
      * - A
        - Collisional excitation lines for any of the standard multi-level ions
          (``nfmions`` list).  All transitions are reported.
      * - B
        - Collisional excitation for the massively multi-level iron ions (``nfeions``
          list).  Two specific transitions are selected interactively by level number;
          their emissivities and ratio are reported.
      * - C
        - Recombination line emissivities.  Available for H II, He I, He II,
          C II, N II, O I, O II, and Ne II.  Only usable with temperature-varying
          model types (B or Q).

3. **Ion selection** — a numbered menu of available ions is printed; the user enters
   the index.  For line type B (iron ions), two transitions are then selected by
   specifying the lower and upper level numbers for each.

4. **Grid parameters** — depend on the model type:

   - Type A / P: minimum density, logarithmic step, number of steps.
   - Type B / Q: minimum temperature (linear or log\ :sub:`10`), log step, number of steps.
   - The fixed quantity (T or P/k or density) is entered on a preceding prompt.

5. **Run name**.

Computation
===========

Before the main loop, the transition data at the starting conditions are printed to
both the terminal and the output file: energy separations, vacuum wavelengths, collision
strengths Υ, Einstein A coefficients.

For each grid step the code:

1. Sets the ion population: ``pop(io,at) = 1.0``, all other species zeroed.
   For recombination (line type C): sets ``pop(io+1,at) = 1.0`` (the recombining ion).
2. Calls ``cool(t, de, dh)`` to evaluate collisional excitation rates and emissivities
   at the current T, n\ :sub:`H`.
3. Reads the resulting line emissivities from the ``fmbri`` (collisional) or recombination
   brightness arrays and writes one record to the output file.

For temperature-varying model types with collisional lines, the collision strengths Υ(T)
are also swept and written before the emissivity table.

Output: ``ion*.csv``.

-------------------------------------------------
CD — Critical Density Analysis (``critdens``)
-------------------------------------------------

The CD model evaluates the critical density and the density-dependent emissivity ratio
for two chosen lines of a single ion.

Setup
=====

1. **Ion selection** — same numbered menu as MM, restricted to the standard multi-level
   ion list.

2. **Line 1** and **Line 2** — each specified by lower and upper quantum level numbers.
   MAPPINGS prints the transition index, vacuum wavelength, and air wavelength for
   confirmation.

3. **Fixed temperature** T\ :sub:`e` (K).

4. **Density range** — minimum density, maximum density, logarithmic step (all as
   log\ :sub:`10`).

5. **Run name**.

Computation
===========

Before the loop, the transition data for both lines are written at the starting
conditions, including:

.. math::

   n_{\rm crit} = \frac{A_{ji}\, g_j}{k_A \, f \, \Upsilon_{ij}}

where f = 1 / √T, k\ :sub:`A` is the rate coefficient constant, and Υ\ :sub:`ij` is
the effective collision strength.

For each density step the code:

1. Sets ``pop(io,at) = 1.0`` and calls ``cool(t, de, dh)``.
2. Reads the emissivities of the two lines and computes their ratio (line 2 / line 1).
3. Records: log n\ :sub:`e`, log T, line 1 emissivity, line 2 emissivity, ratio,
   collisional excitation rate, de-excitation rate, A\ :sub:`ji`, and the fractional
   level populations for both upper levels.

Output: ``cd_<elem><ion>_*.csv``.

------------------------------------------------------------
TE — Temperature-Diagnostic Line Ratios (``tempratios``)
------------------------------------------------------------

The TE model evaluates three-line emissivity ratios as a function of temperature,
designed to reproduce the kind of auroral-to-nebular diagnostic used in nebular abundance
work (e.g. [O III] 4363 / (4959 + 5007)).

Setup
=====

1. **Ion selection** — same multi-level ion menu as MM and CD.

2. **Line 1**, **Line 2**, **Line 3** — each specified by lower and upper level numbers.
   The model computes the ratio Line 1 / (Line 2 + Line 3), so Line 1 is typically
   the temperature-sensitive (auroral) transition and Lines 2 and 3 are the stronger
   nebular transitions.

3. **Fixed density** n\ :sub:`e` (cm\ :sup:`−3`, linear).

4. **Temperature range** — minimum, maximum, and step (all as log\ :sub:`10`).

5. **Run name**.

Computation
===========

Before the loop, the critical densities of all three lines are printed at T = 10\ :sup:`4` K.

For each temperature step the code:

1. Sets ``pop(io,at) = 1.0`` and calls ``cool(t, de, dh)``.
2. Reads the emissivities of all three lines and computes the ratio
   br(1) / (br(2) + br(3)).
3. Records: log T, log n\ :sub:`e`, three emissivities, the ratio, and the
   collisional excitation rate, de-excitation rate, A\ :sub:`ji`, and level
   populations for each of the three transitions.

Output: ``te_<elem><ion>_*.csv``.
