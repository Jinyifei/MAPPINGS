#include "zls.h"

/*
 lines: program to fit multiple gaussians to spectrum data
 lines -l linelist spectrumfile
 Input files can be text or text.gz files
 */

#include "lines.h"

int main(int argc, char * argv[]) {

  int err = noErr;

  if (argc < 3){
    Usage();
  }

 char s0[16];
 char s1[16];
 char s2[16];
 char s3[16];

  char patchFile [512]; // list of patches
  patchFile[0] = 0;
  patchFile[1] = 0;

  char subFile [512]; // optional spectrum with lines removed
  subFile[0] = 0;
  subFile[1] = 0;

  Integer nHeader = 0;

  Integer nListStart = -1;
  Integer nListEnd   = -1;

  Integer showPatches = 0;
  Integer showFullPatches = 0;
  Integer centrePatches = 0;
  Integer nShow = 0;
  Integer nShowStart = 0;
  Integer nShowEnd   = 0;

  Integer showContCoeffs = 0;
  Integer showDebug = 0;

  Integer subtractedSpectrum = 0;

  Integer optind = 0;

  int i = 0;
  int j = 0;
  int ch;
  extern char* optarg;
  while ((ch = getopt(argc, argv, "l:n:p:b:f:r:s:cd")) != -1) {

    optind++;
    switch (ch) {

      case 'l':
        strcpy(patchFile, optarg);
        break;
      case 's':
        subtractedSpectrum = 1;
        strcpy(subFile, optarg);
        break;
      case 'n':
        nHeader = atoi(optarg);
        break;
      case 'r':
        i = 0;
        j = 0;
        argRangeOptions(optarg, &i, &j);
        i = (i<0)? 0:i;
        j = (j<0)? 0:j;
        nListStart = i;
        nListEnd   = j;
        break;
      case 'f':
        showPatches = 1;
        showFullPatches = 1;
        centrePatches = 0;
        i = 0;
        j = 0;
        argRangeOptions(optarg, &i, &j);
        nShowStart = abs(i);
        nShowEnd   = abs(j);
        nShow      = nShowStart;
        break;
      case 'p':
        showPatches = 1;
        showFullPatches = 0;
        centrePatches = 0;
        i = 0;
        j = 0;
        argRangeOptions(optarg, &i, &j);
        if (i < 0) showFullPatches = 1;
        nShowStart = abs(i);
        nShowEnd   = abs(j);
        nShow      = nShowStart;
        break;
      case 'b':
        showPatches = 1;
        showFullPatches = 0;
        centrePatches = 1;
        i = 0;
        j = 0;
        argRangeOptions(optarg, &i, &j);
        if (i < 0) showFullPatches = 1;
        nShowStart = abs(i);
        nShowEnd   = abs(j);
        nShow      = nShowStart;
        break;
      case 'c':
        showContCoeffs = 1;
        break;
      case 'd':
        showDebug = 1;
        break;
      case '?':
      default:
        Usage();

    }

  }


  nListEnd   = (  nListEnd>0)?nListEnd:INT_MAX;
  nListStart = (nListStart>0)?nListStart:1;

  if (nListEnd < nListStart) nListEnd = nListStart;

  nShowEnd   = (  nShowEnd>0)?nShowEnd:INT_MAX;
  nShowStart = (nShowStart>0)?nShowStart:1;

  if (nShowEnd < nShowStart) nShowEnd = nShowStart;

  nHeader = (nHeader<0)?0:nHeader;

  if (argc > 2) {

    Counter nPatches      = 0;
    Counter lineIndex     = 0;
    patchArr p            = NULL;

    ////////////////////////////////////////////////////////////////////////
    nPatches = ReadPatchFile(&p, patchFile);
    ////////////////////////////////////////////////////////////////////////

    if (nPatches > 0){

      Counter nSpec     = 0;
      Q1DArr specCoord  = NULL;
      Q1DArr specFlux   = NULL;
      Q1DArr subFlux    = NULL;

      ////////////////////////////////////////////////////////////////////////
      // read flux from spectrum file arg, always the last arg
      ////////////////////////////////////////////////////////////////////////
      char * fileName = (char *)argv[argc-1];
      nSpec = ReadFluxFile(&specCoord, &specFlux, nHeader, fileName);
      ////////////////////////////////////////////////////////////////////////

      if (nSpec > 4) { // worked and got enough points :)

        ////////////////////////////////////////////////////////////////////////
        PrintHeader(fileName, patchFile, showContCoeffs);
        ////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////
        if (subtractedSpectrum > 0) {
          err = zls_NewQuantity1DArr(&subFlux,nSpec);
          if (err != noErr) {
            printf(" FATAL ERROR: subtracted spectrum allocation failed: %d.\n",nSpec);
            return err;
          }
          // copy for later subtraction of fits
          for (Counter idx = 0 ; idx < nSpec; idx++){
            subFlux[idx] = specFlux[idx];
          }
        }
        ////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////
        // one continuum var shared by patches, minimise malloc
        continuum cont;
        err = NewContinuum(&cont);
        if (err != noErr) {
          printf(" FATAL ERROR: continuum alloc failed. Err = %d\n",err);
          return err;
        }
        ////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////
        //
        // Now loop over the patch list, find patch, do fit and
        // write a patch segment for plotting along with fits if
        // requested
        //
        // get bins for left and right continuum and full range for entire patch
        ////////////////////////////////////////////////////////////////////////
        // Patch Loop
        ////////////////////////////////////////////////////////////////////////
        for ( Counter pidx = 0 ; pidx < nPatches; pidx++){

          ////////////////////////////////////////////////////////////////////////
          // patch number used in patch file,
          Counter pID = p[pidx].patchID;
          // may not be monotonic or contiguous,
          // but must be unique, hence an ID not idx.
          ////////////////////////////////////////////////////////////////////////


          ////////////////////////////////////////////////////////////////////////
          // number of lines in patch
          ////////////////////////////////////////////////////////////////////////
          Counter nGs = p[pidx].nLines;

          ////////////////////////////////////////////////////////////////////////
          // find left, right and overall spectrum bin indices for the patch
          ////////////////////////////////////////////////////////////////////////
          Real st = p[pidx].leftStart;
          Integer idxLeft0 = 0;
          for (Counter idx = 0 ; idx < nSpec; idx++){
            idxLeft0 = ((st - specCoord[idx]) > -EPSILON) ? idx : idxLeft0;
          }

          st = p[pidx].rightStart;
          Integer idxRight0 = 0;
          for (Counter idx = 0 ; idx < nSpec; idx++){
            idxRight0 = ((st - specCoord[idx]) > -EPSILON) ? idx : idxRight0;
          }

          Real en = p[pidx].leftEnd;
          Integer idxLeft1 = 0;
          for (Counter idx = 0 ; idx < nSpec; idx++){
            idxLeft1 = ((en - specCoord[idx]) > -EPSILON) ? idx : idxLeft1;
          }

          en = p[pidx].rightEnd;
          Integer idxRight1 = 0;
          for (Counter idx = 0 ; idx < nSpec; idx++){
            idxRight1 = ((en - specCoord[idx]) > -EPSILON) ? idx : idxRight1;
          }

          st = specCoord[idxLeft0]; // beginning of all
          en = specCoord[idxRight1]; // end of all
          Real patchCentre = 0.5*(st+en);  // patch centre
          p[pidx].patchCentre = patchCentre;
          ////////////////////////////////////////////////////////////////////////


          ////////////////////////////////////////////////////////////////////////
          // And mask bin indices if any
          ////////////////////////////////////////////////////////////////////////
          Integer idxMask0 = INT_MAX; // no mask by default even if useMask is wrong
          Integer idxMask1 = -1;

          if ( p[pidx].useMask > 0 ) {
            st = p[pidx].maskStart;
            for (Counter idx = 0 ; idx < nSpec; idx++){
              idxMask0 = ((st - specCoord[idx]) > -EPSILON) ? idx : idxMask0;
            }
            en = p[pidx].maskEnd;
            for (Counter idx = 0 ; idx < nSpec; idx++){
              idxMask1 = ((en - specCoord[idx]) > -EPSILON) ? idx : idxMask1;
            }
          }
          ////////////////////////////////////////////////////////////////////////

          ////////////////////////////////////////////////////////////////////////
          // continuum for this patch
          ////////////////////////////////////////////////////////////////////////
          cont.l0 = idxLeft0;
          cont.l1 = idxLeft1;
          cont.r0 = idxRight0;
          cont.r1 = idxRight1;

          cont.fixed   = p[pidx].continuumFitKind;
          cont.order   = p[pidx].continuumOrder;

          cont.cv      = p[pidx].continuumConstant;
          cont.cv0     = p[pidx].continuumLeft;
          cont.cv1     = p[pidx].continuumRight;
          cont.centreX = p[pidx].patchCentre;
          cont.leftX   = specCoord[idxLeft0]  - cont.centreX; // cont and lines are in patch centred coordinates
          cont.rightX  = specCoord[idxRight1] - cont.centreX;

          cont.useMask = p[pidx].useMask;
          cont.m0  = idxMask0;
          cont.m1  = idxMask1;
          ////////////////////////////////////////////////////////////////////////

          ////////////////////////////////////////////////////////////////////////
          // dynamic lines array for this patch
          ////////////////////////////////////////////////////////////////////////
          lines l;// one or more  lines in the patch, set common values
          err = NewLines(&l, nGs); // allocate sub arrays
          if (err != noErr) {
            printf(" FATAL ERROR: #%d ID%d patch line array alloc failed. Err = %d\n",pidx+1, p[pidx].patchID, err);
            return err;
          }
          ////////////////////////////////////////////////////////////////////////

          if (idxRight1 > idxLeft0 + 2) { // sensible patch

            Integer nBins = (idxRight1 - idxLeft0) + 1;

            ////////////////////////////////////////////////////////////////////////
            // allocate patch data arrays and load with spectrum
            ////////////////////////////////////////////////////////////////////////

            Q1DArr xq = NULL;
            Q1DArr yq = NULL;
            zls_NewQuantity1DArr(&xq, nBins);
            zls_NewQuantity1DArr(&yq, nBins);

            if ((xq != NULL) && (yq != NULL)) {

              ////////////////////////////////////////////////////////////////////////
              Real max = specFlux[idxLeft0];
              Real min = specFlux[idxLeft0];

              for (Counter idx = 0 ; idx < nBins; idx++){
                xq[idx] = specCoord[idxLeft0+idx]-patchCentre;
                yq[idx] = specFlux[idxLeft0+idx];
                Real f   = specFlux[idxLeft0+idx];
                max      = (max < f)? f : max;
                min      = (min > f)? f : min;
              }
              ////////////////////////////////////////////////////////////////////////

              ////////////////////////////////////////////////////////////////////////
              //
              // normalise to make continuum fit/errors as well behaved as
              // possible, if min is > 0, otherwise leave as is, could be
              // continuum subtracted already
              //
              ////////////////////////////////////////////////////////////////////////
              Real yScale    = 1.0; // scale to normalise
              Real invYScale = 1.0; // inv scale to renorm
              if ( min > 0.0 ){
                yScale    = pow(10.0,-floor(log10(min*2.0))); // scale to normalise
                invYScale = pow(10.0, floor(log10(min*2.0)));  // inv scale to renorm
              }

              // these belong to the patch
              p[pidx].scaleY    = yScale;
              p[pidx].invScaleY = invYScale;

              // and are copied to the continuum and lines for convenience
              cont.scaleY    = yScale;
              cont.invScaleY = invYScale;
              ////////////////////////////////////////////////////////////////////////

              Counter contKind     = cont.fixed; // kFreeContinuum = 0, = free (default), kFixedContinuum = 1  fixed
              Counter contOrder    = cont.order; // 0 const, 1, linear, 2 quad
              Counter fixedWidths  = p[pidx].fixedWidths; // > 0 fixed, == 0 free
              Counter fixedCentres = p[pidx].fixedCentres; // > 0 fixed, == 0 free


              ////////////////////////////////////////////////////////////////////////
              //
              //first fit to combined left and right sub-patches
              //
              ////////////////////////////////////////////////////////////////////////

              ////////////////////////////////////////////////////////////////////////
              // continuum fit, normalises inside, coeffs in normalised units, incl mask
              Counter badContinuum = 0;
              err = FitContinuum(&cont, specCoord, specFlux);
              if (err != noErr) {
                if (showDebug > 0) {
                  printf(" WARNING: #%d ID%d patch continuum fit failed numerically. Err = %d\n",pidx+1, p[pidx].patchID, err);

                }
                badContinuum = 1;
              }
              ////////////////////////////////////////////////////////////////////////
              if (badContinuum == 1) goto endLinesLabel; // sometimes the most direct is best :)

              ////////////////////////////////////////////////////////////////////////
              //
              // Now subtract the continuum fit and then find the remaining gaussian
              // put the whole (patch - continuum)fit into xq, yq, in normalised coords
              //
              ////////////////////////////////////////////////////////////////////////

              ////////////////////////////////////////////////////////////////////////
              // if a mask is present, just don't add data from mask range, and adjust nBins to suit
              ////////////////////////////////////////////////////////////////////////
              Integer premaskNBins = nBins;
              Counter dataIdx = 0;
              if (cont.useMask > 0) {
                for (Counter idx = 0 ; idx < nBins; idx++){
                  Counter specIdx = idxLeft0+idx;
                  if (!((specIdx>=cont.m0)&&(specIdx<=cont.m1))) { // add if not in mask
                    xq[dataIdx] = specCoord[specIdx]-cont.centreX;
                    Real fitC   = EvaluateContinuum  (&cont, xq[dataIdx]);
                    yq[dataIdx] = specFlux[specIdx]*cont.scaleY - fitC;
                    dataIdx++;
                  }
                }
                nBins = dataIdx; // less or equal to nBins
              } else {
                for (Counter idx = 0 ; idx < nBins; idx++){
                  xq[dataIdx] = specCoord[idxLeft0+idx]-cont.centreX;
                  Real fitC   = EvaluateContinuum  (&cont, xq[dataIdx]);
                  yq[dataIdx] = specFlux[idxLeft0+idx]*cont.scaleY - fitC;
                  dataIdx++;
                }
              }
              ////////////////////////////////////////////////////////////////////////

              ////////////////////////////////////////////////////////////////////////
              // Now get the lines (finally)
              ////////////////////////////////////////////////////////////////////////
              Counter badLines = 0;
              err = FitPatchLines(&l, xq, yq, nBins, pidx, p); // puts just the ai and sai coeffs for all lines into l
              if (err != noErr) {
                if (showDebug > 0) {
                  printf(" WARNING: #%d ID%d patch line fit failed numerically. Err = %d\n",pidx+1, p[pidx].patchID, err);
                }
                badLines = 1;
              }
              ////////////////////////////////////////////////////////////////////////
              if (badLines == 1) goto endLinesLabel; // sometimes the most direct is best :)

              ////////////////////////////////////////////////////////////////////////
              // subtract gaussians and measure RMS of residuals over the patch for each line
              ////////////////////////////////////////////////////////////////////////

              I1DArr n3FWBins   = NULL;
              Q1DArr sumOfSquares   = NULL;
              Q1DArr RMS            = NULL;
              err  = zls_NewInteger1DArr(&n3FWBins,  l.nlines);
              err |= zls_NewQuantity1DArr(&sumOfSquares,  l.nlines);
              err |= zls_NewQuantity1DArr(&RMS,  l.nlines);
              if (err != noErr){
                printf(" FATAL ERROR: #%d ID%d local line RMS memory allocation failed\n",pidx+1, p[pidx].patchID);
                return (err);
              }

              for (Counter gidx = 0; gidx < l.nlines; gidx++){
                n3FWBins[gidx]      = 0;
                sumOfSquares[gidx]  = 0.0;
                RMS[gidx]           = 0.0;
              }

              for (Counter idx = 0 ; idx < nBins; idx++){

                Real    x = specCoord[idxLeft0+idx]-cont.centreX;
                Real fitC = EvaluateContinuum  (&cont, xq[idx])*cont.invScaleY; // renormalise
                Real fitG = fGaussian (x, l.ai, l.nlines*3)*cont.invScaleY; // fit all at once and renormalise
                Real residual   = (specFlux[idxLeft0+idx] - fitC - fitG); /// minus all lines in group

                for (Counter gidx = 0; gidx < l.nlines; gidx++){
                  if ( fabs(l.ai[3*gidx+1] - x) <= 3.0*fabs(l.ai[3*gidx+2])*1.66511) {// within 3 FWHM of line centre
                    sumOfSquares[gidx] +=  (residual*residual);
                    n3FWBins[gidx] +=  1;
                  }
                }

                if ( subtractedSpectrum > 0 ) {
                  // save into the subtracted spectrum
                  subFlux[idxLeft0+idx] = subFlux[idxLeft0+idx] - fitG;
                }

              }

              // get the RMS residual in +/- 2FWHM of line centre, or entire patch, whichever is smaller.
              for (Counter gidx = 0; gidx < l.nlines; gidx++){
                RMS[gidx]  =  0.00;
                if (n3FWBins[gidx]> 0) RMS[gidx]  = sqrt(sumOfSquares[gidx]/n3FWBins[gidx]);
              }

              ////////////////////////////////////////////////////////////////////////

              ////////////////////////////////////////////////////////////////////////
              // if masked,
              // put nBins, xq, and yq back the way it was,
              // so any output patches show all the data
              // OK since initial arrays were allocated with premaskNBins value
              ////////////////////////////////////////////////////////////////////////
              if (cont.useMask > 0) {
                nBins = premaskNBins;
                for (Counter idx = 0 ; idx < nBins; idx++){
                  xq[idx]   = specCoord[idxLeft0+idx]-cont.centreX;
                  Real fitC = EvaluateContinuum  (&cont, xq[idx]);  // fitC is normalised
                  yq[idx]   = specFlux[idxLeft0+idx]*cont.scaleY - fitC;
                }
              }
              ////////////////////////////////////////////////////////////////////////

              ////////////////////////////////////////////////////////////////////////

              char fitKind[64];
              sprintf(fitKind,"");

              if ((fixedWidths > 0) && (fixedCentres > 0)) {
                sprintf(fitKind,"Fixed Width, Fixed Centre");
              } else if (fixedCentres > 0) {
                sprintf(fitKind,"Fixed Centre");
              } else if (fixedWidths > 0) {
                sprintf(fitKind,"Fixed Width");
              }

              if (contKind >= kFixedContinuum){

                if  (contOrder == 0) {
                  sprintf(fitKind,"%s, Fixed Const. Cont.",fitKind);
                } else {
                  sprintf(fitKind,"%s, Fixed Linear Cont.",fitKind);
                }

              } else {
                if  (contOrder == 0) {
                  sprintf(fitKind,"%s, Const. Cont.",fitKind);
                }
                if (contOrder == 1){
                  sprintf(fitKind,"%s, Linear Cont.",fitKind);
                }
                // if quadratic, ie default don't bother printing type
              }
              ////////////////////////////////////////////////////////////////////////

              ////////////////////////////////////////////////////////////////////////
              // now get patch lines info for printing to stdout
              ////////////////////////////////////////////////////////////////////////
              Real lineArea       = 0.0;
              Real lineContinuum  = 0.0;

              l.linesFitKind      = p[pidx].linesFitKind;

              l.l1 = idxLeft1;
              l.r0 = idxRight0;
              l.r1 = idxRight1;
              l.l0 = idxLeft0;
              l.l1 = idxLeft1;
              l.r0 = idxRight0;
              l.r1 = idxRight1;
              // and get centre and scales once from continuum
              l.centreX    = cont.centreX;
              l.leftX      = cont.leftX;
              l.rightX     = cont.rightX;
              l.scaleY     = cont.scaleY;
              l.invScaleY  = cont.invScaleY;
              ////////////////////////////////////////////////////////////////////////

              ////////////////////////////////////////////////////////////////////////
              // Patch lines gidx loop
              for (Counter gidx = 0; gidx < l.nlines; gidx++){

                lineIndex += 1;
                Counter lID = gidx+1; // ordinal value from patch file

                ////////////////////////////////////////////////////////////////////////
                //clear the line values
                l.lineCentre[gidx]  = 0.0;
                l.lineHeight[gidx]  = 0.0;
                l.lineWidth [gidx]  = 0.0;
                ////////////////////////////////////////////////////////////////////////


                ////////////////////////////////////////////////////////////////////////
                // values in spectrum units
                ////////////////////////////////////////////////////////////////////////
                lineArea            = EvaluateLineArea (&l, gidx)*l.invScaleY; // renormalised
                l.lineHeight[gidx] *= l.invScaleY;
                lineContinuum       = EvaluateContinuum ( &cont, l.lineCentre[gidx] )*cont.invScaleY;
                ////////////////////////////////////////////////////////////////////////

                ////////////////////////////////////////////////////////////////////////
                //
                // Simple intrinsic fit error on area, add continuum,
                // Since fit has sig2i = 1.0 for all points, chi2 != 1,
                // and we rescale the errors as if reduced chi2 were 1, a gaussian
                // maximum liklihood errror.
                //
                // width and height parameter errors in quadrature, including corvairiance term
                //
                // This is a formal fit error over the entire patch, if some lines are not
                // modelled they will appear as a large fitting error!
                //
                ////////////////////////////////////////////////////////////////////////
                Real relErrorHeight2 = (l.covar[gidx*3+0][gidx*3+0])/(l.ai[gidx*3+0]*l.ai[gidx*3+0]);                                                                                                      //  width relative error
                Real relErrorWidth2  = l.covar[gidx*3+2][gidx*3+2]/(l.ai[gidx*3+2]*l.ai[gidx*3+2]);
                // width-height covar relative error, nearly cancels the width term...
                // ***can and will be -ve!****
                Real relErrorCovar2  = (2.0*l.covar[gidx*3+0][gidx*3+2])/(l.ai[gidx*3+0]*l.ai[gidx*3+2]);
                Real relErrTotal     = 100.0*sqrt(fabs(relErrorHeight2+relErrorWidth2+relErrorCovar2)); // as a % age

                ////////////////////////////////////////////////////////////////////////
                // independent estimate, local to line, % RMS will include non-gaussian errrors.
                //
                // Will be small for good fits, even if other parts of the patch are poorly
                // modelled. Residual RMS over +/- 2FWHM
                ////////////////////////////////////////////////////////////////////////
                Real rmsOnPeak = 100.0*RMS[gidx]/l.lineHeight[gidx];

                ////////////////////////////////////////////////////////////////////////
                // Output  to stdout
                ////////////////////////////////////////////////////////////////////////

                ////////////////////////////////////////////////////////////////////////
                // output allowed by range
                if ((lineIndex >= nListStart) && ( lineIndex <= nListEnd)) {


                  if (showContCoeffs == 0){  // don't show continuum coefficients
                    PrintLineData(l, gidx, lineIndex, pID, lID, lineContinuum, lineArea, relErrTotal, rmsOnPeak,
                                  showPatches, fitKind);
                  } else {
                    PrintLineAndContData(l, cont, gidx, lineIndex, pID, lID, lineContinuum, lineArea, relErrTotal, rmsOnPeak,
                                         showPatches, fitKind);
                  }

                  if ((showPatches > 0) && (showFullPatches <= 0 ) &&
                      (((lineIndex >= nShowStart) && (lineIndex <= nShowEnd)) || (nShow <= 0))) {

                    PrintLineFitDetail(specCoord, specFlux, nSpec,
                                       xq, yq, nBins,
                                       p, cont, l, pidx, gidx,
                                       lineIndex , centrePatches);

                  }

                  if ((showPatches > 0) && (showFullPatches > 0 ) &&
                      (((lineIndex >= nShowStart) && (lineIndex <= nShowEnd)) || (nShow <= 0))) {

                    PrintFullLineFitDetail(specCoord, specFlux, nSpec,
                                       xq, yq, nBins,
                                       p, cont, l, pidx, gidx, lineIndex, centrePatches);

                  }

                }
                // output allowed by range
                ////////////////////////////////////////////////////////////////////////


              }
              // gidx line loop
              ////////////////////////////////////////////////////////////////////////

              if ( (showPatches < 0) && (showFullPatches > 0 ) &&
                  ((p[pidx].patchID >= nShowStart) && (p[pidx].patchID <= nShowEnd)) ) {

                PrintFullPatchFitDetail(specCoord, specFlux, nSpec,
                                       xq, yq, nBins,
                                       p, cont, l, pidx, centrePatches);

              }

              if (showDebug > 0) {
                ////////////////////////////////////////////////////////////////////////
                // Output what the code thinks the patch settings are, renumbered by pidx
                ////////////////////////////////////////////////////////////////////////

                Counter contOrder    = p[pidx].continuumOrder; // 0..+2
                Counter contKind     = p[pidx].continuumFitKind; // == 0 free, >= fixed
                Counter fixedWidths  = p[pidx].fixedWidths;  // > 0 fixed, == 0 free
                Counter fixedCentres = p[pidx].fixedCentres; // > 0 fixed, == 0 free
                Counter useMask      = p[pidx].useMask;      // > 0 used, == 0 none

                printf("##\n");
                if ( pID != (pidx+1)){
                  printf("# Previous Patch ID: %3.3d -- renumbered to %3.3d\n#\n",pID, pidx+1);
                }

                sprintf( s0,"%#11.4f",p[pidx].leftStart);
                sprintf( s1,"%#11.4f",p[pidx].leftEnd);
                sprintf( s2,"%#11.4f",p[pidx].rightStart);
                sprintf( s3,"%#11.4f",p[pidx].rightEnd);
                printf(" Patch_%3.3d_Left  = %s:%s \n Patch_%3.3d_Right = %s:%s \n",
                       pidx+1, trim(s0), trim(s1),
                       pidx+1, trim(s2), trim(s3));

                if (useMask > 0){
                  sprintf( s0,"%#11.4f",p[pidx].maskStart);
                  sprintf( s1,"%#11.4f",p[pidx].maskEnd);
                  printf(" Patch_%3.3d_Mask  = %s:%s \n",
                         pidx+1, trim(s0), trim(s1));
                }

                if (contKind == kFixedContinuum){
                  sprintf( s0,"%#12.5e",p[pidx].continuumLeft);
                  sprintf( s1,"%#12.5e",p[pidx].continuumRight);
                  sprintf( s2,"%#12.5e",p[pidx].continuumConstant);
                  if ( contOrder == 1) {
                    printf(" Patch_%3.3d_Continuum  = %s:%s\n",pidx+1, trim(s0), trim(s1));
                  } else {
                    printf(" Patch_%3.3d_Continuum  = %s \n",pidx+1, trim(s2));
                  }
                }

                if (fixedWidths > 0){
                  printf(" Patch_%3.3d_Fixed_Widths  = 1\n",pidx+1);
                }
                if (fixedCentres > 0){
                  printf(" Patch_%3.3d_Fixed_Centres = 1\n",pidx+1);
                }

                if (nGs == 1){
                  sprintf( s0,"%#11.4f",p[pidx].centers[0]);
                  sprintf( s1,"%#11.4f",p[pidx].widths[0]);
                  printf(" Patch_%3.3d_Line  = %s:%s\n",
                         pidx+1, trim(s0), trim(s1));

                } else {

                  printf(" Patch_%3.3d_nLines  = %d\n", pidx+1, nGs);
                  for (Counter idx = 0; idx < nGs; idx++){
                    sprintf( s0,"%#11.4f",p[pidx].centers[idx]);
                    sprintf( s1,"%#11.4f",p[pidx].widths[idx]);
                    printf(" Patch_%3.3d_Line_%2.2d  = %s:%s\n",
                           pidx+1, idx+1, trim(s0), trim(s1));

                  }

                }
                printf("#\n");

                ////////////////////////////////////////////////////////////////////////
              }
              //              zls_DisposeQuantity2DArr(residuals); residuals = NULL;
              //              zls_DisposeQuantity2DArr(gs); gs = NULL;
              //              zls_DisposeQuantity1DArr(sumOfGs); sumOfGs = NULL;

              zls_DisposeInteger1DArr(n3FWBins); n3FWBins = NULL;
              zls_DisposeQuantity1DArr(sumOfSquares); sumOfSquares = NULL;
              zls_DisposeQuantity1DArr(RMS); RMS = NULL;
              //
              //              zls_DisposeQuantity1DArr(sumOfWSquares); sumOfWSquares = NULL;
              //              zls_DisposeQuantity1DArr(wRMS); wRMS = NULL;

            endLinesLabel: ; // skip point if lines fit is numerically invalid

            } else {
              printf(" FATAL ERROR: #%d ID%d patch memory allocation failed: %d bins\n",pidx+1, p[pidx].patchID, nBins);
              return err;
            } // xq yq

            zls_DisposeQuantity1DArr  (xq); xq = NULL;
            zls_DisposeQuantity1DArr  (yq); yq = NULL;

          } else { //  !(idxRight1 > idxLeft0+2)
                   ////////////////////////////////////////////////////////////////////////
                   // usually happens when patch is not valid or simply not present
                   ////////////////////////////////////////////////////////////////////////
            if (showDebug > 0) {
              printf(" WARNING: #%d ID%d bad bin ranges: %d -- %d\n",pidx+1, p[pidx].patchID, idxLeft0, idxRight1);
              printf("         The points for this patch were not found in the spectrum file.\n");
              printf("         Either the patch was specified badly,\n");
              printf("         or the patch is legitimately outside\n");
              printf("         the range of the spectrum file.\n");
            }
          } // idx range

          ////////////////////////////////////////////////////////////////////////
          DisposeLines(&l);
          ////////////////////////////////////////////////////////////////////////


        } // patch loop
          ////////////////////////////////////////////////////////////////////////

        DisposeContinuum(&cont);

        ////////////////////////////////////////////////////////////////////////
        // Output subtracted spectrum if requested
        ////////////////////////////////////////////////////////////////////////
        if ( subtractedSpectrum > 0 ) {
          printSubtractedSpectrum ( subFile, fileName, patchFile,
                                   specCoord, specFlux, subFlux, nSpec);
        }
        ////////////////////////////////////////////////////////////////////////

      } else { // nSpec < 5
        NoSpectrum(nHeader);
      } //(nSpec > 4 on fluxes)

    } else { // nPatches < 1
      InvalidLineList();
    }

  } else {
    Usage();
  }
  return err;
}


