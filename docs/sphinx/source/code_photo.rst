.. _code_photo:

##################################################
Code Operation: P6 / P7 Photoionisation Models
##################################################

This page describes how the P6 and P7 photoionisation models operate
internally.  For the user-facing inputs and outputs see :doc:`models`
and :doc:`outputs`, or :doc:`walkthrough_p6` for a full worked example.
For the broader code structure see :doc:`code_overview`.  For how the
radiative processes used here compare to the shock model, see
:doc:`physics_shocks`.

P6 and P7 are structurally identical — they share the same setup
sequence and the same zone-stepping algorithm.  The only differences are:

- P6 uses ``p6blocks.inc`` and writes ``.ph6`` output; P7 uses
  ``p7blocks.inc`` and writes ``.ph7`` output.
- P7 exposes additional output options and is the recommended mode for
  automated batch calculations.

The implementation lives in ``src/photo6.f`` (~3940 lines) and
``src/photo7.f`` (~4190 lines).  The descriptions below apply equally
to both unless noted.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Overview
-------------------------------------------------

The photoionisation models compute a stratified, multi-zone nebula
illuminated by a central ionising source.  The calculation marches
outward from an inner boundary, solving at each zone for the local
radiation field, ionisation balance, and temperature before stepping to
the next zone.  There is no iteration between zones — each zone
advances one direction only (the "outward-only" scheme).  The diffuse
radiation field emitted by the gas itself is accumulated and carried
forward as the integration proceeds.

-------------------------------------------------
Phase 1 — Setup (``photo6`` / ``photo7``)
-------------------------------------------------

The setup routine handles all user interaction before calling
``compph6`` / ``compph7``.  The prompts appear in this order:

1. **Initial ionisation balance** — :doc:`popcha`.

2. **Radiation field** — :doc:`photsou`.  After the field is defined,
   ``srcsummary`` prints a summary of the ionising photon fluxes.

3. **Geometry** — spherical (``S``) or plane-parallel (``P``).

   - *Plane-parallel*: the user also chooses the transfer mode —
     two-sided outward-only (``T``, default, symmetric slab) or
     one-sided (``O``, suitable for precursor models).

   - *Spherical*: the source size is specified as a radius (``R``),
     bolometric or ionising luminosity (``L``), or total ionising photon
     rate (``P``).  MAPPINGS then estimates the Strömgren radius for H
     and He and prints ionisation parameters Q(H), Q(N), U(H), U(N) at
     the inner and volume-averaged radii.  The inner radius of the model
     (``remp``) is then set as a distance, ionisation parameter U(H) or
     U(N), photon flux Q(H) or Q(N), or as a fraction of the Strömgren
     radius.

4. **Thermal structure** *(expert mode only)* — self-consistent (``S``,
   recommended) or isothermal at a fixed T\ :sub:`e` (``T``).

5. **Density structure** — three options:

   .. list-table::
      :header-rows: 1
      :widths: 10 90

      * - Code
        - Description
      * - C
        - Isochoric: constant hydrogen density n\ :sub:`H` throughout.
          The user gives n\ :sub:`H` directly.
      * - B
        - Isobaric: constant total pressure P/k.  The user gives P/k
          and an initial temperature estimate (used to convert P/k to an
          approximate starting density; the actual density adjusts
          zone by zone as T changes).
      * - F
        - Functional form n(r) = n\ :sub:`0`\ [f\ :sub:`x`\ exp((r−a)/r\ :sub:`0`) +
          f\ :sub:`p`\ (r/a)\ :sup:`b`] + c.  Seven parameters are read
          on one line.

6. **Filling factor** f (0 < f ≤ 1) — the volume fraction actually
   occupied by the emitting gas.

7. **Ionisation balance mode** — three options controlling whether the
   ionisation state at each zone is solved in time-dependent or
   equilibrium fashion:

   .. list-table::
      :header-rows: 1
      :widths: 10 90

      * - Mode
        - Description
      * - E
        - Equilibrium: both ionisation balance and temperature are
          iterated to convergence at every zone.
      * - F
        - Finite source lifetime: the source has been on for a time
          ``telap`` and will remain on for a total lifetime ``tlife``.
          The ionisation age at each zone is computed from the light
          travel time.  Requires an initial neutral-gas temperature.
      * - P
        - Post-equilibrium decay: the source has been switched off for
          a time ``telap`` and retains a fractional final luminosity
          ``frlum``.  The recombining ionisation state is integrated
          forward in time at each zone.

