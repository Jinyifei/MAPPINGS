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
      subroutine ionab (reco, pion, pionau, ab, adndt, nde, tstep)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Luc Binette's PhD Thesis ANU 1982
c     Excerpt: Section 2.2Bb, pg17 - "Time dependent ionisation balance"
c
c     Assuming that the total densities of the atomic elements and also
c     the electronic density remain constant in time, the ionisation
c     equation for each heavy element can be written in the differential
c     form
c
c         dn/dt = Rn
c
c     where n is the total column vector containing the ionic abundances
c     of the atomic element considered, and R is the matrix containing
c     the rates per ion per second corresponding to the changes in
c     ionisation stage allowed for the atomic element under
c     consideration.  Processes involving multiple ionisation are easily
c     taken into account in this formulation.
c
c     If we assume that the rates remain constant during some time step
c     t (which implies no change of physical conditions and of
c     abundances of the species with which charge transfer reactions
c     take place), then the ionic abundances at the end of the time
c     step, n_j, are given in terms of the abundances at the start of
c     the timestep, n_i, by (Pullman, 1976)
c
c     n_j = {exp(Rt)} n_i = {I + Rt + (Rt)^2/2! + (Rt)^3/3! ...} n_i
c
c     For large t, this series is not convergent.  However, this can be
c     resolved by expressing the solution in the following manner:
c
c         n_j = T^m n_i = {exp(O)}^m n_i
c     where the matrix O = R*delta and m = t/delta, an integer >= 1.
c
c     If delta is chosen such that none of the elements in the matrix O
c     is greater than one, convergence is assured.  The expansion of the
c     new series, for exp(O), is terminated at the level set by the
c     numerical precision in the computer.  However, to raise the matrix
c     T to the mth power would be a very time consuming process,
c     involving many matrix multiplications.  It is advantageous to use
c     a unit operator U such that
c
c         U^l = T^{kl} = T^m
c     with k, l, m integers and k << l, giving
c
c         n_j = U.U.U. ... .U.n_j    (U appears l times)
c
c     where the multiplications are performed from right to left,
c     involving the much faster multiplication of a matrix and a column
c     vector.
c
c     This procedure is satisfactory and stable for time-steps as long
c     as 10^{15}/r_max in double precision, where r_max is the fastest
c     rate in the matrix R.  To all practical purposes, such a timestep
c     defines ionisation equilibrium when required, but with a much
c     higher dynamic range in the relative sizes of the various ionic
c     abundances than in the methods commonly employed.  (The latter
c     often make use of terms of the type (1 - f_k) for which the
c     evaluation is limited by numerical precision in the computer).
c
c     The ionisation balance of hydrogen was treated in a different
c     way.  (Described in the remaining text of the section, and
c     implemented in iohyd.f)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Version 2.0, expanded arrays to cope with higher ionisation
c     stages.
c
c     RSS 8/90
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******CALCULATES IONIC ABUNDANCES AFTER TIME : TSTEP
c     DEPOPULATION RATES : RECO(5) ; #OF IONIC SPECIES : NDE
c     REPOPULATION RATES : PION(5) ,PIONAU(4)
c     INITIAL ABUNDANCES IN AB(6)
c     RETURNS ABUNDANCES IN AB(6) AND DERIVATIVES IN ADNDT(6)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c     Variables
c
      real*8 astem,cyn,dyn
      real*8 repoprate
      real*8 rm,ryn,tr,tstep
c
      real*8 reco(mxion), pion(mxion), pionau(mxion)
      real*8 ab(mxion), b(mxion, mxion+1), c(mxion, mxion)
      real*8 s(mxion, mxion), as(mxion, 2)
      real*8 cm(mxion, mxion), adndt(mxion)
      real*8 ratetotal
      real*8 dtotal, da, dma, delt, tim, dun, rn, invrn, bm
c
      integer*4 i, j, m1, nde
      integer*4 nit, n, nn, nitmi, nitma, kk
      integer*4 j1, j2, k, l, m, maxio
c
      character ndyn*4
c
c    ***CALCULATES TOTAL ABUND. : DTOTAL
c
      dun=1.00000001d0
      j1=1
