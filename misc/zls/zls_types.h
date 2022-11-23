#ifndef ZLS_TYPES_H
#define ZLS_TYPES_H

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <strings.h>
#include <math.h>
#include <limits.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/times.h>
#include <time.h>

#include "zlib.h"

//================================================================================
// Computer/Achitecture related defines for ZLS,
// set OS, multi-processing,
// precisions etc plus debug level.
//================================================================================
//
#define ZLS_DEBUG   0
#define ZLS_VERBOSE 1
//
#define OS_GENERIC
//#define OS_GENERICLINUX
//#define OS_CENTOS
//#define OS_CYGWIN
//#define OS_SOLARISSPARC
//#define OS_SOLARISAMD64
//#define OS_MACOSXG4
//#define OS_MACOSXG5
//#define OS_MACOSXCORE
//uncomment the following if running in MacOS X 10.4 or older.
//#define OS_MACOSX104TIMING
//

#define PTHREADS
#define NCPUs 1
#define ZLS_MAXPTHREADS 1

//================================================================================
// SINGLE_PRECISION = 32 bit floating pt, fast, but low range/accuracy, less memory
// DOUBLE_PRECISION = 64 bit floating pt, best range/accuracy, more memory
//#define SINGLE_PRECISION
#define DOUBLE_PRECISION
//
//================================================================================


#if defined(SINGLE_PRECISION)
typedef float Real;
typedef float Complex[2];
#elif defined(DOUBLE_PRECISION)
typedef double Real;
typedef double Complex[2];
#else
#error "Not a valid precision flag"
#endif //

typedef float         Real32;

#ifdef OS_GENERIC
typedef int      Integer;
typedef short    SInt16;
typedef char     SInt8;  // char treated as signed
typedef unsigned int    Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef unsigned short   UInt16;
typedef unsigned char    UInt8;  // char treated as unsigned
typedef Counter UInt32; // convenience alias for Counter in low level routines
typedef Integer SInt32; // convenience alias for Integer in low level routines
typedef unsigned long     Size;
#endif // OS_GENERIC

#ifdef OS_GENERICLINUX
typedef int      Integer;
typedef short    SInt16;
typedef char     SInt8;  // char treated as signed
typedef unsigned int    Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef unsigned short   UInt16;
typedef unsigned char    UInt8;  // char treated as unsigned
typedef Counter UInt32; // convenience alias for Counter in low level routines
typedef Integer SInt32; // convenience alias for Integer in low level routines
typedef unsigned long     Size;
#endif // OS_GENERICLINUX

#ifdef OS_CYGWIN
typedef int      Integer;
typedef short    SInt16;
typedef char     SInt8;  // char treated as signed
typedef unsigned int    Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef unsigned short   UInt16;
typedef unsigned char    UInt8;  // char treated as unsigned
typedef Counter UInt32; // convenience alias for Counter in low level routines
typedef Integer SInt32; // convenience alias for Integer in low level routines
typedef unsigned long     Size;
#endif // OS_CYGWIN

#ifdef OS_MACOSXG4
typedef int32_t    Integer;
typedef int16_t    SInt16;
typedef int8_t     SInt8;  // char treated as signed
typedef u_int32_t  Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef u_int16_t  UInt16; // unsigned 16 bit for 2D image IO , Tiffs and Raw.
typedef u_int8_t   UInt8;  // char treated as unsigned
typedef Counter UInt32; // convenience alias for Counter in low level routines
typedef Integer SInt32; // convenience alias for Integer in low level routines
typedef size_t     Size;  // 32 or 64 bit depending on OS, not used in saved structures.
                          // For memory and file size allocations only
#endif // OS_MACOSXG4

#ifdef OS_MACOSXG5
typedef int32_t    Integer;
typedef int16_t    SInt16;
typedef int8_t     SInt8;  // char treated as signed
typedef u_int32_t  Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef u_int16_t  UInt16;
typedef u_int8_t   UInt8;  // char treated as unsigned
typedef Counter UInt32; // convenience alias for Counter in low level routines
typedef Integer SInt32; // convenience alias for Integer in low level routines
typedef size_t     Size;  // 32 or 64 bit depending on OS, not used in saved structures.
                          // For memory and file size allocations only
#endif // OS_MACOSXG5