8. **Zone width control** — the photon absorption fraction ``dtau0``
   (default 0.025).  Zone widths are chosen adaptively so that the
   radiation field changes by at most this fraction per step.

9. **Stopping condition** — when to terminate the outward march.  This
   step shares one menu across P6, P7 and (with the same letters)
   ``jend`` in :doc:`code_s5`, though the underlying quantities tested
   differ between the photoionisation and shock codes.  Two further
   letters, ``R`` and ``G``, appear in the same menu but are not
   ending conditions — ``R`` reinitialises the whole model setup and
   ``G`` resets only the geometry, both letting the user back out of
   this menu rather than choosing a stopping criterion:

   .. list-table::
      :header-rows: 1
      :widths: 8 35 57

      * - Code
        - Ends the model when...
        - What you're asked next
      * - A
        - H\ :sup:`+` fraction falls below a threshold (default 1%,
          shown inline in the menu as the current ``fren``)
        - Nothing — goes straight to output setup (step 10).
      * - B
        - a specified ion of a specified element falls below a given
          fraction
        - ``Applies to element (Atomic number):`` then ``Give the
          final ionisation fraction of <elem> :`` — two separate
          prompts, atomic number first.
      * - C
        - T\ :sub:`e` falls below a minimum
        - ``Give the final temperature (<10 as log):`` — despite the
          prompt text, no log\ :sub:`10` conversion is actually
          applied in the source (``photo6.f``/``photo7.f``); the
          value is only checked to be ≥ 1 and then used directly as
          Kelvin.  Entering a value under 10 intending it as a
          log\ :sub:`10` temperature will set the ending temperature
          to that literal (very low) Kelvin value instead — this
          looks like a latent bug against the prompt's own claim, not
          documented intended behaviour.
      * - D
        - accumulated optical depth exceeds a threshold
        - ``Applies to element (Atomic number):`` then ``Give the
          final optical depth at threshold of <elem>:`` — no log
          conversion; must be a positive number.
      * - E
        - the model reaches a fixed distance from the inner edge
        - ``Give the distance or radius at which the density
          drops:`` — a value ≥ 1e6 is taken as an absolute distance
          in cm from the inner edge; a value < 1e6 is instead taken
          as a **fraction of the Strömgren radius** and scaled
          accordingly.
      * - F
        - the column density of a specific atom and ion reaches a
          limit
        - ``Give the final column density (<100 as log):`` (values
          under 100 genuinely are read as log\ :sub:`10` and
          converted here, unlike ``C``), then ``Applies to element
          (Atomic number):`` then ``Applies to ion stage :``.
      * - H
        - the total hydrogen column density reaches a limit
        - ``Give the total H column density (<100 as log):`` — same
          genuine log\ :sub:`10` conversion as ``F``.

   Whichever letter is chosen, the next prompt after this step (or
   its follow-up, if any) is always output file setup (step 10).

   Two further conditions can end a model regardless of the chosen
   letter, tested every step alongside it: a hard cap at zone
   ``mma = mxnsteps-1`` (the same 4096-zone constant used by S5,
   ``photo6.f:1401,2873``), and a file literally named ``terminate``
   in the run directory (``photo6.f:2823-2825``).  A third,
   letter-independent condition is always checked too: the model ends
   once the normalised electron density falls to within
   ``exla`` (5×10⁻⁵, a fixed constant) of its floor
   (``photo6.f:2820``) — an automatic near-full-recombination safety
   net with no direct S5 analogue.

   Consequence for ``D``, ``E``, ``F``, and ``H``: the ``exla``
   recombination floor is checked on every step regardless of
   ``jend``, and — unlike S5's temperature floor, which some shocks
   never reach — is very likely to actually be satisfied eventually in
   a normal photoionised nebula, since it's just a looser version of
   ``A``'s own 1% ionisation test.  So setting ``tauen``, ``diend``, or
   ``colend`` beyond what the model ever physically reaches doesn't
   produce an unbounded run: the model still ends, via ``exla`` (or,
   failing that, the 4096-zone cap), with the chosen letter's own
   condition never having been satisfied.  This isn't true for
   every quantity individually — ``H``'s total H column, for instance,
   keeps growing with distance into neutral gas rather than
   saturating — but the loop itself always stops regardless.

10. **Output file prefix and options** — ``p6filenames`` /
    ``p7filenames`` sets up the output file names; ``createp6files`` /
    ``createp7files`` opens them; ``p6headers`` / ``p7headers`` writes
    the file headers.

11. **``compph6`` / ``compph7`` is called** to run the model.

