.. _physics_overview:

#############################
Physical Processes: Overview
#############################

The :doc:`code_overview` section and its sub-pages describe how each
model type (``code_photo``, ``code_s5``, ...) drives the calculation —
the setup prompts, the zone-stepping loop, convergence checks. This
section instead cuts across model types and describes the **physics**
those loops call into: the atomic and radiative processes that
determine the ionisation state, temperature, and emergent spectrum of
the gas at each zone. The same routines described here are used by
P6/P7, S5, and the single-zone models alike.

.. contents:: Contents
   :local:
   :depth: 1

-------------------------------------------------
Pages in this section
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Topic
     - Page
   * - Ionisation balance (photoionisation, collisional ionisation,
       charge exchange, recombination, secondary/cosmic-ray ionisation)
     - :doc:`physics_ionization`
   * - Line formation and radiative transfer (optically thin vs.
       radiatively trapped lines, escape probability, Case A/B)
     - :doc:`physics_lines`
   * - Shocks vs. photoionisation radiative transfer (shared engine,
       precursor feedback loop, prescribed vs. solved density)
     - :doc:`physics_shocks`
   * - Output spectra and line fluxes (volume-integrated line totals
       vs. the transported continuum field)
     - :doc:`physics_output_spectra`
   * - Dust and PAH physics (grain charging/heating, PAH heating,
       grain temperature and IR re-emission, dynamic destruction)
     - :doc:`physics_dust`
   * - Heating, cooling, and thermal balance (every heating/cooling
       channel, the equilibrium and time-dependent T solvers)
     - :doc:`physics_heating_cooling`
   * - Continuum diffuse-field emission (free-free, free-bound,
       two-photon)
     - :doc:`physics_continuum`
   * - Non-equilibrium time integration (the closed-form/matrix-
       exponential solvers behind ``timion``)
     - :doc:`physics_time_integration`

All topics identified in the original physical-processes survey are
now documented. Non-Maxwellian κ electron distributions are covered
separately in :doc:`adv_kappa`; smaller open items are tracked as
``.. todo::`` notes on their respective pages rather than here.

-------------------------------------------------
How these pages relate to the source
-------------------------------------------------

Each page below is organised by physical process, not by subroutine,
but every process description names the source file(s) that implement
it so the two can be cross-referenced. As in :doc:`code_overview`, all
shared state is carried in the Fortran ``COMMON`` blocks declared in
``cblocks.inc`` and friends — the routines described here read and
write those arrays directly rather than passing everything through
call arguments.
