#ifndef ZLS_QS_H
#define ZLS_QS_H
#include "zls_types.h"
#include "zls_arrs.h"

//==========================================================================================
//
// Plain, uniterpreted real quantity arrays
//
//==========================================================================================
//==========================================================================================
//
// Declared as Q * 1DArr, Q ** 2DArr and Q *** 3DArr, may accessed as
// Q[i], Q[j][i] and Q[k][j][i] or at single ptr from Q, Q[0] or
// Q[0][0] in 1D , 2D and 3D.
//
// zls_vars contains utility routines for allocating and deacllocating
// these arrays dynamically
//========================================

typedef Real    * QPtr;  // plainest block , 1 2 or 3D

typedef Real    * Q1DArr;  // 1D array of Qs
typedef Real   ** Q2DArr;  // 2D array of Qs q   [j][i]  q   [0] is QPtr
typedef Real  *** Q3DArr;  // 3D array of Qs q[k][j][i]  q[0][0] is QPtr

//

int zls_NewQuantity1D   ( QPtr *q, Counter ni ); // same as zls_NewQuantity1DArr but for QPtr syntax
int zls_NewQuantity2D   ( QPtr *q, Counter ni, Counter nj );
int zls_NewQuantity3D   ( QPtr *q, Counter ni, Counter nj, Counter nk );
int zls_DisposeQuantity ( QPtr q );

//
// multi-dimensional array versions...
//

//
// Note reversed idices, reference arrays by  [j][i] or  [k][j][i]
//

int zls_NewQuantity1DArr ( Q1DArr *q, Counter ni); // same as zls_NewQuantity1D but for Q1DArr syntax
int zls_NewQuantity2DArr ( Q2DArr *q, Counter nj, Counter ni );
int zls_NewQuantity3DArr ( Q3DArr *q, Counter nk, Counter nj, Counter ni );

int zls_DisposeQuantity1DArr ( Q1DArr q );
int zls_DisposeQuantity2DArr ( Q2DArr q );
int zls_DisposeQuantity3DArr ( Q3DArr q );

//
// Wrap an array around and unstructured block, alternative to New, use
// Release to free without deleting data, no nBC option as the ns must
// equal the input data dims exactly: Not needed for 1D arrays.
//

int zls_SetQuantity2DArr ( Q2DArr *q, QPtr data, Counter nj, Counter ni );
int zls_SetQuantity3DArr ( Q3DArr *q, QPtr data, Counter nk, Counter nj, Counter ni );

int zls_ReleaseQuantity2DArr ( Q2DArr q );
int zls_ReleaseQuantity3DArr ( Q3DArr q );

//
// Extract an unstructured block, useful for I/O
//

int zls_GetQuantity2DArr ( QPtr *data, Q2DArr q );
int zls_GetQuantity3DArr ( QPtr *data, Q3DArr q );

//==========================================================================================

typedef Real32    * FQPtr;  // plainest block , 1 2 or 3D

typedef Real32    * FQ1DArr;  // 1D array of Qs
typedef Real32   ** FQ2DArr;  // 2D array of Qs q   [j][i]  q   [0] is QPtr
typedef Real32  *** FQ3DArr;  // 3D array of Qs q[k][j][i]  q[0][0] is QPtr

//

int zls_NewFQuantity1D   ( FQPtr *fq, Counter ni ); // same as zls_NewQuantity1DArr but for QPtr syntax
int zls_NewFQuantity2D   ( FQPtr *fq, Counter ni, Counter nj );
int zls_NewFQuantity3D   ( FQPtr *fq, Counter ni, Counter nj, Counter nk );
int zls_DisposeFQuantity ( FQPtr fq );

//
// multi-dimensional array versions...
//

//
// Note reversed idices, reference arrays by  [j][i] or  [k][j][i]
//

int zls_NewFQuantity1DArr ( FQ1DArr *q, Counter ni); // same as zls_NewQuantity1D but for Q1DArr syntax
int zls_NewFQuantity2DArr ( FQ2DArr *q, Counter nj, Counter ni );
int zls_NewFQuantity3DArr ( FQ3DArr *q, Counter nk, Counter nj, Counter ni );

int zls_DisposeFQuantity1DArr ( FQ1DArr q );
int zls_DisposeFQuantity2DArr ( FQ2DArr q );
int zls_DisposeFQuantity3DArr ( FQ3DArr q );

//
// Wrap an array around and unstructured block, alternative to New, use
// Release to free without deleting data, no nBC option as the ns must
// equal the input data dims exactly: Not needed for 1D arrays.
//

int zls_SetFQuantity2DArr ( FQ2DArr *fq, FQPtr data, Counter nj, Counter ni );
int zls_SetFQuantity3DArr ( FQ3DArr *fq, FQPtr data, Counter nk, Counter nj, Counter ni );

int zls_ReleaseFQuantity2DArr ( FQ2DArr q );
int zls_ReleaseFQuantity3DArr ( FQ3DArr q );

//
// Extract an unstructured block, useful for I/O
//

int zls_GetFQuantity2DArr ( FQPtr *data, FQ2DArr q );
int zls_GetFQuantity3DArr ( FQPtr *data, FQ3DArr q );

