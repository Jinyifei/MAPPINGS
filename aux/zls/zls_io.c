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

#ifdef ZLSUSEPNG

// here all PNGs,have 8 bits per channel
#define ZLS_PNGINTERLACE  (PNG_INTERLACE_NONE)
#define ZLS_PNGCOMPRESS   (PNG_COMPRESSION_TYPE_BASE)
#define ZLS_PNGFILTER     (PNG_FILTER_TYPE_BASE)
#define ZLS_PNGTRANS      (PNG_TRANSFORM_IDENTITY)


//================================================
// 8 bit single channel with colour lookup table
//================================================

int Write_PNG8     (char * aFile, unsigned char * img, TIFFCTab * outTIFFCTab, int nxOut, int nyOut ){

    int err = 0;

    FILE * fileAccess = NULL;
    png_structp png_ptr;
    png_infop info_ptr;
    png_colorp palette;

    fileAccess = fopen( aFile, "wb");
    if (fileAccess) {

        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

        if (png_ptr == NULL)  {
            fclose(fileAccess);
            return (fileErr);
        }

        info_ptr = png_create_info_struct(png_ptr);
        if (info_ptr == NULL) {
            fclose(fileAccess);
            png_destroy_write_struct(&png_ptr,  NULL);
            return (fileErr);
        }

        png_init_io(png_ptr, fileAccess); // associate file with png_

        png_set_IHDR( png_ptr, info_ptr, nxOut, nyOut, 8,
                     PNG_COLOR_TYPE_PALETTE, ZLS_PNGINTERLACE, ZLS_PNGCOMPRESS, ZLS_PNGFILTER );

        palette = ( png_colorp) png_malloc(png_ptr, ( PNG_MAX_PALETTE_LENGTH * sizeof (png_color)) );

        int i;
        for (i = 0; i < PNG_MAX_PALETTE_LENGTH; i++){
            palette[i].red   = (unsigned char)((outTIFFCTab->red[i])>>8);
            palette[i].green = (unsigned char)((outTIFFCTab->green[i])>>8);
            palette[i].blue  = (unsigned char)((outTIFFCTab->blue[i])>>8);
        }//i

        png_set_PLTE(png_ptr, info_ptr, palette, PNG_MAX_PALETTE_LENGTH);

        png_write_info(png_ptr, info_ptr);

        png_uint_32 row_stride = nxOut; /* per row in image_buffer */
        png_uint_32 k;
        png_bytep row_pointers[nyOut];

        for (k = 0; k < nyOut; k++)
            row_pointers[k] = img + k*row_stride;

        png_write_image(png_ptr, row_pointers);

        png_write_end(png_ptr, info_ptr);

        png_destroy_write_struct(&png_ptr, &info_ptr);

        fclose(fileAccess);

    } else { err = fileErr;}

    return (err);

}


//================================================
// 8 bit single channel grayscale override colour lookup table
//================================================

int Write_PNG8gray     (char * aFile, unsigned char * img, int nxOut, int nyOut ){

    int err = 0;

    FILE * fileAccess = NULL;
    png_structp png_ptr;
    png_infop info_ptr;
    png_colorp palette;

    fileAccess = fopen( aFile, "wb");
    if (fileAccess) {

        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

        if (png_ptr == NULL)  {
            fclose(fileAccess);
            return (fileErr);
        }

        info_ptr = png_create_info_struct(png_ptr);
        if (info_ptr == NULL) {
            fclose(fileAccess);
            png_destroy_write_struct(&png_ptr,  NULL);
            return (fileErr);
        }

        png_init_io(png_ptr, fileAccess); // associate file with png_

        png_set_IHDR( png_ptr, info_ptr, nxOut, nyOut, 8,
                     PNG_COLOR_TYPE_PALETTE, ZLS_PNGINTERLACE, ZLS_PNGCOMPRESS, ZLS_PNGFILTER );

        palette = ( png_colorp) png_malloc(png_ptr, ( PNG_MAX_PALETTE_LENGTH * sizeof (png_color)) );

        int i;
        for (i = 0; i < PNG_MAX_PALETTE_LENGTH; i++){
            palette[i].red   = (unsigned char)(i);
            palette[i].green = (unsigned char)(i);
            palette[i].blue  = (unsigned char)(i);
        }//i

        png_set_PLTE(png_ptr, info_ptr, palette, PNG_MAX_PALETTE_LENGTH);

        png_write_info(png_ptr, info_ptr);

        png_uint_32 row_stride = nxOut; /* per row in image_buffer */
        png_uint_32 k;
        png_bytep row_pointers[nyOut];

        for (k = 0; k < nyOut; k++)
            row_pointers[k] = img + k*row_stride;

        png_write_image(png_ptr, row_pointers);

        png_write_end(png_ptr, info_ptr);

        png_destroy_write_struct(&png_ptr, &info_ptr);

        fclose(fileAccess);

    } else { err = fileErr;}

    return (err);

}



//================================================
// 8 bit three channel RGB files
//================================================

