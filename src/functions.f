cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.inc'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function casab(nz,line,series)
c! XXXX - add one line purpose here
c! @param [in,out] integer*4        nz  XXX-meaning
c! @param [in,out] integer*4      line  XXX-meaning
c! @param [in,out] integer*4    series  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function casab(nz,line,series)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO DETERMINE CASE A,B  (CASEAB  0=CASE A , 1=CASE B)
c   SUBROUTINE  RESTRANS  NEEDS TO BE PREVIOUSLY CALLED
c   USES ESCAPE PROBABILITY OF LYMAN-GAMMA PHOTONS
c   for hydrogen or helium
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 trg,  x_sec, abfrac
      integer*4 line,series,nz,atom
c
c      test always case A for all elements-
c     casab=0.d0
c     return
c
c     currently only line=3,series=1 considered
c
      trg=-0.859674131d0
c
      atom=zmap(nz)
      x_sec=0.d0
      if (nz.eq.1) then
        x_sec=hydlin(2,line,series)-1.0d0
      endif
      if (nz.eq.2) then
        x_sec=hellin(2,line,series)-1.0d0
      endif
      if ((nz.gt.2).and.(atom.gt.0)) then
c        x_sec=xhydlin(2,line,series,atom)-1.0d0
c      always case A for heavy elements
        casab=0.d0
        return
      endif
c
      abfrac=0.0
c
      x_sec=dmax1(x_sec,0.0d0)
c
      if (x_sec.lt.42.d0) then
        abfrac=dexp(trg*x_sec)
      endif
