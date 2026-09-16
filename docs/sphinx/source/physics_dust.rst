.. _physics_dust:

##################################################################
Physical Processes: Dust and PAH Physics
##################################################################

This page describes how MAPPINGS treats dust grains and polycyclic
aromatic hydrocarbons (PAHs) as a physical component of the gas — how
they compete with the gas for ionising photons, how they exchange
energy with the gas, and how they re-emit absorbed energy as infrared
continuum. It is about the physics only; for the setup prompts that
configure dust (enabling it, depletion, grain-destruction limits, the
size-distribution model) see :doc:`inputs`. For the ionisation and
radiative-transfer machinery referenced below, see
:doc:`physics_ionization` and :doc:`physics_lines`.

.. contents:: Contents
   :local:
   :depth: 2

-------------------------------------------------
Overview
-------------------------------------------------

When dust is enabled (``grainmode = 1``), grains and PAHs act as a
third component alongside the gas and the radiation field, with three
distinct physical roles:

1. **Opacity** — grains absorb ionising photons that would otherwise
   photoionise the gas, competing directly for the photon budget
   (:doc:`physics_ionization`).
2. **Heating and cooling** — photoelectrons ejected from grains and
   PAHs heat the gas; electrons and ions sticking to (generally
   negatively charged) grain surfaces cool it. Both are genuine terms
   in the same energy-balance tally as the gas-phase heating/cooling
   processes.
3. **Continuum reprocessing** — grains absorb UV/X-ray photons and
   re-radiate the energy as infrared continuum, which is added
   directly to the same transported diffuse field documented in
   :doc:`physics_lines`.

Grain and PAH properties are set up once at the very start of a run
(``grainpar``, called from ``mappings.f`` before any model type is
selected), so dust physics is available to every model type, not just
the photoionisation models — with one significant exception noted
below.

-------------------------------------------------
Grain size distribution and composition
-------------------------------------------------

``grainpar.f`` sets up a power-law grain-size distribution per grain
type (e.g. graphite/carbonaceous and silicate), following either the
classic **MRN distribution** (Mathis, Rumpl & Nordsieck 1977;
N(a) ∝ a\ :sup:`-3.5`, carbonaceous grains 50–2500 Å, silicate grains
100–2500 Å) or a **Jones** distribution (α = −3.3), with the power-law
index and size limits user-adjustable (see :doc:`inputs`).
``solvegraink`` solves for the normalisation constant that ties the
distribution to a specified dust-to-gas mass ratio.

Grain properties are dynamically coupled to elemental depletion:
``graindepletegas(taper)`` scales each depleted element's gas-phase
abundance by a depletion factor ``dion`` that interpolates between its
fully depleted and fully undepleted value as the grain survival
fraction ``taper`` changes (see "Dynamic grain survival" below) — so
an element locked onto grains is progressively returned to the gas
phase as the grains it depends on are destroyed. PAH carbon can
optionally be linked to the same depletion budget as grain carbon
(``clinpah``/``pahcfrac``).

-------------------------------------------------
Grain photoelectric heating and charging
-------------------------------------------------

``hgrains.f`` computes the grain charge and the resulting
photoelectric heating for every grain size bin and type. For each
bin, it solves for the equilibrium grain potential U (volts) by a
binary search for the root of

.. code-block:: none

   f(U) = photoelectric current + electron sticking current
          + proton sticking current  =  0

Photoelectric current comes from photons above a threshold energy
``B`` ejecting electrons with a yield ``Yinf``; the electron/proton
sticking currents depend on the local electron and proton thermal
fluxes and the potential barrier (or well) the charged grain presents
to them. Once U is found, the net kinetic energy carried away by
escaping photoelectrons gives the heating rate (``gheat``); electrons
and ions that stick to the grain and are collected give the
collisional cooling rate (``gcool``). Both are added directly into the
gas's total heating (``tgg``) and cooling (``tll``) accumulators in
``cool.f`` — grains are not a separate energy reservoir tracked
independently of the gas temperature solve, they are simply another
heating/cooling channel in the same balance.

