#
SHELL := /bin/bash
#
# Make MAPPINGS V
#
#    v5.2.0
#-------------------------------
#--- Output (executable) name --
#-------------------------------
#
OUTNAME = map52dev
HOMEAREA= mappings520
#
#
#-------------------------------
#---------- Directories --------
#-------------------------------
#
# local build areas
#
EXEDIR = lab
CODDIR = src
BINDIR = bin
#
#-------------------------------
# Install Areas
#
# std home area ~/mappings520 with optional env vars
#
# set INSTALLBASE to the location for the mappings520 to be
# located. Here $(shell echo ${HOME}) finds the users home area
# if it is put into other locations the user may need elevated
# privelges, eg /usr/local
#
# set HOMEAREA to contain the normal mappings install, eg mappings520
# above, so it is created as ${INSTALLBASE}/${HOMEAREA} eg ~/mappings520
# in a standard install.
#
# INSTALLDATA defauts to  ${INSTALLBASE}/${HOMEAREA} and contains the
# atomic data, atmospheres and abundance files, usually the std HOMEAREA
# but can be elsewhere, eg /usr/local/share/mappings520 for special cases
#
# INSTALLBIN is the location of the mappings an auxillary executables]
# and by default is ${INSTALLBASE}/${HOMEAREA}/${BINDIR} or
# ~/mappings520/bin in standard install.  It may be an independent location
# if necessary
#
# So the standard install create ~/mappings520 containing the MAPPINGS
# data/ atmos/ abund/ bin/ and additional documentation scripts and an
# initial are lab/ to run models in.  The paths and aliases for the chosen
# installation are created automatically for tcsh/csh and bash/zsh shells
# and can be found initially in ~/mappings520 and the user can edit their
# startup shell scripts .tcshrc (.cshrc) and .bashrc (.zshrc) so mappings
# can be run in any location and be able to locate the resources it needs
# to run.
#
# ~/mappings520 is the location for documentation and additional material
# such as example running scripts and tests.
#
#
INSTALLBASE =$(shell echo ${HOME})
INSTALLDATA =${INSTALLBASE}/${HOMEAREA}
INSTALLBIN  =${INSTALLBASE}/${HOMEAREA}/${BINDIR}
#
# eg:
#
# for using the build area as the shared binary and data location
#
# HOMEAREA    = $(shell pwd)
# INSTALLBASE = ${HOMEAREA}
# INSTALLDATA ="${INSTALLBASE}"
# INSTALLBIN  ="${INSTALLBASE}/${BINDIR}"
#
# ADVANCED: for using the /usr/local data locations
#
# INSTALLBASE = "/usr/local"
# INSTALLDATA = "${INSTALLBASE}/share/mappings"
# INSTALLBIN  = "${INSTALLBASE}/${BINDIR}"
#
#-------------------------------
#
# Install Runtime Locations:
#
# Standard Home Area Installation
#
# The simplest, standard, way is to build mappings in your
# home area, eg ~/mappings520, with a lab directory in there
# to run models in.  The standard make build creates the home
# area by default for you or updates it if it is already
# there.
#
#       > Make [-j] build
#
# then
#
#       > cd ~/mappings520/lab
#
# to start running simple models.
#
#       > ./map52
#
# If you build a home area and install the shell startup or in
# and existing user $path location, then MAPPINGS can also be
# run in any other new area,  even outside ~/mappings520
#
# Updates/Uninstall
#
# Updates and new make builds will not delete user files but
# only replace MAPPINGS files if there are  changes or deletions.
# A new MAPPINGS version number creates a fresh home area called
# ~/mappingsXXXX where XXXX is the new version number and the
# user can copy their files to the new build and lab or new
# labs as needed.
#
# In the home area the user can create as many labs as they
# need for different projects. but only the plain lab/ would
# be updated if a standard script changed for example.
#
# It is best  to add ~/mappingsXXXX/lab to your shell
# path variables but even with a simple install so it is easy to
# run MAPPINGS in other locations using
#
#       >./mappingsXXXX/bin/map52
#
# and with the standard alias installed simply
#
#       > map52
#
# Build and Install Processes Details
#
# MAPPINGS is built first in the git/zip download area and you
# can run a test model in the build area lab, but it is safer to
# run the in the standard home area or use the user defined
# installation environment, not the initial build area where
# git may overwrite files in an update.
#
# The end of a successful compile process gives the values in
# script shell templates to for user including both MAPDATA
# and MAPBIN in ~/mappings520/ by default.
#
# Note:
#
# Do not add a trailing / to the paths.
#
#-------------------------------
#---------- Compilers ----------
#-------------------------------

