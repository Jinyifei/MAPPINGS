#ifndef LINES__H
#define LINES__H

#define VERSION "1.0.4 build 19"

enum _fitKind {
  kFreeContinuum    = 0,
  kFixedContinuum   = 1,
  kGaussianLines    = 0,
  kLorentzianLines  = 1
};

typedef struct _patch {

  Counter patchID;

  // continuum ranges
  Real leftStart;
  Real leftEnd;
  Real rightStart;
  Real rightEnd;
  Real maskStart;
  Real maskEnd;

  Integer fixedCentres;
  Integer fixedWidths;
  Integer continuumFitKind;
  Integer useMask;

  // one or more lines to fit
  Integer linesFitKind; // Gaussian (default) or Lorentzian
  Counter nLines;
  Q1DArr centers;
  Q1DArr  widths;

  Real continuumConstant;
  Real continuumLeft;
  Real continuumRight;

  Real continuumOrder;
  Real patchCentre;
  Real scaleY;
  Real invScaleY;

} patch, * patchArr;

typedef struct _lines {

  Integer nlines      ;
  Integer linesFitKind;

  Q1DArr lineCentre   ;
  Q1DArr lineHeight   ;
  Q1DArr lineWidth    ;

  Q1DArr  ai;
  Q1DArr sai;
  Q2DArr covar; // covariance matrix if used
  I1DArr fai;

  Integer l0,l1;
  Integer r0,r1;

  Integer useMask; // use a mask for lines
  Integer m0,m1; // mask bins if any -1 if unused

  Real centreX;
  Real   leftX;
  Real  rightX;
  Real  scaleY;
  Real invScaleY;

} lines, * linesArr;

typedef struct _continuum {

  Q1DArr  ai;
  Q1DArr sai;
  I1DArr fai;

  Integer l0,l1;   // bin numbers in source spectrum, unlike patch values which are reals
  Integer r0,r1;
  Integer m0,m1;   // mask bins if any -1 if unused
  Integer useMask; // use a mask for continuum

  Integer fixed;   // 0 free (default), >= 1 fixed values, ie no fit
  Real order;      // 0 const fit, 1 linear fit, 2 quadratic (default) TODO make enums
  Real cv,cv0,cv1; // centre, left and right continuum if specified
  Real centreX;
  Real   leftX;
  Real  rightX;
  Real  scaleY;
  Real invScaleY;

} continuum, * contArr;


#define EPSILON 1.0e-8

////////////////////////////////////////////////////////////////////////
//
// LifeCycles
//
////////////////////////////////////////////////////////////////////////


int NewPatchArr(patchArr * p, Counter nP);
int DisposePatchArr(patchArr p);

int NewLines(lines * l, Counter nL);
void DisposeLines(lines * l);

int NewContinuum (continuum * c );
void DisposeContinuum (continuum * c );

////////////////////////////////////////////////////////////////////////
//
// std out I/O
//
////////////////////////////////////////////////////////////////////////

void PrintHeader(char * fileName, char * linesFile, Integer showContCoeffs);

void PrintLineData(lines l, Counter gidx, Counter lineIndex,Counter pid, Counter lid,
                   Real lineContinuum, Real lineArea, Real releErrorArea,Real lineRMSResidue,
                   Integer showPatches, char * fitType);

void PrintLineAndContData(lines l, continuum cont, Counter gidx, Counter lineIndex,Counter pid, Counter lid,
                          Real lineContinuum, Real lineArea, Real releErrorArea,Real lineRMSResidue,
                          Integer showPatches, char * fitType);

void PrintLineFitDetail(Q1DArr specCoord, Q1DArr specFlux, Counter nSpec,
                        Q1DArr xq, Q1DArr yq, Counter nBins,
                        patchArr p, continuum cont,lines l, Counter pidx, Counter gidx,
                        Counter lineIndex, Counter centrePatches);

void PrintFullLineFitDetail(Q1DArr specCoord, Q1DArr specFlux, Counter nSpec,
                            Q1DArr xq, Q1DArr yq, Counter nBins,
                            patchArr p, continuum cont,lines l, Counter pidx, Counter gidx,
                            Counter lineIndex, Counter centrePatches);

void PrintFullPatchFitDetail(Q1DArr specCoord, Q1DArr specFlux, Counter nSpec,
                             Q1DArr xq, Q1DArr yq, Counter nBins,
                             patchArr p, continuum cont,lines l, Counter pidx,
                             Counter centrePatches);

void printSubtractedSpectrum (char * subFile, char * fileName, char * patchFile,
                              Q1DArr specCoord, Q1DArr specFlux, Q1DArr subFlux, Counter nSpec);

////////////////////////////////////////////////////////////////////////
//
// Fitting and Evaluation
//
////////////////////////////////////////////////////////////////////////

int FitContinuum     ( continuum * c, Q1DArr x, Q1DArr y );

int FitPatchLines    ( lines * l, Q1DArr xq,Q1DArr  yq,Counter nBins, Counter pidx, patch * p);

int FitNGaussianLines( Q1DArr ai, Q1DArr sai, I1DArr fai,
                      Q1DArr x, Q1DArr y, Integer nBins,
                      patch p, Q2DArr cv, Real * chi2);
int FitNLorentzianLines( Q1DArr ai, Q1DArr sai, I1DArr fai,
                      Q1DArr x, Q1DArr y, Integer nBins,
                      patch p, Q2DArr cv, Real * chi2);

static inline Real EvaluateContinuum(continuum * c, Real x){
  return fPolynomial (x, c->ai, 3);
}

static inline Real EvaluateGaussian(lines * l, Counter gidx, Real x){
  return fGaussian (x, &l->ai[gidx*3], 3);
}

static inline Real EvaluateLorentzian(lines * l, Counter gidx, Real x){
  return fGaussian (x, &l->ai[gidx*3], 3);
}

static inline Real EvaluateLine(lines * l, Counter gidx, Real x){
  if (l->linesFitKind==kGaussianLines){
    return fGaussian (x, &l->ai[gidx*3], 3);
  } else {
    return fLorentzian (x, &l->ai[gidx*3], 3);
  }
}

Real EvaluateGaussianArea  (lines * l, Counter gidx);

Real EvaluateLorentzianArea(lines * l, Counter gidx);

Real EvaluateLineArea      (lines * l, Counter gidx);

////////////////////////////////////////////////////////////////////////
//
// File I/O
//
////////////////////////////////////////////////////////////////////////


Counter ReadPatchFile(patchArr * patches, char * fileName );

Counter ReadFluxFile(Q1DArr * wave, Q1DArr * flux, Integer nHeader, char * fileName );

////////////////////////////////////////////////////////////////////////
//
// command interface
//
////////////////////////////////////////////////////////////////////////

Counter argRangeOptions( char * opt, int *i, int *j);

void Usage(void);
void InvalidLineList(void);
void NoSpectrum(Integer n);


#endif
