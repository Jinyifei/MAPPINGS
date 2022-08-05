#
# v1.0.1
#
OUTNAME = ./blur
EXEDIR  = ./
#
SRCDIR  = src/
ZLSDIR  = zls/
ZLIBDIR  = zlib/
INCDIRS = -I${SRCDIR} -I${ZLSDIR} -I${ZLIBDIR}
#
# GENERIC GCC
#
CC     =  gcc
CFLAGS  = -std=c99 -O3 -funsigned-char -isysroot`xcrun --show-sdk-path`
OPTS   = -c -o $*.o -w ${CFLAGS} ${INCDIRS}
LIB    = -lm -isysroot`xcrun --show-sdk-path`
#
INCS    = ${ZLSDIR}zls.h
OBJ     = blur.o \
#
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

all:${EXEDIR}${OUTNAME}

${EXEDIR}${OUTNAME}: ${INCS} ${SRC} ${OBJ} ${ZLSOBJ} ${ZLIB}
	${CC} ${CFLAGS} -o ${EXEDIR}${OUTNAME} ${OBJ} ${ZLSOBJ} ${GSLOBJ} ${ZLIB} ${LIB}

clean:
	@echo ' Removing object files'
	@rm -f ${OBJ}
	@rm -f ${ZLSOBJ}
	@rm -f ${ZLIB}
	@echo ' Done.'

install:
	[ -d /usr/local/bin ] || mkdir -p /usr/local/bin
	cp ${OUTNAME} /usr/local/bin/
	@echo ' Installed ${OUTNAME} into /usr/local/bin'

uninstall:
	rm -f /usr/local/bin/${OUTNAME}
	@echo ' Uninstalled ${OUTNAME} from /usr/local/bin'
