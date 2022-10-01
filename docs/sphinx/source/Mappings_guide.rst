Mappings Guide
##############
.. container::

|image|

.. container::

   .. rubric:: Purpose of this document
      :name: purpose-of-this-document

This document is an introduction to MAPPINGS. It describes what MAPPINGS
does, how to install it, the input and output parameters, with examples,
including how to run a simple HII region model and generating isolated
single atom models.

.. container::

   .. rubric:: Who should read this? And how?
      :name: who-should-read-this-and-how

The document is aimed at beginning users and as a refresher for people
who have not used MAPPINGS for some years, or who have only used much
older versions. It is intended to be read in a linear mode, from start
to finish.

.. container::

   .. rubric:: What is MAPPINGS and what does it do?
      :name: what-is-mappings-and-what-does-it-do

MAPPINGS is photoionisation modelling code written in FORTRAN. It allows
one to compute nebular emission spectra from the far UV
(:math:`\sim`\ 300 Å) to the far IR (:math:`>`\ 600 :math:`\mu`). It
calculates emission line fluxes for recombination lines,
intercombination lines and collisionally excited lines for all elements
from hydrogen to zinc, where these exceed a (presettable) minimum flux.
MAPPINGS began in 1976 as a five-level-atom solver. It has gone through
major upgrades since then and is currently at version 5.1

It can be used to model HII regions, Planetary Nebulae, AGN emission
regions and shockwaves in the interstellar medium.

It is unique among major photoionisation modelling codes in handling
emission lines from shocks. It is also (as far as we know) the only code
capable of working with kappa non-equilibrium electron energies.
Further, it incorporates element abundance scaling based on the
abundance patterns in old stars, rather than uniform linear scaling,
which we know to be wrong (Nicholls, Sutherland et al, 2017, ADS
2017MNRAS.466.4403N, especially Figure 1).

It uses the latest and best available atomic data, drawing on the
Chianti8 database where possible (Del Zanna, Dere et al., 2015, ADS
2015A&A...582A..56D).

.. container::

   .. rubric:: What this document covers (and does not cover)
      :name: what-this-document-covers-and-does-not-cover

As MAPPINGS is a complex and sophisticated application, writing a
complete user manual is a daunting task. We propose to incorporate the
current document as part of a wiki which will expand piecewise as we
cover the full range of MAPPINGS capabilities. In the meantime, this
document provides a guide to starting with MAPPINGS. It explores only
modelling HII region models. Discussion of modelling AGN spectra and
shock emission lines will be added later.

.. container::

   .. rubric:: Downloading MAPPINGS
      :name: downloading-mappings

The latest public version of the MAPPINGS source code (5.1.13) is
available from https://mappings.anu.edu.au/code/ Initially, download
"Everything including stellar/agn atmospheres" (217MB).

.. container::

   .. rubric:: What to know before you start
      :name: what-to-know-before-you-start

To install and run MAPPINGS, you should be familiar with running
commands from the terminal. At some point, you may need to edit
pre-defined command scripts to set input parameters and to point to the
data directories, depending where the data files are located with
respect to the working area. The standard work area is the /lab
directory. Download MV_atmos.zip Stellar atmospheres (192.8MB). Unzip to
create the atmos directory and move the atmos directory into the lab
area.

.. container::

   .. rubric:: Installing MAPPINGS
      :name: installing-mappings

These directions are intended for Mac users but are readily adaptable to
Linux and other Unix versions. They apply to OSX version 10.9
(Mavericks) onwards. In what follows, we use the ``Courier`` typeface
for terminal commands and file names.

For maximum computational efficiency you will need a FORTRAN compiler.
MAPPINGS will compile with a variety of FORTRAN compilers, but probably
the most useful is gfortran. This runs on Linux (various flavours) and
Mac OSX platforms.

An alternative is to install the f2c application which can be found in
the /src directory in the MAPPINGS download. This converts the MAPPINGS
code to compilable C, for compilation using the Apple or other C
compilers. This results in a somewhat slower compiled application. Also
note that if you need to compile MAPPINGS this way, you will need to use
the correct make file (in the /src directory). Rename ``Makefile.f2c``
to replace the default ``Makefile`` in the /src directory.

Before you can run the standard ``Makefile`` on OSX, it is necessary to
install Apple’s Xcode on the Mac, and the command line tools. These are
available via the Appstore. This is a large download but is necessary
for installing appropriate compilers.

To install gfortran on Mac OSX, you will next need to install Macports.
See https://www.macports.org. When the Macports framework is installed,
the next step is to install the GNU compiler collection from the command
line. This is done with the command: ``sudo port install gcc10`` . This
installs both the GNU C compiler (version 10) and the gfortran compiler
(version 10).

