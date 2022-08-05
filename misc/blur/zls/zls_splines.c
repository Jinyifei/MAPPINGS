#include "zls_splines.h"

Counter zls_BSearch(Q1DArr xa, Real x,
                       Integer index_lo, Integer index_hi);

Counter zls_BSearch( Q1DArr xa, Real x,
                       Integer ilo, Integer ihi)
{
    while (ihi-ilo > 1) {
        Integer i = (ihi+ilo) >> 1;
        if (xa[i] > x) ihi=i;
        else ilo=i;
    }
    return ilo;
}

Integer zls_splineCacheSearch  ( zls_Spline state, Real x);
Integer zls_splineCacheSearch  ( zls_Spline state, Real x)
{
    Counter idx = state->cacheIdx;
    Real *xa = state->xa;
    if(x < xa[idx]) {
        idx = zls_BSearch(xa, x, 0, idx);
    } else if(x >= xa[idx + 1]) {
        idx = zls_BSearch(xa, x, idx, state->nPoints-1);
    }
    state->cacheIdx = idx;
    return idx;
}

Integer zls_cacheSearch  ( zls_AkimaSpline state, Real x);
Integer zls_cacheSearch  ( zls_AkimaSpline state, Real x)
{
    Counter idx = state->cacheIdx;
    Real *xa = state->xa;
    if(x < xa[idx]) {
        idx = zls_BSearch(xa, x, 0, idx);
    } else if(x >= xa[idx + 1]) {
        idx = zls_BSearch(xa, x, idx, state->nPoints-1);
    }
    state->cacheIdx = idx;
    return idx;
}

zls_AkimaSpline zls_AkimaAlloc (Integer nPoints)
{
    zls_AkimaSpline state = (zls_AkimaSpline ) malloc (sizeof (zls_AkimaState));

    if (state == NULL) return NULL;

    state->nPoints  = nPoints;
    state->cacheIdx = 0;
    zls_NewQuantity1DArr(&state->b,nPoints);

    if (state->b == NULL)
      {
        free (state);
        return NULL;
      }

    zls_NewQuantity1DArr(&state->c,nPoints);

    if (state->c == NULL)
      {
        zls_DisposeQuantity1DArr(state->b);
        free (state);
        return NULL;
      }

    zls_NewQuantity1DArr(&state->d,nPoints);

    if (state->d == NULL)
      {
        zls_DisposeQuantity1DArr(state->c);
        zls_DisposeQuantity1DArr(state->b);
        free (state);
        return NULL;
      }

    state->_dels = (Real *) malloc ((nPoints + 4) * sizeof (Real));

    if (state->_dels == NULL)
      {
        zls_DisposeQuantity1DArr(state->d);
        zls_DisposeQuantity1DArr(state->c);
        zls_DisposeQuantity1DArr(state->b);
        free (state);
        return NULL;
      }

    return state;
}

void zls_AkimaCalculate ( zls_AkimaSpline state, Q1DArr m);
void zls_AkimaCalculate ( zls_AkimaSpline state, Q1DArr m)
{
    Integer i;
    Q1DArr xa = state->xa;
    Integer nPoints = state->nPoints;

    for (i = 0; i < (nPoints - 1); i++)
      {
        Real Del = fabs (m[i + 1] - m[i]) + fabs (m[i - 1] - m[i - 2]);
        if (Del <= 1.0e-12){
            state->b[i] = m[i];
            state->c[i] = 0.0;
            state->d[i] = 0.0;
          } else {
            Real h_i = xa[i + 1] - xa[i];
            Real Del_next = fabs (m[i + 2] - m[i + 1]) + fabs (m[i] - m[i - 1]);
            Real alpha_i  = fabs (m[i - 1] - m[i - 2]) / Del;
            Real alpha_ip1;
            Real Del_ip1;
            if (Del_next == 0.0) {
                Del_ip1 = m[i];
              } else {
                alpha_ip1 = fabs (m[i] - m[i - 1]) / Del_next;
                Del_ip1 = (1.0 - alpha_ip1) * m[i] + alpha_ip1 * m[i + 1];
              }
            state->b[i] = (1.0 - alpha_i) * m[i - 1] + alpha_i * m[i];
            state->c[i] = (3.0 * m[i] - 2.0 * state->b[i] - Del_ip1) / h_i;
            state->d[i] = (state->b[i] + Del_ip1 - 2.0 * m[i]) / (h_i * h_i);
          }

      }
    state->b[nPoints - 1] = m[nPoints - 1];
    state->c[nPoints - 1] = 0.0;
    state->d[nPoints - 1] = 0.0;

}


