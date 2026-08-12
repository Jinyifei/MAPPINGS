.. _physics_time_integration:

##################################################################
Physical Processes: Non-Equilibrium Time Integration
##################################################################

This page describes the numerical machinery that advances ionic
populations by a finite time step — the mechanics of *how* a
non-equilibrium ionisation state is integrated forward, as distinct
from *which* rate processes compete (:doc:`physics_ionization`) or
*which* solver calls this machinery and why (:doc:`physics_heating_cooling`,
:doc:`physics_shocks`).

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Overview
-------------------------------------------------

Ionisation kinetics are numerically stiff: recombination and
photoionisation timescales can differ from the dynamical timestep by
orders of magnitude, so naively stepping the rate equations with a
generic small-step numerical integrator would be slow and
unstable. MAPPINGS instead uses two **closed-form (semi-)analytic**
solutions, advanced directly by a finite ``tstep``, rather than a
generic ODE stepper:

- **``sdifeq``** — an exact, closed-form solution for the two-level
  (H⁺/H⁰-like) case, used for hydrogen and helium.
- **``ionab``** — a matrix-exponential solution for the general
  multi-stage ionisation ladder of heavier elements, following
  **Luc Binette's PhD thesis (ANU, 1982)**.

Both are driven, per zone, from ``timion``, which is what
:doc:`physics_heating_cooling`'s ``evoltem`` and the shock models'
per-step loop (:doc:`physics_shocks`) actually call to advance the
ionisation state over an elapsed time.

-------------------------------------------------
Hydrogen and helium: ``iohyd`` and ``sdifeq``
-------------------------------------------------

``iohyd.f`` is the hydrogen-specific time-integration driver. After
refreshing the rates (``allrates``), it sets up the coefficients of a
Riccati-type differential equation for the ionised fraction and calls
``sdifeq`` twice — once for H⁺, once for H⁰:

.. code-block:: none

   df/dt = a*f^2 + b*f + c

``sdifeq(a, b, c, fr, tstep)`` solves this **analytically** rather than
by stepping: it computes the discriminant, branches on its sign and on
degenerate cases (``a`` or ``b`` zero), and returns the exact fraction
``fr`` after time ``tstep`` in closed form. This is exact for a fixed
(frozen) set of rate coefficients over the step, not an approximation
from finite differencing — the only approximation is that the rates
themselves are held constant across the step, matching the assumption
that physical conditions do not change during the step (the same
assumption ``ionab`` makes below).

-------------------------------------------------
Heavier elements: ``iobal`` and ``ionab``
-------------------------------------------------

For elements with more than two ionisation stages, the ionic-abundance
vector **n** for a given element evolves as a linear system,

.. code-block:: none

   dn/dt = R n

where **R** is the matrix of rates per ion per second connecting all
ionisation stages (including multi-electron/Auger jumps). Formally,

.. code-block:: none

   n(t) = exp(R t) n(0)

but the direct Taylor series for ``exp(Rt)`` does not converge well
for the values of ``t`` used in a zone-stepping model. ``ionab.f``
(:doc:`physics_ionization`'s ``iobal`` is the driver that calls it)
resolves this the way Binette's thesis describes: choose a small
sub-step δ = t/m such that every element of **O** = **R**δ is less
than one (guaranteeing rapid convergence of the truncated series for
``exp(O)``), then obtain ``exp(Rt) = (exp(O))^m`` not by m sequential
multiplications but by **repeated squaring** — computing
``T = exp(O)`` once and then forming ``T^m`` via a chain of
``T^(2^l)`` squarings, following the semigroup identity
``U^l = T^(kl) = T^m``. This turns an O(m) matrix-multiplication cost
into O(log m), which is what makes a per-zone, per-timestep matrix
exponential practical at all.

-------------------------------------------------
The dispatcher: ``timion``
-------------------------------------------------

``timion(t, de, dh, fhiif, tstep)`` is the routine actually called by
the time-dependent temperature/ionisation solvers
(:doc:`physics_heating_cooling`'s ``evoltem``, and the shock models'
per-step loop in :doc:`physics_shocks`). It calls ``iohyd`` for
hydrogen and ``iobal`` (which calls ``ionab``) for every other element,
then ``copypop``/``difpop`` (below) to finalise and characterise the
step.

-------------------------------------------------
Population bookkeeping and convergence metrics
-------------------------------------------------

``poputil.f`` is a small utility library for the ionic-population
arrays (``pop(6,11)``) shared by every routine above: ``copypop``,
``addpop``, ``clearpop``, ``scalepop``, and the step-indexed
``copysteppop``/``copypopstep`` variants used by the shock models'
multi-step arrays. Two routines from this file are worth calling out
specifically because they are the actual implementation behind
convergence measures named elsewhere:

- **``averinto``** — averages the near- and far-edge populations of a
  zone into a zone-centred mean (already named as a key routine in
  :doc:`code_photo`).
- **``difpop``**/**``difhhe``** — compute the mean absolute change in
  log₁₀(ionic population) between two population snapshots (above a
  threshold, and tracking which single ion changed the most). This is
  precisely what :doc:`code_photo`'s convergence measures ``difend``
  and ``difpre`` are built from — this page is where that RMS
  fractional-change number actually comes from.

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   timion(t, de, dh, fhiif, tstep)
           |
           |  iohyd  -> sdifeq (H+)   -> exact closed-form fraction
           |          -> sdifeq (H0)     after tstep, rates frozen
           |
           |  iobal  -> ionab (per heavy element)
           |            -> dn/dt = R n solved via exp(Rt), computed
           |               by repeated squaring of exp(R * t/m)
           v
   Updated ionic populations pop(6,11)
           |
           |  copypop / averinto  -> zone-centred populations
           |  difpop / difhhe     -> convergence metrics
           |                         (difend/difpre in physics_heating_cooling
           |                          and code_photo's zone-stepping loop)
           v
   Feeds back into cool.f (physics_heating_cooling) and the next
   zone's photon-budget calculation (physics_ionization)

-------------------------------------------------
Key routines
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Routine
     - Role
   * - ``timion``
     - Per-zone dispatcher: advances H (``iohyd``) and every heavier
       element (``iobal``) over a time step.
   * - ``iohyd``
     - Hydrogen-specific driver; sets up and calls ``sdifeq``.
   * - ``sdifeq``
     - Exact closed-form solution of the two-level Riccati ionisation
       equation.
   * - ``iobal``
     - General multi-element time-dependent (or equilibrium) ionic
       balance driver; documented in :doc:`physics_ionization`.
   * - ``ionab``
     - Matrix-exponential solution for a heavy element's full
       ionisation ladder (Binette 1982), via repeated squaring.
   * - ``averinto``
     - Zone-centred averaging of near-/far-edge populations.
   * - ``difpop`` / ``difhhe``
     - Convergence metrics: mean/maximum log-population change between
       two population snapshots.

.. todo :: Confirm and document the exact relationship between
   ``difpop``'s output and the ``difend``/``difpre`` convergence
   thresholds (``difma``) described procedurally in :doc:`code_photo`.