-------------------------------------------------
PAH photoelectric heating
-------------------------------------------------

``hpahs.f`` computes photoelectric heating from PAHs by the same
underlying mechanism as grain photoelectric heating, using yield and
threshold formulae from **Weingartner & Draine (2001, ApJS 134,
263)**. The result (``paheat``) is added into the same ``tgg`` heating
accumulator in ``cool.f`` alongside the grain terms — from the gas's
point of view, PAH heating is just another contribution to the same
energy balance, not a separate calculation.

-------------------------------------------------
Grain temperature and infrared re-emission
-------------------------------------------------

``dusttemp.f`` determines the temperature (or temperature
*distribution*) of each grain size bin and re-emits the absorbed
energy as an infrared continuum, following the algorithm of
**Draine & Li (2001)**, adapted to track enthalpy rather than internal
energy. Two regimes are used depending on the selected IR mode:

- A **quick equilibrium** estimate (``quickir``), balancing absorbed
  power against Planck emission at a single temperature — valid for
  larger grains that reach a steady temperature between photon
  absorptions.
- A **full stochastic-heating** solve for smaller grains, which are
  heated in temperature spikes by single-photon absorption events
  rather than sitting at one steady temperature. ``transmatrix`` builds
  a transition matrix between temperature bins (using grain enthalpy
  functions ``sil_enth``/``gra_enth`` for silicate/graphite) and
  ``probsolve`` solves for the resulting temperature-occupation
  probability distribution.

The resulting infrared photon field (``irphot``) is added directly
into the local diffuse continuum emissivity in ``localem.f``
(``emidifcont(inl) = emidifcont(inl) + irphot(inl)``) whenever
``grainmode = 1``. From that point on, grain IR emission is
indistinguishable from any other continuum source: it propagates
through ``totphot2``/``newdif2`` and appears in the transported
continuum spectrum exactly as documented in :doc:`physics_lines` and
:doc:`physics_output_spectra`.

-------------------------------------------------
Dust opacity and the photon budget
-------------------------------------------------

Dust does not only radiate — it also absorbs. ``crosssections.f``
computes a dust opacity per H atom (``dustsigmat``) alongside the gas
photoelectric opacity (``sigmt``), via ``crosssectionsdust`` (called
instead of the gas-only ``crosssections`` whenever ``grainmode = 1``;
see :doc:`physics_ionization`). Photons absorbed by dust are removed
from the field available to photoionise the gas, so enabling dust
genuinely changes the ionisation balance and the ionisation structure
of the model, not just its thermal balance and continuum shape.

-------------------------------------------------
Dynamic grain survival and depletion
-------------------------------------------------

Grains are not indestructible. ``adjustgrains(t, qh, allowonandoff)``
computes a survival fraction that smoothly ramps to zero above two
independent thresholds:

- a **temperature** threshold (``grainmaxtemp``, with an exponential
  rolloff scale ``grainscaletemp``) — thermal sublimation/destruction
  in hot gas;
- an **ionising-flux** threshold (``grainmaxq``, rolloff
  ``grainscaleq``) — radiative destruction under an intense field
  (e.g. close to an AGN continuum source).

The two survival factors are multiplied together; if the combined
factor reaches exactly zero, grains can be switched off entirely
(``grainmode = 0``) for the rest of that zone's calculation when
``allowonandoff`` permits it. Whenever the survival fraction changes,
``graindepletegas`` re-taper the depletion (see above), ``solvegraink``
renormalises the size distribution, and ``grainfinalise`` finalises the
resulting grain properties for that zone. Dust has no independent
dynamics of its own in this code — no drift velocity or momentum
equation relative to the gas — so "grain destruction" here means the
grain population's mass/opacity is scaled down in place, not that
grains physically move or are entrained differently from the gas.

