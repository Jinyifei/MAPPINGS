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
c     Adam D. Thomas, Yi-Fei Jin
c
c
c       Version v5.1.21
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine kappainit ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Subroutine to setup electron distributions
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 k
      real*8 kap, x, delta
      character ilgg*4
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Non-thermal Kappa excitation,will move to init routine when debugged
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      kappaidx=9
      kappaa=1.d0
      kappab=0.d0
      usekappa=.false.
      usekappainterp=.false.
      kappa=1.0d99
c
   10 format(
     & /' ::::::::::::::::::::::::::::::::',
     & '::::::::::::::::::::::::::::::::::')
   20  format(
     & /' ::::::::::::::::::::::::::::::::',
     & '::::::::::::::::::::::::::::::::::',/
     & '  Electron Energy Distributions:'
     & /' ::::::::::::::::::::::::::::::::',
     & '::::::::::::::::::::::::::::::::::')
   30 format(/'  Maxwellian thermal distributions are being used.'/
     &       /'  Use Kappa electron distributions ? (y/N) : ',$)
   40 format (a)
   50 format(
     & /' ::::::::::::::::::::::::::::::::',
     & '::::::::::::::::::::::::::::::::::',/
     & '  Select a Kappa value'/
     & '   (2.0 - 1000.0, outside this range disabled)'/
     & '   (2.0, 3.0, 4.0, 6.0, 10.0, 20.0, 50.0, 100.0 are exact) :',$)
      usekappa=.false.
      if (kappamode.eq.1) then
        write (*,20)
        write (*,30)
        read (*,40) ilgg
        ilgg=ilgg(1:1)
        if (ilgg.eq.'y') ilgg='Y'
        if (ilgg.eq.'Y') usekappa=.true.
        if (usekappa) then
          write (*,50)
          read (*,*) kap
          if ((kap.ge.2.d0).and.(kap.le.1000.d0)) then
            kappa=kap
            do k=1,(nkappas-1)
              if (kap.ge.kappas(k)) kappaidx=k
            enddo
            delta=(1.d0/kappas(kappaidx))-(1.d0/kappas(kappaidx+1))
            x=(1.d0/kappa)-(1.d0/kappas(kappaidx+1))
            kappaa=x/delta
            kappab=1.d0-kappaa
            if (kappaa.lt.0.995d0) usekappainterp=.true.
c
            write (*,*) kappa,kappaA,kappaB,kappaidx,useKappaInterp
c
          else
            usekappa=.false.
          endif
        endif
      endif
c
      write (*,10)
c
      return
      end