At present we recommend you use the latest gfortran version, currently
gfortran8. If you are using an older version of Mac OSX (for example,
10.9 Mavericks, because you have an old Mac computer), gfortran version
4.9 is the better choice. Also note that in this case you will need a
legacy Macports install. Refer to the Macports website for details. To
check the gfortran compiler is installed and available, use the
following command in the terminal: ``gfortran –version``. If this does
not confirm the version, you will need to seek assistance.

When Xcode, the command line tools, Macports and the GNU compilers are
installed, unzip the mappings download into a new directory. The
MAPPINGS makefile is found in the /src directory.

Install in the standard way from the /src directory using
``make install``. Full installation instructions are included in the
``README.txt`` file. This is a comprehensive description of the
installation and you should read it carefully before commencing. it is
included as Appendix 1 in this document.

Open the readme file or go to the appendix below and follow the
instructions. MAPPINGS can be run from the /lab directory, but the best
approach, as described in the readme file, is to make a universal
install which can be run from any location using the command map51 .

.. container::

   .. rubric:: MAPPINGS data inputs
      :name: mappings-data-inputs

There are several types data input for MAPPINGS: physical model
parameters (pressure, density, ionisation parameter etc.), atomic data,
dust depletion data, abundance scaling data, standard abundances, and
excitation spectra.

The main data are contained in extensive libraries in the
sub-directories in the /lab directory. The HIIGrid306 directory contains
additional libraries of abundances and pre-calculated synthetic cluster
spectra derived from the Starburst99 spectral synthesis code. The input
data are described in more detail below.

.. container::

   .. rubric:: Ways to run models
      :name: ways-to-run-models

You can run MAPPINGS models in three ways: entering input data an entry
at a time at the input prompts; pasting a single model file at the first
MAPPINGS input prompt; or running a multi-model shell script, for
example to create log(Q)/metallicity grids for strong line ratios.

You can also use Mappings to run single atom models at specified
temperatures and densities, but while useful, these do not correspond to
physical nebulae.

.. container::

   .. rubric:: Running a single model
      :name: running-a-single-model

In the terminal, change to the /lab directory. Run the command ./map51 .
You will be presented with a series of prompts as MAPPINGS requests the
data it needs to run a model. These relate to abundance data, type of
model, physical parameters (e.g., pressure, starting temperature,
ionisation parameter etc). We will now describe the main prompts and
responses. For the purpose of this guide, we will assume we are
modelling an HII region isobaric (constant pressure model) with
log(P/k)=6.0 with a metallicity 12+log(O/H)=8.53 and an ionisation
parameter log(Q)=8.0.

The following text is a commented sequence of typical inputs. Use this
as an exercise. Enter one entry at a time, ignoring the ":" and
subsequent text. In most cases, MAPPINGS ignores any string content
after the required response. At each entry, the next options will be
presented. You can explore these later, but this input file should suit
most simple models. You can edit the file and cut/paste the whole file
at the prompt when you are happy with the settings.

.. container::

   .. rubric:: Sample HII region single model input file for MAPPINGS
      :name: sample-hii-region-single-model-input-file-for-mappings

::

   yes   : change abundance
   abund/GC16Grid/GC\_ZO\_M0530.abn
   no    : no more changes
   no    : no offsets
   no  : Use Kappa electron distributions 
   yes   : include dust
   yes   : change depletions
   abund/unified_depletion/Depln_Fe_1.50.txt\\
   no    : no more changes
   no    : allow grain destruction
   M     : MRN distribution
   yes   : Include PAH molecules?
   0.3   : fraction of Carbon Dust Depletion in PAHs
   Q     : PAH switch on QHDH < Value
   4e2   : PAH switch on Value
   no    : graphite grains to be cospatial with PAHs
   no    : Evaluate dust temperatures and IR flux?
   P6    : the main Mappings model to use
   D     : Default ionisation values
   H     : Input spectral energy distribution data (usually Starburst99)
   Q/inputs/cont\_a05t23isp\_vm802.spectrum
   9     : Age of the HII region. Age = (n-1)*0.5 Myr
   X     : eXit with current source
   N     : Include cosmic ray heating
   S     : Spherical Geometry. (For Plane parallel, 'P', different options)
   L     : Source by Luminosity
   T     : Total or Ionising Luminosity
   40    : bolometric source luminosity (log erg/s)
   B     : isoBaric, (const pressure)
   6.0 :  Pressure regime (p/k, <10 as log)
   4     : log(Initial temperature)
   1     : filling factor (0<f<=1)
   q     : Give initial radius in terms of distance or Q(N) (d/q) ***nb old  options
   8.0 :   Q at inner radius (< 100 as log)
   y     : Volume integration over the whole sphere? (y/n)
   E     : Equilibrium ionization balance.
   0.02  : Step value of the photon absorption fraction  *******
   A     : Ionisation bounded, 99\% neutral **********
   A   : Standard output
   SPH\_zM0530\_Q80\_Pk6\_cont\_a05\_t23\_step9\_M5118 : ID string
   X   : end model

