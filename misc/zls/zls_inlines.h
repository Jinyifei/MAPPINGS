#ifndef ZLS_INLINES_H
#define ZLS_INLINES_H
#include "zls.h"

#define zls_min( x , y ) ((x)<(y)?(x):(y))
#define zls_max( x , y ) (!((x)<(y))?(x):(y))

#define zls_min3( x , y , z ) (zls_min(zls_min((x),(y)),(z)))
#define zls_max3( x , y , z ) (zls_max(zls_max((x),(y)),(z)))

#define zls_abs(x) ( (x) < 0.0 ? (-x) : (x) )

#define zls_minmod( x , y ) ( (((x)>0.0)&&((y)>0.0)) ? ((x)<(y)?(x):(y)) \
: ( (((x)<0.0)&&((y)<0.0)) ? ((x)<(y)?(y):(x)) \
:  0.0 )  )

#define zls_median( x , y, z ) (x) + zls_minmod(((y)-(x)), ((z)-(x)))

#define zls_sqr(x) ( (x)*(x) )
//static inline Real zls_sqr(Real x){return(x*x);}

#ifdef OS_MACOSXG4

static inline double zls_fabs ( double argument ) __attribute__((always_inline));
static inline double zls_fabs ( double argument )
{
  register double result;
  asm ( "fabs %0, %1" : /*OUT*/ "=f" ( result ) : /*IN*/ "f" ( argument ) );
  return result;
}
#define zls_sign(x,y) ((y)<0.0?-zls_fabs((x)):zls_fabs((x)))

#else

#define zls_fabs(x) ( zls_abs( (x) ) )
#define zls_sign(x,y) ((y)<0.0?-zls_abs((x)):zls_abs((x)))

#endif //

// zls_sign0 returns 0 if x < 0 or 1.0 if >= 0
#define zls_sign0(x) ((x)<0.0? 0.0:1.0)
// zls_sign1 returns -1.0 if x < 0 or 1.0 if >= 0
#define zls_sign1(x) ((x)<0.0?-1.0:1.0)

// zls_tol returns -1, 0 or +1 if a real is compared to a tolerance.
// abs(x)-tol < 0 clips to 0
//
// zls_tolx returns x, or 0 if a real is compared to a tolerance,
// clipping values close to 0
//
// zls_tol1 returns 1, or 0 (integer) if a real is compared to a
// tolerance, clipping values close to 0

#define zls_tol(x, e)  ((zls_abs((x))-(e))>0.0?zls_sign(1.0, (x)):0.0)
#define zls_tolx(x, e) ((zls_abs((x))-(e))>0.0?(x):0.0)
#define zls_tol1(x, e) ((zls_abs((x))-(e))>0.0?1:0)
#define zls_tole(x, e) ((zls_abs((x))-(e))>0.0?(x):(e))

#ifdef DOUBLE_PRECISION
//  extern  double zls_FastInvSqrt(double x);
static inline double zls_FastInvSqrt(double x)
{
  //
  // only works for IEEE 754 64 bit double precision
  // and long long = 64 two's complement ints, remove on
  // other systems.
  //
  union {
    double f;
    long long i;
  } tmp;
  tmp.f = x;
  tmp.i = 0x5FE6EB50C7AA19F9LL - (tmp.i >> 1LL);

  register double z, w;
  z = tmp.f; w = 0.5*x;
  z *= (1.5 - w * z * z);// uncomment for 10^-3 acc
  z *= (1.5 - w * z * z);// uncomment for 10^-6 acc
  //z *= (1.5 - w * z * z);// uncomment for 10^-12 acc
  // z *= (1.5 - w * z * z);// uncomment for 10^-16 acc
  return z;
}
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
//static inline float zls_FastInvSqrt(float x);
static inline float zls_FastInvSqrt(float x)
{
  //
  // only works for IEEE 754 32 bit precision
  // and int = 32 two's complement ints, remove on
  // other systems.
  //
  union {
    float f;
    int i;
  } tmp;
  tmp.f = x;
  tmp.i = 0x5f3759df - (tmp.i >> 1);

  register float z, w;
  z = tmp.f; w = 0.5*x;
  z *= (1.5 - w * z * z);// uncomment for 10^-3 acc
  z *= (1.5 - w * z * z);// uncomment for 10^-6 acc
  //z *= (1.5 - w * z * z);// uncomment for 10^-12 acc
  return z;
}
#endif // SINGLE_PRECISION

