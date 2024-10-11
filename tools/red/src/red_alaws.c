//
//  red_alaws.c
//
//  Created by Ralph Sutherland on 12/01/2015.
//
//  v1.0.8
//
#include "red_alaws.h"

static const Real kLambdaHbeta = 4861.333; // NIST ASD Std Air

/*
* ======================================================================
* General Functions, use ID to call selected function.
* Below these is the same API re-written for each reddening function
* so that they all have the same calling format. You can use the general
* or specific API calls as required.
* ======================================================================
*/

#pragma mark - GENERIC

/**
* @brief The function int function red_PrintType(redID)
* Display reddening chosen on commandline
* @param [in]   Integer         redID  ID of Reddening Function
* @return [out]  int            err   always noErr with default CCM89 if fails
* @details
* Simple switch to display curve chosen or CCM89 by default.
*/
int red_PrintType  (Integer redID ){

    int err = noErr;

    switch (redID) {
        case 0:
            printf(" CCM89 Reddening\n");
            break;
        case 1:
            printf(" Blagrave 2007 Orion modified CCM89 Reddening\n");
            break;
        case 2:
            printf(" Fitzpatrick 1999 Reddening\n");
            break;
        case 3:
            printf(" Fitzpatrick  & Massa 2007 Reddening\n");
            break;
        case 4:
            printf(" Calzetti 2000 Reddening\n");
            break;
        case 5:
            printf(" Fischera 2005 Av=1.0 Reddening\n");
            break;
        case 6:
            printf(" Piembert Orion Rv=5.5 1970 Reddening\n");
            break;
        case 7:
            printf(" VCG 2004 UV only modified CCM89 + 2014 corr.\n");
            break;

        default:
            printf(" CCM89 Reddening\n");
            break;
    }
    return err;
}

#pragma mark - Scalar Functions

  //***************************************************************
  //! @brief The function int function fred_AlAV(redID)
  //! Std interface to Alambda/AV for all curves
  //! @param [in]   Real         Rv         Function Rv value
  //! @param [in]   Real         lambda     Wavelength lambda (A) where it is evaluated
  //! @param [in]    Integer      id        Reddening Function ID
  //! @return [out]  Real         AlAV      Al/AV Exctinction ratio to AV in Mag
  //! @details
  //!  Std interface to Alambda/AV for all curves given curve if
  //****************************************************************

Real fred_AlAV   ( Real Rv, Real lambda , Integer id){

    switch (id) {
        case 0:
            return fred_AlAV_CCM89( Rv, lambda );
            break;
        case 1:
            return fred_AlAV_B07( Rv, lambda );
            break;
        case 2:
            return fred_AlAV_F99( Rv, lambda );
            break;
        case 3:
            return fred_AlAV_FM07( Rv, lambda );
            break;
        case 4:
            return fred_AlAV_C00( Rv, lambda );
            break;
        case 5:
            return fred_AlAV_FD05( Rv, lambda );
            break;
        case 6: // no P70 function
            break;
        case 7:
            return fred_AlAV_VCG04( Rv, lambda );
            break;

        default:
            return fred_AlAV_CCM89( Rv, lambda );
            break;
    }

    return 0.0;

}// Al/AV


Real fred_AlEBmV ( Real Rv, Real lambda , Integer id){
        // Al/E(B-V) = (Al/AV - 1.0)*Rv + Rv
    Real AlEBmV = fred_AlAV(Rv, lambda, id) - 1.0;
    AlEBmV *= Rv; // E(l-V)/E(B-V)
    AlEBmV += Rv; // Al/(AB-AV)
    return AlEBmV;
}// Al/E(B-V)


Real fred_ElmVEBmV ( Real Rv, Real lambda , Integer id){
        // FM99 normalisation E(l-V)/E(B-V)
        // E(l-V)/E(B-V) = Al/E(B-V)- Rv
    Real ElvEBmV = fred_AlEBmV (Rv, lambda, id) - Rv;
    return ElvEBmV;
}


Real fred_Fl_RV  ( Real Rv, Real lambda , Integer id){

    switch (id) {
        case 0:
            return fred_Fl_RV_CCM89( Rv, lambda );
            break;
        case 1:
            return fred_Fl_RV_B07  ( Rv, lambda );
            break;
        case 2:
            return fred_Fl_RV_F99  ( Rv, lambda );
            break;
        case 3:
            return fred_Fl_RV_FM07 ( Rv, lambda );
            break;
        case 4:
            return fred_Fl_RV_C00  ( Rv, lambda );
            break;
        case 5:
            return fred_Fl_RV_FD05  ( Rv, lambda );
            break;
        case 6:
            return fred_Fl_RV_P70  ( lambda );
            break;
        case 7:
            return fred_Fl_RV_VCG04  ( Rv, lambda );
            break;

        default:
            return fred_Fl_RV_CCM89( Rv, lambda );
            break;
    }

    return 0.0;

}// F(l)

#pragma mark - Array Functions

    // Al/AV, Al/E(B-V) or F(l) functions of Rv only
    // A(l)/A(V)
int red_AlAV( Real * A, Real Rv, Real * wave, Integer n, Integer id){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam     = wave[ idx ];
        A[idx]  = fred_AlAV( Rv, lam, id);
    }
    return err;
}

int red_AlEBmV( Real * A, Real Rv, Real * wave, Integer n, Integer id){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_AlEBmV(Rv, lam, id); // returns Al/E(B-V)
    }
    return err;
}

int red_ElmVEBmV( Real * A, Real Rv, Real * wave, Integer n, Integer id){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_ElmVEBmV(Rv, lam, id); // returns E(l-V)/E(B-V)
    }
    return err;
}

int red_Fl_RV( Real * F_l, Real Rv, Real * wave, Integer n, Integer id){
    int err = noErr;
        //f(l) = (Al/AV)/(AHb/AV) - 1, get 1/(AHb/AV) for multiplying...
    Real invAHbeta_Av = 1.0/fred_AlAV( Rv, kLambdaHbeta, id); // Hbeta, 1 call
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        Real AlAv = fred_AlAV( Rv, lam , id);;
        F_l[idx]  = (AlAv*invAHbeta_Av) - 1.0;
    }
    return err;
}

#pragma mark - Absolute Functions

int red_Al_RVAV( Real * A_l, Real Rv, Real Av, Real * wave, Integer n, Integer id){
    int err = noErr;
    Real EBmV = Av/Rv;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV(Rv, lam, id) * EBmV;
    }
    return err;
}

int red_Al_RVEBmV( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n, Integer id){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV(Rv, lam, id) * EBmV;
    }
    return err;
}
/*
 ======================================================================
 END General Functions, use ID to call selected function
 ======================================================================
 */

/*
 ======================================================================
 Specific Reddening Functions, using same API form
 ======================================================================
 */

