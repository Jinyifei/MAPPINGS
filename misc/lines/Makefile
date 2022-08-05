#
# v1.0.4 build 19
#
OUTNAME  = lines
OUTNAME2 = listlines
EXEDIR   = ./
#
SRCDIR  = src/
ZLSDIR  = zls/
CCLDIR  = zls/ccl/
ZLIBDIR = zls/zlib/
INCDIRS = -I${SRCDIR} -I${ZLSDIR} -I${ZLIBDIR} -I${CCLDIR}
#
# GENERIC CC
#
CC     =  cc
CFLAGS  = -O3
OPTS   = -c -o $*.o ${CFLAGS} ${INCDIRS}
LIB    = -lm
#
INCS    = ${ZLSDIR}zls.h
#
OBJ     = lines.o
OBJ2    = listlines.o
#
# basic set
#
ZLSOBJ = ${ZLSDIR}zls_arrs.o \
	${ZLSDIR}zls_qs.o \
	${ZLSDIR}zls_io.o \
	${ZLSDIR}zls_fitpoly.o \
	${ZLSDIR}ccl/bst.o \
	${ZLSDIR}ccl/ccl.o
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
#
%.o: %.c ${INCS}
	${CC} ${OPTS} $*.c
#
all:${EXEDIR}${OUTNAME} ${EXEDIR}${OUTNAME2}
#
${EXEDIR}${OUTNAME}: ${INCS} ${SRC} ${OBJ} ${ZLSOBJ} ${ZLIB}
	${CC} ${CFLAGS} -o ${EXEDIR}${OUTNAME} ${OBJ} ${ZLSOBJ} ${ZLIB} ${LIB}
#
${EXEDIR}${OUTNAME2}: ${INCS} ${SRC} ${OBJ2} ${ZLSOBJ} ${ZLIB}
	${CC} ${CFLAGS} -o ${EXEDIR}${OUTNAME2} ${OBJ2} ${ZLSOBJ} ${ZLIB} ${LIB}
#
clean:
	@echo ' Removing object files'
	@rm -f ${OBJ}
	@rm -f ${OBJ2}
	@rm -f ${ZLSOBJ}
	@rm -f ${ZLIB}
	@echo ' Done.'
#
install:
	[ -d /usr/local/bin ] || mkdir -p /usr/local/bin
	cp ${OUTNAME} /usr/local/bin/
	cp ${OUTNAME2} /usr/local/bin/
	@echo ' Installed ${OUTNAME} into /usr/local/bin'
#
uninstall:
	rm -f /usr/local/bin/${OUTNAME}
	rm -f /usr/local/bin/${OUTNAME2}
	@echo ' Uninstalled ${OUTNAME} from /usr/local/bin'
#
