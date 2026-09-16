.. _physics_lines:

###########################################################
Physical Processes: Line Formation and Radiative Transfer
###########################################################

This page describes how MAPPINGS handles emission lines from a
radiative-transfer perspective: how the diffuse field is propagated
zone to zone, and why forbidden lines and resonance lines are treated
completely differently. See :doc:`physics_overview` for context and
:doc:`physics_ionization` for how the ionic populations that feed these
line emissivities are computed.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Overview
-------------------------------------------------

MAPPINGS does not perform full angle-dependent line transfer. It uses
a **zone-stepping, two-stream (upstream/downstream) escape-probability
scheme**, consistent with the "outward-only" integration described in
:doc:`code_photo`. At each zone, the diffuse radiation field — both
continuum and lines — is carried in two vectors:

- **downstream** (``dwdif``), propagating outward, away from the source
- **upstream** (``updif``), propagating back toward the source

``newdif.f`` updates both after every space step. The split between
the two directions is set by geometric dilution weights ``dwex``/
``upex`` (derived from the local curvature radius in spherical
geometry). Upstream photons are attenuated back through the zones
already traversed and can still photoionise or heat gas closer to the
source — this is what keeps the diffuse field self-consistent, as
opposed to assuming every photon simply escapes to infinity.

Lines are then split into two physically distinct treatments,
depending on whether they can build up significant optical depth.

-----------------------------------------------------------
Optically thin lines (collisionally excited / forbidden)
-----------------------------------------------------------

``multilevel.f`` solves the multi-level statistical-equilibrium level
populations (collisional excitation/de-excitation, radiative decay)
for each ion, using the ionic populations from
:doc:`physics_ionization`, and produces line emissivities directly.
**No optical depth or escape probability is applied**: these lines
(forbidden and semi-forbidden transitions, which dominate nebular
cooling) have such small oscillator strengths that they are assumed to
always escape freely. This is the standard nebular-diagnostics
assumption.

-----------------------------------------------------------
Heavy-element and He I recombination lines
-----------------------------------------------------------

A third category sits alongside the collisionally-excited lines
above: permitted recombination lines from elements heavier than
hydrogen and helium (C II, N II, O I, O II, Ne II), computed in
``heavyrec.f`` (subroutines ``recom_cii``, ``recom_nii``, ``recom_oi``,
``recom_oii``, ``recom_neii``). Each recombines from the next-higher
ionisation stage (e.g. C III recombining to produce C II lines) using
precomputed Case A and Case B emissivity coefficients, spline-
interpolated in log temperature, with **no escape-probability
treatment applied** — like the collisionally-excited lines above, they
are summed straight into the volume-integrated flux totals in
:doc:`physics_output_spectra`, not passed through
``transferline.f``. When kappa electron distributions are enabled
(:doc:`adv_kappa`), the effective temperature used for the
interpolation is rescaled accordingly.

He I gets its own dedicated treatment in ``helioi.f`` (called from
``hydro.f``), combining both collisional excitation (using Gaunt
factors, similar in spirit to the free-free treatment in
:doc:`physics_continuum`) and recombination contributions for the
important He I triplet/singlet transitions, rather than reusing the
simpler Case A/B blend applied to H and He II
(:doc:`physics_output_spectra`'s description of ``hydro.f``'s
``hydrobri``).

--------------------------------------------------------------------
Radiatively trapped lines (resonance and recombination series)
--------------------------------------------------------------------

Hydrogen and helium recombination-line series, and short-wavelength
(< 2000 Å) resonance lines carried in the ``XLINDAT`` line list, *can*
build up substantial optical depth and are radiatively trapped. These
are handled with a genuine escape-probability formalism in
``transferline.f``.

Effective optical depth (``fdismul``)
======================================

``fdismul(t, dh, dr, dv, atom, ion, ejk, fab)`` computes, for a given
line and zone:

1. A **thermal optical depth** ``tauther`` from the column density
   (``dh`` × ionic fraction × abundance × ``dr``) and the thermal
   Doppler width ``vther`` of the ion at the local temperature.
2. A **velocity desaturation factor** from the differential bulk
   velocity ``dv`` across the zone (e.g. expansion or shock velocity
   gradients): a large ``dv`` relative to ``vther`` lets a photon
   redshift out of resonance before being reabsorbed, reducing the
   effective optical depth via an ``erf(vra)/vra`` term. This is a
   Sobolev-like desaturation.
3. An escape-probability approximation following
   **Capriotti (1965, ApJ 142, 1101)**, evaluated with two asymptotic
   fits (``e7a`` for the Doppler core, ``e7b`` for the damped wing).

The result is an effective **path-length multiplier** ``dismul``: the
optical depth a trapped line photon actually has to fight through is
``tau0 * dismul``, not the raw geometric ``tau0``.