-------------------------------------------------------------------
Phase 2 — Zone-stepping integration (``compph6`` / ``compph7``)
-------------------------------------------------------------------

``compph6`` and ``compph7`` implement the same outward-only integration
algorithm.  The loop advances zone by zone from the inner boundary
(``remp``) outward until the stopping condition is met.

Initial boundary setup
======================

Before the main loop, the inner boundary conditions are established:

1. The radiation field at the inner boundary is computed with
   ``localem`` + ``totphot2``.
2. For isobaric models, the inner density and radius are iterated
   until the pressure and ionisation parameter are self-consistent
   (up to 5 iterations, converging when Δn\ :sub:`H`/n\ :sub:`H` <
   ``dhlma``).
3. For equilibrium mode (``E``), ``teequi2`` is called to solve the
   first zone to thermal and ionisation equilibrium.  For time-dependent
   modes (``F``/``P``), ``evoltem`` evolves the temperature and
   ``equion`` estimates the ionisation state using the local light
   travel time as the ionisation age.

Main step loop — each zone
===========================

For each zone the following sequence runs.  Because the end-of-zone
conditions depend on the solution itself, an inner iteration loop
(typically 3–10 cycles) runs until convergence.

**Step 1 — Predict end-of-zone conditions.**
  The temperature at the far edge of the zone (``te1``) is extrapolated
  from the previous two steps.  For isobaric or functional density
  profiles the corresponding density (``dh1``) is computed from the
  pressure or density function.

**Step 2 — Set the zone width (``dr``).**
  ``absdis2`` computes the zone width such that the photon mean free
  path spans a fraction ``dtau0`` of the optical depth.  For spherical
  geometry the zone is widened slightly to account for the divergence
  of the beam.

**Step 3 — Compute the radiation field.**
  ``localem`` evaluates the local continuum and line emissivities at
  the mean zone temperature and density.  ``totphot2`` then propagates
  the radiation field across the zone in the outward-only ("DW"
  downstream) direction, accumulating the diffuse nebular emission into
  the total field ``tphot``.  ``intjnu`` integrates the mean intensity
  over frequency to obtain the ionising photon rates for H, He I, He II,
  and all tracked metals.

**Step 4 — Solve ionisation and temperature at the far edge.**
  Depending on the mode:

  - *Equilibrium (E)*: ``teequi2`` iterates the ionisation balance and
    temperature simultaneously until both converge.  The iteration
    alternates between solving the multi-level ionisation network at the
    current T and solving the thermal balance equation at the current
    ionisation state.

  - *Finite age / post-equilibrium (F/P)*: the local ionisation age is
    computed from the light travel time and the ionisation-front
    velocity.  If the age is long enough, ``teequi2`` is called as for
    equilibrium mode.  If the age is short, ``evoltem`` integrates the
    temperature forward in time from the initial neutral-gas temperature.

**Step 5 — Check convergence.**
  Four convergence measures are computed:

  - ``difend``: RMS fractional change in the ionic populations at the
    far zone edge relative to the previous iteration, normalised by
    ``difma`` (default 5%).
  - ``difpre``: same measure at the near zone edge.
  - ``difde``: fractional change in electron density, normalised by
    ``dhlma`` (default 5%).
  - ``difte``: fractional change in temperature, normalised by
    ``dtlma`` (default 10%).

  The overall convergence indicator ``difg`` is the maximum of these
  four.  If ``difg > 1`` the iteration repeats from Step 1 with the
  updated end-of-zone estimates.

**Step 6 — Record the zone and advance.**
  Once converged, the zone-averaged quantities are accumulated into the
  integrated emission spectrum and output arrays.  If writing is
  enabled, the zone structure (T, n\ :sub:`e`, n\ :sub:`H`, ionisation
  fractions, radiation field) is written to the main output file.

  The quantities the ending conditions compare against are also
  updated here, and mean different things depending on geometry:

  - ``dis1`` (cm) is what the ``E`` condition tests against
    ``diend``.  For spherical geometry it's the absolute radius from
    the source (``rad0`` starts at ``remp`` and accumulates ``dr``
    each zone, then ``dis1 = rad1``, ``photo6.f:1626-1627,1927-1928``);
    for plane-parallel geometry it's cumulative depth into the slab,
    starting at ``remp`` (``photo6.f:1631-1637,1938``).  Either way,
    ``diend`` is itself offset by ``remp`` at setup
    (``diend = remp + diend``, ``photo6.f:1049``), so the comparison
    always means "distance travelled outward from the inner edge",
    regardless of which geometry sets ``dis1``'s baseline differently.
  - ``taux`` (dimensionless), what the ``D`` condition tests against
    ``tauen``, is the optical depth **at the photoionisation threshold
    energy of the specific ion chosen at setup** —
    ``taux = sigpho(n) * popint(jpoen,ielen)`` (cross-section in
    cm² times that ion's integrated column density in cm⁻²,
    ``photo6.f:2790-2792``) — not a bolometric or line-centre optical
    depth.
  - ``popint(jpoen,ielen)`` / ``popinttot`` (cm⁻²), what ``F`` and
    ``H`` test against ``colend``, are integrated column densities:
    ``F`` uses a specific element/ion's column (or their sum, if
    ``jpoen`` was set beyond the element's highest ion stage), ``H``
    always sums neutral + singly-ionised hydrogen
    (``popint(1,1)+popint(2,1)``, ``photo6.f:2793-2809``).