int Write_PNG8RGB     (char * aFile, unsigned char * imgR, unsigned char * imgG, unsigned char * imgB, int nxOut, int nyOut ){

    int err = 0;

    unsigned char  *imgRGB = NULL;
    unsigned int ySize = nyOut;

    FILE * fileAccess = NULL;
    png_structp png_ptr;
    png_infop info_ptr;


    // allocate rgb chunky pixel array and combine rgb planes

    imgRGB = (unsigned char *) malloc(3L*nxOut*nyOut);

    if (imgRGB != NULL) {

        int i, j, jOffset;

        for (j = 0; j<nyOut; j++){
            jOffset = nxOut*j;
            for (i = 0; i<nxOut; i++){

                imgRGB[3*(i + jOffset)  ] = imgR[i + jOffset];
                imgRGB[3*(i + jOffset)+1] = imgG[i + jOffset];
                imgRGB[3*(i + jOffset)+2] = imgB[i + jOffset];

            }//i
        }//j


        fileAccess =  fopen( aFile, "wb");

        if (fileAccess) {

            png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

            if (png_ptr == NULL)   {
                free(imgRGB);
                fclose(fileAccess);
                return (fileErr);
            }

            info_ptr = png_create_info_struct(png_ptr);
            if (info_ptr == NULL)  {
                free(imgRGB);
                fclose(fileAccess);
                png_destroy_write_struct(&png_ptr,  NULL);
                return (fileErr);
            }

            png_init_io(png_ptr, fileAccess); // associate file with png_

            png_set_IHDR( png_ptr, info_ptr, nxOut, nyOut, 8,
                         PNG_COLOR_TYPE_RGB, ZLS_PNGINTERLACE, ZLS_PNGCOMPRESS, ZLS_PNGFILTER );

            png_write_info(png_ptr, info_ptr);

            png_uint_32 row_stride = nxOut * 3; /* per row in image_buffer */
            png_uint_32 k;
            png_bytep row_pointers[ySize];

            for (k = 0; k < nyOut; k++)
                row_pointers[k] = imgRGB + k*row_stride;

            png_write_image(png_ptr, row_pointers);

            png_write_end(png_ptr, info_ptr);

            png_destroy_write_struct(&png_ptr, &info_ptr);

            fclose(fileAccess);

        } else { err = fileErr;}

        free(imgRGB);

    } // imgRGB allocated OK
    else { err = memErr;}

    return (err);

}

int Read_PNG8     (char * aFile, unsigned char ** img, TIFFCTab * outTIFFCTab, int *nxOut, int *nyOut ){

    int err = 0;

    FILE * fileAccess   = NULL;

    png_structp png_ptr = NULL;
    png_infop info_ptr  = NULL;
    png_uint_32  width, height;
    int  bit_depth, color_type;
    unsigned char  *image_data = NULL;

    png_uint_32  i, rowbytes;
    png_bytepp  row_pointers = NULL;

    unsigned char sig[8];

    *nxOut = 0;
    *nyOut = 0;
    *img = NULL;

    fileAccess =  fopen( aFile, "rb");

    if (fileAccess) {

        fread(sig, 1, 8, fileAccess);

        if ( png_check_sig(sig, 8) ){

            png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
            if (!png_ptr)
                return memErr;   /* out of memory */

            info_ptr = png_create_info_struct(png_ptr);
            if (!info_ptr) {
                png_destroy_read_struct(&png_ptr, NULL, NULL);
                return memErr;   /* out of memory */
            }

            png_init_io(png_ptr, fileAccess);
            png_set_sig_bytes(png_ptr, 8);  /* we already read the 8 signature bytes */

            if (setjmp(png_jmpbuf(png_ptr)))
            {
                png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
                fclose(fileAccess);
                return (fileErr);
            }

            png_read_info(png_ptr, info_ptr);  /* read all PNG info up to image data */


            /* alternatively, could make separate calls to png_get_image_width(),
             * etc., but want bit_depth and color_type for later [don't care about
             * compression_type and filter_type => NULLs] */

            png_get_IHDR(png_ptr, info_ptr, &width, &height, &bit_depth, &color_type,
                         NULL, NULL, NULL);

            if (( color_type == PNG_COLOR_TYPE_PALETTE ) && ( bit_depth == 8 )) {

                // only operate on 8 bit color palette files

                *nxOut = width;
                *nyOut = height;

                rowbytes = png_get_rowbytes(png_ptr, info_ptr);

                if ((image_data = (unsigned char *)malloc(rowbytes*height)) == NULL) {
                    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
                    return fileErr;
                }
                if ((row_pointers = (png_bytepp)malloc(height*sizeof(png_bytep))) == NULL) {
                    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
                    free(image_data);
                    image_data = NULL;
                    return fileErr;
                }
                /* set the individual row_pointers to point at the correct offsets */

                for (i = 0;  i < height;  ++i)
                    row_pointers[i] = image_data + i*rowbytes;

                /* now we can go ahead and just read the whole image */

                png_read_image(png_ptr, row_pointers);

                *img = image_data;

                // read pallette into outTIFFCTab->
                // nyi
                // outTIFFCTab = NULL;

                /* and we're done!  (png_read_end() can be omitted if no processing of
                 * post-IDAT text/time/etc. is desired) */

                free(row_pointers);
                row_pointers = NULL;
                
                //png_read_end(png_ptr, NULL);
                
                
            } else {
                return (formErr);
            }
            
            
            
        } else {
            err = fileErr;
        }
        
        fclose(fileAccess);
        
    } else {
        err = fileErr;
    }
    
    return (err);
    
}

