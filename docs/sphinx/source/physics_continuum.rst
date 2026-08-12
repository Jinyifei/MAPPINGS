.. _physics_continuum:

##################################################################
Physical Processes: Continuum Diffuse-Field Emission
##################################################################

This page describes the three processes that generate the continuum
part of the local diffuse radiation field: free-free (thermal
bremsstrahlung), free-bound (radiative recombination), and two-photon
emission. All three are computed by ``localem.f`` at every zone and
feed the same transported diffuse field documented in
:doc:`physics_lines` and :doc:`physics_output_spectra`. For the
line-emission counterpart, see :doc:`physics_lines`; for the
ionisation state that these processes depend on, see
:doc:`physics_ionization`.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Overview
-------------------------------------------------

``localem.f`` calls all three routines together at every zone:

.. code-block:: none

   call freebound (t, de, dh)
   call freefree  (t, de, dh)
   call twophoton (t, de, dh)

Each adds its contribution, in photons cm\ :sup:`-3` s\ :sup:`-1`
Hz\ :sup:`-1` sr\ :sup:`-1`, into the same per-bin continuum
emissivity array (``fbph``, ``ffph``, and via ``cnphot``
respectively) that ``totphot2``/``newdif2`` then propagate zone to
zone exactly as documented in :doc:`physics_lines`. From the
radiative-transfer machinery's point of view, these three processes
and the grain infrared emission from :doc:`physics_dust` are
indistinguishable — they are simply sources feeding the same
transported continuum.

-------------------------------------------------
Free-free (thermal bremsstrahlung) emission
-------------------------------------------------

``freefree.f`` computes the free-free continuum emissivity for every
ion present, following **Karzas & Latter (1961)**. The frequency- and
temperature-dependent Gaunt factor is not computed analytically at run
time; it is interpolated from a precomputed 2-D table in the
dimensionless parameters g² = Z²Ry/kT and u = hν/kT (functions
``fgfflin``/``fgfflog``/``fgfflogpoly``/``fgffspline2``, using a
Numerical-Recipes-style cubic 2-D interpolation via ``polint``).

The same file has two entry points:

- ``freefree`` — adds the free-free emissivity into the continuum
  array ``ffph`` used by the diffuse field.
- ``frefre`` — integrates the same physics into a single total
  free-free *cooling rate* (``fflos``), used in the energy balance
  documented in :doc:`physics_heating_cooling`.

They compute the same underlying process for two different purposes
(spectral shape vs. integrated cooling), from the same Gaunt-factor
tables.

-------------------------------------------------
Free-bound (radiative recombination) emission
-------------------------------------------------

``freebound.f`` computes the free-bound continuum in two parts:

- **Ground-state recapture**, for every ion with a tabulated
  photoionisation cross-section: rather than a separate recombination
  cross-section, this uses the **Milne relation** — detailed balance
  between photoionisation and radiative recombination — applied
  directly to the same cross-section used for photoionisation
  (:doc:`physics_ionization`). The governing relation (implemented in
  log space as the function ``hir``, following Osterbrock, Appendix 1)
  ties the recombination emissivity at a given photon energy directly
  to the photoionisation cross-section at that same energy, weighted
  by the Maxwellian electron distribution and the ratio of statistical
  weights between the recombined and ionised states.
- **Excited-level recapture**, for hydrogenic (one-electron)
  isoelectronic-sequence ions specifically: recombination to levels
  n = 2–10 (350 levels summed) is computed from precomputed,
  temperature-interpolated lookup tables, using hydrogenic Z²-scaling
  of the effective temperature. Non-hydrogenic ions do not get this
  excited-level treatment; their excited-level contribution is folded
  into the continuum at the first photoionisation edge above the
  ground state, per the file's header comment.

-------------------------------------------------
Two-photon emission
-------------------------------------------------

Two-photon continuum emission — the simultaneous emission of two
photons whose energies sum to the 2s→1s transition energy, from the
metastable 2s level of H and He-like ions — is split across two files
that must run in a specific order:

1. **``hydro2p.f``** (called from ``hydro.f``, before ``twophoton``)
   computes the *rate* at which the 2s level is populated and decays
   via the two-photon channel, rather than via collisional
   de-excitation back to 2p (which would instead feed Lyman-α). This
   requires the collisional-excitation and recombination rates into
   2s (``hherat``, from ``ratec``, and the recombination rate to 2s),
   competing against collisional l-mixing/quenching (rates ``qpr``/
   ``qel`` for proton and electron collisions) that can return the
   atom to 2p instead. The file's own header notes it retains
   "the old coll and recombination calcs ... only to derive the two
   photon values" — i.e. this routine is legacy machinery kept alive
   specifically because the two-photon rate calculation is entangled
   with it, even though the line-brightness values it also computes
   are "recorded for comparison ... not used otherwise" (superseded by
   ``hydro.f``'s newer treatment for the actual line fluxes).
2. **``twophoton.f``** takes the resulting total two-photon decay
   rates for H (``h2ql``) and He II (``heii2ql``) and distributes them
   over the characteristic two-photon spectral shape, adding the
   result into the continuum array ``cnphot``.

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   hydro.f: H/He level populations, collisional + recombination rates
           |
           |  hydro2p -> total 2s-level two-photon decay rate
           |             (h2ql, heii2ql), competing against
           |             collisional l-mixing back to 2p
           v
   localem.f, per zone:
           |
           |  freebound -> ffph continuum: Milne relation (ground
           |               state, any ion) + hydrogenic excited-level
           |               tables (H-like ions only)
           |  freefree  -> ffph continuum: Gaunt-factor table lookup
           |               (Karzas & Latter 1961)
           |  twophoton -> cnphot continuum: two-photon spectral shape
           |               from hydro2p's decay rates
           v
   Combined with grain IR emission (physics_dust) into the same
   continuum emissivity, then totphot2/newdif2 (physics_lines)
   propagate it zone to zone into the transported diffuse field
   (physics_output_spectra).

-------------------------------------------------
Key routines
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Routine
     - Role
   * - ``freefree``
     - Free-free continuum emissivity via tabulated Gaunt factors
       (Karzas & Latter 1961).
   * - ``frefre``
     - Same physics, integrated into a total free-free cooling rate
       for :doc:`physics_heating_cooling`.
   * - ``freebound``
     - Free-bound continuum: Milne relation for ground-state
       recapture (any ion), hydrogenic lookup tables for excited-level
       recapture (H-like ions).
   * - ``hydro2p``
     - Computes the 2s-level two-photon decay rate for H/He II,
       competing against collisional l-mixing; legacy routine kept
       specifically for this calculation.
   * - ``twophoton``
     - Distributes the two-photon decay rate over its characteristic
       spectral shape into the continuum.
   * - ``localem``
     - Calls all three processes (plus lines and dust IR emission)
       together at each zone.

.. todo :: Document the free-bound Gaunt-factor/effective-temperature
   lookup-table construction (``fblte`` and related tables) in more
   detail, and the exact two-photon spectral shape function used in
   ``twophoton.f``.
