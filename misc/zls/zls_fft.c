#include "zls_fft.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846264
#endif

#ifndef ZLS_ZLS_SIN60
#define ZLS_SIN60 0.866025403784438646763723  /* sin(60 deg) */
#define ZLS_COS72 0.309016994374947424102293  /* cos(72 deg) */
#define ZLS_SIN72 0.951056516295153572116439  /* sin(72 deg) */
#endif

static MemSize  _bytesAllocated = 0;
static Counter _integersAllocated = 0;

/* temp space for scratch arrays */
static void * _zls_FFTTmp0 = NULL;
static void * _zls_FFTTmp1 = NULL;
static void * _zls_FFTTmp2 = NULL;
static void * _zls_FFTTmp3 = NULL;
static Integer * _zls_FFTPermArr = NULL;

#define ZLS_FFT_NFACTOR 32L
static Integer fftFactors [ZLS_FFT_NFACTOR]; // up to a minimum of 2^32 points

/* return the number of factors and square factors*/
Integer zls_FFTfactorize (Integer nPass, Integer * nSqrs);
Integer zls_FFTfactorize (Integer nPass, Integer * nSqrs) {

    Integer nFactor = 0;
    Integer j, jj;

    *nSqrs = 0;
    /* determine the factors of n */
    while ((nPass % 16) == 0)   /* factors of 4 */
      {
        fftFactors [nFactor++] = 4;
        nPass /= 16;
      }
    j = 3; jj = 9;      /* factors of 3, 5, 7, ... */
    do {
        while ((nPass % jj) == 0)
          {
            fftFactors [nFactor++] = j;
            nPass /= jj;
          }
        j += 2;
        jj = j * j;
    } while (jj <= nPass);
    if (nPass <= 4)
      {
        *nSqrs = nFactor;
        fftFactors [nFactor] = nPass;
        if (nPass != 1)
            nFactor++;
      }
    else
      {
        if (nPass - (nPass / 4 << 2) == 0)
          {
            fftFactors [nFactor++] = 2;
            nPass /= 4;
          }
        *nSqrs = nFactor;
        j = 2;
        do {
            if ((nPass % j) == 0)
              {
                fftFactors [nFactor++] = j;
                nPass /= j;
              }
            j = ((j + 1) / 2 << 1) + 1;
        } while (j <= nPass);
      }
    if (*nSqrs)
      {
        j = *nSqrs;
        do
            fftFactors [nFactor++] = fftFactors [--j];
        while (j);
      }

    return nFactor;
}

void zls_FFTFree (void);
void zls_FFTFree (void)
{
    _bytesAllocated = _integersAllocated = 0;
    if (_zls_FFTTmp0) { free (_zls_FFTTmp0); _zls_FFTTmp0 = NULL; }
    if (_zls_FFTTmp1) { free (_zls_FFTTmp1); _zls_FFTTmp1 = NULL; }
    if (_zls_FFTTmp2) { free (_zls_FFTTmp2); _zls_FFTTmp2 = NULL; }
    if (_zls_FFTTmp3) { free (_zls_FFTTmp3); _zls_FFTTmp3 = NULL; }
    if (_zls_FFTPermArr) { free (_zls_FFTPermArr); _zls_FFTPermArr = NULL; }
}


int zls_FFTAllocateStorage (Integer maxFactors, Integer maxPerm);
int zls_FFTAllocateStorage (Integer maxFactors, Integer maxPerm){
    int err = NoErr;

    if (_bytesAllocated < maxFactors * sizeof (Real)) {
        _bytesAllocated = maxFactors * sizeof (Real);
        _zls_FFTTmp0 = realloc (_zls_FFTTmp0, _bytesAllocated);
        _zls_FFTTmp1 = realloc (_zls_FFTTmp1, _bytesAllocated);
        _zls_FFTTmp2 = realloc (_zls_FFTTmp2, _bytesAllocated);
        _zls_FFTTmp3 = realloc (_zls_FFTTmp3, _bytesAllocated);
    }

    if (_integersAllocated < maxPerm) {
        _zls_FFTPermArr = realloc (_zls_FFTPermArr, maxPerm * sizeof(Integer));
        _integersAllocated = maxPerm;
    }

    if (!_zls_FFTTmp0 || !_zls_FFTTmp1 || !_zls_FFTTmp2 || !_zls_FFTTmp3 || !_zls_FFTPermArr) {
        zls_FFTFree();
        return memErr;
    }

    return err;

}


void zls_FFTComputeAllocSizes(Counter *ntot, Integer * maxf, Integer * maxp,
                               Integer ndim,
                               const Integer dims []);