# GCC FORTRAN - gfortran standard default build tested with
# v11 but should work with v4.5 or newer standard build in
# 2022 is gfortran v10.x - 12.x
#
# In Linux, use normal repositories on OSX, use
# MacPorts.org/homebrew to get gcc8 or newer,
#
#  macOS GCC FORTRAN v4.9+ and macOS xcode 11+  and newer requires
# -isysroot`xcrun --show-sdk-path` to locate the xcode -lSyslib
#
#  gcc10+ flto=n allows parallel global obj optimisation, slow but
#  with some  performance improvement, set n to ncpus eg flto=8 on an 8
#  core machine.
#
# if recursion is ever needed use:
# -fmax-stack-var-size=7618560
#
# Set warning flags if testing new code but off by defauult
#
#WARN   = -Wall
#WARN   = -Wunused-variable -Wconversion -Wmaybe-uninitialized -fbounds-check
WARN   =
#
# plain simplest linux build without xcrun
#
# FC     = gfortran -std=legacy
# LDR    = ${WARN} -Ofast -ffpe-summary='none'
# OPTS   = -c ${LDR} -I${INCDIR}
# LIB    =
#
# Standard, no flto, optional flto or debugging LDR, commented.
#
FC     = gfortran -std=legacy -march=native
LDR    = ${WARN} -Ofast -ffpe-summary='none'
#LDR    =  ${WARN} -Ofast -flto=8 -ffpe-summary='none'
#LDR    = ${WARN} -g -O0 -fbounds-check -ffpe-summary='none'
OPTS   = -c ${LDR} -I${CODDIR}/
#
#
.SUFFIXES:
.SUFFIXES: .f .o
#
#-------------------------------
#-- include/header files -------
#-------------------------------
#
INCS =  ${CODDIR}/cblocks.inc \
	${CODDIR}/const.inc \
	${CODDIR}/p6blocks.inc \
	${CODDIR}/p7blocks.inc \
	${CODDIR}/s5blocks.inc
#
#-------------------------------
#-- object files ---------------
#-------------------------------
#
OBJ = ${CODDIR}/mappings.o \
	${CODDIR}/allrates.o \
	${CODDIR}/absdis.o \
	${CODDIR}/avrdata.o \
	${CODDIR}/changes.o \
	${CODDIR}/charex.o \
	${CODDIR}/cheat.o \
	${CODDIR}/collion.o \
	${CODDIR}/coloss.o \
	${CODDIR}/compton.o \
	${CODDIR}/coolc.o \
	${CODDIR}/cool.o \
	${CODDIR}/cosmic.o \
	${CODDIR}/crosssections.o \
	${CODDIR}/dusttemp.o \
	${CODDIR}/equion.o \
	${CODDIR}/evoltem.o \
	${CODDIR}/fine3.o \
	${CODDIR}/findtde.o \
	${CODDIR}/freebound.o \
	${CODDIR}/freefree.o \
	${CODDIR}/functions.o \
	${CODDIR}/grainpar.o \
	${CODDIR}/heavyrec.o \
	${CODDIR}/helioi.o \
	${CODDIR}/hgrains.o \
	${CODDIR}/hpahs.o \
	${CODDIR}/hhecoll.o \
	${CODDIR}/hydrec.o \
	${CODDIR}/hydro.o \
	${CODDIR}/hydro2p.o \
	${CODDIR}/inter.o \
	${CODDIR}/interpol.o \
	${CODDIR}/intvec.o \
	${CODDIR}/iobal.o \
	${CODDIR}/iohyd.o \
	${CODDIR}/ionemit.o \
	${CODDIR}/ionab.o \
	${CODDIR}/ionsec.o \
	${CODDIR}/kappainit.o \
	${CODDIR}/localem.o \
	${CODDIR}/mapinit.o \
	${CODDIR}/mdiag.o \
	${CODDIR}/multilevel.o \
	${CODDIR}/neqc.o \
	${CODDIR}/netgain.o \
	${CODDIR}/newdif.o \
	${CODDIR}/optxagnf.o \
	${CODDIR}/output.o \
	${CODDIR}/pheat.o \
	${CODDIR}/phion.o \
	${CODDIR}/phocrv.o \
	${CODDIR}/photo6.o \
	${CODDIR}/photo7.o \
	${CODDIR}/photsou.o \
	${CODDIR}/poputil.o \
	${CODDIR}/preion.o \
	${CODDIR}/rankhug.o \
	${CODDIR}/ratec.o \
	${CODDIR}/rebin.o \
	${CODDIR}/recom.o \
	${CODDIR}/reson.o \
	${CODDIR}/sdifeq.o \
	${CODDIR}/shock4.o \
	${CODDIR}/shock5.o \
	${CODDIR}/sinsla.o \
	${CODDIR}/slab.o \
	${CODDIR}/spectrum.o \
	${CODDIR}/spotap.o \
	${CODDIR}/strutil.o \
	${CODDIR}/sumdata.o \
	${CODDIR}/teequi.o \
	${CODDIR}/timion.o \
	${CODDIR}/timtqui.o \
	${CODDIR}/totphot.o \
	${CODDIR}/transferline.o \
	${CODDIR}/twophoton.o \
	${CODDIR}/zer.o \
	${CODDIR}/zetaeff.o
