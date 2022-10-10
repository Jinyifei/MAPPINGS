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
c     Adam D. Thomas, Jin Yi-Fei, Knox Long
c
c
c       Version v5.2.0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine findtde ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******FIND TEMPERATURE (TOIII,TNII) USING LINE RATIOS (ROIII,RNII)
c     AND EL. DENS.(DEOIII,DENII) IN COMMON BLOCK /TONLIN/
c
c     FIND DENSITIES (DESII,DEOII) USING LINE RATIOS (RSII,ROII)
c     AND TEMPERATURE (TSII,TOII) IN COMMON BLOCK /DENLIN/
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c
      real*8 ao, bo, co, an, bn, cn, ratio
c
c
      real*8 a, b, c, tg, tgi
      real*8 ra
      integer*4 k, kf
      real*8 ftr, fde
c
c
      ftr(ratio,a,b)=b/(dlog(ratio)-dlog(a))
      fde(dens,tg,c)=1.d0+((c*dens)/dsqrt((tg*(0.5d0+dsign(0.5d0,tg)))+
     &1.d-20))
c
      kf=20
      ao=7.7321d0
      bo=3.2966d4
      co=4.3764d-4
      an=6.8662d0
      bn=2.4995d4
      cn=2.4037d-3
      toiii=0.0d0
c
c    *** OIII
c
      tnii=0.0d0
      ratio=roiii
      if (ratio.le.0.0d0) goto 20
      dens=deoiii
c
      tg=ftr(ratio,ao,bo)
c
      do k=1,kf
        tgi=tg
        ra=fde(dens,tg,co)*ratio
        tg=ftr(ra,ao,bo)
        if ((dabs(tg-tgi)/tg).lt.0.001d0) goto 10
      enddo
   10 toiii=tg
c
c    *** NII
c
   20 continue
      ratio=rnii
      if (ratio.le.0.0d0) goto 40
      dens=denii
c
      tg=ftr(ratio,an,bn)
      do k=1,kf
        tgi=tg
        ra=fde(dens,tg,cn)*ratio
        tg=ftr(ra,an,bn)
        if ((dabs(tg-tgi)/tg).lt.0.001d0) goto 30
      enddo
   30 tnii=tg
c
   40 continue
      return
      end
