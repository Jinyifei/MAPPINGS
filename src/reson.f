cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.inc'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******COMPUTES RESONANCE LINE COOLING
c       NB.  SUBR. HYDRO SHOULD BE CALLED PREVIOUSLY
c
c     RETURNS RLOSS = RESONANCE COOLING RATE(ERG CM-3 S-1)
c     RBRI(I,J) = BRIGTHNESS OF EACH LINE (ERG CM-3 S-1 STER-1)
c     AVAILABLE IN COMMOM BLOCK /RLINE/
c     CALL SUBR. RATEC, USES FUNCTION FGAUNT
c
c     subroutine reson (t, de, dh)
cc
c     include 'cblocks.inc'
cc
cc           Variables
cc
c     real*8 t, de, dh
cC     real*8 aa,abup,e,f, y
cC     real*8 po,r12,rr,u,zi
cCc
cC     real*8 ratekappa
cCc
cC     integer*4 jel,jjj,m
cc
cc           Functions
cc
cC     real*8 fgaunt
cC     real*8 fkenhance
cCc
cCc     internal functions
cCc
cC     real*8 a , x1, fr, lg, x
cc
cC      a(x)=(((5.232d0*x)-6.652d0)*x)+2.878d0
cC     x1(x)=0.7179d0*(x**(-0.0584d0))
cC     fr(x)=0.588d0*(x**(-0.234d0))
cC     lg(x)=0.07d0*(x**(-0.085d0))
cc
c     rloss=0.0d0
c      return
c
c     f=dsqrt(1.0d0/(t+epsilon))
c
c    ***GET R12 , HENCE COOLING RATE
c
c     do m=1,nlines
c
c       rr=0.0d0
c       jel=ielr(m)
c       jjj=ionr(m)
c       rbri(m)=0.d0
c       zi=zion(jel)
c       po=pop(jjj,jel)
c       if (zi*po.ge.pzlimit) then
c         e=e12r(m)
c         y=e/(rkb*t)
c         if ((y.gt.0.d0).and.(y.lt.maxdekt)) then
c         abup=de*dh*zi*po
c         ratekappa=1.d0
c         if (usekappa) then
c           ratekappa=fkenhance(kappa,aa)
c         endif
c         r12=((rka*f)*omres(m))*dexp(-y)*ratekappa
c         rr=((r12*abup)*e)*fgaunt(jjj,0,aa)
c         rr=rr/(0.413497d0*a(1.0d0/dble(jjj)))
c         coolz(jel)=coolz(jel)+rr
c         coolzion(jjj,jel)=coolzion(jjj,jel)+rr
c         rloss=rloss+rr
c         rbri(m)=rr*ifpi
c         endif
c
c       endif
c
c     enddo
c
c     if (rloss.lt.epsilon) rloss=0.d0
cc
c     return
cc
c     end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     New resonance line data in XLINDAT, requires new
c     code so that the effective osc strength f' can be used
c     effectively.
c
c
c     calls the new function fresga to get gaunt factors needed.
c
c
c     refs: Landini & Monsignori Fosse 1990 A.A.Suppl.Ser. 82:229
c        Mewe 1985 A.A.Suppl.Ser. 45:11
c
c     RSS 8/90
c
c     NOTE: transition energy does not give Egj, it gives Ejk
c     and in some cases this may not be a good approximation.....
c     ie transition H6
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******COMPUTES RESONANCE LINE COOLING
c       NB.  SUBR. HYDRO SHOULD BE CALLED PREVIOUSLY
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     subroutine reson2 (t, de, dh)
cc
c     include 'cblocks.inc'
cc
cc
cc           Variables
cc
c     real*8 t, de, dh
c     real*8 abup,rr,y,f,loss
c     real*8 egj,ejk,tr,fef,gbar,fresga
c     real*8 cgjb,omegab,gi,pz
cc      real*8 e1
cc
c     real*8 ratekappa
cc
c     integer*4 i, ionindex, civindex, nvindex, oviindex
c     integer*4 atom,ion,isos,code
cc
cc           Functions
cc
cc      real*8 farint
c     real*8 fkenhance
cc
cc
c     xrloss=0.0d0
c     if (xlines.lt.1) return
cc
c     t=dmax1(t,mintemp)
c     f=1.d0/dsqrt(t)
cc
c     gi=2.d0
cc
c     civindex=0
c     do ionindex=1,nfmions
c       if (fmatom(ionindex).eq.zmap(6)) then
c         if (fmion(ionindex).eq.4) then
c           civindex=ionindex
c         endif
c       endif
c     enddo
cc
c     nvindex=0
c     do ionindex=1,nfmions
c       if (fmatom(ionindex).eq.zmap(7)) then
c         if (fmion(ionindex).eq.5) then
c           nvindex=ionindex
c         endif
c       endif
c     enddo
cc
c     oviindex=0
c     do ionindex=1,nfmions
c       if (fmatom(ionindex).eq.zmap(8)) then
c         if (fmion(ionindex).eq.6) then
c           oviindex=ionindex
c         endif
c       endif
c     enddo
cc
cc
c     do i=1,xlines
cc
cc     get data from arrays for line # i
cc
cc     Note: only line for possible species are read in
cc     so no need to check maxion etc...
cc
c       atom=xrat(i)
c       ion=xion(i)
c       isos=xiso(i)
cc
c       xrbri(i)=0.d0
cc
c       pz=zion(atom)*pop(ion,atom)
cc
cc     only calculate abundant species
cc
c       if (pz.ge.pzlimit) then
cc
cc     note that Egj does not necesarily equal Ejk
cc
c         egj=xegj(i)
c         ejk=xejk(i)
c         tr=xtrans(i)
c         fef=xfef(i)
cc
cc     get scaled energy gap to level j from ground (not k)
cc
c         y=egj*ev/(rkb*t)
cc
c         if (y.lt.maxdekt) then
cc
c           ratekappa=1.d0
c           if (usekappa) then
c             ratekappa=fkenhance(kappa,y)
c           endif
cc
cc     get mean gaunt factor
cc
c           gbar=fresga(atom,isos,tr,egj,t,code)
cc
cc     transition power rate rr
cc
c           rr=0.d0
c           cgjb=0.d0
c           if (code.ge.0) then
c             omegab=pi8rt3*fef*gi*gbar*r_inf/egj
c           else
c             omegab=fef
c           endif
cc
c           cgjb=rka*f*dexp(-y)
c           rr=cgjb*omegab*ratekappa
cc
cc     number to transition is in abup
cc
cc     photons cm^-3 s^-1
cc
c           rr=de*dh*pz*rr
cc
cc     ergs...
cc
c           loss=ev*ejk*rr
cc
c           coolz(atom)=coolz(atom)+loss
c           coolzion(ion,atom)=coolzion(ion,atom)+loss
c           xrloss=xrloss+loss
c           xrbri(i)=loss*ifpi
cc
c         endif
cc
cc     end population limited loop
cc
c       endif
cc
c     enddo
cc
c     if (xrloss.lt.epsilon) xrloss=0.d0
cc
c     return
cc
c     end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fxr3omgspl(t,y,icol,idx)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8         y  XXX-meaning
c! @param [in,out]   real*8      icol  XXX-meaning
c! @param [in,out]   real*8       idx  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fxr3omgspl(t,y,icol,idx)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, y
      integer*4 idx, icol
