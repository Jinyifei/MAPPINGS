.. _physics_ionization:

##################################################
Physical Processes: Ionisation Balance
##################################################

This page describes how MAPPINGS determines the ionisation state of
the gas at a zone — which rate processes compete, which routines
compute them, and how they are assembled into a balance equation. See
:doc:`physics_overview` for how this page relates to the rest of the
physics documentation, and :doc:`code_photo` / :doc:`code_s5` for where
these routines are called from within the zone-stepping loop.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Overview
-------------------------------------------------

At each zone, the ionic population of every tracked species is set by
balancing processes that push an ion to a higher stage (ionisation)
against processes that return it to a lower one (recombination).
MAPPINGS evaluates four ionisation channels and two recombination
channels:

.. list-table::
   :header-rows: 1
   :widths: 25 15 60

   * - Process
     - Direction
     - Routine
   * - Photoionisation (incl. Auger)
     - up
     - ``phion.f``
   * - Collisional ionisation
     - up
     - ``collion.f``
   * - Secondary ionisation (fast photo-/cosmic-ray electrons)
     - up
     - ``ionsec.f``
   * - Cosmic-ray primary ionisation
     - up
     - ``cosmic.f``
   * - Radiative + dielectronic recombination
     - down
     - ``recom.f``
   * - Charge exchange with H
     - both
     - ``charex.f``

All six are gathered together in ``allrates.f`` and combined into the
actual ionic population solve in ``equion.f`` (equilibrium) or
``iobal.f`` (equilibrium *or* finite-age, time-dependent).

-------------------------------------------------
Photoionisation and Auger ionisation
-------------------------------------------------

``phion.f`` computes photoionisation rates ``rphot(mxion,mxelem)`` and
the associated photoheating rates ``heaph`` by integrating the local
mean intensity J\ :sub:`ν` (held in ``tphot``, and built up zone by
zone by the radiative-transfer routines — see :doc:`physics_lines` for
how the diffuse field itself is propagated) against the photoionisation
cross section of every ion, over the full photon energy grid
(``ionum`` cross sections).

Because the radiation field extends to X-ray energies, a single
absorbed photon can eject more than one electron via **inner-shell
(Auger) ionisation**: this is folded into ``phion.f`` alongside direct
valence-shell photoionisation, and matters most for the heavier
elements exposed to a hard (AGN-like) spectrum. ``phion.f`` also
computes the basis arrays (``anr``, ``wnr``) used by the secondary
ionisation calculation below, since a fast photoelectron's energy
budget is set at the moment it is ejected.

-------------------------------------------------
Collisional ionisation
-------------------------------------------------

``collion.f`` computes electron-impact ionisation rates using the
five-parameter fits of **Arnaud & Rothenflug (1985)** and
**Younger (1981, 1983)**, integrated analytically over a Maxwellian
electron energy distribution at the local electron temperature. This
channel is negligible in cool photoionised gas but becomes important
at the higher temperatures found behind shocks or in X-ray-heated gas,
where it can dominate over photoionisation.

-------------------------------------------------
Secondary and cosmic-ray ionisation
-------------------------------------------------

Two related channels account for ionisation by non-thermal electrons
rather than by direct photon or thermal-electron collision:

- **Secondary ionisation** (``ionsec.f``) — a photoelectron ejected
  with more energy than needed to escape its parent ion does not
  simply heat the gas as it thermalises; some of that excess energy
  goes into ionising *other* atoms as the fast electron scatters. This
  follows **Shull (1979)** and **Bergeron & Souffrin**, using the
  energy-partition basis computed in ``phion.f`` and returning rates in
  ``rasec(3,11)``. This channel is significant wherever the radiation
  field is hard (X-rays, cosmic rays), since soft UV photoelectrons
  carry little excess energy.

- **Cosmic-ray ionisation/heating** (``cosmic.f``) — the primary
  ionisation and heating rate of H and He by cosmic rays, following
  Shull (1979) with a mean ejected-electron energy of 35 eV. This
  primary rate is what feeds the secondary-ionisation cascade above in
  regions where cosmic rays (rather than photoelectrons) are the
  dominant source of fast electrons.

-------------------------------------------------
Recombination
-------------------------------------------------

``recom.f`` computes **radiative and dielectronic recombination**
rates and returns them in ``rec(ion,atom)`` (units cm\ :sup:`3`
s\ :sup:`-1`). Hydrogen and helium are treated specially
(``rec(3,1)``, ``rec(4,2)``, ``rec(5,2)``) to support the **on-the-spot
approximation**, in which recombinations directly to the ground state
produce an ionising photon that is assumed to be reabsorbed
immediately rather than transported — an approximation whose validity
is linked to the Case A/B treatment of the Lyman lines (see
:doc:`physics_lines`).

-------------------------------------------------
Charge exchange
-------------------------------------------------

``charex.f`` computes charge-transfer reaction rates between each ion
and neutral/ionised hydrogen, returned in ``charte``. This channel can
dominate the low-temperature ionisation balance of species whose
ionisation potential is close to that of hydrogen (e.g. O\ :sup:`+`,
N\ :sup:`+`), because the reaction cross sections are resonant and
large even though the gas is too cool for collisional ionisation to
compete.