/*
 ======================================================================
 Cardelli Clayton and Mathis 1989 stellar functions
 ======================================================================
 */
#pragma mark - CCM89

static inline Real Fa_CCM89( Real x );
static inline Real Fa_CCM89( Real x ) {
    Real x0 = (x-5.9);
    Real fa = (x0<0.0)?0.0:(-x0*x0*(0.04473 + x0*0.009779));
    return fa;
}

static inline Real Fb_CCM89( Real x );
static inline Real Fb_CCM89( Real x ) {
    Real x0 = (x-5.9);
    Real fb = (x0<0.0)?0.0:(x0*x0*(0.2103 + x0*0.1207));
    return fb;
}

#pragma mark -

    // A(l)/A(V), fundamental for CCM89
Real fred_AlAV_CCM89   ( Real Rv, Real lambda ){
        // Al_AV = a(x) + b(x)/Rv;
    Real x = 1.0e4/lambda; // 1/ microns
    Real y = 0.0;
    Real a = 0.0;
    Real b = 0.0;

    if ( x <= 1.1 ) { //continue below 0.3 for simplicty x -> 0
                      // IR
        a =  0.574*pow(x, 1.61);
        b = -0.527*pow(x, 1.61);

    } else if ( x <= 3.3 ) {
            // Optical NIR
        Real y = (x - 1.82);
        a = 1.0+y*(0.17699
                   +y*(-0.50447
                       +y*(-0.02427
                           +y*(0.72085
                               +y*(0.01979
                                   +y*(-0.77530
                                       +y*0.32999))))));
        b = y*(1.41338
               +y*(2.28305
                   +y*(1.07233
                       +y*(-5.38434
                           +y*(-0.62251
                               +y*(5.30260
                                   -y*2.09002))))));

    } else if ( x <= 8.0 ) {
            // UV and FUV
        Real xa = (x-4.67);
        Real xb = (x-4.62);
        a = ( 1.752-0.316*x)-(0.104/(0.341+xa*xa)) + Fa_CCM89(x);
        b = (-3.090+1.825*x)+(1.206/(0.263+xb*xb)) + Fb_CCM89(x);
    }

    Real Al_Av = a + b/Rv;

    return Al_Av;

}

    // calls above
Real fred_AlEBmV_CCM89 ( Real Rv, Real lambda ){
        // Al/E(B-V) = (Al/AV - 1.0)*Rv + Rv
    Real AlEBmV = fred_AlAV_CCM89(Rv, lambda) - 1.0;
    AlEBmV *= Rv; // E(l-V)/E(B-V)
    AlEBmV += Rv; // Al/(AB-AV)
    return AlEBmV;
}

Real fred_ElmVEBmV_CCM89( Real Rv, Real lambda ){
        // FM99 normalisation E(l-V)/E(B-V)
        // E(l-V)/E(B-V) = Al/E(B-V)- Rv
  printf("fred_ElmVEBmV_CCM89\n");
  Real ElvEBmV = fred_AlEBmV_CCM89(Rv, lambda) - Rv;
    return ElvEBmV;
}

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_CCM89  ( Real Rv, Real lambda ){
    Real invAHbeta_Av = 1.0/fred_AlAV_CCM89( Rv, kLambdaHbeta );
    Real AlAv = fred_AlAV_CCM89( Rv, lambda );
    return (AlAv*invAHbeta_Av) - 1.0;
}

#pragma mark -
    // Array routines
    // A(l)/A(V)
int red_AlAV_CCM89( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam     = wave[ idx ];
        A[idx]  = fred_AlAV_CCM89( Rv, lam );
    }
    return err;
}

int red_AlEBmV_CCM89( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_AlEBmV_CCM89(Rv, lam); // returns Al/E(B-V)
    }
    return err;
}

int red_ElmVEBmV_CCM89( Real * E, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        E[idx] = fred_ElmVEBmV_CCM89(Rv, lam);
    }
    return err;
}

int red_Fl_RV_CCM89( Real * F_l, Real Rv, Real * wave, Integer n ){
    int err = noErr;
        //f(l) = (Al/AV)/(AHb/AV) - 1, get 1/(AHb/AV) for multiplying...
    Real invAHbeta_Av = 1.0/fred_AlAV_CCM89( Rv, kLambdaHbeta ); // Hbeta, 1 call
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        Real AlAv = fred_AlAV_CCM89( Rv, lam );
        F_l[idx]  = (AlAv*invAHbeta_Av) - 1.0;
    }
    return err;
}

#pragma mark -

int red_Al_RVAV_CCM89( Real * A_l, Real Rv, Real Av, Real * wave, Integer n ){
    int err = noErr;
    Real EBmV = Av/Rv;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_CCM89(Rv, lam) * EBmV;
    }
    return err;
}

int red_Al_RVEBmV_CCM89( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_CCM89(Rv, lam) * EBmV;
    }
    return err;
}

/*
 ======================================================================
 END Cardelli Clayton and Mathis 1989 stellar functions
 ======================================================================
 */


/*
 ======================================================================
 Valencic Clayton and Gordon 2004/2014 UV functions
 ======================================================================
 */
#pragma mark - VCG04

    // includes 2014 erratum


static inline Real Fa_VCG04( Real x );
static inline Real Fa_VCG04( Real x ) {
    Real x0 = (x-5.9);
    Real fa = (x0<0.0)?0.0:(-x0*x0*(0.0077 + 0.0030*x0));
    return fa;
}

static inline Real Fb_VCG04( Real x );
static inline Real Fb_VCG04( Real x ) {
    Real x0 = (x-5.9);
    Real fb = (x0<0.0)?0.0:(x0*x0*(0.2060 + 0.0550*x0));
    return fb;
}

#pragma mark -

    // A(l)/A(V), fundamental for VCG04
Real fred_AlAV_VCG04   ( Real Rv, Real lambda ){
        // Al_AV = a(x) + b(x)/Rv;
    Real x = 1.0e4/lambda; // 1/ microns
    Real y = 0.0;
    Real a = 0.0;
    Real b = 0.0;

    if ((x > 3.3 )&&( x <= 8.0 )) {
            // UV and FUV only
        Real xa = (x-4.558);
        Real xb = (x-4.587);
        a = (1.8080-0.215*x)-(0.134/(0.566+xa*xa)) + Fa_VCG04(x);
        b = (-2.350+1.403*x)+(1.103/(0.263+xb*xb)) + Fb_VCG04(x);
    }

    Real Al_Av = a + b/Rv;

    return Al_Av;

}

    // calls above
Real fred_AlEBmV_VCG04 ( Real Rv, Real lambda ){
        // Al/E(B-V) = (Al/AV - 1.0)*Rv + Rv
    Real AlEBmV = fred_AlAV_VCG04(Rv, lambda) - 1.0;
    AlEBmV *= Rv; // E(l-V)/E(B-V)
    AlEBmV += Rv; // Al/(AB-AV)
    return AlEBmV;
}

    // calls above