c
      real*8 upsilon
      integer*4 l,nspl
      integer*4 omtype
      real*8 beta
      real*8 btc
      real*8 btx(mxxr3nspl)
      real*8 bty(mxxr3nspl)
      real*8 bty2(mxxr3nspl)
c
      real*8 fsplint
c
      upsilon=0.d0
      omtype=xr3col_typespl(icol,idx)
      if ((omtype.eq.3).or.(omtype.eq.13)) then
c
c should be type 3 or 13, most differences are lost on init
c as x, y, and y2 are made for all types. only some types need
c exponentiation at the end
c
        btc=xr3col_tc(icol,idx)
        beta=(t/(t+btc))
        nspl=xr3col_nspl(icol,idx)
        do l=1,nspl
c      uniform splines for all hhe data
          btx(l)=xr3col_x(l)
          bty(l)=xr3col_y(l,icol,idx)
          bty2(l)=xr3col_y2(l,icol,idx)
        enddo
        upsilon=fsplint(btx,bty,bty2,nspl,beta)
        if (omtype.eq.13) then
          upsilon=upsilon*dlog((1.d0/y)+2.71828182845905d0)
        endif
      else
        write (*,*) 'ERROR, Invalid spline type in fxr3omgspl:',omtype
        write (*,*) t,icol,idx
        stop
      endif
      fxr3omgspl=dmax1(0.d0,upsilon)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine solvexr3ionkappa
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c! @param [in,out]   real*8       idx  XXX-meaning
c! @param [in,out]   real*8       bri  XXX-meaning
c! @param [in,out]   real*8        ni  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine solvexr3ionkappa (t, de, dh, idx, bri, ni)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     refs: CHIANTI database 8.01
c     Values derived by RSS2015
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, de, dh, abde
      integer*4 idx, ni
      integer*4 atom, ion, is
      integer*4 icol, nc, line, nl
      integer*4 i,j,jj,kk,l
      integer*4 mspecies
      integer*4 j2phlevel,ngrnd