void zls_FFTComputeAllocSizes(Counter *ntot, Integer * maxf, Integer * maxp,
                               Integer ndim,
                               const Integer dims []){

//c    maxf must be .ge. the maximum prime factor of n.
//c    maxp must be .gt. the number of prime factors of n.
//c    in addition, if the square-free portion k of n has two or
//c    more prime factors, then maxp must be .ge. k-1.
//c    conservative estimates, use all factors not just prime ones

    Integer mxFactor     = 16; // minimum allocation
    Integer mxprodFactor = 16; // minimum allocation
    Counter nt = 1;
    Counter i;
    for (i = 0; i < ndim; i++) {

        nt *= dims [i];

        Integer n_SqFactors = 0;
        Integer n_Factors = zls_FFTfactorize (dims[i], &n_SqFactors);
        Integer n_NonSqFactors =(n_Factors-(2*n_SqFactors));

            //c    maxf must be .ge. the maximum prime factor of n of all n

        Integer j;
        for (j = 0; j < n_Factors; j++){
            mxFactor = (mxFactor<fftFactors[j])?fftFactors[j]:mxFactor;
        }

//c    maxp must be .gt. the number of prime factors of n of all n
//c    in addition, if the square-free portion k of n has two or
//c    more prime factors, then maxp must be .ge. k-1.

        Integer prodFactor = n_Factors+1;
        Integer prodNonSqFactors = 1;
        if ( n_NonSqFactors > 0 ){
            for (j = 0; j < n_NonSqFactors; j++){
                prodNonSqFactors *= fftFactors[j+n_SqFactors];
            }
        }

        prodFactor   = (prodFactor<prodNonSqFactors)?prodNonSqFactors:prodFactor;
        mxprodFactor = (mxprodFactor<prodFactor)?prodFactor:mxprodFactor;
    }
//
//
//    printf(" maxFactor: %d, maxPerm: %d \n",maxFactor, maxPerm);
//
//    Extravagant: just use the full vector size as upperlimit values
//
//        maxFactors = 1;
//        maxPerm    = 1;
//        nTotal = 1;
//
//        for ( Integer i = 0; i < ndim; i++) {
//            if (dims [i] <= 0) return dimensionErr;
//            maxFactors = (dims [i] > maxFactors)? dims [i]: maxFactors;
//            nTotal *= dims [i];
//        }
//        maxFactors = maxFactors + ( maxFactors % 2); // for allocs of 16
//        maxPerm    = maxFactors;
//
//   or  the constants used in the original Fortran code,
//   for very limited FFT input values allowed:
//    maxFactors = 23;
//    maxPerm = 209;
//
    *maxf  = mxFactor     + ( mxFactor % 2); // for allocs of 16 bytes, even number of Real
    *maxp  = mxprodFactor + ( mxprodFactor % 4); // for allocs of 16 bytes, multiple of 4 Integers
    *ntot  = nt;
    
}

/* ----------------------------------------------------------------------*
 * Integer fftradix (Real Re[], Real Im[], Counter nTotal, Counter nPass,
 *       Counter nSpan, Integer iSign, Counter maxFactor,
 *       Counter maxPerm);
 *
 * RE and IM hold the real and imaginary components of the data, and
 * return the resulting real and imaginary Fourier coefficients.
 * Multidimensional data *must* be allocated contiguously.  There is
 * no limit on the number of dimensions.
 *
 *
 * Although there is no limit on the number of dimensions, fftradix()
 * must be called once for each dimension, but the calls may be in
 * any order.
 *
 * NTOTAL = the total number of complex data values
 * NPASS  = the size of the dimension of the current variable
 * NSPAN/NPASS = the spacing of consecutive data values while indexing
 *  the current variable
 * ISIGN - see above documentation
 *
 * example:
 * tri-variate transform with Re[n1][n2][n3], Im[n1][n2][n3]
 *
 *  fftradix (Re, Im, n1*n2*n3, n1,       n1, 1, maxf, maxp);
 *  fftradix (Re, Im, n1*n2*n3, n2,    n1*n2, 1, maxf, maxp);
 *  fftradix (Re, Im, n1*n2*n3, n3, n1*n2*n3, 1, maxf, maxp);
 *
 * single-variate transform,
 *    NTOTAL = N = NSPAN = (number of complex data values),
 *
 *  fftradix (Re, Im, n, n, n, 1, maxf, maxp);
 *
 * The data can also be stored in a single array with alternating
 * real and imaginary parts, the magnitude of ISIGN is changed to 2
 * to give correct indexing increment, and data [0] and data [1] used
 * to pass the initial addresses for the sequences of real and
 * imaginary values,
 *
 * example:
 *  Real data [2*NTOTAL];
 *  fftradix (&data[0], &data[1], NTOTAL, nPass, nSpan, 2, maxf, maxp);
 *
 * for temporary allocation:
 c    maxFactor must be .ge. the maximum factor of n.
 c    maxPerm must be .gt. the number of factors of n.
 c    in addition, if the square-free portion, k of n, has two or
 c    more prime factors, then maxp must be .ge. k-1.
 * These conditions are computed in the wrapper function below.
 * ----------------------------------------------------------------------*/

/*
 * Singleton's mixed radix routine with dynamic temp storage
 C
 C REFERENCE-  SINGLETON, R. C.,  AN ALGORITHM FOR COMPUTING THE MIXED
 C             RADIX FAST FOURIER TRANSFORM , IEEE TRANSACTIONS ON AUDIO
 C             AND ELECTROACOUSTICS, VOL. AU-17, NO. 2, JUNE, 1969
 C             PP. 93-103.
 */

int fftradix (Real *Re,
              Real *Im,
              Counter nTotal,
              Counter nPass,
              Counter nSpan,
              Integer iSign,
              Integer maxFactor,
              Integer maxPerm);