The model starts running as soon as the ID string is entered and the
interim values for a series of physical parameters are displayed on the
terminal screen as the computation proceeds. The final option, after the
model finishes, asks if you want to run another model or exit. Enter X
to terminate.

Depending on the output requested (here, "basic"), several files will be
generated containing the model outputs. The most useful is the
"specNNNN.csv" file which lists the line fluxes for all the lines above
the threshold set in the MAPPINGS source file. In a text editor, inspect
all the .csv and .ph6 files to see what they contain.

To run the whole model as a single exercise, you can cut and paste model
text as a single block at the initial command line prompt after MAPPINGS
starts, but you will need to trim the text following text input (e.g.,
the ID string). The response for "yes" can accept "y" or "Y" or "yes" or
"YES", and similarly for "no". Upper or lower case letters are treated
the same for simple responses. You can edit and save blocks like this as
text files for the inputs for single models.

.. container::

   .. rubric:: Grid models
      :name: grid-models

It is straight forward to create script files to automate running models
(shell scripts and/or awk files). This allows one to build a grid of
models for a range of input parameters (e.g., metallicity, log(Q)). In
the HIIGrid306 directory there is a file named ``rungrid.sh``. Examine
this in a text editor to see how a shell script can be constructed. It
can be edited in the same way the single model files to change model
type (plane parallel or spherical), pressure, etc. This shell script
creates a grid of models for metallicity (relative to standard or
"solar") Z = 0.05 to Z=3, and ionisation parameter log(Q) = 6.50 to
8.50, values that span the range of the parameters likely to be
encountered in an HII region.

Outputs: Apart from the model files (each metallicity set is copied at
the end of the model run to its own log(Q) directory), the script (and
associated awk scripts) creates two csv files with an array of line
ratio values for each Z/log(Q) combination. One file orders results by
Z, the other by log(Q), ready for plotting a grid of connected points
for any two chosen strong line ratios.

We use an OSX application, Graf, to plot the grids, to which it is
exceptionally well adapted, but you can plot the grids in any plotting
program of your choice.

To run a grid model, go to the directory that includes ``rungrid.sh``
and execute it: ``./rungrid.sh`` It will prompt you for the input
parameters it needs, These are the number of core processors to use (5
is a good choice on a 4-core MacBook, for the 9 model sets to be run)
and a name for the model. We are developing a standard for model names -
stay tuned.

When you have run a grid model, examine the csv grid files. You will see
columns with various physical parameters (e.g., metallicity, gas phase
and total), and log line flux ratios for the different strong line
combinations.

Note our convention for naming the ratio column headings: a "+" sign
means the fluxes of both lines in a doublet are added. Entries without a
flux refer to the brighter line in a doublet, or a single line. Thus
[OIII] means the flux of the OIII line at 5007Å, while the "+" sign in
[OIII]+ means flux ([OIII] 5007 + [OIII] 4959).

.. container::

   .. rubric:: MAPPINGS input parameters
      :name: mappings-input-parameters

MAPPINGS’ modelling capabilities extend far beyond the HII region models
described here, so the following description of the model inputs is a
subset, sufficient for this guide. Note that if you run a model one
prompt at a time, MAPPINGS tells you all the possible options for the
context. The prompts for an HII region model are as follows.

*Change abundance*: This allows you to select from the MAPPINGS
libraries the abundances of elements to be used in the model. Of the 30
elements in MAPPINGS range, we mainly use the 16 elements of interest
and importance in HII regions. This can be extended for more complex
models but is seldom necessary.

*Offsets*: You can change abundance offsets for particular elements
without changing the main abundance table. Normally ignore.

*Use kappa distribution electrons*: Nicholls et al. (ADS
2012ApJ...752..148N) suggested that under some circumstances, the
electron energies may not be in equilibrium , but follow a kappa
distribution. MAPPINGS can calculate fluxes for non-equilibrium electron
energies. If you wish to model a normal Maxwell-Boltzmann equilibrium,
respond "no" to this input. If "yes" you can specify the value of the
kappa index (2 < kappa <1000).

*Dust and Change depletions*: Normally include dust. Depletions are
problematic as they are likely to vary from object to object. We have
derived a set of scaled depletion files (see Nicholls, Sutherland et al,
2017, ADS 2017MNRAS.466.4403N) based on ISM measurements and analysis by
Jenkins. They are based on the level of Fe depletion. We have found that
a log(Fe depletion) of -1.50 gives a useful match for observations of
HII regions and PNe.

*Dust destruction*, grain distribution, PAHs and carbon in PAHs, etc:
Use the default values shown the the model list above. Dust physics
involves considerable degeneracies, and it is best to use the default
values These values generate results that match observations. If you
enter responses to MAPPINGS prompts by hand, you will see the other
options available and some explanations. Normally use the defaults,
unless you wish to explore the effect of varying particular parameters,
and know what you are doing!