#ifdef OS_MACOSXG4
//static inline double __frsqrte ( double argument );
static inline double __frsqrte ( double argument )//
{
  double result;
  asm ( "frsqrte %0, %1" : /*OUT*/ "=f" ( result ) : /*IN*/ "f" ( argument ) );
  return result;
}

//static inline double zls_sqrt(double x) __attribute__((always_inline));
static inline double zls_sqrt(double x) {
  register double z, w;
  if ( x <= 0.0 ) return(0.0);
  z = __frsqrte ( x );
  w = 0.5*x;
  z = z*(1.5 - w*z*z);
  z = z*(1.5 - w*z*z); // uncomment for 10^-8 acc
  //  z = z*(1.5 - w*z*z); // uncomment for 10^-12 acc
  //  z = z*(1.5 - w*z*z); // uncomment for 10^-16 acc = system sqrt speed tho.
  return(z*x);
}

//static inline double zls_sqrtfaster(double x) __attribute__((always_inline));
static inline double zls_sqrtfaster(double x) {  // note - doesn't like 0.0!!

  register double z, w;
  //  if ( x <= 0.0 ) return(0.0);
  z = __frsqrte ( x );
  w = 0.5*x;
  z = z*(1.5 - w*z*z);
  return(z*x);
}
#endif //

#ifndef OS_MACOSXG4
//static inline double zls_sqrt(double x);
static inline double zls_sqrt(double x) {
#ifdef DOUBLE_PRECISION
  return(sqrt(x));
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return(sqrtf(x));
#endif // SINGLE_PRECISION
}
//static inline double zls_sqrtfaster(double x);
static inline double zls_sqrtfaster(double x) { // just the same as sqrt on generic systems
#ifdef DOUBLE_PRECISION
  return(sqrt(x));
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return(sqrtf(x));
#endif // SINGLE_PRECISION
}
#endif //


//extern Real zls_hypot(Real x, Real y);
static inline Real zls_hypot(Real x, Real y){
#ifdef DOUBLE_PRECISION
  //  return( zls_sqrt(x*x+y*y));
  return( hypot( x,  y ));
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return( hypotf( x,  y ));
#endif // SINGLE_PRECISION
}

//extern Real zls_hypot3(Real x, Real y, Real z);
static inline Real zls_hypot3(Real x, Real y, Real z){
#ifdef DOUBLE_PRECISION
  //  return( zls_sqrt(x*x+y*y+z*z));
  return( sqrt((x*x)+(y*y)+(z*z)));
  //  return( hypot( x,  hypot( y, z)) );
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return( hypotf( x,  hypotf( y, z)) );
#endif // SINGLE_PRECISION
}


//  extern  Real zls_Exp10(Real x);
static inline Real zls_Exp10(Real x){
#ifdef DOUBLE_PRECISION
  return( pow( 10.0, x) );
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return( powf( 10.0F, x) );
#endif // SINGLE_PRECISION
}

//  extern  Real zls_Log10(Real x);
static inline Real zls_Log10(Real x){
#ifdef DOUBLE_PRECISION
  return( log10( x) );
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return( log10f( x) );
#endif // SINGLE_PRECISION
}

//  extern  Real zls_Exp(Real x);
static inline Real zls_Exp(Real x){
#ifdef DOUBLE_PRECISION
  return( exp(x) );
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return( expf( x) );
#endif // SINGLE_PRECISION
}

//  extern  Real zls_Log(Real x);
static inline Real zls_Log(Real x){
#ifdef DOUBLE_PRECISION
  return( log( x) );
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return( logf( x) );
#endif // SINGLE_PRECISION
}


//  extern  Real zls_Pow(Real x, Real a);
static inline Real zls_Pow(Real x, Real a){
#ifdef DOUBLE_PRECISION
  return( pow( x , a) );
#endif // DOUBLE_PRECISION
#ifdef SINGLE_PRECISION
  return( powf( x , a) );
#endif // SINGLE_PRECISION
}