int fftradix (Real *Re,
              Real *Im,
              Counter nTotal,
              Counter nPass,
              Counter nSpan,
              Integer iSign,
              Integer maxFactor,
              Integer maxPerm)
{

    Integer nFactor=0, nSqrs=0;
    Integer kspan=0, ispan=0, inc=0;
    Integer ii=0, j=0, jc=0, jf=0, jj=0;
    Integer k=0, k1=0, k2=0, k3=0, k4=0, kk=0;
    Integer nn=0, ns=0, nt=0;

    Real rads=0.0;
    Real c1=0.0, c2=0.0, c3=0.0, cd=0.0;
    Real s1=0.0, s2=0.0, s3=0.0, sd=0.0;

    Real s60 = ZLS_SIN60; // sin(60 deg)
    Real s72 = ZLS_SIN72; // sin(72 deg)
    Real c72 = ZLS_COS72; // cos(72 deg)
    Real pi  = M_PI;
    Real pi2 = 2.0*pi;

    Re--;
    Im--;

    if (nPass < 2)
        return dimensionErr;

    int err = zls_FFTAllocateStorage(maxFactor, maxPerm);

    if (err != NoErr ) goto ErrorLabel;

        // set temp arrays
    Real * Rt  = (Real *) _zls_FFTTmp0;
    Real * It  = (Real *) _zls_FFTTmp1;
    Real * Cos = (Real *) _zls_FFTTmp2;
    Real * Sin = (Real *) _zls_FFTTmp3;
    Integer * Permute = (Integer *) _zls_FFTPermArr;

    /*
     * Function Body
     */

    inc = iSign;
    if (iSign < 0)
      {
        s60 = -s60;
        s72 = -s72;
        pi  = -pi;
        pi2 = 2.0*pi;
        inc = -inc;
      }

    /* adjust for increments */
    nt = inc * nTotal;
    ns = inc * nSpan;
    kspan = ns;

    nn   = nt - inc;
    jc   = ns / nPass;
    rads = pi * (double) jc;

    ii = 0;
    jf = 0;
    /* determine the factors of n */

    nFactor = zls_FFTfactorize (nPass, &nSqrs);
    if (nFactor > ZLS_FFT_NFACTOR) goto ErrorLabel;

    /* compute fourier transform */
    for (;;) {

        sd = rads / (double) kspan;
        cd = sin (sd);
        cd = 2.0 * cd * cd;
        sd = sin (sd + sd);
        kk = 1;
        ii++;

        switch (fftFactors [ii - 1]) {
            case 2:
                /* transform for factor of 2 (including rotation factor) */
                kspan /= 2;
                k1 = kspan + 2;
                do {
                    do {
                        k2 = kk + kspan;
                        Real ak = Re[k2];
                        Real bk = Im[k2];
                        Re[k2] = Re[kk] - ak;
                        Im[k2] = Im[kk] - bk;
                        Re[kk] += ak;
                        Im[kk] += bk;
                        kk = k2 + kspan;
                    } while (kk <= nn);
                    kk -= nn;
                } while (kk <= jc);
                if (kk > kspan)
                    goto PermuteLabel;   /* exit infinite loop */
                do {
                    c1 = 1.0 - cd;
                    s1 = sd;
                    do {
                        do {
                            do {
                                k2 = kk + kspan;
                                Real ak = Re[kk] - Re[k2];
                                Real bk = Im[kk] - Im[k2];
                                Re[kk] += Re[k2];
                                Im[kk] += Im[k2];
                                Re[k2] = c1 * ak - s1 * bk;
                                Im[k2] = s1 * ak + c1 * bk;
                                kk = k2 + kspan;
                            } while (kk < nt);
                            k2 = kk - nt;
                            c1 = -c1;
                            kk = k1 - k2;
                        } while (kk > k2);
                        Real ak = c1 - (cd * c1 + sd * s1);
                        s1 = sd * c1 - cd * s1 + s1;
//
// the following 3 lines are for truncation errors in ancient CDC6xxxs
// use  c1 = ak; eg for sane ieee 754 math
//
//                         c1 = 2.0 - (ak * ak + s1 * s1);
//                         s1 *= c1;
//                         c1 *= ak;
                        c1 = ak;
                        kk += jc;
                    } while (kk < k2);
                    k1 += (inc + inc);
                    kk = (k1 - kspan) / 2 + jc;
                } while (kk <= jc + jc);
                break;

            case 4:
                kspan /= 4;
                do {
                    c1 = 1.0;
                    s1 = 0.0;
                    do {
                        do {

                            k1 = kk + kspan;
                            k2 = k1 + kspan;
                            k3 = k2 + kspan;

                            Real akp = Re[kk] + Re[k2];
                            Real akm = Re[kk] - Re[k2];
                            Real ajp = Re[k1] + Re[k3];
                            Real ajm = Re[k1] - Re[k3];
                            Re[kk] = akp + ajp;
                            ajp = akp - ajp;

                            Real bkp = Im[kk] + Im[k2];
                            Real bkm = Im[kk] - Im[k2];
                            Real bjp = Im[k1] + Im[k3];
                            Real bjm = Im[k1] - Im[k3];
                            Im[kk] = bkp + bjp;
                            bjp = bkp - bjp;

                            if (iSign < 0) {
                                akp = akm + bjm;
                                akm -= bjm;
                                bkp = bkm - ajm;
                                bkm += ajm;
                            } else {
                                akp  = akm - bjm;
                                akm += bjm;
                                bkp = bkm + ajm;
                                bkm -= ajm;
                            }

                            if (s1 == 0.0) {
                                Re[k1] = akp;
                                Im[k1] = bkp;
                                Re[k2] = ajp;
                                Im[k2] = bjp;
                                Re[k3] = akm;
                                Im[k3] = bkm;
                            } else {
                                Re[k1] = akp * c1 - bkp * s1;
                                Im[k1] = akp * s1 + bkp * c1;
                                Re[k2] = ajp * c2 - bjp * s2;
                                Im[k2] = ajp * s2 + bjp * c2;
                                Re[k3] = akm * c3 - bkm * s3;
                                Im[k3] = akm * s3 + bkm * c3;
                            }
                            kk = k3 + kspan;
                        } while (kk <= nt);

                        c2 = c1 - (cd * c1 + sd * s1);
                        s1 = sd * c1 - cd * s1 + s1;
// again, 3 lines for CDC systems with poor truncation errors
// use c1 = c2 if proper rounding exists
//c1 = 2.0 - (c2 * c2 + s1 * s1);
//s1 *= c1;
//c1 *= c2;
                        c1 = c2;
                        c2 = c1 * c1 - s1 * s1;
                        s2 = 2.0 * c1 * s1;
                        c3 = c2 * c1 - s2 * s1;
                        s3 = c2 * s1 + s2 * c1;
                        kk = kk - nt + jc;
                    } while (kk <= kspan);
                    kk = kk - kspan + inc;
                } while (kk <= jc);
                if (kspan == jc)
                    goto PermuteLabel;   /* exit infinite loop */
                break;

            default:

                ispan = kspan;
                k = fftFactors [ii - 1];
                kspan /= k;

                switch (fftFactors [ii - 1]) {
                    case 3: /* transform for factor of 3 (optional code) */
                        do {
                            do {
                                k1 = kk + kspan;
                                k2 = k1 + kspan;
                                Real ak = Re[kk];
                                Real bk = Im[kk];
                                Real aj = Re[k1] + Re[k2];
                                Real bj = Im[k1] + Im[k2];
                                Re[kk] = ak + aj;
                                Im[kk] = bk + bj;
                                ak -= 0.5 * aj;
                                bk -= 0.5 * bj;
                                aj = (Re[k1] - Re[k2]) * s60;
                                bj = (Im[k1] - Im[k2]) * s60;
                                Re[k1] = ak - bj;
                                Re[k2] = ak + bj;
                                Im[k1] = bk + aj;
                                Im[k2] = bk - aj;
                                kk = k2 + kspan;
                            } while (kk < nn);
                            kk -= nn;
                        } while (kk <= kspan);
                        break;

                    case 5: /* transform for factor of 5 (optional code) */
                        c2 = c72 * c72 - s72 * s72;
                        s2 = 2.0 * c72 * s72;
                        do {
                            do {

                                k1 = kk + kspan;
                                k2 = k1 + kspan;
                                k3 = k2 + kspan;
                                k4 = k3 + kspan;

                                Real akp = Re[k1] + Re[k4];
                                Real akm = Re[k1] - Re[k4];
                                Real bkp = Im[k1] + Im[k4];
                                Real bkm = Im[k1] - Im[k4];

                                Real ajp = Re[k2] + Re[k3];
                                Real ajm = Re[k2] - Re[k3];
                                Real bjp = Im[k2] + Im[k3];
                                Real bjm = Im[k2] - Im[k3];

                                Real aa  = Re[kk];
                                Real bb  = Im[kk];
                                Re[kk]   = aa + akp + ajp;
                                Im[kk]   = bb + bkp + bjp;

                                Real ak = akp * c72 + ajp * c2 + aa;
                                Real bk = bkp * c72 + bjp * c2 + bb;

                                Real aj = akm * s72 + ajm * s2;
                                Real bj = bkm * s72 + bjm * s2;

                                Re[k1] = ak - bj;
                                Im[k1] = bk + aj;

                                Re[k4] = ak + bj;
                                Im[k4] = bk - aj;

                                ak = akp * c2 + ajp * c72 + aa;
                                bk = bkp * c2 + bjp * c72 + bb;
                                aj = akm * s2 - ajm * s72;
                                bj = bkm * s2 - bjm * s72;

                                Re[k2] = ak - bj;
                                Im[k2] = bk + aj;

                                Re[k3] = ak + bj;
                                Im[k3] = bk - aj;

                                kk = k4 + kspan;
                            } while (kk < nn);
                            kk -= nn;
                        } while (kk <= kspan);
                        break;

                    default:
                        k = fftFactors [ii - 1];
                        if (jf != k)
                          {
                            jf = k;
                            s1 = pi2 / (double) jf;
                            c1 = cos (s1);
                            s1 = sin (s1);
                            if (jf > maxFactor)
                                goto ErrorLabel;
                            Cos [jf - 1] = 1.0;
                            Sin [jf - 1] = 0.0;
                            j = 1;
                            do {
                                Cos [j - 1] = Cos [k - 1] * c1 + Sin [k - 1] * s1;
                                Sin [j - 1] = Cos [k - 1] * s1 - Sin [k - 1] * c1;
                                k--;
                                Cos [k - 1] = Cos [j - 1];
                                Sin [k - 1] = -Sin [j - 1];
                                j++;
                            } while (j < k);
                          }
                        do {
                            do {
                                Real aa, ak;
                                Real bb, bk;
                                aa = ak = Re[kk];
                                bb = bk = Im[kk];
                                k1 = kk;
                                k2 = kk + ispan;
                                j  = 1;
                                k1 += kspan;
                                do {
                                    k2 -= kspan;
                                    Rt [j] = Re[k1] + Re[k2];
                                    ak += Rt [j];
                                    It [j] = Im[k1] + Im[k2];
                                    bk += It [j];
                                    j++;
                                    Rt [j] = Re[k1] - Re[k2];
                                    It [j] = Im[k1] - Im[k2];
                                    j++;
                                    k1 += kspan;
                                } while (k1 < k2);
                                Re[kk] = ak;
                                Im[kk] = bk;

                                k1 = kk;
                                k2 = kk + ispan;
                                j = 1;
                                do {
                                    ak = aa;
                                    bk = bb;
                                    Real aj = 0.0;
                                    Real bj = 0.0;
                                    k1 += kspan;
                                    k2 -= kspan;
                                    jj = j;
                                    k = 1;
                                    do {
                                        ak += Rt [k] * Cos [jj - 1];
                                        bk += It [k] * Cos [jj - 1];
                                        k++;
                                        aj += Rt [k] * Sin [jj - 1];
                                        bj += It [k] * Sin [jj - 1];
                                        k++;
                                        jj += j;
                                        if (jj > jf)
                                            jj -= jf;
                                    } while (k < jf);
                                    k = jf - j;
                                    Re[k1] = ak - bj;
                                    Im[k1] = bk + aj;
                                    Re[k2] = ak + bj;
                                    Im[k2] = bk - aj;
                                    j++;
                                } while (j < k);
                                kk += ispan;
                            } while (kk <= nn);
                            kk -= nn;
                        } while (kk <= kspan);
                        break;
                }
                if (ii == nFactor)
                    goto PermuteLabel;
                kk = jc + 1;
                do {
                    c2 = 1.0 - cd;
                    s1 = sd;
                    do {
                        c1 = c2;
                        s2 = s1;
                        kk += kspan;
                        do {
                            do {
                                Real ak = Re[kk];
                                Re[kk] = c2 * ak - s2 * Im[kk];
                                Im[kk] = s2 * ak + c2 * Im[kk];
                                kk += ispan;
                            } while (kk <= nt);
                            Real tmp = s1 * s2;
                            s2 = s1 * c2 + c1 * s2;
                            c2 = c1 * c2 - tmp;
                            kk = kk - nt + kspan;
                        } while (kk <= ispan);
                        c2 = c1 - (cd * c1 + sd * s1);
                        s1 += sd * c1 - cd * s1;
//
// again, 3 lines for systems with poor truncation errors
// may be deleted if proper rounding exists
//
//c1 = 2.0 - (c2 * c2 + s1 * s1);
//s1 *= c1;
//c2 *= c1;
//
                        kk = kk - ispan + jc;
                    } while (kk <= kspan);
                    kk = kk - kspan + jc + inc;
                } while (kk <= jc + jc);
                break;
        }
    }

/* permute the results to normal order -- done in two stages */
/* permutation for square factors of n */

PermuteLabel:
    Permute [0] = ns;
    if (nSqrs)
      {
        k = nSqrs + nSqrs + 1;
        if (k > nFactor)
            k--;
        Permute [k] = jc;
        j = 1;
        do {
            Permute [j] = Permute [j - 1] / fftFactors [j - 1];
            Permute [k - 1] = Permute [k] * fftFactors [j - 1];
            j++;
            k--;
        } while (j < k);
        k3 = Permute [k];
        kspan = Permute [1];
        kk = jc + 1;
        k2 = kspan + 1;
        j = 1;
        if (nPass != nTotal) {
// permutation for multivariate transform
        PermuteMulti:
            do {
                do {
                    k = kk + jc;
                    do {
                        Real tmp;
                        tmp = Re[kk]; Re[kk] = Re[k2]; Re[k2] = tmp;
                        tmp = Im[kk]; Im[kk] = Im[k2]; Im[k2] = tmp;
                        kk += inc;
                        k2 += inc;
                    } while (kk < k);
                    kk += (ns - jc);
                    k2 += (ns - jc);
                } while (kk < nt);
                k2 = k2 - nt + kspan;
                kk = kk - nt + jc;
            } while (k2 < ns);
            do {
                do {
                    k2 -= Permute [j - 1];
                    j++;
                    k2 = Permute [j] + k2;
                } while (k2 > Permute [j - 1]);
                j = 1;
                do {
                    if (kk < k2)
                        goto PermuteMulti;
                    kk += jc;
                    k2 += kspan;
                } while (k2 < ns);
            } while (kk < ns);
        }
        else
          {
          PermuteSingle:
            do {
                Real tmp;
                tmp = Re[kk]; Re[kk] = Re[k2]; Re[k2] = tmp;
                tmp = Im[kk]; Im[kk] = Im[k2]; Im[k2] = tmp;
                kk += inc;
                k2 += kspan;
            } while (k2 < ns);
            do {
                do {
                    k2 -= Permute [j - 1];
                    j++;
                    k2 = Permute [j] + k2;
                } while (k2 > Permute [j - 1]);
                j = 1;
                do {
                    if (kk < k2)
                        goto PermuteSingle;
                    kk += inc;
                    k2 += kspan;
                } while (k2 < ns);
            } while (kk < ns);
          }
        jc = k3;
      }

    if ((nSqrs << 1) + 1 >= nFactor)
        return 0;
    ispan = Permute [nSqrs];

        // permutation for non-square factors of n
    j = nFactor - nSqrs;
    fftFactors [j] = 1;
    do {
        fftFactors [j - 1] *= fftFactors [j];
        j--;
    } while (j != nSqrs);
    nn = fftFactors [nSqrs] - 1;
    nSqrs++;
    if (nn > maxPerm)
        goto ErrorLabel;

    j = jj = 0;
    for (;;) {
        k = nSqrs + 1;
        k2 = fftFactors [nSqrs - 1];
        kk = fftFactors [k - 1];
        j++;
        if (j > nn)
            break;/* exit infinite loop */
        jj += kk;
        while (jj >= k2)
          {
            jj -= k2;
            k2 = kk;
            kk = fftFactors [k++];
            jj += kk;
          }
        Permute [j - 1] = jj;
    }
        // determine the permutation cycles of length greater than 1
    j = 0;
    for (;;) {
        do {
            kk = Permute [j++];
        } while (kk < 0);
        if (kk != j) {
            do {
                k = kk;
                kk = Permute [k - 1];
                Permute [k - 1] = -kk;
            } while (kk != j);
            k3 = kk;
        } else {
            Permute [j - 1] = -j;
            if (j == nn)
                break;      /* exit infinite loop */
        }
    }

    maxFactor *= inc;

    /* reorder a and b, following the permutation cycles */
    for (;;) {
        j = k3 + 1;
        nt -= ispan;
        ii = nt - inc + 1;
        if (nt < 0)
            break;          /* exit infinite loop */
        do {
            do {
                j--;
            } while (Permute [j - 1] < 0);
            jj = jc;
            do {
                if (jj < maxFactor) kspan = jj; else kspan = maxFactor;
                jj -= kspan;
                k = Permute [j - 1];
                kk = jc * k + ii + jj;
                k1 = kk + kspan;
                k2 = 0;
                do {
                    Rt [k2] = Re[k1];
                    It [k2] = Im[k1];
                    k2++;
                    k1 -= inc;
                } while (k1 != kk);
                do {
                    k1 = kk + kspan;
                    k2 = k1 - jc * (k + Permute [k - 1]);
                    k = -Permute [k - 1];
                    do {
                        Re[k1] = Re[k2];
                        Im[k1] = Im[k2];
                        k1 -= inc;
                        k2 -= inc;
                    } while (k1 != kk);
                    kk = k2;
                } while (k != j);

                k1 = kk + kspan;
                k2 = 0;
                do {
                    Re[k1] = Rt [k2];
                    Im[k1] = It [k2];
                    k2++;
                    k1 -= inc;
                } while (k1 != kk);
            } while (jj);
        } while (j != 1);
    }

    return NoErr;

ErrorLabel:
    zls_FFTFree ();
    return memErr;

}
/*
 * use macros to access the Real/Imaginary parts so that it's possible
 * to substitute different macros if a complex struct is used
 */
