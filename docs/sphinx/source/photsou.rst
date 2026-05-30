.. _photsou:

###################################
Defining the Radiation Field
###################################

After the ionisation balance is set, models that involve a radiation field
— P6, P7, S5, SS, and PP — call the shared ``photsou`` routine to define
the incident photon source.  The cooling models (CC, NC) and test-atom
models (MM, CD, TE) do not use this step.

``photsou`` builds a composite radiation field by adding one or more
spectral components to an internal source vector.  The menu loops: each
choice adds a component to the existing field (or operates on it), and
the session exits when ``X`` is entered.  The field can be zeroed and
rebuilt at any point using ``Z``.

.. contents:: Contents
   :local:
   :depth: 1

-------------------------------------------------
The Menu
-------------------------------------------------

::

    ::::::::::::::::::::::::::::::::::::::::::::::::
     Multiple Component Photoionisation Source:
    ::::::::::::::::::::::::::::::::::::::::::::::::
     Basic Sources:
        A  :   Power Law, non-thermal component (c*nu**Alpha)
        B  :   Black Body component
        E  :   Bremsstrahlung component (c*exp(-hnu/kT))
     Stellar Sources:
        C1 :   ATLAS9 Stellar models    (30000 - 50000K)
        C2 :   TLUSTY Stellar models    (27500 - 55000K)
        C3 :   CMFGEN Stellar models    (27500 - 48500K)
        C4 :   WMBASIC Stellar models
        P1 :   TNMAP CSPN New HNi models (50kK - 190kK)
        P2 :   TNMAP CSPN Old HCa models (50kK - 1000kK)
     Non-Stellar Sources:
        F  :   Local ISRF (Mathis et al 1983)
        G  :   AGN (Bland-Hawthorn et al 2013)
        J  :   AGN (Component Library v2, Jin et al 2012)
        OX :   OPTXAGNF full AGN model
     File I/O Sources:
        HS :   Input SLUG2 spectrum file
        H  :   Input Starburst99 spectrum file
        K  :   Input two-column flux file (variable points)
        I  :   Input .sou photon source file
        O  :   Output .sou photon source file
     Operations:
        Z  :   Zero (clear) radiation field
        S  :   Apply overall scaling factor
        N  :   Normalise fluxes
        X  :   eXit with current source
    ::

-------------------------------------------------
Source Types
-------------------------------------------------

Basic Sources
=============

**A — Power Law**
  A non-thermal power-law spectrum F\ :sub:`ν` ∝ ν\ :sup:`α`.  MAPPINGS
  prompts for the spectral index α and a normalisation (luminosity or
  ionising photon rate).

**B — Blackbody**
  A Planck blackbody at a given effective temperature T\ :sub:`eff`.
  MAPPINGS prompts for T\ :sub:`eff` (K) and a luminosity or ionising
  photon rate Q(H).

**E — Bremsstrahlung**
  A free-free (thermal bremsstrahlung) spectrum ∝ exp(−hν/kT).  Useful
  as an X-ray background component.  Prompts for temperature and
  normalisation.

Stellar Model Atmospheres
=========================

Stellar atmosphere grids are read from pre-computed files in the
``atmos/`` data directory.  Each grid is interpolated to the requested
T\ :sub:`eff`.

.. list-table::
   :header-rows: 1
   :widths: 10 30 60

   * - Code
     - Grid
     - Temperature range
   * - C1
     - ATLAS9
     - 30 000 – 50 000 K
   * - C2
     - TLUSTY
     - 27 500 – 55 000 K
   * - C3
     - CMFGEN
     - 27 500 – 48 500 K
   * - C4
     - WMBASIC
     - OB supergiants
   * - P1
     - TNMAP CSPN (HNi)
     - 50 000 – 190 000 K (central stars of planetary nebulae)
   * - P2
     - TNMAP CSPN (HCa)
     - 50 000 – 1 000 000 K (central stars of planetary nebulae)