//========================================
//
// Some 16bit, 32bit and 64bit byte swap macros
//
// Macros for swapping constant values.  System dependent so may fail
// on some systems. Most likely to fail in the next three generic
// typedefs and macros - user may need to adjust them for a given
// system.  Works for GCC and OSX so far.  On old systems, without any
// long long support, an alternative double swap using a two element
// u32 array could be used.
//
typedef unsigned short u16;
typedef unsigned int   u32;
typedef unsigned long long   u64;

#define ZLS_BSWAP16(x) ((((u16)(x) & 0xff00) >> 8) | \
(((u16)(x) & 0x00ff) << 8))

#define ZLS_BSWAP32(x) ((((u32)(x) & 0xff000000) >> 24) | \
(((u32)(x) & 0x00ff0000) >>  8) | \
(((u32)(x) & 0x0000ff00) <<  8) | \
(((u32)(x) & 0x000000ff) << 24))

#define ZLS_BSWAP64(x) ((((u64)(x) & 0xff00000000000000ULL) >> 56) | \
(((u64)(x) & 0x00ff000000000000ULL) >> 40) | \
(((u64)(x) & 0x0000ff0000000000ULL) >> 24) | \
(((u64)(x) & 0x000000ff00000000ULL) >>  8) | \
(((u64)(x) & 0x00000000ff000000ULL) <<  8) | \
(((u64)(x) & 0x0000000000ff0000ULL) << 24) | \
(((u64)(x) & 0x000000000000ff00ULL) << 40) | \
(((u64)(x) & 0x00000000000000ffULL) << 56))

//
// Int routines use void * so they work on signed or unsigned equally
//

#ifdef OS_MACOSXG4
static inline void zls_Int16Swap ( void * i ) __attribute__((always_inline));
#endif // OS_MACOSXG4
#ifdef OS_MACOSXG5
static inline void zls_Int16Swap ( void * i ) __attribute__((always_inline));
#endif // OS_MACOSXG5
#ifdef OS_MACOSXCORE
static inline void zls_Int16Swap ( void * i ) __attribute__((always_inline));
#endif // OS_MACOSXCORE
#ifdef OS_GENERIC
static inline void zls_Int16Swap ( void * i );
#endif // OS_GENERIC
#ifdef OS_GENERICLINUX
static inline void zls_Int16Swap ( void * i );
#endif // OS_GENERICLINUX
#ifdef OS_CENTOS
static inline void zls_Int16Swap ( void * i );
#endif // OS_CENTOS
#ifdef OS_OS_SOLARISSPARC
static inline void zls_Int16Swap ( void * i );
#endif // OS_OS_SOLARISSPARC
#ifdef OS_OS_SOLARISAMD64
static inline void zls_Int16Swap ( void * i );
#endif // OS_OS_SOLARISAMD64

static inline void zls_Int16Swap ( void * i ) {
  u16 * u = (u16 *)i;
  *u = ZLS_BSWAP16(*u);
}

#ifdef OS_MACOSXG4
static inline void zls_Int32Swap ( void * i );//__attribute__((always_inline));
#endif // OS_MACOSXG4
#ifdef OS_MACOSXG5
static inline void zls_Int32Swap ( void * i );//__attribute__((always_inline));
#endif // OS_MACOSXG5
#ifdef OS_MACOSXCORE
static inline void zls_Int32Swap ( void * i );//__attribute__((always_inline));
#endif // OS_MACOSXCORE
#ifdef OS_GENERIC
static inline void zls_Int32Swap ( void * i );
#endif // OS_GENERIC
#ifdef OS_GENERICLINUX
static inline void zls_Int32Swap ( void * i );
#endif // OS_GENERICLINUX
#ifdef OS_CENTOS
static inline void zls_Int32Swap ( void * i );
#endif // OS_CENTOS
#ifdef OS_OS_SOLARISSPARC
static inline void zls_Int32Swap ( void * i );
#endif // OS_OS_SOLARISSPARC
#ifdef OS_OS_SOLARISAMD64
static inline void zls_Int32Swap ( void * i );
#endif // OS_OS_SOLARISAMD64