c
      real*8 y,omegaij,rr,cr,cgjb,pz,loss,invrkt,sum
c      real*8 ratekappa,f,br,ee,invgi,emiss,j2ploss
      real*8 ratekappa,f,br,ee,invgi,emiss
      real*8 bri(mxxr3lvls,mxxr3lvls)
      real*8 eji(mxxr3lvls,mxxr3lvls)
      real*8 fl(mxxr3lvls)
c
      real*8 fkenhance
      real*8 fxr3omgspl
      atom=xr3at(idx)
      if (atom.eq.0) return
      ion=xr3ion(idx)
      is=(mapz(atom)-ion+1)
      pz=zion(atom)*pop(ion,atom)
      if (pz.le.pzlimit) return
      abde=de*dh*pz
      j2phlevel=xr32s12j(idx)
c
      do i=1,ni
        do j=1,ni
          bri(i,j)=0.d0
          eji(i,j)=plk*cls*dabs(xr3ei(j,idx)-xr3ei(i,idx))
        enddo
      enddo
c lower level pop fractions for collision populations
      do l=1,mxxr3lvls
        fl(l)=0.d0
      enddo
      fl(1)=1.d0
c find fractions in lower levels
      mspecies=fmspindex(ion,atom)
      if (mspecies.gt.0) then
        sum=0.d0
        ngrnd=fmnl(mspecies)
        do l=1,ngrnd
          fl(l)=0.d0
          if (fmx(l,mspecies).gt.1.0d-3) then
            fl(l)=fmx(l,mspecies)
            sum=sum+fl(l)
          endif
        enddo
        do l=1,ngrnd
          fl(l)=fl(l)/sum
        enddo
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      t=dmax1(t,mintemp)
      f=1.d0/dsqrt(t)
      invrkt=1.d0/(rkb*t)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      nc=nxr3ioncol(idx)
c  kappa
      do icol=1,nc
c i = lower, j = upper
        i=xr3col_i(icol,idx)
        xr3col_fr(icol,idx)=fl(i)
        if (fl(i).gt.epsilon) then
          j=xr3col_j(icol,idx)
          ee=eji(i,j)
          y=ee*invrkt
          if ((y.gt.0.d0).and.(y.lt.maxdekt)) then
            ratekappa=fkenhance(kappa,y)
            invgi=xr3invgi(i,idx)
            omegaij=fxr3omgspl(t,y,icol,idx)*invgi
            cgjb=rka*f*dexp(-y)
            cr=fl(i)*cgjb*omegaij*ratekappa
            rr=abde*cr
            if (rr.gt.epsilon) then
              if (linecoolmode.eq.1) then
                if ((is.eq.1).and.(i.eq.1).and.(j.eq.j2phlevel)) then
c      dont add the 2photon loss here, testing
                  goto 10
                endif
                if ((is.eq.2).and.(i.eq.1).and.(j.eq.j2phlevel)) then
