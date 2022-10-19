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
      real*8 function fhheomgspl(t,y,icol,idx)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t,y
      integer*4 idx, icol
c
      real*8 upsilon
      integer*4 l,nspl
      integer*4 omtype
      real*8 beta
      real*8 btc
      real*8 btx(mxhhenspl)
      real*8 bty(mxhhenspl)
      real*8 bty2(mxhhenspl)
c
      real*8 fsplint
c
      upsilon=0.d0
c
      omtype=hhecol_typespl(icol,idx)
c
      if ((omtype.eq.3).or.(omtype.eq.13)) then
c
c should be type 3 or 13, for all
c as x, y, and y2 are made for all types.
c
        btc=hhecol_tc(icol,idx)
        beta=(t/(t+btc))
        nspl=hhecol_nspl(icol,idx)
        do l=1,nspl
c      uniform splines for all hhe data
          btx(l)=hhecol_x(l)
          bty(l)=hhecol_y(l,icol,idx)
          bty2(l)=hhecol_y2(l,icol,idx)
        enddo
        upsilon=fsplint(btx,bty,bty2,nspl,beta)
        if (omtype.eq.13) then
          upsilon=upsilon*dlog((1.d0/y)+2.71828182845905d0)
        endif
      else
        write (*,*) 'ERROR, Invalid spline type in fhheomgspl:',omtype
        write (*,*) t,icol,idx
        stop
      endif
      fhheomgspl=dmax1(0.d0,upsilon)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine solvehheion (t, de, dh, idx, ni)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     refs: Anderson 2000/2002 upsilons H refit
c     refs: CHIANTI 8.0.1 He spline refit
c     Values derived by RSS2015
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, de, dh, abde, ee
      integer*4 idx, ni, nq
      integer*4 atom, ion
      integer*4 icol, nc
      integer*4 i,j
c
      real*8 y,omegaij,rr,cr,cgjb,pz,loss
      real*8 ratekappa,f,invgi,invrkt
      real*8 eji(mxhhelvls,mxhhelvls)
c
      real*8 fkenhance
      real*8 fhheomgspl
c
      atom=hheat(idx)
      if (atom.eq.0) return
c
      ion=hheion(idx)
      pz=zion(atom)*pop(ion,atom)
c
      if (pz.le.pzlimit) return
c
      abde=de*dh*pz
c
      do i=1,ni
        do j=1,ni
          eji(i,j)=plk*cls*dabs(hheei(j,idx)-hheei(i,idx))
        enddo
      enddo
c
      t=dmax1(t,mintemp)
      f=1.d0/dsqrt(t)
      invrkt=1.d0/(rkb*t)
c
      nc=nhheioncol(idx)
      do icol=1,nc
c lower = i upper = j
        i=hhecol_i(icol,idx)
c        ground excitation only atm
        if (i.eq.1) then
          j=hhecol_j(icol,idx)
          nq=hhen(j,idx)
          ee=eji(i,j)
          y=ee*invrkt
          if ((y.gt.0.d0).and.(y.lt.maxdekt)) then
            ratekappa=1.d0
            if (usekappa) then
              ratekappa=fkenhance(kappa,y)
            endif
            invgi=hheinvgi(i,idx)
            omegaij=fhheomgspl(t,y,icol,idx)*invgi
            cgjb=rka*f*dexp(-y)
            cr=cgjb*omegaij*ratekappa
            rr=abde*cr
            if (rr.gt.epsilon) then
              loss=rr*ee
c            1s 2S1/2->2s 2S1/2 collision
              if (j.eq.2) then
c           save rate for 2p calcs
                collrate2p(atom)=cr
c      distributed elsewhere
c            dont add 2S to Ly Alpha
                rr=0.d0
                if (linecoolmode.eq.1) then
                  loss=0.d0
                endif
              endif
              hheloss=hheloss+loss
              coolz(atom)=coolz(atom)+loss
              coolzion(ion,atom)=coolzion(ion,atom)+loss
              rateton(atom,nq)=rateton(atom,nq)+rr
            endif
          endif
        endif
      enddo
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine hhecoll (t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c     Local  params and variables
c
      real*8 t, de, dh
      real*8 pz
      real*8 f
c
      integer*4 j
      integer*4 idx, atom, ion
      integer*4 ni
c
      t=dmax1(t,mintemp)
      f=1.d0/dsqrt(t)
      hheloss=0.d0
      do idx=1,nhheions
        atom=hheat(idx)
        if (atom.ne.0) then
          do j=1,5
            rateton(atom,j)=0.0d0
          enddo
          collrate2p(atom)=0.0d0
          ion=hheion(idx)
          ni=hheni(idx)
          pz=zion(atom)*pop(ion,atom)
          if (pz.ge.pzlimit) then
            call solvehheion (t, de, dh, idx, ni)
          endif
        endif
      enddo
      if (hheloss.lt.epsilon) hheloss=0.d0
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
