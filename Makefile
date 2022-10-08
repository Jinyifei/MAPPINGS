#
# Make MAPPINGS V
#
#    v5.2.0rss
#-------------------------------
#--- Output (executable) name --
#-------------------------------
#
OUTNAME = map52rss
#
#-------------------------------
#---------- Directories --------
#-------------------------------
#
# output area, Knox can you help make this a make / setup option
# to copy or link the master lab to an install area to match the
# enviroment variables in the shell.
#
EXEDIR = lab/
CODDIR = src/
#
#-------------------------------
#---------- Compilers ----------
#-------------------------------
#
# GCC FORTRAN - gfortran generic, recommend GCC v10.x
# tested with v11 but should work with v4.5 or newer, 8.x+ preferred
# on OSX, use MacPorts.org to get gcc10 or newer.
# In Linux, use normal repositories, cygwin - try pgi fortran
#
#  GCC FORTRAN v4.9-11.x - added fpe suppression switch,
#  otherwise as v4.8
#  xcode 11+ -isysroot`xcrun --show-sdk-path` if -lSyslib is not found
#  gcc10+ flto=n parallel global obj optimisation, slow but some performance
#         improvement, set n to ncpus eg flto=8 on an 8 core machine.
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
# if recursion is ever needed; -fmax-stack-var-size=7618560
# no flto by default, use flto for longer build time but some perforance
#
FC     = gfortran -std=legacy -march=native
LDR    =  ${WARN} -Ofast -ffpe-summary='none'
#LDR    =  ${WARN} -Ofast -flto=8 -ffpe-summary='none'
#LDR    = ${WARN} -g -O0 -fbounds-check -ffpe-summary='none'
OPTS   = -c ${LDR} -I${CODDIR}
#
UNAME = $(shell uname)
#
ifeq ($(UNAME),Darwin)
	LIB    = -isysroot`xcrun --show-sdk-path`
	XSYS = macOS (with xcrun)
else
	LIB =
	XSYS = Linux
endif
#
start:
	@echo MAPPINGS V v5.2.0 make options:
	@echo ' '
	@echo Type "'make help'    to see this menu"
	@echo Type "'make build'   to create executable from scratch and clean in ../lab"
	@echo ' '
	@echo Type "'sudo make install'   to install the built code and data into /usr/local"
	@echo Type "'sudo make installcode' to install the built code only into /usr/local"
	@echo ' '
	@echo Type "'sudo make installopt' to install the built code and data into /opt/local"
	@echo Type "'sudo make installcodeopt' to install the built code only into /opt/local"
	@echo ' '
	@echo Type "'make clean'   to remove '*.o'"
	@echo ' '
	@echo Type "'make uninstall' remove /usr/local/"
	@echo Type "'make uninstallopt' remove /opt/local/"
#
#
.SUFFIXES:
.SUFFIXES: .f .o
#
#-------------------------------
#-- include/header files -------
#-------------------------------
#
INCS =  ${CODDIR}cblocks.inc \
	${CODDIR}const.inc \
	${CODDIR}p6blocks.inc \
	${CODDIR}p7blocks.inc \
	${CODDIR}s5blocks.inc
#
#-------------------------------
#-- object files ---------------
#-------------------------------
#
OBJ = ${CODDIR}mappings.o \
	${CODDIR}allrates.o \
	${CODDIR}absdis.o \
	${CODDIR}avrdata.o \
	${CODDIR}changes.o \
	${CODDIR}charex.o \
	${CODDIR}cheat.o \
	${CODDIR}collion.o \
	${CODDIR}coloss.o \
	${CODDIR}compton.o \
	${CODDIR}coolc.o \
	${CODDIR}cool.o \
	${CODDIR}cosmic.o \
	${CODDIR}crosssections.o \
	${CODDIR}dusttemp.o \
	${CODDIR}equion.o \
	${CODDIR}evoltem.o \
	${CODDIR}fine3.o \
	${CODDIR}findtde.o \
	${CODDIR}freebound.o \
	${CODDIR}freefree.o \
	${CODDIR}functions.o \
	${CODDIR}grainpar.o \
	${CODDIR}heavyrec.o \
	${CODDIR}helioi.o \
	${CODDIR}hgrains.o \
	${CODDIR}hpahs.o \
	${CODDIR}hhecoll.o \
	${CODDIR}hydrec.o \
	${CODDIR}hydro.o \
	${CODDIR}hydro2p.o \
	${CODDIR}inter.o \
	${CODDIR}interpol.o \
	${CODDIR}intvec.o \
	${CODDIR}iobal.o \
	${CODDIR}iohyd.o \
	${CODDIR}ionemit.o \
	${CODDIR}ionab.o \
	${CODDIR}ionsec.o \
	${CODDIR}kappainit.o \
	${CODDIR}localem.o \
	${CODDIR}mapinit.o \
	${CODDIR}mdiag.o \
	${CODDIR}multilevel.o \
	${CODDIR}neqc.o \
	${CODDIR}netgain.o \
	${CODDIR}newdif.o \
	${CODDIR}optxagnf.o \
	${CODDIR}output.o \
	${CODDIR}pheat.o \
	${CODDIR}phion.o \
	${CODDIR}phocrv.o \
	${CODDIR}photo6.o \
	${CODDIR}photo7.o \
	${CODDIR}photsou.o \
	${CODDIR}poputil.o \
	${CODDIR}preion.o \
	${CODDIR}rankhug.o \
	${CODDIR}ratec.o \
	${CODDIR}rebin.o \
	${CODDIR}recom.o \
	${CODDIR}reson.o \
	${CODDIR}sdifeq.o \
	${CODDIR}shock4.o \
	${CODDIR}shock5.o \
	${CODDIR}sinsla.o \
	${CODDIR}slab.o \
	${CODDIR}spectrum.o \
	${CODDIR}spotap.o \
	${CODDIR}strutil.o \
	${CODDIR}sumdata.o \
	${CODDIR}teequi.o \
	${CODDIR}timion.o \
	${CODDIR}timtqui.o \
	${CODDIR}totphot.o \
	${CODDIR}transferline.o \
	${CODDIR}twophoton.o \
	${CODDIR}zer.o \
	${CODDIR}zetaeff.o
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
#
#-----------------------------------------------------------
#
clean:
	@echo ' Removing object files'
	@rm -f ${OBJ}
	@echo ' Done.'