c      dont add the 2photon loss here, testing
                  goto 10
                endif
              endif
              loss=rr*ee
              xr3loss=xr3loss+loss
              coolz(atom)=coolz(atom)+loss
              coolzion(ion,atom)=coolzion(ion,atom)+loss
   10         continue
              nl=xr3col_nl(icol,idx)
              do line=1,nl
c      lower
                jj=xr3col_jj(line,icol,idx)
c      higher
                kk=xr3col_kk(line,icol,idx)
                br=xr3col_br(line,icol,idx)
c      note index swap above
                emiss=(rr*br*eji(jj,kk))
                bri(kk,jj)=bri(kk,jj)+emiss
              enddo
            endif
          endif
        endif
      enddo
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine solvexr3ion
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c! @param [in,out]   real*8       idx  XXX-meaning
c! @param [in,out]   real*8       bri  XXX-meaning
c! @param [in,out]   real*8        ni  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine solvexr3ion (t, de, dh, idx, bri, ni)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     refs: CHIANTI database 8.01
c     Values derived by RSS2015
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, de, dh, abde
      integer*4 idx, ni
      integer*4 atom, ion, is
      integer*4 icol, nc, line, nl
      integer*4 i,j,jj,kk,l
      integer*4 mspecies
      integer*4 j2phlevel,ngrnd
c
      real*8 y,omegaij,rr,cr,cgjb,pz,loss,invrkt,sum
c      real*8 ratekappa
      real*8 f,br,ee,invgi,emiss
      real*8 bri(mxxr3lvls,mxxr3lvls)
      real*8 eji(mxxr3lvls,mxxr3lvls)
      real*8 fl(mxxr3lvls)
c
      real*8 fxr3omgspl
      atom=xr3at(idx)
      if (atom.eq.0) return
      ion=xr3ion(idx)
      is=(mapz(atom)-ion+1)
      pz=zion(atom)*pop(ion,atom)
      if (pz.le.pzlimit) return
      abde=de*dh*pz
      j2phlevel=xr32s12j(idx)
c
      do i=1,ni
        do j=1,ni
          bri(i,j)=0.d0
          eji(i,j)=plk*cls*dabs(xr3ei(j,idx)-xr3ei(i,idx))
        enddo
      enddo
c lower level pop fractions for collision populations
      do l=1,mxxr3lvls
        fl(l)=0.d0
      enddo
      fl(1)=1.d0
c find fractions in lower levels
      mspecies=fmspindex(ion,atom)
      if (mspecies.gt.0) then
        sum=0.d0
        ngrnd=fmnl(mspecies)
        do l=1,ngrnd
          fl(l)=0.d0
          if (fmx(l,mspecies).gt.1.0d-3) then
            fl(l)=fmx(l,mspecies)
            sum=sum+fl(l)
          endif
        enddo
        do l=1,ngrnd
          fl(l)=fl(l)/sum
        enddo
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      t=dmax1(t,mintemp)
      f=1.d0/dsqrt(t)
      invrkt=1.d0/(rkb*t)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      nc=nxr3ioncol(idx)
      do icol=1,nc
c i = lower, j = upper
        i=xr3col_i(icol,idx)
        xr3col_fr(icol,idx)=fl(i)
        if (fl(i).gt.epsilon) then
          j=xr3col_j(icol,idx)
          ee=eji(i,j)
          y=ee*invrkt
          if ((y.gt.0.d0).and.(y.lt.maxdekt)) then
            invgi=xr3invgi(i,idx)
            omegaij=fxr3omgspl(t,y,icol,idx)*invgi
            cgjb=rka*f*dexp(-y)
            cr=fl(i)*cgjb*omegaij
            rr=abde*cr
            if (rr.gt.epsilon) then
              if (linecoolmode.eq.1) then
                if ((is.eq.1).and.(i.eq.1).and.(j.eq.j2phlevel)) then
c      dont add the 2photon loss here, testing
                  goto 10
                endif
                if ((is.eq.2).and.(i.eq.1).and.(j.eq.j2phlevel)) then
