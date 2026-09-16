.. _physics_shocks:

##################################################################
Physical Processes: Shocks vs. Photoionisation Radiative Transfer
##################################################################

This page compares how radiative processes are handled in the
shockwave model (S5) versus the photoionisation models (P6/P7). It is
about the *physics and architecture* of the calculation only — for the
input parameters and setup prompts of each model type see
:doc:`models`, :doc:`code_s5`, and :doc:`code_photo`. For the shared
radiative-transfer and atomic-physics engine itself (escape
probability, ionisation balance, ...) see :doc:`physics_ionization`
and :doc:`physics_lines`, which this page does not repeat.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Overview
-------------------------------------------------

S5 and P6/P7 call the same underlying routines for local emissivity,
ionisation balance, and radiation transport: ``localem``, ``totphot2``,
``newdif2``, ``teequi2``, ``phion``, ``recom``, ``collion``, ``charex``,
``cool``, and ``multilevel``. Every elementary process described in
:doc:`physics_ionization` and :doc:`physics_lines` — photoionisation
cross sections, the escape-probability line-transfer formalism,
continuous Case A/B, the optically-thin treatment of forbidden lines —
is identical between the two model families.

What differs is the architecture *around* that engine: where the
ionising radiation originates, whether the calculation is a single
outward pass or an iterated feedback loop, how the surrounding gas
density is determined, and what "time" means for non-equilibrium
ionisation.

-------------------------------------------------
Where the ionising radiation originates
-------------------------------------------------

**P6/P7** illuminate the nebula with a single external source fixed at
the inner boundary (:doc:`photsou`). The integration marches outward
only; the upstream component of the diffuse field (see
:doc:`physics_lines`) feeds back into zones already computed nearer
that fixed source, but the source itself is never altered by the
gas's own emission.

**S5** is a superset. The hot, collisionally- and recombination-
excited post-shock gas is itself an ionising source, and its radiation
is explicitly launched in *both* directions: downstream into the
cooling zone behind the shock front, and **upstream**, ahead of the
shock, into the still-unshocked pre-shock gas. An external ambient
field can also be defined via :doc:`photsou` (stored as ``prefield``)
and is added to the shock's self-generated field — so a shock model
can be irradiated from outside *and* pre-ionise its own precursor at
the same time, a combination P6/P7 has no equivalent of.

----------------------------------------------------------
One-pass march vs. an iterated precursor feedback loop
----------------------------------------------------------

**P6/P7** perform a single outward march from the inner boundary to
the stopping condition. There is no second pass and nothing is
recomputed once a zone is finalised.

**S5** alternates between two calculations until they agree:

1. ``compsh5`` integrates the post-shock cooling zone, zone by zone,
   downstream from the shock front (see :doc:`code_s5` for the full
   step sequence).
2. ``shock5precursor`` takes the accumulated radiation field escaping
   from that cooling zone, propagates it upstream in ``UP`` mode, and
   uses it to compute the pre-ionisation state of the upstream gas.
3. The resulting precursor ionisation state (``pop_pre``) becomes the
   new pre-shock boundary condition, and ``compsh5`` runs again.
4. ``shock5check`` computes the RMS fractional change in the radiation
   field and ionisation state between global iterations; once it falls
   below 0.01% the loop exits, a few more ordinary iterations run to
   settle further, and one last pass runs with ``finalit=1`` to write
   full output. The precursor state fed forward each iteration is
   blended with the previous iteration's state using a self-tuning
   relaxation weight (Aitken Δ² dynamic relaxation) rather than being
   substituted outright — see :doc:`code_s5`, "How the precursor↔shock
   loop actually converges", for why an undamped substitution can
   settle into a non-decaying oscillation for some shocks instead of
   converging.

This two-way coupling — the cooling zone determines the precursor,
and the precursor's pre-ionised state changes the boundary condition
the cooling zone starts from — has no counterpart in P6/P7, where the
source is external and fixed by definition.

-------------------------------------------------
A known simplification in the precursor transport
-------------------------------------------------

Radiation transport within the precursor is simpler than the transport
used in the spherical photoionisation models. At each upstream step:

.. code-block:: none

   tphot(nu) = src(nu) * attcol(nu)

where ``src`` is the field at the shock face and ``attcol`` is the
Beer-Lambert photoelectric attenuation through the integrated column
(ion populations x dr, accumulated outward from the shock face).