-------------------------------------------------
A difference between model families
-------------------------------------------------

.. admonition :: Developer Note

   Grain and PAH heating/cooling (``hgrains``/``hpahs``, via
   ``cool.f``) run for **any** model type, since ``cool`` is called
   uniformly and each routine is internally gated only by the global
   ``grainmode`` flag set once at startup. But ``dusttemp`` (grain
   temperature and infrared re-emission) and ``adjustgrains`` (dynamic
   grain destruction) are called only from ``photo6.f``/``photo7.f`` —
   there is no call to either in ``shock4.f`` or ``shock5.f``.

   In practice this means: if dust is enabled for a shock model,
   grains still heat/cool the gas and still remove photons from the
   radiation field via ``dustsigmat``, but the model will **not**
   produce a grain infrared continuum, and grains will **not** be
   dynamically destroyed by high post-shock temperatures or by the
   shock's own radiation field — the destruction thresholds
   (``grainmaxtemp``, ``grainmaxq``) are simply never evaluated in the
   shock zone-stepping loop. This is a real asymmetry verified in the
   source, not a configuration option — getting temperature- or
   flux-dependent grain destruction (e.g. thermal sputtering behind a
   fast shock) or IR output in a shock model would require adding
   those calls to ``compsh5``, not just enabling dust at setup.

-------------------------------------------------
Data flow summary
-------------------------------------------------

.. code-block:: none

   Startup (once): grainpar -> grain size distribution + composition
           |
   Each zone (P6/P7 only for the two starred steps):
           |
           |  crosssectionsdust -> dustsigmat (dust opacity, competes
           |                        with gas photoionisation opacity)
           |
           |  cool.f -> hgrains  -> gheat, gcool  (heating/cooling)
           |         -> hpahs   -> paheat         (heating)
           |            (added into cool.f's tgg / tll accumulators,
           |             alongside all other heating/cooling terms)
           |
           |  * dusttemp -> irphot (grain temperature / IR emission)
           |              -> localem: emidifcont += irphot
           |              -> totphot2/newdif2 (transported continuum,
           |                 see physics_lines / physics_output_spectra)
           |
           |  * adjustgrains -> survival fraction (temperature + flux
           |                     thresholds) -> graindepletegas,
           |                     solvegraink, grainfinalise
           v
   Next zone

-------------------------------------------------
Key routines
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Routine
     - Role
   * - ``grainpar``
     - Sets up the grain size distribution (MRN or Jones power law)
       and composition once at startup, for any model type.
   * - ``solvegraink``
     - Normalises the size distribution to a specified dust-to-gas
       mass ratio.
   * - ``graindepletegas``
     - Scales gas-phase elemental abundances by a depletion factor
       tied to the current grain survival fraction.
   * - ``hgrains``
     - Solves the grain charge-balance equation per size bin/type;
       returns photoelectric heating (``gheat``) and collisional
       cooling (``gcool``).
   * - ``hpahs``
     - PAH photoelectric heating (Weingartner & Draine 2001);
       returns ``paheat``.
   * - ``dusttemp``
     - Grain temperature (equilibrium or stochastic-heating
       distribution, Draine & Li 2001) and infrared re-emission
       (``irphot``). P6/P7 only.
   * - ``adjustgrains``
     - Dynamic grain destruction above temperature/flux thresholds;
       triggers re-depletion and re-normalisation. P6/P7 only.
   * - ``crosssectionsdust``
     - Computes dust opacity (``dustsigmat``) alongside gas opacity,
       feeding the same photon-budget calculation as
       :doc:`physics_ionization`.

.. todo :: Document the exact grain charge-balance equation and yield
   formulae in ``hgrains.f``/``hpahs.f`` in full (this page summarises
   the structure of the solve, not every term), and cross-link this
   page from the (not yet written) heating/cooling and thermal-balance
   page once it exists, since ``gheat``/``gcool``/``paheat`` are
   genuine terms in that balance.