Real fred_ElmVEBmV_VCG04 ( Real Rv, Real lambda ){
        // FM99 normalisation E(l-V)/E(B-V)
        // E(l-V)/E(B-V) = Al/E(B-V)- Rv
    Real ElvEBmV = fred_AlEBmV_VCG04(Rv, lambda) - Rv;
    return ElvEBmV;
}

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_VCG04  ( Real Rv, Real lambda ){
    Real invAHbeta_Av = 1.0/fred_AlAV_VCG04( Rv, kLambdaHbeta );
    Real AlAv = fred_AlAV_VCG04( Rv, lambda );
    return (AlAv*invAHbeta_Av) - 1.0;
}

#pragma mark -
    // Array routines
    // A(l)/A(V)

int red_AlAV_VCG04( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam     = wave[ idx ];
        A[idx]  = fred_AlAV_VCG04( Rv, lam );
    }
    return err;
}

int red_AlEBmV_VCG04( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_AlEBmV_VCG04(Rv, lam); // returns Al/E(B-V)
    }
    return err;
}

int red_ElmVEBmV_VCG04( Real * E, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        E[idx] = fred_ElmVEBmV_VCG04(Rv, lam);
    }
    return err;
}

int red_Fl_RV_VCG04( Real * F_l, Real Rv, Real * wave, Integer n ){
    int err = noErr;
        //f(l) = (Al/AV)/(AHb/AV) - 1, get 1/(AHb/AV) for multiplying...
    Real invAHbeta_Av = 1.0/fred_AlAV_VCG04( Rv, kLambdaHbeta ); // Hbeta, 1 call
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        Real AlAv = fred_AlAV_VCG04( Rv, lam );
        F_l[idx]  = (AlAv*invAHbeta_Av) - 1.0;
    }
    return err;
}

#pragma mark -

int red_Al_RVAV_VCG04( Real * A_l, Real Rv, Real Av, Real * wave, Integer n ){
    int err = noErr;
    Real EBmV = Av/Rv;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_VCG04(Rv, lam) * EBmV;
    }
    return err;
}

int red_Al_RVEBmV_VCG04( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_VCG04(Rv, lam) * EBmV;
    }
    return err;
}
/*
 =====================================================================
 END Valencic Clayton and Gordon 2004/2014 stellar functions
 ======================================================================
 */

/*
 ======================================================================
 Blagrave Orion 2007 CCM89 modified functions
 ======================================================================
 */
#pragma mark - B07

static inline Real Fa_B07( Real x );
static inline Real Fa_B07( Real x ) {
    Real x0 = (x-5.9);
    Real fa = (x0<0.0)?0.0:(-x0*x0*(0.04473 + 0.009779*x0));
    return fa;
}

static inline Real Fb_B07( Real x );
static inline Real Fb_B07( Real x ) {
    Real x0 = (x-5.9);
    Real fb = (x0<0.0)?0.0:(x0*x0*(0.2103 + 0.1207*x0));
    return fb;
}

#pragma mark -

    // A(l)/A(V), fundamental for CCM89
Real fred_AlAV_B07   ( Real Rv, Real lambda ){
        // Al_AV = a(x) + b(x)/Rv;
    Real x = 1.0e4/lambda; // 1/ microns
    Real y = 0.0;
    Real a = 0.0;
    Real b = 0.0;

    if ( x <= 1.1 ) { //continue below 0.3 for simplicty x -> 0
                      // IR
        a = 0.56102*pow(x, 1.85);
        b =-0.51508*pow(x, 1.85);

    } else if ( x <= 3.3 ) {

        if ( x > 2.3) {
                // Blagrave mods
            Real yb = (x-2.3);
            a = 1.192528+yb*(0.27592-yb*0.15733);
            b = 0.0;

        } else {
                // Optical NIR Eq 3a and 3b
            Real y = (x - 1.82);
            a = 1.0+y*(0.17699
                       +y*(-0.50447
                           +y*(-0.02427
                               +y*(0.72085
                                   +y*(0.01979
                                       +y*(-0.7753
                                           +y*0.32999))))));
            b = y*(1.41338
                   +y*(2.28305
                       +y*(1.07233
                           +y*(-5.38434
                               +y*(-0.62251
                                   +y*(5.3026
                                       -y*2.09002))))));
        }

    } else if ( x <= 8.0 ) {
            // UV and FUV, modified 4b
        Real xa = (x-4.67);
        Real xb = (x-4.65);
        a = ( 1.752-0.316*x)-(0.104/(0.341+xa*xa)) + Fa_B07(x);
        b = (-2.900+1.825*x)+(0.930/(0.263+xb*xb)) + Fb_B07(x);
    }

    Real Al_Av = a + b/Rv;

    return Al_Av;

}

    // calls above
Real fred_AlEBmV_B07 ( Real Rv, Real lambda ){
        // Al/E(B-V) = (Al/AV - 1.0)*Rv + Rv
    Real AlEBmV = fred_AlAV_B07(Rv, lambda) - 1.0;
    AlEBmV *= Rv; // E(l-V)/E(B-V)
    AlEBmV += Rv; // Al/(AB-AV)
    return AlEBmV;
}

Real fred_ElmVEBmV_B07 ( Real Rv, Real lambda ){
        // FM99 normalisation E(l-V)/E(B-V)
        // E(l-V)/E(B-V) = Al/E(B-V)- Rv
  printf("fred_ElmVEBmV_B07\n");
    Real ElvEBmV = fred_AlEBmV_B07 (Rv, lambda) - Rv;
    return ElvEBmV;
}

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_B07  ( Real Rv, Real lambda ){
    Real invAHbeta_Av = 1.0/fred_AlAV_B07( Rv, kLambdaHbeta );
    Real AlAv = fred_AlAV_B07( Rv, lambda );
    return (AlAv*invAHbeta_Av) - 1.0;
}

#pragma mark -
    // A(l)/A(V)

int red_AlAV_B07( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam     = wave[ idx ];
        A[idx]  = fred_AlAV_B07( Rv, lam );
    }
    return err;
}

int red_AlEBmV_B07( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_AlEBmV_B07(Rv, lam); // returns Al/E(B-V)
    }
    return err;
}

int red_ElmVEBmV_B07( Real * E, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        E[idx] = fred_ElmVEBmV_B07(Rv, lam);
    }
    return err;
}

