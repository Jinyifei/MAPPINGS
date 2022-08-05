cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c standalone driver for optxagnf, and Jin et al Library generation
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      program agnspec
c
      include 'const.inc'
c
      integer i,j,ifl,luin
      character filename*80
      character ilgg*4,ibuf(20)*4
      real*8 ear(0:nn),photar(nn),param(14)
      real*8 total(nn), disk(nn), coro(nn), nont(nn)
      real*8 jbh(nn),ec(nn),lec(nn),mint(nn),minj(nn)
      real*8 tot, dsk, cor, non, scale
      real*8 dloge,ew,lum,a
      real*8 invz, zfac
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     call params for optxagnf
c
c     param(1) mass in solar 1e6 - 1e9
      param(1)=1.0d7
c     param(2) distance Mpc 413.5
      param(2)=413.5d0
c     param(3) log10 mass accretion rate in L/LEdd, -6 - 0, > 0 linear
      param(3)=-1.0d0
c     param(4) astar - BH rotation parameter - set 0.0
      param(4)=0.0d0
c     param(5) linear rcorona/rg 6 - rout :  40/60 if -ve return only disc
      param(5)=40.0d0
c     param(6) log10 rout/rg
      param(6)=4.0d0
c     param(7) opt thick kte in keV, 0.2 default?
      param(7)=0.2d0
c     param(8) opt thick tau  ~10 15       if -ve return only comp
      param(8)=15.0d0
c     param(9) power law gamma, -ve slope of hard powerlaw in phot spec
      param(9)=2.2d0
c     param(10) frac of c power in power law. 0.2 0.5,-ve return only pl
      param(10)=0.2d0
c     param(11) redshift 0.1
      param(11)=0.0d0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      luin=21
   10 format(20a4)
   20 format(' ',20a4)
      filename='agn.conf'
      open (luin,file=filename,status='OLD')
   50 read (luin,10) (ibuf(j),j=1,20)
      ilgg=ibuf(1)
      if (ilgg(1:1).eq.'%') goto 50
      write (*,20) (ibuf(j),j=1,20)
c param 1
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      if ( a.le.9.d0) a = 10.d0**a
      if ((a.ge.1.0d6).and.(a.le.1.0d9)) param(1)=a
c param 2
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      if ( a.gt.1.d6) a = a/(1.d6*pc)
      param(2)=a
c param 3
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      if (a.gt.0.0d0) a=dlog10(a)
      param(3)=a
c param 4
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      param(4)=a
c param 5
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      if (a.lt.6.0d0) a=6.d0
      param(5)=a
c param 6
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      param(6)=a
c param 7
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      param(7)=a
c param 8
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      if (a.lt.0.0d0) a=0.0d0
      param(8)=a
c param 9
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      param(9)=a
c param 10
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      param(10)=a
c param 11
      read (luin,10) (ibuf(j),j=1,20)
c      write (*,20) (ibuf(j),j=1,20)
      read(luin,*) a
      if ( a.lt.0.d0) a = 0.0d0
      param(11)=a
      close(luin)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      zfac=1.d0+param(11)
c
c obs energy array
c
      ear(0)=1.0d-4
      ear(nn)=5.0d2
c
      dloge=dlog10(ear(nn)/ear(0))/dble(nn)
      do i=1,nn,1
        ear(i)=10.d0**(dlog10(ear(0))+dloge*dble(i))
      enddo
c
      do i=1,nn,1
        ec(i)=0.5d0*(ear(i)+ear(i-1))
      enddo
c
c optxagnf returns bin integral photons at right edge of bin
c Phots/s/cm^2  ie already multiplied by e(i)-e(i-1)
c
c note, some subroutines have pretty  sloppy low accuracy
c constants (eg pc = 3e18cm) , plus L/LEdd is not
c strictly enforced when fcor is applied.
c May need to be renormalised.
c
      ifl=0  ! ignored, kept for xspec API
c
      param( 5) =  dabs(param( 5))
      param( 8) =  dabs(param( 8))
      param(10) =  dabs(param(10))
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Get all components in one call
c
      call optxagnf (ear, nn, param, ifl, total, disk, coro, nont)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        now redshift the energy bins back if necessay
c
      if (param(11).gt.1.d0) then
      zfac=1.0d0+param(11) ! 1+z
      invz=1.d0/zfac
      do i=0,nn,1
        ear(i)=ear(i)*invz
      enddo
c        and now correct the flux
      do i=1,nn,1
        total(i)=total(i)*invz
        disk(i)=disk(i)*invz
        coro(i)=coro(i)*invz
        nont(i)=nont(i)*invz
      enddo
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  100 format( " M_BH: ",1pg12.4," M_0        ",
     &        " L  : ",1pg12.4," L/Ledd ",/
     &        " D   : ",1pg12.4," cm         ",
     &        " z  : ",1pg12.4," redshift ",/
     &        " Rcor: ",1pg12.4," Rg         ",
     &        " Ro : ",1pg12.4," Rg ",/
     &        " C_T : ",1pg12.4," keV        ",
     &        " Tau: ",1pg12.4," Optical Depth ",/
     &        " gam : ",1pg12.4," (-slope)   ",
     &        " fpl: ",1pg12.4," Fraction ",/
     &        " E               DeltaE          E.FE total     ",
     &        " E.FE Disk       E.FE Compton    E.FE NonThermal",/
     &        " (keV)           (keV)           E.E/cm2/s/E    ",
     &        " E.E/cm2/s/E     E.E/cm2/s/E     E.E/cm2/s/E  ")
c
      write(*,100) param( 1), (10.d0**param( 3))
     & ,param( 2)*pc*1.0d6, param(11)
     & ,param( 5), param( 6)
     & ,param( 7), param( 8)
     & ,param( 9), param(10)
c
  110 format(6(1pg15.8,x))
      do i=1,nn,1

        ew=(ear(i)-ear(i-1))
        scale=ec(i)*ec(i)/ew
        tot = total(i)*scale
        dsk = disk(i)*scale
        cor = coro(i)*scale
        non = nont(i)*scale
c
        if (tot.lt.1.0d-30) tot = 0.d0
        if (dsk.lt.1.0d-30) dsk = 0.d0
        if (cor.lt.1.0d-30) cor = 0.d0
        if (non.lt.1.0d-30) non = 0.d0
c
        write(*,110)
     &        ec(i),ew,tot,dsk,cor,non
      enddo
c
      end