#ifdef OS_MACOSXCORE
typedef int32_t    Integer;
typedef int16_t    SInt16;
typedef int8_t     SInt8;  // char treated as signed
typedef u_int32_t  Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef u_int16_t  UInt16;
typedef u_int8_t   UInt8;  // char treated as unsigned
typedef Counter UInt32; // convenience alias for Counter in low level routines
typedef Integer SInt32; // convenience alias for Integer in low level routines
typedef size_t     Size;  // 32 or 64 bit depending on OS, not used in saved structures.
                          // For memory and file size allocations only
#endif // OS_MACOSXCORE

#ifdef OS_CENTOS
typedef int32_t    Integer;
typedef int16_t    SInt16;
typedef int8_t     SInt8;  // char treated as signed
typedef u_int32_t   Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef u_int16_t   UInt16;
typedef u_int8_t    UInt8;  // char treated as unsigned
typedef Counter   UInt32; // convenience alias for Counter in low level routines
typedef Integer   SInt32; // convenience alias for Integer in low level routines
typedef size_t     Size;  // 32 or 64 bit depending on OS, not used in saved structures.
                          // For memory and file size allocations only
#endif // OS_CENTOS

#ifdef OS_SOLARISSPARC
typedef int32_t    Integer;
typedef int16_t    SInt16;
typedef int8_t     SInt8;  // char treated as signed
typedef uint32_t   Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef uint16_t   UInt16;
typedef uint8_t    UInt8;  // char treated as unsigned
typedef Counter UInt32; // convenience alias for Counter in low level routines
typedef Integer SInt32; // convenience alias for Integer in low level routines
typedef size_t     Size;  // 32 or 64 bit depending on OS, not used in saved structures.
                          // For memory and file size allocations only
#endif // OS_SOLARISSPARC

#ifdef OS_SOLARISAMD64
typedef int32_t    Integer;
typedef int16_t    SInt16;
typedef int8_t     SInt8;  // char treated as signed
typedef uint32_t   Counter; // all 32 bit counters, ie cycles etc, and keeps binary dumps predictable.
typedef uint16_t   UInt16;
typedef uint8_t    UInt8;  // char treated as unsigned
typedef Counter UInt32; // convenience alias for Counter in low level routines
typedef Integer SInt32; // convenience alias for Integer in low level routines
typedef size_t     Size;  // 32 or 64 bit depending on OS, not used in saved structures.
                          // For memory and file size allocations only
#endif // OS_SOLARISAMD64


#ifndef FLT_MAX
#define FLT_MAX (3.40282347E+38F)
#endif //

#ifndef FLT_MIN
#define FLT_MIN (1.17549435E-38F)
#endif //

#ifndef FLT_EPSILON
#define FLT_EPSILON (1.17549435E-8F)
#endif //

#ifndef DBL_MAX
#define DBL_MAX (1.7976931348623157E+308)
#endif //

#ifndef DBL_MIN
#define DBL_MIN (2.2250738585072014E-308)
#endif //

#ifndef DBL_EPSILON
#define DBL_EPSILON (2.2204460492503131E-016)
#endif //

#ifndef MAX_INTEGER
#define MAX_INTEGER (2L<<30)
#endif // MAX_INTEGER

#ifdef DOUBLE_PRECISION
#ifdef OS_MACOSXCORE
#define      zls_isnan( x )   isnan ((x))
#endif // OS_MACOSXCORE xcode4+

#ifdef OS_MACOSXG5
#define      zls_isnan( x )   __isnand ((x))
#endif // OS_MACOSXG5

#ifdef OS_MACOSXG4
#define      zls_isnan( x )   __isnand ((x))
#endif // OS_MACOSXG4

#ifdef OS_SOLARISSPARC
#define      zls_isnan( x )   isnand ((x))
#endif // OS_SOLARISSPARC

#ifdef OS_SOLARISAMD64
#define      zls_isnan( x )   isnand ((x))
#endif // OS_SOLARISAMD64

#ifdef OS_GENERIC
#define      zls_isnan( x )   isnan ((x))
#endif // OS_GENERIC

#ifdef OS_GENERICLINUX
#define      zls_isnan( x )   isnan ((x))
#endif // OS_GENERICLINUX

#ifdef OS_CENTOS
#define      zls_isnan( x )   isnan ((x))
#endif // OS_CENTOS

#ifdef OS_CYGWIN
#define      zls_isnan( x )   isnan ((x))
#endif // OS_CYGWIN

#endif // DOUBLE_PRECISION

#ifdef SINGLE_PRECISION
#ifdef OS_MACOSXCORE
#define      zls_isnan( x )   __isnanf ((x))
#endif // OS_MACOSXCORE

#ifdef OS_MACOSXG5
#define      zls_isnan( x )   __isnanf ((x))
#endif // OS_MACOSXG5