int zls_AkimaInit (zls_AkimaSpline state,  Real xa[],  Real ya[], Integer nPoints)
{
        // keep refs
    state->xa = xa;
    state->ya = ya;
    state->nPoints  = nPoints;
    state->cacheIdx = 0;

        // compute coeffs, prepare m array offset by 2
    Real * m = state->_dels + 2;

    Integer i;
    for (i = 0; i < nPoints - 1; i++) {
        m[i] = (ya[i + 1] - ya[i]) / (xa[i + 1] - xa[i]);
    }

    m[-2] = 3.0 * m[0] - 2.0 * m[1];
    m[-1] = 2.0 * m[0] - m[1];
    m[nPoints - 1] = 2.0 * m[nPoints - 2] - m[nPoints - 3];
    m[nPoints] = 3.0 * m[nPoints - 2] - 2.0 * m[nPoints - 3];

    zls_AkimaCalculate (state, m);

    return NoErr;
}

int zls_AkimaInitPeriodic (zls_AkimaSpline state,
                           Q1DArr xa,
                           Q1DArr ya,
                           Integer nPoints)
{
        // keep refs
    state->xa = xa;
    state->ya = ya;
    state->nPoints = nPoints;
    state->cacheIdx = 0;

    Real * m = state->_dels + 2; /* offset so we can address the -1,-2 components */

    Integer i;
    for (i = 0; i < nPoints - 1; i++) {
        m[i] = (ya[i + 1] - ya[i]) / (xa[i + 1] - xa[i]);
    }

    /* periodic boundary conditions */
    m[-2] = m[nPoints - 1 - 2];
    m[-1] = m[nPoints - 1 - 1];
    m[nPoints - 1] = m[0];
    m[nPoints] = m[1];

    zls_AkimaCalculate (state, m);

    return NoErr;
}

void zls_AkimaFree (zls_AkimaSpline state)
{
    if ( state == NULL) return;
    zls_DisposeQuantity1DArr(state->b);
    zls_DisposeQuantity1DArr(state->c);
    zls_DisposeQuantity1DArr(state->d);
    free (state->_dels);
    free (state);
}

Real zls_Akima (zls_AkimaSpline state,
                Real x )
{
    Real y = 0.0;

    Integer idx = zls_cacheSearch(state, x);

    Integer khi = idx+1;
    Integer klo = idx;

    Real xlo = state->xa[klo];
    Real xhi = state->xa[khi];
    Real  dx = xhi-xlo;

    Real ylo = state->ya[klo];
    Real yhi = state->ya[khi];
    Real  dy = yhi-ylo;

    Real y2lo = 2.0*state->c[klo];
    Real y2hi = 2.0*state->c[klo] + 6.0 *state->d[klo]*dx;

    Real f  = (xhi-x)/dx;
    Real cf = (x-xlo)/dx;

    if ( f < 0.0){ // linear extrapolate high
        Real dydx=(dy/dx)+(1.0/6.0)*dx*y2lo+(2.0/6.0)*dx*y2hi;//A=0,B=1
        y =yhi+dydx*(x-xhi);
    } else if ( cf < 0.0){ // linear extrapolate low
        Real dydx=(dy/dx)-(2.0/6.0)*dx*y2lo-(1.0/6.0)*dx*y2hi;//A=1,B=0
        y =ylo-dydx*(xlo-x);
    } else if ((y2lo == 0.0)&&(y2hi == 0.0)){ // linear interpolate
        y = f*ylo+cf*yhi;
    } else { // cubic interpolate else
        y = f*ylo+cf*yhi
        +((f*f*f-f)*y2lo+(cf*cf*cf-cf)*y2hi)*(dx*dx)/6.0;
    }
    return y;
}

