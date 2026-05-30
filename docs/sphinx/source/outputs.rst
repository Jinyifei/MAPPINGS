.. _outputs:

###############
Output Files
###############

MAPPINGS produces a variety of output files depending on the model type run.
All file names are constructed from a **prefix** and a zero-padded four-digit
**sequence number** (e.g. ``photn0001.ph6``, ``photn0002.ph6``, …), so that
multiple models in a single run produce distinct files.  For shock models the
user is also prompted for an additional string that is embedded in the prefix
(e.g. ``shck_v100s_0001.sh5``).

The file extensions group files by model type and content as described in the
sections below.

.. contents:: Contents
   :local:
   :depth: 2

---------------------------------
Photoionization Models
---------------------------------

Photoionization models are run by the ``photo6`` (mode 6) and ``photo7``
(mode 7) solvers and produce files with the extensions ``.ph6`` and ``.ph7``
respectively, together with a set of ``.csv`` files and optional photon source
(``.sou``) and spectrum (``.lam``) files.

Main Output Files
=================

These files are always written for each photoionization model.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Filename pattern
     - Contents
   * - ``photn<N>.ph6`` / ``photn<N>.ph7``
     - Primary output.  Contains the full nebular structure zone by zone,
       emission line fluxes, ionic fractions, temperatures, densities, and
       an integrated line list.
   * - ``phapn<N>.ph6`` / ``phapn<N>.ph7``
     - Aperture-summed photon output, integrating the emission over a
       specified projected aperture.
   * - ``phlss<N>.ph6`` / ``phlss<N>.ph7``
     - Line and spectrum summary; a condensed form of the line list and
       broadband fluxes suitable for quick inspection.
   * - ``phsem<N>.ph6`` / ``phsem<N>.ph7``
     - Spectral energy map; the full spectral energy distribution resolved
       across the nebular zones.
   * - ``ions_<N>.ph6`` / ``ions_<N>.ph7``
     - Ion fraction profiles as a function of depth through the nebula for
       all tracked species.

Optional Tabular Output Files
==============================

These ``.csv`` files are written when the corresponding output option is
selected in the run menu.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Filename pattern
     - Contents
   * - ``spec<N>.csv``
     - Full emission spectrum as a two-column (wavelength, flux) table.
   * - ``lines<N>.csv``
     - Line flux table listing every computed emission line, its
       identification, and its flux relative to H\ :math:`\beta`.
   * - ``bands<N>.csv``
     - Integrated fluxes in standard broadband photometric filters.
   * - ``rates<N>.csv``
     - Reaction rate coefficients and heating/cooling rates by process.
   * - ``flam_<N>.csv``
     - F\ :math:`\lambda` spectrum: wavelength (Å) versus flux
       (erg s\ :sup:`−1` cm\ :sup:`−2` Å\ :sup:`−1`).
   * - ``<X>_ion<N>.csv``
     - Per-element ion fraction profiles, where ``<X>`` is a one- or
       two-character element abbreviation.
   * - ``<X>_col<N>.csv``
     - Per-element column density profiles.

Radiation Field Files
======================

These files record the internal radiation field at selected points and can be
read back as input photon sources for downstream models, allowing models to be
chained.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Filename pattern
     - Contents
   * - ``psou<N>.sou``
     - Primary (stellar or AGN) ionising photon source vector in
       J\ :math:`_\nu` units (1/4π sr).
   * - ``nsou<N>.sou``
     - Diffuse nebular photon source vector accumulated over the model.
   * - ``ssou<N>.sou``
     - Secondary photon source vector (e.g. two-photon continuum).
   * - ``lsou<N>.sou``
     - Local radiation field source vector at the illuminated face.
   * - ``irsou<N>.sou``
     - Infrared radiation field source vector.
   * - ``IRflux<N>.sou``
     - Total IR flux source vector including dust emission.
   * - ``pahs<N>.sou``
     - PAH (polycyclic aromatic hydrocarbon) emission source vector.
   * - ``local<N>.lam``
     - Local radiation field as wavelength (Å) versus
       F\ :math:`\lambda` (erg s\ :sup:`−1` cm\ :sup:`−2` Å\ :sup:`−1`).
   * - ``grpot<N>.ph6``
     - Grain potential output — the electrostatic grain charge as a
       function of depth.


---------------------------------
Shock Models — S5
---------------------------------

The S5 shock solver (``shock5.f``) computes steady-state, magnetised,
radiative shock waves and their photo-ionised precursors.  When starting a
shock run the user is asked for a short prefix string (up to 8 characters)
that is embedded in all output filenames, for example ``v100s``, giving files
such as ``shck_v100s_0001.sh5``.

Main Structure Files (``.sh5``)
=================================

.. list-table::
   :header-rows: 1
   :widths: 38 62

   * - Filename pattern
     - Contents
   * - ``shck_<pfx>_<N>.sh5``
     - Main shock zone-by-zone structure: temperature, density, velocity,
       magnetic field, ionisation state, and cooling as a function of
       column depth through the post-shock cooling layer.
   * - ``prec_<pfx>_<N>.sh5``
     - Precursor zone structure: the same quantities for the photo-ionised
       region ahead of the shock front.
   * - ``ionSH<pfx>_<N>.sh5``
     - Ion fraction profiles through the shock.
   * - ``ratSH<pfx>_<N>.sh5``
     - Reaction and heating/cooling rates through the shock.
   * - ``ratPC<pfx>_<N>.sh5``
     - Reaction and heating/cooling rates through the precursor.
   * - ``dynSH<pfx>_<N>.sh5``
     - Dynamical flow variables (velocity, pressure, Mach number) through
       the shock.

