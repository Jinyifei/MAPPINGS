#ifndef ZLS_FFT_H
#define ZLS_FFT_H

#include "zls_types.h"
#include "zls_qs.h"

    // type of FFT
enum {
    kFFTTypeRealToPowerSpec    = 0,
    kFFTTypeComplexToPowerSpec = 1,
    kFFTTypeRealToComplex      = 2,
    kFFTTypeComplexToReal      = 3,
    kFFTTypeComplexToComplex   = 4
};

enum {

    kFFTDirReverseFlag    = 0x00,
    kFFTDirForwardFlag    = 0x01,
    kFFTDirMask           = 0x01,

    kFFTDirNoNormaliseFlag      = 0x00,
    kFFTDirNormaliseNFlag       = 0x02,
    kFFTDirNormaliseSQRTNFlag   = 0x04, // 1/sqrt(N)
    kFFTDirNormaliseMask        = 0x06,

    kFFTDirReverseNoNormal       = 0,
    kFFTDirForwardNoNormal       = 1,
    kFFTDirReverseNormalN        = 2,
    kFFTDirForwardNormalN        = 3,
    kFFTDirReverseNormalSQRTN    = 4,
    kFFTDirForwardNormalSQRTN    = 5,

};

int zls_expandComplex    ( CQ1DArr * cDst,  Real rValue, Real cValue, Counter n );
int zls_expandReal       ( CQ1DArr * cDst,  Q1DArr iSrc, Real rValue, Counter n );
int zls_expandImaginary  ( CQ1DArr * cDst,  Q1DArr rSrc, Real cValue, Counter n );

int zls_combineComplex   ( CQ1DArr * cDst,  Q1DArr rSrc, Q1DArr iSrc, Counter n );
int zls_cloneComplex     ( CQ1DArr * cDst, CQ1DArr cSrc, Counter n );

int zls_extractReal      (  Q1DArr * rDst, CQ1DArr rSrc, Counter n );
int zls_extractImaginary (  Q1DArr * iDst, CQ1DArr iSrc, Counter n );

int zls_splitComplex     (  Q1DArr * rDst,  Q1DArr * iDst, CQ1DArr iSrc, Counter n );

    // These allocate the result arrays, caller must dispose them when done

int zls_FFT1DRtoC        ( CQ1DArr *cDst, Q1DArr  rSrc, Counter n, Integer dir );
int zls_FFT1DCtoC        ( CQ1DArr *cDst, CQ1DArr cSrc, Counter n, Integer dir );
int zls_FFT1DCtoR        ( Q1DArr  *rDst, CQ1DArr cSrc, Counter n, Integer dir );

int zls_FFT1DRtoSpec     ( Q1DArr *rSpec, Q1DArr  rSrc, Counter n );
int zls_FFT1DCtoSpec     ( Q1DArr *rSpec, CQ1DArr cSrc, Counter n );

#endif //ZLS_FFT_H
