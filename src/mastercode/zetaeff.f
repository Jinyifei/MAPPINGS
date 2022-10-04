cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c       MAPPINGS V.  An Astrophysical Plasma Modelling Code.
c
c
c     Creative Commons v4.0 International
c     By Attribution, Share Alike
c     CC-BY-SA-4.0Intl https://creativecommons.org
c     1976 -- 2022+ Ralph Sutherland,
c     Michael Dopita, Luc Binette, Ian Evans,
c     Brent Groves, David Nicholls,
c     Adam D. Thomas, Jin Yi-Fei
c
c
c       Version v5.2.0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
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