////////////////////////////////////////////////////////////////////////
//
// command interface
//
////////////////////////////////////////////////////////////////////////


void Usage(void){

  printf("\n  lines: Spectral line measurements. %s\n",VERSION);
  printf("\n  Useage: lines [-c -d -s subFile -p n[:m] -b n[:m] -r n[:m]] -l patchList [-n nlines ] spectrumFile\n");
  printf("      Args: required: -l patchList (see example list.txt for format)\n");
  printf("            required: spectrumFile, two cols, wavelength - flambda\n");
  printf("                      file can be text or text.gz file\n");
  printf("                      n header lines (default 0) and then two columns:\n");
  printf("                      Lambda  Flambda\n");
  printf("            optional: -n number of header lines in spectrumfile, default 0\n");
  printf("            optional: -r n or -r n:m print output for just line #n or lines #n:m\n");
  printf("            optional: -c output the continuum quadratic coefficients, a, b, c: a + bx + cx^2\n");
  printf("            optional: -s output the spectrum with all gaussian lines subtracted, leaving residual continuum\n");
  printf("            optional: -p n or -p n:m print out line fit #n or #n to #m, 0 for all.\n");
  printf("            optional: -p n or -p n:m print out line fit +/- 3FWHM,\n");
  printf("                      for line #n or #n to #m, -p 0 for all lines\n");
  printf("            optional: -f as p but prinout each line fit over full patch, not just  +/- 3FWHM,\n");
  printf("            optional: -b as p but with patch centred on the line\n");
  printf("            optional: -d output debugging information - especially to renumber patches\n");
  printf("    Output: std out line fits suitable for csv/text file, redirect to a csv filename for example\n\n");

  exit(-1);

}

