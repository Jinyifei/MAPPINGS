#include "zls.h"

#define C_KMS 299792.458


int zls_WLogXConvolve(Q1DArr wv, Q1DArr fl, Q1DArr cn, Q1DArr nz, Counter nSpec, Real resR, Real fwhm, Real vSini , Real box){


    int err = noErr;

        //
        // spectra are already evenly sampled, and are returned with the same sampling
        // This routine resamples to x5 resolution and log lambda then does
        // convolutions on each of the y arrays, fl5, cn5 and nz5
        // Then it resamples and returns modified arrays.
        // Uses gls akima 3rd order non oscillating splines
        //

    if (( resR <= 0.0 ) && ( fwhm <= 0.0 ) && ( vSini <= 0.0 ) && ( box <= 0.0 )) return noErr; // nothing to do but OK

        // cvt to ln lambda for constant kernels in v space
    Q1DArr lwv = NULL;

    err  = zls_NewQuantity1DArr( &lwv, nSpec );

    if (err == noErr ){ // log lambda array OK

        for (Counter idx = 0; idx < nSpec; idx++) {
            lwv [idx] = log( wv[idx] ); // ln
        }

            // 5 times sampled arrays:

        Q1DArr wv5 = NULL;
        Q1DArr fl5 = NULL;
        Q1DArr cn5 = NULL;
        Q1DArr nz5 = NULL;

        Counter n5 = ((nSpec-1)*5)+1;

        Real ldw  = (lwv[nSpec-1] - lwv[0])/(nSpec-1);
        Real ldw5 = ldw*0.2; // x5 resolution

        err  = zls_NewQuantity1DArr( &wv5, n5 );
        err |= zls_NewQuantity1DArr( &fl5, n5 );
        err |= zls_NewQuantity1DArr( &cn5, n5 );
        err |= zls_NewQuantity1DArr( &nz5, n5 );

        if ( err == noErr ){

            zls_AkimaSpline *gSpline = NULL;
            gSpline = zls_AkimaAlloc(nSpec);

            err = zls_AkimaInit (gSpline, lwv, fl, nSpec); // log x axis
            if ( err != noErr ) {
                return err;
            }

            Real w0 = log(wv[ 0 ]); // log lamdda
                                    //Real w0 = (wv[ 0 ]); // log lamdda
            for (Counter idx = 0; idx < n5; idx++) {
                Real x = w0 + idx*ldw5; // uniform in log space
                wv5 [idx] = x;
                Real y = zls_Akima( gSpline, x);
                fl5 [idx ] = y;
            }

            err = zls_AkimaInit (gSpline, lwv, cn, nSpec);
            if ( err != noErr ) {
                return err;
            }

            for (Counter idx = 0; idx < n5; idx++) {
                Real x = wv5 [idx];
                Real y = zls_Akima( gSpline, x);
                cn5 [idx ] = y;
            }

            err = zls_AkimaInit (gSpline, lwv, nz, nSpec);
            if ( err != noErr ) {
                return err;
            }

            for (Counter idx = 0; idx < n5; idx++) {
                Real x = wv5 [idx];
                Real y = zls_Akima( gSpline, x);
                nz5 [idx ] = y;
            }

            zls_AkimaFree(gSpline); gSpline = NULL;

            /* all specs are x5 and in a uniform log wavelength scale */

            /* convolve with rotation first, then fwhm, then with instrumental resolution */
            /* if resR, fwhm, or vSini <= 0.0 then skip that convolution */

                // do rotation 1st

            if (vSini > 0.0) {

                printf(" Width of Projected Rotation: %#12.5g km/s\n",vSini);

                Real vRes  = C_KMS/vSini;
                Real sigma = log((vRes+vRes+1.0)/(vRes+vRes-1.0));

                err = zls_WRotationalConvolution( wv5, fl5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

                err = zls_WRotationalConvolution( wv5, cn5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

                err = zls_WRotationalConvolution( wv5, nz5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

            }

                // do intrisic gaussian 2nd

            if (fwhm > 0.0) {

                Real gRes = C_KMS/fwhm;
                Real sResR = gRes*2.35482; // FWHM -> sigma
                Real sigma = log((sResR+sResR+1.0)/(sResR+sResR-1.0));

                printf(" FWHM of Gaussian: %#12.5g km/s\n", fwhm);

                err = zls_WGaussianConvolution( wv5, fl5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

                err = zls_WGaussianConvolution( wv5, cn5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

                err = zls_WGaussianConvolution( wv5, nz5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }
                
            }
            

            if ( box > 0.0) {

                Real bRes = C_KMS/box;
                Real sResR = bRes*0.5; // FW  -> 0.5
                Real sigma = log((sResR+sResR+1.0)/(sResR+sResR-1.0));

                printf(" FW of Box: %#12.5g km/s\n", box);

                err = zls_WBoxcarConvolution( wv5, fl5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

                err = zls_WBoxcarConvolution( wv5, cn5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

                err = zls_WBoxcarConvolution( wv5, nz5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }
                
            }
            
                // do instrumental resolving power last

            if ( resR > 0.0 ){

                    // compute sigma in log ratios
                Real sResR = resR*2.35482; // FWHM -> sigma
                Real sigma = log((sResR+sResR+1.0)/(sResR+sResR-1.0));

                printf(" Resolving Power: %#12.5g\n",resR);
                printf(" FWHM of Instrumental Gaussian: %#12.5g km/s\n",C_KMS/resR);
                printf("Sigma of Instrumental Gaussian is: %#12.5g km/s\n",C_KMS/sResR);

                err = zls_WGaussianConvolution( wv5, fl5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

                err = zls_WGaussianConvolution( wv5, cn5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

                err = zls_WGaussianConvolution( wv5, nz5, n5, sigma);
                if ( err != noErr ) {
                    return err;
                }

            }

            /* Convert back to original sampling */

            zls_AkimaSpline *gReSpline = NULL;

            gReSpline = zls_AkimaAlloc(n5);

            err = zls_AkimaInit (gReSpline, wv5, fl5, n5);
            if ( err != noErr ) {
                return err;
            }

            for (Counter idx = 0; idx < nSpec; idx++ ) {
                Real x = lwv [idx];
                Real y = zls_Akima( gReSpline, x);
                fl [idx ] = y;
            }

            err = zls_AkimaInit (gReSpline, wv5, cn5, n5);
            if ( err != noErr ) {
                return err;
            }

            for (Counter idx = 0; idx < nSpec; idx++ ) {
                Real x = lwv [idx];
                Real y = zls_Akima( gReSpline, x);
                cn [idx ] = y;
            }

            err = zls_AkimaInit (gReSpline, wv5, nz5, n5);
            if ( err != noErr ) {
                return err;
            }

            for (Counter idx = 0; idx < nSpec; idx++ ) {
                Real x = lwv [idx];
                Real y = zls_Akima( gReSpline, x);
                nz [idx ] = y;
            }

            zls_AkimaFree(gReSpline); gReSpline = NULL;

            zls_DisposeQuantity1DArr(wv5);
            zls_DisposeQuantity1DArr(fl5);
            zls_DisposeQuantity1DArr(cn5);
            zls_DisposeQuantity1DArr(nz5);

        } // allocated arrays

            // All done, dispose of lwv, and just leave wv untouched.
        zls_DisposeQuantity1DArr(lwv);

    } // alloacted log lambda array

    return (err);
}

int zls_WRotationalConvolution( Q1DArr wv, Q1DArr fl, Counter n, Real sigma) {

    int err = noErr;

        // prepare kernel and then do a direct convolution

    Real w0 = wv[0];
    Real w1 = wv[n-1];

    Real dx = (w1-w0)/(n-1); // actually log lambda

    Real invSigma = 1.0/sigma;

    Real cutoff   = sigma/dx; // number of cells in half the resp
    Counter nResp = 2 * (int)ceil(cutoff) + 1; // always odd

    Integer nResp2 = nResp/2;
    Q1DArr resp = NULL;
    err  = zls_NewQuantity1DArr( &resp, nResp );

    if ( err != noErr ) return err;

    Real epsilon = 0.5;

    Real a1 = 0.0;
    Real a2 = 1.0;

    if (epsilon < 1.0) {
        a1=6.283185307179586; // 2pi
        a2=0.5*epsilon/(1.0-epsilon);
    }

    Real respSum = 0.0; // for normalising

        // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real gm1 = 0.0;
        Real a = (dx*idx - 0.5*dx)*invSigma;
        Real b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            gm1 = 0.0;
        } else {
            gm1 = a1*sqrt(b)+a2*b;//       ! resp = __/\__
        }

        Real g0 = 0.0;
        a = (dx*idx)*invSigma;
        b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            g0 = 0.0;
        } else {
            g0 = a1*sqrt(b)+a2*b; //       ! resp = __/\__
        }

        Real gp1 = 0.0;
        a = (dx*idx + 0.5*dx)*invSigma;
        b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            gp1 = 0.0;
        } else {
            gp1 = a1*sqrt(b)+a2*b; //       ! resp = __/\__
        }

        Real meanG = (gm1 + 4.0*g0 + gp1)/6.0; // 3rd order para quad

        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;

    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }

        // do the convolution

    err = zls_WDirectConvolution  ( fl, resp, n, nResp);

    zls_DisposeQuantity1DArr(resp);

    return err;

}

int zls_WGaussianConvolution  ( Q1DArr wv, Q1DArr fl, Counter n, Real sigma) {

    int err = noErr;

    const Real kNSigma = 6.0; // out to 6 sigma

        // prepare gassian kernel and then do a direct convolution

    Real invSigma = 1.0/sigma;

        // make the gaussian response function

    Real w0 = wv[0];
    Real w1 = wv[n-1];

    Real dx = (w1-w0)/(n-1); // actually log lambda

    Real cutoff = kNSigma*sigma/dx; // number of cells in half the resp
    Counter nResp = 2 * (int)floor(cutoff) + 1; // always odd

    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising

        // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real a = (dx*idx - 0.5*dx)*invSigma;
        Real gm1 = exp(-0.5*a*a);

        a = (dx*idx)*invSigma;
        Real g0 = exp(-0.5*a*a);

        a = (dx*idx + 0.5*dx)*invSigma;
        Real gp1 = exp(-0.5*a*a);

        Real meanG = (gm1 + 4.0*g0 + gp1)/6.0; // 3rd order para quad

        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        resp[ idx + nResp2 ] /= respSum;

    }
        // do the convolution

    err = zls_WDirectConvolution  ( fl, resp, n, nResp);
    
    zls_DisposeQuantity1DArr(resp);
    
    return err;
    
}


int zls_WBoxcarConvolution  ( Q1DArr wv, Q1DArr fl, Counter n, Real sigma) {

    int err = noErr;

    const Real kNSigma = 1.0; // out to 1+/-1 HW

        // prepare gassian kernel and then do a direct convolution
        // make the gaussian response function

    Real w0 = wv[0];
    Real w1 = wv[n-1];

    Real dx = (w1-w0)/(n-1); // actually log lambda

    Real cutoff = kNSigma*sigma/dx; // number of cells in half the resp
    Counter nResp = 2 * (int)floor(cutoff) + 1; // always odd

    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising

        // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real meanG = 1.0;

        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        resp[ idx + nResp2 ] /= respSum;

    }
        // do the convolution

    err = zls_WDirectConvolution  ( fl, resp, n, nResp);
    
    zls_DisposeQuantity1DArr(resp);
    
    return err;
    
}

int zls_WDirectConvolution  ( Q1DArr f, Q1DArr resp, Counter n, Counter nResp) {

    int err = noErr;

        // actual convolution done here, on a single prepared evenly sampled
        // input array, response function is -nResp/2 .. 0 .. nResp/2 ie odd
        // 0..nResp, not 0..nResp-1; resp should be normalised to sum to 1.0
        // for simplicty

    Q1DArr out = NULL;

    err  = zls_NewQuantity1DArr( &out, n );

    if ( err != noErr ) return err;

    for (Integer idx = 0; idx < n; idx++ )
        out[ idx ] = 0.0;

        //
        // response function is centered at idx nResp2:
        // |_/\_||
        //

    Integer nResp2 = nResp/2; // ie -10 - 0 - 10 = 21 bins, on array [0..20]
                              // access : (-nResp2 .. nResp2,  + nResp) % nResp  -> 11..20, 0, 1..10

    for ( Integer jdx =-nResp2; jdx <=nResp2; jdx++ ) { // resp loop
        for (Integer idx = 0; idx < nResp2; idx++ ) { // input loop, first half of resp

            Integer l = idx + jdx;
            l = (l < 0)?(-l):(l); // reflection

            Integer kdx = (jdx + nResp2);
            out[idx] += f[l]*resp[kdx];
            
        }
    }
    
    for ( Integer jdx =-nResp2; jdx <=nResp2; jdx++ ) { // resp loop
        for (Integer idx = nResp2; idx < n-nResp2; idx++ ) { // middle input loop
            
            Integer kdx = (jdx + nResp2);
            out[ idx ] += f[idx+jdx]*resp[kdx];
            
        }
    }
    
    for ( Integer jdx = -nResp2; jdx <= nResp2; jdx++ ) { // resp loop
        for (Integer idx = n-nResp2; idx < n; idx++ ) { // input loop, last half of resp
            
            Integer  l=idx+jdx;
            l = (l >= n)?(2*n-l-2):l; // reflection, jump -1 past last cell
            
            Integer kdx = (jdx + nResp2);
            out[ idx ] += f[l]*resp[kdx];
            
        }
    }
    
    for (Integer idx = 0; idx < n; idx++ )
        f[ idx ] = out[ idx ];
    
    zls_DisposeQuantity1DArr(out); out = NULL;
    
    return err;
    
}


// inverse of oversampling factor
static const Real os = (1.0/5.0);

int zls_ResampleXYData( Q1DArr *rx, Q1DArr *ry, Counter *nuni, Q1DArr x, Q1DArr y, Counter n );
int zls_ResampleXYData( Q1DArr *rx, Q1DArr *ry, Counter *nuni, Q1DArr x, Q1DArr y, Counter n ){

    int err = noErr;

    //
    // cvt to uniform x coordinates
    //

    Real w0 = x[0];
    Real w1 = x[n-1];

    Real dx = os*(x[1]-x[0]);
    // find minimum step
    Real lx0 = x[0];
    for (Counter idx = 1; idx < n; idx++) {
        Real lx1 = x[ idx ];
        Real ddx = os*(lx1-lx0);
        dx = (ddx < dx)?ddx:dx;
        lx0 = lx1;
    }

    Counter nu = (int)round((w1-w0)/dx);

    Q1DArr lx  = NULL; // linear steps in log x
    err  = zls_NewQuantity1DArr( &lx, nu );
    for (Counter idx = 0; idx < nu; idx++) {
        lx[ idx ] = w0 + idx*dx; // uniform log steps
    }
    Q1DArr ly = NULL;
    err  = zls_NewQuantity1DArr( &ly, nu );

    zls_AkimaSpline gSpline = zls_AkimaAlloc(n);
    err = zls_AkimaInit (gSpline, x, y, n);
    if ( err != noErr ) {
        return err;
    }
    for (Counter idx = 0; idx < nu; idx++) {
        Real x0 = lx[idx] ; // uniform x steps
        Real y0 = zls_Akima( gSpline, x0);
        ly [ idx ] = y0;
    }
    zls_AkimaFree(gSpline); gSpline = NULL;

    *rx = lx;
    *ry = ly;
    *nuni = nu;

    return err;
    
}

int zls_DesampleYData( Q1DArr *y, Q1DArr x, Counter n, Q1DArr rx, Q1DArr ry, Counter nuni );
int zls_DesampleYData( Q1DArr *y, Q1DArr x, Counter n, Q1DArr rx, Q1DArr ry, Counter nuni ){

    int err = noErr;

    Q1DArr ly = NULL;
    err  = zls_NewQuantity1DArr( &ly, n );
    zls_AkimaSpline gSpline = zls_AkimaAlloc(nuni);
    err = zls_AkimaInit (gSpline, rx, ry, nuni);
    if ( err != noErr ) {
        return err;
    }
    for (Counter idx = 0; idx < n; idx++) {

        Real x0 = x[ idx ]; // original steps in normal space
        Real y0 = zls_Akima( gSpline, x0);
        ly[idx] = y0;
    }
    zls_AkimaFree(gSpline); gSpline = NULL;

    *y = ly;

    return err;

}

int zls_RotConvolution  ( Q1DArr * cnv, Q1DArr y, Counter n, Real nbins ) {

    int err = noErr;

    Real dx       = 1.0; // bin
    Real fullWidth    = nbins*dx; // number of cells in the resp
    Real invW = 1.0/fullWidth;

    //
    // make the response function
    //

    Counter nResp = 2 * (int)ceil(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real epsilon  = 0.5;
    const Real a1 = 6.283185307179586; // 2pi
    Real a2 = 1.0;
    if (epsilon < 1.0) a2=0.5*epsilon/(1.0-epsilon);

    Real respSum = 0.0; // for normalising

    // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real gm1 = 0.0;
        Real a = (dx*idx - 0.5*dx)*invW;
        Real b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            gm1 = 0.0;
        } else {
            gm1 = a1*sqrt(b)+a2*b;//       ! resp = __/\__
        }

        Real g0 = 0.0;
        a = (dx*idx)*invW;
        b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            g0 = 0.0;
        } else {
            g0 = a1*sqrt(b)+a2*b; //       ! resp = __/\__
        }

        Real gp1 = 0.0;
        a = (dx*idx + 0.5*dx)*invW;
        b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            gp1 = 0.0;
        } else {
            gp1 = a1*sqrt(b)+a2*b; //       ! resp = __/\__
        }

        Real meanG = (gm1 + 4.0*g0 + gp1)/6.0; // 3rd order para quad
        
        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
        
    }
    
    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }
    // do the convolution

    err = zls_DirectConvolution  ( cnv, y, resp, n, nResp);

    zls_DisposeQuantity1DArr(resp);
    
    return err;
    
}