c
c     find total abundance
c
      dtotal=0.d0
      ratetotal=0.d0
      do k=1,nde
        dtotal=ab(k)+dtotal
        ratetotal=reco(k)+pion(k)+pionau(k)
      enddo
c
      maxio=nde
c
c     ***ZERO MATRICES C,B,S,AS
c
      do l=1,maxio
        as(l,1)=0.d0
        as(l,2)=0.d0
        do k=1,maxio
          c(k,l)=0.d0
          cm(k,l)=0.0d0
          s(k,l)=0.d0
          b(k,l)=0.d0
        enddo
      enddo
c
c     ***PUT INITIAL ABUNDANCES IN AS(K,1)
c
      do k=1,nde
        as(k,1)=ab(k)
      enddo
c
c     ***FORM MATRIX OF IONISATION RATES IN C
c
      ndyn='TEST'
   10 continue
      do k=1,nde-1
        c(k,k+1)=reco(k)
        c(k+1,k+1)=-c(k,k+1)
      enddo
      c(1,1)=0.d0
      do k=1,nde-1
        c(k+1,k)=pion(k)
        c(k,k)=c(k,k)-c(k+1,k)
      enddo
c
c     ***FIND MAX. OF ABS( C )
c
      do k=1,nde-2
        c(k+2,k)=pionau(k)
        c(k,k)=c(k,k)-c(k+2,k)
      enddo
      da=0.d0
      do k=1,nde
        da=dmax1(da,dabs(c(k,k)))
      enddo
c
c     ***FIND INTEGRATION TIME : DELT  (PER STEP)
c     THE POWER TO WHICH MATRIX  S  WILL BE RISEN : (NITMI*10)
c     AND THE NUMBER OF ITERATIONS : NIT
      dyn=1.d13
c     dyn = 1.d14
      tim=tstep
      nitma=100
      if (da.lt.(1.d-38*nitma)) da=1.d-38*nitma
      delt=1.d0/da
      if (tim.le.delt) goto 50
      if (tim.le.(nitma*delt)) goto 60
      nitma=20
c
c     **COMPRESS IONISING RATES IF DYNAMIC RANGE EXCEEDED
c
      if ((((dyn*1.d-38)*delt)*nitma).gt.1.d0) goto 40
      tr=tim/(dyn*delt)
      if (tr.le.1.0d0) goto 40
      tim=dyn*delt
      if (ndyn.eq.'OK') goto 40
      j=0
      rm=1.d38
      do 20 i=1,nde-1
        tr=dlog(pion(i)+1.d-37)-dlog(reco(i)+1.d-37)
        if (dabs(tr).ge.rm) goto 20
        j=i
        rm=tr
   20 continue
c
      if (j.lt.3) goto 40
      ryn=(reco(j)*dyn)*0.01d0
      repoprate=pion(j)*1.d4
      do i=1,j-2
        tr=pion(i)
        cyn=reco(i)*1.d7
        if (((tr.le.ryn).or.(tr.lt.repoprate)).or.(tr.lt.cyn)) goto 30
        rm=ryn/pion(i)
        pion(i)=pion(i)*rm
        reco(i)=reco(i)*rm
        if (i.gt.1) pionau(i-1)=pionau(i-1)*rm
   30   continue
      enddo
      ndyn='OK'
      goto 10
c
   40 continue
c     write (*,*) '40',tim,nitma,delt,dun
      delt=tim/(nitma*dint((tim/(nitma*delt))+dun))
      da=dlog10(tim/(nitma*delt))
      dma=da-dint(da)
c     write (*,*) da,dma
      dma=nitma*(10.0d0**dma)
      delt=delt*(dma/dint(dma+dun))
      da=dlog10(tim/(nitma*delt))
c     write(*,*) delt,dma,da
      dma=da-dint(da)
      nitmi=idint(da)
      nit=idnint(nitma*(10.0d0**dma))
c     write(*,*) '40',tim,delt,da,dma,nitmi,nit
      goto 70
   50 nitmi=0
      delt=tim
      nit=1
      goto 70
   60 nitmi=0
      delt=tim/dint((tim/delt)+dun)
      nit=idint(tim/delt)+1