#ifndef Re_Data
#define Re_Data(i) data[i][0]
#define Im_Data(i) data[i][1]
#endif
/*
 * zls_fftradixC C wrapper for fftradix, Brief overview of parameters:
 * ---------------------------------------------------------------------*
 * In-Place multi-Radix FFT,
 *
 * Integer  zls_fftradixC (Integer ndim,
 *                   const Integer dims[],
 *                         Complex data,
 *                         Integer direction,
 *                            Real scale);
 *
 * NDIM = the total number dimensions
 * DIMS = a vector of array sizes
 *
 * data holds the real and imaginary components of the data, in
 * alternating order. Multidimensional data *must* be allocated
 * contiguously, zls_arrs.h does this.  There is
 * no limit on the number of dimensions.
 *
 * direction = the sign of the complex exponential
 * direction: +1 = forward  -1 = reverse
 *
 * scale = normalizing constant by which the final result is DIVIDED
 *  if scale == -1, normalize by total dimension of the transform
 *  if scale <  -1, normalize by the square-root of the total dimension
 *
 * example:
 * tri-variate transform with data[n3][n2][n1]
 *
 *  Integer dims[3] = {n1,n2,n3}
 *  zls_fftradixC (3, dims, data, 1, scale);
 *
 */

int zls_fftradixC (Integer ndim,
                   const Integer dims [],
                   Complex * data,
                   Integer direction,
                   Real scaling);

