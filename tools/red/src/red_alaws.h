#ifndef __red_alaws__
#define __red_alaws__

//  v1.0.8

#include "zls.h"

#pragma mark GENERIC

/*
 ======================================================================
 General Functions, use ID to call selected function, general API:
 ======================================================================
 */

int red_PrintType  (Integer redID );

    //scalar functions

Real fred_AlAV     ( Real Rv, Real lambda , Integer redID ); // Al/AV
Real fred_AlEBmV   ( Real Rv, Real lambda , Integer redID ); // Al/E(B-V)
Real fred_ElmVEBmV ( Real Rv, Real lambda , Integer redID ); // E(l-V)/E(B-V)
Real fred_Fl_RV    ( Real Rv, Real lambda , Integer redID ); // F(l)

    // Array routines

    // Al/AV, Al/E(B-V) E(l-V)/E(B-V) or F(l) functions of Rv only
int red_AlAV       ( Real * A, Real Rv, Real * wave, Integer n , Integer redID);
int red_AlEBmV     ( Real * A, Real Rv, Real * wave, Integer n , Integer redID);
int red_ElmVEBmV   ( Real * E, Real Rv, Real * wave, Integer n , Integer redID);
int red_Fl_RV      ( Real * F, Real Rv, Real * wave, Integer n , Integer redID);

//====================================================================================
// Absolute A(l),  using Rv + Av or Rv + E(B-V)
int red_Al_RVAV    ( Real * A, Real Rv, Real   Av, Real * wave, Integer n , Integer redID);
int red_Al_RVEBmV  ( Real * A, Real Rv, Real EBmV, Real * wave, Integer n , Integer redID);
/*
 ======================================================================
 END General Functions, use ID to call selected function
 ======================================================================
 */

/*
 ======================================================================
 Begin specific function calls, selected by id above
 ======================================================================
 */

/*
 ======================================================================
 Cardelli Clayton and Mathis 1989 stellar functions
 ======================================================================
 */
#pragma mark - CCM89
    //
    // scalar functions
    //
    // A(l)/A(V) fundamental CCM89 function
Real fred_AlAV_CCM89     ( Real Rv, Real lambda );

    // A(l)/E(B-V), calls above
Real fred_AlEBmV_CCM89   ( Real Rv, Real lambda );

    // E(l-V)/E(B-V), calls above
Real fred_ElmVEBmV_CCM89 ( Real Rv, Real lambda );

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_CCM89    ( Real Rv, Real lambda );

    // Array routines

    // Al/AV, Al/E(B-V) or F(l) functions of Rv only
int red_AlAV_CCM89      ( Real * A, Real Rv, Real * wave, Integer n );
int red_AlEBmV_CCM89    ( Real * A, Real Rv, Real * wave, Integer n );
int red_ElmVEBmV_CCM89  ( Real * E, Real Rv, Real * wave, Integer n );
int red_Fl_RV_CCM89     ( Real * F, Real Rv, Real * wave, Integer n );

    // A(l),  using Rv + Av or Rv + E(B-V)
int red_Al_RVAV_CCM89   ( Real * A, Real Rv, Real   Av, Real * wave, Integer n );
int red_Al_RVEBmV_CCM89 ( Real * A, Real Rv, Real EBmV, Real * wave, Integer n );
    //
/*
 ======================================================================
 End  Cardelli Clayton and Mathis 1989 stellar functions
 ======================================================================
 */

/*
 ======================================================================
 Valencic Clayton and Gordon 2004/2014 UV functions
 ======================================================================
 */
#pragma mark - VCG04
    //
    // scalar functions
    //
    // A(l)/A(V) fundamental CCM89 function
Real fred_AlAV_VCG04     ( Real Rv, Real lambda );

    // A(l)/E(B-V), calls above
Real fred_AlEBmV_VCG04   ( Real Rv, Real lambda );

    // E(l-V)/E(B-V), calls above
Real fred_ElmVEBmV_VCG04 ( Real Rv, Real lambda );

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_VCG04    ( Real Rv, Real lambda );

    // Array routines

    // Al/AV, Al/E(B-V) or F(l) functions of Rv only
int red_AlAV_VCG04      ( Real * A, Real Rv, Real * wave, Integer n );
int red_AlEBmV_VCG04    ( Real * A, Real Rv, Real * wave, Integer n );
int red_ElmVEBmV_VCG04  ( Real * E, Real Rv, Real * wave, Integer n );
int red_Fl_RV_VCG04     ( Real * F, Real Rv, Real * wave, Integer n );

    // A(l),  using Rv + Av or Rv + E(B-V)