*MAPPINGS model to use*: For HII regions, the choice should be P6, the
most recent and most efficient code. Other P series are included for
compatibility with older versions of MAPPINGS. You can model single
atoms at fixed conditions (e.g., temperature, density) and if you choose
MM, for example, the subsequent menus vary from what is described here.
For this work, use P6.

*Ionisation balance*: normally use default

*Radiation field*: This refers to the source of the ionising radiation
for the excitation. The choice allows you to select, *inter alia*:

-  a black body,

-  a single star for which you have the spectrum, from a variety of
   stellar atmosphere model sources,

-  a synthesised cluster population spectrum calculated by, e.g.,
   Starburst99, for which a pre-calculated library of spectra are
   included in the MAPPINGS data files, and

-  An AGN spectrum.

As before, if you enter responses at the prompts manually, MAPPINGS
shows all the options. For this work, choose H, which then requires
choosing a spectrum file from the library.

*Spectrum to use (file name)*: This requires selecting the appropriate
spectrum file. In this exercise, we use Starburst99 files. The SB99
library includes precomputed spectra for a range of cluster ages (0 to
10Myr) and for continuous star formation or coeval evolution at a single
age. The library has been calculated for Salpeter and Kroupa initial
mass functions (IMF), stellar atmosphere models, and stellar
evolutionary track models. For example, the file
cont_a05t23isp_vm802.spectrum has been calculated using continuous star
formation, a Pauldrach WM-Basic atmosphere model, a Geneva evolutionary
track and Salpeter IMF. The particular file matches the metallicities of
the atmospheres and tracks (but see "Dark Secrets" below).

*Model time (star or cluster age)*: Each spectrum file includes the
models for different ages (0 to 10Myr in 0.5Myr steps) and this input
selects which age to use. HII regions are brightest between 4 and 5Myr,
options 9,10,11, so these values are the most useful.

Enter X at this point to tell MAPPINGS to continue.

*Cosmic ray heating*: normally default to "No".

*Spherical or plane parallel geometry and Radiative transfer mode*:
MAPPINGS can calculate two geometries for HII regions. Spherical
geometry corresponds to a Strömgren sphere. This is observed in small
single star HII regions but is not the norm. Plane Parallel is the
alternative, and it is usual to calculate a two sided model (radiation
from the far side coming back through the nebula).

*Density structure*: this option allows a choice of constant density
(isochoric, C), constant pressure (isobaric, B), or a functional form.
For most HII regions, the sound crossing time is about the same as the
age of the observed ionising cluster, allowing pressure to equilibrate,
so constant pressure is the sensible choice. However, there are many
combinations of metallicity and ionisation parameter at constant
pressure that do have nearly constant density (see Kewley, Nicholls,
Sutherland, et al., 2017, ARAA, in press). For this exercise, we use a
constant pressure (isobaric) model.

T\ *otal pressure*: This specifies log(P/k) where k is the Boltzmann
constant. A value between 4 and 8 is plausible, and the best choice for
observed HII regions is usually 5 or 6.

*Initial temperature estimate*: Electron temperature is a free
parameter, not an input parameter for the model, but we need to tell
MAPPINGS approximately where to start. It rapidly iterates to a physical
value from the input parameters (P, Q, Z). Te =104 is the usual input
value (4 as a log) for an HII region.

*Filling factor*: Normally use 1

*Ionising flux at inner edge*: Here we want to specify the ionisation
parameter, log(Q), at the inner edge (point closest to the ionising
source/cluster) so specify Q.

*QHDN at inner edge*: This specifies the value of the ionisation
parameter at the inner edge. The usual range is 6.50 < log(Q) < 8.50.

*Geometrical dilution factor*: Another adjustment factor, normally use
0.5.

*Ionisation balance*: Normally enter E for equilibrium balance. Step
photon absorption fraction: This is the integration step size. For the
P6 model, 0.02 is a good choice. A smaller value implies a longer
computation time but may be required if the model is unstable at the
larger step. Normally not a problem.

*Model ending*: Do we run out of ionising radiation first, or matter or
optical depth etc? The simplest model is radiation bounded (A) and this
is a good approximation to most nebulae.

*Output settings*: This is where we choose what output files are
generated. We can select particular elements or particular ions to
present, as a function of nebular depth, in addition to the standard
output. For this exercise we select the standard output (A). Other
options require additional inputs (element, ion, etc.).

*Name/code for model run*: We don’t have a standard for this yet, but
something that summarises the input parameters is useful. For testing
purposes, "test" is fine.

When the run name has bee entered, the model commences. If you are
running a single model, the progress of the computation cascades through
the terminal screen. The final input asks whether a new model should be
run or the modelling ended. Enter X unless you want to run another model
with different parameters.