int zls_fftradixC (Integer ndim,
                   const Integer dims [],
                   Complex * data,
                   Integer direction,
                   Real scaling)
{

// wrapper function for fftradix that accepts complex interleaved data

    int err = NoErr;

    // terminate as early as possible

    if ( scaling == 0.0 ) return domainErr;
    if ( data == NULL )   return memErr;
    if ( ndim < 1)        return dimensionErr;
    if ( dims == NULL )   return dimensionErr;

    Counter i;
    for (i = 0; i < ndim; i++)
        if (dims [i] <= 0) return dimensionErr;

    Counter nTotal=1;
    Integer maxFactor=1, maxPerm=1;

    zls_FFTComputeAllocSizes(&nTotal, &maxFactor, &maxPerm, ndim, dims);

    if (nTotal > 1){
        Counter nSpan = 1;
        for (i = 0; i < ndim; i++) {
            nSpan *= dims [i];
            err = fftradix (&data[0][0], &data[0][1], nTotal, dims [i], nSpan, 2*direction, maxFactor, maxPerm);
            if (err != NoErr) return err;
        }
        if ( scaling != 1.0) {
            if (scaling < 0.0)
                scaling = (scaling < -1.0) ? sqrt (nTotal) : nTotal;
            scaling = 1.0 / scaling;
            for (i = 0; i < nTotal; i ++) {
                Re_Data (i) *= scaling;
                Im_Data (i) *= scaling;
            }
        }
    } else { err = dimensionErr; }

    return err;
}