int red_Fl_RV_B07( Real * F_l, Real Rv, Real * wave, Integer n ){
    int err = noErr;
        //f(l) = (Al/AV)/(AHb/AV) - 1, get 1/(AHb/AV) for multiplying...
    Real invAHbeta_Av = 1.0/fred_AlAV_B07( Rv, kLambdaHbeta ); // Hbeta, 1 call
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        Real AlAv = fred_AlAV_B07( Rv, lam );
        F_l[idx]  = (AlAv*invAHbeta_Av) - 1.0;
    }
    return err;
}

#pragma mark -

int red_Al_RVAV_B07( Real * A_l, Real Rv, Real Av, Real * wave, Integer n ){
    int err = noErr;
    Real EBmV = Av/Rv;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_B07(Rv, lam) * EBmV;
    }
    return err;
}

int red_Al_RVEBmV_B07( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_B07(Rv, lam) * EBmV;
    }
    return err;
}

/*
 ======================================================================
 End Blagrave Orion 2007 CCM89 modified functions
 ======================================================================
 */


/*
 ======================================================================
 Fitzpatrick adhoc spline+f 1999 generic Al/E(B-V) function
 ======================================================================
*/
#pragma mark - F99

inline static Real D_fm90 ( Real x, Real gamma, Real x0);
inline static Real D_fm90 ( Real x, Real gamma, Real x0){
    Real x02 = x0*x0;
    Real x2 = x*x;
    Real g2 = gamma*gamma;
    return x2/(((x2-x02)*(x2-x02))+x2*g2);
}

inline static Real F_fm90 ( Real x);
inline static Real F_fm90 ( Real x){
    Real x0 = (x-5.9);
    Real f = (x0<0.0)?0.0:(x0*x0*(0.5392 + 0.05644*x0));
    return f;
}

//static gsl_spline *gSpline = NULL;
//static gsl_interp_accel *gSplineAcc = NULL;

static zls_Spline gSpline;

int freeF99Spline( void );
int freeF99Spline( void ){

//    if ( gSpline) gsl_spline_free( gSpline ); gSpline = NULL;
//    if ( gSplineAcc) gsl_interp_accel_free( gSplineAcc ); gSplineAcc = NULL;
    if ( gSpline ) zls_SplineFree( gSpline );

}

int initF99Spline( Real Rv );
int initF99Spline( Real Rv ){

    int err = noErr;
  // 1/lambda microns

  if ( gSpline == NULL ) {

    // function return A(l)/E(B-V) = E(l-V)/E(B-V) + Rv
    // fit appears to be to E(l-V)/E(B-V) + Rv

    Integer nSpline = 9;

    Q1DArr splx;
    zls_NewQuantity1DArr(&splx, nSpline);
    splx[0] = 0.000;
    splx[1] = 0.377;
    splx[2] = 0.820;
    splx[3] = 1.667;
    splx[4] = 1.828;
    splx[5] = 2.141;
    splx[6] = 2.433;
    splx[7] = 3.704;
    splx[8] = 3.846;

    Q1DArr sply;
    zls_NewQuantity1DArr(&sply, nSpline);
    sply[0] = 0.0;
    sply[1] = 0.0;
    sply[2] = 0.0;
    sply[3] = 0.0;
    sply[4] = 0.0;
    sply[5] = 0.0;
    sply[6] = 0.0;
    sply[7] = 0.0;
    sply[8] = 0.0;

//    gSplineAcc = gsl_interp_accel_alloc ();
//    gSpline    = gsl_spline_alloc(gsl_interp_cspline, nSpline);
    gSpline    = zls_SplineAlloc(nSpline);

        // IR
    sply[0]  = 0.0;
    sply[1]  = 0.265 * (Rv/3.1);
    sply[2]  = 0.829 * (Rv/3.1);

        // Optical spl[3-6]
    sply[3] = -0.426 + 1.0044 * Rv;
    sply[4] = -0.050 + 1.0016 * Rv;
    sply[5] = +0.701 + 1.0016 * Rv;
    sply[6] = +1.208 + Rv*(1.0032 - Rv*0.00033);

        // UV spl 7 and 8
    Real c2    = -0.824 + 4.717/Rv;
    Real c1    =  2.030 - 3.007 * c2;
    Real x0    = 4.596;
    Real gamma = 0.99;
    Real c3    = 3.23;
    Real c4    = 0.41;

    Real d7 = D_fm90(splx[7], gamma, x0);
    Real d8 = D_fm90(splx[8], gamma, x0);

    Real f7 = F_fm90(splx[7]);
    Real f8 = F_fm90(splx[8]);

    sply[7] = Rv + c1 + c2*splx[7] + c3*d7 + c4 *f7;
    sply[8] = Rv + c1 + c2*splx[8] + c3*d8 + c4 *f8;

//    err     = gsl_spline_init (gSpline, splx, sply, nSpline);
     err     = zls_InitNaturalSpline (gSpline, splx, sply, nSpline);


    } // set up only if not already initialised
//
//  for (int i = 0; i< gSpline->nPoints ; i++){
//    printf("%d %e %e \n", i, gSpline->xa[i],gSpline->ya[i],gSpline->y2[i] );
//  }

    return err;
}

    // Public functions:
    //
    // F99 spline is only initialsed once so repeated calls are
    // fast and memory efficient.
    // single spline remains allocated for enire programm lifetime,
    // so private free function is not needed in general.
    //

#pragma mark -

Real fred_AlEBmV_F99( Real Rv, Real lambda ){
    // function return A(l)/E(B-V) = E(l-V)/E(B-V) + Rv
    // fit appears to be to E(l-V)/E(B-V) + Rv
    int err = noErr;

    err = initF99Spline(Rv); // set up spline if not already

    Real y;
    Real x = 1.0e4/lambda;
    if (lambda > 2700.0 ){
//         y = gsl_spline_eval( gSpline, x, gSplineAcc);
        y = zls_SplineYatX( gSpline, x);
    } else {
        Real c2    = -0.824 + 4.717/Rv;
        Real c1    =  2.030 - 3.007 * c2;
        Real x0    = 4.596;
        Real gamma = 0.99;
        Real c3    = 3.23;
        Real c4    = 0.41;
        Real d = D_fm90(x, gamma, x0);
        Real f = F_fm90(x);
        y = Rv + c1 + c2*x + c3*d + c4 *f;
    }
    return y;
}

    // A(l)/A(V)
Real fred_AlAV_F99( Real Rv, Real lambda ){
    int err = noErr;
    Real Al_EBmV  = fred_AlEBmV_F99(Rv, lambda);
    // E(l-V)/E(B-V)  = Al/E(B-V) - Rv
    Real ElmV_EBmV = Al_EBmV-Rv;
    //Al/AV - 1 = [E(l-V)/E(B-V)]/ Rv
    Real Al_Avm1 = ElmV_EBmV/Rv;
    return (Al_Avm1 + 1.0);
}