static inline void zls_Int32Swap( void *i ){
  u32 * u = (u32 *)i;
  u32 x = *u;
  *u = ZLS_BSWAP32(x);
}

#ifdef OS_MACOSXG4
static inline void zls_Int64Swap ( void * i );// __attribute__((always_inline));
#endif // OS_MACOSXG4
#ifdef OS_MACOSXG5
static inline void zls_Int64Swap ( void * i );// __attribute__((always_inline));
#endif // OS_MACOSXG5
#ifdef OS_MACOSXCORE
static inline void zls_Int64Swap ( void * i );// __attribute__((always_inline));
#endif // OS_MACOSXCORE
#ifdef OS_GENERIC
static inline void zls_Int64Swap ( void * i );
#endif // OS_GENERIC
#ifdef OS_GENERICLINUX
static inline void zls_Int64Swap ( void * i );
#endif // OS_GENERICLINUX
#ifdef OS_CENTOS
static inline void zls_Int64Swap ( void * i );
#endif // OS_CENTOS
#ifdef OS_OS_SOLARISSPARC
static inline void zls_Int64Swap ( void * i );
#endif // OS_OS_SOLARISSPARC
#ifdef OS_OS_SOLARISAMD64
static inline void zls_Int64Swap ( void * i );
#endif // OS_OS_SOLARISAMD64

static inline void zls_Int64Swap( void *i ){
  u64 * u = (u64 *)i;
  *u = ZLS_BSWAP64(*u);
}
// these simple float conversion routines work on pointers to float/double to
// make inplace conversions on array pointer arithmatic easier. see zls_restart.c
// for an example

typedef union ifl{
  u32 i32;
  float    f;
} zls_uif;


#ifdef OS_MACOSXG4
static inline float zls_FloatSwap ( float * f ) __attribute__((always_inline));
#endif // OS_MACOSXG4
#ifdef OS_MACOSXG5
static inline float zls_FloatSwap ( float * f ) __attribute__((always_inline));
#endif // OS_MACOSXG5
#ifdef OS_MACOSXCORE
static inline float zls_FloatSwap ( float * f ) __attribute__((always_inline));
#endif // OS_MACOSXCORE
#ifdef OS_GENERIC
static inline float zls_FloatSwap ( float * f );
#endif // OS_GENERIC
#ifdef OS_GENERICLINUX
static inline float zls_FloatSwap ( float * f );
#endif // OS_GENERICLINUX
#ifdef OS_CENTOS
static inline float zls_FloatSwap ( float * f );
#endif // OS_CENTOS
#ifdef OS_OS_SOLARISSPARC
static inline float zls_FloatSwap ( float * f );
#endif // OS_OS_SOLARISSPARC
#ifdef OS_OS_SOLARISAMD64
static inline float zls_FloatSwap ( float * f );
#endif // OS_OS_SOLARISAMD64

static inline float zls_FloatSwap ( float * f ) {
  zls_uif  u;
  u.f   = *f;
  u.i32 = ZLS_BSWAP32(u.i32);
  *f    = u.f;
  return(u.f);
}

typedef union idb{
  u64   i64;
  double   d;
} zls_uid;


#ifdef OS_MACOSXG4
static inline double zls_DoubleSwap( double *d ) __attribute__((always_inline));
#endif // OS_MACOSXG4
#ifdef OS_MACOSXG5
static inline double zls_DoubleSwap( double *d ) __attribute__((always_inline));
#endif // OS_MACOSXG5
#ifdef OS_MACOSXCORE
static inline double zls_DoubleSwap( double *d ) __attribute__((always_inline));
#endif // OS_MACOSXCORE
#ifdef OS_GENERIC
static inline double zls_DoubleSwap( double *d );
#endif // OS_GENERIC
#ifdef OS_GENERICLINUX
static inline double zls_DoubleSwap( double *d );
#endif // OS_GENERICLINUX
#ifdef OS_CENTOS
static inline double zls_DoubleSwap( double *d );
#endif // OS_CENTOS
#ifdef OS_OS_SOLARISSPARC
static inline double zls_DoubleSwap( double *d );
#endif // OS_OS_SOLARISSPARC
#ifdef OS_OS_SOLARISAMD64
static inline double zls_DoubleSwap( double *d );
#endif // OS_OS_SOLARISAMD64

