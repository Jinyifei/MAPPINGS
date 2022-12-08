#include "zls.h"
#include "zlib.h"

/*
 v1.0.2

 blur: program to resample general spectra to dlam = 0.25A
 from 3300.0 to 9000.0 A, and optionaly convolve with an instrumental
 resolution, generic gaussian and/or an stellar rotation velocity.

 Read two CMFGEN spectra and write to std out.

 blur25 [-r resolvePower] [-f fwhm] [-v vsini] flux25file cont25file
 resolvePower: positive float, lambda/dlambda
 vsini: positive float, km/s
 if -r -f and -v are omitted, no convoltion is performed
 Input files can be text or text.gz files

 #define LAMBDA0 3295.0
 #define LAMBDA1 9005.0
 #define DLAMBDA 0.25

 #define OUTLAMBDA0 3300.0
 #define OUTLAMBDA1 9000.0

 */

#define LAMBDA0 3300.25
#define LAMBDA1 8934.25
#define DLAMBDA 0.25

#define OUTLAMBDA0 3310.0
#define OUTLAMBDA1 8930.0

    // Prototypes
Counter ReadFluxFile(Q1DArr * wave, Q1DArr * flux, char * fileName );

void Usage(void){

    printf("\n  Useage: blur [-s] [-d dlambda][-l headerlines] [-n min lambda] [-m maxlabda] [-r resolvePower] [-f fwhm] [-v vsini] flux25file cont25file\n\n");
    printf("      Args: optional -s use single spectrum - no normalising continuum\n");
    printf("            optional resolvePower: positive float, lambda/dlambda\n");
    printf("            optional  fwhm: gaussian positive float, km/s\n");
    printf("            optional vsini: rotation positive float, km/s\n");
    printf("            if -r -f -v are omitted or all <= 0.0, no convolution is performed\n\n");
    printf("            default 3300.25 wave optional min -n minwave \n");
    printf("            default 8934.25 wave optional max -m maxwave \n");
    printf("            default 0.25 A -d dLam optional output bin resolution \n");
    printf("            default 7 header lines -l lines optional  and then two columns\n");
    printf("  Required: Input files can be text or text.gz files\n");
    printf("            lambda <3295.0A >9005.0A 0.25A bins\n");
    printf("            Lambda   Flambda\n\n");
    printf("    Output: lambda 3300.0A - 9000.0A 0.25A bins\n");
    printf("            lambda, flux, continuum, normalised flux\n");
    printf("            suitable as a 4 column csv file\n\n");
    exit(-1);

}