int zls_expandComplex( CQ1DArr * cDst, Real rValue, Real cValue, Counter n){
    int err = NoErr;
    CQ1DArr cm = NULL;
    zls_NewCQuantity1DArr(&cm, n);
    if (cm != NULL) {
        for (Counter i = 0; i < n; i++ ) {
            cm[i][0]=rValue;
            cm[i][1]=cValue;
        }
    } else { err = memErr; }
    *cDst = cm;
    return err;
}

int zls_expandReal( CQ1DArr * cDst, Q1DArr iSrc, Real rValue, Counter n){
    int err = NoErr;
    CQ1DArr cm = NULL;
    zls_NewCQuantity1DArr(&cm, n);
    if (( iSrc != NULL ) && (cm != NULL) ){
        for (Counter i = 0; i < n; i++ ) {
            cm[i][0]=rValue;
            cm[i][1]=iSrc[i];
        }
    } else { err = memErr; }
    *cDst = cm;
    return err;
}


int zls_expandImaginary( CQ1DArr * cDst, Q1DArr rSrc, Real cValue, Counter n){
    int err = NoErr;
    CQ1DArr cm = NULL;
    zls_NewCQuantity1DArr(&cm, n);
    if (( rSrc != NULL ) && (cm != NULL) ){
        for (Counter i = 0; i < n; i++ ) {
            cm[i][0]=rSrc[i];
            cm[i][1]=cValue;
        }
    } else { err = memErr; }
    *cDst = cm;
    return err;
}