int zls_RotXConvolution ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth) {

    int err = noErr;

    //
    // prepare kernel and then do a direct convolution
    // make the response function
    // resamples to spacing in log space
    //

    Real invW = 1.0/fullWidth;

    //
    // cvt to uniform x coordinates
    //

    Q1DArr rx = NULL;
    Q1DArr ry = NULL;
    Counter nuni;

    // resample uniformly

    err = zls_ResampleXYData( &rx, &ry, &nuni, x, y, n );
    if ( err != noErr) return err;

    Real dx = (rx[1] - rx[0]); // ok as rx is uniformly spaced

    Real nbins = fullWidth/dx; // number of bins in full width
    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real epsilon = 0.5;
    const Real a1 = 6.283185307179586; // 2pi
    Real a2 = 1.0;
    if (epsilon < 1.0) a2=0.5*epsilon/(1.0-epsilon);

    Real respSum = 0.0; // for normalising

    // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real gm1 = 0.0;
        Real a = (dx*idx - 0.5*dx)*invW;
        Real b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            gm1 = 0.0;
        } else {
            gm1 = a1*sqrt(b)+a2*b;//       ! resp = __/\__
        }

        Real g0 = 0.0;
        a = (dx*idx)*invW;
        b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            g0 = 0.0;
        } else {
            g0 = a1*sqrt(b)+a2*b; //       ! resp = __/\__
        }

        Real gp1 = 0.0;
        a = (dx*idx + 0.5*dx)*invW;
        b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            gp1 = 0.0;
        } else {
            gp1 = a1*sqrt(b)+a2*b; //       ! resp = __/\__
        }

        Real meanG = (gm1 + 4.0*g0 + gp1)/6.0; // 3rd order para quad

        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
        
    }
    
    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }

    // do the convolution

    Q1DArr rc = NULL;
    err = zls_DirectConvolution  ( &rc, ry, resp, nuni, nResp);
    if ( err != noErr) return err;

    // desample back to original spacings

    Q1DArr oy = NULL;
    err = zls_DesampleYData( &oy, x, n, rx, rc, nuni );
    if ( err != noErr) return err;

    zls_DisposeQuantity1DArr(rc);
    zls_DisposeQuantity1DArr(rx);
    zls_DisposeQuantity1DArr(ry);
    zls_DisposeQuantity1DArr(resp);

    *cnv = oy;

    return err;

}