And that describes the single model inputs. Next we’ll take a quick look
at the grid script, rungrid.sh. Many of the same inputs are used in the
script as in the single model.

.. container::

   .. rubric:: Grid script structure and inputs
      :name: grid-script-structure-and-inputs

The script file rungrid.sh (with associated awk scripts) is located in
the HIIGrid306 directory. Open it in a text editor to see its structure
and embedded inputs. It will be apparent that the first 150 lines relate
closely to the single model inputs. After that the multi-model loops and
scripts are set up, but the same parameters apply. More informative
comments are provided in the script than are available in the single
model input described above.

In particular, lines 81 to 97 set up a range of abundance files for five
different metallicities. We are using by preference the Galactic
Concordance abundance files (and scaling) described in Nicholls,
Sutherland et al. (ADS 2017MNRAS.466.4403N). We use these in place of
the so called "solar" abundances, which have varied greatly over the
past 30 years. For example, standard metallicity (equivalent to 1.0
"solar") corresponds to 12+log(O/H)=8.76 . However, equivalent files for
standard (Asplund et al., 2009) solar values are also available in the
/abund/AGSS2009 directory. Older "solar" abundance files are also
available in the /abund directory.

The relative abundance scaling of different elements in the Galactic
Concordance set is based on the evidence in old stars. It is possible to
express the abundances in terms of either the Fe scale or the oxygen
scale. They involve the same physics, but the oxygen abundance files
span a somewhat greater range of metallicities. The need for non-uniform
scaling at different metallicities is described in Nicholls, Sutherland
et al., (ADS 2017MNRAS.466.4403N). You can use the abundance files
listed in the rungrid.sh file as inputs for single models or choose
other standards from the /abund sub-directory in the /lab directory.
Other points to note

If you terminate a running script mid run using control-C, you will need
to manually clean up the partly completed files in your working
directory. If you are running multiple processes (e.g., if you run more
than one process at a time), you will need to kill the zombie map51
processes. This can be done from the terminal, or, more easily followed,
in the OSX Application Monitor app.

.. container::

   .. rubric:: Dark secrets
      :name: dark-secrets

As with all branches of astrophysics, those familiar with the
assumptions that go into a model know that there are approximations
involved, missing and unreliable data, and in some cases, Rumsfeldian
"unknown unknowns". MAPPINGS has evolved over the years to incorporate
the most efficient computation methods, the best atomic data available,
and all the "known physics". The biggest problem we face is that, to
determine the ionising spectrum of a star cluster, the synthetic
spectrum depends on having extensive stellar atmosphere sets, and
reliable interpolation between models (with a closely spaced model
grid). The available O-star grids are sparse. We also need stellar
evolutionary tracks calculated on the same basis (relative metallicity
values) as the atmospheres. No such compatible sets exist at present,
and we need to choose the most compatible combinations of atmospheres
and tracks.

We also know that stellar atmosphere model fluxes, particularly for the
massive O-stars that dominate the cluster ionising spectrum, can differ
by an order of magnitude between the different atmosphere models at
energies responsible for ionising O+ to O++ , a critical value in
determining nebular ionisation balances.

We are in the process of building a new grid of O-star stellar
atmosphere models, TOSCA, using the CMFGEN code (Hillier, ADS
2012IAUS..282..229H). This is a huge undertaking and may not be complete
for a while. Likewise, we are using the MIST code (Choi et al., ADS
2016ApJ...823..102C) to develop compatible evolutionary tracks. When
both of these are complete we will use the SLUG2 stochastic stellar
population spectral synthesis code (da Silva et al., ADS
2012ApJ...745..145D) to generate more consistent ionising spectra to use
in MAPPINGS calculations.

Atomic data are also a problem. Because of the radiative cascade
processes involved in generating recombination emission lines, lack of
information about the higher energy levels of ions such as O+ and C+
leads to incomplete information on these transitions.

Nitrogen also presents a problem. Because of the different ways nitrogen
can be created in stars (core collapse supernovae, WN stars, AGB stars
etc.) the nebular abundance of nitrogen can vary considerably from a
"standard" level in different nebulae. MAPPINGS can set the abundance of
nitrogen to the desired value, but this must be adjusted manually when
running a model.

These difficulties are faced by all photoionisation models. Despite
this, it is gratifying how well we are able to model nebular
photoionisation physics. The models provide a useful guide to observed
physical conditions, but should not be assumed to be "absolute truth".
Nonetheless, MAPPINGS is a very useful tool for understanding
observations.

.. container::

   .. rubric:: The abundance files, what they mean and how to use them
      :name: the-abundance-files-what-they-mean-and-how-to-use-them

