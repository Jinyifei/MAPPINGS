.. _adv_kappa:

##############################################
Kappa Electron Energy Distributions
##############################################

By default MAPPINGS assumes the free electrons in a plasma are in thermal
equilibrium with a Maxwell–Boltzmann (M-B) energy distribution.  An
alternative "kappa distribution" is also supported.  This page describes
what the kappa distribution is, why it may be physically relevant, how to
enable it, and how to set the kappa parameter when running a model.

.. contents:: Contents
   :local:
   :depth: 1


-------------------------------------------------
What is the Kappa Distribution?
-------------------------------------------------

The kappa distribution is a M-B distribution with an additional
high-energy power-law tail.  It was introduced by Vasyliunas (1968,
ADS 1968JGR....73.2839V) to describe the electron energy distributions
measured directly by satellites and space probes in solar system plasmas,
where non-Maxwellian distributions are the norm rather than the exception.

The shape is controlled by a single index κ (kappa).  In the limit
κ → ∞ the distribution reduces exactly to a Maxwellian.  Smaller values
of κ produce a more pronounced high-energy tail and a greater departure
from M-B equilibrium; the minimum physically meaningful value is κ = 2.

Applied to nebular modelling, a kappa distribution

- **enhances** collisional excitation of high-energy levels (e.g. the
  :sup:`1`\ S\ :sub:`0` level of [O III] responsible for the 4363 Å
  auroral line);
- **reduces** excitation of intermediate-energy levels (e.g. the
  :sup:`1`\ D\ :sub:`2` level of [O III] responsible for 5007 Å);
- **enhances** low-energy processes such as recombination.

These effects shift the apparent electron temperature inferred from line
ratios and may explain the long-standing discrepancy between electron
temperatures and chemical abundances measured from collisionally excited
lines (CELs) versus optical recombination lines (ORLs) — the "abundance
discrepancy problem".

For a thorough discussion see Nicholls et al. (2012, 2013, 2017 and
references therein; ADS 2012ApJ...752..148N, 2013ApJS..207...21N,
2017mcp..book...633N).


-------------------------------------------------
Enabling Kappa Mode
-------------------------------------------------

Kappa mode is **disabled by default**.  To enable the kappa prompt at
startup, open ``map.prefs`` (normally ``~/mappings520/lab/map.prefs``)
and add the keyword block::

    Kappa Mode
    1

The keyword ``Kappa Mode`` must appear on its own line; ``1`` on the
following line enables the prompt (``0`` disables it).  Copy the edited
``map.prefs`` into the working directory before starting MAPPINGS.

.. note::
   Kappa mode is **not** controlled by ``switches.txt``.  The
   ``switches.txt`` file governs low-level physics toggles unrelated to
   the electron energy distribution.


-------------------------------------------------
Setting the Kappa Value at Runtime
-------------------------------------------------

When kappa mode is enabled, a new prompt appears during startup (Step 3
of the initialisation sequence, between the abundance offsets step and
the dust step)::

    Electron Energy Distributions:
    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    Maxwellian thermal distributions are being used.
    Use Kappa electron distributions ? (y/N) :

Enter ``N`` (or press Return) to proceed with a standard Maxwellian.
Enter ``Y`` to use a kappa distribution; MAPPINGS then asks::

    Select a Kappa value
    (2.0 - 1000.0, outside this range disabled)
    (2.0, 3.0, 4.0, 6.0, 10.0, 20.0, 50.0, 100.0 are exact) :

The valid range is 2.0 ≤ κ ≤ 1000.0.  The eight values listed are
computed directly from tabulated data; all other values in the range are
obtained by interpolation.  Values outside the range disable kappa and
revert to a Maxwellian.  The lower the value, the greater the departure
from M-B equilibrium.

The computation then proceeds identically to a standard Maxwellian run;
only the internal collisional excitation rates are modified.


-------------------------------------------------
Physical Background
-------------------------------------------------

Historical context
==================

It has been accepted since the 1940s that electrons in HII regions and
PNe are in thermal equilibrium.  Bohm & Aller (1947,
ADS 1947ApJ...105..131B) found the velocity distribution to be "very
close to Maxwellian", and Spitzer (1962) showed that electron energies
equilibrate rapidly through Coulomb collisions.  This led later authors
to assume M-B equilibrium universally.  However, Spitzer also showed
that the equilibration time of an energetic electron scales as the cube
of its velocity, meaning very high-energy electrons take much longer to
thermalise than those produced by normal UV photoionization.

Direct measurements in solar system plasmas by satellites and space
probes find that electron energy distributions depart substantially from
Maxwellian and resemble a M-B with a high-energy power-law tail —
precisely the kappa form.  IBEX observations of energetic neutral atoms
at the heliosheath boundary provide further evidence.  In solar system
plasmas, kappa distributions are more common than M-B distributions.

Physical origin
===============

The kappa distribution arises naturally from Tsallis "q non-extensive
statistical mechanics", in the same way the M-B distribution arises
from Boltzmann–Gibbs statistics.  The requirement is that macroscopic
interactions between forces and particles operate in addition to the
short-range Coulombic forces that produce M-B equilibration.

Non-Maxwellian electron energy distributions arise whenever the
energetic-electron population is being replenished on a timescale
shorter than the collisional redistribution timescale.  Candidate
mechanisms in nebulae include:

- Magnetic reconnection followed by migration of high-energy electrons
  along field lines
- Development of inertial Alfvén waves
- Local shocks driven by supersonic turbulence or colliding bulk flows
- Photoionization itself — normal UV photoionization produces
  supra-thermal electrons on a timescale similar to the recombination
  timescale; X-ray inner-shell (Auger) ionization produces keV electrons
- Photoionization of dust grains, which releases energetic electrons
  into the gas

The probability of a kappa distribution is enhanced in plasmas with a
hard ionizing spectrum: AGN-photoionized regions, planetary nebulae
(where the central star can reach ~250 000 K), and high-redshift HII
regions excited by very low metallicity O-stars.

Moreover, there is evidence that kappa distributions with κ ≲ 2.5 can
remain stable — or even evolve to lower κ — through the increase of
non-extensive entropy, giving rise to time-invariant "stationary states"
with lifetimes longer than classical collisional thermalisation would
predict.  This is consistent with the ubiquity of kappa distributions in
solar system observations.

Relevance to the abundance discrepancy problem
===============================================

For several decades, systematic discrepancies have been found between
nebular abundances derived from CELs and those from ORLs and the
hydrogen/helium bound–free continuum — the "abundance discrepancy
problem".  A kappa electron energy distribution provides a natural
explanation: the enhanced high-energy tail raises the apparent CEL
temperature while leaving the ORL temperature largely unchanged,
mimicking the observed discrepancy without requiring inhomogeneous
abundances.

The kappa distribution capability in MAPPINGS was implemented to allow
direct comparison of kappa-model predictions with observed nebular
diagnostics in HII regions, AGN narrow-line regions, planetary nebulae,
and shocks.