void InvalidLineList(void){

  printf("\n  lines: Spectral line measurements. %s\n",VERSION);
  printf("    ERROR: No valid line list found in patchList file --\n");
  printf("         Malformed, invalid or missing input list file.\n\n");
  exit(-1);

}

void NoSpectrum(Integer n){

  printf("\n  lines: Spectral line measurements. %s\n",VERSION);
  printf("    ERROR: No valid spectrum found -- One of:\n");
  printf("         File Not Found, or \n");
  printf("         Incorrect header lines skipped [%d] (use -n to change) , or\n", n);
  printf("         Insufficient numer of points found (must be 5 or more) , or\n");
  printf("         -c or -d options with additional unwanted arguments, or\n");
  printf("         Malformed, or invalid or input spectrum file.\n\n");
  exit(-1);

}

Counter argRangeOptions(char * opt, int *i, int *j){

  Integer ncp;
  char* cp = strchr(opt, ':');

  *i = 0;
  *j = 0;

  if (cp) {
    *j = atoi(cp+1);
    ncp = (Integer)strcspn(opt, ":");
    if (ncp > 0) {
      opt[ncp]='\0';
      *i = atoi(opt);
      return (2);// found two
    } else {
      *i = *j;
      return (3);// found only 1, second arg
    }
  } else {
    *i = atoi(opt);
    *j = *i;
    return (1);// found 1, first arg
  }

  return (0);

}