.. admonition :: Developer Note

   **No geometrical dilution factor is applied in the precursor.** The
   ``fdilu`` function used by the spherical photoionisation models —
   W = ½(1 − √(1 − (r\ :sub:`source`/r)\ :sup:`2`)) — is present in the
   code but explicitly commented out in ``shock5precursor``. This is
   self-consistent for an idealised infinite plane-parallel shock sheet
   (a uniform emitting plane produces a constant-intensity field at any
   upstream distance, with no beam spreading), but it neglects the
   1/r\ :sup:`2` fall-off that would apply whenever the emitting
   cooling zone subtends a small solid angle as seen from the
   precursor — e.g. fast shocks with compact cooling zones, or bow
   shocks around isolated objects. In those cases the precursor's
   ionising flux, and therefore its degree of pre-ionisation at large
   upstream distances, is overestimated. See :doc:`code_s5` for the
   full note on this.

-------------------------------------------------
Density and hydrodynamics: prescribed vs. solved
-------------------------------------------------

**P6/P7** take the density structure as an *input law* — isochoric
(constant n\ :sub:`H`), isobaric (constant P/k), or a specified
functional form n(r) (see :doc:`models`). The gas has no inertia or
momentum equation; only temperature and ionisation state are solved
zone to zone against that prescribed density.

**S5** solves density, velocity, temperature, and magnetic field
self-consistently via the Rankine-Hugoniot MHD conservation equations
(``rankhug``), driven every step by the net radiative loss rate
(``flocallosses``). Radiative cooling directly compresses the
post-shock flow; that compression changes the local emissivity, which
changes the cooling rate, which changes the compression — a genuine
two-way dynamical coupling between the radiative physics and the flow
that P6/P7 does not have, since its density is never derived from a
momentum balance.

-------------------------------------------------
The clock for non-equilibrium ionisation
-------------------------------------------------

Both model families support ionisation states that are out of
equilibrium with the instantaneous temperature and radiation field,
but they measure "time" against different physical clocks:

- **P6/P7** (finite-age / post-equilibrium modes) key the ionisation
  age off the *source's* age or light-travel time — ``evoltem``
  integrates forward from an initial neutral-gas temperature using the
  elapsed time since (or until) the source switched on or off.
- **S5** keys the ionisation state off the *fluid element's* advection
  time through the flow — ``timion`` advances the ionisation balance
  by the local timestep ``dt`` set by ``fdynamictimestep`` (the
  smallest of the recombination, cooling, and photon-absorption
  timescales) as that parcel of gas moves downstream from the shock
  front.

Both ultimately call into the same rate machinery described in
:doc:`physics_ionization`; only the notion of elapsed time driving the
integration differs.

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   P6 / P7 (single external source, one-pass march)
   -------------------------------------------------
   External source (photsou)
           |
           v
   Inner boundary  -->  zone 1  -->  zone 2  -->  ...  --> stopping condition
           (density prescribed; localem + totphot2 + newdif2 each zone;
            upstream diffuse field feeds back into already-computed zones only)


   S5 (self-generated source, iterated precursor feedback loop)
   --------------------------------------------------------------
   Proto-shock gas  --(shockcmpf: Rankine-Hugoniot jump)-->  post-shock state
           |                                                       |
           |                                                       v
           |                                     compsh5: cooling-zone march
           |                                     (rankhug + timion + flocallosses,
           |                                      density SOLVED, not prescribed)
           |                                                       |
           |                                       radiation escaping upstream
           |                                                       v
           +-----------------------------------  shock5precursor: pre-ionises
                                                   upstream gas (Beer-Lambert only,
                                                   no 1/r^2 dilution)
                                                                    |
                                            updated pop_pre (new pre-shock BC)
                                                                    |
                                     shock5check: converged? --no--+
                                                |
                                               yes
                                                v
                                  final pass (finalit=1), full output

-------------------------------------------------
Comparison summary
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 25 37 38

   * - Aspect
     - P6 / P7 (photoionisation)
     - S5 (shock)
   * - Ionising source
     - External, fixed (``photsou``)
     - Self-generated by post-shock gas, plus optional external field
   * - Transfer direction
     - Single outward march
     - Downstream cooling zone + separately iterated upstream precursor
   * - Feedback between passes
     - None
     - Cooling zone <-> precursor, iterated to RMS convergence
   * - Precursor dilution
     - N/A (full ``fdilu`` used for spherical geometry in the main march)
     - Beer-Lambert only; ``fdilu`` present but disabled
   * - Density structure
     - Prescribed (isochoric / isobaric / functional)
     - Solved dynamically (Rankine-Hugoniot, ``rankhug``)
   * - Non-equilibrium clock
     - Source age / light-travel time (``evoltem``)
     - Fluid advection time (``timion``)
   * - Shared engine
     - ``localem``, ``totphot2``, ``newdif2``, ionisation balance,
       escape-probability line transfer
     - Identical routines and physics in both

.. todo :: Document the S5 magnetic-field parameterisation options and
   how the MHD terms in ``rankhug`` enter the momentum equation
   alongside the radiative loss term — currently only summarised here
   as "solved dynamically."
