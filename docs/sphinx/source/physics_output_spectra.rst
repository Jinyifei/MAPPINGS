.. _physics_output_spectra:

##################################################################
Physical Processes: Output Spectra and Line Fluxes
##################################################################

This page explains what the final integrated line fluxes and
continuum spectra written to a model's output files actually
represent — a volume-integrated total, a directional emergent flux,
or something else. It is about the physics of how those numbers are
assembled, not the file formats themselves; for that see :doc:`outputs`.
For the ionisation and radiative-transfer machinery referenced below,
see :doc:`physics_ionization` and :doc:`physics_lines`.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Overview
-------------------------------------------------

Line fluxes and the continuum spectrum are assembled by two
**different mechanisms**, and neither is quite "the emission in a
particular forward/backward direction" in the way that phrase usually
implies for angle-dependent transfer:

- **Line fluxes** are a volume integral of each zone's local line
  emissivity, summed over every zone in the model. No optical depth
  or escape weighting is applied *between* zones at this stage.
- **The continuum spectrum** is the actual radiatively-transferred
  diffuse field, i.e. a snapshot of the same ``tphot`` array that
  ``totphot2``/``newdif2`` build up zone by zone (see
  :doc:`physics_lines`), taken at the outer boundary.

Both mechanisms are implemented in shared routines called identically
by the shock model (``shock4.f``, ``shock5.f``) and the photoionisation
models (``photo6.f``, ``photo7.f``) — the exact call sites are listed
below, confirming this is not something that differs between model
families.

-------------------------------------------------
Line fluxes: volume-integrated local emissivity
-------------------------------------------------

Every line-flux array — H/He recombination series (``hydroflux``,
``heliflux``), forbidden/semi-forbidden collisionally-excited lines
(``fluxm``, ``fluxfe``, ``fluxf3``), resonance lines
(``xr3lines_flux``, ``xrllines_flux``), and the rest — is accumulated
in ``sumdata.f``, called once per zone immediately after that zone's
ionisation and emissivity solve. The pattern is the same for every
species:

.. code-block:: none

   wei          = dvol * fi
   fluxX(line)  = fluxX(line) + Xbri(line) * wei

where ``Xbri`` is the zone's local line brightness (erg cm\ :sup:`-3`
s\ :sup:`-1` sr\ :sup:`-1`, computed by ``multilevel.f`` for
collisionally-excited lines or ``hydro.f`` for H/He recombination
lines), ``dvol`` is the zone's volume element, and ``fi`` is the
filling factor. This sum runs over **every zone from the inner
boundary to the stopping radius** with a plain addition — no
attenuation, no escape probability, no distance or aperture factor is
applied at this stage. ``avrdata.f`` subsequently only rescales the
totals (e.g. relative to Hβ = 100 for the line-list output); it adds
no further transport.

So a line flux in the output represents the **total nebula-integrated
line luminosity** (up to the overall units/normalisation chosen at
output), not a directionally-resolved quantity, and not one further
reduced by having to cross intervening zones' opacity on the way out.

Local radiative-transfer physics already inside the brightness
==================================================================

This doesn't mean line fluxes are entirely transfer-free. The *local*
brightness fed into ``sumdata`` already reflects some
radiative-transfer physics computed within that zone:

- ``hydro.f`` computes ``hydrobri`` by interpolating between
  full-Case-A and full-Case-B line-ratio tables, weighted by the
  local Lyman-line escape fraction (``casab``; see :doc:`physics_lines`).
  So the recombination cascade branching already reflects local
  Lyman-photon trapping.
- Forbidden/semi-forbidden lines are modelled as always optically thin
  (:doc:`physics_lines`), so for those species summing local
  emissivity over volume is exact — there is nothing to transfer.

What is *not* accounted for is a line photon, once counted as having
escaped its zone of origin, being reabsorbed by the line opacity of
zones further out on its way to an observer. That reabsorption is
simply not modelled for the flux tally (as distinct from the
diffuse-field bookkeeping in :doc:`physics_lines`, which *is* used to
determine local trapping and feeds back into ionisation/heating, but
which does not itself feed the flux totals in ``sumdata``).

-------------------------------------------------
Continuum spectrum: the transported diffuse field
-------------------------------------------------

The continuum spectrum output (``.lam``, ``.csv`` 4-flambda tables) is
built differently. The writer routines (``wplam4`` for P6/P7,
``wpsou``/``wpsoufile`` for the shock models — ``wpsou`` calls
``wpsoufile`` directly, so both ultimately go through the same code)
take a field array (``tp1``…``tp4``, populated from ``tphot`` and its
source/nebula-only/nebula-continuum variants) and do nothing more than
a **unit conversion**:

