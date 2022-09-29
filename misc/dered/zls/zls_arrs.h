#ifndef ZLS_ARRS_H
#define ZLS_ARRS_H
#include "zls_types.h"
//
// private array creater/freers/setters/releasers, public interface
// should use New/Dispose functions
//
//
// private array constructors, public interface should use New functions
//

//
// these primitive routines return pointers, not error values, public
// interfaces use errors
//
// 
// a[k][j][i] is the ith element of the jth row, of the kth layer, i
// sequential in memory,
// 
// use k,j,i loops like FORTRAN and reverse the indices:   C a[k][j][i]
// == FORTAN a(i,j,k) ie   loop k{j{i{ a[k][j][i]}}} , and x(i) is
// sequential (typical backwards C)
//
// This is equivalent to a loop: do k do j do i a(i,j,k) enddo enddo
// enddo, i sequential in memory in Fortran.
//
// The actual 3D data type is pointed to by a[0][0], and the rest of
// the 2D plane cross ref the 3D block rows and layers. a[][][] thus
// has 3 malloc'd blocks, a[0][0], 3d of elements. a[0] 2d of (void*)
// and a 1d of (void *) freeing this is in reverse order - trash
// a[0][0], then a[0] then a, after checking that a, a[0] and
// a[0][0][0] exist first.  zlsFree3DArr calles zlsFree2DArr after
// disposing of a[0][0] to do this.
//
// All elementsizes in bytes.  The type MemSize allows for 64 bit memory
// systems.
//

void **  zlsAlloc2DArr(MemSize elementsize, MemSize nj, MemSize ni);
void *** zlsAlloc3DArr(MemSize elementsize, MemSize nk, MemSize nj, MemSize ni);

void zlsFree2DArr(void **a);
void zlsFree3DArr(void ***a);

// Set up arrays around an existing  data block

void **  zlsSet2DArr(void * data, MemSize elementsize, MemSize nj, MemSize ni);
void *** zlsSet3DArr(void * data, MemSize elementsize, MemSize nk, MemSize nj, MemSize ni);

//
// delete offset allocations, but leave data alone, assuming there is a reference to the 
// data elsewhere, goes with Set

void zlsRelease2DArr(void **a);
void zlsRelease3DArr(void ***a);

// set all elements to 0 quiickly

void zlsZero2DArr( void ** a, MemSize elementsize, MemSize nj, MemSize ni);
void zlsZero3DArr( void *** a, MemSize elementsize, MemSize nk, MemSize nj, MemSize ni);
  
#endif