c
      casab=1.0d0-abfrac
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function densnum(dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function densnum(dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******GIVES TOTAL NUMBER DENSITY INCLUDING ALL ELEMENTS  .
c   USES RELATIVE ABUNDANCES  :  ZION(I)
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 i
      real*8 dh
c
      densnum=0.0d0
      do i=1,atypes
        densnum=densnum+zion(i)
      enddo
c
      densnum=dh*densnum
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function denstot(dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function denstot(dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******GIVES TOTAL DENSITY IN atomic mass units / cc
c   USES ATOMIC MASSES  :  ATWEI   AND RELAT. ABUND.  :  ZION
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 i
      real*8 dh,d
c
      d=0.0d0
      do i=1,atypes
        d=d+(zion(i)*atwei(i))
      enddo
c
      denstot=dh*d
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function dfuint(bet, sa, b1, b2, alo)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8       bet  XXX-meaning
c! @param [in,out]   real*8        sa  XXX-meaning
c! @param [in,out]   real*8        b1  XXX-meaning
c! @param [in,out]   real*8        b2  XXX-meaning
c! @param [in,out]   real*8       alo  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function dfuint(bet, sa, b1, b2, alo)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******COMPUTES INTEGRAL FOR THE PHOTOIONISATION RATES
c   ARGUMENTS B1 AND B2 IN DOUBLE PRECIS.
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      real*8 da, db, dc, dd, dl, dk, b2, b1
      real*8 bet, sa, alo, sa1, df
      real*8 aldl, lb1, lb2, lsa, lsa1
c
      dfuint=0.d0
      df=0.0d0
c
      da=0.d0
      db=0.d0
      dc=0.d0
      dd=0.d0
      dl=0.d0
      dk=0.d0
c
      sa1=sa+1.0d0
c
      if (sa1.lt.12.0d0) then
        if (sa.eq.0.0d0) then
          da=bet*(((b2**sa1)/sa1)-((b1**sa1)/sa1))
          db=(1.0d0-bet)*(dlog(b2)-dlog(b1))
        elseif (sa1.eq.0.0d0) then
          da=bet*(dlog(b2)-dlog(b1))
          db=(1.0d0-bet)*(((b2**sa)/sa)-((b1**sa)/sa))
        else
          da=bet*(((b2**sa1)/sa1)-((b1**sa1)/sa1))
          db=(1.0d0-bet)*(((b2**sa)/sa)-((b1**sa)/sa))
        endif
c
        dl=da+db
c
        if (dl.le.0.d0) then
          df=0.0d0
        else
          aldl=(alo+dlog(dl))
          if (dabs(aldl).lt.logkhuge) then
            df=dexp(aldl)
          endif
        endif
      else
        lb1=dlog(b1)
        lb2=dlog(b2)
        lsa=dlog(dabs((sa)))
        lsa1=dlog(dabs((sa1)))
        da=(alo+(sa1*lb2))-lsa1
        db=(alo+(sa1*lb1))-lsa1
        dc=(alo+(sa*lb2))-lsa
        dd=(alo+(sa*lb1))-lsa
        if ((dabs(da).lt.logkhuge).and.(dabs(db).lt.logkhuge)) then
          dl=(bet*(dexp(da)-dexp(db)))*dsign(1.0d0,sa1)
        endif
        if ((dabs(dc).lt.maxdekt).and.(dabs(dd).lt.maxdekt)) then
          dk=((1.0d0-bet)*(dexp(dc)-dexp(dd)))*dsign(1.0d0,sa)
        endif
c
        df=dmax1(0.d0,dl+dk)
c
      endif
c
      dfuint=df
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function vernerph1(e,l,ph1)
c! XXXX - add one line purpose here
c! @param [in,out] implicit         e  XXX-meaning
c! @param [in,out] implicit         l  XXX-meaning
c! @param [in,out] implicit       ph1  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function vernerph1(e,l,ph1)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   This function will evaluate the first form H-S photo cross sections
c   from Verner et al 1998
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
c
      real*8 e
      real*8 ph1(5)
      integer*4 l
      real*8 p1,y,q,a,b,s
      p1=-ph1(4)
      y=e/ph1(1)
      q=-0.5d0*p1-dble(l)-5.5d0
      a=ph1(2)*(((y-1.d0)*(y-1.d0))+(ph1(5)*ph1(5)))
      b=dsqrt(y/ph1(3))+1.d0
      s=a*(y**q)*(b**p1)
      vernerph1=s
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function vernerph2(e,ph2)
c! XXXX - add one line purpose here
c! @param [in,out] implicit         e  XXX-meaning
c! @param [in,out] implicit       ph2  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function vernerph2(e,ph2)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   This function will evaluate the second form H-S photo cross sections
c   from Verner et al 1998
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
c
      real*8 e
      real*8 ph2(7)
      real*8 p1,q,x,z,a,b,s
      p1=-ph2(4)
      q=-0.5d0*p1-5.5d0
      x=e/ph2(1)-ph2(6)
      z=dsqrt((x*x)+(ph2(7)*ph2(7)))
      a=ph2(2)*(((x-1.d0)*(x-1.d0))+(ph2(5)*ph2(5)))
      b=1.d0+dsqrt(z/ph2(3))
      s=a*(z**q)*(b**p1)
      vernerph2=s
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function vernerphoto(e,ion)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         e  XXX-meaning
c! @param [in,out]   real*8       ion  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function vernerphoto(e,ion)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c compute photo crossection for ion in phiondat list
c at energy e (eV), returns cross section in cgs units
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 e
      integer*4 ion
      integer*4 l
      integer*4 j
      real*8 ph2limit,cx
      real*8 p1(5),p2(7)
      real*8 vernerph1
      real*8 vernerph2
c
      cx=0.d0
c
      if (e.ge.ipotpho(ion)) then
c
c only compute above any edge, returns 0.0 below the edge
c
c
        l=lquantpho(ion)
        do j=1,5
          p1(j)=ph1pho(j,ion)
        enddo
        cx=vernerph1(e,l,p1)
        if (ph2mode.eq.0) then
c
          do j=1,7
            p2(j)=ph2pho(j,ion)
          enddo
          ph2limit=ph2limitpho(ion)
c
c most using ph1 H-S cross sections, except outer shell and
c some shells masked off.  All use ph1 fit above ph2limit.
c
c outer ground level uses ph2 up to ph2limit and ph1 beyond that
c
          if (ph2limit.gt.0.d0) then
            if (hasph2(ion).eq.1) then
              if (e.lt.ph2limit) then
                cx=vernerph2(e,p2)
              else
                cx=vernerph1(e,l,p1)
              endif
            else
              if (e.ge.ph2limit) then
                cx=vernerph1(e,l,p1)
              endif
            endif
          else
            if (hasph2(ion).eq.1) then
              cx=vernerph2(e,p2)
            else
              cx=vernerph1(e,l,p1)
            endif
          endif
        else
c
c all using ph1 H-S cross sections
c
          cx=vernerph1(e,l,p1)
c
        endif
      endif
c  Mb -> cm^2
      vernerphoto=cx*1.d-18
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     These functions evaluate the first exponential integral;
c     E1(x) and exp(x)*E1(x), x real > 0
c     Using the A&S poly fit, rel error < 1e-7
c     from Abramowitz and Stegun or DMLF in public domain
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fE1(x)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fE1(x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    Compute first exponential integral E1(x) = -Ei(-x)
c    Fast version
      implicit none
      real*8 x,f,nx
      real*8 a(0:5)
      real*8 b(1:4)
      real*8 c(1:4)
      data a / -0.57721566490d0,0.99999193d0,-0.24991055d0,
     &          0.05519968d0,  -0.00976004d0, 0.00107857d0 /
      data b / 8.5733287401d0,18.059016973d0,
     &         8.6347608925d0,0.2677737343d0 /
      data c / 9.5733223454d0,25.6329561486d0,
     &        21.0996530827d0, 3.9584969228d0 /
      data nx / 0.d0 /
c
      if (x.le.0.d0) then
        fE1=(0.d0/nx)
        return
      endif
c
c     evaluate E1(x) = integral(1 to inf)(e^-xt)/t dt
c
      f=0.d0
      if (x.lt.700.d0) then
        if (x.lt.1.d0) then
c     A&S Eqn 5.1.53 pg231
          f=a(0)+x*(a(1)+x*(a(2)+x*(a(3)+x*(a(4)+x*a(5)))))-dlog(x)
        else
c     A&S Eqn 5.1.56 pg 231
          f=(b(4)+x*(b(3)+x*(b(2)+x*(b(1)+x))))
          f=f*dexp(-x)/(x*(c(4)+x*(c(3)+x*(c(2)+x*(c(1)+x)))))
        endif
      endif
      fE1=f
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fexpE1(x)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fexpE1(x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    Compute exp(x)*first exponential integral: exp(x)*E1(x)
c    but does so by retaining internal exp(x) term in series for x>1
c    for stability at large x, exp(x) is well behaved with 0<x<1.
c    Here x can go much much larger than for,E1(x) alone.
c    Fast version, see cody version for precision
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 x,f,nx
      real*8 a(0:5)
      real*8 b(1:4)
      real*8 c(1:4)
      data a / -0.57721566490d0,0.99999193d0,-0.24991055d0,
     &          0.05519968d0,  -0.00976004d0, 0.00107857d0 /
      data b / 8.5733287401d0,18.059016973d0,
     &         8.6347608925d0,0.2677737343d0 /
      data c / 9.5733223454d0,25.6329561486d0,
     &        21.0996530827d0, 3.9584969228d0 /
      data nx / 0.d0 /
c
      if (x.le.0.d0) then
        fexpE1=(0.d0/nx)
        return
      endif
c
c     evaluate exp(x)*E1(x) = exp(x)*integral(1 to inf)(e^-xt)/t dt
c
      f=0.d0
      if (x.lt.1.d0) then
c     A&S Eqn 5.1.53 pg231
        f=a(0)+x*(a(1)+x*(a(2)+x*(a(3)+x*(a(4)+x*a(5)))))-dlog(x)
        f=f*dexp(x)
      else
c     A&S Eqn 5.1.56 pg 231
        f=(b(4)+x*(b(3)+x*(b(2)+x*(b(1)+x))))
        f=f/(x*(c(4)+x*(c(3)+x*(c(2)+x*(c(1)+x)))))
      endif
      fexpE1=f
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fcodyE1(x)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fcodyE1(x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Precise Exponential Integral, E1(x) and exp(x)*E1(x), x real > 0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c----------------------------------------------------------------------
c    Compute first exponential integral E1(x) = -Ei(-x)
c    DP accurate version
c----------------------------------------------------------------------
c           integral (from t=-infinity to t=x) (exp(t)/t),  x > 0,
c  Ei(x) =
c          -integral (from t=-x to t=infinity) (exp(t)/t),  x < 0,
c
c
c  E1(x) = -Ei(-x), x > 0
c
c     Function                      Parameters for CALCE1
c       Call                         ARG             RESULT
c      CALCE1(X,RESULT)            X .GT. 0          -Ei(-X)
c
c  The main computation involves evaluation of rational Chebyshev
c  approximations published in Math. Comp. 22, 641-649 (1968), and
c  Math. Comp. 23, 289-303 (1969) by Cody and Thacher.  This
c  transportable program is patterned after the machine-dependent
c  FUNPACK packet  NATSEI,  but cannot match that version for
c  efficiency or accuracy.  This version uses rational functions
c  that theoretically approximate the exponential integrals to
c  at least 18 significant decimal digits.  The accuracy achieved
c  depends on the arithmetic system, the compiler, the intrinsic
c  functions, and proper selection of the machine-dependent
c  constants.
c
c
c*******************************************************************
c*******************************************************************
c
c Explanation of machine-dependent constants
c
c   beta = radix for the floating-point system.
c   minexp = smallest representable power of beta.
c   maxexp = smallest power of beta that overflows.
c   XBIG = largest argument acceptable to EONE; solution to
c          equation:
c                     exp(-x)/x * (1 + 1/x) = beta ** minexp.
c   XINF = largest positive machine number; approximately
c                     beta ** maxexp
c   XMAX = largest argument acceptable to EI; solution to
c          equation:  exp(x)/x * (1 + 1/x) = beta ** maxexp.
c
c     Approximate values for some important machines are:
c
c                     beta      minexp      maxexp
c  IEEE   (S.P.)       2        -126         128
c  IEEE   (D.P.)       2       -1022        1024
c
c*******************************************************************
c*******************************************************************
c
c Intrinsic functions required are:
c
c     ABS, SQRT, EXP
c
c
c  Original Author: W. J. Cody
c          Mathematics abd Computer Science Division
c          Argonne National Laboratory
c          Argonne, IL 60439
c
c----------------------------------------------------------------------
      implicit none
      integer*4 i
      real*8 x
      real*8 xbig
      real*8 a,b,c,d,e,ei,f,sump,sumq,w
      real*8 zero,one,four
      dimension  a(7),b(6),c(9),d(9),e(10),f(10)
c----------------------------------------------------------------------
c  mathematical constants
c----------------------------------------------------------------------
      data zero,one,four/0.0d0,1.0d0,4.0d0/
c----------------------------------------------------------------------
c machine-dependent constants IEEE DP
c----------------------------------------------------------------------
      data xbig/701.84d0/
c----------------------------------------------------------------------
c coefficients  for -1.0 <= x < 0.0
c----------------------------------------------------------------------
      data a/1.1669552669734461083368d2, 2.1500672908092918123209d3,
     &       1.5924175980637303639884d4, 8.9904972007457256553251d4,
     &       1.5026059476436982420737d5,-1.4815102102575750838086d5,
     &       5.0196785185439843791020d0/
      data b/4.0205465640027706061433d1, 7.5043163907103936624165d2,
     &       8.1258035174768735759855d3, 5.2440529172056355429883d4,
     &       1.8434070063353677359298d5, 2.5666493484897117319268d5/
c----------------------------------------------------------------------
c coefficients for -4.0 <= x < -1.0
c----------------------------------------------------------------------
      data c/3.828573121022477169108d-1, 1.107326627786831743809d+1,
     &       7.246689782858597021199d+1, 1.700632978311516129328d+2,
     &       1.698106763764238382705d+2, 7.633628843705946890896d+1,
     &       1.487967702840464066613d+1, 9.999989642347613068437d-1,
     &       1.737331760720576030932d-8/
      data d/8.258160008564488034698d-2, 4.344836335509282083360d+0,
     &       4.662179610356861756812d+1, 1.775728186717289799677d+2,
     &       2.953136335677908517423d+2, 2.342573504717625153053d+2,
     &       9.021658450529372642314d+1, 1.587964570758947927903d+1,
     &       1.000000000000000000000d+0/
c----------------------------------------------------------------------
c coefficients for x < -4.0
c----------------------------------------------------------------------
      data e/1.3276881505637444622987d+2,3.5846198743996904308695d+4,
     &       1.7283375773777593926828d+5,2.6181454937205639647381d+5,
     &       1.7503273087497081314708d+5,5.9346841538837119172356d+4,
     &       1.0816852399095915622498d+4,1.0611777263550331766871d03,
     &       5.2199632588522572481039d+1,9.9999999999999999087819d-1/
      data f/3.9147856245556345627078d+4,2.5989762083608489777411d+5,
     &       5.5903756210022864003380d+5,5.4616842050691155735758d+5,
     &       2.7858134710520842139357d+5,7.9231787945279043698718d+4,
     &       1.2842808586627297365998d+4,1.1635769915320848035459d+3,
     &       5.4199632588522559414924d+1,1.0d0/
c----------------------------------------------------------------------
c return IEEE infinty for 0.d0 or less
c----------------------------------------------------------------------
      if (x.le.0.d0) then
        fcodyE1=(0.d0/zero)
        return
      endif
c----------------------------------------------------------------------
c calculate E1.
c----------------------------------------------------------------------
      ei=0.d0
      if (x.le.one) then
        sump=a(7)*x+a(1)
        sumq=x+b(1)
        do i=2,6
          sump=sump*x+a(i)
          sumq=sumq*x+b(i)
        enddo
        ei=dlog(x)-sump/sumq
      elseif (x.le.four) then
        w=one/x
        sump=c(1)
        sumq=d(1)
        do i=2,9
          sump=sump*w+c(i)
          sumq=sumq*w+d(i)
        enddo
        ei=-sump/sumq
        ei=ei*dexp(-x)
      else
        if (x.gt.xbig) then
          ei=zero
        else
          w=one/x
          sump=e(1)
          sumq=f(1)
          do i=2,10
            sump=sump*w+e(i)
            sumq=sumq*w+f(i)
          enddo
          ei=-w*(one-w*sump/sumq)
          ei=ei*dexp(-x)
        endif
      endif
      fcodyE1=-ei
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fcodyExpE1(arg)
c! XXXX - add one line purpose here
c! @param [in,out]  Unknown       arg  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fcodyExpE1(arg)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c----------------------------------------------------------------------
c    Compute exp(x)*E1(x) = -Ei(-x)*exp(x)
c
c    multiply by dexp(x) x < 1.0, remove dexp(-x) , x > 1
c    for stability at large x.
c
c    Here x can go much much larger than for,E1(x) alone.
c
c    DP accurate version
c----------------------------------------------------------------------
c           integral (from t=-infinity to t=x) (exp(t)/t),  x > 0,
c  Ei(x) =
c          -integral (from t=-x to t=infinity) (exp(t)/t),  x < 0,
c
c
c  E1(x) = -Ei(-x), x > 0
c
c     Function                      Parameters for CALCE1
c       Call                         ARG             RESULT
c      CALCE1(X,RESULT)            X .GT. 0          -Ei(-X)
c
c  The main computation involves evaluation of rational Chebyshev
c  approximations published in Math. Comp. 22, 641-649 (1968), and
c  Math. Comp. 23, 289-303 (1969) by Cody and Thacher.  This
c  transportable program is patterned after the machine-dependent
c  FUNPACK packet  NATSEI,  but cannot match that version for
c  efficiency or accuracy.  This version uses rational functions
c  that theoretically approximate the exponential integrals to
c  at least 18 significant decimal digits.  The accuracy achieved
c  depends on the arithmetic system, the compiler, the intrinsic
c  functions, and proper selection of the machine-dependent
c  constants.
c
c
c*******************************************************************
c*******************************************************************
c
c Explanation of machine-dependent constants
c
c   beta = radix for the floating-point system.
c   minexp = smallest representable power of beta.
c   maxexp = smallest power of beta that overflows.
c   XBIG = largest argument acceptable to EONE; solution to
c          equation:
c                     exp(-x)/x * (1 + 1/x) = beta ** minexp.
c   XINF = largest positive machine number; approximately
c                     beta ** maxexp
c   XMAX = largest argument acceptable to EI; solution to
c          equation:  exp(x)/x * (1 + 1/x) = beta ** maxexp.
c
c     Approximate values for some important machines are:
c
c                     beta      minexp      maxexp
c  IEEE   (S.P.)       2        -126         128
c  IEEE   (D.P.)       2       -1022        1024
c
c*******************************************************************
c*******************************************************************
c
c Intrinsic functions required are:
c
c     ABS, SQRT, EXP
c
c
c  Original Author: W. J. Cody
c          Mathematics and Computer Science Division
c          Argonne National Laboratory
c          Argonne, IL 60439
c
c----------------------------------------------------------------------
      implicit none
      integer*4 i
      real*8 arg,x
      real*8 a,b,c,d,e,ei,f,sump,sumq,w
      real*8 zero,one,four
      dimension  a(7),b(6),c(9),d(9),e(10),f(10)
c----------------------------------------------------------------------
c  mathematical constants
c----------------------------------------------------------------------
      data zero,one,four/0.0d0,1.0d0,4.0d0/
c----------------------------------------------------------------------
c coefficients  for -1.0 <= x < 0.0
c----------------------------------------------------------------------
      data a/1.1669552669734461083368d2, 2.1500672908092918123209d3,
     &       1.5924175980637303639884d4, 8.9904972007457256553251d4,
     &       1.5026059476436982420737d5,-1.4815102102575750838086d5,
     &       5.0196785185439843791020d0/
      data b/4.0205465640027706061433d1, 7.5043163907103936624165d2,
     &       8.1258035174768735759855d3, 5.2440529172056355429883d4,
     &       1.8434070063353677359298d5, 2.5666493484897117319268d5/
c----------------------------------------------------------------------
c coefficients for -4.0 <= x < -1.0
c----------------------------------------------------------------------
      data c/3.828573121022477169108d-1, 1.107326627786831743809d+1,
     &       7.246689782858597021199d+1, 1.700632978311516129328d+2,
     &       1.698106763764238382705d+2, 7.633628843705946890896d+1,
     &       1.487967702840464066613d+1, 9.999989642347613068437d-1,
     &       1.737331760720576030932d-8/
      data d/8.258160008564488034698d-2, 4.344836335509282083360d+0,
     &       4.662179610356861756812d+1, 1.775728186717289799677d+2,
     &       2.953136335677908517423d+2, 2.342573504717625153053d+2,
     &       9.021658450529372642314d+1, 1.587964570758947927903d+1,
     &       1.000000000000000000000d+0/
c----------------------------------------------------------------------
c coefficients for x < -4.0
c----------------------------------------------------------------------
      data e/1.3276881505637444622987d+2,3.5846198743996904308695d+4,
     &       1.7283375773777593926828d+5,2.6181454937205639647381d+5,
     &       1.7503273087497081314708d+5,5.9346841538837119172356d+4,
     &       1.0816852399095915622498d+4,1.0611777263550331766871d03,
     &       5.2199632588522572481039d+1,9.9999999999999999087819d-1/
      data f/3.9147856245556345627078d+4,2.5989762083608489777411d+5,
     &       5.5903756210022864003380d+5,5.4616842050691155735758d+5,
     &       2.7858134710520842139357d+5,7.9231787945279043698718d+4,
     &       1.2842808586627297365998d+4,1.1635769915320848035459d+3,
     &       5.4199632588522559414924d+1,1.0d0/
c----------------------------------------------------------------------
c return IEEE infinty for 0.d0 or less
c----------------------------------------------------------------------
      x=arg
      if (x.le.0.d0) then
        fcodyExpE1=(0.d0/zero)
        return
      endif
c----------------------------------------------------------------------
c calculate exp(x)*E1.
c----------------------------------------------------------------------
      ei=0.d0
      if (x.le.one) then
        sump=a(7)*x+a(1)
        sumq=x+b(1)
        do i=2,6
          sump=sump*x+a(i)
          sumq=sumq*x+b(i)
        enddo
        ei=dexp(x)*(dlog(x)-sump/sumq)
      elseif (x.le.four) then
        w=one/x
        sump=c(1)
        sumq=d(1)
        do i=2,9
          sump=sump*w+c(i)
          sumq=sumq*w+d(i)
        enddo
        ei=-sump/sumq
      else
        w=one/x
        sump=e(1)
        sumq=f(1)
        do i=2,10
          sump=sump*w+e(i)
          sumq=sumq*w+f(i)
        enddo
        ei=-w*(one-w*sump/sumq)
      endif
      fcodyExpE1=-ei
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function farint(sub,x)
c! XXXX - add one line purpose here
c! @param [in,out] integer*4       sub  XXX-meaning
c! @param [in,out] integer*4         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function farint(sub,x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     This subroutine will evaluate the exponential integrals
c     used by Arnaud and Rothenflug 1985 to evaluate collisional
c     ionisation rates.
c
c     ref: Arnaud, M., Rothenflug, R. 1985 A. A. Suppl. Ser. 62:425
c     particularly pages 435-436.
c
c     NOTE: there are some algebraic errors in the expressions published
c     and the function for f2 is only valid for large X.  I have used
c     my own series expansion for small x < 3 and AR's one for large X.
c
c     RSS 7/90
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 x
      integer*4 sub
c
c     sub is an index to the two different integrals
c
      real*8 xp,p,q,xinv
      real*8 fint
      real*8 fcodyExpE1
c
      real*8 pj(0:14), qj(0:14)
      integer*4 j
c
c     data for coefficients
c
      data pj / 1.d0,2.1658d2,2.0336d4,1.0911d6,3.7114d7,8.3963d8,
     &1.2889d10,1.3449d11,9.4002d11,4.2571d12,1.1743d13,1.7549d13,
     &1.0806d13,4.9776d11,0.0d0 /
c
      data qj / 1.0d0,2.1958d2,2.0984d4,1.1517d6,4.0349d7,9.4900d8,
     &1.5345d10,1.7182d11,1.3249d12,6.9071d12,2.3531d13,4.9432d13,
     &5.7760d13,3.0225d13,3.3641d12 /
c
c     begin calculations
c
      fint=0.d0
      if (sub.eq.1) then
c
c     evaluate f1(x) = e^x integral(1 to inf)(e^-xt)/t dt
c
        fint=fcodyExpE1(x)
c
      else
c
c     sub = 2
c
c     evaluate f2(x) = e^x integral(1 to inf) (e^-xt)ln(t)/t dt
c    (Note: *not* E_2)
c
        p=0.d0
        q=0.d0
        xp=1.d0
        xinv=1.d0/x
        do j=0,14
          p=p+xp*pj(j)
          q=q+xp*qj(j)
          xp=xp*xinv
        enddo
        fint=xinv*xinv*p/q
c
      endif
c
      farint=fint
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     exp(u)*E1(u)*exp(-rexp)
c     = fexpE1(u)*dexp(-rexp)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fue1(u, rexp)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         u  XXX-meaning
c! @param [in,out]   real*8      rexp  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fue1(u, rexp)
      implicit none
      real*8 u,rexp,fcodyExpE1
      fue1=fcodyExpE1(u)*dexp(-rexp)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fautoi(t,atom,ion)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8      atom  XXX-meaning
c! @param [in,out] integer*4       ion  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fautoi(t,atom,ion)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     function returns collisional autoionisation
c     rate for atom,ion. ref Arnaud&Rothenflug 1985 A.A.Supp.Ser.60:425
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t,f1,g,y,a,b,zr,cea
      real*8 term1,term2,ktev,iea
      integer*4 atom,ion,isos,z
c
c           Functions
c
      real*8 farint
c
      fautoi=0.d0
      cea=0.d0
      z=mapz(atom)
      zr=dble(z)
      isos=z-ion+1
      ktev=rkb*t/ev
c
c
      if (isos.eq.3) then
c
c     Lithium iso series
c
        term1=(zr-0.835d0)*(zr-0.835d0)
        term2=(zr-1.62d0)*(zr-1.62d0)
        iea=r_inf*term1-0.25d0*term2
        b=1.d0/(1.d0+2.d-4*zr*zr*zr)
c
c     an effective z due to screening?
c
        zr=zr-0.43d0
c
c     yet another gaunt factor
c
        y=iea/ktev
c
        cea=0.d0
        if (y.le.maxdekt) then
c
          f1=farint(1,y)
          g=2.22d0*f1+0.67d0*(1.d0-y*f1)+0.49d0*y*f1+1.2d0*y*(1.d0-y*f1)
c
c     see ref for explanation of 1.2 factor (Appendix A)
c
          cea=1.2d0*(1.60d-7*b*dexp(-y)*g/(zr*zr*dsqrt(ktev)))
c
        endif
c
c     correct for some particular species
c
        if (z.eq.6) cea=cea*0.6d0
        if (z.eq.7) cea=cea*0.8d0
        if (z.eq.8) cea=cea*1.25d0
c
      endif
c
      if (isos.eq.11) then
c
c     Sodium iso series
c
        if (z.le.16) then
c
          iea=26.d0*(zr-10.d0)
          y=iea/ktev
          cea=0.d0
          if (y.le.maxdekt) then
            f1=farint(1,y)
            a=2.8d-17*(zr-10.d0)**(-0.7d0)
            cea=6.69d7*a*iea*dexp(-y)*(1.d0-y*f1)/dsqrt(ktev)
            if (cea.lt.0.d0) cea=0.d0
          endif
c
        else
c     (16 <z <28)
c
          iea=11.d0*(zr-10.d0)**1.5d0
          y=iea/ktev
          cea=0.d0
          if (y.le.maxdekt) then
            f1=farint(1,y)
            a=1.3d-14*(zr-10.d0)**(-3.73d0)
            cea=6.69d7*a*iea*dexp(-y)*(1.d0-(y-y*y+y*y*y*f1)/2.d0)/
     &       dsqrt(ktev)
          endif
c
        endif
      endif
c
c
      if ((z.ge.18).and.(isos.gt.11).and.(isos.lt.17)) then
c
c     magnesium through sulphur series for heavy elements
c
        iea=0.d0
        if (isos.eq.12) iea=10.3d0*(zr-10.d0)**1.52d0
        if (isos.eq.13) iea=18.0d0*(zr-11.d0)**1.33d0
        if (isos.eq.14) iea=18.4d0*(zr-12.d0)**1.36d0
        if (isos.eq.15) iea=23.7d0*(zr-13.d0)**1.29d0
        if (isos.eq.16) iea=40.1d0*(zr-14.d0)**1.10d0
c
        y=iea/ktev
        cea=0.d0
        if (y.le.maxdekt) then
          f1=farint(1,y)
          a=(4.d-13/(zr*zr))/iea
          cea=6.69d7*a*iea*dexp(-y)*(1.d0-(y-y*y+y*y*y*f1)/2.d0)/
     &     dsqrt(ktev)
        endif
c
      endif
c
      if ((z.eq.20).and.(ion.le.2)) then
c
c     calcium I and II
c
        iea=25.d0+4.d0*dble(ion-1)
c
        a=6.0d-17+3.8d-17*dble(ion-1)
        b=1.12d0
c
        y=iea/ktev
c
        cea=0.d0
        if (y.le.maxdekt) then
          f1=farint(1,y)
          cea=6.69d7*a*iea*dexp(-y)*(1.d0+b*f1)/dsqrt(ktev)
        endif
c
      endif
c
      if ((z.eq.26).and.((ion.eq.4).or.(ion.eq.5))) then
c
c     Fe IV and V
c
        iea=60.d0+13.d0*dble(ion-4)
c
        a=1.8d-17-1.3d-17*dble(ion-4)
        b=1.00d0
c
        y=iea/ktev
c
        cea=0.d0
        if (y.le.maxdekt) then
c
          f1=farint(1,y)
c
          cea=6.69d7*a*iea*dexp(-y)*(1.d0+b*f1)/dsqrt(ktev)
c
        endif
c
      endif
c
c     pass back result
c
c      if (z.eq.17) then
c         write(*,*) t,' ',elem(atom),rom(ion),cea
c      endif
c
      fautoi=cea
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function favcha(popul)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8     popul  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function favcha(popul)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO DERIVE AVERAGE POSITIVE CHARGE PER NUCLEON
c   LINEAR:NOR=1 old
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 fne,wei,weito
      real*8 popul(mxion, mxelem)
      integer*4 i,j
c
      fne=0.0d0
      weito=0.0d0
c lin
      do i=1,atypes
        wei=zion(i)
        weito=weito+wei
        do j=2,maxion(i)
          fne=fne+((wei*(j-1))*popul(j,i))
        enddo
      enddo
c
      favcha=(fne/weito)
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function favcha2(popul)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8     popul  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function favcha2(popul)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO DERIVE AVERAGE POSITIVE CHARGE PER NUCLEON
c  RMS:NOR=2 old
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 fne,wei,weito
      real*8 popul(mxion, mxelem)
      integer*4 i,j
c
      fne=0.0d0
      weito=0.0d0
c rms
      do i=1,atypes
        wei=zion(i)
        weito=weito+wei
        do j=2,maxion(i)
          fne=fne+((wei*((j-1)*(j-1)))*popul(j,i))
        enddo
      enddo
c
      favcha2=dsqrt(fne/weito)
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fbessi(x)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fbessi(x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     function to evaluate the modified bessel function of
c     the first kind Io(x)
c
c     This is required for the exact free free gaunt
c     factor calculation
c
c     ref Mewe et al  1986 A.A.Suppl.Ser. 65:511
c     Abramowitz & Stegun Handbook of mathematical tables
c      (eds) public domain
c
c
c     Io(x) = 1/pi * integral(0-inf) cosh(x * cos t) dt
c
c
c     errors:
c       x <=3.75 : error < 2e-7
c       x >3.75 : error < 2e-7
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      real*8 x,i0,x3,x32
      real*8 a1,a2,a3,a4,a5,a6
      real*8 b1,b2,b3,b4,b5,b6,b7,b8,b9
c
c     assign polynomial constants
c
      parameter (a1 = 3.5156229d0)
      parameter (a2 = 3.0899424d0)
      parameter (a3 = 1.2067492d0)
      parameter (a4 = 0.2659732d0)
      parameter (a5 = 0.0360768d0)
      parameter (a6 = 0.0045813d0)
c
      parameter (b1 =  0.39894228d0)
      parameter (b2 =  0.01328592d0)
      parameter (b3 =  0.00225319d0)
      parameter (b4 = -0.00157565d0)
      parameter (b5 =  0.00916281d0)
      parameter (b6 = -0.02057706d0)
      parameter (b7 =  0.02635537d0)
      parameter (b8 = -0.01647633d0)
      parameter (b9 =  0.00392377d0)
c
      fbessi=0.0d0
      i0=0.0d0
c
c     this is only valid for  x > -3.75
c
      if (x.ge.-3.75d0) then
        if (x.le.3.75d0) then
          x3=x/3.75d0
          x32=x3*x3
          i0=1.d0+x32*(a1+x32*(a2+x32*(a3+x32*(a4+x32*(a5+x32*a6)))))
        else
          x3=3.75d0/x
          i0=b1+x3*(b2+x3*(b3+x3*(b4+x3*(b5+x3*(b6+x3*(b7+x3*(b8+x3*b9))
     &     )))))
          i0=i0/(dsqrt(x)*dexp(-x))
        endif
      else
        write (*,*) 'Error in fbessi, x argument too small'
        write (*,*) ' x = ',x
        stop
      endif
c
      fbessi=i0
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fbessk(x)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fbessk(x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     function to evaluate the modified bessel function of
c     the second kind exp(x)*Ko(x)
c
c     This is required for the exact free free gaunt
c     factor calculation
c
c     ref Mewe et al  1986 A.A.Suppl.Ser. 65:511
c     Abramowitz & Stegun Handbook of mathematical tables
c      (eds)
c
c
c     Ko(x) = integral(0 to infinity) cos(xt)/sqrt(t^2+1) dt
c
c     {x > 0}
c
c
c     errors:
c       x < 2 : error < 1e-8
c       x > 2 : error < 2e-7
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      real*8 fbessi
      real*8 x,k0,x2,x22
      real*8 a1,a2,a3,a4,a5,a6
      real*8 b1,b2,b3,b4,b5,b6,b7
c
c     assign polynomial constants
c
      parameter (a1 = 0.42278420d0)
      parameter (a2 = 0.23069756d0)
      parameter (a3 = 0.03488590d0)
      parameter (a4 = 0.00262698d0)
      parameter (a5 = 0.00010750d0)
      parameter (a6 = 0.00000740d0)
c
      parameter (b1 =  1.25331414d0)
      parameter (b2 = -0.07832358d0)
      parameter (b3 =  0.02189568d0)
      parameter (b4 = -0.01062446d0)
      parameter (b5 =  0.00587872d0)
      parameter (b6 = -0.00251540d0)
      parameter (b7 =  0.00053208d0)
c
      fbessk=0.0d0
      k0=0.0d0
c
c     this is only valid for positive x
c
      if (x.ge.0.0d0) then
        if (x.le.2.0d0) then
          x2=x/2.0d0
          x22=x2*x2
          k0=-dlog(x2)*fbessi(x)-euler
          k0=k0+(x22*(a1+x22*(a2+x22*(a3+x22*(a4+x22*(a5+x22*a6))))))
          k0=k0*dexp(x)
        else
          x2=2.0d0/x
          k0=b1+x2*(b2+x2*(b3+x2*(b4+x2*(b5+x2*(b6+x2*b7)))))
          k0=k0/dsqrt(x)
        endif
      else
        write (*,*) 'Error in fbessk, negative x argument'
        write (*,*) ' x = ',x
        stop
      endif
c
      fbessk=k0
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fcietim(dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fcietim(dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******TO DERIVE AVERAGE collsionial ionisation equilibrium
c       TIME SCALE
c   ASSUMING CONSTANT ELECTRONIC DENSITY : DE
c       Weighted by population fractions and abundances
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8  de, dh,rcol,totn,wei,feldens
      integer*4 i,j
c
      rcol=0.d0
      totn=0.d0
      fcietim=0.d0
      de=feldens(dh,pop)
c
      do i=1,atypes
        do j=1,maxion(i)-1
          totn=totn+pop(j,i)*zion(i)
        enddo
      enddo
c
      do i=1,atypes
        do j=1,maxion(i)-1
          wei=pop(j,i)*zion(i)
          rcol=rcol+(wei*(col(j,i)*de+epsilon))
        enddo
      enddo
c
      fcietim=totn/(rcol+epsilon)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fcolltim(de)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        de  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fcolltim(de)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c       Calculates Weighted Collisional Ionisation Timescales
c
c       Weighted by population fractions and abundances
c       Assumes that the rates are all up to date. call
c       Allrates otherwise.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 de,rcol,totn,wei
      integer*4 i,j
c
      rcol=0.d0
      totn=0.d0
      fcolltim=0.d0
c
      do i=1,atypes
        totn=totn+zion(i)
      enddo
c
      do i=1,atypes
c
        do j=1,maxion(i)-1
          wei=pop(j,i)*zion(i)
          rcol=rcol+(wei*col(j,i))
        enddo
c
      enddo
c
      fcolltim=totn/(de*rcol+epsilon)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fcrit(dloss, zeta)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8     dloss  XXX-meaning
c! @param [in,out]   real*8      zeta  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fcrit(dloss, zeta)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******DETERMINE THE CONVERGENCE CRITERION USING THE
c   SINC FUNCTION TO THE POWER ZETA
c   DLOS  MUST  SATISFY  :   -1<=DLOS <=1
c   OUTPUT  :  0<=FCRIT<=1.0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      real*8 dloss, zeta
c
      fcrit=((dabs(dsin((pi*dloss)+1.d-10))/dabs((pi*dloss)+1.d-10))+
     &1.d-10)**zeta
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fdilu(rsou, rad)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8      rsou  XXX-meaning
c! @param [in,out]   real*8       rad  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fdilu(rsou, rad)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******COMPUTES GEOMETRICAL DILUTION FACTOR
c   USING PHOTON SOURCE RADIUS : RSOU  AND RADIUS AT WHICH
c   IT IS CALCULATED : RAD
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 rio,gdilf,phi,cphi,fdilf
      real*8 rsou, rad, rsou2, rad2
c
c     default plane || factor (jgeo=P)
c
      fdilf=0.5d0
      gdilf=1.0d0
c
      if (jgeo.eq.'P') then
        gdilf=0.5d0
      endif
c
      if (jgeo.eq.'S') then
c
c     spherical geometry
c
        if (rad.le.rsou) then
          gdilf=1.d0
        else
          rio=(rsou)/rad
          if (rio.gt.4.0d-4) then
c
c     real*8 trig functions work
c
            rsou2=rsou*rsou
            rad2=rad*rad
            phi=dasin(rio)
            cphi=dcos(phi)
            gdilf=(rsou2-rad2*(1.0d0-cphi))/(rad2*cphi)
          else
            gdilf=(0.5d0*rio*rio)
          endif
        endif
      endif
c
      if (jgeo.eq.'F') then
c
c     finite plane parallel
c
        if (rad.le.0.d0) then
          gdilf=1.d0
        else
          rio=(rsou)/rad
          if (rio.gt.4.0d-4) then
c
c     real*8 trig functions work
c
            phi=datan(rio)
            cphi=dcos(phi)
            gdilf=(1.0d0-cphi)
          else
            gdilf=(0.5d0*rio*rio)
          endif
        endif
      endif
c
      fdilu=fdilf*gdilf
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function feldens(dh, popul)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        dh  XXX-meaning
c! @param [in,out]   real*8     popul  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function feldens(dh, popul)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******DERIVES THE ELECTRONIC DENSITY USING IONIC POPULATIONS
c   IN MATRIX POPUL(6,11)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'cblocks.inc'
c
      real*8 dh, popul(mxion, mxelem)
      real*8 ne, z, pz
c
c
      integer*4 i, j
c
      ne=0.0d0
      do i=1,atypes
        z=zion(i)
        do j=1,maxion(i)-1
          pz=z*popul(j+1,i)
          if (pz.gt.pzlimit) ne=ne+(dble(j)*pz)
        enddo
      enddo
c
      feldens=dh*ne
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function felneur(popul, neio)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8     popul  XXX-meaning
c! @param [in,out]   real*8      neio  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function felneur(popul, neio)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO COMPUTE ELECTRON TO NEUTRAL DENSITY RATIO (NEIO=1)
c   OR ELECTRON TO ION DENSITY RATIO
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 ael,ane
      real*8 popul(mxion, mxelem)
      integer*4 i,j,mm,neio
c
      mm=min0(2,max0(1,neio))
      ane=0.0d0
      ael=0.0d0
      do i=1,atypes
        do j=mm,maxion(i)
          ane=ane+(zion(i)*popul(j,i))
          ael=ael+((zion(i)*popul(j,i))*(j-1.0d0))
        enddo
      enddo
      if (mm.eq.1) then
        felneur=ael/ane
      elseif ((ael+ane).gt.0.0d0) then
        felneur=ael/ane
      else
        felneur=1.d0
      endif
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fsplint(xa,ya,y2a,n,x)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        xa  XXX-meaning
c! @param [in,out]   real*8        ya  XXX-meaning
c! @param [in,out]   real*8       y2a  XXX-meaning
c! @param [in,out]   real*8         n  XXX-meaning
c! @param [in,out]   real*8         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fsplint(xa,ya,y2a,n,x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c NR cubic spline interpolation.  As a function and subroutine
c not SS-BY-CA-40i used with permission
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      integer*4 n
      real*8 xa(n),ya(n),y2a(n)
      real*8  x,y,a,b,c,d
      real*8 dy,dx,dydx
      real*8 sixth
      parameter( sixth = 1.0d0/6.0d0 )
      integer*4 k,khi,klo
      save khi,klo
      klo=1
      khi=n
   10 if (khi-klo.gt.1) then
        k=(khi+klo)/2
        if (xa(k).gt.x) then
          khi=k
        else
          klo=k
        endif
        goto 10
      endif
      dx=xa(khi)-xa(klo)
      a=(xa(khi)-x)/dx
      b=1.d0-a
      y=a*ya(klo)+b*ya(khi)
      if (a.lt.0.0d0) then
c linear extrapolate from spline derivs
c set A=0 and get 1st deriv
        dy=ya(khi)-ya(klo)
c A=0,B=1
        dydx=(dy/dx)+sixth*dx*y2a(klo)+2.d0*sixth*dx*y2a(khi)
        y=ya(khi)+dydx*(x-xa(khi))
        fsplint=y
        return
      elseif (b.lt.0.0d0) then
c linear extrapolate from spline derivs
        dy=ya(khi)-ya(klo)
c set B=0 and get 1st deriv
c A=1,B=0
        dydx=(dy/dx)-2.d0*sixth*dx*y2a(klo)-sixth*dx*y2a(khi)
        y=ya(klo)-dydx*(xa(klo)-x)
        fsplint=y
        return
      else
        c=sixth*(a*(a*a-1.d0))*(dx*dx)
        d=sixth*(b*(b*b-1.d0))*(dx*dx)
        y=y+c*y2a(klo)+d*y2a(khi)
      endif
      fsplint=y
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine splint
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        xa  XXX-meaning
c! @param [in,out]   real*8        ya  XXX-meaning
c! @param [in,out]   real*8       y2a  XXX-meaning
c! @param [in,out]   real*8         n  XXX-meaning
c! @param [in,out]   real*8         x  XXX-meaning
c! @param [in,out]   real*8         y  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine splint (xa, ya, y2a, n, x, y)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c NR cubic spline interpolation.  As a function and subroutine
c not SS-BY-CA-40i used with permission
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      integer*4 n
      real*8  x,y,xa(n),y2a(n),ya(n)
      real*8  a,b,c,d
      real*8 dy,dx,dydx
      real*8 sixth
      parameter( sixth = 1.0d0/6.0d0 )
      integer*4 k,khi,klo
      save khi,klo
      klo=1
      khi=n
   10 if (khi-klo.gt.1) then
        k=(khi+klo)/2
        if (xa(k).gt.x) then
          khi=k
        else
          klo=k
        endif
        goto 10
      endif
      dx=xa(khi)-xa(klo)
      a=(xa(khi)-x)/dx
      b=1.d0-a
      y=a*ya(klo)+b*ya(khi)
      if (a.lt.0.0d0) then
        dy=ya(khi)-ya(klo)
        dydx=(dy/dx)+sixth*dx*y2a(klo)+2.0*sixth*dx*y2a(khi)
        y=ya(khi)+dydx*(x-xa(khi))
        return
      elseif (b.lt.0.0d0) then
        dy=ya(khi)-ya(klo)
        dydx=(dy/dx)-2.0*sixth*dx*y2a(klo)-sixth*dx*y2a(khi)
        y=ya(klo)-dydx*(xa(klo)-x)
        return
c     else if ((a.ge.0.d0).and.(b.ge.0.d0)) then
      else
        c=sixth*(a*(a*a-1.d0))*(dx*dx)
        d=sixth*(b*(b*b-1.d0))*(dx*dx)
        y=y+c*y2a(klo)+d*y2a(khi)
      endif
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine endgrads
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         y  XXX-meaning
c! @param [in,out]   real*8         n  XXX-meaning
c! @param [in,out]   real*8       yp1  XXX-meaning
c! @param [in,out] implicit       ypn  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine endgrads (x, y, n, yp1, ypn)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c NR cubic spline interpolation.  As a function and subroutine
c not SS-BY-CA-40i used with permission
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      integer*4 n
      real*8 x(n), y(n)
      real*8 yp1,ypn
      yp1=0.0d0
      ypn=0.0d0
      if (n.gt.1) then
        yp1=(y(2)-y(1))/(x(2)-x(1))
        ypn=(y(n)-y(n-1))/(x(n)-x(n-1))
      endif
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine spline
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         y  XXX-meaning
c! @param [in,out]   real*8         n  XXX-meaning
c! @param [in,out]   real*8       yp1  XXX-meaning
c! @param [in,out] implicit       ypn  XXX-meaning
c! @param [in,out] implicit        y2  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine spline (x, y, n, yp1, ypn, y2)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c NR cubic spline interpolation.  As a function and subroutine
c not SS-BY-CA-40i used with permission
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      integer*4 n,nmax
      real*8  yp1,ypn,x(n),y(n),y2(n)
      parameter (nmax=1024)
      integer*4 i,k
      real*8  p,qn,sig,un,u(nmax)
      if (n.gt.nmax) then
        write (*,*) 'Too many points in spline:',n
        stop
      endif
      if (yp1.gt.0.99e30) then
        y2(1)=0.d0
        u(1)=0.d0
      else
        y2(1)=-0.5d0
        u(1)=(3.d0/(x(2)-x(1)))*((y(2)-y(1))/(x(2)-x(1))-yp1)
      endif
      do i=2,n-1
        sig=(x(i)-x(i-1))/(x(i+1)-x(i-1))
        p=sig*y2(i-1)+2.d0
        y2(i)=(sig-1.d0)/p
        u(i)=(6.d0*((y(i+1)-y(i))/(x(i+1)-x(i))-(y(i)-y(i-1))/(x(i)-x(i-
     &   1)))/(x(i+1)-x(i-1))-sig*u(i-1))/p
      enddo
      if (ypn.gt.0.99d30) then
        qn=0.d0
        un=0.d0
      else
        qn=0.5d0
        un=(3.0d0/(x(n)-x(n-1)))*(ypn-(y(n)-y(n-1))/(x(n)-x(n-1)))
      endif
      y2(n)=(un-qn*u(n-1))/(qn*y2(n-1)+1.d0)
      do k=n-1,1,-1
        y2(k)=y2(k)*y2(k+1)+u(k)
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine spline00
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         y  XXX-meaning
c! @param [in,out]   real*8         n  XXX-meaning
c! @param [in,out]   real*8        y2  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine spline00 (x, y, n, y2)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c NR cubic spline interpolation.  As a function and subroutine
c not SS-BY-CA-40i used with permission
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      integer*4 n,nmax
      real*8 x(n),y(n),y2(n)
      parameter (nmax=1024)
      integer*4 i,k
      real*8  p,sig,u(nmax)
      real*8  xm,x0,xp,ym,y0,yp,dx
      save xm,x0,xp,ym,y0,yp,dx
      y2(1)=0.d0
      u(1)=0.d0
      do i=2,n-1
        xm=x(i-1)
        x0=x(i)
        xp=x(i+1)
        dx=xp-xm
        ym=y(i-1)
        y0=y(i)
        yp=y(i+1)
        sig=(x0-xm)/(dx)
        p=sig*y2(i-1)+2.d0
        y2(i)=(sig-1.d0)/p
        u(i)=(6.d0*((yp-y0)/(xp-x0)-(y0-ym)/(x0-xm))/(dx)-sig*u(i-1))/p
      enddo
      y2(n)=0.d0
      u(n)=0.d0
      do k=n-1,1,-1
        y2(k)=y2(k)*y2(k+1)+u(k)
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine splin2
c! XXXX - add one line purpose here
c! @param [in,out]   real*8       x1a  XXX-meaning
c! @param [in,out]   real*8       x2a  XXX-meaning
c! @param [in,out]   real*8        ya  XXX-meaning
c! @param [in,out]   real*8       y2a  XXX-meaning
c! @param [in,out]   real*8         m  XXX-meaning
c! @param [in,out]   real*8         n  XXX-meaning
c! @param [in,out]   real*8        x1  XXX-meaning
c! @param [in,out]   real*8        x2  XXX-meaning
c! @param [in,out] implicit         y  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine splin2 (x1a, x2a, ya, y2a, m, n, x1, x2, y)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c NR cubic spline interpolation.  As a function and subroutine
c not SS-BY-CA-40i used with permission
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      integer*4 m,n,nn
      real*8  x1,x2,y,x1a(m),x2a(n)
      real*8  y2a(m,n),ya(m,n)
      real*8  yp1, ypn
      parameter (nn=121)
cU    USES spline,splint
      integer*4 j,k
      real*8  y2tmp(nn),ytmp(nn),yytmp(nn)
      do j=1,m
        do k=1,n
          ytmp(k)=ya(j,k)
          y2tmp(k)=y2a(j,k)
        enddo
        call splint (x2a, ytmp, y2tmp, n, x2, yytmp(j))
      enddo
      call endgrads (x1a, yytmp, m, yp1, ypn)
      call spline (x1a, yytmp, m, yp1, ypn, y2tmp)
      call splint (x1a, yytmp, y2tmp, m, x1, y)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fgaunt(ion, ndel, xsi)
c! XXXX - add one line purpose here
c! @param [in,out] integer*4       ion  XXX-meaning
c! @param [in,out] integer*4      ndel  XXX-meaning
c! @param [in,out] integer*4       xsi  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fgaunt(ion, ndel, xsi)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO COMPUTE THE GAUNT FACTOR IN COLLISIONAL
c   EXCITATION FOR ARBITRARY XSI (EN.GAP/KT) AND IONIC SPECIE
c   NDEL IS THE  CHANGE IN THE PRINCIPAL QUANTUM NUMBER
c
c     **REFERENCES : BELY,O. 1966 PROC. PHYS. SOC. 88,587
c            TARTER,C.B. 1969 AP J SUPPL. 18,1
c                VAN REGEMORTER,H 1962 AP J 136,P 906
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 u,y
      real*8 xsi
      integer*4 ion, ndel
c
c           Functions
c
      real*8 a,aa,b,bb,c,cc,fue1
c
      a(y)=(((5.232d0*y)-6.652d0)*y)+2.878d0
      b(y)=(((2.79d0*y)+1.764d0)*y)+0.898d0
      c(y)=(((0.7917d0*y)+0.2308d0)*y)+0.10741d0
      aa(y)=(((((-(1.9347d0*y))+3.0267d0)*y)-1.5369d0)*y)+0.3122d0
      bb(y)=(((10.574d0*y)+68.378d0)*y)+3.496d0
      cc(y)=(((-(0.2359d0*y))-0.07154d0)*y)+0.2667d0
c
      fgaunt=0.2d0
c
c    ***IONIC SPECIES
c
      if (ion.le.1) goto 20
      y=1.0d0/dble(ion)
c
c     **NO CHANGE IN PRINCIPAL QUANTUM NUMBER
c
      if (ndel.gt.0) goto 10
      u=xsi/c(y)
      fgaunt=(0.413497d0*a(y))*(1.d0+((b(y)*fue1(u,0.d0))/2.3026d0))
      goto 30
   10 continue
c
c     **WITH CHANGE IN PRINCIPAL QUANTUM NUMBER
c
      u=xsi/cc(y)
      fgaunt=(0.413497d0*aa(y))*(1.d0+((bb(y)*fue1(u,0.d0))/2.3026d0))
      goto 30
   20 continue
c
c    ***NEUTRAL SPECIES (ION=1)
c
      if (xsi.lt.0.5d0) then
        fgaunt=0.276d0*fue1(xsi,xsi)
      else
        fgaunt=(0.066d0/dsqrt(xsi))+(0.033d0/xsi)
      endif
c
      if (ndel.le.0) fgaunt=2.5d0*fgaunt
c
   30 continue
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fheavyside(x)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fheavyside(x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Simple heavyside function
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 x,  fh
c
      fh=1.d0
      if (x.lt.0.d0) fh=0.d0
      fheavyside=fh
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fgamln(az)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        az  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fgamln(az)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Complete and Incomplete Gamma functions
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     Complete ln(Gamma) version 1
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 z , a(7) , s, pi
      real*8 a_1, a_2, a_3, a_4, a_5, a_6, a_7
      real*8 az
      integer i
      parameter(pi=4.d0*datan(1.d0))
      parameter(a_1=1.d0/12.d0)
      parameter(a_2=1.d0/30.d0)
      parameter(a_3=53.d0/210.d0)
      parameter(a_4=195.d0/371.d0)
      parameter(a_5=22999.d0/22737.d0)
      parameter(a_6=29944523.d0/19733142.d0)
      parameter(a_7=109535241009.d0/48264275462.d0)
      z=0.0d0
      z=az
      s=z
      s=z+a_7/s
      s=z+a_6/s
      s=z+a_5/s
      s=z+a_4/s
      s=z+a_3/s
      s=z+a_2/s
      s=a_1/s
      s=s-z+(z-0.5d0)*dlog(z)+0.5d0*dlog(2.d0*pi)
      fgamln=s
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fgserr(a, x, gln)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         a  XXX-meaning
c! @param [in,out]   real*8         x  XXX-meaning
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx       gln  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fgserr(a, x, gln)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c SERIES REPRESENTATION OF INCOMPLETE GAMMA FUNCTION - version 1
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 a , x , gln , ap , sum , del , eps
      real*8 fgamln
      integer itmax , n
      parameter (itmax=10000,eps=3.d-12)
      gln=fgamln(a)
      if (x.le.0.0d0) then
        fgserr=0.d0
        return
      endif
      ap=a
      sum=1.d0/a
      del=sum
      do n=1,itmax
        ap=ap+1.d0
        del=del*x/ap
        sum=sum+del
        if (abs(del).lt.abs(sum)*eps) goto 20
      enddo
      write (*,*) 'Warning: Inc. Gamma Fn. fgserr did not converge for A
     & = ',a
   20 fgserr=sum*dexp(-x+a*log(x)-gln)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fgcff (a, x, gln)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         a  XXX-meaning
c! @param [in,out]   real*8         x  XXX-meaning
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx       gln  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fgcff (a, x, gln)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c CONTINUED FRACTION METHOD FOR INCOMPLETE GAMMA FUNCTION
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 a0 , b0 , a1 , b1 , gln
      real*8 eps , a , x , anf , g
      real*8 gold , fac , ana , an
      integer itmax , n
      real*8 fgamln
      parameter (itmax=10000,eps=3.d-12)
      gln=fgamln(a)
      gold=0.0d0
      a0=1.d0
      a1=x
      b0=0.d0
      b1=1.d0
      fac=1.d0
      g=0.0d0
      do n=1,itmax
        an=dble(n)
        ana=an-a
        a0=(a1+a0*ana)*fac
        b0=(b1+b0*ana)*fac
        anf=an*fac
        a1=x*a0+anf*a1
        b1=x*b0+anf*b1
        if (a1.ne.0.0d0) then
          fac=1.d0/a1
          g=b1*fac
          if (dabs((g-gold)/g).lt.eps) goto 10
          gold=g
        endif
      enddo
      write (*,*) 'Warning: Inc. Gamma Fn. GCFF did not converge for A =
     & ',a
   10 fgcff=dexp(-x+a*dlog(x)-gln)*g
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fgammln(xx)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        xx  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fgammln(xx)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     Complete ln(Gamma) version 2, need to check if 1 and 2 agree
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 xx
      integer j
      real*8 ser,stp,tmp,x,y,cof(6)
      save cof,stp
      data cof,stp/76.18009172947146d0, -86.50532032941677d0,
     & 24.01409824083091d0, -1.231739572450155d0,
     & 0.1208650973866179d-2, -.5395239384953d-5,
     & 2.5066282746310005d0/
c
      x=xx
      y=x
      tmp=x+5.5d0
      tmp=(x+0.5d0)*log(tmp)-tmp
      ser=1.000000000190015d0
      do j=1,6
        y=y+1.d0
        ser=ser+cof(j)/y
      enddo
      fgammln=tmp+dlog(stp*ser/x)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fgamma(x)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fgamma(x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     Complete Gamma Function
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 x
      real*8 calc
      real*8 fgammln
      calc=0.0d0
      if (x.ge.1.d0) then
        calc=fgammln(x)
      else
        calc=fgammln(x+1.d0)-dlog(x)
      endif
      fgamma=dexp(calc)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fincgamma(a,x)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         a  XXX-meaning
c! @param [in,out]   real*8         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fincgamma(a,x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     Incomplete Gamma Function
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 a , x , gln , gammcf , gamser
      real*8 fgserr,fgcff
      if (x.lt.0.d0.or.a.le.0.d0) then
        write (*,*) 'fincgamma called with x < 0 or A <= 0'
      endif
c USE THE SERIES REPRESENTATION
      if (x.lt.(a+1.d0)) then
        gamser=fgserr(a,x,gln)
        fincgamma=gamser
      else
c USE THE CONTINUED FRACTION METHOD
        gammcf=fgcff(a,x,gln)
        fincgamma=1.d0-gammcf
      endif
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fkenhance(k, x)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         k  XXX-meaning
c! @param [in,out]   real*8         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fkenhance(k, x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******COMPUTES RATE ENHANCEMENT FOR GIVEN KAPPA AND KAPPA TEMPERATURE
c  RATIO
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 k, x
      real*8 fgamma
c
      real*8 g1, g2, r1, r2
      real*8 gam1
      real*8 ratm
      real*8 ratk
      real*8 rat
c
      if (.not.(usekappa)) then
        fkenhance=1.d0
        return
      endif
c
      gam1=1.d0
      rat=1.d0
c
      if (k.le.100.d0) then
        if (k.ge.1.5d0) then
          g1=fgamma(k+1.0d0)
          g2=fgamma(k-0.5d0)
          r1=(1.0d0-3.d0/(2.d0*k))
          r2=((k-1.5d0)**(1.5d0))
          gam1=(r1*g1)/(r2*g2)
          ratm=dexp(-x)
          ratk=(1.d0+x/(k-1.5d0))**(-k)
          rat=ratk/ratm
c      write(*,*) k,x, min( gam1*rat, 1000.d0)
        endif
      endif
      fkenhance=min(gam1*rat,1000.d0)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fioncha(popul, iord)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8     popul  XXX-meaning
c! @param [in,out]   real*8      iord  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fioncha(popul, iord)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO COMPUTE AVERAGE CHARGE OF IONS
c   LINEAR:IORD=1   ;   RMS:IORD=2
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 weito
      real*8 popul(mxion, mxelem)
      integer*4 i,iek,j,iord
c
      iek=max(1,iord)
      weito=0.0d0
c
      fioncha=0.0d0
      do i=1,atypes
        do j=2,maxion(i)
          weito=weito+(zion(i)*popul(j,i))
          fioncha=fioncha+((zion(i)*popul(j,i))*dble((j-1)**iek))
        enddo
      enddo
      if (weito.gt.0.0d0) then
        fioncha=(fioncha/weito)**(1.d0/dble(iek))
      else
        fioncha=1.0d0
      endif
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fkramer(ion,atom,t)
c! XXXX - add one line purpose here
c! @param [in,out] integer*4       ion  XXX-meaning
c! @param [in,out] integer*4      atom  XXX-meaning
c! @param [in,out] integer*4         t  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fkramer(ion,atom,t)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     This function calculates the radiative recombination rates
c     for hydrogenic ions.
c
c     Total Radiative Hydrogenic Recombination. 10 < Te/Z^2 <10^9 K Z^2
c
c     x = Log(Te), y = log(rate) cm^3 s^-1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t,tz2,z,z2
      real*8 ltz2
      real*8 a
      real*8 rate
      real*8 raten1
      real*8 rate2
c
      real*8 fsplint
c
      integer*4 atom,ion
c
      fkramer=0.d0
      rate=0.d0
      rate2=0.d0
c
c     Check that the ion is really hydrogenic
c
      if ((mapz(atom)-ion+1).ne.0) then
        write (*,*) 'Warning, incorrect ion in fkramer'
        write (*,*) elem(atom),rom(ion)
        stop
      endif
c
c     OK, we are recombining to a H ion
c
c
c     get lambda (alias h)
c
      z=dble(mapz(atom))
      z2=z*z
      tz2=t/z2
      ltz2=dlog10(tz2)
      a=fsplint(hreclgt,hreclga,hreclga2,nhrec,ltz2)
      rate=z*dmax1((10.d0**a),0.d0)
c
c     Check to see if we have H or He and calculate on the spot
c     recombination rates.
c
      if (mapz(atom).le.2) then
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     subtract Spline fit to N=1 level to get otspot rates
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        a=fsplint(hreclgt,hreclga1,hreclga12,nhrec,ltz2)
        raten1=z*dmax1((10.d0**a),0.d0)
c
        rate2=rate-raten1
        if (rate2.lt.0.d0) rate2=0.d0
c
        if (mapz(atom).eq.1) rec(3,1)=rate2
        if (mapz(atom).eq.2) rec(5,2)=rate2
c
      endif
c
c     pass back the result
c
      fkramer=rate
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fheirec(ion,atom,t)
c! XXXX - add one line purpose here
c! @param [in,out] integer*4       ion  XXX-meaning
c! @param [in,out] integer*4      atom  XXX-meaning
c! @param [in,out] integer*4         t  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fheirec(ion,atom,t)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c     This function calculates the radiative recombination rates
c     for helio ions.
c
c       Total Radiative Hydrogenic Recombination. 10 < Te/Z^2 <10^9 K Z^2
c
c       x = Log(Te), y = log(rate) cm^3 s^-1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 atom,ion
      real*8 t
      real*8 lt
      real*8 a
      real*8 rate
      real*8 raten1
      real*8 rate2
c
      real*8 fsplint
c
      fheirec=0.d0
      rate=0.d0
      rate2=0.d0
c
c     Check that the ion is really helium1
c
      if (((mapz(atom)-ion+1).ne.1).or.(mapz(atom).ne.2)) then
        write (*,*) 'Warning, incorrect ion in fhe1rec'
        write (*,*) elem(atom),rom(ion)
        stop
      endif
c
c     OK, we are recombining to a He I atom
c
      lt=dlog10(t)
      a=fsplint(hereclgt,hereclga,hereclga2,nherec,lt)
      rate=dmax1((10.d0**a),0.d0)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     subtract Spline fit to N=1 level to get otspot rates
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      a=fsplint(hereclgt,hereclga1,hereclga12,nherec,lt)
      raten1=dmax1((10.d0**a),0.d0)
c
      rate2=rate-raten1
      if (rate2.lt.0.d0) rate2=0.d0
c
      rec(4,2)=dmax1(rate2,0.d0)
c
c     pass back the result
c
      fheirec=rate
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fnoradrec(ion,atom,t)
c! XXXX - add one line purpose here
c! @param [in,out] integer*4       ion  XXX-meaning
c! @param [in,out] integer*4      atom  XXX-meaning
c! @param [in,out] integer*4         t  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fnoradrec(ion,atom,t)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c     This function calculates the radiative recombination rates
c     for NORAD total recombination ions. C,N,O initially
c
c       x = Log(Te), y = log(rate) cm^3 s^-1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 atom,ion
      real*8 t
c
      integer id,nd,i
      real*8 lt
      real*8 lx(17)
      real*8 ly(17)
      real*8 ly2(17)
      real*8 rate,a
c
      real*8 fsplint
c
      rate=0.d0
c
c     Check that the ion is really NORAD ion
c
      id=noradid(ion,atom)
      if (id.eq.0) then
        write (*,*) 'Warning, incorrect ion in fnoradrec'
        write (*,*) elem(atom),rom(ion)
        stop
      endif
c
      nd=nodesndrec(id)
c
c     OK, we are recombining to a NORAD atom
c
      lt=dlog10(t)
      do i=1,nd
        lx(i)=tendrec(i,id)
        ly(i)=andrec(i,id)
        ly2(i)=a2ndrec(i,id)
      enddo
      a=fsplint(lx,ly,ly2,nd,lt)
      rate=dmax1((10.d0**a),0.d0)
c
c      write(*,*) 'NORAD', mapz(atom), ion, nd, lt, rate
c
      fnoradrec=rate
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fmua(de, dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fmua(de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******COMPUTES  MU  INCLUDING ALL ELEMENTS .
c   USES ATOMIC MASSES  :  ATWEI   AND RELAT. ABUND.  :  ZION
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 de,dh
      real*8 denstot,densnum
c
c      write(*,*) 'fmua de: dh:  denstot:  densnum:', de, dh, denstot(dh), densn
c
      fmua=(denstot(dh)+(de*me/amu))/(de+densnum(dh))
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fpsiy(x)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fpsiy(x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     function to evaluate the normalised two photon spectral probability
c     function of Spitzer and Greenstein 1951 ApJ 114, 407-409
c
c     psi(x)/int(0-1) psi(x) dx
c
c     where int(0-1) psi dx = 3.7695 (ADU2002)
c
c     This is required for the two photon gaunt
c     factor calculation
c
c     Note:
c
c     A(x) = 9 a^6 c Rhy/2^10 psi(x)   (for hydrogen)
c          = 4.363932296875 psi(x) in modern constants
c
c        x = nu/nu_2p
c
c        0 <= x <= 1.0
c
c        function is only symmetrical in photons/unit interval.
c
c     I fit a constrained polynomial of 6th order to range 0 - 0.5 and
c     use symmetry for the rest.  This is significantly more accurate
c     than the Mewe method.
c
c     errors: max error ~ 0.09 percent
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      real*8 x,p0,x2
      real*8 a1,a2,a3,a4,a5,a6
c
c     assign polynomial constants
c
      a1=44.29819429d0
      a2=-235.44054804d0
      a3=893.35016831d0
      a4=-2163.35461352d0
      a5=2870.53449429d0
      a6=-1572.88858194d0
c
      fpsiy=0.0d0
      p0=0.d0
c
c     this is only valid for 0<= x <=1.0
c
      if ((x.ge.0.0d0).and.(x.le.1.0d0)) then
        if (x.gt.0.5d0) then
          x2=1.0d0-x
          p0=(x2*(a1+x2*(a2+x2*(a3+x2*(a4+x2*(a5+x2*a6))))))
        else
          p0=(x*(a1+x*(a2+x*(a3+x*(a4+x*(a5+x*a6))))))
        endif
      else
        write (*,*) 'Error in fpsiy, x argument out of range 0-1'
        write (*,*) 'x = ',x
        stop
      endif
c
      fpsiy=p0*0.2652871733651678d0
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fphotim()
c! XXXX - add one line purpose here
c! @param This function has no parameters, which is surprising
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fphotim()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c       Calculates Weighted Photo-Ionisation Timescales
c
c       Weighted by population fractions and abundances
c       Assumes that the rates are all up to date. call
c       Allrates otherwise.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 rpho,totn,wei
      integer*4 i,j
c
      rpho=0.d0
      totn=0.d0
      fphotim=0.d0
c
      do i=1,atypes
        totn=totn+zion(i)
      enddo
c
      do i=1,atypes
c
        do j=1,maxion(i)-1
          wei=pop(j,i)*zion(i)
          rpho=rpho+wei*rphot(j,i)
        enddo
c
      enddo
c
      fphotim=totn/(rpho+epsilon)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fradpress(dr,dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        dr  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fradpress(dr,dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******COMPUTES RADIATION PRESSURE Phi Sigma/c
c
c   Assumes tphot is up to date.  Tphot is in 1/4pi sr flux units
c   Also assumes xsec is up to date from totphot, includes dust
c   radiation pressure.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 wid, blum, dr, tau
      real*8 dustf, grainf
      real*8 dustradp, ionradp,dh, dgrad
      integer*4 i,k,dtype
c
      fradpress=0.d0
c
      if (radpressmode.eq.1) return
c Jnu in tphot
      blum=0.d0
      do i=ionstartbin,infph-1
        if (xsec(i).gt.0.d0) then
          wid=widbinnu(i)
          tau=dabs(dr*xsec(i))
          if (tau.gt.1.d-8) then
            blum=blum+tphot(i)*wid*(1.d0-dexp(-tau))
          else
            blum=blum+tphot(i)*wid*tau
          endif
        endif
      enddo
      ionradp=fpi*blum/cls
c
      dustf=0.d0
      dustradp=0.d0
c
      if (grainmode.eq.1) then
        do dtype=1,numtypes
          do k=mindust(dtype),maxdust(dtype)
            do i=1,infph-1
              if (absorp(i,k,dtype).gt.0.0d0) then
                wid=widbinnu(i)
                dgrad=gradedge(k+1)-gradedge(k)
                grainf=(absorp(i,k,dtype)+(1-gcos(i,k,dtype))*scatter(i,
     &           k,dtype))*dustsig(k,dtype)*dgrad
                tau=dabs(dr*grainf*dh)
                if (tau.gt.1.d-8) then
                  dustf=dustf+tphot(i)*wid*(1.d0-dexp(-tau))
                else
                  dustf=dustf+tphot(i)*wid*tau
                endif
              endif
            enddo
          enddo
        enddo
        dustradp=fpi*dustf/cls
      endif
c      write(*,'(" Ion, Dust  Rad Pressure: ",2(1pg12.5))')
c     &  blum, dustf
c      write(*,'(" Dust, Ion  Rad Pressure: ",2(1pg12.5))')
c     &  dustradP, ionradP
c
      fradpress=(ionradp+dustradp)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fpressu(t, dh, popul)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c! @param [in,out]   real*8     popul  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fpressu(t, dh, popul)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******COMPUTES PRESSURE USING FUNCTION FELDENS
c     Calculate gas pressure from T, the H density "dh", and the ion
c     populations "popul" (used to find electron density "de").
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, dh
      real*8 popul(mxion, mxelem),de
      real*8 en
c
c           Functions
c
      real*8 feldens
c
      de=feldens(dh,popul)
c
      en=zen*dh+de
c
      fpressu=en*rkb*t
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fpresse(t, de, dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fpresse(t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     Calculate gas pressure from temperature T, electron density "de",
c     and H density "dh".
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, dh
      real*8 de
      real*8 en
c
c      Functions
c
      en=zen*dh+de
c
      fpresse=en*rkb*t
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function frectim(t, de, dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function frectim(t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******TO DERIVE AVERAGE RECOMBINATION TIME SCALE
c   ASSUMING CONSTANT ELECTRONIC DENSITY : DE
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 t, de, dh
      real*8 recab(mxion)
      real*8 a,ad,adlt,ar,b,bd,c,d
      real*8 et,f,rain,ta,tb,u,u4,wei,weito
c
      integer*4 i,ion,j,jj,mif,mij
c
c           Functions
c
      real*8 adf,adltf,arf
c
      arf(u,ar,et)=ar*((u/1.0d4)**(-et))
      adf(u,ad,bd,ta,tb)=(((1.0+(bd*dexp(-(tb/u))))*dexp(-(ta/u)))*ad)*
     &(u**(-1.5d0))
      adltf(u4,a,b,c,d,f)=((1.0d-12*((((a/u4)+b)+(c*u4))+((d*u4)*u4)))*
     &(u4**(-1.5)))*dexp(-(f/u4))
c
      u=dmax1(0.01d0,t)
      u4=u/1.d4
      ion=atypes
      rain=0.0d0
      weito=0.0d0
c
      do i=1,atypes
        mif=0
        mij=2
        do j=mij,maxion(i)
          recab(j)=0.0d0
          ar=arad(j,i)
          if (ar.gt.0.0d0) then
            ad=adi(j,i)
            et=xrad(j,i)
            ta=t0(j,i)
            bd=bdi(j,i)
            tb=t1(j,i)
            a=adilt(j,i)
            b=bdilt(j,i)
            c=cdilt(j,i)
            d=ddilt(j,i)
            f=fdilt(j,i)
            adlt=adltf(u4,a,b,c,d,f)
            if (adlt.lt.0.0) adlt=0.0d0
            recab(j)=(arf(u,ar,et)+adf(u,ad,bd,ta,tb))+adlt
            mif=j
          else
            mij=j+1
          endif
        enddo
c
        if (mif.ge.mij) then
          wei=1.0d0
          weito=weito+(zion(i)*wei)
          do j=mij,mif
            do jj=mij,j
              rain=rain+(wei/(recab(jj)+1.d-36))
            enddo
          enddo
        endif
      enddo
c
      frectim=rain/(((de*dh)*weito)+(1.d-36*rain))
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function frectim2(de)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        de  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function frectim2(de)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c       Calculates Weighted Recombination timescale
c
c       Weighted by population fractions and abundances
c       Assumes that the rates are all up to date. call
c       Allrates otherwise.
c
c   ASSUMES CONSTANT ELECTRONIC DENSITY : DE
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 de,rrec,totn,wei
      integer*4 i,j
c
      rrec=0.d0
      totn=0.d0
      frectim2=0.d0
c
      do i=1,atypes
        totn=totn+zion(i)
      enddo
c
      do i=1,atypes
c
        do j=2,maxion(i)
          wei=pop(j,i)*zion(i)
          rrec=rrec+(wei*rec(j,i))
        enddo
c
      enddo
c
      frectim2=totn/(de*rrec+epsilon)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function frectim3(dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function frectim3(dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c       Calculates Weighted Potential Recombination timescale
c       number of recombinations available, works in neutral gas
c       to compute how many recombinations could take place if it were
c       ionised by one more stage in each ion
c
c       Weighted by population fractions and abundances
c       Assumes that the rates are all up to date. call
c       Allrates otherwise.
c
c   ASSUMES CONSTANT ELECTRONIC DENSITY : DE
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 dh,rrec,totn,wei
      integer*4 i,j
c
      rrec=0.d0
      totn=0.d0
      frectim3=0.d0
c
      do i=1,atypes
        totn=totn+zion(i)
      enddo
c
      do i=1,atypes
c
        do j=2,maxion(i)
          wei=pop(j-1,i)*zion(i)
          rrec=rrec+(wei*rec(j,i))
        enddo
c
      enddo
c
      frectim3=totn/(dh*rrec+epsilon)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     real*8 function fresga(atom,isoe,trans,ejk,telec, code)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c********************************************************
c
c   This routine is to calculate the gaunt factors
c   for the new XLINLIST resonance line data.
c
c   The five parameter fit from Landini&Monsignori Fosse 1990
c   is used with extentions for He & Li like ions from Mewe 1981.
c
c   A new (rational) lookup table code has been implemented
c   to replace the unusual one used by L&M...
c
c     NOTE: Helio will still call the old fgaunt
c     sign errors for C and y^2D corrected
c
c
c     RSS 9/1990.
c********************************************************
c     include 'cblocks.inc'
cc
c     real*8 f1,f2,f3
c     integer*4 isoe,atom,fclookup,code,trid
c     real*8 ejk,telec,y,e1y
c     real*8 a,b,c,d,e,trans,z
cc
cc           Functions
cc
c     real*8 farint
cc
cc   internal functions (ref Mewe 1981 A.A.Suppl.Ser. 45:11  pg 20)
cc   f4 not used since the y>>1 approx not used
cc
c     f1(z)=1.d0-1.3d0/z
c     f2(z)=1.d0+1.5d0/z
c     f3(z)=1.d0+7.0d0/z
cc
c     fresga=0.2d0
cc
cc   find y and the first exponential integral (see farint.f)
cc
c     y=ejk*ev/(rkb*telec)
c     e1y=farint(1,y)
cc
cc
cc   get code for transition
cc
c     code=fclookup(isoe,trans)
cc
cc
c     if (code.gt.-1) then
cc
cc
c       if (code.lt.1) code=1
c       if (code.gt.37) code=1
cc
cc   get parameters from data arrays
cc
c       a=arg(code)
c       b=brg(code)
c       c=crg(code)
c       d=drg(code)
c       e=erg(code)
cc
c       if (isoe.ne.2) then
c         fresga=a+(e+y*(b+y*(y*d-c)))*e1y+y*(c+d)-y*y*d
cc          fresga=a+(e+y*(b+y*(y*d-c)))*e1y+y*((c+d)+y*d)
c       else
c         trid=idint(trans)
c         z=mapz(atom)
c         if (trans.le.4) then
c           a=a*f1(z)
c           d=d*f1(z)
c         endif
c         if (trans.eq.5) then
c           c=c*f2(z)
c           d=d*f3(z)
c         endif
c         if (trans.eq.6) then
c           c=c*f2(z)
c           d=d*f2(z)
c         endif
c         fresga=a+(e+y*(b+y*(y*d-c)))*e1y+y*(c+d)-y*y*d
cc          fresga=a+(e+y*(b+y*(y*d-c)))*e1y+y*((c+d)+y*d)
c       endif
cc
c     else
cc
cc     transition from meta-stable level fef = omega/statwei already
cc
c       fresga=1.d0
cc
c     endif
cc
cc      if ((mapz(atom).eq.8).and.(isoe.eq.7)) then
cc         write (*,*) atom,isoe,trans,ejk,telec
cc         write (*,*) code,A,B,C,D,E,e1y,fresga
cc      endif
cc
c     return
cc
c     end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function frho(de, dh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function frho(de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******FUNCTION TO COMPUTE DENSITY IN G/CC USING NUMBER DENSITY
c   USES FUNCTION DENSTOT (amus)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 de, dh
      real*8 denstot
c
      frho=(amu*denstot(dh))+(me*de)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine invrho
c! XXXX - add one line purpose here
c! @param [in,out]   real*8       rho  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c! @param [in,out]   real*8     popul  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine invrho (rho, de, dh, popul)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******FUNCTION TO COMPUTE  NUMBER DENSITY (de,dh) USING
c       density in g/cc and population in popul
c     USES FUNCTION DENSTOT (amus)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      real*8 rho, de, dh
      real*8 dt,f
      real*8 popul(mxion,mxelem)
      real*8 denstot,feldens
c
      dt=denstot(1.0d0)
      f=feldens(1.0d0,popul)
      dh=rho/(amu*dt+me*f)
      de=f*dh
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fzgas()
c! XXXX - add one line purpose here
c! @param This function has no parameters, which is surprising
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fzgas()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******FUNCTION TO GAS METALLICITY, Zgas, not including H and He
c       H and He are used, and He is used
c       uses global zsol and current gas phase abundances, zion
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      integer*4 i
      real*8 zg
c
      zg=0.d0
      do i=3,atypes
        zg=zg+zion(i)/zsol(i)
      enddo
c
      if (atypes.gt.2) then
        zg=zg/(atypes-2)
      elseif (atypes.eq.2) then
        zg=zion(2)/zsol(2)
      else
        zg=1.d0
      endif
c
      fzgas=zg
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function lambda(t,de,nu)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        nu  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function lambda(t,de,nu)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Function to calculate the coulomb integral at frequency nu
c
c     ref: Krolick and McKee 1978 ApJS 37,459
c
c     from: Johnston and Dawson 1973, Phys Fluids 16 722 (not sighted)
c
c    TODO: needs update
c    Try NRL plasma handbook, not urgent as not
c    used anywhere atm
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t,de,nu
      real*8 con,x,y
      real*8 nuplasma,ear
      real*8 zp,nu0,zav
      parameter (con = (3.d0/16.d0))
c
c           Functions
c
      real*8 favcha
c
      lambda=0.d0
c
c
      x=dsqrt((iphe)/(rkb*t))
      y=1.d0/x
      ear=1.d0/(de*bohr**3.d0)
      nuplasma=dsqrt((pi*de*eesu)/me)/pi
      nu0=nuplasma/nu
      zav=favcha(pop)
      zp=rt2*zav*x*x
c
      lambda=con*y*ear*(dmin1(1.d0,nu0)/dmax1(zp,x))
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fplank(ts, rnuh)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        ts  XXX-meaning
c! @param [in,out]   real*8      rnuh  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fplank(ts, rnuh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO CALCULATE BNU (ERGS.S-1.CM-2.HZ-1.SR-1)
c   FROM PLANK ENERGY DISTRIBUTION
c   TS : TEMP.    RNUH : FREQUENCY IN RYDBERGS (NU/NUHYD)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      real*8 a,b,c
      real*8 ts, rnuh
c
c   1 IPH = 13.59844eV
c
c     F = pi B(nu) = 2 pi h c^-2 nu^3 /(exp(-h nu/k t)-1)
c
c     2(IPH ev/h)^3 h c^-2 = 0.5250125547220821
c                          = 0.5241734265468874 CODATA2010
c
c     IPH ev/rkb = 1.578875215924684e5
c                = 157803.3594680892 CODATA2010
c     this routine returns B (1/pi Inu units)
c
c
      a=0.5241734265468874*(rnuh*rnuh*rnuh)
      b=(1.578033594680892d5*rnuh)/ts
      if (b.gt.1.0d2) goto 10
      c=1.0d0/(dexp(b)-1.0d0)
      goto 20
   10 c=dexp(-b)
   20 fplank=a*c
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fnair(lamvac)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8    lamvac  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fnair(lamvac)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     mean air refractive index used in ancient mappings
c
c     airref=1.00025552d0
c
c     Prev: Refractive index of std air for Lam>2000 A
c     MV AQ3 formula with typo based on Edlen 1953
c     nair(s)=1.0d0+(643.26d0+294981.d0/(146.d0-s*s)+2554.d0/
c     &(41.d0-s*s))/1.0d7
c
c     Current: NIST ASD standard Peck & Reeder 1972 broad range formula
c     extended to 2->4 microns to cover astronomical JHK bands
c
c     refractive index of std air at 15C and 330ppm CO2
c     lamvac wavelength in vac in Angstroms
c
c     n=1.0000000 vac wavelengths for lambda<2000A
c     n=1.0000000 vac wavelengths for lambda>=40000A, 4microns
c     (ASD uses 20000A 2.0microns but this lands in jhk bands)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
      real*8 lamvac,s,n
c
c
      n=1.d0
      if ((lamvac.ge.2.d3).and.(lamvac.lt.4.d4)) then
        s=1.d4/lamvac
        n=1.0d0+(8060.51d0+2480990.d0/(132.274d0-s*s)+17455.7d0/
     &   (39.32957d0-s*s))*1.0d-8
      endif
      fnair=n
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     integer*4 function fclookup(isos,tran)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     fclookup: converts the L&M transition code + iso series
c     to an ordinal value for fresgau.
c
c     NOTE: transitions such as 14c have been entered as 14.3
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     include 'cblocks.inc'
cc
c     integer*4 isos, trid,code
c     real*8 tran,trd
cc
cc    assign defaults.
cc
c     fclookup=1
c     code=0
cc
cc    Sorry, this is going to be a bit dirty...
cc
cc    metastable transitions are handled elsewhere
cc     (inter2.f)
cc
c     trid=idint(tran)
c     trd=dble(trid)
cc
cc    find if we have a whole number
cc
c     if (trd.eq.tran) then
cc
cc    we have a whole number, use the code array
cc
c       code=clkup(isos,trid)
c     else
cc
cc      handle case by case, assuming prior knowlege of allowed (sic)
cc     transition numbers in XLINDAT....
cc
cc        isos  tran  rcode gcode
cc          4   14.1    14   100
cc          4   14.2    20   200
cc          4   14.3    20   200
cc         10    1.1     9    53
cc         10    3.1    12    58
cc         10    3.2    13    61
cc         12    6.1    17   103
cc
c       if (isos.eq.4) then
c         code=20
c         if (dabs(tran-14.1d0).lt.0.01d0) code=14
c       endif
c       if (isos.eq.10) then
c         code=9
c         if (dabs(tran-3.1d0).lt.0.01d0) code=12
c         if (dabs(tran-3.2d0).lt.0.01d0) code=13
c       endif
c       if (isos.eq.12) then
c         code=17
c       endif
c     endif
cc
cc    pass back result
cc
c     fclookup=code
cc
c     return
cc
c     end
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function qua (x, y, a, b, c)
c! XXXX - add one line purpose here
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         x  XXX-meaning
c! @param [in,out] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         y  XXX-meaning
c! @param [in,out]   real*8         a  XXX-meaning
c! @param [in,out]   real*8         b  XXX-meaning
c! @param [in,out]   real*8         c  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function qua (x, y, a, b, c)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c********************************************************
c     A quadratic regression routine not really a function.
c     At present it accecpts 3 points and so does a perfect fit
c     but it can be extended to fit more points by
c     increasing n and dimensioning larger arrays, returns minumum
c     RSS 1990.2022
c********************************************************
c     WARNING: The following must be true
c
c     x(1)<>x(2)<>x(3)
c
c     However ordering is not important
c
c********************************************************
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      real*8 x(3),y(3),a,b,c
      real*8 invn
      real*8 sxx,sxy,sxx2,sx2y,sx2x2
      real*8 sigx,sigx2,sigx3,sigx4
      real*8 sigy,sigxy,sigx2y,det
      integer*4 n,i
c
c     initialize, don't assume zeros in variables
c
      n=3
      invn=1.d0/dble(n)
      sigx=0.0d0
      sigx2=0.0d0
      sigx3=0.0d0
      sigx4=0.0d0
      sigy=0.0d0
      sigxy=0.0d0
      sigx2y=0.0d0
c
      do i=1,n
        sigx=sigx+x(i)
        sigx2=sigx2+(x(i)*x(i))
        sigx3=sigx3+(x(i)*x(i)*x(i))
        sigx4=sigx4+(x(i)*x(i)*x(i)*x(i))
        sigy=sigy+y(i)
        sigxy=sigxy+(x(i)*y(i))
        sigx2y=sigx2y+(x(i)*x(i)*y(i))
      enddo
c
      sxx=sigx2-(sigx*sigx)*invn
      sxy=sigxy-(sigx*sigy)*invn
      sxx2=sigx3-(sigx*sigx2)*invn
      sx2y=sigx2y-(sigx2*sigy)*invn
      sx2x2=sigx4-(sigx2*sigx2)*invn
c
      det=(sxx*sx2x2)-(sxx2*sxx2)
c
      a=((sx2y*sxx)-(sxy*sxx2))/det
      b=((sxy*sx2x2)-(sx2y*sxx2))/det
      c=(sigy/n)-(b*(sigx*invn))-(a*(sigx2*invn))
c
c  If you have the equation in the form of y = ax^2
c  + bx + c, you can find the minimum value using the equation
c  min = min = c - b^2/4a
c
      qua=c-((b*b)/(4.d0*a))
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