#
#-------------------------------
#-------  implicit rules  -----
#-------------------------------
#
.f.o:
	${FC} ${OPTS} -o $*.o $<
#
#-------------------------------
#------  explicit rules  ------
#-------------------------------
#
#
#-------------------------------
#---------  Targets  ----------
#-------------------------------
#
UNAME = $(shell uname)
#
ifeq ($(UNAME),Darwin)
	LIB  = -isysroot`xcrun --show-sdk-path`
	XSYS = macOS (with xcrun)
else
	LIB  =
	XSYS = Linux
endif
#
#-------------------------------
#

help:
	@cat ${CODDIR}/credits.txt
	@echo " "
	@echo "MAPPINGS V make options:"
	@echo '-----------------------------------------------------------'
	@echo ' '
	@echo "'make, make help'             To see this menu"
	@echo ' '
	@echo "'make build'      Build and install, and clean."
	@echo "                  Creates MAPPINGS in ${INSTALLBASE}"
	@echo "                  and creates optional environment variable "
	@echo "                  templates for startup scripts."
	@echo "'make compile'    to make new '*.o' in the build area only"
	@echo "'make clean'      to clean up '*.o' files from a compile"
	@echo "'make distclean'  as clean but also remove ${OUTNAME}"
	@echo ' '
	@echo "'make install'    install afer manual compile"
	@echo "'make uninstall'  remove installed ${OUTNAME}"
	@echo ' '
	@echo "'make aux'        make and install aux programs"
	@echo ' '
	@echo '-----------------------------------------------------------'
#
#-----------------------------------------------------------
#
clean:
	@echo ' '
	@echo '#############################################################'
	@echo ' Removing ${OUTNAME} object files'
	@rm -f ${OBJ}
	cd aux; $(MAKE) clean
	@echo '#############################################################'
	@echo ' '
#
distclean:
	@echo ' Removing ${OUTNAME} object files and exe'
	@rm -f ${OBJ}
	@rm -f "for_bashrc.txt"
	@rm -f "for_tcshrc.txt"
	@rm -f ${EXEDIR}/${OUTNAME}
	@rm -f ${BINDIR}/${OUTNAME}
	cd aux; $(MAKE) distclean
