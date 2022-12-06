#
# v1.0.8
#
# for ~/mappings520/bin
#
OUTNAME  = blur
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
SRCDIR  = ./
ZLSDIR  = ../zls/
ZLIBDIR  = ../zlib/
INCDIRS = -I${SRCDIR} -I${ZLSDIR} -I${ZLIBDIR}
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
OBJ     = ${SRCDIR}blur.o
#
# basic set
ZLSOBJ = ${ZLSDIR}zls_arrs.o \
	${ZLSDIR}zls_qs.o \
	${ZLSDIR}zls_io.o \
	${ZLSDIR}zls_fitpoly.o \
	${ZLSDIR}zls_splines.o \
	${ZLSDIR}zls_fft.o \
	${ZLSDIR}zls_convolve.o
#-------------------------------
#-- zlib compression lib -------
#-------------------------------
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
#
%.o: %.c ${INCS}
	${CC} ${OPTS} $*.c
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

compile:${OUTNAME}

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

clean:
	@echo ' '
	@echo '#############################################################'
	@echo ' Cleaning ${OUTNAME} object files'
	@rm -f ${OBJ}
	@rm -f ${ZLSOBJ}
	@rm -f ${ZLIB}
	@echo '#############################################################'
	@echo ' '

distclean:
	@echo ' '
	@echo '#############################################################'
	@echo ' Cleaning ${OUTNAME} and ${OUTNAME} object files'
	@rm -f ${OBJ}
	@rm -f ${ZLSOBJ}
	@rm -f ${ZLIB}
	@rm -f ${OUTNAME}
	@echo '#############################################################'
	@echo ' '

build:
	@echo 'Building ${OUTNAME} for $(XSYS)'
	@make compile
	@echo 'Cleaning'
	@make clean
	@echo ' '
	@echo '#############################################################'
	@echo ' Compile and Cleaned ${OUTNAME} Successfully...'
	@echo '#############################################################'
	@echo ' '
	@echo 'Installing into ' ${INSTALLBIN}
	@echo ' '
	@make install

install:
	[ -d ${INSTALLBIN} ] || mkdir -p ${INSTALLBIN}
	cp ${OUTNAME} ${INSTALLBIN}
	@echo ' Installed ${OUTNAME} into ${INSTALLBIN}'

uninstall:
	rm -f  ${INSTALLBIN}/${OUTNAME}
	@echo ' Uninstalled ${OUTNAME} from ${INSTALLBIN}'