static inline double zls_DoubleSwap( double *d ){
  zls_uid  u;
  u.d   = *d;
  u.i64 = ZLS_BSWAP64(u.i64);
  *d    = u.d;
  return(u.d);
}

//
// alternative double swap with 2 32 bit swaps for old systems, not heavily tested so beware
//
//typedef union idb{
//u32   i64[2];
//double   d;
//} zls_uid;
//
//static inline double zls_DoubleSwap( double d ) __attribute__((always_inline));
//static inline double zls_DoubleSwap( double d ){
//  zls_uid  u;
//  u32 temp;
//  u.d = d;
//  temp = ZLS_BSWAP32(u.i64[0]);
//  u.i64[0] = ZLS_BSWAP32(u.i64[1]);
//  u.i64[1] = temp;
//  return(u.d);
//}
//
// v lo level mass block byte swapping routines, blockSize in bytes

static inline int zls_ByteSwapFloatBlock ( void * q, Size blockSize );
static inline int zls_ByteSwapFloatBlock ( void * q, Size blockSize ){
  Counter count = 0;
  Counter nElements = blockSize/sizeof(float);
  float * p = (float *)q;
  while ( count++ < nElements){
    zls_FloatSwap(p++);
  }
  return(noErr);
}

static inline int zls_ByteSwapDoubleBlock ( void * q, Size blockSize );
static inline int zls_ByteSwapDoubleBlock ( void * q, Size blockSize ){
  Counter count = 0;
  Counter nElements = blockSize/sizeof(double);
  double * p = (double *)q;
  while ( count++ < nElements){
    zls_DoubleSwap(p++);
  }
  return(noErr);
}

static inline int zls_ByteSwapInt32Block ( void * q, Size blockSize );
static inline int zls_ByteSwapInt32Block ( void * q, Size blockSize ){
  Counter count = 0;
  Counter nElements = blockSize/sizeof(UInt32);
  UInt32 * p = (UInt32 *)q;
  while ( count++ < nElements){
    zls_Int32Swap(p++);
  }
  return(noErr);
}

static inline int zls_ByteSwapInt16Block ( void * q, Size blockSize );
static inline int zls_ByteSwapInt16Block ( void * q, Size blockSize ){
  Counter count = 0;
  Counter nElements = blockSize/sizeof(UInt16);
  UInt16 * p = (UInt16 *)q;
  while ( count++ < nElements){
    zls_Int16Swap(p++);
  }
  return(noErr);
}

// v lo level mass block byte swapping routines, nElements in number of numbers

static inline int zls_ByteSwapFloatElements ( void * q, Counter nElements );
static inline int zls_ByteSwapFloatElements ( void * q, Counter nElements ){
  Counter count = 0;
  float * p = (float *)q;
  while ( count++ < nElements){
    zls_FloatSwap(p++);
  }
  return(noErr);
}

static inline int zls_ByteSwapDoubleElements ( void * q, Counter nElements );
static inline int zls_ByteSwapDoubleElements ( void * q, Counter nElements ){
  Counter count = 0;
  double * p = (double *)q;
  while ( count++ < nElements){
    zls_DoubleSwap(p++);
  }
  return(noErr);
}

static inline int zls_ByteSwapInt32Elements ( void * q, Counter nElements );
static inline int zls_ByteSwapInt32Elements ( void * q, Counter nElements ){
  Counter count = 0;
  UInt32 * p = (UInt32 *)q;
  while ( count++ < nElements){
    zls_Int32Swap(p++);
  }
  return(noErr);
}

static inline int zls_ByteSwapInt16Elements ( void * q, Counter nElements );
static inline int zls_ByteSwapInt16Elements ( void * q, Counter nElements ){
  Counter count = 0;
  UInt16 * p = (UInt16 *)q;
  while ( count++ < nElements){
    zls_Int16Swap(p++);
  }
  return(noErr);
}


#endif // ZLS_INLINES_H