#
#------------------------------------------------------------
#
compile: ${BINDIR}/${OUTNAME}
#
# compile and create input for .bashrc and .tcshrc etc
#
${BINDIR}/${OUTNAME}: ${INCS} ${OBJ}
	@echo ' '
	@echo '#############################################################'
	@echo ' Compiling ${OUTNAME} for $(XSYS)'
	${FC} ${LDR} -o ${BINDIR}/${OUTNAME} ${OBJ} ${LIB}
	@echo '#############################################################'
	@echo ' '
	@echo '#############################################################'
	@echo ' MAPPINGS ${OUTNAME} Compiled Successfully.'
	@echo '#############################################################'
	@echo ' Compiling Auxillary Programs...'
	@echo '#############################################################'
	cd aux; $(MAKE) compile
	@echo ' '
	@echo '#############################################################'
	@echo ' A local version of the executable ${OUTNAME} can be found in:'
	@echo ' ${EXEDIR} . Install startup variables for .bashrc and .tcshrc'
	@echo ' with the contents of "for_bashrc.txt" and "for_tcshrc.txt", '
	@echo ' as needed.'
	@echo ' (macOS users may need to use .zshrc with the bashrc settings)'
	@echo '#############################################################'
	@echo ' '
	@cat src/src-bashrc.txt > for_bashrc.txt
	@echo 'export mapbase="${INSTALLBASE}/${HOMEAREA}"' >> for_bashrc.txt
	@echo 'export MAPDATA="$$mapbase"' >> for_bashrc.txt
	@echo 'export MAPBIN="$$mapbase/${BINDIR}"' >> for_bashrc.txt
	@echo '# add bin area to global path:' >> for_bashrc.txt
	@echo 'export PATH="$$MAPBIN:$$PATH"' >> for_bashrc.txt
	@echo '#' >> for_bashrc.txt
	@echo '# add a generic map alias for every executable and location' >> for_bashrc.txt
	@echo '#' >> for_bashrc.txt
	@echo 'alias map52="$$mapbin/${OUTNAME}"' >> for_bashrc.txt
	@echo 'alias m52="$$mapbase"'   >> for_bashrc.txt
	@echo '#' >> for_bashrc.txt
	@echo '########################################################################' >> for_bashrc.txt
	@cat src/src-tcshrc.txt > for_tcshrc.txt
	@echo 'set mapbase = "${INSTALLBASE}/${HOMEAREA}"' >> for_tcshrc.txt
	@echo 'setenv MAPDATA "$$mapbase"' >> for_tcshrc.txt
	@echo 'set mapbin = "$$mapbase/${BINDIR}"' >> for_tcshrc.txt
	@echo 'setenv MAPBIN "$$mapbin"' >> for_tcshrc.txt
	@echo '#' >> for_tcshrc.txt
	@echo '# add bin area to global path:' >> for_tcshrc.txt
	@echo '#' >> for_tcshrc.txt
	@echo 'set path = ($$mapbin $$path)' >> for_tcshrc.txt
	@echo '#' >> for_tcshrc.txt
	@echo '# add a generic map alias for every executable and location' >> for_tcshrc.txt
	@echo '#' >> for_tcshrc.txt
	@echo 'alias map "$$mapbin/${OUTNAME}"' >> for_tcshrc.txt
	@echo 'alias m52 "$$mapbase"' >> for_tcshrc.txt
	@echo '#' >> for_tcshrc.txt
	@echo '########################################################################' >> for_tcshrc.txt
#
#------------------------------------------------------------
#
build:
	@echo 'Building ${OUTNAME} for $(XSYS)'
	@make compile
	@echo 'Cleaning'
	@make clean
	@echo ' '
	@echo '#############################################################'
	@echo ' Compile and Cleaned Successfully...'
	@echo '#############################################################'
	@echo ' '
	@echo 'Installing into ' ${INSTALLDATA}
	@echo ' '
	@make install
#
#------------------------------------------------------------
#
# main install into shared locations, be sure to put correct locations into
# bashrc.sh and .tcshrc  and/or .cshrc or .kshrc
#
install:
	[ -d ${INSTALLDATA} ] || mkdir -p ${INSTALLDATA}
	[ -d ${INSTALLBIN} ] || mkdir -p ${INSTALLBIN}
	[ -d ${INSTALLDATA}/${EXEDIR} ] || mkdir -p ${INSTALLDATA}/${EXEDIR}
	cp ${BINDIR}/${OUTNAME} ${INSTALLBIN}/${OUTNAME}
