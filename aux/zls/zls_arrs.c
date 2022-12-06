#include "zls_arrs.h"

//
// private array creater/freers/setters/releasers, public interface 
// should use Dispose functions
//
void zlsZero2DArr(void ** a, MemSize elementsize, MemSize nj, MemSize ni){ 
  
  if (a[0]!=NULL){
    bzero((void *) a[0], ni*nj*elementsize); 
  }                       
}


void zlsZero3DArr( void *** a, MemSize elementsize, MemSize nk, MemSize nj, MemSize ni){ 
  
  if (a[0][0]!=NULL){
    bzero((void *) a[0][0], ni*nj*nk*elementsize); 
  }                       
}

//
// delete offset allocations, but leave data along, assuming there is a reference to the 
// data elsewhere

void zlsRelease2DArr(void **a){
// unwrap an array from a simple block, leaving the block untouched
  if (a!=NULL){
    free(a);
  }
}

void zlsRelease3DArr(void ***a){
// unwrap an array from a simple block, leaving the block untouched
  
  if (a!=NULL){
    if (a[0]!=NULL){
      free(a[0]);
    } 
    free(a);
  } 
}

void zlsFree2DArr(void **a){
// completely free a 2D Arr including main block
  if (a!=NULL){
    if (a[0]!=NULL){
      free(a[0]);// delete data block
    }
    free(a);
  }
}

void zlsFree3DArr(void ***a){
// completely free a 2D Arr including main block
  if (a!=NULL){
    if (a[0][0]!=NULL){
      free(a[0][0]); // delete data
    }
    
    if (a[0]!=NULL){
      free(a[0]);
    }   
    free(a);
  }
}

//
// private array constructors, public interface should use New functions
//

//
// these primitive routines return pointers, not error values, public interfaces use errors
//

void **  zlsAlloc2DArr(MemSize elementsize, MemSize nj, MemSize ni){ 
//elementsize in bytes
  
  void ** a; // cast for any array type
  char * base; // for computing row offsets
  MemSize j, jOffset; 
  
  a = (void **)malloc(nj*sizeof(void*)); // 1D array of row ptrs, = number of rows = j
  
  if(a == NULL){ 
    return NULL;
  }
  
  a[0] = (void *)calloc(1,ni*nj*elementsize); // allocate main memory block, plane
                      // remaining pointers are precalculated col offsets
  if(a[0] == NULL){
    free((void *)a);
    return NULL;
  }
//
// set up row offsets
//
  base = (char *)a[0];
  
  for( j=0; j<nj; j++){ // 0 is done, j to <nj to compute row offsets, each row is ni cells long
    jOffset = j*ni;
    a[j] = (void *)(base + jOffset*elementsize); //  ptr arith is in bytes
  }
  
  return (a);
}