For each stellar model, MAPPINGS prompts for T\ :sub:`eff` and a
luminosity or Q(H) normalisation.

Non-Stellar Sources
===================

**F — Local ISRF**
  The Mathis et al. (1983) interstellar radiation field.  No further
  parameters needed.

**G — AGN (Bland-Hawthorn et al. 2013)**
  A multi-component AGN spectrum combining a soft X-ray excess and a
  power-law ionising continuum.  Prompts for normalisation.

**J — AGN Component Library (Jin et al. 2012)**
  A library of AGN spectral components.  Prompts for the component
  choice and normalisation.

**OX — OPTXAGNF**
  The Done et al. (2012) full AGN spectral energy distribution model.
  Prompts for black hole mass, Eddington ratio, and other model parameters.

File I/O Sources
================

**I — Input .sou file**
  Reads a previously saved photon source vector (in J\ :sub:`ν` units,
  1/4π sr) from a ``.sou`` file.  This is the primary mechanism for
  chaining models: the photon source output of one run becomes the
  ionising input for the next.

**K — Two-column flux file**
  Reads a user-supplied spectrum as a plain text file with two columns:
  wavelength (Å) and flux.  The spectrum is interpolated onto MAPPINGS'
  internal energy grid.

**H — Starburst99 spectrum**
  Reads an output spectrum from the Starburst99 stellar population
  synthesis code.

**HS — SLUG2 spectrum**
  Reads an output spectrum from the SLUG2 stellar population synthesis
  code.

**O — Output .sou file**
  Writes the current composite source vector to a ``.sou`` file for
  inspection or later reuse, without affecting the field itself.

-------------------------------------------------
Operations
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 8 92

   * - Key
     - Action
   * - Z
     - **Zero** — clears the entire radiation field so a new one can be
       built from scratch.
   * - S
     - **Scale** — multiplies the entire current field by a user-supplied
       constant factor.
   * - N
     - **Normalise** — rescales the field to a specified total or ionising
       luminosity.
   * - X
     - **Exit** — accepts the current composite field and proceeds.

-------------------------------------------------
Field Summary Display
-------------------------------------------------

After each component is added, MAPPINGS prints a summary of the current
field::

    Total Intensity     :  <value>  (ergs/s/cm^2)
    Total Photons       :  <value>  (phots/cm^2/s)
    Ion. Intensity      :  <value>  (ergs/s/cm^2)
    Ion. Photons (FQ)   :  <value>  (phots/cm^2/s)
    <Ion. Photon E<100eV>: <value>  (eV)
    <X Photon E >100eV> : <value>  (eV)
    FQ Total  (>13.6eV) :  <value>  (phots/cm^2/s)
    FQHI  (13.6-24.6eV) :  <value>  (phots/cm^2/s)
    FQHeI (24.6-54.4eV) :  <value>  (phots/cm^2/s)
    FQHeII    (>54.4eV) :  <value>  (phots/cm^2/s)

followed by per-ion ionising photon rates for C, N, O, Ne, S, and Fe,
and X-ray band integrals at 0.1, 1, 2, 5, and 10 keV.  This lets you
verify the field before proceeding.

-------------------------------------------------
Notes
-------------------------------------------------

The radiation field is represented internally as an intensity vector
I\ :sub:`ν` in units of erg s\ :sup:`−1` cm\ :sup:`−2` Hz\ :sup:`−1`
sr\ :sup:`−1` (1/π steradians, plane-parallel convention).  External
files (``.sou``, stellar atmosphere grids) are stored in J\ :sub:`ν`
units (1/4π sr) and are converted on read-in.

For S5 shock models, the radiation field defined here is the **ambient
pre-shock field**.  Setting it to zero (option ``Z`` then ``X``) gives a
pure shock with no external ionising background; the shock's own
UV/X-ray emission is still computed self-consistently.