In the folder mappings_V-xxx/lab/abund (among other places) you will
find a collection of element abundance files with the .abn suffix. These
are derived from several sources, including the Asplund et al., 2009 ADS
2009ARA&A..47..481A "solar standard". These are scaled in a simple
manner: e.g., 50% standard (solar) oxygen corresponds to 50% standard
(solar) iron, which we know to be incorrect. In previous versions of
MAPPINGS, these were the abundance sets we used, but should not normally
be used except close to standard (solar) metallicity or to re-run old
models.

As a result of identifying from stellar spectra how elements scale
relative to one another at lower metallicities, we now have the
"Galactic Concordance" (GC) scale, and the GC standard set. The latter
is intended to replace the diverse "solar" abundance sets that have been
measured of the past few decades, and which differ from each other by
disturbingly large amounts. The GC standard is based on an extension of
the abundances measured by Nieva & Przybilla, 2012, ADS
2012A&A...539A.143N from 20 local Milky Way B-stars. See Nicholls,
Sutherland et al, 2017, ADS 2017MNRAS.466.4403N, for a detailed
discussion. At lower metallicities, the abundances are scaled following
the stellar data.

The GC abundance files are provided for convenient line ratio grid
calculations in the folder ``../lab/abund/GC16Grid`` and as a set of
conveniently scaled values in the folder ``../lab/abund/GC2016``. The
.abn files are all text files. They include detailed header information
on the abundances of oxygen and iron.

A word on the file nomenclature for the GC abundance files is in order
here. The "M" and "P" notations mean minus and plus. Thus, GC_ZO_M1130
means the standard oxygen metallicity (12+log(O/H)=8.76 for the GC
scale) minus 1.130. So GC_ZO_M1130 refers to a set with oxygen
metallicity (8.76-1.13), or 7.63 The GC_ZFe set are derived from the
standard Fe abundance, 12+log(Fe/H)= 7.52 (not the standard O
abundance). So GC_ZFe_M1150 means the standard Fe metallicity minus
1.15: 12+log(Fe/H)=7.52-1.15, or 6.37. Using the GC relative scaling
procedures, this corresponds to an oxygen metallicity 12+log(O/H)= 8.11
.

Take a look at the contents of the file ``GC_Fe_M1150.abn`` (it’s a text
file) and you will see all this in the header comments. Open the other
.abn files to see the oxygen and iron abundances each one corresponds
to.

The GC_ZFe Grid files allow you to choose 12+log(O/H) = 8.110, 8.485,
8.635, 8.835 and 8.985 (GC_ZFe_M1150, ...M0550, ...M0250, ...P0150,
...P0450) The GC_ZO files allow you to choose 12+log(O/H)= 7.630, 8.230,
8.530, 8.930, and 9.230 (GC_ZO_M1130, ...M0530, ...M0230, ...P0170,
...P0470)

The GC_ZO files span a wider range of oxygen metallicities but using the
GC_ZFe files allows to you choose a slightly different group of oxygen
abundances. The physics and scaling procedures are the same, they just
use different reference standard elements.

If you wish to run a single model at a specific metallicity, check the
available metallicities in the .abn file headers in ``GC16Grid`` and
``GC2016`` folders to find the value nearest to the metallicity you want
to model. You will also need to select the stellar atmosphere + track
.spectrum file from the folder ``../lab/HIIGrid306/Q/inputs/`` that
matches the .abn file as closely as possible.

.. container::

   .. rubric:: The ``.spectrum`` files
      :name: the-.spectrum-files

MAPPINGS expects an excitation spectrum as input to ionise the ISM. For
HII regions, the excitation source is usually a hot young star cluster.
Shock excited spectra are also possible in HII regions, but modelling
shocks is complex and outside the scope of this introductory guide.

MAPPINGS takes its excitation spectra in the form of ``.spectrum``
files, which can be found in the ``../lab/HIIGrid306/Q/inputs/`` folder.
For typical star clusters we need to calculate the synthesised spectrum
from a simulated young star cluster. This requires a value of the
initial metallicity, inputs from an array of stellar spectra, a set of
stellar evolutionary tracks, an Initial Mass Function (e.g., the
Salpeter IMF), the age of the cluster and whether the cluster stars
formed immediately and have all evolved since then, or are forming
continuously. At present the stellar population synthesis program
Starburst99 ADS 1999ApJS..123....3L is used to pre-calculate sets of
spectra to use as inputs to MAPPINGS. As discussed above under "Dark
Secrets", the stellar synthesised spectra are sub-optimal, but will
improve as better stellar atmospheres, compatible evolutionary tracks
and more sophisticated stellar spectrum synthesis applications are
available.

At present, for a chosen model metallicity, one needs to select the
appropriate spectrum file to run a sensible model. The following is a
description of the file naming process we use to identify the right
.spectrum file to choose to model a particular metallicity.