void *** zlsAlloc3DArr( MemSize elementsize, MemSize nk, MemSize nj, MemSize ni){ 
//elementsize in bytes
// 
// a[k][j][i] is the ith element of the jth row, of the kth layer, i
// sequential in memory,
// 
// Option: use k,j,i loops like FORTRAN:
// C a[k][j][i] == FORTAN a(i,j,k)
//
// A problem lies in the desire to have the *first* index equate to the
// *x-direction*, *and* be sequential in memory but the C compiler
// interprets the indices in reverse order no matter what!  The last
// index is sequential in memory for these dynamic arrays and for
// normal c static arrays.  This is intrinsic to the C
// language/Compiler.
//
// So there are different loop orders vs index order conventions.
// Sequential memory access *is* faster, so either loop i{j{k{
// a[i][j][k]}}} , and z (k) is sequential. or   loop k{j{i{
// a[k][j][i]}}} , and x (i) is sequential (typical backwards C)
//
// The last is equivalent to a loop: do k do j do i a(i,j,k) enddo
// enddo enddo, i sequential in memory in Fortran. If x is sequential
// in memory - ie a common image convention and one where pointer
// arithmatic is often used too then reversing the loop indices and
// using k,j,i seems preferable, the binary is the same memory order in
// x, y ,z as the equivalent FORTRAN array and most image conventions,
// so no fiddling on output is needed.
//
// ZLS uses the second convention, the indices are reversed compared to
// fortran, but at least the loop indexes are nested in the same order
// as the array expression.  The arrays then have the same memory
// layout wrt to the indices i, j and k as FORTRAN arrays, and they
// only need to be written in reverse order: [k][j][i];
//
// This also makes it easier to use zlsAlloc2DArr to make the 3DArr,
// leveraging off previous work.
//
// The actual 3D data type is pointed to by a[0][0], and the rest of
// the 2D plane cross ref the 3D block rows and layers. a[][][] thus
// has 3 malloc'd blocks, a[0][0], 3d of elements. a[0] 2d of (void*)
// and a 1d of (void *) freeing this is in reverse order - trash
// a[0][0], then a[0] then a, after checking that a, a[0] and
// a[0][0][0] exist first.  zlsFree3DArr calles zlsFree2DArr after
// disposing of a[0][0] to do this.
//

  
  void *** a; // cast for any array type
  char * base; // for computing row/column offsets
  
  MemSize j, jOffset; 
  MemSize k, kOffset; 
  
  a = (void ***)zlsAlloc2DArr(sizeof(void *), nk, nj); // 2D array of k,j - layer/row ptrs
  
  if(a == NULL){ 
    return NULL;
  }
  
  a[0][0]     = (void *)calloc(1,ni*nj*nk*elementsize); // allocate main memory block, vol
                            // remaining pointers are precalculated row/plane offsets
  if(a[0][0]  == NULL){
    zlsFree2DArr((void **)a);
    return NULL;
  }
  
//
// set up row/plane offsets
//
  base = (char *)a[0][0];
  
  for( k=0; k<nk; k++){ // 0 is done, i to <ni to compute
    kOffset = k*(ni*nj);
    for( j=0; j<nj; j++){ // all of subsequent planes
      jOffset = j*ni;
      a[k][j] = (void *)(base + (kOffset+jOffset)*elementsize); //  ptr arith is in bytes
    }
  }
  
  return (a);
}

void **  zlsSet2DArr(void * data, MemSize elementsize, MemSize nj, MemSize ni){ 
// wrap an array around a simple block
  
  void ** a; // cast for any array type
  char * base; // for computing row offsets
  MemSize j, jOffset; 
  
  a = (void **)malloc(nj*sizeof(void * )); // 1D array of row ptrs, = number of rows = j
  
  if(a == NULL){ 
    return NULL;
  }
  
  a[0] = data; // set main memory block from data
         // remaining pointers are precalculated col offsets
  if(a[0] == NULL){   
    free((void *)a);  
    return NULL;
  }
//
// set up row offsets
//
  base = (char *)a[0];
  
  for( j=0; j<nj; j++){ // 0 is done, j to <nj to compute row offsets, each row is ni cells long
    jOffset = j*ni;
    a[j] = (void *)(base + jOffset*elementsize); //  ptr arith is in bytes
  }
  
  return (a);
}



void *** zlsSet3DArr( void * data, MemSize elementsize, MemSize nk, MemSize nj, MemSize ni){ 
// wrap an array around a simple block
  
  void *** a; // cast for any array type
  char * base; // for computing row/column offsets
  
  MemSize j, jOffset; 
  MemSize k, kOffset; 
  
  a = (void ***)zlsAlloc2DArr(sizeof(void *), nk, nj); // 2D array of k,j - layer/row ptrs
  
  if(a == NULL){ 
    return (a);
  }
  
  a[0][0]     = data; // allocate main memory block, vol
            // remaining pointers are precalculated row/plane offsets
  if(a[0][0]  == NULL){
    zlsFree2DArr((void **)a);
    return (NULL);
  }
  
//
// set up row/plane offsets
//
  base = (char *)a[0][0];
  
  for( k=0; k<nk; k++){ // 0 is done, i to <ni to compute
    kOffset = k*(ni*nj);
    for( j=0; j<nj; j++){ // all of subsequent planes
      jOffset = j*ni;
      a[k][j] = (void *)(base + (kOffset+jOffset)*elementsize); //  ptr arith is in bytes
    }
  }
  
  return (a);
}

