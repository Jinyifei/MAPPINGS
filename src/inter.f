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
      subroutine inter (t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******COMPUTES INTERCOMBINATION LINE COOLING
c     NB.  SUBR. HYDRO SHOULD BE CALLED PREVIOUSLY
c
c     RETURNS DATA IN COMMON BLOCK /CLINE/
c     FSLOS (ERG.CM-3.S-1)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, de, dh
      real*8 rp,q21,q12,aa,pn2,fbr,omg
      real*8 f, pz,ba,t2,frkt
      real*8 ratekappa
      integer*4 atom,ion,m
c
      real*8 fkenhance
c
      fslos=0.0d0
      if (mlines.lt.1) return
c
c    ***COMPUTES RATES Q12,Q21 , HENCE POPULATION OF LEVEL 2
c
      f=dsqrt(1.0d0/(t+epsilon))
      t2=t*0.01d0
      frkt=1.d0/(rkb*t)
      do m=1,mlines
        atom=ielfs(m)
        ion=ionfs(m)
        pz=zion(atom)*pop(ion,atom)
        if (pz.ge.pzlimit) then
c
          fbr=0.0d0
          fsbri(m)=0.d0
c
          aa=e12fs(m)*frkt
          if (aa.lt.maxdekt) then
            ba=dexp(-aa)
            omg=omfs(m)
            ratekappa=1.d0
            if (usekappa) then
              ratekappa=fkenhance(kappa,aa)
            endif
            q12=(rka*f)*omg*ba/w1fs(m)*ratekappa
            q21=(rka*f)*omg/w2fs(m)*ratekappa
            rp=(de*q12)/(a21fs(m)+(de*q21))
            pn2=dh*pz*(rp/(1.0d0+rp))
            fbr=(pn2*a21fs(m))*e12fs(m)
            coolz(atom)=coolz(atom)+fbr
            coolzion(ion,atom)=coolzion(ion,atom)+fbr
            fslos=fslos+fbr
            fsbri(m)=fbr*ifpi
          endif
c
        endif
c
      enddo
c
      if (fslos.lt.epsilon) fslos=0.d0
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Subroutine to calculate the transitions
c     from metatsable levels of highly ionised ions.
c     long lambda and low ionisations are handled in inter.
c
c     Uses the collision strength/statwei provided
c
c
c     refs: Landini & Monsignori Fosse 1990 A.A.Suppl.Ser. 82:229
c        Mewe 1985 A.A.Suppl.Ser. 45:11
c
c     RSS 9/90
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     subroutine inter2 (t, de, dh)
cc
c     include 'cblocks.inc'
cc
c     real*8 t, de, dh
c     real*8 egj,ejk,rr,frkt
c     real*8 cgjb,omegab
c     real*8 abde,pz,y,loss
cc
c     real*8 ratekappa
cc
c     integer*4 i,atom,ion
cc
c     real*8 fkenhance
cc
c     xiloss=0.0d0
c     if (xilines.lt.1) return
c
c      t=dmax1(t,mintemp)
c     frkt=1.d0/(rkb*t)
cc
c     do i=1,xilines
cc
cc     get data from arrays for line # i
cc
cc     Note: only line for possible species are read in
cc     so no need to check maxion etc...
cc
c       atom=xiat(i)
c       ion=xiion(i)
cc
cc     only calculate for abundant species
cc
c       xrbri(i)=0.d0
cc
c       pz=zion(atom)*pop(ion,atom)
cc
c       if (pz.ge.pzlimit) then
cc
c         abde=de*dh*pz
cc
cc     note that Egj does equal Ejk
cc
c         egj=xiejk(i)*ev
c         y=egj*frkt
c         if (y.lt.maxdekt) then
cc
c         ejk=egj
c         omegab=xomeg(i)
cc
cc     get scaled energy gap to level j from ground (not k)
cc
c         ratekappa=1.d0
c         if (usekappa) then
c           ratekappa=fkenhance(kappa,y)
c         endif
cc
cc     transition power rate rr
cc
c         rr=0.d0
c         cgjb=0.d0
c         cgjb=rka*(dexp(-y)/dsqrt(t))*omegab
cc
c         rr=cgjb*ratekappa
cc
cc     number to transition abup
cc
cc
cc     total power in line
cc
c         loss=ejk*abde*rr
cc
c         xiloss=xiloss+loss
c         coolz(atom)=coolz(atom)+loss
c         coolzion(ion,atom)=coolzion(ion,atom)+loss
cc
c         xibri(i)=loss*ifpi
c         endif
cc
cc     end population limited loop
cc
c       endif
cc
cc
c     enddo
cc
c     if (xiloss.lt.epsilon) xiloss=0.d0
cc
c     return
cc
c     end