//==========================================================================================
//
// Plain, complex pairs quantity arrays
//
//==========================================================================================
//==========================================================================================
//
// Declared as CQ * 1DArr, CQ ** 2DArr and CQ *** 3DArr, may accessed as
// CQ[i], CQ[j][i] and CQ[k][j][i] or at single ptr from CQ, CQ[0] or
// CQ[0][0] in 1D , 2D and 3D.
//
// zls_vars contains utility routines for allocating and deacllocating
// these arrays dynamically
//========================================


typedef Complex    * CQPtr;  // plainest block , 1 2 or 3D

typedef Complex    * CQ1DArr;  // 1D array of Qs
typedef Complex   ** CQ2DArr;  // 2D array of Qs q   [j][i]  q   [0] is QPtr
typedef Complex  *** CQ3DArr;  // 3D array of Qs q[k][j][i]  q[0][0] is QPtr

//

int zls_NewCQuantity1D ( CQPtr *cq, Counter ni ); // same as zls_NewQuantity1DArr but for QPtr syntax
int zls_NewCQuantity2D ( CQPtr *cq, Counter ni, Counter nj );
int zls_NewCQuantity3D ( CQPtr *cq, Counter ni, Counter nj, Counter nk );

int zls_DisposeCQuantity ( CQPtr cq );

//
// multi-dimensional array versions...
//

//
// Note reversed idices, reference arrays by  [j][i] or  [k][j][i]
//

int zls_NewCQuantity1DArr ( CQ1DArr *cq, Counter ni); // same as zls_NewQuantity1D but for Q1DArr syntax
int zls_NewCQuantity2DArr ( CQ2DArr *cq, Counter nj, Counter ni );
int zls_NewCQuantity3DArr ( CQ3DArr *cq, Counter nk, Counter nj, Counter ni );

int zls_DisposeCQuantity1DArr ( CQ1DArr cq );
int zls_DisposeCQuantity2DArr ( CQ2DArr cq );
int zls_DisposeCQuantity3DArr ( CQ3DArr cq );

//
// Wrap an array around and unstructured block, alternative to New, use
// Release to free without deleting data, no nBC option as the ns must
// equal the input data dims exactly: Not needed for 1D arrays.
//

int zls_SetCQuantity2DArr ( CQ2DArr *cq, CQPtr cdata, Counter nj, Counter ni );
int zls_SetCQuantity3DArr ( CQ3DArr *cq, CQPtr cdata, Counter nk, Counter nj, Counter ni );

int zls_ReleaseCQuantity2DArr ( CQ2DArr cq );
int zls_ReleaseCQuantity3DArr ( CQ3DArr cq );

//
// Extract an unstructured block, useful for I/O
//

int zls_GetCQuantity2DArr ( CQPtr *cdata, CQ2DArr cq );
int zls_GetCQuantity3DArr ( CQPtr *cdata, CQ3DArr cq );

//==========================================================================================
//
// Plain, uniterpreted integer quantity arrays
//
//==========================================================================================
//==========================================================================================
//
// Declared as I * 1DArr, I ** 2DArr and I *** 3DArr, may accessed as
// I[i], I[j][i] and I[k][j][i] or at single ptr from I, I[0] or
// I[0][0] in 1D , 2D and 3D.
//
//========================================

typedef Integer    * IPtr;  // plainest block , 1 2 or 3D

typedef Integer    * I1DArr;  // 1D array of Qs
typedef Integer   ** I2DArr;  // 2D array of Qs q   [j][i]  q   [0] is QPtr
typedef Integer  *** I3DArr;  // 3D array of Qs q[k][j][i]  q[0][0] is QPtr

//

int zls_NewInteger1D ( IPtr *q, Counter ni ); // same as zls_NewQuantity1DArr but for QPtr syntax
int zls_NewInteger2D ( IPtr *q, Counter ni, Counter nj );
int zls_NewInteger3D ( IPtr *q, Counter ni, Counter nj, Counter nk );

int zls_DisposeInteger ( IPtr q );

//
// multi-dimensional array versions...
//

//
// Note reversed idices, reference arrays by  [j][i] or  [k][j][i]
//

int zls_NewInteger1DArr ( I1DArr *q, Counter ni); // same as zls_NewQuantity1D but for Q1DArr syntax
int zls_NewInteger2DArr ( I2DArr *q, Counter nj, Counter ni );
int zls_NewInteger3DArr ( I3DArr *q, Counter nk, Counter nj, Counter ni );

int zls_DisposeInteger1DArr ( I1DArr q );
int zls_DisposeInteger2DArr ( I2DArr q );
int zls_DisposeInteger3DArr ( I3DArr q );

//
// Wrap an array around and unstructured block, alternative to New, use
// Release to free without deleting data, no nBC option as the ns must
// equal the input data dims exactly: Not needed for 1D arrays.
//

int zls_SetInteger2DArr ( I2DArr *q, IPtr data, Counter nj, Counter ni );
int zls_SetInteger3DArr ( I3DArr *q, IPtr data, Counter nk, Counter nj, Counter ni );

int zls_ReleaseInteger2DArr ( I2DArr q );
int zls_ReleaseInteger3DArr ( I3DArr q );

//
// Extract an unstructured block, useful for I/O
//

int zls_GetInteger2DArr ( IPtr *data, I2DArr q );
int zls_GetInteger3DArr ( IPtr *data, I3DArr q );


#endif