Escape and attenuation functions
==================================

Given ``dismul`` and the raw zone optical depth ``tau0``,
``tauline(dismul, tau0)`` returns the effective optical depth (capped
at 10\ :sup:`10`). Three functions then act on it:

.. list-table::
   :header-rows: 1
   :widths: 25 25 50

   * - Function
     - Formula
     - Used for
   * - ``localout(dismul, tau)``
     - (1 − e\ :sup:`-τ`) / τ
     - Escape fraction of photons produced *locally* in the zone
   * - ``transferout(dismul, tau)``
     - e\ :sup:`-τ`
     - Attenuation of a beam of line photons *crossing* the zone from
       elsewhere (no local source)
   * - ``meanfield(dismul, tau)``
     - (1 − e\ :sup:`-τ`) / τ
     - Average intensity of a crossing beam within the zone

``newdif.f`` applies these separately to the downstream and upstream
components of every trapped line (e.g. ``hyddwlin``/``hyduplin``,
``heldwlin``/``heluplin``, ``xr3lines_dwlin``/``uplin``,
``xrllines_dwlin``/``uplin``), using the same ``dwex``/``upex``
geometric split as the continuum. Photons that don't escape a given
zone remain in the appropriate directional vector and are available
for reabsorption in the next zone.

-------------------------------------------------
Case A / Case B as a continuous quantity
-------------------------------------------------

Rather than choosing Case A or Case B as a fixed setting,
``casab(nz, line, series)`` in ``functions.f`` derives a **continuous**
Case A/B mixing fraction from the computed escape fraction of the
Lyman lines (``hydlin``/``hellin``), for hydrogen and helium only —
heavier-element resonance lines are always forced to Case A. The more
trapped the Lyman lines are locally, the more the recombination
cascade behaves like on-the-spot (Case B); the more they escape, the
closer to fully optically thin (Case A).

-------------------------------------------------
Bowen fluorescence (currently disabled)
-------------------------------------------------

``fbowen(t, dv)`` in ``transferline.f`` implements the He II λ303 → O
III Bowen fluorescence mechanism following **Kallman & McCray (1980)**.

.. admonition :: Developer Note

   ``fbowen`` is hard-disabled in the current code
   (``fbowen = 0.d0`` is returned unconditionally after the
   calculation). The code comment explains why: Bowen fluorescence is
   an inherently *global* nebular effect — a photon absorbed in one
   region can be re-emitted and detected in another — which does not
   fit cleanly into the local, zone-by-zone outward-only integration
   scheme used here. The values the (otherwise complete) calculation
   produces are not yet trusted. Re-enabling this will likely require
   a non-local integration method, not just flipping the disabled
   return.

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   Ionic populations (physics_ionization) + local T, n_e, n_H, dv
           |
           |  multilevel  -> forbidden/semi-forbidden line emissivities
           |                 (optically thin, no transfer)
           |  fdismul     -> effective optical depth multiplier for
           |                 each trapped resonance / recombination line
           v
   tauline -> localout / transferout / meanfield
           |
           |  applied separately downstream (dwex) and upstream (upex)
           v
   newdif  -> updates dwdif/updif (continuum) and the per-line
              dwlin/uplin vectors for the next zone
           |
           v
   casab   -> Case A/B mixing fraction for H, He recombination lines
              (from Lyman-line trapping)
           |
           v
   Integrated line list + emergent spectrum (.csv, .lam, .nfn)

-------------------------------------------------
Key routines
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Routine
     - Role
   * - ``multilevel``
     - Multi-level statistical-equilibrium solve for collisionally
       excited (forbidden/semi-forbidden) lines; optically thin, no
       transfer applied.
   * - ``heavyrec`` / ``helioi``
     - Heavy-element and He I recombination-line emissivities; also
       optically thin, no transfer applied.
   * - ``fdismul``
     - Effective optical-depth multiplier for a trapped resonance or
       recombination line (Capriotti 1965 escape probability +
       velocity desaturation).
   * - ``tauline``
     - Applies the ``dismul`` multiplier to the raw zone optical depth.
   * - ``localout`` / ``transferout`` / ``meanfield``
     - Escape/attenuation fractions for locally produced vs.
       crossing-beam line photons.
   * - ``newdif``
     - Propagates the two-stream (downstream/upstream) diffuse field —
       continuum and lines — across a zone.
   * - ``casab``
     - Continuous Case A/B mixing fraction for H/He recombination
       lines, from Lyman-line trapping.
   * - ``fbowen``
     - Bowen fluorescence fraction; implemented but currently disabled.

.. todo :: Document how the propagated diffuse field (``dwdif``/
   ``updif``) feeds back into ``phion`` for re-photoionisation of
   upstream zones. The continuum diffuse field (free-free, free-bound,
   two-photon) is now covered in :doc:`physics_continuum`.
