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
c     Adam D. Thomas, Yi-Fei Jin, Knox Long
c
c
c       Version v5.2.0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine compton
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! 
c! @return
c!  XXXX Add one or more lines describing what is updated
c! 
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine compton (t, de)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     This routine returns the non-relativistic net compton
c     heating.
c
c     ref: Krolik, McKee and Tarter Ap. J. 249:422-442
c
c     Thanks to Wang Chi Lin
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c
      real*8 t, de
      real*8 sigmat,f1,eav
      real*8 sumfe, sumf
      real*8 energ
      integer*4 i
c
c
      cmplos=0.d0
      cmpcool=0.d0
      cmpheat=0.d0
      if (linecoolmode.eq.1) return
c
c     relativistic (2hv/mc^2) term neglected
c
      sigmat=6.6524d-25
c
c     get totalflux sumf, and mean photon energy eav
c
      sumf=0.0d0
      sumfe=0.0d0
      do i=1,infph-1
        energ=ev*cphotev(i)
        f1=tphot(i)*widbinnu(i)
        sumfe=sumfe+f1*energ
        sumf=sumf+f1
      enddo
c
      if (sumf.gt.0.d0) then
c
        eav=sumfe/sumf
c
c     get the loss rate...
c
        cmplos=((sigmat*sumf)/(me*cls*cls))*de*((4*rkb*t)-eav)
        cmpcool=((sigmat*sumf)/(me*cls*cls))*de*((4*rkb*t))
        cmpheat=((sigmat*sumf)/(me*cls*cls))*de*(-eav)
      endif
c
      if (expertmode.gt.0) then
        write (*,10) 'Te,Ctot,ht,cl:',t,cmplos,cmpcool,cmpheat
   10    format (a15,1p4e15.4)
      endif
c
      return
      end
