.. _walkthrough_s5:

##################################
Walkthrough: An S5 Shock Model
##################################

This page runs one concrete S5 shock model end to end — the actual
prompts answered, the actual files it produces, and what is inside
them — so the whole path from "run a shock model" to "here is my line
flux as a function of position" is in one place. :doc:`models`
(prompt order), :doc:`code_s5` (what the solver does internally), and
:doc:`outputs` (full file/column reference) remain the authoritative
pages for those topics; this page does not restate them, it walks one
worked example and points back to them for the general case.

.. contents:: Contents
   :local:
   :depth: 1

-------------------------------------------------
The scenario
-------------------------------------------------

A 200 km/s, α = 1 (equipartition magnetic field) radiative shock into
solar-abundance gas at n\ :sub:`H` = 1 cm\ :sup:`−3`, with MAPPINGS'
auto-iterated photo-ionised precursor and the full internal diffuse
radiation field. The proto-shock gas is started at 1000 K (rather than
a lower guess), the model runs to a 1%-weighted-ionisation ending
condition rather than a fixed temperature floor, and only the standard
output files are requested — a minimal, representative script rather
than one exercising every optional output table.

-------------------------------------------------
The script
-------------------------------------------------

Piped to ``map52`` non-interactively (see :doc:`inputs`, "Running from
a script"). This is a real, tested script — download
:download:`s5_shock200.mv <../../../lab/examples/s5_shock200.mv>` and
its abundance file,
:download:`s5_shock_abund.txt <../../../lab/examples/s5_shock_abund.txt>`,
and run it as shown below. It also ships with every install, in
``~/mappings520/lab/examples/``.

.. literalinclude:: ../../../lab/examples/s5_shock200.mv
   :language: none

Each of these is one instance of the general prompt sequence documented
in :doc:`popcha` (ionisation balance), :doc:`photsou` (radiation
field — zeroed here with ``X`` immediately, since the shock supplies its
own), and :doc:`models` (S5 jump type/field/velocity/density/stopping
prompts) — this page just shows concrete answers.

A few of these are worth spelling out:

* The velocity/density line (``1000.0 1.0 200.0``) answers "Specify the
  proto-shock conditions: T (K), dh (N), v (km/s)". T ≤ 10 is taken as a
  log, so ``1000.0`` (> 10) is read literally as 1000 K; ``2.0`` would
  give the same thing via 10²=100 K. This is the *proto-shock* gas
  far upstream, distinct from the *pre-shock* state immediately ahead of
  the jump (~9600 K in this run), which the precursor solver computes
  self-consistently regardless of the proto-shock guess — see
  "Does the starting temperature matter?" below.
* ``A`` at "Model Ending Condition" is "Standard ending, 1% weighted
  ionisation" — the default stopping rule, needing no follow-up value
  (unlike ``C``/``S``, which ask for a temperature). See :doc:`code_s5`
  for the other lettered stopping criteria.
* In the Output Multi-Option Menu, ``A`` means "Standard output — and
  Reset" (clears any options set so far), so ``A`` then ``X`` produces
  the plain standard output set with none of the optional tables (ion
  balance files, rates, cooling, etc.) — see :doc:`outputs` for what
  each of the other letters adds.
* The output-file prefix (``v200s_``) is read with a fixed-width
  read, not a free-form one — unlike almost every other prompt in this
  script, MAPPINGS does **not** ignore trailing text on this line, so it
  must contain the prefix alone. A trailing underscore keeps generated
  filenames readable, since MAPPINGS inserts no separator of its own —
  see :doc:`outputs`, "Notes on File Naming".

Run it (from wherever you saved the two downloaded files, or from
``~/mappings520/lab/examples/`` if using the shipped copy)::

    map52 < s5_shock200.mv

-------------------------------------------------
Does the starting temperature matter?
-------------------------------------------------

Starting the proto-shock gas at 1000 K instead of a lower guess (e.g.
100 K) does converge, and converges to the same physical state: with a
1000 K start this run's pre-shock temperature settled to 9665.8 K,
post-shock temperature 567 729 K, compression 3.9306 — matching an
otherwise-identical run started at 100 K to within numerical noise
(9605 K / 568 798 K / 3.9362). The precursor solver recomputes the
pre-shock equilibrium state from radiative balance each iteration, so
the proto-shock guess only affects the very first iteration's starting
point, not the converged answer.

It does, however, affect *how many* global iterations are needed: this
run required more than the requested minimum of 3, reaching
"CONVERGED" only after MAPPINGS auto-extended the loop to 5, then ran
one further pass (6 of 6) to write output at the tightened tolerance —
the same behaviour documented in :doc:`code_s5`, "Phase 2c —
Convergence check". A closer initial guess can save a couple of
iterations; a distant one does not prevent convergence, it just costs
a bit more runtime.

-------------------------------------------------
Checking for convergence and other failures
-------------------------------------------------

**A shock model that finishes without a crash has not necessarily
converged.** MAPPINGS never treats non-convergence as a fatal error: if
a run isn't converged within the requested number of iterations, it
silently extends the iteration cap by one and tries again, up to a hard
ceiling of 16 global iterations (see :doc:`outputs`, "Convergence
diagnostics and standard output"). Whatever happens, it then runs one
more pass and writes full output regardless — same exit code, same file
set, no warning anywhere in the ``.sh5``/``.csv`` files themselves.
Concretely, always check the following before trusting a shock result:

1. **Capture stdout.** None of this is recorded in the output files, so
   redirect it when you run the model::

       ./map52 < model.mv | tee run.log

2. **Check the last "SHOCK 5 Convergence Test" block**, not just that
   the program exited cleanly::

       grep "Result:" run.log | tail -1

   It must say ``Result: CONVERGED``. If it says ``NOT CONVERGED``, the
   physical state MAPPINGS wrote out is whatever it reached after
   exhausting all 16 iterations — treat it as unreliable rather than as
   a slow-but-valid answer.

3. **Look at how many iterations it actually took**
   (``grep "Convergence Test" run.log``). This run converged at 5 of an
   extended 5 — comfortably under the ceiling. A run that only reaches
   "CONVERGED" at or near iteration 16 converged in a formal sense but
   was close to not converging at all; it's worth treating with more
   suspicion and, if practical, rerunning with a closer initial guess
   or a less demanding parameter combination to see if it settles
   faster and to the same answer.

4. **Confirm you're reading the actual final output file.** When
   MAPPINGS extends the iteration count beyond what you requested, it
   can start a fresh, higher-numbered output file part-way through,
   leaving the original low-numbered ``.sh5``/``.csv`` files short
   (header only, no "Model ended" line) and the real output in
   ``..._0002.*`` instead. This isn't guaranteed to happen on every run
   that extends — a comparable run in this same session extended from 3
   to 6 iterations without splitting the file — but it's worth checking
   for. The reliable check, independent of the convergence question and
   useful as a general "did this run actually finish" test too, is::

       grep -l "Model ended" shck_*.sh5

   A ``.sh5`` file without that line — whether because of the sequence-
   number split above or a genuine mid-run failure — is not the model's
   final state and should not be used.

-------------------------------------------------
What got created
-------------------------------------------------

With no optional output letters selected (just ``A`` then ``X``), this
run produced only the always-written files:

.. list-table::
   :header-rows: 1
   :widths: 34 66

   * - File
     - Contents
   * - ``shck_v200s_0002.sh5``
     - Post-shock cooling-zone structure (see below). ``_0002`` because
       this run's iteration count was extended — see "Checking for
       convergence and other failures" above.
   * - ``prec_v200s_0002.sh5``
     - Precursor-zone structure, same format.
   * - ``specSHv200s_0002.csv`` / ``specPCv200s_0002.csv``
     - Integrated line list for the shock / precursor (see below).
   * - ``SHupv200s_0001.lam`` / ``.sou``; ``PCupv200s_0001.lam`` / ``.sou``
     - Upstream radiation field snapshots. Written unconditionally —
       not gated by any output-menu option (see :doc:`outputs`).
   * - ``v200s_0001.bln``
     - Blanketed continuum.

No ``elSH``/``elPC`` (needs ``B``), ``bandSH`` (needs ``H``), ``coolSH``
(needs ``K``), ``linSH``/``linPC`` (needs ``L``), or ``SHdw*`` (needs
``E``) — this is the minimal S5 output set. Every pattern and its full
column layout is catalogued in :doc:`outputs` ("Shock Models — S5").

-------------------------------------------------
A peek inside
-------------------------------------------------

``shck_v200s_0002.sh5`` — after the header, abundance table, and the
Rankine-Hugoniot jump summary (preshock T = 9665.8 K, postshock T =
567 729 K, compression factor 3.93), one row per downstream step::

    487, 1.059309E+18, 3.153909E+15, 474.026, 1.75907, 74.1970, 80.5894,
    1.23154, 1.332825E+12, 1.170053E+10, 2.403413E-27, 2.617202E-22,
    3.206194E-02, 0.983858, 1.614224E-02, 1.447985E-04

Columns are step, distance (cm), dr (cm), T (K), n\ :sub:`e`,
n\ :sub:`H`, n\ :sub:`i`, μ, elapsed time, dt, normalised net cooling,
total cooling, d\ :sub:`los`, X(H⁰), X(H⁺), B (G) — the full column
reference is in :doc:`outputs`. By step 487 the gas has cooled from the
567 729 K post-shock plateau to ~474 K — well past the 500 K floor used
in a fixed-temperature-ending run, because the ``A`` ending condition
(1% weighted ionisation) lets the gas keep cooling until it is almost
fully recombined (X(H⁺) ≈ 0.016). The full run reached 187 K before
stopping.

``specSHv200s_0002.csv`` — the integrated shock line list. The high
post-shock temperature reaches ionisation stages a slow shock never
does — the list opens with O VII X-ray lines rather than He II/Mg II::

     Lambda(A),  E (eV) , Flux (HB=1.0), Species  , Kind, Accuracy (1-5)
     =======================================================================
          17.396,  7.12717E+02,  1.32875E-07, O  VII   , CC  ,    3
          21.602,  5.73948E+02,  6.37617E-05, O  VII   , CC  ,    3

-------------------------------------------------
Getting line strength as a function of position
-------------------------------------------------

The above files give you the *integrated* structure and the
*integrated* line list, but not individual line strengths at each
position. For that, add output option ``L`` ("Monitor lines"). Starting
from the same minimal script, only the output-menu section changes —
because ``B`` and ``K`` are not selected, none of their follow-up
prompts (element tracking, cooling normalisation) appear, so the
sequence is shorter than it would be with those options active.
Download :download:`s5_shock200_linemonitor.mv
<../../../lab/examples/s5_shock200_linemonitor.mv>` (uses the same
abundance file as above) — it differs from the base script only in the
output-prefix/menu block:

.. literalinclude:: ../../../lab/examples/s5_shock200_linemonitor.mv
   :language: none
   :lines: 16-21

This produces ``linSHv200sl_0001.csv`` (post-shock zone) and
``linPCv200sl_0001.csv`` (precursor zone), one row per step with the
local flux of each selected line::

     # [1] <X>, [2] DeltaX, [3] dX, [4] t, ... ,    4861.330[14],    6562.820[15],    5006.840[16],
        1,  0.0000    ,  1.08851E+12, ...,  1.87252E-23,  5.73073E-23,  4.59017E-24,

Verified end to end for this scenario: 308 rows in
``linPCv200sl_0001.csv``, 527 in ``linSHv200sl_0001.csv``. All three
monitored lines carry real, sensible, position-varying flux through
both the precursor and the cooling zone (Hβ and Hα in all 527 shock
rows; [O III] in 468 of them — zero only where the gas is too hot for
O⁺⁺ to exist, which is correct physics rather than a matching failure).
Both files share the same selected-line list and header, so a line's
strength can be traced continuously from the precursor through the
shock front and into the cooling zone. See :doc:`physics_output_spectra`
for the underlying mechanism, including a note on when this
position-resolved precursor output was added, and the note below on
the wavelength-matching tolerance this depends on.

.. note::

   Getting a match at all depends on the requested wavelength falling
   within a tolerance of the line's internally tabulated value.
   Wavelengths typed to the usual 2 decimal places match correctly; a
   wavelength that matches nothing stops the run immediately with an
   explicit error rather than silently reporting zero flux. See
   :doc:`physics_output_spectra`, "How a requested wavelength gets
   matched", for the mechanism and the tolerance value.

-------------------------------------------------
Adapting this to your own model
-------------------------------------------------

* **Proto-shock conditions** (``1000.0 1.0 200.0``) — temperature (K,
  or log if ≤ 10), hydrogen density (cm⁻³, or log if ≤ 0), and velocity
  (km/s if < 1e5, else cm/s), in that order.
* **Magnetic parameterisation** (``A`` then ``1.0``) — switch to ``B``
  for a field strength in μG, or ``M``/``C``/``R`` for the other
  parameterisations (see :doc:`models`).
* **Ending condition** (``A``) — switch to ``C``/``S`` for a temperature
  floor (with a follow-up value), ``D``/``E`` for a distance/time limit,
  or ``B`` for a specific ion-fraction threshold; see :doc:`code_s5` for
  what each does internally.
* **Output options** — add ``B`` for per-element ion balance files,
  ``H`` for X-ray/UV cooling bands, ``K`` for cooling-by-element, ``D``
  for rates/timescales, ``C`` for the dynamics file (note the C/D
  menu-label swap documented in :doc:`outputs`), or ``L`` as shown above
  for position-resolved line monitoring — each adds its own follow-up
  prompts before the output menu can be exited with ``X``.
