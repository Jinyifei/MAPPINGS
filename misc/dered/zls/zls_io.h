#ifndef ZLS_IO_H
#define ZLS_IO_H

//#define ZLSUSEPNG

#include "zls_types.h"
#include "zls_qs.h"

typedef gzFile zFile;

static inline zFile zlsio_open ( char * path, char * mode );
static inline zFile zlsio_open ( char * path, char * mode ){
    return( gzopen( path, mode ) );
}

static inline int zlsio_write ( zFile f, void * p, UInt32 s );
static inline int zlsio_write ( zFile f, void * p, UInt32 s ){
    int err;
    gzwrite( f, p, s );
    gzerror ( f, &err );
    if ( err >= 0 ) err = noErr;
    return( err );
}


static inline int zlsio_read ( zFile f, void * p, UInt32 s );
static inline int zlsio_read ( zFile f, void * p, UInt32 s ){
    int err;
    gzread( f, p, s );
    gzerror ( f, &err );
    if ( err >= 0 ) err = noErr;
    return( err );
}

static inline int zlsio_seek ( zFile f, UInt32 offset ); // always from start of file, ie SEEK_SET
static inline int zlsio_seek ( zFile f, UInt32 offset ){
    int err;
    gzseek( f, offset, SEEK_SET );
    gzerror ( f, &err );
    if ( err >= 0 ) err = noErr;
    return( err );
}


static inline int zlsio_gets ( zFile f, void * p, UInt32 s );
static inline int zlsio_gets ( zFile f, void * p, UInt32 s ){
    int err;
    char * line = gzgets( f, p, s );
    gzerror ( f, &err );
    if ( err >= 0 )  err = noErr;
    if ( line == NULL )  err = fileErr;
    return( err );
}

static inline int zlsio_close ( zFile f );
static inline int zlsio_close ( zFile f ){
    return( gzclose( f ) );
}

#ifdef ZLSUSEPNG

#include "png/png.h"

//----------------------------------------------------------------------------------------------------------------
//
// PNG File IO Routines
//
//----------------------------------------------------------------------------------------------------------------

// here all PNGs have 8 bits per channel

//================================================
// 8 bit single channel with colour lookup table
//================================================

int Write_PNG8    ( char * aFile, unsigned char * img, TIFFCTab * outTIFFCTab, int nxOut, int nyOut );

//================================================
// 8 bit single channel grayscale override colour lookup table
//================================================

int Write_PNG8gray( char * aFile, unsigned char * img, int nxOut, int nyOut );

//================================================
// 8 bit three channel RGB files
//================================================

int Write_PNG8RGB ( char * aFile, unsigned char * imgR, unsigned char * imgG, unsigned char * imgB, int nxOut, int nyOut );

//================================================
// 8 bit  channel with/without colour lookup table
//================================================

int Read_PNG      ( char * aFile, unsigned char ** img, int *nxOut, int *nyOut );
int Read_PNG8     ( char * aFile, unsigned char ** img, TIFFCTab * outTIFFCTab, int *nxOut, int *nyOut );
int Read_PNGType  ( char * aFile, int * color_type, int * bit_depth, int *nxOut, int *nyOut );

#endif

#endif
