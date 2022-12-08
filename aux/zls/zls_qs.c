//#include <fftw3.h>
#include "zls_qs.h"
//
//  Allocating/Releasing
//

//
// Basic Quantities - stored in zones, just an array
// and each element is the same size in all dimenstions.
// Convenience 2D and 3D allocators, take j, and k ranges
//
//========================================
//
// Single quantities:
//
//========================================

int zls_NewQuantity1D(QPtr *q, Counter ni){

    int err = NoErr;

    *q = (QPtr)calloc(1,sizeof(Real)*ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewQuantity2D(QPtr *q, Counter ni, Counter nj){

    int err = NoErr;
    MemSize n =  (ni*nj);

    *q = (QPtr)calloc(1,n*sizeof(Real));

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewQuantity3D(QPtr *q, Counter ni, Counter nj, Counter nk){
    int err = NoErr;
    MemSize n =  (ni*nj*nk);
    *q = (QPtr)calloc(1,n*sizeof(Real));

    if (*q == NULL) {
        err = memErr;
    }
    return(err);
}


int zls_DisposeQuantity(QPtr q){
    int err = NoErr;
    if (q != NULL) {
        free(q);
    }
    return(err);
}

//========================================
//
// multi-dimensional array versions...
//
// Note reversed idices, reference arrays by [i], [j][i] or  [k][j][i]
//
//========================================

int zls_NewQuantity1DArr(Q1DArr *q, Counter ni){ // same as NewQuantity but for Q1DArr syntax

    int err = noErr;

    *q = (Q1DArr)calloc(1,sizeof(Real) * ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewQuantity2DArr(Q2DArr *q, Counter nj, Counter ni){

    int err = NoErr;

    *q = (Q2DArr)zlsAlloc2DArr(sizeof(Real), nj, ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewQuantity3DArr(Q3DArr *q, Counter nk, Counter nj, Counter ni){

    int err = NoErr;

    *q = (Q3DArr)zlsAlloc3DArr(sizeof(Real), nk, nj, ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_DisposeQuantity1DArr(Q1DArr q){

    int err = NoErr;

    if (q != NULL) {
        free((void *) q);
    } else {err = memErr;}

    return(err);
}

int zls_DisposeQuantity2DArr(Q2DArr q){

    int err = NoErr;

    if (q != NULL) {
        zlsFree2DArr((void **) q);
    } else {err = memErr;}

    return(err);
}

int zls_DisposeQuantity3DArr(Q3DArr q){

    int err = NoErr;

    if (q != NULL) {
        zlsFree3DArr((void ***) q);
    } else {err = memErr;}

    return(err);
}

//========================================
//
// Wrap an array around an unstructured block, alternative to New,
// if data already exists Release disposes without affecting data,
// not needed for 1D data
//
//========================================

int zls_SetQuantity2DArr(Q2DArr *q, QPtr data, Counter nj, Counter ni){

    int err = NoErr;
    Q2DArr  tempQ = NULL;

    tempQ = (Q2DArr)zlsSet2DArr((void *) data, sizeof(Real), nj, ni);

    if (tempQ == NULL) {
        err = memErr;
    }
    *q = tempQ;

    return(err);
}

int zls_SetQuantity3DArr(Q3DArr *q, QPtr data, Counter nk, Counter nj, Counter ni){

    int err = NoErr;

    *q = (Q3DArr)zlsSet3DArr((void *) data, sizeof(Real), nk, nj, ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

//========================================
//
// remove offset pointer structures from a multi-dim array leaving
// the data untouched must have a copy of the data reference elsewhere
// or it will be lost and memory will leak badly.
//
//========================================

int zls_ReleaseQuantity2DArr(Q2DArr q){

    int err = NoErr;

    if (q != NULL) {
        zlsRelease2DArr((void **) q);
    } else { err = memErr;}

    return(err);
}

int zls_ReleaseQuantity3DArr(Q3DArr q){

    int err = NoErr;

    if (q != NULL) {
        zlsRelease3DArr((void ***) q);
    } else { err = memErr;}

    return(err);
}

//========================================
// Extract an unstructured block, useful for I/O, returns a reference
// to the data, no extra memory is allocated
//========================================

int zls_GetQuantity2DArr(QPtr *data, Q2DArr q){
    *data = q[0];
    return(NoErr);
}

int zls_GetQuantity3DArr(QPtr *data, Q3DArr q){
    *data = q[0][0];
    return(NoErr);
}

//=========================================


int zls_NewFQuantity1D(FQPtr *fq, Counter ni){

    int err = NoErr;

    *fq = (FQPtr)malloc(sizeof(Real32)*ni);

    if (*fq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewFQuantity2D(FQPtr *fq, Counter ni, Counter nj){

    int err = NoErr;
    MemSize n =  (ni*nj);

    *fq = (FQPtr)malloc(n*sizeof(Real32));

    if (*fq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewFQuantity3D(FQPtr *fq, Counter ni, Counter nj, Counter nk){
    int err = NoErr;
    MemSize n =  (ni*nj*nk);
    *fq = (FQPtr)malloc(n*sizeof(Real32));

    if (*fq == NULL) {
        err = memErr;
    }
    return(err);
}


int zls_DisposeFQuantity(FQPtr fq){
    int err = NoErr;
    if (fq != NULL) {
        free(fq);
    }
    return(err);
}

//========================================
//
// multi-dimensional array versions...
//
// Note reversed idices, reference arrays by [i], [j][i] or  [k][j][i]
//
//========================================

int zls_NewFQuantity1DArr(FQ1DArr *fq, Counter ni){ // same as NewQuantity but for Q1DArr syntax

    int err = NoErr;

    *fq = (FQ1DArr)malloc(sizeof(Real32) * ni);

    if (*fq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewFQuantity2DArr(FQ2DArr *fq, Counter nj, Counter ni){

    int err = NoErr;

    *fq = (FQ2DArr)zlsAlloc2DArr(sizeof(Real32), nj, ni);

    if (*fq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewFQuantity3DArr(FQ3DArr *fq, Counter nk, Counter nj, Counter ni){

    int err = NoErr;

    *fq = (FQ3DArr)zlsAlloc3DArr(sizeof(Real32), nk, nj, ni);

    if (*fq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_DisposeFQuantity1DArr(FQ1DArr fq){

    int err = NoErr;

    if (fq != NULL) {
        free((void *) fq);
    } else {err = memErr;}

    return(err);
}

int zls_DisposeFQuantity2DArr(FQ2DArr fq){

    int err = NoErr;

    if (fq != NULL) {
        zlsFree2DArr((void **) fq);
    } else {err = memErr;}

    return(err);
}

int zls_DisposeFQuantity3DArr(FQ3DArr fq){

    int err = NoErr;

    if (fq != NULL) {
        zlsFree3DArr((void ***) fq);
    } else {err = memErr;}

    return(err);
}

//========================================
//
// Wrap an array around an unstructured block, alternative to New,
// if data already exists Release disposes without affecting data,
// not needed for 1D data
//
//========================================

int zls_SetFQuantity2DArr(FQ2DArr *fq, FQPtr data, Counter nj, Counter ni){

    int err = NoErr;
    FQ2DArr  tempQ = NULL;

    tempQ = (FQ2DArr)zlsSet2DArr((void *) data, sizeof(Real32), nj, ni);

    if (tempQ == NULL) {
        err = memErr;
    }
    *fq = tempQ;

    return(err);
}

int zls_SetFQuantity3DArr(FQ3DArr *fq, FQPtr data, Counter nk, Counter nj, Counter ni){

    int err = NoErr;

    *fq = (FQ3DArr)zlsSet3DArr((void *) data, sizeof(Real32), nk, nj, ni);

    if (*fq == NULL) {
        err = memErr;
    }

    return(err);
}

//========================================
//
// remove offset pointer structures from a multi-dim array leaving
// the data untouched must have a copy of the data reference elsewhere
// or it will be lost and memory will leak badly.
//
//========================================

int zls_ReleaseFQuantity2DArr(FQ2DArr fq){

    int err = NoErr;

    if (fq != NULL) {
        zlsRelease2DArr((void **) fq);
    } else { err = memErr;}

    return(err);
}

int zls_ReleaseFQuantity3DArr(FQ3DArr fq){

    int err = NoErr;

    if (fq != NULL) {
        zlsRelease3DArr((void ***) fq);
    } else { err = memErr;}

    return(err);
}

//========================================
// Extract an unstructured block, useful for I/O, returns a reference
// to the data, no extra memory is allocated
//========================================

int zls_GetFQuantity2DArr(FQPtr *data, FQ2DArr fq){
    *data = fq[0];
    return(NoErr);
}

int zls_GetFQuantity3DArr(FQPtr *data, FQ3DArr fq){
    *data = fq[0][0];
    return(NoErr);
}


//=========================================
//
// Complex Quantities - stored in zones, just an array
// and each element is the same size in all dimenstions.
// Convenience 2D and 3D allocators, take j, and k ranges
//
//========================================
//
// Single complex quantities:
//
//========================================

int zls_NewCQuantity1D(CQPtr *cq, Counter ni){

    int err = NoErr;

    *cq = (CQPtr)malloc(sizeof(Complex)*ni);

    if (*cq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewCQuantity2D(CQPtr *cq, Counter ni, Counter nj){

    int err = NoErr;
    MemSize n =  (ni*nj);

    *cq = (CQPtr)malloc(n*sizeof(Complex));

    if (*cq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewCQuantity3D(CQPtr *cq, Counter ni, Counter nj, Counter nk){
    int err = NoErr;
    MemSize n =  (ni*nj*nk);
    *cq = (CQPtr)malloc(n*sizeof(Complex));

    if (*cq == NULL) {
        err = memErr;
    }
    return(err);
}


int zls_DisposeCQuantity(CQPtr cq){
    int err = NoErr;
    if (cq != NULL) {
        free(cq);
    }
    return(err);
}

//========================================
//
// multi-dimensional array versions...
//
// Note reversed idices, reference arrays by [i], [j][i] or  [k][j][i]
//
//========================================

int zls_NewCQuantity1DArr(CQ1DArr *cq, Counter ni){ // same as NewCQuantity but for CQ1DArr syntax

    int err = NoErr;

    *cq = (CQ1DArr)malloc(sizeof(Complex) * ni);

    if (*cq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewCQuantity2DArr(CQ2DArr *cq, Counter nj, Counter ni){

    int err = NoErr;

    *cq = (CQ2DArr)zlsAlloc2DArr(sizeof(Complex), nj, ni);

    if (*cq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewCQuantity3DArr(CQ3DArr *cq, Counter nk, Counter nj, Counter ni){

    int err = NoErr;

    *cq = (CQ3DArr)zlsAlloc3DArr(sizeof(Complex), nk, nj, ni);

    if (*cq == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_DisposeCQuantity1DArr(CQ1DArr cq){

    int err = NoErr;

    if (cq != NULL) {
        free((void *) cq);
    } else {err = memErr;}

    return(err);
}

int zls_DisposeCQuantity2DArr(CQ2DArr cq){

    int err = NoErr;

    if (cq != NULL) {
        zlsFree2DArr((void **) cq);
    } else {err = memErr;}

    return(err);
}

int zls_DisposeCQuantity3DArr(CQ3DArr cq){

    int err = NoErr;

    if (cq != NULL) {
        zlsFree3DArr((void ***) cq);
    } else {err = memErr;}

    return(err);
}

//========================================
//
// Wrap an array around an unstructured block, alternative to New,
// if data already exists Release disposes without affecting data,
// not needed for 1D data
//
//========================================

int zls_SetCQuantity2DArr(CQ2DArr *cq, CQPtr cdata, Counter nj, Counter ni){

    int err = NoErr;
    CQ2DArr  tempQ = NULL;

    tempQ = (CQ2DArr)zlsSet2DArr((void *) cdata, sizeof(Complex), nj, ni);

    if (tempQ == NULL) {
        err = memErr;
    }
    *cq = tempQ;

    return(err);
}

int zls_SetCQuantity3DArr(CQ3DArr *cq, CQPtr cdata, Counter nk, Counter nj, Counter ni){

    int err = NoErr;

    *cq = (CQ3DArr)zlsSet3DArr((void *) cdata, sizeof(Complex), nk, nj, ni);

    if (*cq == NULL) {
        err = memErr;
    }

    return(err);
}

//========================================
//
// remove offset pointer structures from a multi-dim array leaving
// the cdata untouched must have a copy of the cdata reference elsewhere
// or it will be lost and memory will leak badly.
//
//========================================

int zls_ReleaseCQuantity2DArr(CQ2DArr cq){

    int err = NoErr;

    if (cq != NULL) {
        zlsRelease2DArr((void **) cq);
    } else { err = memErr;}

    return(err);
}

int zls_ReleaseCQuantity3DArr(CQ3DArr cq){

    int err = NoErr;

    if (cq != NULL) {
        zlsRelease3DArr((void ***) cq);
    } else { err = memErr;}

    return(err);
}

//========================================
// Extract an unstructured block, useful for I/O, returns a reference
// to the cdata, no extra memory is allocated
//========================================

int zls_GetCQuantity2DArr(CQPtr *cdata, CQ2DArr cq){
    *cdata = cq[0];
    return(NoErr);
}

int zls_GetCQuantity3DArr(CQPtr *cdata, CQ3DArr cq){
    *cdata = cq[0][0];
    return(NoErr);
}

//========================================
//
// Single quantities:
//
//========================================

int zls_NewInteger1D(IPtr *q, Counter ni){

    int err = NoErr;

    *q = (IPtr)malloc(sizeof(Integer)*ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewInteger2D(IPtr *q, Counter ni, Counter nj){

    int err = NoErr;
    MemSize n =  (ni*nj);

    *q = (IPtr)malloc(n*sizeof(Integer));

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewInteger3D(IPtr *q, Counter ni, Counter nj, Counter nk){
    int err = NoErr;
    MemSize n =  (ni*nj*nk);
    *q = (IPtr)malloc(n*sizeof(Integer));

    if (*q == NULL) {
        err = memErr;
    }
    return(err);
}


int zls_DisposeInteger(IPtr q){
    int err = NoErr;
    if (q != NULL) {
        free(q);
    }
    return(err);
}

//========================================
//
// multi-dimensional array versions...
//
// Note reversed idices, reference arrays by [i], [j][i] or  [k][j][i]
//
//========================================

int zls_NewInteger1DArr(I1DArr *q, Counter ni){ // same as NewInteger but for I1DArr syntax

    int err = NoErr;

    *q = (I1DArr)malloc(sizeof(Integer) * ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewInteger2DArr(I2DArr *q, Counter nj, Counter ni){

    int err = NoErr;

    *q = (I2DArr)zlsAlloc2DArr(sizeof(Integer), nj, ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_NewInteger3DArr(I3DArr *q, Counter nk, Counter nj, Counter ni){

    int err = NoErr;

    *q = (I3DArr)zlsAlloc3DArr(sizeof(Integer), nk, nj, ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

int zls_DisposeInteger1DArr(I1DArr q){

    int err = NoErr;

    if (q != NULL) {
        free((void *) q);
    } else {err = memErr;}

    return(err);
}

int zls_DisposeInteger2DArr(I2DArr q){

    int err = NoErr;

    if (q != NULL) {
        zlsFree2DArr((void **) q);
    } else {err = memErr;}

    return(err);
}

int zls_DisposeInteger3DArr(I3DArr q){

    int err = NoErr;

    if (q != NULL) {
        zlsFree3DArr((void ***) q);
    } else {err = memErr;}

    return(err);
}

//========================================
//
// Wrap an array around an unstructured block, alternative to New,
// if data already exists Release disposes without affecting data,
// not needed for 1D data
//
//========================================

int zls_SetInteger2DArr(I2DArr *q, IPtr data, Counter nj, Counter ni){

    int err = NoErr;
    I2DArr  tempQ = NULL;

    tempQ = (I2DArr)zlsSet2DArr((void *) data, sizeof(Integer), nj, ni);

    if (tempQ == NULL) {
        err = memErr;
    }
    *q = tempQ;

    return(err);
}

int zls_SetInteger3DArr(I3DArr *q, IPtr data, Counter nk, Counter nj, Counter ni){

    int err = NoErr;

    *q = (I3DArr)zlsSet3DArr((void *) data, sizeof(Integer), nk, nj, ni);

    if (*q == NULL) {
        err = memErr;
    }

    return(err);
}

//========================================
//
// remove offset pointer structures from a multi-dim array leaving
// the data untouched must have a copy of the data reference elsewhere
// or it will be lost and memory will leak badly.
//
//========================================

int zls_ReleaseInteger2DArr(I2DArr q){

    int err = NoErr;

    if (q != NULL) {
        zlsRelease2DArr((void **) q);
    } else { err = memErr;}

    return(err);
}

int zls_ReleaseInteger3DArr(I3DArr q){

    int err = NoErr;

    if (q != NULL) {
        zlsRelease3DArr((void ***) q);
    } else { err = memErr;}

    return(err);
}

//========================================
// Extract an unstructured block, useful for I/O, returns a reference
// to the data, no extra memory is allocated
//========================================

int zls_GetInteger2DArr(IPtr *data, I2DArr q){
    *data = q[0];
    return(NoErr);
}

int zls_GetInteger3DArr(IPtr *data, I3DArr q){
    *data = q[0][0];
    return(NoErr);
}

//========================================
// Copy lower dim quantity arrays from higher dim quantities
//========================================

int zls_SetI1DArrI2DArrY(I1DArr q1, I2DArr q, Integer nj, Integer i){
    int err = NoErr;
    Integer     j;
    if ((q1!=NULL) &&(q!=NULL)){
        for (j = 0; j < nj; j++){
            q1[j]     = q[j][i];
        }
    } else {err = memErr; }
    return(err);
}


int zls_SetI1DArrI2DArrX(I1DArr q1, I2DArr q, Integer ni, Integer j){
    int err = NoErr;
    Integer     i;
    if ((q1!=NULL) &&(q!=NULL)){
        for (i = 0; i < ni; i++){
            q1[i]     = q[j][i];
        }
    } else {err = memErr; }
    return(err);
}

int zls_SetI1DArrI3DArrX( I1DArr q1, I3DArr q, Integer ni, Integer k, Integer j ){
    int err = NoErr;
    Integer     i;
    if ((q1!=NULL) &&(q!=NULL)){
        for (i = 0; i<ni; i++){
            q1[i] = q[k][j][i];
        }
    } else {err = memErr; }
    return(err);
}

int zls_SetI1DArrI3DArrY( I1DArr q1, I3DArr q, Integer nj, Integer k, Integer i ){
    int err = NoErr;
    Integer     j;
    if ((q1!=NULL) &&(q!=NULL)){
        for (j = 0; j<nj; j++){
            q1[j] = q[k][j][i];
        }
    } else {err = memErr; }
    return(err);
}

int zls_SetI1DArrI3DArrZ( I1DArr q1, I3DArr q, Integer nk, Integer j, Integer i ){
    int err = NoErr;
    Integer     k;
    if ((q1!=NULL) &&(q!=NULL)){
        for (k = 0; k<nk; k++){
            q1[k] = q[k][j][i];
        }
    } else {err = memErr; }
    return(err);
}

int zls_SetI2DArrI3DArrYZ( I2DArr q2, I3DArr q, Integer nj, Integer nk, Integer i ){
    int err = NoErr;
    Integer    j,k;
    if ((q2!=NULL) &&(q!=NULL)){
        for (k = 0; k<nk; k++){
            for (j = 0; j<nj; j++){
                q2[k][j] = q[k][j][i];
            }
        }
    } else {err = memErr; }
    return(err);
}

int zls_SetI2DArrI3DArrZX( I2DArr q2, I3DArr q, Integer nk, Integer ni, Integer j ){
    int err = NoErr;
    Integer     i, k;
    if ((q2!=NULL) &&(q!=NULL)){
        for (k = 0; k<nk; k++){
            for (i = 0; i<ni; i++){
                q2[i][k] = q[k][j][i];
            }
        }
    } else {err = memErr; }
    return(err);
}

int zls_SetI2DArrI3DArrXY( I2DArr q2, I3DArr q, Integer ni, Integer nj, Integer k ){
    int err = NoErr;
    Integer    i,j;
    if ((q2!=NULL) &&(q!=NULL)){
        for (j = 0; j<nj; j++){
            for (i = 0; i<ni; i++){
                q2[j][i] = q[k][j][i];
            }
        }
    } else {err = memErr; }
    return(err);
}