int red_Al_RVAV_VCG04   ( Real * A, Real Rv, Real   Av, Real * wave, Integer n );
int red_Al_RVEBmV_VCG04 ( Real * A, Real Rv, Real EBmV, Real * wave, Integer n );
    //
/*
 ======================================================================
 End Valencic Clayton and Gordon 2004/2014 UV functions
 ======================================================================
 */

/*
 ======================================================================
 Fitzpatrick adhoc spline+f 1999 generic Al/E(B-V) function
 ======================================================================
 */
#pragma mark - F99
    //
    // First call to any function/routine allocated a static
    // spline, subsequent calls reuse the spline.
    //
    // function returns A(l)/RV = A(l)/E(B-V) = E(l-V)/E(B-V) + Rv
    // fit appears to be k(l) = E(l-V)/E(B-V) and Rv is added
    // RV = AV/E(B-V)
    //
    // scalar functions
    //
Real fred_AlEBmV_F99   ( Real Rv, Real lambda );

    // A(l)/A(V), calls above
Real fred_AlAV_F99     ( Real Rv, Real lambda );

    // E(l-V)/E(B-V), calls above
Real fred_ElmVEBmV_F99 ( Real Rv, Real lambda );

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_F99    ( Real Rv, Real lambda );

    // Array routines

    // Al/AV, Al/E(B-V) or F(l) functions of Rv only
int red_AlAV_F99       ( Real *  A, Real Rv, Real * wave, Integer n );
int red_AlEBmV_F99     ( Real *  A, Real Rv, Real * wave, Integer n );
int red_ElmVEBmV_F99   ( Real *  E, Real Rv, Real * wave, Integer n );
int red_Fl_RV_F99      ( Real *  F, Real Rv, Real * wave, Integer n );

    // A(l),  using Rv + Av or Rv + E(B-V)
int red_Al_RVAV_F99    ( Real * A_l, Real Rv, Real   Av, Real * wave, Integer n );
int red_Al_RVEBmV_F99  ( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n );
    //
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
    //
    // First call to any function/routine allocated a static
    // spline, subsequent calls reuse the spline.
    //
    // function returns A(l)/RV = A(l)/E(B-V) = E(l-V)/E(B-V) + Rv
    // fit appears to be E(l-V)/E(B-V) and Rv is added
    // RV = AV/E(B-V)
    //
    // scalar functions
    //
Real fred_AlEBmV_FM07   ( Real Rv, Real lambda );

    // A(l)/A(V), calls above
Real fred_AlAV_FM07     ( Real Rv, Real lambda );

    // E(l-V)/E(B-V), calls above
Real fred_ElmVEBmV_FM07 ( Real Rv, Real lambda );

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_FM07    ( Real Rv, Real lambda );

    // Array routines

    // Al/AV, Al/E(B-V) or F(l) functions of Rv only
int red_AlAV_FM07      ( Real * A, Real Rv, Real * wave, Integer n );
int red_AlEBmV_FM07    ( Real * A, Real Rv, Real * wave, Integer n );
int red_ElmVEBmV_FM07  ( Real * E, Real Rv, Real * wave, Integer n );
int red_Fl_RV_FM07     ( Real * F, Real Rv, Real * wave, Integer n );

    // A(l),  using Rv + Av or Rv + E(B-V)
int red_Al_RVAV_FM07   ( Real * A_l, Real Rv, Real   Av, Real * wave, Integer n );
int red_Al_RVEBmV_FM07 ( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n );
    //
/*
 ======================================================================
 End Fitzpatrick and Massa adhoc spline+f 2007 generic Al/E(B-V) function
 ======================================================================
 */

/*
 ======================================================================
 Calzetti Extragalactic Function
 ======================================================================
 */
#pragma mark - C00
    //
    // scalar functions
    //

    // A(l)/E(B-V), *Exctintion* k(lambda) definition Eq 2.1 in Calz 2001
    // point source behind a screen.
Real fred_AlEBmV_C00   ( Real Rv, Real lambda );

    // A(l)/A(V) calls above
Real fred_AlAV_C00     ( Real Rv, Real lambda );

    // E(l-V)/E(B-V), calls above
Real fred_ElmVEBmV_C00 ( Real Rv, Real lambda );

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_C00    ( Real Rv, Real lambda );

    // Array routines

    // Al/AV, Al/E(B-V) or F(l) functions of Rv only