Counter processRangeOptions(char * opt, Real *r0, Real *r1){

  Integer ncp;
  char* cp = strchr(opt, ':');
  *r0 = 0.0;
  *r1 = 0.0;

  if (cp) {
    *r1 = atof(cp+1);
    ncp = (Integer)strcspn(opt, ":");
    if (ncp > 0) {
      opt[ncp]='\0';
      *r0 = atof(opt);
      return (2);// found two
    } else {
      *r0 = *r1;
      return (3);// found only 1, second arg
    }
  } else {
    *r0 = atof(opt);
    *r1 = *r0;
    return (1);// found 1, first arg
  }

  return (0);

}


////////////////////////////////////////////////////////////////////////
//
// LifeCycle
//
////////////////////////////////////////////////////////////////////////


int NewPatchArr(patchArr * p, Counter nP) {
  int err = noErr;
  *p = (patchArr)calloc(1,sizeof(patch) * nP);
  if (*p == NULL) {
    err = memErr;
  }
  return(err);
}

int DisposePatchArr(patchArr p){

  int err = noErr;

  if (p != NULL) {
    free((void *) p);
  } else {err = memErr;}

  return(err);

}

int NewLines(lines * l, Counter nL){

  int err = noErr;

  // new empty lines
  l->linesFitKind = kGaussianLines;
  l->nlines = nL;

  l->lineCentre = NULL;
  l->lineHeight = NULL;
  l->lineWidth  = NULL;
  err |= zls_NewQuantity1DArr(&l->lineCentre, nL);
  err |= zls_NewQuantity1DArr(&l->lineHeight, nL);
  err |= zls_NewQuantity1DArr(&l->lineWidth, nL);

  l->centreX   = 0.0;
  l->scaleY    = 1.0;
  l->invScaleY = 1.0;

  l->ai  = NULL;
  l->sai = NULL;
  l->fai = NULL;
  err |= zls_NewQuantity1DArr(&l->ai , nL*3); // 3 coeffs per line
  err |= zls_NewQuantity1DArr(&l->sai, nL*3);
  err |= zls_NewInteger1DArr(&l->fai, nL*3);
  err |= zls_NewQuantity2DArr(&l->covar, nL*3, nL*3);

  // allocated

  l->l0 = 0; l->l1 = 0;
  l->r0 = 0; l->r1 = 0;
  l->m0 = 0; l->m1 = 0;

  l->useMask = 0;

  return err;
}


void DisposeLines(lines * l){

  // new empty lines
  l->nlines = 0;

  zls_DisposeQuantity1DArr(l->lineCentre);l->lineCentre=NULL;
  zls_DisposeQuantity1DArr(l->lineHeight);l->lineHeight=NULL;
  zls_DisposeQuantity1DArr(l->lineWidth) ;l->lineWidth=NULL;

  zls_DisposeQuantity1DArr(l->ai );l->ai =NULL;
  zls_DisposeQuantity1DArr(l->sai);l->sai=NULL;
  zls_DisposeInteger1DArr(l->fai) ;l->fai=NULL;
  zls_DisposeQuantity2DArr(l->covar);l->covar=NULL;

}

int NewContinuum (continuum * c ){
  int err = noErr;
  c->ai  = NULL;
  c->sai = NULL;
  c->fai = NULL;
  err |= zls_NewQuantity1DArr(&c->ai , 3); // 3 coeffs per continuum
  err |= zls_NewQuantity1DArr(&c->sai, 3);
  err |= zls_NewInteger1DArr (&c->fai, 3);

  c->ai[0]  = 0.0;
  c->ai[1]  = 0.0;
  c->ai[2]  = 0.0;
  c->sai[0] = 0.0;
  c->sai[2] = 0.0;
  c->sai[2] = 0.0;
  c->fai[0] = 0;
  c->fai[1] = 0;
  c->fai[2] = 0;

  c->l0 = 0; c->l1 = 0;
  c->r0 = 0; c->r1 = 0;
  c->m0 = 0; c->m1 = 0;
  c->useMask = 0; // use a mask for continuum

  c->fixed     = 0; // >= 1 fixed, 0 free (default)
  c->order     = 0; // 0 const fit, 1 linear fit, 2 quadratic (default)

  c->cv        = 0.0; // centre
  c->cv0       = 0.0; // left
  c->cv1       = 0.0; // right
  c->centreX   = 0.0;
  c->leftX     = 0.0;
  c->rightX    = 0.0;

  c->scaleY    = 1.0;
  c->invScaleY = 1.0;

  return err;
}
void DisposeContinuum (continuum *c ){
  zls_DisposeQuantity1DArr(c->ai );c->ai =NULL;
  zls_DisposeQuantity1DArr(c->sai);c->sai=NULL;
  zls_DisposeInteger1DArr(c->fai);c->fai=NULL;
}

////////////////////////////////////////////////////////////////////////
//
// Fitting and Evaluation
//
////////////////////////////////////////////////////////////////////////



int FitNGaussianLines(Q1DArr ai, Q1DArr sai, I1DArr fai,
                      Q1DArr x, Q1DArr y, Integer nBins,
                      patch p, Q2DArr cv, Real * chi2 ) {

  int err = noErr;

  // x data in patch centre = 0.0 coordinates, centre used in c
  // y data in normalised scale, scale used in s
  // Gaussian fit coeffs, three per gaussian
  // initial values
  // 0 = Peak, 1 = centre - patch centre, 2 = width (sqrt2*sigma)
  // ai coeff resutls
  // sai coeff sigma rsults
  // fai coeffs   0 = free 1 = fixed input

  Counter nGs = p.nLines;

  for (Counter gidx = 0; gidx < nGs; gidx++){

    // get initial peak value estimate from bin nearest line centre
    Real lineCentre = p.centers[gidx] - p.patchCentre ; // initial guess centres in patch centre coords
    Integer cwIdx = 0;
    for (Counter idx = 0 ; idx < nBins; idx++){
      cwIdx = ((lineCentre - x[idx]) > -EPSILON) ? idx : cwIdx;
    }
    Real centreFlux = y[nBins/2];
    if ((cwIdx > 0) && (cwIdx < nBins))
      centreFlux = y[cwIdx];
    Real lineWidth = p.widths[gidx]; // initial guess centres in patch centre coords

    ai[gidx*3]     = centreFlux;// gaussian height ~ flux near line centre
    ai[gidx*3+1]   = lineCentre;// gaussian centre, - patch
    ai[gidx*3+2]   = lineWidth; // gaussian sqrt(2)*sigma

    sai [gidx*3]   = 0.0;
    fai [gidx*3]   = 0; // peak always free

    sai [gidx*3+1] = 0.0;
    fai [gidx*3+1] = p.fixedCentres; // 0 free 1 to fix centres

    sai [gidx*3+2] = 0.0;
    fai [gidx*3+2] = p.fixedWidths; // 0 free 1 to fix widths

  }

  err= LMFit (x, y, nBins, NULL, 0,
              fai, ai, sai, nGs*3,  // 3 for each line
              kFitFNGaussians, chi2, cv);

//
//  err = MRQGaussFit  (x, y, nBins, NULL, 0,
//                      fai, ai, sai, nGs*3,  // 3 for each gaussian
//                      0, chi2, cv);

  return err;

}


