.. _repo_structure:

################################
Repository Directory Structure
################################

This page describes the layout of the MAPPINGS V repository.  The top-level
directories are:

.. code-block:: none

   mappings/
   ├── src/           Fortran source code (~87 files)
   ├── tools/         C post-processing tools
   ├── lab/           Working directory and runtime data
   ├── scripts/       Test suites, model grids, and utilities
   ├── docs/          Documentation (Sphinx, Doxygen, PDFs)
   ├── addons/        Optional extras and alternate build files
   ├── bin/           Compiled executable placeholder
   └── Makefile       Root build system

.. contents:: Contents
   :local:
   :depth: 1

-------------------------------------------------
``src/`` — Fortran source code
-------------------------------------------------

The Fortran 77 source for the main MAPPINGS executable.  All files are compiled
by the root ``Makefile`` into ``bin/map52``.  The compiler is ``gfortran`` with
``-std=legacy -march=native -Ofast``.

The ``.inc`` files declare Fortran COMMON blocks that are included by every
source file needing shared state:

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - File
     - Contents
   * - ``cblocks.inc``
     - Master COMMON block: abundances, atomic data arrays, run parameters,
       photon grid.  Includes ``const.inc``.
   * - ``const.inc``
     - Physical and mathematical constants; sets ``implicit none`` for the
       whole codebase.
   * - ``p6blocks.inc``
     - COMMON blocks specific to the P6 photoionisation model.
   * - ``p7blocks.inc``
     - COMMON blocks specific to the P7 photoionisation model.
   * - ``s5blocks.inc``
     - COMMON blocks specific to the S5 shock model.
   * - ``credits.inc``
     - Version string and authorship, included at the top of every source file.

The main entry point is ``mappings.f``.  Initialization is in ``mapinit.f``,
which reads all atomic data from disk at startup.  The physics is distributed
across roughly 80 further ``.f`` files covering individual models, physics
routines, output, and utilities.

-------------------------------------------------
``tools/`` — C post-processing tools
-------------------------------------------------

Three standalone tools written in C, each built with ``gcc -O3``.  They are
independent of the Fortran code and are installed to ``~/mappings520/bin/`` by
``make tools``.

.. list-table::
   :header-rows: 1
   :widths: 15 85

   * - Directory
     - Tool
   * - ``tools/blur/``
     - **blur** — convolve and rebin spectra; optionally normalise by a
       continuum model.
   * - ``tools/lines/``
     - **lines** — Gaussian (or Lorentzian) line fitting using a patch list.
       **listlines** — tabulate or renumber a ``lines`` patch file.
   * - ``tools/red/``
     - **red** — apply reddening corrections to spectra.

Two internal libraries are shared by all three tools:

.. list-table::
   :header-rows: 1
   :widths: 15 85

   * - Directory
     - Library
   * - ``tools/zls/``
     - Array, I/O, FFT, spline, and polynomial utilities used by all three
       tools.
   * - ``tools/zlib/``
     - Compression library that allows the tools to read ``.txt.gz`` input
       files.
   * - ``tools/ccl/``
     - Binary search tree; used by ``lines`` and ``listlines`` only.

Each tool directory also contains a ``samples/`` subdirectory with example
input files and a ``ReadMe.md``.

-------------------------------------------------
``lab/`` — Working directory and runtime data
-------------------------------------------------

``lab/`` is the normal working directory when running MAPPINGS.  It must be
the current directory (or ``$MAPDATA`` must point to it) because MAPPINGS
searches for its data files here at startup.

``lab/map.prefs``
   The default preferences file.  Controls which optional prompts appear
   (kappa mode, expert switches, etc.).  Must be present in the working
   directory.  Variant copies are in ``lab/prefs/``.

``lab/data/``
   Atomic and photon-grid data files read by ``mapinit`` at startup.  These
   are plain-text files; the names are hard-coded in the source.

   .. list-table::
      :header-rows: 1
      :widths: 30 70

      * - File / subdirectory
        - Contents
      * - ``ATDAT.txt``
        - Multi-level ion data: energy levels, collision strengths, A values.
      * - ``PHOTDAT-std.txt``
        - Standard photon energy grid used by photoionisation and shock models.
          Several alternative grids exist (``PHOTDAT-10k.txt``,
          ``PHOTDAT-LogE.txt``, etc.).
      * - ``CONTDAT.txt``
        - Continuum emission data (free-free, free-bound Gaunt factors).
      * - ``STARDAT.txt``
        - Stellar atmosphere grid index.
      * - ``hydrogenic/``
        - Recombination and collision data for H and He: ``HRECDAT.txt``,
          ``HERECDAT.txt``, ``HCOLLDATA.txt``, etc.
      * - ``ionisation/``
        - Ionisation cross-sections, collisional ionisation rates, charge
          exchange, dielectronic recombination: ``IONDAT.txt``,
          ``PHIONDAT.txt``, ``CHXDAT.txt``, ``DRECOMDAT.txt``, etc.
      * - ``lines/``
        - Line data for specific processes: multi-level iron ions
          (``FEDAT.txt``), resonance lines (``RESONDAT2.txt``), kappa
          collision-strength corrections (``KAPPADAT.txt``), recombination
          lines for C II, N II, O I, O II, Ne II, and three-photon data.
      * - ``dust/``
        - Dust opacity data for silicate (``DUSTDATsil.txt``), graphite
          (``DUSTDATgra.txt``), and PAH (``DUSTDATpah.txt``) grain models.