Real fred_ElmVEBmV_F99( Real Rv, Real lambda ){
        // FM99 normalisation E(l-V)/E(B-V)
        // E(l-V)/E(B-V) = Al/E(B-V)- Rv
    Real ElmVEBmV = fred_AlEBmV_F99(Rv, lambda) - Rv;
    return ElmVEBmV;
}

Real fred_Fl_RV_F99( Real Rv, Real lambda ){
    Real invAHbeta_Av = 1.0/fred_AlAV_F99( Rv, kLambdaHbeta );
    Real AlAv = fred_AlAV_F99( Rv, lambda );
    return (AlAv*invAHbeta_Av) - 1.0;
}

#pragma mark -

    // A(l)/A(V)
int red_AlAV_F99( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam     = wave[ idx ];
        A[idx]  = fred_AlAV_F99( Rv, lam );
    }
    return err;
}

int red_AlEBmV_F99( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_AlEBmV_F99(Rv, lam); // returns Al/E(B-V)
    }
    return err;
}

int red_ElmVEBmV_F99( Real * E, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        E[idx] = fred_ElmVEBmV_F99(Rv, lam);
    }
    return err;
}

int red_Fl_RV_F99( Real * F_l, Real Rv, Real * wave, Integer n ){
    int err = noErr;
        //f(l) = (Al/AV)/(AHb/AV) - 1, get 1/(AHb/AV) for multiplying...
    Real invAHbeta_Av = 1.0/fred_AlAV_F99( Rv, kLambdaHbeta ); // Hbeta, 1 call
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        Real AlAv = fred_AlAV_F99( Rv, lam );
        F_l[idx]  = (AlAv*invAHbeta_Av) - 1.0;
    }
    return err;
}

#pragma mark -

int red_Al_RVAV_F99( Real * A_l, Real Rv, Real Av, Real * wave, Integer n ){
    int err = noErr;
    Real EBmV = Av/Rv;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_F99(Rv, lam) * EBmV;
    }
    return err;
}

int red_Al_RVEBmV_F99( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_F99(Rv, lam) * EBmV;
    }
    return err;
}

/*
 ======================================================================
 End Fitzpatrick adhoc spline+f 1999 generic Al/E(B-V) function
 ======================================================================
*/

/*
 ======================================================================
 Fitzpatrick and Massa adhoc spline+f 2007 generic Al/E(B-V) function
 ======================================================================
 */
#pragma mark - FM07

inline static Real D_fm07 ( Real x, Real gamma, Real x0);
inline static Real D_fm07 ( Real x, Real gamma, Real x0){
    Real x02 = x0*x0;
    Real x2  = x*x;
    Real g2  = gamma*gamma;
    return x2/(((x2-x02)*(x2-x02))+x2*g2);
}

// static gsl_spline *gFM07Spline = NULL;
// static gsl_interp_accel *gFM07SplineAcc = NULL;
static zls_Spline gFM07Spline = NULL;

int freeFM07Spline( void );
int freeFM07Spline( void ){

//     if ( gFM07Spline ) gsl_spline_free( gFM07Spline ); gFM07Spline = NULL;
//     if ( gFM07SplineAcc ) gsl_interp_accel_free( gFM07SplineAcc ); gFM07SplineAcc = NULL;
    if ( gFM07Spline ) zls_SplineFree( gFM07Spline ); gFM07Spline = NULL;

}

int initFM07Spline( Real Rv );
int initFM07Spline( Real Rv ){

    int err = noErr;

        // spline like F99 but *without* + Rv term
        // ie this is k(l) = E(l-V)/E(B-V)
        // F99 fits to Al/E(B-V) = E(l-V)/E(B-V) + Rv
        // normalized inter- stellar extinction

    if ( gFM07Spline == NULL ) {

      Integer nSpline = 10;
            // 1/lambda microns

      Q1DArr splx;
      zls_NewQuantity1DArr(&splx, nSpline);
      splx[0] = 0.0;
      splx[1] = 0.25;
      splx[2] = 0.50;
      splx[3] = 0.75;
      splx[4] = 1.0;
      splx[5] = 1.0e4/5430.0;
      splx[6] = 1.0e4/4000.0;
      splx[7] = 1.0e4/3300.0;
      splx[8] = 1.0e4/2700.0;
      splx[9] = 1.0e4/2600.0;

      Q1DArr sply;
      zls_NewQuantity1DArr(&sply, nSpline);
      sply[0] = 0.0;
      sply[1] = 0.0;
      sply[2] = 0.0;
      sply[3] = 0.0;
      sply[4] = 0.0;
      sply[5] = 0.0;
      sply[6] = 0.0;
      sply[7] = 0.0;
      sply[8] = 0.0;

//         gFM07SplineAcc = gsl_interp_accel_alloc ();
//         gFM07Spline    = gsl_spline_alloc(gsl_interp_cspline, nSpline);
        gFM07Spline    = zls_SplineAlloc(nSpline);

            // IR
        Real kir =(0.63*Rv)-0.83363; //1.057 @ 3.001
        Real alphaIR = 1.84;

        sply[0]  = kir*pow(splx[0],alphaIR) - Rv; // subtract Rv, added again after
        sply[1]  = kir*pow(splx[1],alphaIR) - Rv;
        sply[2]  = kir*pow(splx[2],alphaIR) - Rv;
        sply[3]  = kir*pow(splx[3],alphaIR) - Rv;
        sply[4]  = kir*pow(splx[4],alphaIR) - Rv;

            // Optical - note reverse!  F is crazy

        sply[5]    = 0.000;
        sply[6]    = 1.322;
        sply[7]    = 2.055;

            // UV
        Real    c1 = -0.175;
        Real    c2 =  0.807;
        Real    c3 =  2.991;
        Real    c4 =  0.319;
        Real    c5 =  6.097;
        Real    x0 =  4.592;
        Real gamma =  0.922;

        for (Integer idx = 8; idx < nSpline ; idx++ ){
            Real  x = splx[idx];
            Real x5 = x - c5;
            x5 = (x5<0.0)?0.0:x5;
            Real Dx = D_fm07(x, gamma, x0);
            sply[idx] = c1 + c2*x + c3*Dx + (c4*x5*x5);
        }
//
//        for (Integer idx = 0; idx < nSpline ; idx++ ){
//            printf(" x l y: %#13.6g %#13.6g %#13.6g \n", splx[idx], 1e4/splx[idx], sply[idx] );
//        }
//
//        err = gsl_spline_init (gFM07Spline, splx, sply, nSpline);
        err = zls_InitNaturalSpline (gFM07Spline, splx, sply, nSpline);

    } // set up only if not already initialised

    return err;
}
    //
    // FM07 spline is only initialsed once so repeated calls are
    // fast and memory efficient.
    // single spline remains allocated for enire programm lifetime,
    // so private free function is not needed ingeneral.
    //

#pragma mark -

