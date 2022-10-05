# MAPPINGS V v5.2.0

		Creative Commons v4.0 International
		By Attribution, Share Alike
		CC-BY-SA-4.0Intl https://creativecommons.org
		1976 -- 2022+ Ralph Sutherland,
		Michael Dopita, Luc Binette, Ian Evans,
		Brent Groves, David Nicholls,
		Adam D. Thomas, Jin Yi-Fei, Knox Long


`https://mappings.anu.edu.au/code`
`https://bitbucket.org/RalphSutherland/mappings`

#### Contact:

	Ralph.Sutherland@anu.edu.au


## Quick Start Compiling and Running:

		> cd mappings/src
		> make build`

[wait a while....]

	> cd ../lab
	> ./map52

### Installing so map52 can run anywhere:

	> cd mappings/src
	> make build
	> sudo make install

This copies map52 into /usr/local/bin so it can be run
from any location by all users of the computer.
It also creates copies of the essential lab directories; data, atmos, and
abund, into /usr/local/share.

#### When running map52, you can run locally in lab/ (note ./map52)

	> cd ../lab
	> ./map52

and it will find the local map.prefs, data, abund etc
old scripts will work as before.

#### With the `/local` installed option you can use any directory
(note plain map52) ie:

	> cd
	> mkdir test
	> cd test
	> map52

If mappings finds a local data file it will use those,
otherwise it will fallback to use the shared copy, so you can
still maintain a custom set of data and abundances etc
or use the standard shared set.

## Uninstalling:

To remove the shared installation simply

	> sudo make uninstall
.
To remove the local copy simply delete the `mappings/` directory

## The Mappings directory structure:

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
* `map52`: The executable.


* `map.prefs`   Essential startup data - must be present.
* `mapStd.prefs`  A standard 16 atom startup in case map.prefs is lost for any reason, can be copied and renamed map.prefs if needed
* `mapFull.prefs`  A full 30 atom startup in case map.prefs is lost for any reason, can be copied and renamed map.prefs if needed
* `data/`: Contains the atomic data for MAPPINGS V. Read at runtime in mapinit.f.  Essential and must be present and complete.
* `abund/`:  A set of useful abundance settings that can be read interactively during a run.  Optional.
* `atmos/`:  A set of useful radiation source files and stellar atmosphere models.  Optional.
* `scripts/`: A collection of (mostly) useful of UNIX shell and MAPPINGS scripts

* `src/`
 Contains the code area and the Makefile(s).  There are three makefiles, one
for a setup with fortran installed, Makefile.for, and one to use if you are running
f2c and a C compiler, Makefile.f2c.  If using f2c, rename the Makefile.f2c to
simply Makefile and use that.  If using FORTRAN, rename Makefile.for to Makefile.
All the useful parameters are near the top of the makefile.

* `Makefile`.   This makefile  controls all the building of MAPPINGS.  It takes one argument to control the operation:

        `MAPPINGS V v5.2.0 make options:
        `
        `Type 'make help'    to see this menu
        `Type 'make build'   to create executable from scratch and clean in ../lab
        `
        `Type 'sudo make install'   to install the built code and data into /usr/local
        `Type 'sudo make installcode' to install the built code only into /usr/local
        `
        `Type 'sudo make installopt' to install the built code and data into /opt/local
        `Type 'sudo make installcodeopt' to install the built code only into /opt/local
        `
        `Type 'make prepare' to copy over '*.f' and '*.inc' files
        `Type 'make compile' to create executable
        `Type 'make backup'  to backup '*.f' and '*.inc' files
        `Type 'make clean'   to backup '*.f' and '*.inc', remove '*.o'
        `Type 'make listing' to create listing of code
        `
        `Type 'make uninstall' remove /usr/local/
        `Type 'make uninstallopt' remove /opt/local/

* `mastercode/` Contains a master copy of the code - only accessed by the Makefile.
* `workcode/`   The Makefile copies the .f files here.  These can be edited etc by
the user.   The Makefile compiles these files to make the executable.

* `f2c.zip`:  A zip archive of `f2c`, requires only a `C` compiler to make, `gcc` by
default.  MAPPINGS can be built from scratch by building `f2c`, installing it in
`/usr/local` and then use the `f2c` and `gcc` Makefile to build MAPPINGS.
