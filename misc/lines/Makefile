#
# v1.0.4 build 19
#
# for ~/mappings520/bin
#
OUTNAME  = lines
OUTNAME2 = listlines
HOMEAREA = mappings520
BINDIR   = bin
#-------------------------------
# Install Areas
#
# std home area ~/ expanded with optional env vars
#
INSTALLBASE =$(shell echo ${HOME})
INSTALLBIN  =${INSTALLBASE}/${HOMEAREA}/${BINDIR}
#
# ADVANCED: for using the /usr/local data locations
# requires sudo powers
#
# INSTALLBASE = "/usr/local"
# INSTALLBIN  = "${INSTALLBASE}/${BINDIR}"
#
#-------------------------------
#
SRCDIR  = src/
ZLSDIR  = ../zls/
CCLDIR  = ../ccl/
ZLIBDIR = ../zlib/
INCDIRS = -I${SRCDIR} -I${ZLSDIR} -I${ZLIBDIR} -I${CCLDIR}
#
# GENERIC GCC
#
CC     =  gcc
CFLAGS  = -std=c99 -O3 -funsigned-char
OPTS   = -c -o $*.o -w ${CFLAGS} ${INCDIRS}
LIB    = -lm
#
INCS    = ${ZLSDIR}zls.h
#
OBJ     = ${SRCDIR}lines.o
OBJ2    = ${SRCDIR}listlines.o
#
# basic set
#
ZLSOBJ = ${ZLSDIR}zls_arrs.o \
	${ZLSDIR}zls_qs.o \
	${ZLSDIR}zls_io.o \
	${ZLSDIR}zls_fitpoly.o \
	${ZLSDIR}zls_splines.o \
	${ZLSDIR}zls_fft.o \
	${ZLSDIR}zls_convolve.o \
	${CCLDIR}ccl.o \
	${CCLDIR}bst.o
#
#-------------------------------
#-- zlib compression lib -------
#-------------------------------
#
ZLIB = ${ZLIBDIR}adler32.o \
	${ZLIBDIR}compress.o \
	${ZLIBDIR}crc32.o \
	${ZLIBDIR}deflate.o \
	${ZLIBDIR}gzio.o \
	${ZLIBDIR}infback.o \
	${ZLIBDIR}inffast.o \
	${ZLIBDIR}inflate.o \
	${ZLIBDIR}inftrees.o \
	${ZLIBDIR}trees.o \
	${ZLIBDIR}uncompr.o \
	${ZLIBDIR}zutil.o
#
SRC    = $(OBJ:.o=.c) $(ZLSOBJ:.o=.c) $(ZLIB:.o=.c)
SRC2   = $(OBJ2:.o=.c) $(ZLSOBJ:.o=.c) $(ZLIB:.o=.c)
#
%.o: %.c ${INCS}
	${CC} ${OPTS} $*.c
#
#-------------------------------
#---------  Targets  ----------
#-------------------------------
UNAME = $(shell uname)
#
ifeq ($(UNAME),Darwin)
	LIB  = -isysroot `xcrun --show-sdk-path`
	XSYS = macOS (with xcrun)
else
	LIB  =
	XSYS = Linux
endif
#
compile:${OUTNAME} ${OUTNAME2}
#
${OUTNAME}: ${INCS} ${SRC} ${OBJ} ${ZLSOBJ} ${ZLIB}
	@echo ' '
	@echo '#############################################################'
	@echo ' Compiling ${OUTNAME} for $(XSYS)'
	${CC} ${CFLAGS} -o ${OUTNAME} ${OBJ} ${ZLSOBJ} ${ZLIB} ${LIB}
	@echo '#############################################################'
	@echo ' '
	@echo '#############################################################'
	@echo ' ${OUTNAME} Compiled Successfully.'
	@echo '#############################################################'
#
${OUTNAME2}: ${INCS} ${SRC2} ${OBJ2} ${ZLSOBJ} ${ZLIB}
	@echo ' '
	@echo '#############################################################'
	@echo ' Compiling ${OUTNAME2} for $(XSYS)'
	${CC} ${CFLAGS} -o ${OUTNAME2} ${OBJ2} ${ZLSOBJ} ${ZLIB} ${LIB}
	@echo '#############################################################'
	@echo ' '
	@echo '#############################################################'
	@echo ' ${OUTNAME2} Compiled Successfully.'
	@echo '#############################################################'
#
clean:
	@echo ' '
	@echo '#############################################################'
	@echo ' Removing object files'
	@rm -f ${OBJ}
	@rm -f ${OBJ2}
	@rm -f ${ZLSOBJ}
	@rm -f ${ZLIB}
	@echo '#############################################################'
	@echo ' '
#
distclean:
	@echo ' '
	@echo '#############################################################'
	@echo ' Removing object files'
	@rm -f ${OBJ}
	@rm -f ${OBJ2}
	@rm -f ${ZLSOBJ}
	@rm -f ${ZLIB}
	@rm -f ${OUTNAME}
	@rm -f ${OUTNAME2}
	@echo '#############################################################'
	@echo ' '
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
	@echo 'Installing into ' ${INSTALLBIN}
	@echo ' '
	@make install
#
install:
	[ -d ${INSTALLBIN} ] || mkdir -p ${INSTALLBIN}
	cp ${OUTNAME}  ${INSTALLBIN}
	cp ${OUTNAME2} ${INSTALLBIN}
	@echo ' Installed ${OUTNAME} and ${OUTNAME2} into ${INSTALLBIN}'
#
uninstall:
	rm -f /usr/local/bin/${OUTNAME}
	rm -f /usr/local/bin/${OUTNAME2}
	@echo ' Uninstalled ${OUTNAME} and ${OUTNAME2} from ${INSTALLBIN}'
#