int Read_PNG    (char * aFile, unsigned char ** img, int *nxOut, int *nyOut ){

    int err = 0;

    FILE * fileAccess   = NULL;

    png_structp png_ptr = NULL;
    png_infop info_ptr  = NULL;
    png_uint_32  width, height;
    int  bit_depth, color_type;
    unsigned char  *image_data = NULL;

    png_uint_32  i, rowbytes;
    png_bytepp  row_pointers = NULL;

    unsigned char sig[8];

    *nxOut = 0;
    *nyOut = 0;
    *img = NULL;

    fileAccess =  fopen( aFile, "rb");

    if (fileAccess) {

        fread(sig, 1, 8, fileAccess);

        if ( png_check_sig(sig, 8) ){

            png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
            if (!png_ptr)
                return memErr;   /* out of memory */

            info_ptr = png_create_info_struct(png_ptr);
            if (!info_ptr) {
                png_destroy_read_struct(&png_ptr, NULL, NULL);
                return memErr;   /* out of memory */
            }

            png_init_io(png_ptr, fileAccess);
            png_set_sig_bytes(png_ptr, 8);  /* we already read the 8 signature bytes */

            if (setjmp(png_jmpbuf(png_ptr)))
            {
                png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
                fclose(fileAccess);
                return (fileErr);
            }

            png_read_info(png_ptr, info_ptr);  /* read all PNG info up to image data */


            /* alternatively, could make separate calls to png_get_image_width(),
             * etc., but want bit_depth and color_type for later [don't care about
             * compression_type and filter_type => NULLs] */

            png_get_IHDR(png_ptr, info_ptr, &width, &height, &bit_depth, &color_type,
                         NULL, NULL, NULL);


                *nxOut = width;
                *nyOut = height;

                rowbytes = png_get_rowbytes(png_ptr, info_ptr);

                if ((image_data = (unsigned char *)malloc(rowbytes*height)) == NULL) {
                    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
                    return fileErr;
                }
                if ((row_pointers = (png_bytepp)malloc(height*sizeof(png_bytep))) == NULL) {
                    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
                    free(image_data);
                    image_data = NULL;
                    return fileErr;
                }
                /* set the individual row_pointers to point at the correct offsets */

                for (i = 0;  i < height;  ++i)
                    row_pointers[i] = image_data + i*rowbytes;

                /* now we can go ahead and just read the whole image */

                png_read_image(png_ptr, row_pointers);

                *img = image_data;

                /* and we're done!  (png_read_end() can be omitted if no processing of
                 * post-IDAT text/time/etc. is desired) */

                free(row_pointers);
                row_pointers = NULL;
                
                //png_read_end(png_ptr, NULL);            
            
            
        } else {
            err = fileErr;
        }
        
        fclose(fileAccess);
        
    } else {
        err = fileErr;
    }
    
    return (err);
    
}

int Read_PNGType     (char * aFile, int * color_type, int * bit_depth, int *nxOut, int *nyOut ){

    int err = 0;

    FILE * fileAccess   = NULL;

    png_structp png_ptr = NULL;
    png_infop info_ptr  = NULL;
    png_uint_32  width, height;

    unsigned char sig[8];

    *nxOut = 0;
    *nyOut = 0;

    *bit_depth = 0;
    *color_type = 0;

    fileAccess =  fopen( aFile, "rb");

    if (fileAccess) {

        fread(sig, 1, 8, fileAccess);

        if ( png_check_sig(sig, 8) ){

            png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
            if (!png_ptr)
                return memErr;   /* out of memory */

            info_ptr = png_create_info_struct(png_ptr);
            if (!info_ptr) {
                png_destroy_read_struct(&png_ptr, NULL, NULL);
                return memErr;   /* out of memory */
            }

            png_init_io(png_ptr, fileAccess);
            png_set_sig_bytes(png_ptr, 8);  /* we already read the 8 signature bytes */

            if (setjmp(png_jmpbuf(png_ptr)))
            {
                png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
                fclose(fileAccess);
                return (fileErr);
            }

            png_read_info(png_ptr, info_ptr);  /* read all PNG info up to image data */


            /* alternatively, could make separate calls to png_get_image_width(),
             * etc., but want bit_depth and color_type for later [don't care about
             * compression_type and filter_type => NULLs] */

            png_get_IHDR(png_ptr, info_ptr, &width, &height, bit_depth, color_type,
                         NULL, NULL, NULL);
            
            *nxOut = width;
            *nyOut = height;

            
        } else {
            err = fileErr;
        }
        
        fclose(fileAccess);
        
    } else {
        err = fileErr;
    }
    
    return (err);
    
}

#endif
