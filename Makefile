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
OUTNAME = map52rss
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
#
#-------------------------------
#
# Install runtime areas:
#
# MAPPINGS can run in isolation or be incorporated into your shell environment
# in several ways. One way is to use the build area as the source
# for the libraries data and the binary. Other configurations are possible, see
# advanced installation options in the documentation.
#
# Standard installation uses a shell variable MAPDATA to locate the
# necessary running files, and MAPBIN is added to the user global
# path to the executable so MAPPINGS can run anywhere.
#
# An alias 'map' is made for whichever version of MAPPINGS V is being used. and is
# optional, so the direct executable name can still be used if desired.
#
# If using standard environment variables be sure to edit both the contents of
# both .bashrc and .tcshrc in your home area using the for_bashrc.sh and
# for_tcshrc.csh.  If you have newer macOS you may need to put for_bashrc.sh
# *also* into a .zshrc to all three shells can find the code consistently.
#
# As no data copying is needed, make install is not needed, simply
# make -j compile and adjust the login startup files with the for_ files
# as needed.
#
# The end of a successful compile process gives the value to use for
# both MAPDATA and MAPBIN in the shell scripts.
#
#
INSTALLBASE =$(shell pwd)
INSTALLDATA ="${INSTALLBASE}/lab"
INSTALLBIN  ="${INSTALLBASE}/lab"
#
# Manual Setup: if a make install is necessary, to copy files to the
# different locations, sudo power may be required, but local user areas are
# allowed too.
#
# MAPDATA and MAPBIN may be the same path or different, but are the same by
# default.
#
# Do not add a trailing / to the paths.
#
# eg: a sudo is required and MAPBIN and MAPDATA point to different locations
# similar to a CLOUDY installation. /opt/local is also often used as a base
# on macOS with macports installations.
#
#INSTALLBASE = "/usr/local"
#INSTALLDATA = "${INSTALLBASE}/share/mappings"
#INSTALLBIN  = "${INSTALLBASE}/bin"
#
#-------------------------------
#---------- Compilers ----------
#-------------------------------
#
# GCC FORTRAN - gfortran standard default build
# tested with v11 but should work with v4.5 or newer
# standard build in 2022 is gfortran v10.x
#
# In Linux, use normal repositories
# on OSX, use MacPorts.org/homebrew to get gcc8 or newer,
#
#  GCC FORTRAN v4.9-11.x
#  macOS xcode 11+ -isysroot`xcrun --show-sdk-path` if -lSyslib is not found
#  gcc10+ flto=n parallel global obj optimisation, slow but some performance
#         improvement, set n to ncpus eg flto=8 on an 8 core machine.
#
# if recursion is ever needed use: -fmax-stack-var-size=7618560
#
#WARN   = -Wall
#WARN   = -Wunused-variable -Wconversion -Wmaybe-uninitialized -fbounds-check
WARN   =
#
# plain
#
# FC     = gfortran -std=legacy
# LDR    = ${WARN} -Ofast -ffpe-summary='none'
# OPTS   = -c ${LDR} -I${INCDIR}
# LIB    =
#
# Standard no flto, optional flto or debugging LDR commented.
#
FC     = gfortran -std=legacy -march=native
LDR    =  ${WARN} -Ofast -ffpe-summary='none'
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

help:
	@cat ${CODDIR}/credits.txt
	@echo " "
	@echo "MAPPINGS V v5.2.0 make options:"
	@echo " "
	@echo "'make help'       to see this menu"
	@echo "'make compile'    to create ${OUTNAME} in ${INSTALLBIN}"
	@echo "                  gives optional ${INSTALLBIN}"
	@echo "'make clean'      to clean up '*.o' ready to run"
	@echo "'make distclean'  as clean but also remove ${OUTNAME}"
	@echo " "
	@echo " Optional:"
	@echo "'make build'         make compile and clean combined"
	@echo "'sudo make install'  to install in"
	@echo "                     ${INSTALLBIN}"
	@echo "                   & ${INSTALLDATA}"
	@echo " "
	@echo "'sudo make installcode' to install the built code only into"
	@echo "                        ${INSTALLBIN}"
	@echo "'make uninstall'     remove installed ${OUTNAME}"
	@echo " "

#
#-----------------------------------------------------------
#
clean:
	@echo ' Removing object files'
	@rm -f ${OBJ}
#
distclean:
	@echo ' Removing object files and exe'
	@rm -f ${OBJ}
	@rm -f ${EXEDIR}/${OUTNAME}