int main(int argc, char * argv[]) {

    int err = noErr;

    if (argc < 3){
        Usage();
        return -1;
    }

    int ch;
    extern char* optarg;

    Real resPower = 0.0; // lambda/dlambda, ie 7000.0
    Real vSini    = 0.0; // km/s, ie 100.0
    Real fwhm     = 0.0; // km/s, ie 100.0
    Real box      = 0.0; // km/s, ie 30.0
    int gSpeconly = 0;

    Real lambda0 = LAMBDA0;
    Real lambda1 = LAMBDA1;
    Real dLambda = DLAMBDA;
    int hl = 7;
    Counter headerLines = 7;

    Integer optind = 0;
    while ((ch = getopt(argc, argv, "l:n:m:d:a:f:r:v:s")) != -1) {
        optind++;
        switch (ch) {
            case 'l':
                hl = atoi( optarg );
                headerLines=(hl>0)?(Counter)hl:7L;
                break;
            case 'a':
                box = atof( optarg );
                break;
            case 'r':
                resPower = atof( optarg );
                break;
            case 'v':
                vSini = atof( optarg );
                break;
            case 'f':
              fwhm = atof( optarg );
              break;
            case 'n':
              lambda0 = atof( optarg );
              break;
            case 'm':
              lambda1 = atof( optarg );
              break;
            case 'd':
              dLambda = atof( optarg );
              break;
            case 's':
              gSpeconly = 1;
              break;
            case '?':
            default:
                Usage();
        }
    }
    Real outLambda0=LAMBDA0;
    Real outLambda1=LAMBDA1;

    optind *= 2; // account for init args: 2 per arg
    optind += 1; // account for command name

    resPower = (resPower<0.0)?0.0:resPower;
    vSini = (vSini<0.0)?0.0:vSini;
    fwhm = (fwhm<0.0)?0.0:fwhm;
    box = (box<0.0)?0.0:box;
    gSpeconly = (gSpeconly != 1) ? 0: 1;
    optind=(gSpeconly==1)?optind-1:optind; // -s has no arg

    if ( argc > (optind) ) {

        Q1DArr waveFlux = NULL;
        Q1DArr fluxFlux = NULL;
        Q1DArr cWaveFlux = NULL;
        Q1DArr cFluxFlux = NULL;

        Q1DArr wv = NULL;  // stdair wavelengths A
        Q1DArr fl = NULL;  // fluxes Hnu
        Q1DArr cn = NULL;  // continuum Hnu
        Q1DArr nz = NULL;  // normalised spectrum

        Real w0 = lambda0;
        Real dw = dLambda;
        Counter nSpline = (Counter) lround((lambda1-lambda0)/dLambda) + 1;

        err  = zls_NewQuantity1DArr( &wv, nSpline );
        err |= zls_NewQuantity1DArr( &fl, nSpline );
        err |= zls_NewQuantity1DArr( &cn, nSpline );
        err |= zls_NewQuantity1DArr( &nz, nSpline );

        if (err == noErr) {

                // read flux from 1st file arg

            Counter nSpec = ReadFluxFile(&waveFlux, &fluxFlux, (char *)argv[optind] );
            Counter nSpectrum = nSpec;
            zls_AkimaSpline zSpline= NULL;

            if ( nSpectrum > 4 ){ // worked and got enough points :)

                 zSpline = zls_AkimaAlloc (nSpec);
                 err = zls_AkimaInit ( zSpline, waveFlux, fluxFlux, nSpec);

                if ( err == noErr ) {

                    for ( Counter idx = 0 ; idx < nSpline; idx++){
                        Real x = w0 + idx*dw;
                        Real y = zls_Akima( zSpline, x);
                        wv[ idx ] = x;
                        fl[ idx ] = y;
                    }

                }

                zls_AkimaFree( zSpline ); zSpline = NULL; nSpec = 0;

   // read continuum from 2nd file arg
                if ( gSpeconly != 1 ) {
                    nSpec = ReadFluxFile(&waveFlux, &fluxFlux, (char *)argv[optind+1] );
                } else {
                   zls_NewQuantity1DArr(&cWaveFlux, nSpectrum);
                   zls_NewQuantity1DArr(&cFluxFlux, nSpectrum);
                   for ( Counter idx = 0 ; idx < nSpectrum; idx++){
                       cWaveFlux[ idx ] = waveFlux[idx];
                       cFluxFlux[ idx ] = 1.0;
                   }
                   nSpec=nSpectrum;
                }

                if ( nSpec > 4 ){

                    zSpline = zls_AkimaAlloc (nSpec);
                    err = zls_AkimaInit ( zSpline, waveFlux, fluxFlux, nSpec);

                    if ( err == noErr ) {

                        for ( Counter idx = 0 ; idx < nSpline; idx++){
                            Real x = w0 + idx*dw;
                            Real y = zls_Akima( zSpline, x);
                            cn[ idx ] = y;
                        }

                            // Make normalised spec

                        for ( Counter idx = 0 ; idx < nSpline; idx++){
                            Real f = fl[ idx ];
                            Real c = cn[ idx ];
                            c = (c<=0.0)?1.0:c;
                            nz[ idx ] = f/c ;
                        }

                       // Do convolutions here, on fl cn and nz if needed

                        if (( resPower > 0.0 ) || ( vSini > 0.0 ) || ( fwhm > 0.0 )|| ( box > 0.0 )) {
                            err = zls_WLogXConvolve( wv, fl, cn, nz, nSpline, resPower, fwhm, vSini, box);
                        }

                        if (err == noErr ){

                                // Output spectra to stdout

                            printf(" Wave  (A air), Flux   (Flam), Cont.  (Flam),    Normalized\n");
                            for ( Counter idx = 0 ; idx < nSpline; idx++){
                                Real w  = wv[ idx ];
                                if (( w >= outLambda0) && ( w<= outLambda1)) {
                                    Real f  = fl[ idx ];
                                    Real c  = cn[ idx ];
                                    Real nf = nz[ idx ];
                                    printf( "%#13.6g, %#13.6g, %#13.6g, %#13.6g  \n", w, f, c, nf );
                                }
                            }

                        }
                    }

                    zls_AkimaFree(zSpline); zSpline=NULL; nSpec=0;

                  } //( nSpec > 4 on continuum)

            } //( nSpec > 4 on fluxes)

            zls_DisposeQuantity1DArr(wv);
            zls_DisposeQuantity1DArr(fl);
            zls_DisposeQuantity1DArr(cn);
            zls_DisposeQuantity1DArr(nz);

        } // allocate arrays

    } else {
        Usage();
        return -1;
    }

    return err;

}

Counter ReadFluxFile(Q1DArr * wave, Q1DArr * flux, char * fileName ){

    Counter nSpec = 0;

    Q1DArr waveBuffer = NULL;
    Q1DArr fluxBuffer = NULL;

    *wave = NULL;
    *flux = NULL;

    zls_NewQuantity1DArr( &waveBuffer, 1000000L);
    zls_NewQuantity1DArr( &fluxBuffer, 1000000L);

    if ((waveBuffer != NULL)&&(fluxBuffer != NULL)){

        zFile ctlFile = zlsio_open ( fileName, "r" );

        if (ctlFile != NULL){
            char line[1024];

            zlsio_gets(ctlFile, line, 1024); printf("%s",line);
            zlsio_gets(ctlFile, line, 1024); printf("%s",line);
            zlsio_gets(ctlFile, line, 1024); printf("%s",line);
            zlsio_gets(ctlFile, line, 1024); printf("%s",line);
            zlsio_gets(ctlFile, line, 1024); printf("%s",line);
            zlsio_gets(ctlFile, line, 1024); printf("%s",line);
            zlsio_gets(ctlFile, line, 1024); printf("%s",line);

            while ( zlsio_gets(ctlFile, line, 1024) == noErr) {
                Real w,flx;
                sscanf( line, "%lf %lf", &w, &flx );
                waveBuffer[nSpec] =   w;
                fluxBuffer[nSpec] = flx;
                nSpec++;
            }

            zlsio_close( ctlFile);

            if ( nSpec > 0 ) {

                zls_NewQuantity1DArr( wave, nSpec );
                zls_NewQuantity1DArr( flux, nSpec );

                for (Counter idx = 0; idx < nSpec; idx++ ){

                    (*wave)[idx] = waveBuffer[idx];
                    (*flux)[idx] = fluxBuffer[idx];

                }

            }
        }

    }

    zls_DisposeQuantity1DArr(waveBuffer);
    zls_DisposeQuantity1DArr(fluxBuffer);

    return nSpec;

}

