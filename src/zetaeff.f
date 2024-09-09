cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.inc'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine zetaeff
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine zetaeff (dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******TO CALCULATE THE EFFECTIVE DENSITY OF PHOTONS PER PARTICLE
c     IT TAKES INTO ACCOUNT THE DIFFERENT CROSS SECTIONS OF
c     PHOTOIONISATION AND THE RELATIVE ABUNDANCES OF ELEMENTS.
c     GIVES ALSO TO THE FIRST ORDER THE IONISING FRONT VELOCITY VIOFR
c     CALL SUBR. ALLRATES
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 abr,dh
      real*8 ph
      real*8 wei
c
      integer*4 idx,ion
c
      character jjmod*4
c
      if (photonmode.eq.0) return
c
c
c    ***CALCULATE NEW PHOTOIONISATION/HEATING RATES IF NECESSARY.
c
      jjmod='PHOT'
      call allrates (100.d0, jjmod)
c
c
c    ***COMPUTES ZETAE IN COMMON BLOCK /DENLIN/
c
      wei=zion(1)
      ph=zion(1)*rphot(1,1)
c
      do idx=2,atypes
        abr=zion(idx)
        wei=wei+abr
        ion=maxion(idx)-1
        ph=ph+(abr*rphot(ion,idx))
        do ion=1,maxion(idx)-2
          wei=wei+abr
          ph=ph+(abr*(rphot(ion,idx)+auphot(ion,idx)))
        enddo
      enddo
c
      zetae=ph/(dh*wei)
c
      qhdh=qtosoh/dh
      qhdn=qhdh/zen
      uhdh=qhdh/cls
      viofr=qtosoh/((fi*dh)*zen)
c
      return
      end