int zls_combineComplex(CQ1DArr * cDst, Q1DArr rSrc, Q1DArr iSrc, Counter n){
    int err = NoErr;
    CQ1DArr cm = NULL;
    zls_NewCQuantity1DArr(&cm, n);
    if (cm != NULL) {
        for (Counter i = 0; i < n; i++ ){
            cm[i][0]= rSrc[i];
            cm[i][1]= iSrc[i];
        }
    } else { err = memErr; }
    *cDst = cm;
    return err;
}

int zls_cloneComplex( CQ1DArr * cDst, CQ1DArr cSrc, Counter n ){
    int err = NoErr;
    CQ1DArr cm = NULL;
    zls_NewCQuantity1DArr(&cm, n);
    if (cm != NULL) {
        for (Counter i = 0; i < n; i++ ) {
            cm[i][0]=cSrc[i][0];
            cm[i][1]=cSrc[i][1];
        }
    } else { err = memErr; }
    *cDst = cm;
    return err;
}

int zls_extractReal( Q1DArr * rDst, CQ1DArr rSrc, Counter n){
    int err = NoErr;
    Q1DArr re = NULL;
    zls_NewQuantity1DArr(&re, n);
    if (re != NULL) {
        for (Counter i = 0; i < n; i++ )
            re[i]= rSrc[i][0];
    } else { err = memErr; };
    *rDst  = re;
    return err;
}

int zls_extractImaginary(Q1DArr * iDst, CQ1DArr imSrc, Counter n){
    int err = NoErr;
    Q1DArr im = NULL;
    zls_NewQuantity1DArr(&im, n);
    if (im != NULL) {
        for (Counter i = 0; i < n; i++ )
            im[i]= imSrc[i][1];
    } else { err = memErr; }
    *iDst  = im;
    return err;
}


int zls_splitComplex(Q1DArr * rDst, Q1DArr * iDst, CQ1DArr imSrc, Counter n){
    int err = NoErr;
    Q1DArr re = NULL;
    Q1DArr im = NULL;
    if (imSrc != NULL) {
        zls_NewQuantity1DArr( &re, n );
        zls_NewQuantity1DArr( &im, n );
        if (( re != NULL ) && ( im != NULL )){
            for (Counter i = 0; i < n; i++ ){
                re[i]= imSrc[i][0];
                im[i]= imSrc[i][1];
            }
        } { err = memErr; };
    } else { err = memErr; };
    *rDst = re;
    *iDst = im;
    return err;
}

    // | cSrc x cSrc* | eg 1+2i * 1-2i = 5.0+0i = |r|^2 + |c|^2
Q1DArr zls_complexSqr (CQ1DArr cSrc, Counter n){
    Q1DArr rDst = NULL;
    zls_NewQuantity1DArr(&rDst, n);
    if (cSrc != NULL)
        for (Counter i = 0; i < n; i++ ){
            Real r = cSrc[i][0];
            Real c = cSrc[i][1];
            rDst[i]= r*r+c*c;
        }
    return (rDst);
}

    // Sqrt| cSrc x cSrc* | eg sqrt(1+2i * 1-2i) = Sqrt(5.0+0i) = Sqrt(|r|^2 + |c|^2)
Q1DArr zls_complexMag (CQ1DArr cSrc, Counter n){
    Q1DArr rDst = NULL;
    zls_NewQuantity1DArr(&rDst, n);
    if (cSrc != NULL)
        for (Counter i = 0; i < n; i++ ){
            Real r = cSrc[i][0];
            Real c = cSrc[i][1];
            rDst[i]= sqrt(r*r+c*c);
        }
    return (rDst);
}

void zls_complexNormaliseN (CQ1DArr cSrc, Counter n){
    if (cSrc != NULL) {
        Real norm = 1.0/(double)(n);
        for (Counter i = 0; i < n; i++ ){
            cSrc[i][0] *= norm;
            cSrc[i][1] *= norm;
        }
    }
}

void zls_realNormaliseN (Q1DArr rSrc, Counter n){
    if (rSrc != NULL) {
        Real norm = 1.0/(double)(n);
        for (Counter i = 0; i < n; i++ ){
            rSrc[i] *= norm;
        }
    }
}