int zls_RotLogXConvolution ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real res) {

    int err = noErr;

    //
    // prepare kernel and then do a direct convolution
    // make the response function
    // resamples to spacing in log space
    //

    //Real invW = 1.0/fullWidth;

    Q1DArr lx   = NULL; // log of x, not uniform in log space
    err  = zls_NewQuantity1DArr( &lx, n );
    for (Counter idx = 0; idx < n; idx++) {
        lx[idx]  = log(x[idx]); // original, possibly uneven steps
    }
    //
    // cvt to uniform x coordinates
    //

    Q1DArr rx = NULL;
    Q1DArr ry = NULL;
    Counter nuni;

    // resample uniformly

    err = zls_ResampleXYData( &rx, &ry, &nuni, lx, y, n );
    if ( err != noErr) return err;

    Real dx = (rx[1] - rx[0]); // ok as rx is uniformly spaced

    // make the  response function

    Real sResR    = res;//(0.5*(x[0]+x[n-1]))/fullWidth; /// resolving power
    Real sigma    = log((sResR+sResR+1.0)/(sResR+sResR-1.0));
    Real invSigma = 1.0/sigma;

    Real nbins = sigma/dx; // number of bins in full width
    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real epsilon = 0.5;
    const Real a1 = 6.283185307179586; // 2pi
    Real a2 = 1.0;
    if (epsilon < 1.0) a2=0.5*epsilon/(1.0-epsilon);

    Real respSum = 0.0; // for normalising

    // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real gm1 = 0.0;
        Real a = (dx*idx - 0.5*dx)*invSigma;
        Real b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            gm1 = 0.0;
        } else {
            gm1 = a1*sqrt(b)+a2*b;//       ! resp = __/\__
        }

        Real g0 = 0.0;
        a = (dx*idx)*invSigma;
        b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            g0 = 0.0;
        } else {
            g0 = a1*sqrt(b)+a2*b; //       ! resp = __/\__
        }

        Real gp1 = 0.0;
        a = (dx*idx + 0.5*dx)*invSigma;
        b = 1.0-(a*a);

        if ( b <= 0.0 ) {
            gp1 = 0.0;
        } else {
            gp1 = a1*sqrt(b)+a2*b; //       ! resp = __/\__
        }

        Real meanG = (gm1 + 4.0*g0 + gp1)/6.0; // 3rd order para quad

        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
        
    }
    
    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }

    // do the convolution

    Q1DArr rc = NULL;
    err = zls_DirectConvolution  ( &rc, ry, resp, nuni, nResp);
    if ( err != noErr) return err;

    // desample back to original spacings

    Q1DArr oy = NULL;
    err = zls_DesampleYData( &oy, lx, n, rx, rc, nuni );
    if ( err != noErr) return err;

    zls_DisposeQuantity1DArr(lx);
    zls_DisposeQuantity1DArr(rc);
    zls_DisposeQuantity1DArr(rx);
    zls_DisposeQuantity1DArr(ry);
    zls_DisposeQuantity1DArr(resp);
    
    *cnv = oy;
    
    return err;
    
}



