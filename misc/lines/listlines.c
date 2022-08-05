#include "zls.h"

/*
 listlines: program to simply list the left, right, centres and widths of
 lines found in a patch file.
 */

#include "lines.h"

void PrintTableHeader(char * patchFile);
void PrintTableHeadLine(void);
void PrintTableLine(patchArr p, Counter pidx, Counter lineIndex, Counter pid, Counter gidx, char * fitType);

int main(int argc, char * argv[]) {

  int err = noErr;

  if (argc < 2){
    Usage();
  }

 char s0[16];
 char s1[16];
 char s2[16];
 char s3[16];

//  char* s0 = calloc(16,sizeof(char));
//  char* s1 = calloc(16,sizeof(char));
//  char* s2 = calloc(16,sizeof(char));
//  char* s3 = calloc(16,sizeof(char));

  Integer showDebug = 0;

  Integer optind = 0;

  int ch;
  extern char* optarg;
  while ((ch = getopt(argc, argv, "d")) != -1) {

    optind++;
    switch (ch) {
      case 'd':
        showDebug = 1;
        break;
      case '?':
      default:
        Usage();
    }

  }

    char * patchFile = (char *)argv[argc-1];

    Counter nPatches      = 0;
    Counter lineIndex     = 0;
    patchArr p            = NULL;

    ////////////////////////////////////////////////////////////////////////
    nPatches = ReadPatchFile(&p, patchFile);
    ////////////////////////////////////////////////////////////////////////

    if (nPatches > 0){

        PrintTableHeader(patchFile);
        if (showDebug == 0) {
           PrintTableHeadLine();
        }
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
          Real en = p[pidx].rightEnd;
          p[pidx].patchCentre = 0.5*(en+st);
          ////////////////////////////////////////////////////////////////////////


          if (en > st) { // sensible patch

            Counter contOrder    = p[pidx].continuumOrder; // 0..+2
            Counter contKind     = p[pidx].continuumFitKind; // == 0 free, >= fixed
            Counter fixedWidths  = p[pidx].fixedWidths;  // > 0 fixed, == 0 free
            Counter fixedCentres = p[pidx].fixedCentres; // > 0 fixed, == 0 free

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
                if (contOrder == 2){
                  sprintf(fitKind,"%s, Quadratic Cont.",fitKind);
                }
              }
              ////////////////////////////////////////////////////////////////////////

              if (showDebug == 0) {

              ////////////////////////////////////////////////////////////////////////
              // Patch lines gidx loop
              for (Counter gidx = 0; gidx < nGs; gidx++){

                lineIndex += 1;

                ////////////////////////////////////////////////////////////////////////
                // Output  to stdout
                ////////////////////////////////////////////////////////////////////////
                PrintTableLine(p, pidx, lineIndex, pID, gidx, fitKind);

              }
              // gidx line loop
              ////////////////////////////////////////////////////////////////////////

              } else {
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


          }

        } // patch loop
          ////////////////////////////////////////////////////////////////////////

    } else { // nPatches < 1
      InvalidLineList();
    }

  return err;

}


////////////////////////////////////////////////////////////////////////
//
// command interface
//
////////////////////////////////////////////////////////////////////////


void Usage(void){

  printf("\n  listlines: Tabulate a summary of a patchfile %s\n",VERSION);
  printf("\n  Useage: listlines [-d] patchList\n");
  printf("      Args: required: patchList (see example list.txt for format)\n");
  printf("            optional: -d re-output as patches - especially to renumber patches\n");
  printf("    Output: std out line fits suitable for csv/text file, redirect to a csv filename for example\n\n");

  exit(-1);

}

void InvalidLineList(void){

  printf("\n  listlines: tabulate a summary of a patchfile %s\n",VERSION);
  printf("    ERROR: No valid line list found in patchList file --\n");
  printf("         Malformed, invalid or missing input list file.\n\n");
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
  err |= zls_NewQuantity1DArr(&l->ai , nL*3); // 3 coeffs per gaussian
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
// std out I/O
//
////////////////////////////////////////////////////////////////////////


void PrintTableHeader(char * patchFile){

  printf("# \n");
  printf("# linelist : %s\n",VERSION);
  printf("# patchList: %s \n",patchFile);
  time_t  currTime = time(NULL);
  printf("# Date:  %s", ctime(&currTime));
  printf("# \n");

}

void  PrintTableHeadLine(void){

      printf("   Line#,  Start Left,    End Left, Start Right,   End Right,      Centre,       Width, PID, line#, of lines, Type\n");
}

void  PrintTableLine(patchArr p, Counter pidx, Counter lineIndex, Counter pid, Counter gidx, char * fitType){

      printf("   %4d ,  %#10.4f,  %#10.4f,  %#10.4f,  %#10.4f,  %#10.4f,  %#10.4f, %3.3d,    %2.2d,       %2.2d, %s\n",
             lineIndex, p[pidx].leftStart,  p[pidx].leftEnd,  p[pidx].rightStart, p[pidx].rightEnd,
             p[pidx].centers[gidx],p[pidx].widths[gidx],
             pid, gidx+1, p[pidx].nLines, fitType);

}


////////////////////////////////////////////////////////////////////////
//
// File I/O
//
////////////////////////////////////////////////////////////////////////

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
