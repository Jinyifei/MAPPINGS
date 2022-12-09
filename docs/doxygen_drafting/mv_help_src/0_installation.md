# Getting Started

MAPINGS V is written in FORTRAN 77/90 with some auxillary code in ANSI C
and does not require anything but a modeest version of FORTRAN and C to
install, such as the GCC gfortran/gcc compiler collection.  it will run
in any POSIX compliant shell envionment from UNIX, Linux or even Cygwin.

The latest versions of Mappings and the primary site for obtaining the
source code and associated cata files is on Bitbucket at
<https://bitbucket.org/RalphSutherland/mappings/src/public/>

Most of the recent develpment has been carried out using gfortran. Most
of the developers are currently using MACOs or linux (ubnuntu), and the
standard Makefile is intended to run on either system. We provide some
Makefiles for some other versions of Fortran, as well but these are less
well tested with recent versions of Mappings and if anyone encounters
prablems wit installation, please describe your problem on the issues
page of the repository.

### Installation

Mappings and the various routines associated with it are in a
self-contained directory structure, which needs to be retreived from
BitBucket.

Once you have downloaded the repository, you need got to the src
directory within the distribuiton

and then if you have gfortan on your machine you should be able to
compile mappings with the command

It should be obvious from what is printed out to the terminal whether
the compilaton has been successful

The existing make file should work on MacOS or on most linux
distributions. If you encounter problems, there are other makefiles that
may be more appropriate for your system in altmakefiles directory.

The make build compiles executables and places them in the mappings/bin
directory.

At this point you have two options:

-   Set up enviroment variables to point to the local installation of
    mappings on your computer. This is the preferred option for most
    users if you are the sole user, but it requires you to add several
    lines to your profile to access mappings properly. It has the
    advantabe that you can easily determine what executable versons of
    mappings are available.
-   Installing the code in a central location for use by you and others
    on a machine. This is the apppropriate option for inatallation for a
    group of users, where one person is responsible for the mappings
    coed, but there are a number of users who should be using the
    identical version of the code.

#### Single Users

For personal users, the only thing that needs to be done after building
mappings as described above is to add the following lines to one of your
profile files (for bash, either .bash\_profile or .bashrc, whichever you
prefer).

The commands for bash and it variants are:

where MAPPINGS points to the top level directory for the mappins
installation.

for csh, tcsh and other similar shells the commmnad sould be

Defining the $MAPPINGS variable is require because is required to locate
the data files.

Aside: If you are installing for yourself a version of mappings on a
machine where there is also a system installation, you may need to
change to order of the PATH search, using by replacing the PATH command
above by

#### Multiple Users

For multiple users, one does not need to add anything to the profile
files. Instead, the person resposible for installing mappings should the
following command from within the src directory

or depending on the user's privileges

This will install mappings in /usr/local

Aside: There are also options to install in /opt/local if that is
preferred. To see these options, we refer the user to the Makefile
itself.

### Updating mappings

Assuming you have downloaded mappings as a git archive, updating the
stable version of mappings is straightforward. Simple go to the mappings
directory an issue the follwoing command, and then repeat the build
process descibed above.

Aside: There will be other branches on the BitBucket site, but the
public branch is the one that is relatively stable, and should be the
branch that most researchers use. We may encourage some users to test
other branches, but all of these branches are experimental and subject
to rapid change.

### Removing mappings

To remove mappings from your system, personal users need only to delete
the mappings directory (and if they wish the lines added to the setup
files (.bash\_profile or .bashrc for bash users.

To remove mappings for installations for multiple users, the following
command should be issued from the mapings/src dirctor:

After this the mappings directory itself can be removed.

## The Installed MAPPINGS directory structure:

#### mappings520/
		lab/
		lab/scripts/

		data/
		atmos/
		abund/
		prefs/
		docs/
		misc/

### Key Installed Directories and Files:

* `lab/`  This is where the executable is made and run.  The runtime files such
	as map.prefs are here, the user can create and rename new labs and put map.prefs into them and run
	other models.
* `map52`: The executable.
* `map.prefs`   Essential startup data - must be present.
* `mapStd.prefs`  A standard 16 atom startup in case map.prefs is lost for any reason, can be copied and renamed map.prefs if needed
* `mapFull.prefs`  A full 30 atom startup in case map.prefs is lost for any reason, can be copied and renamed map.prefs if needed
* `scripts/`: A collection of (mostly) useful of UNIX shell and MAPPINGS scripts

* `data/`: Contains the atomic data for MAPPINGS V. Read at runtime in mapinit.f.  Essential and must be present and complete.
* `abund/`:  A set of useful abundance settings that can be read interactively during a run.  Optional.
* `atmos/`:  A set of useful radiation source files and stellar atmosphere models.  Optional.
* `docs/`:  Help, source references and cookbook guides
* `misc/`:  A set of C and other tools for manipilting MAPPINGS output such as reddening

### Key Build Area Directories and Files:

The master copies of the data and other directories above plus:

* `src/` : Contains the code

* `Makefile`   This makefile  controls all the building of MAPPINGS.
It takes one argument to control the operation: build is the main one.

         MAPPINGS V make options:
         -----------------------------------------------------------

         'make, make help'             To see this menu

         'make build'      Build and install, and clean.
                           Creates MAPPINGS in /Users/ralph/mappings520
                           and creates optional environment variable
                           templates for startup scripts.
         'make compile'    to make new '*.o' in the build area only
         'make clean'      to clean up '*.o' files from a compile
         'make distclean'  as clean but also remove map52rss

         'make install'    install afer manual compile
         'make uninstall'  remove installed map52rss

         -----------------------------------------------------------

* `lab/`    : master copy has `data/, atmos/, abund/, and scritps/`
and `map.prefs` masters inside which are installed in the build.
* `docs/`   : in the build area contains additional developer documentation
* `misc/`   :  A set of C and other tools for manipilting MAPPINGS output such as reddening
* `addons/` : Contains alternative Makefiles, alternative pref and runtime options
