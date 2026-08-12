.. _code_overview:

###########################
Code Operation: Overview
###########################

This section describes how MAPPINGS operates internally — what the code
actually does when a model runs, beyond what inputs it accepts and what
output files it produces.  Each page traces the execution through the
relevant Fortran source files.

The source code lives in ``src/``.  All global state is shared through
Fortran COMMON blocks declared in the ``.inc`` include files
(``cblocks.inc``, ``s5blocks.inc``, ``p6blocks.inc``, ``p7blocks.inc``).
The main entry point is ``src/mappings.f``, which calls the startup
sequence and then dispatches to the selected model subroutine.

.. contents:: Contents
   :local:
   :depth: 1

-------------------------------------------------
Common startup sequence
-------------------------------------------------

Before any model runs, ``mapinit`` reads all atomic data from disk.
The interactive startup then steps through abundances, kappa mode (if
enabled), and dust, as described in :doc:`inputs`.  The model subroutine
is then called directly.

Two subroutines are shared by most models:

- :doc:`popcha` — sets the initial ionisation balance of the gas
- :doc:`photsou` — defines the incident radiation field

The pages below trace *control flow* through each model type. For the
underlying physical processes (ionisation balance, line radiative
transfer, ...) organised by topic rather than by call sequence, see
:doc:`physics_overview`.

-------------------------------------------------
Photoionisation models
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 15 85

   * - Model
     - Operation page
   * - P6
     - :doc:`code_photo`
   * - P7
     - :doc:`code_photo`

-------------------------------------------------
Shockwave models
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 15 85

   * - Model
     - Operation page
   * - S5
     - :doc:`code_s5`

-------------------------------------------------
Single-zone models
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 15 85

   * - Model
     - Operation page
   * - SS
     - :doc:`code_singlezone`
   * - CC
     - :doc:`code_singlezone`
   * - NC
     - :doc:`code_singlezone`
   * - PP
     - :doc:`code_singlezone`

-------------------------------------------------
Test-atom models
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 15 85

   * - Model
     - Operation page
   * - MM
     - :doc:`code_testatom`
   * - CD
     - :doc:`code_testatom`
   * - TE
     - :doc:`code_testatom`