-------------------------------------------------
Assembling the rates and solving the balance
-------------------------------------------------

``allrates.f`` is the dispatcher: given a mode flag (``TEMP``, to
recompute only temperature-dependent rates; ``PHOT``, only
radiation-dependent rates; or ``ALL``), it calls ``cosmic``, ``phion``,
``recom``, ``collion``, and ``charex`` as needed, skipping recomputation
of rates that haven't changed since the last call (tracked via the
``tem``/``ipho`` flags — the photon field is considered to have changed
only when ``totphot`` has run).

The actual population solve happens in:

- ``equion.f`` — pure equilibrium ionisation balance at a fixed T and
  n\ :sub:`e`, for all elements.
- ``iobal.f`` — the general driver, supporting both equilibrium
  (``mod='EQUI'``) and finite-age time-dependent integration over a
  step ``tstep``. It calls ``sdifeq``, ``allrates``, ``spotap``,
  ``ionab``, and ``ionsec`` to advance the ionic populations
  ``pop(6,11)`` and their time derivatives ``dndt`` — see
  :doc:`physics_time_integration` for how ``sdifeq``/``ionab``
  actually solve the time-dependent balance.

-------------------------------------------------
Radiation pressure
-------------------------------------------------

Absorbing a photon transfers its momentum to the gas (and to dust, if
enabled — see :doc:`physics_dust`), not just its energy. ``fradpress``
in ``functions.f`` computes the radiation-pressure force Φσ/c from the
same local mean intensity ``tphot`` and opacity ``xsec`` used for
photoionisation above: for every energy bin, it sums the *absorbed*
photon energy flux — ``tphot(i) * widbinnu(i) * (1 - exp(-tau))``,
where ``tau = dr * xsec(i)`` — so only photons actually absorbed in
the zone contribute; photons that pass through unabsorbed exert no
force. The gas and dust contributions are computed and added
separately, since dust opacity (``dustsigmat``, :doc:`physics_dust`)
and gas photoelectric opacity respond differently to the spectrum.

This force feeds directly into the pressure balance of isobaric
density-law models (:doc:`code_photo`'s ``B`` density mode): the
zone-to-zone pressure used to derive density includes this radiation
pressure term on top of the gas thermal pressure, so a sufficiently
intense radiation field can measurably raise the pressure (and hence
lower the density, at fixed P/k) compared to gas pressure alone. A
``radpressmode`` toggle can disable the term entirely.

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   Local radiation field (tphot) + local T, n_e, n_H
           |
           |  cosmic   -> primary cosmic-ray ionisation/heating
           |  phion    -> photoionisation + Auger rates, photoheating,
           |              secondary-ionisation energy basis
           |  collion  -> collisional ionisation rates
           |  charex   -> charge-exchange rates
           |  recom    -> radiative + dielectronic recombination rates
           |  ionsec   -> secondary ionisation rates (from phion basis)
           v
   allrates  (gathers all rates, skips unchanged ones)
           v
   equion / iobal  (solve for ionic populations pop(6,11))
           |
           v
   Ionic populations feed: cooling/heating balance, line and
   continuum emissivities (localem), next zone's opacity (crosssections)

-------------------------------------------------
Key routines
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Routine
     - Role
   * - ``phion``
     - Photoionisation + Auger rates and photoheating from the local
       mean intensity; also computes the secondary-ionisation energy
       basis.
   * - ``collion``
     - Collisional (electron-impact) ionisation rates,
       Arnaud & Rothenflug (1985) / Younger fits.
   * - ``ionsec``
     - Secondary ionisation by non-thermal (fast photo-/cosmic-ray)
       electrons, Shull (1979).
   * - ``cosmic``
     - Primary cosmic-ray ionisation and heating of H/He.
   * - ``recom``
     - Radiative + dielectronic recombination rates, with on-the-spot
       handling for H/He.
   * - ``charex``
     - Charge-exchange rates with hydrogen.
   * - ``allrates``
     - Dispatcher: gathers all rate calls, skipping unchanged ones.
   * - ``equion`` / ``iobal``
     - Solve the ionic population balance (equilibrium or
       time-dependent).
   * - ``fradpress``
     - Radiation-pressure force from absorbed photon momentum (gas +
       dust); feeds the isobaric pressure balance.

.. admonition :: Developer Note

   ``allrates`` avoids recomputing rate sets that haven't changed
   using the ``tem``/``ipho`` flags. When adding a new rate process,
   make sure it participates in this dependency tracking (i.e. is
   recomputed under the correct ``jjmod`` value) or it will silently
   use stale rates after a temperature or radiation-field update.

.. todo :: Document the non-equilibrium time-integration mechanics
   behind ``iobal``'s finite-age mode (``sdifeq``, ``ionab``) in more
   depth than the summary here — now largely covered in
   :doc:`physics_time_integration`; confirm no further detail is
   needed on this page specifically.