int zls_AkimaEvaluate (zls_AkimaSpline state,
                       Real x, Real *y)
{
    *y = 0.0;

    Integer idx = zls_cacheSearch(state, x);

    Integer khi = idx+1;
    Integer klo = idx;

    Real xlo = state->xa[klo];
    Real xhi = state->xa[khi];
    Real  dx = xhi-xlo;

    Real ylo = state->ya[klo];
    Real yhi = state->ya[khi];
    Real  dy = yhi-ylo;

    Real y2lo = 2.0*state->c[klo];
    Real y2hi = 2.0*state->c[klo] + 6.0 *state->d[klo]*dx;

    Real f = (xhi-x)/dx;
    Real cf = (x-xlo)/dx;

    if ( f < 0.0){ // linear extrapolate high
        Real dydx=(dy/dx)+(1.0/6.0)*dx*y2lo+(2.0/6.0)*dx*y2hi;//A=0,B=1
        *y =yhi+dydx*(x-xhi);
    } else if ( cf < 0.0){ // linear extrapolate
        Real dydx=(dy/dx)-(2.0/6.0)*dx*y2lo-(1.0/6.0)*dx*y2hi;//A=1,B=0
        *y =ylo-dydx*(xlo-x);
    } else if ((y2lo == 0.0)&&(y2hi == 0.0)){ // linear interpolate
        *y = f*ylo+cf*yhi;
    } else { // cubic interpolate else
        *y = f*ylo+cf*yhi
        +((f*f*f-f)*y2lo+(cf*cf*cf-cf)*y2hi)*(dx*dx)/6.0;
    }
    return NoErr;
}

zls_Spline zls_SplineAlloc (Integer nPoints)
{
    zls_Spline state = (zls_Spline ) malloc (sizeof (zls_SplineState));

    if (state == NULL) return NULL;

    state->nPoints  = nPoints;
    state->cacheIdx = 0;
    state->kind     = kFitSplineTypeLinear;
    state->dydx0    = 0.0;
    state->dydxn    = 0.0;

    zls_NewQuantity1D(&state->y2,nPoints);

    if (state->y2 == NULL)
      {
        free (state);
        return NULL;
      }

    return state;
}
    //
    // NR cubic splines, returns second derivatives for use in interpolations
    // Allocate x, y and y2 before calling
    //
int zls_InitLinearSpline(zls_Spline state, Q1DArr x, Q1DArr y, Integer n)
{
        // y2 == 0, trivial piecewise linear interpolation, y2 = 0 will work
        // when passed to cubic spline interpolator.

    int err = 0;
    Integer i;

    state->nPoints = n;
    state->kind = kFitSplineTypeLinear;
    
    state->xa = x;
    state->ya = y;

    for (i=0;i<(n-1);i++) {
        state->y2[i]=0.0;
    }
    state->dydx0 = 0.0;
    state->dydxn = 0.0;

    state->cacheIdx = 0;

    return err;
}

int zls_InitNaturalSpline(zls_Spline state, Q1DArr x, Q1DArr y, Integer n)
{
    int err = 0;
    Integer i,k;
    Real p,qn,sig,un;

    state->nPoints = n;
    state->kind = kFitSplineTypeNatural;

    state->xa = x;
    state->ya = y;

    Q1DArr u;
    zls_NewQuantity1DArr(&u, n);

    state->y2[0]=u[0]=0.0;

    for (i=1;i<(n-1);i++) {
        sig=(x[i]-x[i-1])/(x[i+1]-x[i-1]);
        p=1.0/(sig*state->y2[i-1]+2.0);
        state->y2[i]=(sig-1.0)*p;
        u[i]=(y[i+1]-y[i])/(x[i+1]-x[i])-(y[i]-y[i-1])/(x[i]-x[i-1]);
        u[i]=(6.0*u[i]/(x[i+1]-x[i-1])-sig*u[i-1])*p;
    }

    qn=un=0.0;

    state->y2[n-1]=(un-qn*u[n-2])/(qn*state->y2[n-2]+1.0);
    for (k=n-2;k>=0;k--)
        state->y2[k]=state->y2[k]*state->y2[k+1]+u[k];

    zls_DisposeQuantity1DArr(u);

    state->dydx0 = 0.0;
    state->dydxn = 0.0;
    state->cacheIdx = 0;

    return err;
}