File names are of the form cont_a03t21isp_vm802.spectrum The first
section is either cont or coeval: the former refers to continuous star
formation, the latter star formation at year zero only. The second
section is typically a03 or a05. This specifies the stellar atmosphere
models used by Starburst99. a05 has perhaps the best UV spectra and is
based on the Pauldrach WMbasic code ADS 2001A&A...375..161P. Data using
CMFGEN will be available later and will cover a much finer temperature
and metallicity grid. The next segment of the file name is t21 in the
example. This refers to the stellar evolutionary tracks, from the Geneva
track models. The range of options in this case is t21 through t25.
These refer to metallicities for the grid metallicities 0.05 (t21), 0.2
(t22), 0.4 (t23), 1.0 (t24) and 2.0 (t25). It is this name segment that
identifies the metallicity to be used in the (single) model. The next
name segment is the IMF: isp for Salpeter, ikr for Kroupa. In practice,
at present, the IMF choice makes little difference to the output due to
the sparse O-star grid. The final vm802 refers to the version of
Starburst99 used. Each .spectrum file includes a sequence of spectra for
different cluster ages, which is selected in the cluster age input when
running a MAPPINGS model. Inspect a .spectrum file with a text editor to
see the structure.

.. container::

   .. rubric:: Using MAPPINGS to generate single-atom fluxes
      :name: using-mappings-to-generate-single-atom-fluxes

Mappings can also be used to calculate emission line fluxes for single
atoms and ions (for example, O++). This is useful if you wish to
calculate atomic equivalent temperatures for the Te or "Direct method"
to estimate electron temperatures from observed nebular fluxes. This is
the electron temperature of a dust free, isolated assembly of ions at a
uniform electron density and a single electron temperature that
generates the same emission line flux as the observed nebular data. It
can be useful when a nebula is assumed to be isothermal, and is widely
used in nebular data analysis.

To run a single atom calculation we start MAPPINGS as normal, but
respond with "n" to the prompts for abundances, abundance offsets,
kappa, and dust. At the Model choice prompt, we enter "mm" (or "MM") to
select Multi-level Ion Emissivity. This presents two options, depending
on whether we want fluxes at a fixed electron temperature over a range
of densities, or a fixed density over a range of electron temperatures.
The more useful of these is usually the second, selected using the "B"
input. This is because nebulae are approximately isobaric (constant
pressure) but not isochoric (constant density) or isothermal. It is
useful to calculate how the fluxes vary with temperature, but the
results are the same for any temperature and density pair. We will
illustrate the second case. Enter "b" (or "B").

| The next option is to select the sort of output we want. The first
  leads us to a choice of collisionally excited ion, the second a
  many-level Fe model and the third , recombination line options. Here
  we’ll select the first, enter "a". The ion list is presented, for
  which collisionally excited emission line fluxes can be calculated.
  We’ll choose "12", for O++ . MAPPINGS shows the ion energy levels to
  be used, and asks for the density. Enter "2" for a density of 100 cm-3
  . Then we need to specify the minimum Te (linear or log), the
  temperature increment delta (log only), and the number of temperature
  increments. Enter "5000, 0.05, 20", which corresponds to 21
  temperature values starting at 5000K and ending at 50000K. Finally,
  give the run a name, and MAPPINGS creates a file named ``ionxxxx.csv``
  with the results, where xxxx is a sequential number. MAPPINGS does not
  overwrite older files of the same type, but uses the next sequential
  value of xxxx. The final block is the requisite output flux data,
  listed for each emission line.
| In summary, the script would look like this:

::

   }
   n   : no abundance change
   n   : no offset change
   n   : no kappa
   n   : no dust
   mm  : Multi-Level Ion Emissivity
   b   : Fixed density, vary temperature
   a   : Collisional, Multi-level Ions
   12  : O III
   2   : density 100 cm-3
   5000, 0.05, 20  : start at 5000K, 0.05 log(T)increments, 20 steps
   my\_run\_name   : an identifier}

.. container::

   .. rubric:: How does MAPPINGS compare with CLOUDY?
      :name: how-does-mappings-compare-with-cloudy

Compared to CLOUDY, MAPPINGS is a small and relatively compact
application, that runs quickly on a standard laptop. It is explicitly
aimed at calculating nebular emission spectra. It handles some things
that CLOUDY does not, for example shock emission spectra and kappa
electron energy calculations. At least at present, CLOUDY does not scale
nebular abundances to take into account relative abundance variations
due to the evolution of elements. MAPPINGS does not calculate hydrogen
recombination spectra from first principles, as CLOUDY does, but uses a
table lookup method. Both codes are subject to the problems with atomic
data and stellar atmosphere models. Neither code calculates nebular
models with an arbitrary geometry (as MOCASSIN does).

.. container::

   .. rubric:: Who wrote MAPPINGS?
      :name: who-wrote-mappings