Real EvaluateGaussianArea(lines * l, Counter gidx) {
  Real h  = l->ai[gidx*3+0];
  Real c  = l->ai[gidx*3+1];
  Real w  = l->ai[gidx*3+2]*1.66511; // [2*sqrt(2*ln(2))]/sqrt(2), FWHM = 2.35482*sigma = 2.35482*w/1.41421
  Real A  = h*w*1.064467; // area = H*FHWM*sqrt(2*pi)/[2*sqrt(2*ln(2))]
  l->lineHeight[gidx] = h;
  l->lineCentre[gidx] = c;
  l->lineWidth[gidx]  = w;
  return A;
}


int FitNLorentzianLines(Q1DArr ai, Q1DArr sai, I1DArr fai,
                       Q1DArr x, Q1DArr y, Integer nBins,
                       patch p, Q2DArr cv, Real * chi2 ) {

  int err = noErr;

  // x data in patch centre = 0.0 coordinates, centre used in c
  // y data in normalised scale, scale used in s
  // Gaussian fit coeffs, three per gaussian
  // initial values
  // 0 = Peak, 1 = centre - patch centre, 2 = width (sqrt2*sigma)
  // ai coeff resutls
  // sai coeff sigma rsults
  // fai coeffs   0 = free 1 = fixed input

  Counter nGs = p.nLines;

  for (Counter gidx = 0; gidx < nGs; gidx++){

    // get initial peak value estimate from bin nearest line centre
    Real lineCentre = p.centers[gidx] - p.patchCentre ; // initial guess centres in patch centre coords
    Integer cwIdx = 0;
    for (Counter idx = 0 ; idx < nBins; idx++){
      cwIdx = ((lineCentre - x[idx]) > -EPSILON) ? idx : cwIdx;
    }
    Real centreFlux = y[nBins/2];
    if ((cwIdx > 0) && (cwIdx < nBins))
      centreFlux = y[cwIdx];
    Real lineWidth = p.widths[gidx]; // initial guess centres in patch centre coords

    ai[gidx*3]     = centreFlux;// gaussian height ~ flux near line centre
    ai[gidx*3+1]   = lineCentre;// gaussian centre, - patch
    ai[gidx*3+2]   = lineWidth; // gaussian sqrt(2)*sigma

    sai [gidx*3]   = 0.0;
    fai [gidx*3]   = 0; // peak always free

    sai [gidx*3+1] = 0.0;
    fai [gidx*3+1] = p.fixedCentres; // 0 free 1 to fix centres

    sai [gidx*3+2] = 0.0;
    fai [gidx*3+2] = p.fixedWidths; // 0 free 1 to fix widths

  }

  err= LMFit (x, y, nBins, NULL, 0,
              fai, ai, sai, nGs*3,  // 3 for each line
              kFitFNLorentzians, chi2, cv);

  return err;

}


Real EvaluateLorentzianArea(lines * l, Counter gidx) {
  Real h  = l->ai[gidx*3+0];
  Real c  = l->ai[gidx*3+1];
  Real w  = l->ai[gidx*3+2]*2.0;
  Real A  = l->ai[gidx*3+0]*l->ai[gidx*3+2]*M_PI;
  l->lineHeight[gidx] = h;
  l->lineCentre[gidx] = c;
  l->lineWidth[gidx]  = w;
  return A;
}



Real EvaluateLineArea(lines * l, Counter gidx) {
  if (l->linesFitKind == kGaussianLines){
     return EvaluateGaussianArea  (l, gidx);
  } else {
    return EvaluateLorentzianArea (l, gidx);
  }
}



int FitContinuum( continuum * c, Q1DArr x, Q1DArr y ) {

  int err = noErr;

  Q1DArr ai  = c->ai;
  Q1DArr sai = c->sai;
  I1DArr fai = c->fai;

  //
  // fit quadratic to combined left and right sub-patches,
  // in spectrum coordinates centre and scale for fit
  //

  Counter nCont = (c->l1 - c->l0 +1) + (c->r1 - c->r0 + 1) ;

  Q1DArr xq = NULL;
  Q1DArr yq = NULL;
  err |= zls_NewQuantity1DArr(&xq, nCont);
  err |= zls_NewQuantity1DArr(&yq, nCont);

  if ((xq == NULL) || (yq == NULL)) {
    exit(memErr);
  }

  Counter idxCont = 0;

  if (c->useMask > 0){ // dont use mask region for continuum

    for (Counter idx = c->l0 ; idx <= c->l1; idx++){
      if (!((idx>=c->m0)&&(idx<=c->m1))) { // not in mask
        xq[idxCont] = x[idx]-c->centreX;
        yq[idxCont] = y[idx]*c->scaleY;
        idxCont++;
      }
    }

    for (Counter idx = c->r0 ; idx <= c->r1; idx++){
      if (!((idx>=c->m0)&&(idx<=c->m1))) { // not in mask
        xq[idxCont] = x[idx]-c->centreX;
        yq[idxCont] = y[idx]*c->scaleY;
        idxCont++;
      }
    }

  } else {

    for (Counter idx = c->l0 ; idx <= c->l1; idx++){
      xq[idxCont] = x[idx]-c->centreX;
      yq[idxCont] = y[idx]*c->scaleY;
      idxCont++;
    }

    for (Counter idx = c->r0 ; idx <= c->r1; idx++){
      xq[idxCont] = x[idx]-c->centreX;
      yq[idxCont] = y[idx]*c->scaleY;
      idxCont++;
    }

  }

  nCont = idxCont;// allows for masking

  for (Counter idx = 0 ; idx < 3; idx++){
    ai[idx] = 0.0;
    sai[idx] = 0.0;
    fai[idx] = 0; // all free parameters
  }

  Real chi2 = 0.0; // chi 2

  Integer order = c->order;
  Integer fixedValues = c->fixed;

  if ( fixedValues == 0 ) {
    // free fitting

    switch ( order ) {
      default:
      case 2: // quadratic
        err = LinearFitPoly (xq, yq, nCont, NULL, 0,
                             fai, ai, sai, 3, kFitFNPower, &chi2, NULL);
        break;
      case 1: // linear
        fai[2] = 1; // fix quad term   = 0.0
        err = LinearFitPoly (xq, yq, nCont, NULL, 0,
                             fai, ai, sai, 2, kFitFNPower, &chi2, NULL);
        break;
      case 0: // constant, but free!
        fai[2] = 1; // fix quad term   = 0.0
        fai[1] = 1; // fix linear term = 0.0
        err = LinearFitPoly (xq, yq, nCont, NULL, 0,
                             fai, ai, sai, 1, kFitFNPower, &chi2, NULL);
    }

  } else {
    // same order as free, but all precomputed  terms
    fai[2] = 1; // fix quad term   = 0.0
    fai[1] = 1; // fix linear term = 0.0
    fai[0] = 1; // fix constant term = 0.0

    switch ( order ) {
      default:
      case 0:
        ai[0] = c->cv*c->scaleY;
        ai[1] = 0.0;
        ai[2] = 0.0;
        break;
      case 2: // shouldn't happen, drop to linear
      case 1:
        ai[0]  = 0.5*(c->cv0+c->cv1)*c->scaleY; // centred
        Real slope =  (c->cv1-c->cv0)/(c->rightX-c->leftX);
        ai[1]  = slope*c->scaleY;
        ai[2]  = 0.0;
    }

    // not really needed, but it sets the sais
    //    err = LinearFitPoly (xq, yq, nCont, NULL, 0,
    //                         fai, ai, sai, 2, kFitFNPower, &rchi); // limited to 2 terms


  } // same order as free, but fixed terms

  // Since we don't assign formal errors to ys, we 'correct' variances
  // cf NR chapter 15, near 15.2.13

  Real cc = sqrt(fabs(chi2)/(nCont-2));
  for (Counter idx = 0 ; idx < 3; idx++){
    sai[idx] *= cc;
  }

  zls_DisposeQuantity1DArr  (xq);
  zls_DisposeQuantity1DArr  (yq);

  return err;
}

int FitPatchLines ( lines * l, Q1DArr xq, Q1DArr  yq,Counter nBins, Counter pidx, patch * p){

  int err = noErr;

  Counter nGs = p[pidx].nLines;

  l->nlines  =  p[pidx].nLines;

  Q1DArr   ai = l->ai;
  Q1DArr  sai = l->sai;
  I1DArr  fai = l->fai;
  Q2DArr   cv = l->covar;

  // clear for safety
  for (Counter idx = 0 ; idx < nGs*3; idx++){
    ai[idx]  = 0.0;
    sai[idx] = 0.0;
    fai[idx] = 0;
    for (Counter jdx = 0 ; jdx < nGs*3; jdx++){
      cv[jdx][idx] = 0.0;
    }
  }

  // patch contains counts and centres etc
  // yq is normalised, xq centred on the patch
  Real chi2;

  if (l->linesFitKind == kGaussianLines ) {
    err = FitNGaussianLines(ai, sai, fai,
                          xq, yq, nBins,
                          p[pidx], cv, &chi2);
  } else {
    err = FitNLorentzianLines(ai, sai, fai,
                            xq, yq, nBins,
                            p[pidx], cv, &chi2);
  }

  // Since we don't assign formal errors to ys, ie set sigi2 = 1.0, we 'correct' variances
  // cf NR chapter 15, near 15.2.13

  Real cc = (fabs(chi2)/(nBins-2));

  for (Counter idx = 0 ; idx < nGs*3; idx++){
    sai[idx] *= sqrt(cc);
    for (Counter jdx = 0 ; jdx < nGs*3; jdx++){
      cv[jdx][idx] *= cc;
    }
  }

  return err;

}


////////////////////////////////////////////////////////////////////////
//
// std out I/O
//
////////////////////////////////////////////////////////////////////////

void PrintHeader(char * fileName, char * patchFile, Integer showContCoeffs){

  printf(" lines   : %s\n",VERSION);
  printf(" Spectrum: %s \n",fileName);
  printf(" LineList: %s \n",patchFile);
  time_t  currTime = time(NULL);
  printf(" Date:  %s", ctime(&currTime));
  if (showContCoeffs == 0){  // don't show continuum coefficients
    printf("   Line#, PatchID, Kind,      Left,     Right, fit Centre,    fit Peak,    fit FWHM, fitContinuum, Total Flux, 1sig Flux %%, 3FW-RMSr/Peak %%\n");
  } else { // show continuum coefficient
    printf("   Line#, PatchID, Kind,      Left,     Right, fit Centre,    fit Peak,    fit FWHM,     Cont: a,     Cont: b,     Cont: c, fitContinuum, Total Flux, 1s Flux%%,RMSr/Peak%%\n");
  }

}