int zls_SetSpline(zls_Spline state, Q1DArr x, Q1DArr y, Q1DArr y2, Integer n) {

    int err = NoErr;

    state->nPoints = n;
    state->kind = kFitSplineTypeNatural;

    state->xa = x;
    state->ya = y;
    if ( state->y2 != NULL )
        zls_DisposeQuantity1DArr(state->y2);
    state->y2 = y2;
    
    state->dydx0 = 0.0;
    state->dydxn = 0.0;
    state->cacheIdx = 0;

    return err;
}


int zls_EndpointGradients ( Q1DArr x, Q1DArr y, Integer n, Real *dydx0, Real *dydxn )
{
    int err = 0;

    *dydx0 = 0.0;
    *dydxn = 0.0;

    if ( n > 1 ){
        *dydx0 = (y[1]-y[0])/(x[1]-x[0]);
        *dydxn = (y[n-1]-y[n-2])/(x[n-1]-x[n-2]);
    } else {
        err = -1;
    }
    return err;
}

int zls_InitFixedGradientSpline(zls_Spline state, Q1DArr x, Q1DArr y, Integer n, Real dydx0, Real dydxn)
{
    int err = 0;
    Integer i,k;
    Real p,qn,sig,un;

    state->nPoints = n;
    state->kind = kFitSplineTypeFixGradient;

    state->xa = x;
    state->ya = y;

    Q1DArr u;
    zls_NewQuantity1DArr(&u, n);

    if (dydx0 > 0.99e300)
        state->y2[0]=u[0]=0.0;
    else {
        state->y2[0] = -0.5;
        u[0]=(3.0/(x[1]-x[0]))*((y[1]-y[0])/(x[1]-x[0])-dydx0);
    }
    for (i=1;i<(n-1);i++) {
        sig=(x[i]-x[i-1])/(x[i+1]-x[i-1]);
        p=1.0/(sig*state->y2[i-1]+2.0);
        state->y2[i]=(sig-1.0)*p;
        u[i]=(y[i+1]-y[i])/(x[i+1]-x[i]) - (y[i]-y[i-1])/(x[i]-x[i-1]);
        u[i]=(6.0*u[i]/(x[i+1]-x[i-1])-sig*u[i-1])*p;
    }
    if (dydxn > 0.99e300)
        qn=un=0.0;
    else {
        qn=0.5;
        un=(3.0/(x[n-1]-x[n-2]))*(dydxn-(y[n-1]-y[n-2])/(x[n-1]-x[n-2]));
    }
    state->y2[n-1]=(un-qn*u[n-2])/(qn*state->y2[n-2]+1.0);
    for (k=n-2;k>=0;k--)
        state->y2[k]=state->y2[k]*state->y2[k+1]+u[k];

    zls_DisposeQuantity1DArr(u);

    state->cacheIdx = 0;
    
    return err;
}


int zls_InitGradientSpline(zls_Spline state, Q1DArr x, Q1DArr y, Integer n)
{
    int err = 0;
    Integer i,k;
    Real p,qn,sig,un;

    state->nPoints = n;
    state->kind = kFitSplineTypeFitGradient;
    state->xa = x;
    state->ya = y;

    Real dydx0;
    Real dydxn;
    if ( zls_EndpointGradients (x, y,  n, &dydx0, &dydxn ) == NoErr){

        Q1DArr u;
        zls_NewQuantity1DArr(&u, n);

        if (dydx0 > 0.99e300)
            state->y2[0]=u[0]=0.0;
        else {
            state->y2[0] = -0.5;
            u[0]=(3.0/(x[1]-x[0]))*((y[1]-y[0])/(x[1]-x[0])-dydx0);
        }
        for (i=1;i<(n-1);i++) {
            sig=(x[i]-x[i-1])/(x[i+1]-x[i-1]);
            p=1.0/(sig*state->y2[i-1]+2.0);
            state->y2[i]=(sig-1.0)*p;
            u[i]=(y[i+1]-y[i])/(x[i+1]-x[i]) - (y[i]-y[i-1])/(x[i]-x[i-1]);
            u[i]=(6.0*u[i]/(x[i+1]-x[i-1])-sig*u[i-1])*p;
        }
        if (dydxn > 0.99e300)
            qn=un=0.0;
        else {
            qn=0.5;
            un=(3.0/(x[n-1]-x[n-2]))*(dydxn-(y[n-1]-y[n-2])/(x[n-1]-x[n-2]));
        }
        state->y2[n-1]=(un-qn*u[n-2])/(qn*state->y2[n-2]+1.0);
        for (k=n-2;k>=0;k--)
            state->y2[k]=state->y2[k]*state->y2[k+1]+u[k];
        
        zls_DisposeQuantity1DArr(u);

    }

    state->cacheIdx = 0;
    
    return err;
}

