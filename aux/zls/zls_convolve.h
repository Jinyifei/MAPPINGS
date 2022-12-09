#ifndef ZLS_CONVOLVE_H
#define ZLS_CONVOLVE_H

#include "zls_types.h"
#include "zls_qs.h"

// type of convolution
enum {
    kConvolveTypeBox       = 0,
    kConvolveTypeTri       = 1,
    kConvolveTypeGaussian  = 2,
    kConvolveTypeRotate    = 3
};

enum {
    kConvolveNoNormaliseFlag    = 0x00,
    kConvolveNormaliseFlag      = 0x02,
    kConvolveNormaliseMask      = 0x02
};

    // These are width convolutions, in whichever x space called with. Widths need to
    // be computed in log or linear space as appropriate, usually by a driver routine
    // rather than calling directly., 
    // W routines convolve in place

int zls_WRotationalConvolution  ( Q1DArr lwv, Q1DArr fl, Counter n, Real sigma);
int zls_WGaussianConvolution    ( Q1DArr lwv, Q1DArr fl, Counter n, Real sigma);
int zls_WBoxcarConvolution      ( Q1DArr lwv, Q1DArr fl, Counter n, Real sigma);
int zls_WDirectConvolution      ( Q1DArr f, Q1DArr resp, Counter n, Counter nResp);

// Graf version driver routines, non W return result in new cnv array

int zls_RotConvolution         ( Q1DArr * cnv, Q1DArr y, Counter n, Real nbins );
int zls_RotXConvolution        ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth );
int zls_RotLogXConvolution     ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth );

int zls_GaussianConvolution    ( Q1DArr * cnv, Q1DArr y, Counter n, Real nbins );
int zls_GaussianXConvolution   ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth );
int zls_GaussianLogXConvolution( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth );

int zls_BoxcarConvolution      ( Q1DArr * cnv, Q1DArr y, Counter n, Real nbins );
int zls_BoxcarXConvolution     ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth );
int zls_BoxcarLogXConvolution  ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth );

int zls_TricarConvolution      ( Q1DArr * cnv, Q1DArr y, Counter n, Real nbins );
int zls_TricarXConvolution     ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth );
int zls_TricarLogXConvolution  ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth );

    // Actual convolution once normalised response array is constructed  result in new cnv array

int zls_DirectConvolution      ( Q1DArr * cnv, Q1DArr f, Q1DArr resp, Counter n, Counter nResp );

#endif
