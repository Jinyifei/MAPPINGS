      implicit none
c
c     constants
c
      real*8 pi, c, kev, kkev, kevhz, h
      real*8 msun, stb, g, rgm, pc, ledd
      parameter( c    = 2.99792458d10)
      parameter( kev  = 1.6021766d-9)
      parameter( kkev = 1.16045193d7)
      parameter( kevhz= 2.41798935d17)
      parameter( h    = 6.62606957d-27)
      parameter( msun = 1.9891d+33)
      parameter( stb  = 5.67037d-5)
      parameter( g    = 6.67259d-8)
      parameter( rgm  = 1.47676d+5)
      parameter( pc   = 3.08568d+18)
      parameter( ledd = 1.2572d+38)
      parameter( pi=4.d0*datan(1.0d0))
c
c
      integer nn
      parameter(nn=3000)
c
