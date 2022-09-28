
Downloading and installing Mappings should be straigtforward.


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