Real zls_SplineYatX (zls_Spline state, Real x){

    Real y = 0.0;

    Q1DArr xa = state->xa;
    Q1DArr ya = state->ya;
    Q1DArr y2 = state->y2;

    Integer klo = zls_splineCacheSearch( state, x);
    Integer khi = klo+1;

    Real dy=ya[khi]-ya[klo];
    Real dx=xa[khi]-xa[klo];

    Real a=(xa[khi]-x)/dx;
    Real b=(x-state->xa[klo])/dx;

    if (dx == 0.0) {
        y = 0.0;
        return y;
    }

    if ( a < 0.0){ // linear extrapolate high
                   // set A=0 and get 1st deriv
        Real dydx=(dy/dx)+(1.0/6.0)*dx*y2[klo]+(2.0/6.0)*dx*y2[khi];//A=0,B=1
        Real ylin=ya[khi]+dydx*(x-xa[khi]);
        y = ylin; //a*ya[klo]+b*ya[khi];
    } else if ( b < 0.0){ // linear extrapolate
        Real dydx=(dy/dx)-(2.0/6.0)*dx*y2[klo]-(1.0/6.0)*dx*y2[khi];//A=1,B=0
        Real ylin=ya[klo]-dydx*(xa[klo]-x);
        y = ylin; //a*ya[klo]+b*ya[khi];
    } else if ((y2[klo] == 0.0)&&(y2[khi] == 0.0)){ // linear interpolate
        y = a*ya[klo]+b*ya[khi];
    } else { // cubic interpolate else
        y = a*ya[klo]+b*ya[khi]
        +((a*a*a-a)*y2[klo]+(b*b*b-b)*y2[khi])
        *(dx*dx)*0.166666666666666666666;
    }

    return y;

}

    // return y for given x
int zls_SplineEvaluate(zls_Spline state, Real x, Real *y)
{
    int err = NoErr;
    
    Q1DArr xa = state->xa;
    Q1DArr ya = state->ya;
    Q1DArr y2 = state->y2;

    Integer klo = zls_splineCacheSearch( state, x);
    Integer khi = klo+1;

    Real dy=ya[khi]-ya[klo];
    Real dx=xa[khi]-xa[klo];

    Real a=(xa[khi]-x)/dx;
    Real b=(x-state->xa[klo])/dx;

    if (dx == 0.0) {
        *y = 0.0;
        return -1;
    }

    if ( a < 0.0){ // linear extrapolate high
                   // set A=0 and get 1st deriv
        Real dydx=(dy/dx)+(1.0/6.0)*dx*y2[klo]+(2.0/6.0)*dx*y2[khi];//A=0,B=1
        Real ylin=ya[khi]+dydx*(x-xa[khi]);
        *y = ylin; //a*ya[klo]+b*ya[khi];
    } else if ( b < 0.0){ // linear extrapolate
        Real dydx=(dy/dx)-(2.0/6.0)*dx*y2[klo]-(1.0/6.0)*dx*y2[khi];//A=1,B=0
        Real ylin=ya[klo]-dydx*(xa[klo]-x);
        *y = ylin; //a*ya[klo]+b*ya[khi];
    } else if ((y2[klo] == 0.0)&&(y2[khi] == 0.0)){ // linear interpolate
        *y = a*ya[klo]+b*ya[khi];
    } else { // cubic interpolate else
        *y = a*ya[klo]+b*ya[khi]
        +((a*a*a-a)*y2[klo]+(b*b*b-b)*y2[khi])
        *(dx*dx)*0.166666666666666666666;
    }

    return err;
}

void zls_SplineFree  ( zls_Spline state)
{
    if ( state == NULL) return;
    zls_DisposeQuantity1DArr(state->y2);
    free (state);
}