void  PrintLineData(lines l, Counter gidx, Counter lineIndex, Counter pid, Counter lid,
                    Real lineContinuum, Real lineArea, Real releErrorArea, Real lineRMSResidue,
                    Integer showPatches, char * fitType){

  if (showPatches == 0) {
    if (strlen(fitType)>0) {
      printf("   %4d ,  %3.3d.%2.2d,  %1d  , %#9.3f, %#9.3f, %#10.4f,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#9.3g,%#9.3g, %s\n",
             lineIndex,pid,lid, l.linesFitKind, l.leftX+l.centreX, l.rightX+l.centreX, l.lineCentre[gidx]+l.centreX,
             l.lineHeight[gidx],l.lineWidth[gidx],
             lineContinuum,lineArea,releErrorArea,lineRMSResidue,fitType);
    } else {
      printf("   %4d ,  %3.3d.%2.2d,  %1d  , %#9.3f, %#9.3f, %#10.4f,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#9.3g,%#9.3g,\n",
             lineIndex,pid,lid, l.linesFitKind, l.leftX+l.centreX, l.rightX+l.centreX, l.lineCentre[gidx]+l.centreX,
             l.lineHeight[gidx],l.lineWidth[gidx],
             lineContinuum,lineArea,releErrorArea,lineRMSResidue);
    }
  } else {

    if (strlen(fitType)>0) {
      printf("c,  %4d ,  %3.3d.%2.2d,  %1d  , %#9.3f, %#9.3f, %#10.4f,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#9.3g,%#9.3g, %s\n",
             lineIndex,pid,lid, l.linesFitKind,l.leftX+l.centreX, l.rightX+l.centreX, l.lineCentre[gidx]+l.centreX,
             l.lineHeight[gidx],l.lineWidth[gidx],
             lineContinuum,lineArea,releErrorArea,lineRMSResidue,fitType);
    } else {
      printf("c,  %4d ,  %3.3d.%2.2d,  %1d  , %#9.3f, %#9.3f, %#10.4f,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#9.3g,%#9.3g\n",
             lineIndex,pid,lid, l.linesFitKind,l.leftX+l.centreX, l.rightX+l.centreX, l.lineCentre[gidx]+l.centreX,
             l.lineHeight[gidx],l.lineWidth[gidx],
             lineContinuum,lineArea,releErrorArea,lineRMSResidue);
    }

  }

}

void  PrintLineAndContData(lines l, continuum cont, Counter gidx, Counter lineIndex,Counter pid, Counter lid,
                           Real lineContinuum, Real lineArea, Real releErrorArea, Real lineRMSResidue,
                           Integer showPatches, char * fitType) {

  if (showPatches == 0) {
    if (strlen(fitType)>0) {
      printf("   %4d ,  %3.3d.%2.2d,  %1d  , %#9.3f, %#9.3f, %#10.4f,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#9.3g,%#9.3g, %s\n",
             lineIndex,pid,lid, l.linesFitKind, l.leftX+l.centreX, l.rightX+l.centreX, l.lineCentre[gidx]+l.centreX,
             l.lineHeight[gidx],l.lineWidth[gidx],
             cont.ai[0]*cont.invScaleY,cont.ai[1]*cont.invScaleY,cont.ai[2]*cont.invScaleY,
             lineContinuum,lineArea,releErrorArea,lineRMSResidue,fitType);
    } else {
      printf("   %4d ,  %3.3d.%2.2d,  %1d  , %#9.3f, %#9.3f, %#10.4f,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#9.3g,%#9.3g\n",
             lineIndex,pid,lid, l.linesFitKind, l.leftX+l.centreX, l.rightX+l.centreX, l.lineCentre[gidx]+l.centreX,
             l.lineHeight[gidx],l.lineWidth[gidx],
             cont.ai[0]*cont.invScaleY,cont.ai[1]*cont.invScaleY,cont.ai[2]*cont.invScaleY,
             lineContinuum,lineArea,releErrorArea,lineRMSResidue);
    }

  } else {

    if (strlen(fitType)>0) {
      printf("c,  %4d ,  %3.3d.%2.2d,  %1d  , %#9.3f, %#9.3f, %#10.4f,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#9.3g,%#9.3g, %s\n",
             lineIndex,pid,lid, l.linesFitKind,l.leftX+l.centreX, l.rightX+l.centreX, l.lineCentre[gidx]+l.centreX,
             l.lineHeight[gidx],l.lineWidth[gidx],
             cont.ai[0]*cont.invScaleY,cont.ai[1]*cont.invScaleY,cont.ai[2]*cont.invScaleY,
             lineContinuum,lineArea,releErrorArea,lineRMSResidue,fitType);
    } else {
      printf("c,  %4d ,  %3.3d.%2.2d,  %1d  , %#9.3f, %#9.3f, %#10.4f,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#12.5e,%#9.3g,%#9.3g\n",
             lineIndex,pid,lid, l.linesFitKind,l.leftX+l.centreX, l.rightX+l.centreX, l.lineCentre[gidx]+l.centreX,
             l.lineHeight[gidx],l.lineWidth[gidx],
             cont.ai[0]*cont.invScaleY,cont.ai[1]*cont.invScaleY,cont.ai[2]*cont.invScaleY,
             lineContinuum,lineArea,releErrorArea,lineRMSResidue);
    }
  }

}

void PrintLineFitDetail(Q1DArr specCoord, Q1DArr specFlux, Counter nSpec,
                        Q1DArr xq, Q1DArr yq, Counter nBins,
                        patchArr p, continuum cont,lines l, Counter pidx, Counter gidx,
                        Counter lineIndex, Counter centrePatches){

  Integer pID = p[pidx].patchID;
  Integer lID = gidx+1;
  Real  patchCentre = p[pidx].patchCentre;
  Counter idxLeft0  = cont.l0;
  Real lineWidth    = l.lineWidth[gidx];
  const Integer iov   = 5;
  const Integer iovd2 = iov/2;
  const Real ov = 1.0*iov;

  if (centrePatches > 0) {
    // do data + fit 4x oversampled
    Real dx =  (xq[nBins-1] - xq[0])/(ov*(nBins-1));
    printf(" Line %d ID %3.3d.%2.2d Centred Fit Points at %dx X-sampling:\n Wave - %#10.6f (A),  total Fit ,  Continuum, data(oversampled)\n",
           lineIndex, pID, lID, iov, patchCentre);
    for (Counter idx = 0 ; idx <= (nBins*iov); idx++){
      Real x    = xq[0] + dx*idx;  // fit coordinates
      if (fabs(x-l.lineCentre[gidx])<=(3.0*lineWidth)) {
        Integer specIndex = idxLeft0+((idx+iovd2)/iov);
        specIndex = (specIndex < 0)? 0: specIndex;
        specIndex = (specIndex >= nSpec)? nSpec-1: specIndex;
        Real data = specFlux[specIndex];
        Real fitC = EvaluateContinuum  (&cont, x)*cont.invScaleY; // renormalise
        Real fitG = EvaluateLine(&l, gidx, x)*l.invScaleY; // renormalise
        printf("%#11.5f, %#12.5e, %#12.5e, %#12.5e\n", x-l.lineCentre[gidx], fitG+fitC, fitC, data);
      }
    }

  } else {
    // just the smooth fit, to overplot on data, ov x oversampled
    Real dx =  (xq[nBins-1] - xq[0])/(ov*(nBins-1));
    printf(" Line %d ID %3.3d.%2.2d Points at %dx X-sampling:\n Wave   (A),  total Fit ,  Continuum, data(oversampled)\n",
           lineIndex, pID, lID, iov);
    for (Counter idx = 0 ; idx <= (nBins*iov); idx++){
      Real x = xq[0] + dx*idx;
      if (fabs(x-l.lineCentre[gidx])<=(3.0*lineWidth)) {
        Integer specIndex = idxLeft0+((idx+iovd2)/iov);
        specIndex = (specIndex < 0)? 0: specIndex;
        specIndex = (specIndex >= nSpec)? nSpec-1: specIndex;
        Real data = specFlux[specIndex];
        Real fitC = EvaluateContinuum  (&cont, x)*cont.invScaleY; // renormalise
        Real fitG = EvaluateLine(&l, gidx, x)*l.invScaleY; // renormalise
        printf("%#11.5f, %#12.5e, %#12.5e, %#12.5e\n", x+patchCentre, fitG+fitC, fitC, data);
      }
    }
  }

}



void PrintFullLineFitDetail(Q1DArr specCoord, Q1DArr specFlux, Counter nSpec,
                        Q1DArr xq, Q1DArr yq, Counter nBins,
                        patchArr p, continuum cont,lines l, Counter pidx, Counter gidx,
                        Counter lineIndex, Counter centrePatches){

  Integer pID = p[pidx].patchID;
  Integer lID = gidx+1;
  Real  patchCentre = p[pidx].patchCentre;
  Counter idxLeft0  = cont.l0;
  const Integer iov   = 5;
  const Integer iovd2 = iov/2;
  const Real ov = 1.0*iov;

  if (centrePatches > 0) {
    // do data + fit 4x oversampled
    Real dx =  (xq[nBins-1] - xq[0])/(ov*(nBins-1));
    printf(" Line %d ID %3.3d.%2.2d Centred Fit Points at %dx X-sampling:\n Wave - %#10.6f (A),  total Fit ,  Continuum, data(oversampled)\n",
           lineIndex, pID, lID, iov, patchCentre);
    for (Counter idx = 0 ; idx <= (nBins*iov); idx++){
        Real x    = xq[0] + dx*idx;  // fit coordinates
        Integer specIndex = idxLeft0+((idx+iovd2)/iov);
        specIndex = (specIndex < 0)? 0: specIndex;
        specIndex = (specIndex >= nSpec)? nSpec-1: specIndex;
        Real data = specFlux[specIndex];
        Real fitC = EvaluateContinuum  (&cont, x)*cont.invScaleY; // renormalise
        Real fitG = EvaluateLine(&l, gidx, x)*l.invScaleY; // renormalise
        printf("%#11.5f, %#12.5e, %#12.5e, %#12.5e\n", x-l.lineCentre[gidx], fitG+fitC, fitC, data);
    }

  } else {
    // just the smooth fit, to overplot on data, ov x oversampled
    Real dx =  (xq[nBins-1] - xq[0])/(ov*(nBins-1));
    printf(" Line %d ID %3.3d.%2.2d Points at %dx X-sampling:\n Wave   (A),  total Fit ,  Continuum, data(oversampled)\n",
           lineIndex, pID, lID, iov);
    for (Counter idx = 0 ; idx <= (nBins*iov); idx++){
        Real x = xq[0] + dx*idx;
        Integer specIndex = idxLeft0+((idx+iovd2)/iov);
        specIndex = (specIndex < 0)? 0: specIndex;
        specIndex = (specIndex >= nSpec)? nSpec-1: specIndex;
        Real data = specFlux[specIndex];
        Real fitC = EvaluateContinuum  (&cont, x)*cont.invScaleY; // renormalise
        Real fitG = EvaluateLine(&l, gidx, x)*l.invScaleY; // renormalise
        printf("%#11.5f, %#12.5e, %#12.5e, %#12.5e\n", x+patchCentre, fitG+fitC, fitC, data);
    }
  }

}