#
#------------------------------------------------------------
#
compile:${EXEDIR}${OUTNAME}
#
${EXEDIR}${OUTNAME}: ${INCS} ${OBJ}
	${FC} ${LDR} -o ${EXEDIR}${OUTNAME} ${OBJ} ${LIB}

#
#------------------------------------------------------------
#
build:
	@echo ' Building ${OUTNAME}:'
	@echo ' Compiling for $(XSYS)'
	@make compile
	@echo ' Removing object files'
	@rm -f ${OBJ}
	@echo ' Done.  Compiled Successfully'
	@echo ' Done.  A local version of the executable ${OUTNAME} can be found in ${EXEDIR}'
#
#------------------------------------------------------------
#
install:
	[ -d /usr/local/bin ] || mkdir -p /usr/local/bin
	[ -d /usr/local/share/mappings ] || mkdir -p /usr/local/share/mappings
	cp ${EXEDIR}${OUTNAME} /usr/local/bin/
	cp ${EXEDIR}mapStd.prefs /usr/local/share/mappings/
	cp -r ${EXEDIR}data /usr/local/share/mappings/
	cp -r ${EXEDIR}abund /usr/local/share/mappings/
	cp -r ${EXEDIR}atmos /usr/local/share/mappings/
	@echo ' Installed ${OUTNAME} into /usr/local/bin and /usr/local/share/mappings'
#
installcode:
	[ -d /usr/local/bin ] || mkdir -p /usr/local/bin
	cp ${EXEDIR}${OUTNAME} /usr/local/bin/
	@echo ' Installed ${OUTNAME} into /usr/local/bin'
#
#------------------------------------------------------------
#
installopt:
	[ -d /opt/local/bin ] || mkdir -p /opt/local/bin
	[ -d /opt/local/share/mappings ] || mkdir -p /opt/local/share/mappings
	cp ${EXEDIR}${OUTNAME} /opt/local/bin/
	cp ${EXEDIR}mapStd.prefs /opt/local/share/mappings/
	cp -r ${EXEDIR}data /opt/local/share/mappings/
	cp -r ${EXEDIR}abund /opt/local/share/mappings/
	cp -r ${EXEDIR}atmos /opt/local/share/mappings/
	@echo ' Installed ${OUTNAME} into /opt/local/bin and /opt/local/share/mappings'
#
installcodeopt:
	[ -d /opt/local/bin ] || mkdir -p /opt/local/bin
	cp ${EXEDIR}${OUTNAME} /opt/local/bin/
	@echo ' Installed ${OUTNAME} into /opt/local/bin'
#
#------------------------------------------------------------
#
# Maybe make pick up a user path
#
uninstall:
	rm -f /usr/local/bin/${OUTNAME}
	rm -rf /usr/local/share/mappings
	@echo ' Uninstalled /usr/local/bin/${OUTNAME} and /usr/local/share/mappings'
#
uninstallopt:
	rm -f /opt/local/bin/${OUTNAME}
	rm -rf /opt/local/share/mappings
	@echo ' Uninstalled /opt/local/bin/${OUTNAME} and /opt/local/share/mappings'
#
uninstallall:
	rm -f /usr/local/bin/${OUTNAME}
	rm -rf /usr/local/share/mappings
	@echo ' Uninstalled /usr/local/bin/${OUTNAME} and /usr/local/share/mappings'
	rm -f /opt/local/bin/${OUTNAME}
	rm -rf /opt/local/share/mappings
	@echo ' Uninstalled /opt/local/bin/${OUTNAME} and /opt/local/share/mappings'