MAPPINGS has been built by several authors over the years. Initially by
Mike Dopita, then Luc Binette, Ralph Sutherland and Brent Groves. The
most recent two versions (4, 5) have been built by Ralph Sutherland
(with some input from David Nicholls and Mike Dopita) and are a major
revision of earlier versions.

.. container::

   .. rubric:: Contact information for further help
      :name: contact-information-for-further-help

David Nicholls (general help): david.nicholls@anu.edu.au mob: 0458 901
888 Ralph Sutherland (el supremo inquiries only):
ralph.sutherland@anu.edu.au

.. container::

   .. rubric:: Appendix: the MAPPINGS Readme file
      :name: appendix-the-mappings-readme-file

::

   # MAPPINGS V v5.1.13

   `https://mappings.anu.edu.au/code`
   `https://bitbucket.org/RalphSutherland/mappings`

   #### Contact:

       Ralph.Sutherland@anu.edu.au


   ## Quick Start Compiling and Running:

           > cd mappings/src
           > make build`

   [wait a while....]

       > cd ../lab
       > ./map51

   ### Installing so map51 can run anywhere:

       > cd mappings/src
       > make build
       > sudo make install

   This copies map51 into /usr/local/bin so it can be run
   from any location by all users of the computer.
   It also creates copies of the essential lab directories; data, atmos, and
   abund, into /usr/local/share.

   #### When running map51, you can run locally in lab/ (note ./map51)

       > cd ../lab
       > ./map51

   and it will find the local map.prefs, data, abund etc
   old scripts will work as before.

   #### With the `/local` installed option you can use any directory
   (note plain map51) ie:

       > cd
       > mkdir test
       > cd test
       > map51

   If mappings finds a local data file it will use those,
   otherwise it will fallback to use the shared copy, so you can
   still maintain a custom set of data and abundances etc
   or use the standard shared set.

   ## Uninstalling:

   To remove the shared installation simply

       > sudo make uninstall
   .
   To remove the local copy simply delete the `mappings/` directory

   ## The MAPPINGS directory structure:

   #### mappings/
       lab/
           data/
           abund/
       src/
           mastercode/
           includes/
           workcode/

   #### Optional:
           lab/atmos/
           lab/scripts/

   #### Shared: (optional with sudo make install)
           /usr/local/bin/
           /usr/local/share/mappings/
               data/
               abund/
               atmos/

   ### Key Directories and Files:

   * `lab/`  This is where the executable is made and run.  The runtime files such
       as map.prefs are here and the essential data directory with the runtime data
       files.
   * `map51`: The executable.


   * `map.prefs`   Essential startup data - must be present.
   * `mapStd.prefs`  A standard 16 atom startup in case map.prefs is lost for any reason, 
      can be copied and renamed map.prefs if needed
   * `mapFull.prefs`  A full 30 atom startup in case map.prefs is lost for any reason, 
      can be copied and renamed map.prefs if needed
   * `data/`: Contains the atomic data for MAPPINGS V. Read at runtime in mapinit.f.  
      Essential and must be present and complete.
   * `abund/`:  A set of useful abundance settings that can be read interactively 
      during a run.  Optional.
   * `atmos/`:  A set of useful radiation source files and stellar atmosphere models.  
      Optional.
   * `scripts/`: A collection of (mostly) useful of UNIX shell and MAPPINGS scripts

   * `src/`
    Contains the code area and the Makefile(s).  There are three makefiles, one
   for a setup with fortran installed, Makefile.for, and one to use if you are running
   f2c and a C compiler, Makefile.f2c.  If using f2c, rename the Makefile.f2c to
   simply Makefile and use that.  If using FORTRAN, rename Makefile.for to Makefile.
   All the useful parameters are near the top of the makefile.

   * `Makefile`.   This makefile  controls all the building of MAPPINGS.  
   It takes one argument to control the operation:

                MAPPINGS V v5.1.x make options:
                'make help'    to see this menu
                'make build'   to create executable from scratch and clean
                'sudo make install'   to install the built executable into /usr/local
                'make prepare' to copy over '\*.f' and '\*.inc' files
                'make compile' to create executable
                'make backup'  to backup '\*.f' and '\*.inc' files
                'make clean'   to backup '\*.f' and '\*.inc', remove '*.o'
                'make listing' to create listing of code

   * `mastercode/` Contains a master copy of the code - only accessed by the Makefile.
   * `workcode/`   The Makefile copies the .f files here.  These can be edited etc by
   the user.   The Makefile compiles these files to make the executable.

   * `f2c.zip`:  A zip archive of `f2c`, requires only a `C` compiler to make, `gcc` by
   default.  MAPPINGS can be built from scratch by building `f2c`, installing it in
   `/usr/local` and then use the `f2c` Makefile to build MAPPINGS.

.. |image| image:: ANUlogo.jpg
   :width: 4cm
