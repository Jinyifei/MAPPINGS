.. _popcha:

######################################
Setting the Initial Ionisation State
######################################

Before computing a model, MAPPINGS needs to know the starting ionisation
balance of the gas — how much of each element begins in each ionisation
stage.  This is handled by a shared setup step that appears in the
photoionisation models (P6, P7), shock model (S5), single-slab model (SS),
and PIE curve model (PP).

The cooling models (CC, NC) and test-atom models (MM, CD, TE) bypass this
step entirely: CC and NC start from CIE, and MM/CD/TE work on isolated
ions rather than a full gas mixture.

.. contents:: Contents
   :local:
   :depth: 1

-------------------------------------------------
The Prompt
-------------------------------------------------

MAPPINGS displays the default ionisation rule and then presents the menu::

    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
     Setting the ionisation state for  <model>
    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
     Default: Elements with ionisation potentials
     above 1 Rydberg are neutral.  All others are
     singly ionised.

    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
     Choose an ionisation balance:
    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
       C  : Calculate a preionisation balance
       D  : Default ionisation values

       E  : Enter ionisation values
       F  : read a ionisation balance from a File
       S  : Save current balance to a File

       X  : eXit with current balance
    ::

The menu loops: after ``C``, ``F``, ``S``, or ``E`` the menu is
redisplayed so that multiple adjustments can be chained.  Enter ``X`` (or
``D`` to accept the default) to proceed to the next step.

-------------------------------------------------
Options
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 8 92

   * - Key
     - Action
   * - D
     - **Default** — elements with ionisation potentials below 1 Rydberg
       (13.6 eV) are set to singly ionised; those above are set to neutral
       (with a trace fraction 10\ :sup:`−2` to avoid a fully neutral
       starting point).  This is safe for most nebular models.
   * - C
     - **Calculate** — calls the single-slab equilibrium solver
       (``sinsla``) to compute a self-consistent ionisation balance at the
       current temperature and density before the main model starts.  Useful
       when the starting conditions are far from the default.
   * - E
     - **Enter manually** — prompts for an element number (0 to finish,
       99 for all elements) then accepts the ionisation fractions for each
       stage of that element interactively.
   * - F
     - **File** — reads a saved ionisation balance file.  The file is
       searched for first as given, then in ``$MAPDATA/``.  Format: lines
       beginning with ``%`` are comments; one title line; one line giving
       the number of entries; then one line per entry as
       ``<Z>  <ion>  <fraction>`` where negative fractions are interpreted
       as log\ :sub:`10`.
   * - S
     - **Save** — writes the current ionisation balance to a file in the
       same format, which can be reloaded later with ``F``.
   * - X
     - **Exit** — proceed to the next step using whatever balance is
       currently set.

-------------------------------------------------
Notes
-------------------------------------------------

The default ionisation balance is almost always adequate for photoionisation
models because the solver iterates to equilibrium within the first few
zones.  The ``C`` (calculate) option is more useful for shock and
time-dependent models where the pre-shock gas needs to start in a realistic
partially ionised state.

The saved balance files produced by ``S`` can be reused across sessions or
shared between models.  They carry the same ``%``-comment, title,
nentries, and ``Z ion fraction`` format as abundance files.