void PrintFullPatchFitDetail(Q1DArr specCoord, Q1DArr specFlux, Counter nSpec,
                        Q1DArr xq, Q1DArr yq, Counter nBins,
                        patchArr p, continuum cont,lines l, Counter pidx,
                        Counter centrePatches){

  Integer pID = p[pidx].patchID;

  Real  patchCentre = p[pidx].patchCentre;
  Counter idxLeft0  = cont.l0;
  const Integer iov   = 5;
  const Integer iovd2 = iov/2;
  const Real ov = 1.0*iov;

  if (centrePatches > 0) {
    // do data + fit ov x oversampled
    Real dx =  (xq[nBins-1] - xq[0])/(ov*(nBins-1));
    printf(" Patch ID %3.3d Centred Fit Points at %dx X-sampling:\n Wave - %#10.6f (A),  total Fit ,  Continuum, data(oversampled)\n",
           pID, iov, patchCentre);
    for (Counter idx = 0 ; idx <= (nBins*iov); idx++){
      Real x    = xq[0] + dx*idx;  // fit coordinates
        Integer specIndex = idxLeft0+((idx+iovd2)/iov);
        specIndex = (specIndex < 0)? 0: specIndex;
        specIndex = (specIndex >= nSpec)? nSpec-1: specIndex;
        Real data = specFlux[specIndex];
        Real fitC = EvaluateContinuum  (&cont, x)*cont.invScaleY; // renormalise
        Real fitG = 0.0;
        for (Counter gidx = 0; gidx < l.nlines; gidx++)
          fitG +=  EvaluateLine(&l, gidx, x)*l.invScaleY; // renormalise
        printf("%#11.5f, %#12.5e, %#12.5e, %#12.5e\n", x-patchCentre, fitG+fitC, fitC, data);
    }

  } else {
    // just the smooth fit, to overplot on data, ov x oversampled
    Real dx =  (xq[nBins-1] - xq[0])/(ov*(nBins-1));
    printf(" Patch ID %3.3d Points at %dx X-sampling:\n Wave   (A),  total Fit ,  Continuum, data(oversampled)\n",
           pID, iov);
    for (Counter idx = 0 ; idx <= (nBins*iov); idx++){
      Real x = xq[0] + dx*idx;
      Integer specIndex = idxLeft0+((idx+iovd2)/iov);
      specIndex = (specIndex < 0)? 0: specIndex;
      specIndex = (specIndex >= nSpec)? nSpec-1: specIndex;
      Real data = specFlux[specIndex];
      Real fitC = EvaluateContinuum  (&cont, x)*cont.invScaleY; // renormalise
      Real fitG = 0.0;
      for (Counter gidx = 0; gidx < l.nlines; gidx++)
        fitG += EvaluateLine(&l, gidx, x)*l.invScaleY; // renormalise
      printf("%#11.5f, %#12.5e, %#12.5e, %#12.5e\n", x+patchCentre, fitG+fitC, fitC, data);
    }
  }

}

////////////////////////////////////////////////////////////////////////
//
// File I/O
//
////////////////////////////////////////////////////////////////////////

void printSubtractedSpectrum (char * subFile, char * fileName, char * patchFile,
                              Q1DArr specCoord, Q1DArr specFlux, Q1DArr subFlux, Counter nSpec){
  // use stdio, zlsio writes gzipped files that may confuse if not named properly :)
  FILE * sub = fopen ( subFile, "w" );
  fprintf(sub," lines   : %s\n",VERSION);
  fprintf(sub," Spectrum: %s \n",fileName);
  fprintf(sub," LineList: %s \n",patchFile);
  time_t  currTime = time(NULL);
  fprintf(sub," Date:  %s", ctime(&currTime));
  fprintf(sub," Line Subtracted Spectrum:\n");
  fprintf(sub," Wavelength,  Original Flux,  Line Subtracted Flux\n");
  for (Counter idx = 0 ; idx < nSpec; idx++){
    fprintf(sub,"%#12.5e,%#12.5e,%#12.5e\n",specCoord[idx], specFlux[idx], subFlux[idx]);
  }
  fclose (sub);
}

