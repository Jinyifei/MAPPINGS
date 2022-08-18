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
c       Version v5.1.21
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine equion (t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO FIND IONISATION EQUILIBRIUM AT A GIVEN TEMP.& DENS.
c     FOR ALL ELEMENTS  ;  OUTPUT ELECTRONIC DENSITY  :  DE
c     AND THE FRACTIONAL ABUNDANCE OF THE DIFFERENT SPECIES
c     OF EACH ELEMENT  :  POP(6,11)  IN COMMON BLOCK /ELABU/
c     CALL SUBROUTINES IOHYD,IOBAL
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 popzero(mxion, mxelem)
      real*8 t, de, dh, tstep, xhy, difma
      real*8 difm1, difm2
      real*8 treh, trea, zm, xhyf, dif1
      real*8 dia, dift, dfh, dft
      integer*4 nf, n, m, idx, inttemp
c
      character mod*4, nff*4, nel*4
c
      tstep=1.d37
      mod='EQUI'
      xhy=-1.0d0
      nf=7
      difma=1.d-3
      difm1=1.d-4
      difm2=0.08d0
      treh=1.d-8
c
c
      trea=1.d-5
      nff='ALL'
      zm=0.0d0
      do idx=3,atypes
        zm=zm+zion(idx)
      enddo
c
c
c    ***ITERATES TO FIND IONIC POPULATIONS AT EQUILIBRIUM
c
      do m=1,7
        call copypop (pop, popzero)
        do n=1,nf
c
          call iohyd (dh, xhy, t, tstep, de, xhyf, mod)
c
          call difpop (pop, popzero, treh, 1, dif1)
c
          dia=dmax1(0.0d0,dlog(5.0d0/(zm+1.d-5))/20.0d0)*pop(2,1)
          if (dif1.ge.dia) then
            nel='ALL'
          elseif ((m.eq.1).and.(n.lt.nf)) then
            nel='HE'
          elseif (m.gt.2) then
            nel='ALL'
          endif
c
          if (de.lt.pzlimit) de=pzlimit
          call iobal (mod, nel, de, dh, xhyf, t, tstep)
          call difpop (pop, popzero, trea, atypes, dift)
c
          call copypop (pop, popzero)
c
          if ((dift.lt.difm1).and.(nel.eq.'HE')) goto 30
          if ((dift.lt.difm2).and.(nel.eq.'ALL')) goto 30
c
        enddo
c
   30   if (((nel.eq.'ALL').and.(dif1.lt.difma)).and.(dift.lt.difm2))
     &   goto 50
        call iohyd (dh, xhy, t, tstep, de, xhyf, mod)
        call iobal (mod, nff, de, dh, xhyf, t, tstep)
        inttemp=1
        call difpop (pop, popzero, treh, inttemp, dif1)
c
        call difpop (pop, popzero, trea, atypes, dift)
        if ((dif1.le.difma).and.(dift.le.difm2)) goto 50
c
      enddo
c
      if ((dif1.le.difma).and.(dift.le.difm2)) goto 50
      dfh=dif1/difma
      dft=dift/difm2
c
   50 continue
      return
      end
