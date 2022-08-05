#ifndef ZLS_IO_H
#define ZLS_IO_H

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


#endif