#
#------------------------------------------------------------
#
compile: ${EXEDIR}/${OUTNAME}
#
# compile and create input for .bashrc and .tcshrc etc
#
${EXEDIR}/${OUTNAME}: ${INCS} ${OBJ}
	@echo ' #############################################################'
	@echo ' Compiling ${OUTNAME} for $(XSYS)'
	${FC} ${LDR} -o ${EXEDIR}/${OUTNAME} ${OBJ} ${LIB}
	@echo ' #############################################################'
	@echo ' Done.  Compiled Successfully'
	@echo ' #############################################################'
	@echo ' A local version of the executable ${OUTNAME} can be found in:'
	@echo ' ${EXEDIR} . Install startup variables for .bashrc and .tcshrc'
	@echo ' with the contents of "for_bashrc.sh" and "for_tcshrc.csh", '
	@echo ' as needed.'
	@echo ' (macOS users may need to use .zshrc with the bashrc settings)'
	@echo ' #############################################################'
	@cat src/src-bashrc.txt > for_bashrc.sh
	@echo 'export mapbase="${INSTALLBASE}"' >> for_bashrc.sh
	@echo 'export MAPDATA="$$mapbase/lab"' >> for_bashrc.sh
	@echo 'export MAPBIN="$$mapbase/lab"' >> for_bashrc.sh
	@echo '# add bin area to global path:' >> for_bashrc.sh
	@echo 'export PATH="$$MAPBIN:$$PATH"' >> for_bashrc.sh
	@echo '#' >> for_tcshrc.sh
	@echo "# add a generic map alias for every executable version" >> for_bashrc.sh
	@echo '#' >> for_tcshrc.sh
	@echo 'alias map=${OUTNAME}' >> for_bashrc.sh
	@echo '#' >> for_bashrc.sh
	@echo '########################################################################' >> for_bashrc.sh
	@cat src/src-tcshrc.txt > for_tcshrc.sh
	@echo 'set mapbase = "${INSTALLBASE}"' >> for_tcshrc.sh
	@echo 'setenv MAPDATA "$$mapbase/lab"' >> for_tcshrc.sh
	@echo 'set mapbin = "$$mapbase/lab"' >> for_tcshrc.sh
	@echo 'setenv MAPBIN "$$mapbin"' >> for_tcshrc.sh
	@echo '#' >> for_tcshrc.sh
	@echo '# add bin area to global path:' >> for_tcshrc.sh
	@echo '#' >> for_tcshrc.sh
	@echo 'set path = ($$mapbin $$path)' >> for_tcshrc.sh
	@echo '#' >> for_tcshrc.sh
	@echo "# add a generic map alias for every executable version" >> for_tcshrc.sh
	@echo '#' >> for_tcshrc.sh
	@echo 'alias map ${OUTNAME}' >> for_tcshrc.sh
	@echo '#' >> for_tcshrc.sh
	@echo '########################################################################' >> for_tcshrc.sh
#
#------------------------------------------------------------
#
build:
	@echo 'Building ${OUTNAME} for $(XSYS)'
	@make compile
	@echo 'Removing object files'
	@rm -f ${OBJ}
	@echo 'Done.  Compile and Cleaned Successfully'
#
#------------------------------------------------------------
#
# main install into shared locations, be sure to put correct locations into
# bashrc.sh and .tcshrc  and/or .cshrc or .kshrc
#
install:
	[ -d ${INSTALLBIN} ] || mkdir -p ${INSTALLBIN}
	[ -d ${INSTALLDATA} ] || mkdir -p ${INSTALLDATA}
	cp ${EXEDIR}/${OUTNAME} ${INSTALLBIN}/
	cp ${EXEDIR}/map.prefs ${INSTALLBIN}/
	cp ${EXEDIR}/mapStd.prefs ${INSTALLBIN}/
	cp ${EXEDIR}/mapFull.prefs ${INSTALLBIN}/
	cp -r ${EXEDIR}/data ${INSTALLDATA}/
	cp -r ${EXEDIR}/abund ${INSTALLDATA}/
	cp -r ${EXEDIR}/prefs ${INSTALLDATA}/
	cp -r ${EXEDIR}/atmos ${INSTALLDATA}/
	cp -r ${EXEDIR}/scripts ${INSTALLDATA}/
	@echo ' Installed ${OUTNAME} into ${INSTALLBIN}/ and ${INSTALLDATA}/'
#
installcode:
	[ -d ${INSTALLBIN} ] || mkdir -p ${INSTALLBIN}
	cp ${EXEDIR}/${OUTNAME} ${INSTALLBIN}/
	@echo ' Installed ${OUTNAME} into ${INSTALLBIN}/'
#
#------------------------------------------------------------
#
uninstall:
	rm -f "${INSTALLBIN}/${OUTNAME}"
	@echo ' Uninstalled "${INSTALLBIN}/${OUTNAME}"
	@echo ' Goto "$(INSTALLDATA}" and remove mappings only
	@echo ' if it is not the home install area.'
#