**Step 7 — Check the stopping condition.**
  The stopping criterion chosen at setup is evaluated, along with the
  hard zone cap, the ``terminate`` poll file, and the ``exla``
  recombination floor — see the full list under "Stopping condition"
  in Phase 1 above.  If any is met, the integration ends.  Otherwise
  the outer boundary of the current zone becomes the inner boundary of
  the next and the loop repeats.

-------------------------------------------------
Key physics routines
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Routine
     - Role
   * - ``teequi2``
     - Core equilibrium solver.  Iterates ionisation balance and electron
       temperature simultaneously to convergence using the local radiation
       field.
   * - ``equion``
     - Equilibrium ionisation balance at a fixed temperature.  Used to
       provide a mid-zone estimate of the ionisation state.
   * - ``evoltem``
     - Time-dependent temperature evolution for finite-age models.
       Integrates the energy equation forward from the neutral initial
       temperature using the local heating and cooling rates.
   * - ``totphot2``
     - Radiation field propagation.  Adds local emissivity to the
       accumulated field and attenuates by photoelectric absorption
       across the zone.  Called in downstream (``DW``) mode for the
       main integration and in source-only (``SO``) mode to estimate
       the optical depth for zone-width selection.
   * - ``localem``
     - Computes the local continuum and line emissivities (free-free,
       free-bound, two-photon, dust, line) at the current T, n.
   * - ``absdis2``
     - Computes the zone width ``dr`` such that the integrated optical
       depth equals ``dtau0``.
   * - ``intjnu``
     - Integrates the local mean intensity J\ :sub:`ν` over the photon
       grid to give the H, He I, He II and total ionising photon rates.
   * - ``zetaeff``
     - Computes the effective recombination parameter ζ taking into
       account the diffuse field contribution.
   * - ``averinto``
     - Averages the near- and far-edge ionisation populations to give
       a zone-centred mean, weighted by the geometry factor ``rww``
       (closer to the far edge for spherical geometry).
   * - ``fradpress``
     - Radiation pressure integral across the zone; added to the gas
       pressure in isobaric models.

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   Inner boundary (remp, Te_inner, nH, pop0)
           |
           | Initial radiation field: localem + totphot2
           | Initial equilibrium: teequi2 (or evoltem for F/P)
           v
   Zone 1 start conditions
           |
           | For each zone:
           |   absdis2     → zone width dr from optical depth criterion
           |   equion      → mid-zone ionisation estimate
           |   totphot2    → propagate radiation field outward (DW mode)
           |   intjnu      → ionising photon rates
           |   teequi2     → equilibrium T and ionisation at far edge
           |     (or evoltem for finite-age / post-equilibrium modes)
           |   difhhe      → check convergence; repeat if needed
           |   averinto    → zone-centred populations
           |   localem + totphot2 → zone emissivity + radiation update
           |   write zone structure to .ph6 / .ph7
           |   check stopping condition
           v
   Next zone ... until stopping condition met
           |
           v
   Assemble integrated spectrum, line list, broadband fluxes
   Write to .csv, .lam, .nfn, .sou files (plus .bln, the separate
   ionisation-balance table — see :doc:`outputs`)

-------------------------------------------------
P6 vs P7 differences
-------------------------------------------------

Beyond the output file extension and common-block file, P7 offers
additional output options not present in P6:

- Aperture-integrated spectra (projected slit or circular aperture)
- Per-zone spectral energy distributions
- Extended line lists with all tracked transitions
- A scripting-friendly output format suited to automated grid runs

In all other respects — setup prompts, zone-stepping algorithm,
physics routines, and stopping conditions — P6 and P7 are identical.