int red_AlAV_C00      ( Real * A, Real Rv, Real * wave, Integer n );
int red_AlEBmV_C00    ( Real * A, Real Rv, Real * wave, Integer n );
int red_ElmVEBmV_C00  ( Real * E, Real Rv, Real * wave, Integer n );
int red_Fl_RV_C00     ( Real * F, Real Rv, Real * wave, Integer n );

    // A(l),  using Rv + Av or Rv + E(B-V)
int red_Al_RVAV_C00   ( Real * A_l, Real Rv, Real   Av, Real * wave, Integer n );
int red_Al_RVEBmV_C00 ( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n );
    //
/*
 ======================================================================
 END Calzetti Extragalactic Function
 ======================================================================
 */

/*
 ======================================================================
 Fishera 2005 theoretical screen
 ======================================================================
 */
#pragma mark - FD05
    //
    // scalar functions
    //
    // A(l)/A(V) fundamental FD05 function
Real fred_AlAV_FD05     ( Real Rv, Real lambda );

    // A(l)/E(B-V), calls above
Real fred_AlEBmV_FD05   ( Real Rv, Real lambda );

    // E(l-V)/E(B-V), calls above
Real fred_ElmVEBmV_FD05 ( Real Rv, Real lambda );

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_FD05    ( Real Rv, Real lambda );

    // Array routines

    // Al/AV, Al/E(B-V) or F(l) functions of Rv only
int red_AlAV_FD05      ( Real * A, Real Rv, Real * wave, Integer n );
int red_AlEBmV_FD05    ( Real * A, Real Rv, Real * wave, Integer n );
int red_ElmVEBmV_FD05  ( Real * E, Real Rv, Real * wave, Integer n );
int red_Fl_RV_FD05     ( Real * F, Real Rv, Real * wave, Integer n );

    // A(l),  using Rv + Av or Rv + E(B-V)
int red_Al_RVAV_FD05   ( Real * A_l, Real Rv, Real   Av, Real * wave, Integer n );
int red_Al_RVEBmV_FD05 ( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n );
    //
/*
 ======================================================================
 End Fishera 2005 theoretical screen
 ======================================================================
 */

/*
 ======================================================================
 Blagrave Orion 2007 CCM89 modified functions
 ======================================================================
 */
#pragma mark - B07
    //
    // scalar functions
    //
    // A(l)/A(V) fundamental CCM89 function
Real fred_AlAV_B07     ( Real Rv, Real lambda );

    // A(l)/E(B-V), calls above
Real fred_AlEBmV_B07   ( Real Rv, Real lambda );

    // E(l-V)/E(B-V), calls above
Real fred_ElmVEBmV_B07 ( Real Rv, Real lambda );

    // Nebula F(l) reddening function [A(l)/A(V)]/[A(Hbeta)/A(V)] -1.0
Real fred_Fl_RV_B07    ( Real Rv, Real lambda );

    // Array routines

    // Al/AV, Al/E(B-V) or F(l) functions of Rv only
int red_AlAV_B07      ( Real * A, Real Rv, Real * wave, Integer n );
int red_AlEBmV_B07    ( Real * A, Real Rv, Real * wave, Integer n );
int red_ElmVEBmV_B07  ( Real * E, Real Rv, Real * wave, Integer n );
int red_Fl_RV_B07     ( Real * F, Real Rv, Real * wave, Integer n );

    // A(l),  using Rv + Av or Rv + E(B-V)
int red_Al_RVAV_B07   ( Real * A_l, Real Rv, Real   Av, Real * wave, Integer n );
int red_Al_RVEBmV_B07 ( Real * A_l, Real Rv, Real EBmV, Real * wave, Integer n );
    //
/*
 ======================================================================
 End Blagrave Orion 2007 CCM89 modified functions
 ======================================================================
 */

/*
 ======================================================================
 Piembert 1970 fixed Rv= 5.5 Orion F(l) Only
 ======================================================================
 */
#pragma mark - P70

// Rv fixed at Rv=5.5, only F(l) values available, as we cannot
// undo (A(l)/AV)/A(Hbeta)/AV) if A(Hbeta)/AV is not given,
// = A(l)/A(Hbeta) - 1
// only F the ratio. (is that true???)
// Rv is implicit, so no parameter

Real fred_Fl_RV_P70   ( Real lambda );
int  red_Fl_RV_P70    ( Real * F, Real * wave, Integer n );

/*
 ======================================================================
 END Piembert 1970 fixed Rv= 5.5 Orion F(l) Only
 ======================================================================
 */


#endif
