#ifndef ZLS_FITPOLY_H
#define ZLS_FITPOLY_H
#include "zls_types.h"
#include "zls_qs.h"

//========================================================================
// linear polynomial fit by matrix inversion
// can fit with free and fixed coefficients, 
// can fit normal polys, Chebychev, Legendre and Harmonic series as well.
//========================================================================

#define IncorrectParameters -1
#define UndefinedMode       -2
#define AllocationError     -3
#define SingularMatrix    -128

// type of fitting
enum {
    kFitTypeLinear    = 0,
    kFitTypeSVDLinear = 1,
    kFitTypeNonLinear = 2
};

// kind of fit:

enum _zlsFitType {
  kFitFNPower       = 0, // normal power series
  kFitFNLegendre    = 1, // Legendre polynomials
  kFitFNCheby       = 2, // Chebychev polys
  kFitFNHarmonic    = 3, // Harmonic Series
  kFitFNHarmonicLog = 4, // Harmonic Series + Log
  kFitFNGaussians   = 5, // multi gaussian
  kFitFGaussianPoly = 6, // single gaussian + polynomial
  kFitFNLorentzians = 7, // multi lorentzians
  kFitFLorentzPoly    = 8, // single lorentzian + polynomial
  kFitFLorentzNGauss  = 9, // single lorentzian + n x gaussian
  kFitFGaussNLorentz  = 10, // single gaussian + n x lorentzian
  kFitFGaussLorentzPoly = 11, // single gaussian + single lorentzian + polynomial centred on gaussian
  kFitFLorentzGaussPoly = 12 // single lorentzians + single gaussian + polynomial centred on lorentzian
};

// coefficient types
enum {
    kFitFreeCoeff     = 0,
    kFitFixedCoeff    = 1
};

// treatment of error in fittings
enum {
    kFitNoErrorWeighting = 0, // esp if none are available, sigi2 = 1, scale covars with [chi2/(n-2)]^-1
    kFitSqrtWeighting = 1, // if measurements have sqrt(y) impicit poisson noise
    kFitYErrWeighting = 2  // if errors are know explicitly in yerr array
};

void FitPolynomial      (Real x, Real * ai, Integer  m);
Real fPolynomial  (Real x, Real * ai, Integer  m);
void FitLegendre  (Real x, Real * ai, Integer  m);
void FitCheby     (Real x, Real * ai, Integer  m);
void FitHarmonic  (Real x, Real * ai, Integer  m);
void FitHarmonicPlusLog (Real x, Real * ai, Integer  m);

// function and coefficient derivatives for M-L fitting

void FitNLorentz  (Real x, Real * ai, Real *y, Real dyda[], Integer na);
void FitNGauss    (Real x, Real * ai, Real *y, Real dyda[], Integer na);
void FitGaussPoly (Real x, Real * ai, Real *y, Real dyda[], Integer na);

Real fGaussian    (Real x, Real * ai, Integer m);
Real fLorentzian  (Real x, Real * ai, Integer m);

int LinearFitPoly (Q1DArr  xq, Q1DArr yq, Integer n, Q1DArr yerr, Integer errormode, 
                   I1DArr fai, Q1DArr ai, Q1DArr sai, Integer nterms, 
                   Integer fit, Real * chi2, Q2DArr covar);// chi2 == NULL and/or covar == NULL to ignore

// singular value poly fit with all terms -  TODO: mod for selectable terms and errs
int SVDFitPoly (Q1DArr xq, Q1DArr yq, Integer n, 
                Q1DArr ai, Integer nterms, 
                Integer fit, Real * chi2, Q2DArr covar);// chi2 == NULL and/or covar == NULL to ignore


// chi2 == NULL and/or covar == NULL to ignore
int LMFit ( Q1DArr   xq, Q1DArr  yq, Integer n,
           Q1DArr yerr, Integer errormode,
           I1DArr  fai, Q1DArr  ai, Q1DArr sai, Integer nterms,
           Integer fitType, Real * chi2, Q2DArr covar);

// non-linear M-L fit with selectable terms
int MRQGaussFit  ( Q1DArr   xq, Q1DArr  yq, Integer n, Q1DArr yerr, Integer errormode,  
              I1DArr  fai, Q1DArr  ai, Q1DArr sai, Integer nterms, 
                  Integer fit, Real * chi2, Q2DArr covar);// chi2 == NULL and/or covar == NULL to ignore



#endif
