#ifndef ZLS_SPLINES_H
#define ZLS_SPLINES_H

#include "zls_types.h"
#include "zls_qs.h"

enum {
    kFitSplineTypeLinear      = 0,
    kFitSplineTypeNatural     = 1,
    kFitSplineTypeFitGradient = 2,
    kFitSplineTypeFixGradient = 3,
    kFitSplineTypeZLSAkima    = 4
};

typedef struct {
        // owned and need alloc and freeing
    Q1DArr y2;

        // just references
    Q1DArr xa;
    Q1DArr ya;

    Integer nPoints;
    Integer kind;
    Real   dydx0;
    Real   dydxn;

        // binary search index cache
    Integer  cacheIdx;

} zls_SplineState,* zls_Spline;

typedef struct {
        // owned and need alloc and freeing
    Q1DArr b;
    Q1DArr c;
    Q1DArr d;
    Real * _dels;

        // just references
    Q1DArr xa;
    Q1DArr ya;
    Integer nPoints;

        // binary search index cache
    Integer  cacheIdx;

} zls_AkimaState, * zls_AkimaSpline;

    // lifetime

zls_AkimaSpline zls_AkimaAlloc  (Integer nPoints);

int  zls_AkimaInit          ( zls_AkimaSpline state,
                               Q1DArr xa, Q1DArr ya, Integer nPoints);

int  zls_AkimaInitPeriodic  ( zls_AkimaSpline state,
                               Q1DArr xa, Q1DArr ya, Integer nPoints);

void zls_AkimaFree          ( zls_AkimaSpline state);

Real zls_Akima              ( zls_AkimaSpline state, Real x );
int  zls_AkimaEvaluate      ( zls_AkimaSpline state, Real x, Real *y);

//
// cubic spline, x, y and y2 need to allocated first
//
int zls_EndpointGradients ( Q1DArr x, Q1DArr y, Integer n, Real *dydx0, Real *dydxn );

zls_Spline      zls_SplineAlloc (Integer nPoints);
int zls_SetSpline               ( zls_Spline state, Q1DArr x, Q1DArr y, Q1DArr y2, Integer n );
int zls_InitLinearSpline        ( zls_Spline state, Q1DArr x, Q1DArr y, Integer n );
int zls_InitNaturalSpline       ( zls_Spline state, Q1DArr x, Q1DArr y, Integer n );
int zls_InitFixedGradientSpline ( zls_Spline state, Q1DArr x, Q1DArr y, Integer n, Real dydx0, Real dydxn);
int zls_InitGradientSpline      ( zls_Spline state, Q1DArr x, Q1DArr y, Integer n );

void zls_SplineFree             ( zls_Spline state);

    // interpolate at x, to give y
Real zls_SplineYatX (zls_Spline state, Real x);
int zls_SplineEvaluate (zls_Spline state, Real x, Real *y);

#endif //ZLS_SPLINES_H