int zls_GaussianConvolution  ( Q1DArr * cnv, Q1DArr y, Counter n, Real nbins ) {

    int err = noErr;

    const Real kNSigma = 6.0; // out to 6 sigma

    Real dx = 1.0; // bin

        // prepare gassian kernel and then do a direct convolution
    Real sigma     = 2.35482*nbins*dx/kNSigma;
    Real invSigma  = 1.0/sigma;

    Real cutoff    = kNSigma*sigma/dx; // number of cells in half the resp
    Counter nResp  = 2 * (int)floor(cutoff) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising

        // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real a = (dx*idx - 0.5*dx)*invSigma;
        Real gm1 = exp(-0.5*a*a);

        a = (dx*idx)*invSigma;
        Real g0 = exp(-0.5*a*a);

        a = (dx*idx + 0.5*dx)*invSigma;
        Real gp1 = exp(-0.5*a*a);

        Real meanG = (gm1 + 4.0*g0 + gp1)/6.0; // 3rd order para quad

        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        resp[ idx + nResp2 ] /= respSum;

    }
        // do the convolution

    err = zls_DirectConvolution  ( cnv, y, resp, n, nResp);
    
    zls_DisposeQuantity1DArr(resp);
    
    return err;
    
}

int zls_GaussianXConvolution  ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth) {

    int err = noErr;

    const Real kNSigma = 6.0; // out to 6 sigma

    //
    // cvt to uniform x coordinates
    //

    Q1DArr rx = NULL;
    Q1DArr ry = NULL;
    Counter nuni;

    // resample uniformly

    err = zls_ResampleXYData( &rx, &ry, &nuni, x, y, n );
    if ( err != noErr) return err;

    Real dx = (rx[1] - rx[0]); // ok as rx is uniformly spaced

    Real nbins = fullWidth/dx; // number of bins in full width

    Real sigma    = 2.35482*nbins*dx/kNSigma; // number of cells in half the resp
    Real invSigma = 1.0/sigma;

    Real cutoff   = kNSigma*sigma/dx; // number of cells
    Counter nResp = 2 * (int)floor(cutoff) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising

    // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real a = (dx*idx - 0.5*dx)*invSigma;
        Real gm1 = exp(-0.5*a*a);

        a = (dx*idx)*invSigma;
        Real g0 = exp(-0.5*a*a);

        a = (dx*idx + 0.5*dx)*invSigma;
        Real gp1 = exp(-0.5*a*a);

        Real meanG = (gm1 + 4.0*g0 + gp1)/6.0; // 3rd order para quad

        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        resp[ idx + nResp2 ] /= respSum;

    }

    // do the convolution

    Q1DArr rc = NULL;
    err = zls_DirectConvolution  ( &rc, ry, resp, nuni, nResp);
    if ( err != noErr) return err;

    // desample back to original spacings

    Q1DArr oy = NULL;
    err = zls_DesampleYData( &oy, x, n, rx, rc, nuni );
    if ( err != noErr) return err;

    zls_DisposeQuantity1DArr(rc);
    zls_DisposeQuantity1DArr(rx);
    zls_DisposeQuantity1DArr(ry);
    zls_DisposeQuantity1DArr(resp);

    *cnv = oy;
    
    return err;

}