Real fred_AlEBmV_FM07( Real Rv, Real lambda ){

        // function return A(l)/E(B-V) = E(l-V)/E(B-V) + Rv
        // spline is E(l-V)/E(B-V) and +Rv is needed, unlike F99

    int err = noErr;

    err = initFM07Spline(Rv); // set up spline if not already

    Real y;
    Real x = 1.0e4/lambda;
    if (lambda > 2700.0 ){
//        y = Rv + gsl_spline_eval( gFM07Spline, x, gFM07SplineAcc);
        y = Rv + zls_SplineYatX( gFM07Spline, x);
    } else {
        Real    c1 = -0.175;
        Real    c2 =  0.807;
        Real    c3 =  2.991;
        Real    c4 =  0.319;
        Real    c5 =  6.097;
        Real    x0 =  4.592;
        Real gamma =  0.922;
        Real    x5 = x - c5;
        x5 = (x5<0.0)?0.0:x5;
        Real Dx = D_fm07(x, gamma, x0);
        y = Rv + c1 + c2*x + c3*Dx + (c4*x5*x5);
    }
    return y;
}


Real fred_ElmVEBmV_FM07( Real Rv, Real lambda ){
        // FM99 normalisation E(l-V)/E(B-V)
        // E(l-V)/E(B-V) = Al/E(B-V)- Rv
  printf("fred_ElmVEBmV_FM07\n");
    Real ElmVEBmV = fred_AlEBmV_FM07(Rv, lambda) - Rv;
    return ElmVEBmV;
}

    // A(l)/A(V)
Real fred_AlAV_FM07( Real Rv, Real lambda ){
    int err = noErr;
    Real Al_EBmV  = fred_AlEBmV_FM07(Rv, lambda);
        // E(l-V)/E(B-V)  = Al/E(B-V) - Rv
    Real ElmV_EBmV = Al_EBmV-Rv;
        //Al/AV - 1 = [E(l-V)/E(B-V)]/ Rv
    Real Al_Avm1 = ElmV_EBmV/Rv;
    return (Al_Avm1 + 1.0);
}


Real fred_Fl_RV_FM07( Real Rv, Real lambda ){
    Real invAHbeta_Av = 1.0/fred_AlAV_FM07( Rv, kLambdaHbeta );
    Real AlAv = fred_AlAV_FM07( Rv, lambda );
    return (AlAv*invAHbeta_Av) - 1.0;
}

#pragma mark -
    // A(l)/A(V)
int red_AlAV_FM07( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam     = wave[ idx ];
        A[idx]  = fred_AlAV_FM07( Rv, lam );
    }
    return err;
}

int red_AlEBmV_FM07( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_AlEBmV_FM07(Rv, lam); // returns Al/E(B-V)
    }
    return err;
}

int red_ElmVEBmV_FM07( Real * E, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        E[idx] = fred_ElmVEBmV_FM07(Rv, lam);
    }
    return err;
}

int red_Fl_RV_FM07( Real * F_l, Real Rv, Real * wave, Integer n ){
    int err = noErr;
        //f(l) = (Al/AV)/(AHb/AV) - 1, get 1/(AHb/AV) for multiplying...
    Real invAHbeta_Av = 1.0/fred_AlAV_FM07( Rv, kLambdaHbeta ); // Hbeta, 1 call
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        Real AlAv = fred_AlAV_FM07( Rv, lam );
        F_l[idx]  = (AlAv*invAHbeta_Av) - 1.0;
    }
    return err;
}

#pragma mark -

int red_Al_RVAV_FM07( Real * A_l, Real Rv, Real Av, Real * wave, Integer n ){
    int err = noErr;
    Real EBmV = Av/Rv;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_FM07(Rv, lam) * EBmV;
    }
    return err;
}

int red_Al_RVEBmV_FM07( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_FM07(Rv, lam) * EBmV;
    }
    return err;
}

/*
 ======================================================================
 End Fitzpatrick and Massa adhoc spline+f 2007 generic Al/E(B-V) function
 ======================================================================
 */

/*
 ======================================================================
 Fishera 2005 theoretical screen
 ======================================================================
 */
#pragma mark - FD05


// static gsl_spline *gFD05Spline = NULL;
// static gsl_interp_accel *gFD05SplineAcc = NULL;

static zls_AkimaSpline gFD05Spline = NULL;

int freeFD05Spline( void );
int freeFD05Spline( void ){

//     if ( gFD05Spline) gsl_spline_free( gFD05Spline ); gFD05Spline = NULL;
//     if ( gFD05SplineAcc) gsl_interp_accel_free( gFD05SplineAcc ); gFD05SplineAcc = NULL;
    if ( gFD05Spline) zls_AkimaFree( gFD05Spline ); gFD05Spline = NULL;

}

#define kFD05_AV0 1.0

