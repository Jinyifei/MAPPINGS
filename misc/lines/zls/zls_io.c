#include "zls_io.h"

void zlsio_ZFPrintf ( zFile f, const char *template, ...){
    if ( f != NULL) {
        char buf[4096];
        UInt32 len;
        va_list ap;
        va_start (ap, template);
        len = vsprintf(buf, template, ap);
        va_end(ap);
        zlsio_write ( f, (void *)buf, len );
    }
}


void zlsio_ZFScanf ( zFile f, const char *template, ...){
    if ( f != NULL) {
        char buf[4096];
        UInt32 len = 4096;
        int err = zlsio_gets ( f, (void *)buf, len );
        if ( err == noErr ){
        va_list ap;
        va_start (ap, template);
        vsscanf (buf, template, ap);
        va_end(ap);
        }
    }
}