int zls_GaussianLogXConvolution  ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real res ) {

    int err = noErr;

    const Real kNSigma = 6.0; // out to 6 sigma

    Q1DArr lx   = NULL; // log of x, not uniform in log space
    err  = zls_NewQuantity1DArr( &lx, n );
    for (Counter idx = 0; idx < n; idx++) {
        lx[idx]  = log(x[idx]); // original, possibly uneven steps
    }

    //
    // cvt to uniform x coordinates
    //

    Q1DArr rx = NULL;
    Q1DArr ry = NULL;
    Counter nuni;

    // resample uniformly

    err = zls_ResampleXYData( &rx, &ry, &nuni, lx, y, n );
    if ( err != noErr) return err;

    Real dx = (rx[1] - rx[0]); // ok as rx is uniformly spaced

    Real sResR    = res; //(x[0]+x[n-1])/fullWidth; /// resolving power
    Real sigma    = log((sResR+sResR+1.0)/(sResR+sResR-1.0));
    Real invSigma = 1.0/sigma;

    Real nbins = kNSigma*sigma/dx; // number of bins in full width
    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising

    // 3rd order quadrature averaging:

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){

        Real a = (dx*idx - 0.5*dx)*invSigma;
        Real gm1 = exp(-0.5*a*a);

        a = (dx*idx)*invSigma;
        Real g0 = exp(-0.5*a*a);

        a = (dx*idx + 0.5*dx)*invSigma;
        Real gp1 = exp(-0.5*a*a);

        Real meanG = (gm1 + 4.0*g0 + gp1)/6.0; // 3rd order para quad

        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }

    // do the convolution

    Q1DArr rc = NULL;
    err = zls_DirectConvolution  ( &rc, ry, resp, nuni, nResp );
    if ( err != noErr) return err;

    // desample back to original spacings

    Q1DArr oy = NULL;
    err = zls_DesampleYData( &oy, lx, n, rx, rc, nuni );
    if ( err != noErr) return err;

    zls_DisposeQuantity1DArr(lx);
    zls_DisposeQuantity1DArr(rc);
    zls_DisposeQuantity1DArr(rx);
    zls_DisposeQuantity1DArr(ry);
    zls_DisposeQuantity1DArr(resp);
    
    *cnv = oy;
    
    return err;
    
}