c     write(*,*) '60',delt,da,dma,nitmi,nit
   70 continue
c
c     ***MULTIPLY MATRIX BY : DELT
c
      do l=1,nde
        do k=1,nde
          cm(k,l)=c(k,l)
          c(k,l)=c(k,l)*delt
        enddo
      enddo
c
c     ***SET S AND B AS IDENTITY MATRICES
c
      do k=1,nde
        b(k,k)=1.d0
        s(k,k)=1.d0
      enddo
c
c     ***EACH TERM OF THE DEXPANSION IS FORMED IN B
c     AND ADDED TO S
c
      rn=0.d0
      da=0.d0
      m1=maxio+1
   80 continue
      do m=1,10
        rn=rn+1.d0
        invrn=1.d0/rn
        do k=1,nde
          do l=1,nde
            bm=0.d0
            do n=1,nde
              bm=bm+(c(l,n)*b(n,k))
            enddo
            b(l,m1)=bm
          enddo
          do l=1,nde
            b(l,k)=b(l,m1)*invrn
            s(l,k)=s(l,k)+b(l,k)
          enddo
        enddo
      enddo
c
      do k=1,nde
        do l=1,nde
          dma=dmax1(dabs(b(l,k)),0.d0)
        enddo
      enddo
      da=dmax1(da,dma)
      if (dma.gt.0.d0) goto 80
c
c     ***RAISE MATRIX S TO POWER : (NITMI*10)
c
      if (nitmi.lt.1) goto 90
      do nn=1,nitmi
        do k=1,nde
          do l=1,nde
            c(l,k)=s(l,k)
          enddo
        enddo
        do m=2,10
          do k=1,nde
            do l=1,nde
              bm=0.d0
              do n=1,nde
                bm=bm+(c(l,n)*s(n,k))
              enddo
              b(l,m1)=bm
            enddo
            do l=1,nde
              s(l,k)=b(l,m1)
            enddo
          enddo
        enddo
      enddo
c
c     ***MULTIPLY VECTOR  AS  BY MATRIX  S   (NIT  TIMES)
c
c     write (*,*) nit
   90 l=0
      do 120 n=1,nit
        l=1-l
        j1=1+l
        j2=2-l
        do 110 k=1,nde
          astem=0.0d0
          do 100 kk=1,maxio
            astem=astem+s(k,kk)*as(kk,j2)
  100     continue
          as(k,j1)=astem
  110   continue
  120 continue
c
c     FIND NORMALISATION FACTOR : DA
c
      da=0.d0
      do 130 k=1,nde
        if (as(k,j1).gt.0.0d0) da=da+as(k,j1)
  130 continue
      da=da/dtotal
      dma=100.0d0*dabs(1.d0-da)
c
c     ***NORMALISATION AND WARNING MESSAGE IF ABUNDANCES
c     DO NOT CONSERVE
c
      if (dma.lt.1.d0) goto 160
      write (*,140) dma
c
  140 format(//' WARNING (ionab)'/
     & 'ABUNDANCES DID NOT CONSERVE BEFORE NORMALISATION :',g10.3,
     & ' %')
      write (*,*) 'Input fractions:'
      write (*,*) nde,ratetotal
      write (*,*) 'dtotal,ion1,ion2...'
      write (*,150) dtotal,(ab(k),k=1,nde)
      write (*,*) 'Input recom rates:'
      write (*,150) (reco(k),k=1,nde)
      write (*,*) 'Input pion rates:'
      write (*,150) (pion(k),k=1,nde)
      write (*,*) 'calculated fractions:'
      write (*,*) 'da,ion1,ion2...'
      write (*,*) da,(as(k,j1),k=1,nde)
  150 format (1pg12.5,1x,31(1pg12.5,1x))
c
      stop
c
  160 continue
      do k=1,nde
        ab(k)=as(k,j1)/da
        if (ab(k).lt.1.0d-38) ab(k)=0.0d0
      enddo
c
c     ***CALCULATES DN/DT FOR EACH IONIC SPECIES
c
      do k=1,nde
        adndt(k)=0.0d0
        do n=1,nde
          adndt(k)=adndt(k)+(ab(n)*cm(k,n))
        enddo
      enddo
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
