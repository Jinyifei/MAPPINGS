#
# Make MAPPINGS V
#
#    v5.2.0
#-------------------------------
#--- Output (executable) name --
#-------------------------------
#
OUTNAME = map52dev
#
#
#-------------------------------
#---------- Directories --------
#-------------------------------
#
# output build areas, Knox can you help make this a make / setup option
# to copy or link the master lab to an install area to match the
# enviroment variables in the shell.
#
EXEDIR = lab/
CODDIR = src/
#
#-------------------------------
#
INSTALLBASE = /usr/local
INSTALLDATA = "${INSTALLBASE}/share/mappings"
INSTALLBIN  = "${INSTALLBASE}/bin"
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
	cat ${CODDIR}/credits.txt
	@echo ' '
	@echo MAPPINGS V v5.2.0 make options:
	@echo ' '
	@echo Type "'make help'    to see this menu"
	@echo Type "'make compile' to create executable in ${EXEDIR}"
	@echo Type "'make clean'   to clean src/ and remove '*.o'"
	@echo ' '
	@echo Type "'make build'   to recreate executable from scratch and clean in ${EXEDIR}"
	@echo ' '
	@echo Type "'sudo make install'     to install the built code and data into ${INSTALLBASE}"
	@echo Type "'sudo make installcode' to install the built code only into ${INSTALLBIN}"
	@echo ' '
	@echo Type "'make uninstall' remove ${INSTALLBIN} and ${INSTALLDATA} from ${INSTALLBASE}"
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
#-----------------------------------------------------------
#
clean:
	@echo ' Removing object files'
	@rm -f ${OBJ}
#
#------------------------------------------------------------
#
compile:${EXEDIR}${OUTNAME} ${INCS} ${OBJ}
	@echo ' Compiling ${OUTNAME} for $(XSYS)'
	${FC} ${LDR} -o ${EXEDIR}${OUTNAME} ${OBJ} ${LIB}
	@echo ' Done.  Compiled Successfully'
	@echo ' Done.  A local version of the executable ${OUTNAME} can be found in ${EXEDIR}'

#
#------------------------------------------------------------
#
build:
	@echo ' Building ${OUTNAME} for $(XSYS)'
	@make compile
	@echo ' Removing object files'
	@rm -f ${OBJ}
	@echo ' Done.  Build and Clean Successfully'
	@echo ' Done.  A local version of the executable ${OUTNAME} can be found in ${EXEDIR}'
#
#------------------------------------------------------------
#
# main install into shared locations, be sure to put correct locations into
# bashrc.sh and .tcshrc  and/or .cshrc or .kshrc
#
install:
	[ -d "${INSTALLBIN}" ]  || mkdir -p "${INSTALLBIN}"
	[ -d "$(INSTALLDATA}" ] || mkdir -p "$(INSTALLDATA}"
	cp ${EXEDIR}${OUTNAME} "${INSTALLBIN}"
	cp ${EXEDIR}mapStd.prefs "$(INSTALLDATA}"
	cp -r ${EXEDIR}data  "$(INSTALLDATA}"
	cp -r ${EXEDIR}abund "$(INSTALLDATA}"
	cp -r ${EXEDIR}atmos "$(INSTALLDATA}"
	@echo ' Installed ${OUTNAME} into "${INSTALLBIN}" and "$(INSTALLDATA}"'
#
installcode:
	[ -d "${INSTALLBIN}"  ] || mkdir -p "${INSTALLBIN}"
	cp ${EXEDIR}${OUTNAME} "${INSTALLBIN}"
	@echo ' Installed ${OUTNAME} into "${INSTALLBIN}"'
#
#------------------------------------------------------------
#
uninstall:
	rm -f "${INSTALLBIN}/${OUTNAME}"
	rm -rf "$(INSTALLDATA}"
	@echo ' Uninstalled "${INSTALLBIN}/${OUTNAME}" and "$(INSTALLDATA}"'
#