int zls_BoxcarConvolution  ( Q1DArr * cnv, Q1DArr y, Counter n, Real nbins ) {

    int err = noErr;

    //
    // prepare box kernel and then do a direct convolution
    // make the box response function
    //

    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        Real meanG = 1.0;
        resp[ idx + nResp2 ] = meanG;
        respSum += meanG;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }
    // do the convolution

    err = zls_DirectConvolution  ( cnv, y, resp, n, nResp);
    
    zls_DisposeQuantity1DArr(resp);
    
    return err;
    
}

int zls_BoxcarXConvolution ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth) {

    int err = noErr;

    //
    // prepare kernel and then do a direct convolution
    // make the response function
    // resamples to uniform spacing
    //

    //
    // cvt to uniform x coordinates
    //

    Q1DArr rx = NULL;
    Q1DArr ry = NULL;
    Counter nuni;

    // resample uniformly

    err = zls_ResampleXYData( &rx, &ry, &nuni, x, y, n );
    if ( err != noErr) return err;

    Real dx = (rx[1] - rx[0]); // ok as rx is uniformly spaced

    Real nbins = fullWidth/dx; // number of bins in full width
    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    // make the  response function

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] = 1.0;
        respSum += 1.0;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }

    // do the convolution

    Q1DArr rc = NULL;
    err = zls_DirectConvolution  ( &rc, ry, resp, nuni, nResp);
    if ( err != noErr) return err;

    // desample back to original spacings

    Q1DArr oy = NULL;
    err = zls_DesampleYData( &oy, x, n, rx, rc, nuni );
    if ( err != noErr) return err;

    zls_DisposeQuantity1DArr(rc);
    zls_DisposeQuantity1DArr(rx);
    zls_DisposeQuantity1DArr(ry);
    zls_DisposeQuantity1DArr(resp);

    *cnv = oy;

    return err;

}