int initFD05Spline( Real Rv );
int initFD05Spline( Real Rv ){

    int err = noErr;
    if ( gFD05Spline == NULL ) {

      Integer nSpline = 18;
            // 1/lambda microns
      Q1DArr splx;
      zls_NewQuantity1DArr(&splx, nSpline);
      splx[0]  = 0.2093;
      splx[1]  = 0.2784;
      splx[2]  = 0.4562;
      splx[3]  = 0.6064;
      splx[4]  = 0.8071;
      splx[5]  = 0.9709;
      splx[6]  = 1.3889;
      splx[7]  = 1.8248;
      splx[8]  = 2.2727;
      splx[9]  = 2.7397;
      splx[10] = 3.3333;
      splx[11] = 4.0323;
      splx[12] = 4.5977;
      splx[13] = 5.2466;
      splx[14] = 6.4516;
      splx[15] = 8.2237;
      splx[16] = 9.4967;
      splx[17] = 10.9649;


      Q1DArr sply;
      zls_NewQuantity1DArr(&sply, nSpline);
      sply[0]  = 0.0000;
      sply[1]  = 0.0000;
      sply[2]  = 0.0000;
      sply[3]  = 0.0000;
      sply[4]  = 0.0000;
      sply[5]  = 0.0000;
      sply[6]  = 0.0000;
      sply[7]  = 0.0000;
      sply[8]  = 0.0000;
      sply[9]  = 0.0000;
      sply[10] = 0.0000;
      sply[11] = 0.0000;
      sply[12] = 0.0000;
      sply[13] = 0.0000;
      sply[14] = 0.0000;
      sply[15] = 0.0000;
      sply[16] = 0.0000;
      sply[17] = 0.0000;


//         gFD05SplineAcc = gsl_interp_accel_alloc ();
//         gFD05Spline    = gsl_spline_alloc(gsl_interp_akima, nSpline);
        gFD05Spline    = zls_AkimaAlloc(nSpline);

            // compute nodes
            //
            //Av = 1.0 coefficients: table 2 FD05
            //
        Real a1b[5] = {4.95676E-03, 3.42939E+00,-3.62163E+00, 1.64220E+00, 0.00000E+00};
        Real a2b[5] = {3.93932E-02,-7.08645E-01,-6.68874E-01, 5.11725E+00,-2.19900E+00};
        Real a3b[5] = {1.74931E-02,-4.84444E-01, 5.17489E+00,-1.92137E+01, 2.15465E+01};

        Real z = 1.0/(Rv-1.0);

            // eq 9
        Real a1 = a1b[0]+z*(a1b[1]+z*(a1b[2]+z*(a1b[3]+z*a1b[4])));
        Real a2 = a2b[0]+z*(a2b[1]+z*(a2b[2]+z*(a2b[3]+z*a2b[4])));
        Real a3 = a3b[0]+z*(a3b[1]+z*(a3b[2]+z*(a3b[3]+z*a3b[4])));

        Real Av = kFD05_AV0;
            // not used, initially Av = 1.0, error max ~5% if really Av 10

        Real LogAlAv0[18] = {-1.544068E+00,-1.318289E+00,-9.274493E-01,-7.236277E-01,
                             -5.299868E-01,-4.061244E-01,-1.686123E-01,0.000000E+00,
                              1.221094E-01,2.107666E-01,2.929893E-01,3.952810E-01,
                              5.121870E-01,4.302133E-01,4.198271E-01,5.288166E-01,
                              6.177762E-01,6.917472E-01};

        for (int j = 0; j < nSpline; j++){
            Real sum = 0.0;
            Real x = LogAlAv0[j];
            sum = x*(a1+x*(a2+x*a3));
            sply[j] = pow(10.0, sum);
        }
//
//        for (int j = 0; j < nSpline; j++){
//            printf("%#13.6g %#13.6g \n", splx[j], sply[j]);
//        }
//
//        err     = gsl_spline_init (gFD05Spline, splx, sply, nSpline);
        err     = zls_AkimaInit (gFD05Spline, splx, sply, nSpline);

    } // set up only if not already initialised

    return err;
}

#pragma mark -


    // A(l)/A(V)
Real fred_AlAV_FD05( Real Rv, Real lambda ){
    int err = initFD05Spline(Rv); // set up spline if not already
    Real y = 0.0;
    Real x = 1.0e4/lambda;
    if ((x >= 0.2093)&&(x<=10.9649)){
//         y = gsl_spline_eval( gFD05Spline, x, gFD05SplineAcc);
        y = zls_Akima( gFD05Spline, x);
    }
    return y;
}

    // calls above
Real fred_AlEBmV_FD05 ( Real Rv, Real lambda ){
        // Al/E(B-V) = (Al/AV - 1.0)*Rv + Rv
    Real AlEBmV = fred_AlAV_FD05(Rv, lambda) - 1.0;
    AlEBmV *= Rv; // E(l-V)/E(B-V)
    AlEBmV += Rv; // Al/(AB-AV)
    return AlEBmV;
}

Real fred_ElmVEBmV_FD05( Real Rv, Real lambda ){
        // FM99 normalisation E(l-V)/E(B-V)
        // E(l-V)/E(B-V) = Al/E(B-V)- Rv
  printf("fred_ElmVEBmV_FD05\n");
    Real ElmVEBmV = fred_AlEBmV_FD05(Rv, lambda) - Rv;
    return ElmVEBmV;
}

Real fred_Fl_RV_FD05( Real Rv, Real lambda ){
    Real invAHbeta_Av = 1.0/fred_AlAV_FD05( Rv, kLambdaHbeta );
    Real AlAv = fred_AlAV_FD05( Rv, lambda );
    return (AlAv*invAHbeta_Av) - 1.0;
}

#pragma mark -

    // A(l)/A(V)
int red_AlAV_FD05( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam     = wave[ idx ];
        A[idx]  = fred_AlAV_FD05( Rv, lam );
    }
    return err;
}

int red_AlEBmV_FD05( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_AlEBmV_FD05(Rv, lam); // returns Al/E(B-V)
    }
    return err;
}

int red_ElmVEBmV_FD05( Real * E, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        E[idx] = fred_ElmVEBmV_FD05(Rv, lam);
    }
    return err;
}

int red_Fl_RV_FD05( Real * F_l, Real Rv, Real * wave, Integer n ){
    int err = noErr;
        //f(l) = (Al/AV)/(AHb/AV) - 1, get 1/(AHb/AV) for multiplying...
    Real invAHbeta_Av = 1.0/fred_AlAV_FD05( Rv, kLambdaHbeta ); // Hbeta, 1 call
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        Real AlAv = fred_AlAV_FD05( Rv, lam );
        F_l[idx]  = (AlAv*invAHbeta_Av) - 1.0;
    }
    return err;
}

#pragma mark -

int red_Al_RVAV_FD05( Real * A_l, Real Rv, Real Av, Real * wave, Integer n ){
    int err = noErr;
    Real EBmV = Av/Rv;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_FD05(Rv, lam) * EBmV;
    }
    return err;
}

int red_Al_RVEBmV_FD05( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_FD05(Rv, lam) * EBmV;
    }
    return err;
}


/*
 ======================================================================
 END Fishera 2005 theoretical screen
 ======================================================================
 */


/*
 ======================================================================
 Calzetti 2000/2001 extra galactic function
 ======================================================================
 */
#pragma mark - C00

    // k(l) = Al/E(B-V) fundamental for C00
Real fred_AlEBmV_C00 ( Real Rv, Real lambda ){
        // k(l) = Al/E(B-V)
    Real x = 1.0e4/lambda;
    Real y = 0.0;
    if ( lambda >= 6300.0 ) {
        y = 2.659*(-1.857 + 1.040*x) + Rv;
    } else {
        Real p = -2.156+x*(1.5090+x*(-0.1980+ x*0.0110));
        y = 2.659*p + Rv;
    }
    return y;
}

    // ke(l) = 0.44*Al/E(B-V) fundamental for C00
Real fred_ExtAlEBmV_C00 ( Real Rv, Real lambda ){
        // k(l) = Al/E(B-V)
    Real x = 1.0e4/lambda;
    Real y = 0.0;
    if ( lambda >= 6300.0 ) {
        y = 2.659*(-1.857 + 1.040*x) + Rv;
    } else {
        Real p = -2.156+x*(1.5090+x*(-0.1980+ x*0.0110));
        y = 2.659*p + Rv;
    }
    return (0.440*y);
}

    // A(l)/A(V), calls above
Real fred_AlAV_C00   ( Real Rv, Real lambda ){
    Real Al_EBmV  = fred_AlEBmV_C00(Rv, lambda);
        // E(l-V)/E(B-V)  = Al/E(B-V) - Rv
    Real ElmV_EBmV = Al_EBmV-Rv;
        //Al/AV - 1 = [E(l-V)/E(B-V)]/ Rv
    Real Al_Avm1 = ElmV_EBmV/Rv;
    return (Al_Avm1 + 1.0);
}

