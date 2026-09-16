.. _walkthrough_p6:

##########################################
Walkthrough: A P6 Photoionisation Model
##########################################

This page runs one concrete P6 model end to end — the actual prompts
answered, the actual files it produces, and what is inside them — so you
can see the whole path in one place instead of assembling it from
:doc:`models` (prompt order), :doc:`inputs` (startup steps), and
:doc:`outputs` (file reference).  Those three pages remain the
authoritative reference for each of those topics; this page does not
restate them, it demonstrates them with one worked example and points
back to them for the general case.

.. contents:: Contents
   :local:
   :depth: 1

-------------------------------------------------
The scenario
-------------------------------------------------

A classic isochoric (constant-density) HII region: solar abundances, a
45,000 K ATLAS9 O-star atmosphere as the ionising source, specified by
its ionising photon rate, a low mean hydrogen density typical of a
diffuse HII region, and a spherical, radiation-bounded (Strömgren-sphere
type) geometry with the standard ionisation-parameter inner boundary.
This is one of the models already used as a regression test — see
``scripts/testScripts/MV52tests/MV52Scripts/01_solhii.mv``.

-------------------------------------------------
The script
-------------------------------------------------

Piped to ``map52`` non-interactively (see :doc:`inputs`, "Running from a
script"), one line per prompt. This is a real, tested script — download
:download:`p6_hii_atlas9.mv <../../../lab/examples/p6_hii_atlas9.mv>`
and its abundance file, :download:`p6_hii_abund.txt
<../../../lab/examples/p6_hii_abund.txt>`, and run it as shown below.
It also ships with every install, in ``~/mappings520/lab/examples/``.

.. literalinclude:: ../../../lab/examples/p6_hii_atlas9.mv
   :language: none

Every step above is one instance of the general prompt sequence
documented in :doc:`inputs` (abundances/dust), :doc:`popcha` (ionisation
balance), :doc:`photsou` (radiation field), and :doc:`models` (P6
geometry/density/stopping-condition prompts) — this page just shows the
concrete answers for this particular model rather than the menu text.

.. note::

   The abundance-file and model-name prompts are read as a whole line,
   not a free-form value — unlike almost every other prompt in this
   script, MAPPINGS does **not** ignore trailing text on those two
   lines, so (unlike the rest of the script) they cannot carry an
   inline ``: comment`` annotation the way they might elsewhere.

Run it (from wherever you saved the two downloaded files, or from
``~/mappings520/lab/examples/`` if using the shipped copy)::

    map52 < p6_hii_atlas9.mv

-------------------------------------------------
What got created
-------------------------------------------------

Because output option ``B`` ("standard + monitor element ionisation")
was selected and elements 1, 2, 6, 8 (H, He, C, O) were chosen, this run
produced:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - File
     - Contents
   * - ``photn0001.ph6``
     - Primary output — full zone-by-zone structure and the integrated
       line list (see below).
   * - ``phapn0001.ph6``
     - Aperture-summed photon output.
   * - ``phlss0001.ph6``
     - Condensed line/spectrum summary.
   * - ``phsem0001.ph6``
     - Spectral energy map across zones.
   * - ``spec0001.csv``
     - Full emission-line list, wavelength/energy/flux relative to
       Hβ = 1 (see below).
   * - ``H_ion0001.csv``, ``He_ion0001.csv``, ``C_ion0001.csv``,
       ``O_ion0001.csv``
     - Per-element ion-fraction profile vs. depth, one file per
       monitored element (the ``B`` option, elements 1 2 6 8).

Every one of these filename patterns and what its columns mean is
catalogued in full in :doc:`outputs` (`Photoionization Models`
section) — this list only says which of the general set this
particular run's choices actually produced.

-------------------------------------------------
A peek inside
-------------------------------------------------

``spec0001.csv`` — the line list, after the header block giving the
abundance table and radiation-field summary::

     Lambda(A),  E (eV) , Flux (HB=1.0), Species  , Kind, Accuracy (1-5)
     =======================================================================
          584.334,  2.12180E+01,  8.94853E-01, He I     , RCB ,    5
          591.412,  2.09641E+01,  1.57118E+00, He I     , RCB ,    5
          977.020,  1.26900E+01,  7.82404E-06, C  III   , CM  ,    2
         1063.298,  1.16603E+01,  4.28952E-04, C  II    , RB  ,    4

1510 lines total for this model, thresholded at flux/Hβ > 10⁻⁷ (see
:doc:`physics_output_spectra` for how that threshold and the line-flux
normalisation work).

``H_ion0001.csv`` — one row per zone stepping outward through the
nebula; columns are step, radius, Δr, T, then the ion fractions::

      17, 1.17683E+20, 3.37701E+17, 7500.3, 0.99328, ...
      18, 1.18020E+20, 3.37333E+17, 7495.6, 0.99321, ...

Temperature is falling and the neutral fraction rising only very
slowly here — this zone is still deep inside the fully ionised
Strömgren sphere, well short of the ionisation front.

-------------------------------------------------
Adapting this to your own model
-------------------------------------------------

The prompts that are worth changing first for a different HII region:

* **Teff / stellar source** (line ``45000``) — swap for a cooler or
  hotter atmosphere, or pick a different grid entirely (``c2``/``c3``
  for TLUSTY/CMFGEN, or ``h`` to read a Starburst99 cluster spectrum —
  see :doc:`photsou`).
* **Ionising photon rate** (``5e48``) — scale the source luminosity.
* **Density** (``0.9206789764391988``) — the constant density for this
  isochoric run; switch the density-structure letter to ``b`` for
  isobaric or ``f`` for a functional density law (see :doc:`models`).
* **Output option** (``b``) — pick ``g`` for every optional output file,
  or ``j`` to add position-resolved monitoring of up to 16 individual
  lines (see :doc:`physics_output_spectra`, "Enabling it and what gets
  written").