int zls_BoxcarLogXConvolution ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real res) {

    int err = noErr;

    //
    // prepare kernel and then do a direct convolution
    // make the response function
    // resamples to spacing in log space
    //

    Q1DArr lx   = NULL; // log of x, not uniform in log space
    err  = zls_NewQuantity1DArr( &lx, n );
    for (Counter idx = 0; idx < n; idx++) {
        lx[idx]  = log(x[idx]); // original, possibly uneven steps
    }
    //
    // cvt to uniform x coordinates
    //

    Q1DArr rx = NULL;
    Q1DArr ry = NULL;
    Counter nuni;

    // resample uniformly

    err = zls_ResampleXYData( &rx, &ry, &nuni, lx, y, n );
    if ( err != noErr) return err;

    Real dx = (rx[1] - rx[0]); // ok as rx is uniformly spaced

    // make the  response function

    Real sResR    = res; //(0.5*(x[0]+x[n-1]))/fullWidth; /// resolving power
    Real sigma    = log((sResR+sResR+1.0)/(sResR+sResR-1.0));

    Real nbins = sigma/dx; // number of bins in full width
    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] = 1.0;
        respSum += 1.0;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }

    // do the convolution

    Q1DArr rc = NULL;
    err = zls_DirectConvolution  ( &rc, ry, resp, nuni, nResp);
    if ( err != noErr) return err;

    // desample back to original spacings

    Q1DArr oy = NULL;
    err = zls_DesampleYData( &oy, lx, n, rx, rc, nuni );
    if ( err != noErr) return err;

    zls_DisposeQuantity1DArr(lx);
    zls_DisposeQuantity1DArr(rc);
    zls_DisposeQuantity1DArr(rx);
    zls_DisposeQuantity1DArr(ry);
    zls_DisposeQuantity1DArr(resp);
    
    *cnv = oy;
    
    return err;

}

int zls_TricarConvolution  ( Q1DArr * cnv, Q1DArr y, Counter n, Real nbins) {

    int err = noErr;

    //
    // prepare box kernel and then do a direct convolution
    // make the box response function
    //

    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;
    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising
    Real dy = 1.0/(nResp2+1);

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        Real yresp = (idx + nResp2 + 1) * dy;
        yresp = (yresp>1.0)?2.0-yresp:yresp;
        yresp = (yresp<0.0)?0.0:yresp;
        resp[ idx + nResp2 ] = yresp;
        respSum += yresp;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }
    // do the convolution

    err = zls_DirectConvolution  ( cnv, y, resp, n, nResp);

    zls_DisposeQuantity1DArr(resp);

    return err;

}

int zls_TricarXConvolution ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real fullWidth) {

    int err = noErr;

    //
    // prepare kernel and then do a direct convolution
    // make the response function
    // resamples to uniform spacing
    //

    //
    // cvt to uniform x coordinates
    //

    Q1DArr rx = NULL;
    Q1DArr ry = NULL;
    Counter nuni;

    // resample uniformly to 0.25*smallest bin

    err = zls_ResampleXYData( &rx, &ry, &nuni, x, y, n);
    if ( err != noErr) return err;

    Real dx = (rx[1] - rx[0]); // ok as rx is uniformly spaced

    Real nbins = fullWidth/dx; // number of bins in full width
    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    // make the  response function

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising
    Real dy = 1.0/(nResp2+1);

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        Real yresp = (idx + nResp2 + 1) * dy;
        yresp = (yresp>1.0)?2.0-yresp:yresp;
        yresp = (yresp<0.0)?0.0:yresp;
        resp[ idx + nResp2 ] = yresp;
        respSum += yresp;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }

    // do the convolution

    Q1DArr rc = NULL;
    err = zls_DirectConvolution  ( &rc, ry, resp, nuni, nResp);
    if ( err != noErr) return err;

    // desample back to original spacings

    Q1DArr oy = NULL;
    err = zls_DesampleYData( &oy, x, n, rx, rc, nuni );
    if ( err != noErr) return err;

    zls_DisposeQuantity1DArr(rc);
    zls_DisposeQuantity1DArr(rx);
    zls_DisposeQuantity1DArr(ry);
    zls_DisposeQuantity1DArr(resp);
    
    *cnv = oy;
    
    return err;

}

