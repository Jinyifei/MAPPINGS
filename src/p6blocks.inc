cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.inc'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Photo 6 shared Variables - Mostly Files
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      character p6pfx*32
c
c modes in cblocks
c
c     character jbal*4 ! bln files
c     character jiel*4 ! Ionisation of elements
c     character jall*4 ! All Ions File
c     character jiem*4 ! Multi-level ions
c     character jlin*4 ! Lines by wavelength
c     character jcol*4 ! Ion columns
c     character jrat*4 ! rates
c     character jbnd*4 ! bands
c     character jspec*4
c
c Files and units
c
      integer*4 luop
      integer*4 lupf
      integer*4 lups
      integer*4 lusp
      integer*4 lunt
      integer*4 lupb
      integer*4 lulin
      integer*4 lurt
      integer*4 lusl
      integer*4 luions(mxelem)
      integer*4 luemiss(mxelem)
      integer*4 lucols(mxmonmlions)
      integer*4 ir1
c
      common /photoP6L/ luop,lups,lupf,lusl,
     & lusp,lunt,lurt,lulin,ir1,lupb,
     & luions,lucols,luemiss
c
      character filnam*64
      character filna*64
      character filnb*64
      character filnc*64
      character filnd*64
      character filin*64
      character filio*64
      character filpb*64
      character filnt*64
      character filrt*64
      character filn(mxelem)*64
      character filncol(mxelem)*64
      character filnem(mxmonmlions)*64
c
      common /photoP6C/ p6pfx,filio,filnam,
     & filnb,filin,filnc,filnd,filnt,filna,filpb,
     & filn,filncol,filnem,filrt
c