.. code-block:: none

   tp(j) = fpi * scale * bv * tp(j) / clam

No further summation over zones happens inside the writer. The
transport already happened earlier, when ``tphot`` was built up
zone-by-zone by ``totphot2``/``newdif2`` using the real photoelectric
optical depth (:doc:`physics_lines`). So the continuum spectrum
genuinely is an emergent, attenuated quantity — a snapshot of the
outward-propagating diffuse field at the point the field array was
captured — unlike the line fluxes, which never pass through that
zone-to-zone attenuation step at all.

----------------------------------------------------------
Position-resolved output: the line-monitor feature
----------------------------------------------------------

The line fluxes described above are cumulative — by the time
``sumdata`` has summed a zone's contribution into ``fluxX``, the
per-zone value is gone. Getting line flux **as a function of
position** requires a separate, opt-in mechanism: the "monitor lines"
feature.

Enabling it and what gets written
====================================

At setup this is offered as an additional mode on top of the standard
run: mode ``J`` in P6 ("Standard + B + monitor up to N lines"), mode
``L`` in P7 ("Monitor up to N lines"), and mode ``L`` in S5 ("Monitor
up to N lines — precursor and shocks"). Up to ``mxmonlines`` = 32
lines can be selected by index.

Once enabled, every zone calls ``speclocallines``, which returns the
**local** brightness (not the running sum) of each selected line at
that zone, and writes one row per zone to a dedicated ``lines*.csv``
file: distance, zone width ``dr``, T, n\ :sub:`e`, n\ :sub:`H`, Hβ,
then the local emissivity of each monitored line. The file's own
header is explicit about what it contains:

   *"Line emissivities (erg/cm^3/s/sr) for N lines as a function of
   distance or radius. Weight by shell volumes x4pi to get
   luminosities."*

In other words, this file hands you the raw ingredient — local
emissivity vs. position — and leaves the volume weighting (to get a
cumulative or partial luminosity curve) to you, rather than doing it
for you the way ``sumdata`` does for the final total.

Companion monitor outputs
============================

Three related opt-in outputs give other position-resolved quantities
by the same mechanism: ``jiem`` (up to 4 monitored multi-level ions,
full per-transition local brightness — the same ``fmbri`` that feeds
the CEL flux totals), ``jiel`` (ionisation fraction vs. position for
chosen elements), and ``jcol`` (column density vs. position).

Shock models: two files, one incomplete
==========================================

S5 creates two separate monitor files: ``linSH*.csv`` for the
post-shock cooling zone (position = ``dist(step)``, distance behind
the shock front) and ``linPC*.csv`` for the precursor.

.. admonition :: Developer Note

   ``linSH*.csv`` is fully functional: the per-step loop in
   ``compsh5`` calls ``speclocallines`` and writes a complete row
   every step (``shock5.f`` ~line 3497).

   ``linPC*.csv`` is **not** currently populated. The precursor's
   zone-stepping routine, ``multizone`` (called from
   ``shock5precursor``), calls ``sumdata`` to accumulate the
   integrated precursor spectrum, but at no point calls
   ``speclocallines`` or writes a data row into ``linPC``'s file unit
   — only the file header gets written, during setup. This is a real
   gap traced in the source, not a configuration issue: **selecting
   the monitor-lines option will not produce position-resolved line
   data for the precursor, no matter how the model is run.**

   Getting this data would require a source change, not just a
   different run configuration: adding a ``speclocallines`` call and
   a formatted write into ``linPC``'s file unit inside ``multizone``'s
   per-zone loop (``shock5.f``, in the same style as the existing
   block in ``compsh5`` around line 3497), keyed to that loop's
   position variable (``x0``) rather than ``dist(step)``. Until that
   change is made, the only precursor diagnostics available as a
   function of position are the ones already wired up independently
   of ``jlin`` — e.g. whatever ``multizone``'s caller writes from
   ``popfr``/``popintfr`` — not local line emissivities.

-------------------------------------------------
Verified identical in both model families
-------------------------------------------------

The line-flux and continuum-output mechanisms above are not specific
to the photoionisation models. The same subroutines are called from
the same points in the zone-stepping loop in both ``shock4.f``/
``shock5.f`` and ``photo6.f``/``photo7.f``:

.. list-table::
   :header-rows: 1
   :widths: 25 37 38

   * - Mechanism
     - Photoionisation (P6/P7)
     - Shock (S4/S5)
   * - Volume-integrated line fluxes
     - ``call sumdata`` in ``photo6.f`` / ``photo7.f``
     - ``call sumdata`` in ``shock4.f`` / ``shock5.f``
       (post-shock cooling zone **and** precursor zone)
   * - Flux normalisation / line list
     - ``call avrdata`` then ``call spec2`` in ``photo6.f`` /
       ``photo7.f``
     - ``call avrdata`` then ``call spec2`` in ``shock4.f`` /
       ``shock5.f``
   * - Transported continuum field written out
     - ``call wplam4`` (-> ``wpsoufile``) in ``photo6.f`` / ``photo7.f``
     - ``call wpsou`` (-> ``wpsoufile``) in ``shock4.f`` / ``shock5.f``
   * - Field the writer draws from
     - ``tphot``, built by ``totphot2``/``newdif2`` during the
       outward march
     - ``tphot``, built by ``totphot2``/``newdif2`` during the
       cooling-zone march **and** the precursor march (see
       :doc:`physics_shocks`)

The one shock-specific wrinkle is that ``sumdata`` is called for
**both** the post-shock cooling zone (``compsh5``) and the precursor
zone (``shock5precursor``) — so a shock model's line-flux and
continuum totals are themselves a superposition of two separately
volume-integrated / separately transported regions (downstream cooling
zone and upstream precursor), rather than a single march as in P6/P7.
That superposition happens at the level of *which zones* contribute,
not a difference in *how* each zone's contribution is computed or
combined — the underlying mechanism documented above is identical.

-------------------------------------------------
Practical implication
-------------------------------------------------

.. admonition :: Developer Note

   Because line fluxes and the continuum are built by genuinely
   different mechanisms, they are not on equal radiative-transfer
   footing: the continuum is attenuated crossing every zone out to the
   boundary; line photons are not, once past their own zone's local
   escape probability. In practice this is a reasonable approximation
   because line optical depths are usually far smaller than the
   continuum photoelectric opacity that matters for attenuation, but
   it is a real asymmetry in the code, not an oversight to be
   "matched up" — the two quantities are constructed for different
   purposes (total nebular line luminosity vs. emergent spectral
   energy distribution) and happen to share the word "spectrum".

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   Each zone: local line brightness (Xbri) + local continuum
   emissivity feeding tphot via totphot2/newdif2
           |
           |  sumdata:  fluxX += Xbri * dvol * fi      (every zone,
           |            no cross-zone attenuation)              |
           |                                                     |
           |  totphot2/newdif2: tphot attenuated zone to zone     |
           |            (crosssections opacity, escape probability)
           v                                                     v
   avrdata + spec2                                    wplam4 / wpsou(file)
   -> line list / .csv                                -> tphot snapshot,
      (total nebula-integrated                            unit-converted only
       line luminosity)                                -> .lam / 4-flambda .csv
                                                           (transported emergent
                                                            spectrum)

-------------------------------------------------
Key routines
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Routine
     - Role
   * - ``sumdata``
     - Accumulates every line-flux array as local brightness × zone
       volume × filling factor, summed across zones. No cross-zone
       transport.
   * - ``avrdata``
     - Rescales the accumulated line fluxes (e.g. relative to Hβ);
       adds no further transport.
   * - ``spec2``
     - Writes the final line list / spectrum table from the
       accumulated, rescaled fluxes.
   * - ``hydro``
     - Computes local H/He recombination-line brightness via a
       Case A/B blend set by the local Lyman-line escape fraction.
   * - ``multilevel``
     - Computes local forbidden/semi-forbidden line brightness;
       always optically thin (see :doc:`physics_lines`).
   * - ``totphot2`` / ``newdif2``
     - Build up the transported diffuse field ``tphot`` zone by zone
       (shared with the ionisation/heating calculation; see
       :doc:`physics_lines`).
   * - ``wplam4`` / ``wpsou`` / ``wpsoufile``
     - Write the continuum spectrum by unit-converting a snapshot of
       ``tphot`` (and its source/nebula-only/nebula-continuum
       variants). No summation over zones happens here.
   * - ``speclocallines``
     - Returns the local (not cumulative) brightness of each
       user-selected monitored line at the current zone; the source of
       the position-resolved ``lines*.csv`` / ``linSH*.csv`` output.

.. todo :: Trace the exact normalisation applied at output (per-unit
   area at a reference distance vs. total luminosity vs. relative to
   Hβ = 100) for each output file type.