#
	cp ${EXEDIR}/map.prefs ${INSTALLDATA}/${EXEDIR}/
	cp ${EXEDIR}/mapStd.prefs ${INSTALLDATA}/${EXEDIR}/
	cp ${EXEDIR}/mapFull.prefs ${INSTALLDATA}/${EXEDIR}/
	cp -r ${EXEDIR}/examples ${INSTALLDATA}/${EXEDIR}
	rm -f ${INSTALLDATA}/${EXEDIR}/${OUTNAME}
	ln -s ${INSTALLBIN}/${OUTNAME} ${INSTALLDATA}/${EXEDIR}/${OUTNAME}
#
	cp -r ${EXEDIR}/data    ${INSTALLDATA}/
	cp -r ${EXEDIR}/abund   ${INSTALLDATA}/
	cp -r ${EXEDIR}/prefs   ${INSTALLDATA}/
	cp -r ${EXEDIR}/atmos   ${INSTALLDATA}/
#
	cp -r scripts ${INSTALLDATA}/
	cp   scripts/admin/clean.sh ${INSTALLBIN}/
	cp -r aux ${INSTALLDATA}/
	cd aux; $(MAKE) install
	cp -r docs ${INSTALLDATA}/
#
	rm -rf ${INSTALLDATA}/docs/doxygen
	mv for_tcshrc.txt ${INSTALLDATA}/
	mv for_bashrc.txt ${INSTALLDATA}/
#
	@echo ' '
	@echo '#############################################################'
	@echo ' '
	@echo ' Installed ${OUTNAME} into ${INSTALLBIN}'
	@echo ' Linked ${OUTNAME} into ${INSTALLDATA}/${EXEDIR}'
	@echo ' MAPPINGS V Installed into ${INSTALLDATA}'
	@echo ' Use "for_bashrc.txt" and "for_tcshrc.txt" to edit'
	@echo ' startup settings, if needed, located in ${INSTALLDATA}.'
	@echo ' '
	@echo '#############################################################'
	@echo ' MAPPINGS V Installed: ${INSTALLDATA}'
	@echo ' MAPPINGS V Initial Run Area: ${INSTALLDATA}/${EXEDIR}'
	@echo '#############################################################'
	@echo ' '
#
#------------------------------------------------------------
#
uninstall:
	@rm -f  ${INSTALLDATA}/${EXEDIR}/${OUTNAME}
	@rm -f  ${INSTALLDATA}/${EXEDIR}/mapFull.prefs
	@rm -f  ${INSTALLDATA}/${EXEDIR}/mapStd.prefs
	@rm -rf ${INSTALLDATA}/${EXEDIR}/examples/cooling
	@rm -f  ${INSTALLDATA}/${EXEDIR}/examples/bb100k.sou
	@rm -f  ${INSTALLDATA}/${EXEDIR}/examples/bb100k.mv
	@rm -f  ${INSTALLDATA}/${EXEDIR}/examples/bbt.mv
	@rm -f  ${INSTALLBIN}/${OUTNAME}
	@rm -rf ${INSTALLDATA}/${BINDIR}
	@rm -rf ${INSTALLDATA}/data
	@rm -rf ${INSTALLDATA}/abund
	@rm -rf ${INSTALLDATA}/prefs
	@rm -rf ${INSTALLDATA}/atmos
	@rm -rf ${INSTALLDATA}/scripts
	@rm -rf ${INSTALLDATA}/aux
	cd aux; $(MAKE) uninstall
	@rm -rf ${INSTALLDATA}/docs
	@echo ' '
	@echo '#############################################################'
	@echo ' '
	@echo ' Uninstalled ${INSTALLBIN}/${OUTNAME}'
	@echo ' Uninstalled ${INSTALLDATA}/${EXEDIR}/${OUTNAME}'
	@echo ' Uninstalled ${INSTALLDATA}'
	@echo ' Go to ${INSTALLDATA} to recover user files:'
	@echo '       eg custom map.prefs or models, if needed'
	@echo ' '
	@echo '#############################################################'
	@echo ' MAPPINGS ${INSTALLDATA} Uninstalled.'
	@echo '#############################################################'
	@echo ' '
#
aux:
	cd aux; $(MAKE) all