``lab/abund/``
   Abundance table files.  ``solar.txt`` is the default (loaded at startup).
   Subdirectories contain alternative sets:

   - ``AGSS2009/`` — Asplund et al. 2009 solar abundances
   - ``GC2016/`` — Galactic Centre abundances (Groves et al. 2016)
   - ``depletion/`` — depletion correction tables
   - ``other_solar/`` — alternative solar compilations
   - ``misc/`` — miscellaneous sets (LMC, SMC, starburst grids)

``lab/atmos/``
   Stellar atmosphere SED grids used by :doc:`photsou` to define the
   radiation field:

   - ``ATLAS9/`` — Kurucz ATLAS9 LTE stellar atmospheres
   - ``TLUSTY/`` — NLTE O/B star atmospheres (Lanz & Hubeny)
   - ``CMFGEN/`` — NLTE Wolf-Rayet atmospheres (Hillier & Miller)
   - ``WMBASIC/`` — NLTE OB star winds (Pauldrach et al.)
   - ``CSPN/`` — Central star of planetary nebula grids

``lab/examples/``
   Example ``.mv`` input scripts and their output, including a ``cooling/``
   subdirectory with cooling-curve examples.

``lab/prefs/``
   A collection of ready-made ``map.prefs`` files for different configurations
   (standard, full, kappa-enabled, CMFGEN-enabled, H+He only, etc.).

``lab/scripts/``
   Helper scripts for common run sequences, e.g. ``cooling/runcurves.sh``
   for batch cooling-curve runs.

-------------------------------------------------
``scripts/`` — Test suites, grids, and utilities
-------------------------------------------------

``scripts/testScripts/``
   Automated test suites.  Each subdirectory contains ``.mv`` input scripts,
   a run script, and a ``Results/`` directory (created at run time):

   - ``MV52tests/`` — photoionisation and single-zone model tests;
     run with ``bash runtests.sh`` from that directory.
   - ``ShockTests/`` — shock model tests; run with ``bash runshocks.sh``.
   - ``KTTests/`` — kappa-distribution tests.

``scripts/modelgrids/``
   Scripts for computing large model grids:

   - ``HII-grid401/`` — HII region parameter grid
   - ``AGN-fullgridv3/`` — AGN narrow-line region grid
   - ``shockGrids/`` — shock velocity/magnetic-field grids

``scripts/admin/``
   Developer utilities: ``clean.sh`` (remove build products),
   ``format.sh`` (source formatting), ``warnings.sh`` (compile with
   warnings enabled).

``scripts/PythonMAPPINGS/``
   Python wrapper scripts for driving MAPPINGS programmatically from
   Python, including examples for HII region and NLR grids.

-------------------------------------------------
``docs/`` — Documentation
-------------------------------------------------

``docs/sphinx/``
   This Sphinx documentation.  Built with the ``ksl`` conda environment::

      cd docs/sphinx
      conda run -n ksl python3 -m sphinx -b html source html

   Source ``.rst`` files are in ``docs/sphinx/source/``; built HTML lands
   in ``docs/sphinx/html/``.

``docs/doxygen/``
   Doxygen configuration for generating API-level documentation from the
   Fortran source docstrings (``!>``, ``!>``-style comments).  The config
   file is ``mappings_docs.config``.

``docs/doxygen_drafting/``
   Work-in-progress Doxygen material and RST drafts.

``docs/cookbooks_etc/``
   PDF manuals: ``Mappings_guide.pdf`` (the main user guide) and
   ``kappa_mappings_doc.pdf`` (kappa distribution background).

``docs/art/``
   Logo and artwork files for the project.

-------------------------------------------------
``addons/`` — Optional extras
-------------------------------------------------

``addons/altmakefiles/``
   Alternative ``Makefile`` variants for compilers other than ``gfortran``:
   Intel ``ifort``, ``gcc``, ``f2c``, and an older standard Makefile.  Copy
   the desired file to the repo root as ``Makefile`` to use it.

``addons/switches.txt``
   The expert physics toggle file.  Commenting this file and its options is
   deferred to the appropriate documentation page.  Copy to the working
   directory to override the compiled-in defaults for individual physics
   modules (recombination rates, charge transfer, free-free accuracy, etc.).

``addons/mapFull.prefs``, ``mapStd.prefs``, etc.
   Alternative ``map.prefs`` templates for full or reduced physics sets.

``addons/ATDAT-30.txt``
   An alternative atomic data file with a 30-level truncation, for
   reduced-memory or diagnostic runs.

-------------------------------------------------
``bin/`` — Compiled executable
-------------------------------------------------

``bin/map52`` is the compiled MAPPINGS executable.  A placeholder
``bin/keep.txt`` is committed to preserve the directory in git.  The
executable itself is produced by ``make compile`` and installed to
``~/mappings520/bin/`` by ``make install``.

-------------------------------------------------
Root-level files
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - File
     - Purpose
   * - ``Makefile``
     - Root build system.  Targets: ``build``, ``compile``, ``install``,
       ``uninstall``, ``clean``, ``distclean``, ``tools``.
   * - ``README.md`` / ``README.txt``
     - Project overview and quick-start instructions.
   * - ``.readthedocs.yaml``
     - Configuration for automated builds on Read the Docs.
   * - ``.gitignore``
     - Standard ignores: object files, executables, editor temporaries.