int zls_TricarLogXConvolution ( Q1DArr * cnv, Q1DArr x, Q1DArr y, Counter n, Real res) {

    int err = noErr;

    //
    // prepare kernel and then do a direct convolution
    // make the response function
    // resamples to spacing in log space
    //

    Q1DArr lx   = NULL; // log of x, not uniform in log space
    err  = zls_NewQuantity1DArr( &lx, n );
    for (Counter idx = 0; idx < n; idx++) {
        lx[idx]  = log(x[idx]); // original, possibly uneven steps
    }
    //
    // cvt to uniform x coordinates
    //

    Q1DArr rx = NULL;
    Q1DArr ry = NULL;
    Counter nuni;

    // resample uniformly

    err = zls_ResampleXYData( &rx, &ry, &nuni, lx, y, n );
    if ( err != noErr) return err;

    Real dx = (rx[1] - rx[0]); // ok as rx is uniformly spaced

    // make the  response function

    Real sResR    = res; //(0.5*(x[0]+x[n-1]))/fullWidth; /// resolving power
    Real sigma    = log((sResR+sResR+1.0)/(sResR+sResR-1.0));

    Real nbins = sigma/dx; // number of bins in full width
    Counter nResp = 2 * (int)floor(0.5*nbins) + 1; // always odd
    Integer nResp2 = nResp/2;

    Q1DArr resp = NULL;

    err  = zls_NewQuantity1DArr( &resp, nResp );
    if ( err != noErr ) return err;

    Real respSum = 0.0; // for normalising
    Real dy = 1.0/(nResp2+1);

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        Real yresp = (idx + nResp2 + 1) * dy;
        yresp = (yresp>1.0)?2.0-yresp:yresp;
        yresp = (yresp<0.0)?0.0:yresp;
        resp[ idx + nResp2 ] = yresp;
        respSum += yresp;
    }

    for (Integer idx = -nResp2; idx <= nResp2; idx++ ){
        resp[ idx + nResp2 ] /= respSum;
    }

    // do the convolution

    Q1DArr rc = NULL;
    err = zls_DirectConvolution  ( &rc, ry, resp, nuni, nResp);
    if ( err != noErr) return err;

    // desample back to original spacings

    Q1DArr oy = NULL;
    err = zls_DesampleYData( &oy, lx, n, rx, rc, nuni );
    if ( err != noErr) return err;

    zls_DisposeQuantity1DArr(lx);
    zls_DisposeQuantity1DArr(rc);
    zls_DisposeQuantity1DArr(rx);
    zls_DisposeQuantity1DArr(ry);
    zls_DisposeQuantity1DArr(resp);
    
    *cnv = oy;
    
    return err;

}

int zls_DirectConvolution  ( Q1DArr *cnv, Q1DArr f, Q1DArr resp, Counter n, Counter nResp) {

    int err = noErr;

        // actual convolution done here, on a single prepared evenly sampled
        // input array, response function is -nResp/2 .. 0 .. nResp/2 ie odd
        // 0..nResp, not 0..nResp-1; resp should be normalised to sum to 1.0
        // for simplicty
        //
        // output in cnv array, allocated here
        //

    *cnv = NULL;

    Q1DArr c = NULL;

    err  = zls_NewQuantity1DArr( &c, n );

    if ( err != noErr ) return err;

    for (Integer idx = 0; idx < n; idx++ )

        c[ idx ] = 0.0;

        //
        // response function is centered at idx nResp2:
        // |_/\_||
        //

    Integer nResp2 = nResp/2; // ie -10 - 0 - 10 = 21 bins, on array [0..20]
                              // access : (-nResp2 .. nResp2,  + nResp) % nResp  -> 11..20, 0, 1..10

    for ( Integer jdx =-nResp2; jdx <=nResp2; jdx++ ) { // resp loop
        for (Integer idx = 0; idx < nResp2; idx++ ) { // input loop, first half of resp

            Integer l = idx + jdx;
            l = (l < 0)?(-l):(l); // reflection

            Integer kdx = (jdx + nResp2);
            c[idx] += f[l]*resp[kdx];
            
        }
    }
    
    for ( Integer jdx =-nResp2; jdx <=nResp2; jdx++ ) { // resp loop
        for (Integer idx = nResp2; idx < n-nResp2; idx++ ) { // middle input loop
            
            Integer kdx = (jdx + nResp2);
            c[ idx ] += f[idx+jdx]*resp[kdx];
            
        }
    }
    
    for ( Integer jdx = -nResp2; jdx <= nResp2; jdx++ ) { // resp loop
        for (Integer idx = n-nResp2; idx < n; idx++ ) { // input loop, last half of resp
            
            Integer  l=idx+jdx;
            l = (l >= n)?(2*n-l-2):l; // reflection, jump -1 past last cell
            
            Integer kdx = (jdx + nResp2);
            c[ idx ] += f[l]*resp[kdx];
            
        }
    }
    
//    for (Integer idx = 0; idx < n; idx++ )
//        f[ idx ] = out[ idx ];
//    
//    zls_DisposeQuantity1DArr(out); out = NULL;

    *cnv = c;

    return err;
    
}