Spectral and Line Output (``.csv``)
=====================================

.. list-table::
   :header-rows: 1
   :widths: 38 62

   * - Filename pattern
     - Contents
   * - ``specSH<pfx>_<N>.csv``
     - Integrated emission spectrum of the shock component.
   * - ``specPC<pfx>_<N>.csv``
     - Integrated emission spectrum of the precursor component.
   * - ``linSH<pfx>_<N>.csv``
     - Emission line flux table for the shock.
   * - ``linPC<pfx>_<N>.csv``
     - Emission line flux table for the precursor.
   * - ``coolSH<pfx>_<N>.csv``
     - Normalised cooling function as a function of depth through the shock.
   * - ``bandSH<pfx>_<N>.csv``
     - Broadband photometric fluxes for the shock.
   * - ``elSH<pfx><elem>_<N>.csv``
     - Per-element emission for the shock, where ``<elem>`` is the element
       symbol (e.g. ``elSHv100sO_0001.csv`` for oxygen).
   * - ``elPC<pfx><elem>_<N>.csv``
     - Per-element emission for the precursor.


---------------------------------
Shock Models — S4
---------------------------------

The S4 shock solver (``shock4.f``) is an earlier shock implementation and
produces files with the extension ``.sh4``.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Filename pattern
     - Contents
   * - ``shckn<N>.sh4``
     - Main shock zone structure output.
   * - ``dyn<N>.sh4``
     - Dynamical flow variables through the shock.
   * - ``rates<N>.sh4``
     - Reaction and cooling rates.
   * - ``allion<N>.sh4``
     - Complete ion fraction table.
   * - ``bands<N>.sh4``
     - Broadband filter fluxes.
   * - ``spec<N>.csv``
     - Shock emission spectrum.
   * - ``cc<N>.csv``
     - Cooling curve as a function of temperature.


---------------------------------
Non-Equilibrium Cooling
---------------------------------

The non-equilibrium cooling solver (``neqc.f``) computes time-dependent
cooling of a plasma parcel and produces files with the extension ``.neq``.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Filename pattern
     - Contents
   * - ``neqcl<N>.neq``
     - Main non-equilibrium cooling output: temperature, ionisation, and
       cooling as a function of time.
   * - ``neqc<N>.csv``
     - Tabulated cooling data.
   * - ``rates<N>.csv``
     - Reaction rates as a function of time.
   * - ``dyn<N>.csv``
     - Dynamical quantities as a function of time.
   * - ``spec<N>.csv``
     - Emission spectrum integrated over the cooling.
   * - ``bands<N>.csv``
     - Broadband fluxes.


---------------------------------
Continuum and Spectrum Files
---------------------------------

These file types are produced across multiple model types depending on which
output options are selected.

.. list-table::
   :header-rows: 1
   :widths: 12 88

   * - Extension
     - Contents
   * - ``.bln``
     - Blanketed continuum spectrum: the total model continuum including
       free-free, free-bound, two-photon, and dust emission, without
       emission lines.
   * - ``.lam``
     - Wavelength versus F\ :math:`\lambda` spectrum in five columns:
       wavelength (Å), total flux, source flux, nebular flux, and nebular
       continuum, all in erg s\ :sup:`−1` cm\ :sup:`−2` Å\ :sup:`−1`.
   * - ``.nfn``
     - Frequency versus :math:`\nu F_\nu` spectrum
       (erg s\ :sup:`−1` cm\ :sup:`−2` sr\ :sup:`−1`).
   * - ``.emi``
     - Emission spectrum normalised relative to H\ :math:`\beta`.
   * - ``.dat``
     - X-ray band flux data.
   * - ``.sou``
     - Photon source vector in J\ :math:`_\nu` units (1/4π sr).  Used
       internally as the radiation field representation and can be fed
       back as input to a subsequent model to chain calculations.
   * - ``.txt``
     - Plain-text output from slab geometry models (``slab.f``).


---------------------------------
Notes on File Naming
---------------------------------

Sequence numbers
================

Within a single MAPPINGS run, each model increments the sequence counter
so files from successive models do not overwrite one another.  The counter
resets to ``0001`` at the start of each run.

Shock prefix string
====================

For S5 shock models the user is asked at run time::

    Give a prefix for all output files (max 8 chars):

This string (e.g. ``v100s`` for a 100 km/s shock) is embedded in every
output filename for that model, making it straightforward to run and compare
grids of models with varying parameters in the same directory.

Chaining models with ``.sou`` files
=====================================

The ``.sou`` photon source files output by a photoionization or shock model
can be read back by a subsequent model as the incident radiation field.  This
allows, for example, the nebular emission of a model HII region to be used
as the ionising source for a downstream cloud, or a shock precursor to be
iterated self-consistently.