Counter ReadPatchFile(patchArr * patches, char * fileName){

  int err = noErr;

  Counter nPatches = 0;
  patchArr p = NULL;
  *patches   = NULL;

  struct ccl_t config;
  const char *str1;

  char keyStr[256];
  config.comment_char = '#';
  config.sep_char     = '=';
  config.str_char     = '"';
  config.table        = NULL;

  if (ccl_parse(&config, fileName)==noErr) {

    //
    Real defaultWidth = 1.0;
    if ((str1= ccl_get(&config,"Global_Width"))){
      defaultWidth = atof(str1);
    }
    if ((str1= ccl_get(&config,"Global_Widths"))){
      defaultWidth = atof(str1);
    }
    defaultWidth = (defaultWidth<0.0)? 0.0 :defaultWidth;

    Real gResolution = 0.0;
    if ((str1= ccl_get(&config,"Global_Resolution"))){
      gResolution = atof(str1);
    }
    gResolution = (gResolution<0.0)? 0.0 : gResolution;

    Integer gOrder = 2;
    if ((str1= ccl_get(&config,"Global_Order"))){
      gOrder = atoi(str1);
    }
    gOrder = (gOrder<0)? 0: gOrder;
    gOrder = (gOrder>2)? 2: gOrder;

    //
    NewPatchArr(&p, 1000);

    if (p != NULL) {

      Counter pidx = 0;

      for (Counter idx = 0; idx < 1000; idx++) {

        Counter foundAPatch = 0;
        sprintf(keyStr, "Patch_%3.3d_Line",idx+1);
        if ((str1= ccl_get(&config,keyStr))){
          foundAPatch = 1;
        }

        sprintf(keyStr, "Patch_%3.3d_nLines",idx+1);
        if ((str1= ccl_get(&config,keyStr))){
          foundAPatch = 1;
        }

        if ( foundAPatch > 0 ) {

          p[pidx].patchID = idx+1;

          p[pidx].linesFitKind  = kGaussianLines;
          sprintf(keyStr, "Patch_%3.3d_Lorentz",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            Integer patchLineKind = atoi(str1);
            patchLineKind = (patchLineKind>0)?1:0;
            if (patchLineKind == 0) {
              p[pidx].linesFitKind = kGaussianLines;
            } else {
              p[pidx].linesFitKind = kLorentzianLines;
            };
          } // patchLineKind

          Integer continuumOrder   = gOrder;
          Integer definedContinuum = 0;
          Integer fixedContinuum   = 0;

          p[pidx].leftStart = 0.0;
          p[pidx].leftEnd   = 0.0;
          sprintf(keyStr, "Patch_%3.3d_Left",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            Real l0, l1;
            Counter nl = processRangeOptions((char *)str1, &l0, &l1);
            if (nl == 2) {
              p[pidx].leftStart = l0;
              p[pidx].leftEnd   = l1;
            } else {
              p[pidx].leftStart = l0;
              p[pidx].leftEnd   = l0;
              continuumOrder    = 1;
            }
            definedContinuum = 1;
          } // Patch_left

          p[pidx].rightStart = 0.0;
          p[pidx].rightEnd   = 0.0;
          sprintf(keyStr, "Patch_%3.3d_Right",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            Real r0, r1;
            Counter nr = processRangeOptions((char *)str1, &r0, &r1);
            if (nr == 2) {
              p[pidx].rightStart = r0;
              p[pidx].rightEnd   = r1;
            } else {
              p[pidx].rightStart = r0;
              p[pidx].rightEnd   = r0;
              continuumOrder    = 1;
            }
            definedContinuum = 1;
          } // Patch_Right

          p[pidx].maskStart = 0.0;
          p[pidx].maskEnd   = 0.0;
          p[pidx].useMask   = 0; // no mask by default
          sprintf(keyStr, "Patch_%3.3d_Mask",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            Real m0, m1;
            Counter nr = processRangeOptions((char *)str1, &m0, &m1);
            if (nr == 2) {
              p[pidx].maskStart = m0;
              p[pidx].maskEnd   = m1;
              p[pidx].useMask   = 1;
            }
          } // Patch_Mask

          p[pidx].continuumConstant = -1.0;
          p[pidx].continuumLeft  = -1.0;
          p[pidx].continuumRight = -1.0;
          p[pidx].continuumFitKind = 0;
          sprintf(keyStr, "Patch_%3.3d_Continuum",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            Real cv0, cv1;
            Counter nr = processRangeOptions((char *)str1, &cv0, &cv1);
            if (nr == 2) {
              p[pidx].continuumLeft     = cv0;
              p[pidx].continuumRight    = cv1;
              p[pidx].continuumConstant = 0.5*(cv0+cv1);
              continuumOrder = 1;
            } else {
              p[pidx].continuumConstant = cv0;
              p[pidx].continuumLeft     = cv0;
              p[pidx].continuumRight    = cv0;
              continuumOrder = 0;
            }
            p[pidx].continuumFitKind = 1;
            fixedContinuum = 1;
          } // Patch_Continuum

          Real order;
          sprintf(keyStr, "Patch_%3.3d_Order",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            order = atoi(str1);
            order = (order < 0)? 0: order;
            order = (order > 2 )? 2: order;
            continuumOrder = order;
          } // Patch_Order
          p[pidx].continuumOrder = continuumOrder;

          p[pidx].fixedCentres = 0;
          p[pidx].fixedWidths  = 0;

          Integer fixedCentres = 0;
          sprintf(keyStr, "Patch_%3.3d_Fixed_Centres",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            fixedCentres = atoi(str1);
            fixedCentres = (fixedCentres>0)?1:0;
          } // Fixed_Centres
          sprintf(keyStr, "Patch_%3.3d_Fixed_Centers",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            fixedCentres = atoi(str1);
            fixedCentres = (fixedCentres>0)?1:0;
          } // Fixed_Centres
          sprintf(keyStr, "Patch_%3.3d_Fixed_Centre",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            fixedCentres = atoi(str1);
            fixedCentres = (fixedCentres>0)?1:0;
          } // Fixed_Centres
          sprintf(keyStr, "Patch_%3.3d_Fixed_Center",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            fixedCentres = atoi(str1);
            fixedCentres = (fixedCentres>0)?1:0;
          } // Fixed_Centres
          p[pidx].fixedCentres = fixedCentres;

          Integer fixedWidths = 0;
          sprintf(keyStr, "Patch_%3.3d_Fixed_Widths",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            fixedWidths = atoi(str1);
            fixedWidths = (fixedWidths>0)?1:0;
          } // Fixed_Widths
          sprintf(keyStr, "Patch_%3.3d_Fixed_Width",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            fixedWidths = atoi(str1);
            fixedWidths = (fixedWidths>0)?1:0;
          } // Fixed_Widths
          p[pidx].fixedWidths = fixedWidths;

          Counter nGaussians = 1; // at least one even if just implied
          Counter foundN = 0; // explicit count found
          sprintf(keyStr, "Patch_%3.3d_nLines",idx+1);
          if ((str1= ccl_get(&config, keyStr))){
            nGaussians = atoi(str1);
            foundN = 1;
          } // nLines

          p[pidx].nLines  = nGaussians;
          p[pidx].centers = NULL;
          p[pidx].widths  = NULL;

          Q1DArr q = NULL;
          err = zls_NewQuantity1DArr(&q, nGaussians);
          if (err != noErr) {
            DisposePatchArr(p);
            return memErr;
          }
          p[pidx].centers = q;

          Q1DArr w = NULL;
          err = zls_NewQuantity1DArr(&w, nGaussians);
          if (err != noErr) {
            DisposePatchArr(p);
            return err;
          }
          p[pidx].widths  = w;

          if (foundN > 0) { // explicit count

            Real localLeftMinX  = DBL_MAX;// very +large but not infinite, unlikely(!) to occur in astro data
            Real localLeftMaxX  = DBL_MAX;// very +large but not infinite, unlikely(!) to occur in astro data
            Real localRightMinX = DBL_MIN;// very -large but not infinite, unlikely(!) to occur in astro data
            Real localRightMaxX = DBL_MIN;// very -large but not infinite, unlikely(!) to occur in astro data

            for (Counter gidx = 0; gidx < nGaussians; gidx++){

              p[pidx].centers[gidx] = 0.0;
              p[pidx].widths [gidx] = 0.0;
              sprintf(keyStr, "Patch_%3.3d_Line_%2.2d",idx+1,gidx+1);
              if ((str1= ccl_get(&config, keyStr))){
                Real c0, w0;
                Counter nr = processRangeOptions((char *)str1, &c0, &w0);

                if (nr == 2) {
                  p[pidx].centers[gidx] = c0;
                  p[pidx].widths [gidx] = w0/1.66511; //FWHM -> sqrt2 sigma
                } else {
                  if (gResolution > 0.0) {
                    w0 = c0/gResolution;
                  } else {
                    w0 = defaultWidth;
                  }
                  p[pidx].centers[gidx] = c0;
                  p[pidx].widths [gidx] = w0/1.66511; //FWHM -> sqrt2 sigma
                }

                if (definedContinuum == 0) {
                  // no continuum defined, use 2-2.5xFWHM to estimate,
                  // as we are in a multiple line patch, take the superset of the
                  // sublines as we go...

                  Real minLeft  = p[pidx].centers[gidx]-w0*2.5;
                  Real maxLeft  = p[pidx].centers[gidx]-w0*2.0;
                  Real minRight = p[pidx].centers[gidx]+w0*2.0;
                  Real maxRight = p[pidx].centers[gidx]+w0*2.5;

                  if ( fixedContinuum > 0 ){
                    minLeft  = p[pidx].centers[gidx]-w0;
                    maxLeft  = p[pidx].centers[gidx]-w0;
                    minRight = p[pidx].centers[gidx]+w0;
                    maxRight = p[pidx].centers[gidx]+w0;
                  }

                  localLeftMinX  = (minLeft<localLeftMinX)? minLeft: localLeftMinX;
                  localLeftMaxX  = (maxLeft<localLeftMaxX)? maxLeft: localLeftMaxX;

                  localRightMinX = (minRight>localRightMinX)? minRight: localRightMinX;
                  localRightMaxX = (maxRight>localRightMaxX)? maxRight: localRightMaxX;
                }

              } // Patch_Line

              if (definedContinuum == 0) {
                // no continuum defined, use  superset of 2-2.5xFWHM ws to estimate,
                p[pidx].leftStart  = localLeftMinX;
                p[pidx].leftEnd    = localLeftMaxX;
                p[pidx].rightStart = localRightMinX;
                p[pidx].rightEnd   = localRightMaxX;
              }

            } // gidx

          } else { // implicit count = 1
                   // just look for one unindexed line
            p[pidx].centers[0] = 0.0;
            p[pidx].widths [0] = 0.0;
            sprintf(keyStr, "Patch_%3.3d_Line",idx+1);
            if ((str1= ccl_get(&config, keyStr))){
              Real c0, w0;
              Counter nr = processRangeOptions((char *)str1, &c0, &w0);
              if (nr == 2) {
                p[pidx].centers[0] = c0;
                p[pidx].widths [0] = w0/1.66511; //FWHM -> sqrt2 sigma
              } else {
                if (gResolution > 0.0) {
                  w0 = c0/gResolution;
                } else {
                  w0 = defaultWidth;
                }
                p[pidx].centers[0] = c0;
                p[pidx].widths [0] = w0/1.66511; //FWHM -> sqrt2 sigma
              }

              if (definedContinuum == 0) {
                // no continuum defined, 2-2.5xFWHM to estimate,
                p[pidx].leftStart  = p[pidx].centers[0] - w0*5.0;
                p[pidx].leftEnd    = p[pidx].centers[0] - w0*2.5;
                p[pidx].rightStart = p[pidx].centers[0] + w0*2.5;
                p[pidx].rightEnd   = p[pidx].centers[0] + w0*5.0;
                if ( p[pidx].continuumOrder == 1) {
                  p[pidx].leftStart  = p[pidx].centers[0] - w0*1.698643633059;// 4 sigma
                  p[pidx].leftEnd    = p[pidx].centers[0] - w0*1.698643633059;
                  p[pidx].rightStart = p[pidx].centers[0] + w0*1.698643633059;
                  p[pidx].rightEnd   = p[pidx].centers[0] + w0*1.698643633059;
                }
                if ( p[pidx].continuumOrder == 0) {
                  p[pidx].leftStart  = p[pidx].centers[0] - w0*1.27398272479425; // 3sigma
                  p[pidx].leftEnd    = p[pidx].centers[0] - w0*1.27398272479425;
                  p[pidx].rightStart = p[pidx].centers[0] + w0*1.27398272479425;
                  p[pidx].rightEnd   = p[pidx].centers[0] + w0*1.27398272479425;
                }
              }

            } // Patch_Line

          } // implict single line

          pidx++;

        } // foundAPatch

      }

      nPatches = pidx;

    } else { // p failed t allocate
      err = memErr;
      printf("FATAL ERROR: unable to parse patch file: patches array failed %s\n",fileName);
      exit(err);
    } // p

  } else { // ccl failed
    err  = fileErr;
    printf("FATAL ERROR: unable to find/parse patch file: %s\n",fileName);
    exit(err);
  } // ccl

  *patches = p;
  return nPatches;

}

Counter ReadFluxFile(Q1DArr * wave, Q1DArr * flux, Integer nHeader, char * fileName){

  Counter nSpec = 0;
  Q1DArr waveBuffer = NULL;
  Q1DArr fluxBuffer = NULL;
  *wave = NULL;
  *flux = NULL;
  zls_NewQuantity1DArr(&waveBuffer, 1000000L);
  zls_NewQuantity1DArr(&fluxBuffer, 1000000L);

  if ((waveBuffer != NULL)&&(fluxBuffer != NULL)){

    zFile ctlFile = zlsio_open (fileName, "r");

    if (ctlFile != NULL){

      char line[1024];
      for (Integer idx = 0; idx < nHeader; idx++) {

        zlsio_gets(ctlFile, line, 1024); printf("%s",line);

      }

      while (zlsio_gets(ctlFile, line, 1024) == noErr) {

        Real w,flx;
        sscanf(line, "%lf %lf", &w, &flx);
        waveBuffer[nSpec] =   w;
        fluxBuffer[nSpec] = flx;
        nSpec++;

      }

      zlsio_close(ctlFile);

      if (nSpec > 0) {

        zls_NewQuantity1DArr(wave, nSpec);
        zls_NewQuantity1DArr(flux, nSpec);

        if (waveBuffer[0]>waveBuffer[nSpec-1]){

          for (Counter idx = 0; idx < nSpec; idx++){

            (*wave)[idx] = waveBuffer[nSpec-idx-1];
            (*flux)[idx] = fluxBuffer[nSpec-idx-1];

          }

        } else {

          for (Counter idx = 0; idx < nSpec; idx++){

            (*wave)[idx] = waveBuffer[idx];
            (*flux)[idx] = fluxBuffer[idx];

          }

        }

      }

    }

  } else {
    printf("FATAL ERROR: unable to allocate buffers for spectrum file: %s\n",fileName);
    exit(memErr);
  }

  zls_DisposeQuantity1DArr(waveBuffer);
  zls_DisposeQuantity1DArr(fluxBuffer);

  return nSpec;

}

