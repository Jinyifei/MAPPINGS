
#include "zls.h"
#include "red_alaws.h"

/*!

 Read a spectrum  redden or de-redden and write to std out.
 Input files can be text or text.gz files

  v1.0.8

*/

    // Prototypes
Counter ReadFluxFile(Q1DArr * wave, Q1DArr * flux, char * fileName, Integer nSkip );

/*!
 Usage
 @param [in out] void   None
 @details
   Useage: red [-r Rv] [-c Cn] [-t typeID] [-s scale ] [-n skip ] flux25file

       Version: 1.0.8
       Args: optional Rv: AV/E(B-V) > ~2
                        if -r omitted Rv = 3.1

             optional  Cn: Nebula Reddening Constant
                        if -c omitted Cn = 1.0
                        if Cn < 0.0 then deredden

             optional  scale: Flux Scale Factor
                        if -s omitted scale = 1.0

             optional  typeID: Reddening Function
                        0: CCM89 Stellar Al/Av (default)
                        1: B07 Orion modified CMM89
                        2: F99 Fitzpatrick Al/E(B-V)
                        3: FM07 Fitzpatrick & Massa E(l-V)/E(B-V)
                        4: C00 Calzetti Extinction k(l)
                        5: FD05 Fischera Av=1.0 extinction
                        6: P70 Piembert Rv5.5 Orion Only
                        7: VCG04-14 UV ONLY Modified CMM89

             optional  skip: Input header lines to skip,
                        Defaults to 1 for general texts

   Required: Input file can be text or text.gz file
               Header lines and then two columns
               Lambda   Flambda

             Or a simle two column list in any order:
               Header lines and then two columns
               LineLambda   FLux

     Output: to stdout: lambda, flux, reddened flux, F(l), ...
             Suitable as a 7 column csv file
 */
void Usage(void){

    printf("\n  Useage: red [-r Rv] [-c Cn] [-t typeID] [-s scale ] [-n skip ] flux25file\n\n");
    printf("      Version: 1.0.8\n");
    printf("      Args: optional Rv: AV/E(B-V) > ~2 \n");
    printf("                       if -r omitted Rv = 3.1 \n\n");
    printf("            optional  Cn: Nebula Reddening Constant\n");
    printf("                       if -c omitted Cn = 1.0\n");
    printf("                       if Cn < 0.0 then deredden\n\n");
    printf("            optional  scale: Flux Scale Factor\n");
    printf("                       if -s omitted scale = 1.0\n\n");
    printf("            optional  typeID: Reddening Function\n");
    printf("                       0: CCM89 Stellar Al/Av (default)\n");
    printf("                       1: B07 Orion modified CMM89\n");
    printf("                       2: F99 Fitzpatrick Al/E(B-V)\n");
    printf("                       3: FM07 Fitzpatrick & Massa E(l-V)/E(B-V) \n");
    printf("                       4: C00 Calzetti Extinction k(l)\n");
    printf("                       5: FD05 Fischera Av=1.0 extinction\n");
    printf("                       6: P70 Piembert Rv5.5 Orion Only\n");
    printf("                       7: VCG04-14 UV ONLY Modified CMM89 \n\n");
    printf("            optional  skip: Input header lines to skip, \n");
    printf("                       Defaults to 1 for general texts \n\n");
    printf("  Required: Input file can be text or text.gz file\n");
    printf("              Header lines and then two columns\n");
    printf("              Lambda   Flambda\n");
    printf("            Or a simle two column list in any order:\n");
    printf("              Header lines and then two columns\n");
    printf("              LineLambda   FLux\n\n");
    printf("    Output: to stdout: lambda, flux, reddened flux, F(l), ... \n");
    printf("            Suitable as a 7 column csv file\n\n");

}

int main(int argc, char * argv[]) {

    int err = noErr;

    if (argc < 1){
        Usage();
        return -1;
    }

    int ch;
    extern char* optarg;

    Real Rv = 3.1;
    Real Cn = 1.0;
    Real Scale = 1.0;
    Integer nSkip = 1; // default to skip 1 lines
    Integer redID = 0; // default CCM89 reddening

    Integer optind = 0;
    while ((ch = getopt(argc, argv, "r:c:t:s:n:")) != -1) {
        optind++;
        switch (ch) {
            case 'n':
                nSkip = atoi( optarg );
                break;
            case 'r':
                Rv = atof( optarg );
                break;
            case 'c':
                Cn = atof( optarg );
                break;
            case 's':
                Scale = atof( optarg );
                break;
            case 't':
                redID = atoi( optarg );
                break;
            case '?':
            default:
                Usage();
                return -1;
        }
    }
    optind *= 2; // account for init args: 2 per arg
    optind += 1; // account for command name

    Rv = (Rv<2.0)?2.0:Rv;

    if ( argc == (optind+1) ) {

        Q1DArr wave = NULL;
        Q1DArr flux = NULL;

        // read flux from file arg

        char * fileName = argv[optind];
        Counter nSpec = ReadFluxFile(&wave, &flux, fileName, nSkip );

        if ( nSpec > 0 ){ // worked and got enough points :)

                err |= red_PrintType(redID);

                if (err == noErr ){

                    // Redden/Deredden and output to stdout

                    printf(" R_V = %#13.6g, Cn =  %#13.6g, Scale =  %#13.6g\n",
                             Rv, Cn, Scale);

                    if ( Cn < 0.0) {
                        printf(" De-reddened Fluxes: \n");
                    } else {
                        printf(" Reddened Fluxes: \n");
                    }

                    printf(" Wave (A air),          Flux,     Red flux ,          F(l), E(l-V)/E(B-V),   A(l)/E(B-V),       A(l)/AV\n");
                    for ( Counter idx = 0 ; idx < nSpec; idx++){
                        Real w  = wave[ idx ];

                        Real Eleb = fred_ElmVEBmV( Rv, w , redID);
                        Real Aleb = fred_AlEBmV  ( Rv, w , redID);
                        Real Alav = fred_AlAV    ( Rv, w , redID);
                        Real Fl   = fred_Fl_RV   ( Rv, w , redID);

                        Real f  = flux[ idx ];
                        Real lf = log10(f);
                        lf     -= Cn*Fl; // C -ve then de-redden
                        lf      = pow(10.0,lf)*Scale;

                        printf( "%#13.6g, %#13.6g, %#13.6g, %#13.6g, %#13.6g, %#13.6g, %#13.6g  \n",
                               w, f, lf, Fl, Eleb, Aleb, Alav );

                    }

                }

        } //( nSpec > 0 on fluxes)

    } else {
        Usage();
        return -1;
    }

    return err;

}

Counter ReadFluxFile(Q1DArr * wave, Q1DArr * flux, char * fileName, Integer nSkip ){

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

            for (Integer  idx = 0; idx < nSkip; idx++){
                zlsio_gets(ctlFile, line, 1024);printf("%s\n",line);
            }

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

