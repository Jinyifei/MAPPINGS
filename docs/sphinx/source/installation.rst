##################################
Installing and Building MAPPINGS
##################################

This is the single, current source for getting MAPPINGS from a download
to a running model.  (Earlier versions of this documentation had this
split across three overlapping and partly stale pages; if you have a
bookmark to "Getting Started" or "Downloading and Installing Mappings"
from before, this page replaces both.)

.. contents:: Contents
   :local:
   :depth: 1

-------------------------------------------------
Prerequisites
-------------------------------------------------

MAPPINGS is Fortran 77 (legacy-mode) plus a handful of C post-processing
tools, built with a single ``Makefile``. You need:

* **gfortran** — the standard, best-tested compiler. Most development
  happens on macOS and Linux (Ubuntu); the default ``Makefile`` targets
  both.
* On **macOS**: Xcode's command line tools (``xcode-select --install``)
  so a C/Fortran toolchain and linker are available.
* A C compiler (``gcc``/``clang``) for the ``tools/`` post-processing
  utilities — installed alongside gfortran on most systems.

Compilers other than gfortran (Intel ``ifort``, plain ``gcc``, ``f2c``)
are supported via alternative makefiles in ``addons/altmakefiles/`` —
see :doc:`repo_structure` for what is there; this page only covers the
standard gfortran path.

-------------------------------------------------
Getting the code
-------------------------------------------------

Clone the repository (GitHub mirror, or the Bitbucket/ANU mirrors —
see the project ``README.md`` for all three)::

    git clone <repository-url>
    cd mappings

Atomic data, stellar atmosphere grids, and abundance tables are all
included in the repository under ``lab/`` — there is no separate data
archive to fetch and unpack.

-------------------------------------------------
Building and installing
-------------------------------------------------

From the repository root::

    make build          # or: make -j build   (parallel, faster)

This compiles the code, builds the C tools in ``tools/``, and installs
everything into ``~/mappings520`` by default — a self-contained area
holding the executable, atomic data, abundance/atmosphere files, and an
initial ``lab/`` working directory. It will not touch or remove any
model files you already have there from a previous install of the same
version.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Command
     - Effect
   * - ``make build`` / ``make -j build``
     - Full build: compile, install to ``~/mappings520``, clean up.
       Use this for a normal install.
   * - ``make compile``
     - Compile only, leaving the executable in ``bin/`` without
       installing.
   * - ``make install``
     - Install after a manual ``make compile``.
   * - ``make clean`` / ``make distclean``
     - Remove ``.o`` files, or ``.o`` files plus executables.
   * - ``make uninstall``
     - Remove the ``~/mappings520`` install (preserves any of your own
       files placed there).
   * - ``make tools``
     - Build and install just the ``blur``/``lines``/``red`` C tools.

To install somewhere other than your home directory (e.g. a shared
location for multiple users), override ``INSTALLBASE`` — see the
comments at the top of the root ``Makefile`` for the available
variables and their effect.

-------------------------------------------------
Shell setup
-------------------------------------------------

After a successful build, the repository root contains a generated
``for_bashrc.txt`` with the environment variables MAPPINGS needs to be
run from any directory, not just ``~/mappings520/lab``::

    export MAPDATA="$HOME/mappings520"
    export MAPBIN="$MAPDATA/bin"
    export PATH="$MAPBIN:$PATH"
    alias map52="$MAPBIN/map52"

Paste (or ``source``) these lines into ``.bashrc``/``.zshrc``. ``MAPDATA``
is how MAPPINGS locates its atomic data files at runtime if you are not
running from inside ``~/mappings520/lab``.

-------------------------------------------------
Running your first model
-------------------------------------------------

::

    cd ~/mappings520/lab
    ./map52

``map.prefs`` must be present in the working directory — it already is
in ``lab/``. From here, MAPPINGS walks you through the startup prompts
documented in :doc:`inputs`, then the model-type menu in :doc:`models`.
For a complete worked example rather than an abstract prompt list, see
:doc:`walkthrough_p6` (photoionisation) or :doc:`walkthrough_s5`
(shock).

-------------------------------------------------
Directory layout
-------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Path (under ``~/mappings520/``)
     - Contents
   * - ``lab/``
     - Where you run models. Contains ``map52``, ``map.prefs``, and
       ``examples/``. Copy this directory (or just ``map.prefs``) to
       create additional independent working areas.
   * - ``bin/``
     - The ``map52`` executable and the C post-processing tools.
   * - ``data/``
     - Atomic data, read at startup by ``mapinit.f``. Required.
   * - ``abund/``
     - Pre-made abundance files, loadable interactively (see
       :doc:`inputs`).
   * - ``atmos/``
     - Stellar atmosphere grids and radiation source files (see
       :doc:`photsou`).
   * - ``scripts/``
     - Utility shell/MAPPINGS scripts, including the regression test
       suites under ``scripts/testScripts/``.
   * - ``docs/``
     - Copies of this documentation and reference material.

-------------------------------------------------
Updating and uninstalling
-------------------------------------------------

To update, pull the latest changes and rebuild::

    git pull
    make build

A new MAPPINGS version number installs into a fresh
``~/mappingsXXXX`` area rather than overwriting the old one, so you can
keep working in an older install while testing a new one.

To remove an install, either run ``make uninstall`` from the build
directory (removes ``~/mappings520`` but leaves any files you added
there yourself) or simply delete the ``~/mappings520`` directory.