c      dont add the 2photon loss here, testing
                  goto 10
                endif
              endif
              loss=rr*ee
              xr3loss=xr3loss+loss
              coolz(atom)=coolz(atom)+loss
              coolzion(ion,atom)=coolzion(ion,atom)+loss
   10         continue
              nl=xr3col_nl(icol,idx)
              do line=1,nl
c      lower
                jj=xr3col_jj(line,icol,idx)
c      higher
                kk=xr3col_kk(line,icol,idx)
                br=xr3col_br(line,icol,idx)
c      note index swap above
                emiss=(rr*br*eji(jj,kk))
                bri(kk,jj)=bri(kk,jj)+emiss
              enddo
            endif
          endif
        endif
      enddo
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine reson3
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine reson3 (t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c     Local  params and variables
c
      real*8 t, de, dh
      real*8 pz, brilimit
      parameter (brilimit=1.0d-40)
c
      real*8 ion_bri(mxxr3lvls,mxxr3lvls)
c
      integer*4 i, j, j2phlevel
      integer*4 idx, atom, ion, is
      integer*4 ni,line
c
      xr3loss=0.d0
      if (nxr3ions.lt.1) return
c
      do line=1,nxr3lines
        xr3lines_bri(line)=0.d0
      enddo
      do atom=1,atypes
        if (mapz(atom).gt.2) collrate2p(atom)=0.d0
        if (mapz(atom).gt.1) collrate2phe(atom)=0.d0
      enddo
c
      do idx=1,nxr3ions
        atom=xr3at(idx)
        if (atom.ne.0) then
          ion=xr3ion(idx)
          is=mapz(atom)-ion+1
          pz=zion(atom)*pop(ion,atom)
          if (pz.ge.pzlimit) then
c
c pzlimit
c
            j2phlevel=xr32s12j(idx)
            ni=xr3ni(idx)
            if (usekappa) then
              call solvexr3ionkappa (t, de, dh, idx, ion_bri, ni)
            else
              call solvexr3ion (t, de, dh, idx, ion_bri, ni)
            endif
c H like
            if (is.eq.1) then
c is = 1
              i=1
              do j=1,ni
c
                if (ion_bri(i,j).gt.brilimit) then
                  line=xr3lines_map(i,j,idx)
c
c get effective 2 photon coll rates including cascade
c contributions to j2phlevel,  j2phlevel = 0 for non H- or
c He-like ions and is ignored. Also don't let the 2photon
c energy appear as a monochrome line, the emission is spread
c added elsewhere in twophoton.f
c
                  if (j.eq.j2phlevel) then
                    collrate2p(atom)=ion_bri(i,j)/xr3lines_egij(line)
                    collrate2p(atom)=collrate2p(atom)/(de*dh*pz)
                    goto 10
                  endif
c
                  xr3lines_bri(line)=ion_bri(i,j)*ifpi
                endif
   10           continue
c j i=1
              enddo
c next j levels, i >1
              do i=2,ni
                do j=1,ni
                  if (ion_bri(i,j).gt.brilimit) then
                    line=xr3lines_map(i,j,idx)
                    xr3lines_bri(line)=ion_bri(i,j)*ifpi
                  endif
                enddo
              enddo
c is = 1
              goto 30
            endif
c He like
            if (is.eq.2) then
c is = 2
              i=1
              do j=1,ni
                if (ion_bri(i,j).gt.brilimit) then
                  line=xr3lines_map(i,j,idx)
c
c get effective 2 photon coll rates including cascade
c contributions to j2phlevel,  j2phlevel = 0 for non H- or
c He-like ions and is ignored. Also don't let the 2photon
c energy appear as a monochrome line, the emission is spread
c added elsewhere in twophoton.f
c
                  if (j.eq.j2phlevel) then
                    collrate2phe(atom)=ion_bri(i,j)/xr3lines_egij(line)
                    collrate2phe(atom)=collrate2phe(atom)/(de*dh*pz)
                    goto 20
                  endif
                  xr3lines_bri(line)=ion_bri(i,j)*ifpi
                endif
   20           continue
c j, i=1
              enddo
c next j le vels, i >1
              do i=2,ni
                do j=1,ni
                  if (ion_bri(i,j).gt.brilimit) then
                    line=xr3lines_map(i,j,idx)
                    xr3lines_bri(line)=ion_bri(i,j)*ifpi
                  endif
                enddo
              enddo
c is = 2
              goto 30
            endif
c
c          if (is.gt.2) then
c is others
            do i=1,ni
              do j=1,ni
                if (ion_bri(i,j).gt.brilimit) then
                  line=xr3lines_map(i,j,idx)
                  xr3lines_bri(line)=ion_bri(i,j)*ifpi
                endif
              enddo
            enddo
c is others
c          endif
c
   30       continue
c
c pzlimit
c
          endif
c atom
        endif
      enddo
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (xr3loss.lt.brilimit) xr3loss=0.d0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c***************************************************************
c> @brief The function real*8 function fxrlomgspl(t,y,icol,idx)
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8         y  XXX-meaning
c! @param [in,out]   real*8      icol  XXX-meaning
c! @param [in,out]   real*8       idx  XXX-meaning
c!
c! @return
c!  XXXX This function returns a %s number with is
c!  XXXX say explictly what is returned
c!
c! @details
c!  XXXX Enter details here
c****************************************************************

      real*8 function fxrlomgspl(t,y,icol,idx)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, y
      integer*4 idx, icol
c
      real*8 upsilon
      integer*4 l,nspl
      integer*4 omtype
      real*8 beta
      real*8 btc
      real*8 btx(mxxrlnspl)
      real*8 bty(mxxrlnspl)
      real*8 bty2(mxxrlnspl)
c
      real*8 fsplint
c
      upsilon=0.d0
      omtype=xrlcol_typespl(icol,idx)
c     if ((omtype.eq.3).or.(omtype.eq.13)) then
c
c should be type 3 or 13, most differences are lost on init
c as x, y, and y2 are made for all types. only type 13 needs
c extra scaling at the end
c
      btc=xrlcol_tc(icol,idx)
      beta=(t/(t+btc))
      nspl=xrlcol_nspl(icol,idx)
      do l=1,nspl
c      uniform splines for all hhe data
        btx(l)=xrlcol_x(l)
        bty(l)=xrlcol_y(l,icol,idx)
        bty2(l)=xrlcol_y2(l,icol,idx)
      enddo
      upsilon=fsplint(btx,bty,bty2,nspl,beta)
      if (omtype.eq.13) then
        upsilon=upsilon*dlog((1.d0/y)+2.71828182845905d0)
      endif
c     else
c       write (*,*) 'ERROR, Invalid spline type in fxrlomgspl:',omtype
c       write (*,*) t,icol,idx
c       stop
c     endif
      fxrlomgspl=dmax1(0.d0,upsilon)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine solvexrlion
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c! @param [in,out]   real*8       idx  XXX-meaning
c! @param [in,out]   real*8       bri  XXX-meaning
c! @param [in,out]   real*8        ni  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine solvexrlion (t, de, dh, idx, bri, ni)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     refs: CHIANTI database 8.01
c     Values derived by RSS2015
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, de, dh, abde, sum
      integer*4 idx, ni, ngnd
      integer*4 atom, ion
      integer*4 icol, nc, line, nl
      integer*4 i,j,jj,kk,l,ngrnd
      integer*4 fespecies,mspecies
c
      real*8 y,omegaij,rr,cr,cgjb,pz,loss,invrkt
      real*8 ratekappa,f,br,ee,invgi,emiss
      real*8 bri(mxxrllvls,mxxrllvls)
      real*8 eji(mxxrllvls,mxxrllvls)
      real*8 fl(mxxrllvls)
c
c     integer*4 col_jj(mxxrlcasc,mxxrlcols)
c     integer*4 col_kk(mxxrlcasc,mxxrlcols)
c     real*8    col_br(mxxrlcasc,mxxrlcols)
c
      real*8 fkenhance
      real*8 fxrlomgspl
c
      atom=xrlat(idx)
      if (atom.eq.0) return
      ion=xrlion(idx)
c      is=(mapz(atom)-ion+1)
      pz=zion(atom)*pop(ion,atom)
      if (pz.le.pzlimit) return
c
      abde=de*dh*pz
c
      do l=1,mxxrllvls
        fl(l)=0.d0
      enddo
c
      fl(1)=1.d0
c
      mspecies=fmspindex(ion,atom)
      if (mspecies.gt.0) then
        sum=0.d0
        ngrnd=fmnl(mspecies)
        do l=1,ngrnd
          fl(l)=0.d0
          if (fmx(l,mspecies).gt.1.0d-3) then
            fl(l)=fmx(l,mspecies)
            sum=sum+fmx(l,mspecies)
          endif
        enddo
        do l=1,ngrnd
          fl(l)=fl(l)/sum
        enddo
      endif
c
      fespecies=fespindex(ion,atom)
      if (fespecies.gt.0) then
        ngnd=fenl(fespecies)
        if ((mapz(atom).eq.26).and.(ion.eq.3)) then
          ngnd=34
        endif
        sum=0.d0
        do l=1,ngnd
          fl(l)=0.d0
          if (fex(l,fespecies).gt.1.0d-3) then
            fl(l)=fex(l,fespecies)
            sum=sum+fex(l,fespecies)
          endif
        enddo
        do l=1,ngnd
          fl(l)=fl(l)/sum
        enddo
      endif
c
      do i=1,ni
        do j=1,ni
          bri(i,j)=0.d0
          eji(i,j)=plk*cls*dabs(xrlei(j,idx)-xrlei(i,idx))
        enddo
      enddo
c
      t=dmax1(t,mintemp)
      f=1.d0/dsqrt(t)
      invrkt=1.d0/(rkb*t)
c
      nc=nxrlioncol(idx)
      do icol=1,nc
c i = lower, j = upper
        i=xrlcol_i(icol,idx)
        xrlcol_fr(icol,idx)=fl(i)
        if (fl(i).gt.0.d0) then
          j=xrlcol_j(icol,idx)
          ee=eji(i,j)
          y=ee*invrkt
          if ((y.gt.0.d0).and.(y.lt.maxdekt)) then
            ratekappa=1.d0
            if (usekappa) then
              ratekappa=fkenhance(kappa,y)
            endif
            invgi=xrlinvgi(i,idx)
            omegaij=fxrlomgspl(t,y,icol,idx)*invgi
            cgjb=rka*f*dexp(-y)
            cr=fl(i)*cgjb*omegaij*ratekappa
            rr=abde*cr
            if (rr.gt.epsilon) then
              loss=rr*ee
              xrlloss=xrlloss+loss
              coolz(atom)=coolz(atom)+loss
              coolzion(ion,atom)=coolzion(ion,atom)+loss
              nl=xrlcol_nl(icol,idx)
              do line=1,nl
c      lower
                jj=xrlcol_jj(line,icol,idx)
c      higher
                kk=xrlcol_kk(line,icol,idx)
                br=xrlcol_br(line,icol,idx)
c      note index swap above
                emiss=(rr*br*eji(jj,kk))
                bri(kk,jj)=bri(kk,jj)+emiss
              enddo
            endif
          endif
        endif
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine resonl
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine resonl (t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c     Local  params and variables
c
      real*8 t, de, dh
      real*8 pz
c
      real*8 ion_bri(mxxrllvls,mxxrllvls)
c
      integer*4 i, j
      integer*4 idx, atom, ion
      integer*4 ni,line
c
      xrlloss=0.d0
      if (nxrlions.lt.1) return
c
      do line=1,nxrllines
        xrllines_bri(line)=0.d0
      enddo
c
      do idx=1,nxrlions
        atom=xrlat(idx)
        if (atom.ne.0) then
          ion=xrlion(idx)
          ni=xrlni(idx)
          pz=zion(atom)*pop(ion,atom)
          if (pz.ge.pzlimit) then
            call solvexrlion (t, de, dh, idx, ion_bri, ni)
            do i=1,ni
              do j=1,ni
                if (ion_bri(i,j).gt.epsilon) then
                  line=xrllines_map(i,j,idx)
                  xrllines_bri(line)=ion_bri(i,j)*ifpi
                endif
              enddo
            enddo
          endif
        endif
      enddo
      if (xrlloss.lt.epsilon) xrlloss=0.d0
      return
      end