#ifdef OS_MACOSXG4
#define      zls_isnan( x )   __isnanf ((x))
#endif // OS_MACOSXG4

#ifdef OS_SOLARISSPARC
#define      zls_isnan( x )   isnanf ((x))
#endif // OS_SOLARISSPARC

#ifdef OS_SOLARISAMD64
#define      zls_isnan( x )   isnanf ((x))
#endif // OS_SOLARISAMD64

#ifdef OS_GENERIC
#define      zls_isnan( x )   isnan ((x))
#endif // OS_GENERIC

#ifdef OS_GENERICLINUX
#define      zls_isnan( x )   isnan ((x))
#endif // OS_GENERICLINUX

#ifdef OS_CENTOS
#define      zls_isnan( x )   isnan ((x))
#endif // OS_CENTOS

#ifdef OS_CYGWIN
#define      zls_isnan( x )   isnan ((x))
#endif // OS_CYGWIN

#endif // SINGLE_PRECISION

//
// Sanity check if PTHREADS are not defined and make NCPUs default to 1
// if NCPUs is still not defined then set it to 1
//
#ifndef PTHREADS
#ifdef NCPUs
#undef NCPUs
#endif //
#define NCPUs 1
#endif // PTHREADS

#ifndef NCPUs
#define NCPUs 1
#endif //

//
// flags for general data IO.  TIFFIO has it's own internal endian flags.
//

#ifdef OS_GENERICLINUX
#define DATA_LITENDIAN_OS
#endif // OS_GENERICLINUX

#ifdef OS_CENTOS
#define DATA_LITENDIAN_OS
#endif // OS_CENTOS

#ifdef OS_CYGWIN
#define DATA_LITENDIAN_OS
#endif // OS_CYGWIN

#ifdef OS_SOLARISAMD64
#define DATA_LITENDIAN_OS
#endif // OS_SOLARISAMD64

#ifdef OS_SOLARISSPARC
#define DATA_BIGENDIAN_OS
#endif // OS_SOLARISSPARC

#ifdef OS_MACOSXG4
#define DATA_BIGENDIAN_OS
#endif // OS_MACOSXG4

#ifdef OS_MACOSXG5
#define DATA_BIGENDIAN_OS
#endif // OS_MACOSXG5

#ifdef OS_MACOSXCORE
#define DATA_LITENDIAN_OS
#endif // OS_MACOSXCORE

    // default DATA_LITENDIAN_OS if nothing matches

#ifndef DATA_BIGENDIAN_OS
#ifndef DATA_LITENDIAN_OS
#define DATA_LITENDIAN_OS
#endif //
#endif //


//typedef double          Real;
//typedef double    Complex[2];

//typedef signed char  SInt8;  // char treated as signed
//typedef short       SInt16;
//typedef int         SInt32;
//
//typedef unsigned char    UInt8;  // char treated as unsigned
//typedef unsigned short  UInt16;
//typedef unsigned int    UInt32;
////
//typedef int Integer;
//typedef UInt32 Counter;

typedef size_t MemSize;

typedef Real  (*function_type) (Real);
    //========================================
    //
    // Basic Errors
    //
    //========================================
    //
enum { NoErr = 0,
    noErr     =  0,
    failErr = -1,
    fileErr = -1,
	memErr  = -2,
    formErr = -3,
    domainErr = -4,
    domErr  = -4,
    dimensionErr = -5,
    dimErr    = -5,
    invalidErr = -6,
    ioErr     = -7,
    nyiErr    = -999
};

    //
#define DIVIDERLINE  "================================================================"

#define MAXCOEFS 9

#define EVALBUFFER 1024


static inline char * trim(char *c) {
  char * e = c + strlen(c) - 1;
  while(*c && isspace(*c)) c++;
  while(e > c && isspace(*e)) *e-- = '\0';
  return c;
}


//
// TIFF Structures
//

typedef struct {
    unsigned short tCode;
    unsigned short dataType;
    unsigned int   nDataValues;
    unsigned int   pDataField;
} TagStructure;

// TIFF Colour table

typedef struct{
    unsigned short red[256];   // 0x0000 -> 0xFFFF, if input is 0-255 then byte double
    unsigned short green[256]; // 0x0000 -> 0xFFFF, ie 0xCA -> 0xCACA
    unsigned short blue[256];  // 0x0000 -> 0xFFFF
} TIFFCTab;


extern  TIFFCTab inTIFFCTab;
extern  TIFFCTab outTIFFCTab;

#endif