Real fred_ElmVEBmV_C00 ( Real Rv, Real lambda ){
        // FM99 normalisation E(l-V)/E(B-V)
        // E(l-V)/E(B-V) = Al/E(B-V)- Rv
  printf("fred_ElmVEBmV_C00\n");
    Real ElmVEBmV = fred_AlEBmV_C00 (Rv, lambda) - Rv;
    return ElmVEBmV;
}

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_C00  ( Real Rv, Real lambda ){
    Real invAHbeta_Av = 1.0/fred_AlAV_C00( Rv, kLambdaHbeta );
    Real AlAv = fred_AlAV_C00( Rv, lambda );
    return (AlAv*invAHbeta_Av) - 1.0;
}

#pragma mark -
    // A(l)/A(V)
int red_AlAV_C00( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam     = wave[ idx ];
        A[idx]  = fred_AlAV_C00( Rv, lam );
    }
    return err;
}

int red_AlEBmV_C00( Real * A, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A[idx] = fred_AlEBmV_C00(Rv, lam); // returns Al/E(B-V)
    }
    return err;
}

int red_ElmVEBmV_C00( Real * E, Real Rv, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        E[idx] = fred_ElmVEBmV_C00(Rv, lam);
    }
    return err;
}

int red_Fl_RV_C00( Real * F_l, Real Rv, Real * wave, Integer n ){
    int err = noErr;
        //f(l) = (Al/AV)/(AHb/AV) - 1, get 1/(AHb/AV) for multiplying...
    Real invAHbeta_Av = 1.0/fred_AlAV_C00( Rv, kLambdaHbeta ); // Hbeta, 1 call
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        Real AlAv = fred_AlAV_C00( Rv, lam );
        F_l[idx]  = (AlAv*invAHbeta_Av) - 1.0;
    }
    return err;
}

#pragma mark -

int red_Al_RVAV_C00( Real * A_l, Real Rv, Real Av, Real * wave, Integer n ){
    int err = noErr;
    Real EBmV = Av/Rv;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_C00(Rv, lam) * EBmV;
    }
    return err;
}

int red_Al_RVEBmV_C00( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam = wave[ idx ];
        A_l[idx] = fred_AlEBmV_C00(Rv, lam) * EBmV;
    }
    return err;
}

/*
 ======================================================================
 END Calzetti 2000/2001 extra galactic function
 ======================================================================
 */


#pragma mark - P70

/*
 ======================================================================
 Piembert 1970 fixed Rv= 5.5 Orion F(l) Only
 ======================================================================
 */

// static gsl_spline *gP70Spline = NULL;
// static gsl_interp_accel *gP70SplineAcc = NULL;
static zls_Spline gP70Spline = NULL;

int freeP70Spline( void );
int freeP70Spline( void ){

//     if ( gP70Spline) gsl_spline_free( gP70Spline ); gP70Spline = NULL;
//     if ( gP70SplineAcc) gsl_interp_accel_free( gP70SplineAcc ); gP70SplineAcc = NULL;
    if ( gP70Spline) zls_SplineFree( gP70Spline ); gP70Spline = NULL;

}

int initP70Spline( void );
int initP70Spline( void ){

    int err = noErr;
    if ( gP70Spline == NULL ) {

      Integer nSpline = 14;

            // 1/lambda microns, added extrap at 3.5 following 2.86 trend
            // to cover down to 3000A, alebit approximately
      Q1DArr splx;
      zls_NewQuantity1DArr(&splx, nSpline);
      splx[0]  = 0.00000E+00;
      splx[1]  = 5.00000E-01;
      splx[2]  = 9.09091E-01;
      splx[3]  = 1.00000E+00;
      splx[4]  = 1.11111E+00;
      splx[5]  = 1.25000E+00;
      splx[6]  = 1.42857E+00;
      splx[7]  = 1.66667E+00;
      splx[8]  = 2.00000E+00;
      splx[9]  = 2.05719E+00;
      splx[10] = 2.22222E+00;
      splx[11] = 2.50000E+00;
      splx[12] = 2.85714E+00;
      splx[13] = 3.50000E+00;

      Q1DArr sply;
      zls_NewQuantity1DArr(&sply, nSpline);

      sply[0]  = -1.00000E+00;
      sply[1]  = -9.75000E-01;
      sply[2]  = -8.50000E-01;
      sply[3]  = -8.00000E-01;
      sply[4]  = -7.10000E-01;
      sply[5]  = -5.60000E-01;
      sply[6]  = -3.60000E-01;
      sply[7]  = -1.70000E-01;
      sply[8]  = -2.00000E-02;
      sply[9]  =  0.00000E+00;
      sply[10] =  6.00000E-02;
      sply[11] =  1.40000E-01;
      sply[12] =  2.30000E-01;
      sply[13] =  3.90339E-01;

//        gP70SplineAcc = gsl_interp_accel_alloc ();
//        gP70Spline    = gsl_spline_alloc(gsl_interp_cspline, nSpline);
        gP70Spline    = zls_SplineAlloc(nSpline);

//        err     = gsl_spline_init (gP70Spline, splx, sply, nSpline);
        err     = zls_InitNaturalSpline (gP70Spline, splx, sply, nSpline);

    } // set up only if not already initialised

    return err;
}

    // Public functions:
    //
    // P70 spline is only initialsed once so repeated calls are
    // fast and memory efficient.
    // single spline remains allocated for enire programm lifetime,
    // so private free function is not needed ingeneral.
    //

    // Rv fixed at Rv=5.5, only F(l) values available, as we cannot
    // undo (A(l)/AV)/A(Hbeta)/AV), and A(Hbeta)/AV is not given,
    // only F the ratio.
    //

#pragma mark -

Real fred_Fl_RV_P70( Real lambda ){
    int err = noErr;
    err = initP70Spline(); // set up spline if not already, Rv fixed
    Real x = 1.0e4/lambda;
    Real y = 0.0;
    if ( x <= 3.34){
//          y =  gsl_spline_eval( gP70Spline, x, gP70SplineAcc);
         y =  zls_SplineYatX( gP70Spline, x);
    }
    return y;
}

int red_Fl_RV_P70( Real * F_l, Real * wave, Integer n ){
    int err = noErr;
    for (Integer idx = 0; idx < n; idx++ ){
        Real lam  = wave[ idx ];
        F_l[idx]  = fred_Fl_RV_P70( lam );
    }
    return err;
}


/*
 ======================================================================
 END Piembert 1970 fixed Rv= 5.5 Orion F(l) Only
 ======================================================================
 */