void zls_complexNormaliseSQRTN (CQ1DArr cSrc, Counter n){
    if (cSrc != NULL) {
        Real norm = 1.0/sqrt((double)(n));
        for (Counter i = 0; i < n; i++ ){
            cSrc[i][0] *= norm;
            cSrc[i][1] *= norm;
        }
    }
}

void zls_realNormaliseSQRTN (Q1DArr rSrc, Counter n){
    if (rSrc != NULL) {
        Real norm = 1.0/sqrt((double)(n));
        for (Counter i = 0; i < n; i++ ){
            rSrc[i] *= norm;
        }
    }
}

int zls_FFT1DRtoC (CQ1DArr *cDst, Q1DArr  rSrc, Counter n, Integer dir){
        // always forward
    int err =NoErr;
    CQ1DArr cTemp = NULL;
    if ( rSrc != NULL ) {
        zls_expandImaginary( &cTemp, rSrc, 0.0, n);
        if ( cTemp != NULL) {
            Integer ndim = 1;
            Integer dims[1] = {n};
            Integer sign = -1;
            if (((dir & kFFTDirForwardFlag) ==  kFFTDirForwardFlag ))
                sign = +1;
            Real scale = 1.0;
            if (((dir & kFFTDirNormaliseNFlag) ==  kFFTDirNormaliseNFlag ))
                scale = -1.0;
            if (((dir & kFFTDirNormaliseSQRTNFlag) ==  kFFTDirNormaliseSQRTNFlag ))
                scale = -2.0;
            err = zls_fftradixC (ndim,dims,cTemp,sign,scale);
            zls_FFTFree();
        } else { err = memErr; }
    } else { err = memErr; }
    *cDst = cTemp;
    return err;
}

int zls_FFT1DCtoC ( CQ1DArr *cDst, CQ1DArr cSrc, Counter n, Integer dir ){
        // n is the full -n/2 .. 0 ... n/2
    int err =NoErr;
    CQ1DArr cTemp = NULL;
    if ( cSrc != NULL ) {
        zls_cloneComplex(&cTemp, cSrc,n);
        if ( cTemp != NULL) {

            Integer ndim = 1;
            Integer dims[1] = {n};
            Integer sign = -1;
            if (((dir & kFFTDirForwardFlag) ==  kFFTDirForwardFlag ))
                sign = +1;
            Real scale = 1.0;
            if (((dir & kFFTDirNormaliseNFlag) ==  kFFTDirNormaliseNFlag ))
                scale = -1.0;
            if (((dir & kFFTDirNormaliseSQRTNFlag) ==  kFFTDirNormaliseSQRTNFlag ))
                scale = -2.0;
            err = zls_fftradixC (ndim,dims,cTemp,sign,scale);
            zls_FFTFree();
        } else { err = memErr; }
    } else { err = memErr; }
    *cDst = cTemp;
    return err;
}

int zls_FFT1DCtoR ( Q1DArr  *rDst, CQ1DArr cSrc, Counter n, Integer dir){
        // always reverse
    int err =NoErr;
    Q1DArr rTemp = NULL;
    if ( cSrc != NULL ) {
        CQ1DArr cTemp = NULL;
        zls_cloneComplex(&cTemp, cSrc,n);
        if ( cTemp != NULL ) {
                //ComplexFFT((Real *)cTemp, n, n, 1);
            Integer ndim = 1;
            Integer dims[1] = {n};
            Integer sign = -1;
            if (((dir & kFFTDirForwardFlag) ==  kFFTDirForwardFlag ))
                sign = +1;
            Real scale = 1.0;
            if (((dir & kFFTDirNormaliseNFlag) ==  kFFTDirNormaliseNFlag ))
                scale = -1.0;
            if (((dir & kFFTDirNormaliseSQRTNFlag) ==  kFFTDirNormaliseSQRTNFlag ))
                scale = -2.0;
            err = zls_fftradixC (ndim,dims,cTemp,sign,scale);
            zls_FFTFree();
            
            zls_extractReal(&rTemp, cTemp, n);
            zls_DisposeCQuantity(cTemp);
        } else { err = memErr; }
    } else { err = memErr; }
    *rDst = rTemp;
    return err;
}

int zls_FFT1DRtoSpec (Q1DArr *rSpec, Q1DArr  rSrc, Counter n){
    int err = NoErr;
    Q1DArr re = NULL;
    if (( rSrc != NULL) && ( n > 1)) {
        CQ1DArr cDst = NULL;
        err = zls_FFT1DRtoC (&cDst, rSrc, n, kFFTDirForwardNormalN);
        if (cDst != NULL)
            re = zls_complexSqr(cDst, n);
        zls_DisposeCQuantity(cDst);
    } else (err = memErr);
    *rSpec = re;
    return (err);
}

int zls_FFT1DCtoSpec (Q1DArr *rSpec, CQ1DArr cSrc, Counter n){
    int err = NoErr;
    Q1DArr re = NULL;
    if (( cSrc != NULL) && ( n > 1)) {
        CQ1DArr cDst = NULL;
        err = zls_FFT1DCtoC (&cDst, cSrc, n, kFFTDirForwardNormalN);
        if (cDst != NULL)
            re = zls_complexSqr(cDst, n);
        zls_DisposeCQuantity(cDst);
    } else (err = memErr);
    *rSpec = re;
    return (err);
}


