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
c     Adam D. Thomas, Jin Yie-Fei
c
c
c       Version v5.1.21
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine teequi (tei, tef, edens, hdens, tstep, nmod)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     FINDS THE EQUILIBRIUM TEMPERATURE AND THE
c     CORRESPONDING IONISING STATE OF THE GAS
c     AT EQUILIBRIUM IONISATION OF AFTER TIME STEP :STEP
c     TEI : INITIAL GUESS FOR TEMPERATURE
c     TEF,EDENS: FINAL TEMPERATURE AND ELECTRONIC DENSITY
c
c     NMOD = 'EQUI'  :  EQUILIBRIUM IONISATION
c     NMOD = 'TIM'   :  INITIAL IONIC POP. EVOLVED BY TSTEP SEC.
c
c     CALL SUBR. COOL,EQUION
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 a,b,c1,c2,cc,csub,delexi,delmin
      real*8 dl1,dlodef,dlpr,dt12,dvv,fadl,ftu,ftu0
      real*8 t2,tdef,timin,tl1,tl2,tl2a,tm1,tmin,tsub
      real*8 tti,u,varf,xhyf
      real*8 tei, teinit,tef, edens, hdens, tstep
      real*8 popul(mxion, mxelem)
c
      integer*4 iconsis,isis,jok,luop,luty,n,nf
c
      character nmod*4, ntest*4
c
      real*8 arctanh
c
      arctanh(u)=0.5d0*dlog((1.d0+u)/(1.d0-u))
c
      luty=6
      luop=23
c
      if ((nmod.ne.'EQUI').and.(nmod.ne.'TIM')) then
        write (luty,10) nmod
   10 format(/' MODE IMPROPERLY SET FOR SUBR. TEEQUI  : ',a4)
        stop
      endif
c
c    Fudge which sets everything constant once T =30 K
c
      if (tei.le.30.d0) then
        tef=tei
        goto 120
      endif
c
c
      ntest='N'
      if (tef.lt.0.0d0) ntest='Y'
      delmin=4.d-4
      nf=3
c      tmin = 100.d0
c      timin = 100.d0
      tmin=10.d0
      timin=30.0d0
      ftu0=0.0d0
      isis=0
      if (nmod.eq.'TIM') then
        call copypop (pop, popul)
      endif
c
c    ***GUESS AN IMPROVED VALUE FOR THE TEMPERATURE
c
c
c      te0 = dmax1(timin,tei,dsign(2.d4,-tei))
      teinit=dmax1(timin,tei)
      tef=teinit
      tm1=teinit
c
      tl1=dlog(tm1)
      if (nmod.eq.'TIM') then
        call timion (tm1, edens, hdens, xhyf, tstep)
      else
        call equion (tm1, edens, hdens)
      endif
c
      call cool (tm1, edens, hdens)
c
      if (dabs(dlos).lt.delmin) goto 130
      if (dabs(dabs(dlos)-1.0d0).lt.1.d-6) dlos=dsign(1.0d0-1.d-6,dlos)
      if (dabs(dlos).gt.0.06d0) nf=nf+2
      if (dabs(dlos).gt.0.20d0) nf=nf+3
      c1=arctanh(dlos)
      tl2=tl1-dlos
      t2=dmax1(dexp(tl2),4.0d0*tmin)
      tl2=dlog(t2)
      tti=t2
      dl1=dlos
      tdef=tm1
      dlodef=dl1
      varf=0.02d0+(dabs(dl1)**0.70d0)
      jok=0
c
c
c     ***USING 2 TEMP. (TM1,T2)  AND 2 FRACT. RESID. (DLOS1,DLOS2)
c     IT FITS THE FUNCTION : ARCTANH(DLOS)=B+A*LN(T)
c     NEXT VALUE OF T=DEXP(-B/A)
c
      do 80 n=1,nf
        dlpr=dlos
        if (nmod.eq.'TIM') then
          call copypop (popul, pop)
          call timion (t2, edens, hdens, xhyf, tstep)
          write(*,*) t2
        else
          call equion (t2, edens, hdens)
        endif
        call cool (t2, edens, hdens)
        if (dabs(dabs(dlos)-1.0d0).lt.1.d-6) dlos=dsign(1.0d0-1.d-6,
     &   dlos)
        if (dabs(dlos).le.dabs(dlodef)) then
          dlodef=dlos
          tdef=t2
        endif
        c2=arctanh(dlos)
        csub=c2-c1
        tsub=tl2-tl1
        if (dabs(tsub).lt.1.0d-36) tsub=dsign(1.0d-36,tsub)
        if (tsub.eq.0.0d0) tsub=dsign(1.0d-36,csub)
c     **DOES NOT ALLOW  A  TO BE NEGATIVE
        a=dabs(csub/tsub)
        b=c1-(a*tl1)
        cc=c1
        c1=c2
        tl1=tl2
        tm1=t2
        tl2a=-(b/(dmax1(dabs(a),dabs(b)/20.0d0)*dsign(1.d0,a)))
        dt12=tl2a-tl1
        tl2=tl1+dsign(dmin1(varf,dabs(dt12)),dt12)
        t2=dexp(tl2)
        ftu=(t2-tm1)/dmax1(t2,tm1,tmin/10.d0)
        iconsis=idint(((1.1d0*ftu0)*ftu)/(1.d-20+dabs(ftu0*ftu)))
        ftu0=ftu
c
        dvv=dabs(tl2-tl1)
        if (iconsis.lt.0) then
          isis=isis+1
          varf=varf/(2.0d0+(1.d0/(isis*isis)))
          tl2=tl1+dsign(dmin1(varf,dabs(dt12)),dt12)
          t2=dexp(tl2)
        else if (iconsis.gt.0) then
          varf=dmin1(1.1d0,dmax1(5.0d-4,(1.3d0*varf)*(dmax1(1.5d-1,
     &     dmin1(1.d0,dvv/varf))**0.2d0)))
        endif
c
c     *PRINT OUT WHEN TESTED BY SUBR. TESTI
C       if (ntest.ne.'Y') goto 70
C       if (n.ne.1) goto 40
C       write (luop,20)
C       write (luty,20)
C  20 format('0',t4,'TM1',t14,'DLOS',t27,'T2',t39,'A',t49,'B',t58,'C1'
C    &        ,t68,'C2')
C       write (luty,30) teinit,dl1,tti
C       write (luop,30) teinit,dl1,tti
C  30 format(' ',1pg12.5,g10.3,g12.5)
C  40   write (luty,50) tm1,dlos,t2,a,b,cc,c2,isis
C       write (luop,50) tm1,dlos,t2,a,b,cc,c2,isis,varf
C  50 format(' ',1pg12.5,g10.3,g12.5,4g10.3,i4,1pg10.3)
C       write (luop,60) tloss,hloss,rloss,fslos,fmloss,feloss,fflos,
C    &   colos,pgain,rngain
C  60 format(' ',10(1pg10.2))
C  70   continue
c
        fadl=dmin1(100.0d0,dmax1(0.5d0,dabs(dlpr)/(dabs(dlos)+1.d-4)))
        delexi=7.0d-4+(2.0d-4*dmin1(5.d0,6.d-1*fadl))
        if (dabs(dlos).lt.2.d-3) jok=jok+1
        if (((dabs(dlos).lt.delexi).or.(t2.lt.tmin)).or.((jok.gt.3)
     &   .and.(dabs(dlos).lt.(dble(jok)*1.3d-4)))) goto 90
   80 continue
c
c     ***IF CONVERGENCE POOR , USES TEMP. WITH MIN. ABS(DLOS)
c
   90 if (dabs(dlos).lt.0.02d0) goto 110
      t2=tdef
      if (expertmode.gt.0) write (luty,100) dlodef,tdef
      if (ntest.eq.'Y') write (luop,100) dlodef,tdef
  100 format(' CONVERGENCE FOR EQUIL. TEMP. IS TOO SLOW   ' ,'DL:'
     &     ,1pg9.2,'  TE:',0pf9.0)
  110 continue
c
c     ***USES FINAL TEMPERATURE
c
      if (dabs(dlos).gt.(2.0d0*dabs(dlodef))) t2=tdef
      tef=dmax1(t2,30.d0)
  120 if (nmod.eq.'TIM') then
        call copypop (popul, pop)
        call timion (tef, edens, hdens, xhyf, tstep)
      else
        call equion (tef, edens, hdens)
      endif
c
c      if (tef.lt.200.d0) write (*,*)
c     & 'WARNING: temperature may be unrealistic'
c
c      WRITE(*,*) N,DL1,TEinit,DLODEF,TDEF,DLOS,TEF
c
      call cool (tef, edens, hdens)
  130 continue
c
c
      return
c
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine teequi2 (tei, tef, edens, hdens, tstep, nmod)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     more iteration on dlos
c
c     FINDS THE EQUILIBRIUM TEMPERATURE AND THE
c     CORRESPONDING IONISING STATE OF THE GAS
c     AT EQUILIBRIUM IONISATION OF AFTER TIME STEP :STEP
c     TEI : INITIAL GUESS FOR TEMPERATURE
c     TEF,EDENS: FINAL TEMPERATURE AND ELECTRONIC DENSITY
c
c     NMOD = 'EQUI'  :  EQUILIBRIUM IONISATION
c     NMOD = 'TIM'   :  INITIAL IONIC POP. EVOLVED BY TSTEP SEC.
c
c     CALL SUBR. COOL,EQUION
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Parameters
c
      real*8 tei, tef, edens, hdens, tstep
      character nmod*4
c
c           Variables
c
      real*8 a,b,c1,c2,cc,csub,delexi,delmin,dl0
      real*8 dl1,dlodef,dlpr,dt12,dvv,fadl,ftu,ftu0
      real*8 t2,tdef,timin,tl1,tl2,tl2a,tm1,tmin,tsub
      real*8 tti,u,varf,xhyf,alos,teinit
      real*8 popul(mxion, mxelem)
      real*8 maxdloss
      parameter (maxdloss=(1.d0-1.d-6))
c
      integer*4 iconsis,isis,jok,n,nf
c
c
      real*8 arctanh
      arctanh(u)=0.5d0*dlog((1.d0+u)/(1.d0-u))
c
      if ((nmod.ne.'EQUI').and.(nmod.ne.'TIM')) then
        write (*,10) nmod
   10 format(/' MODE IMPROPERLY SET FOR SUBR. TEEQUI2 : ',a4)
        stop
      endif
c
c    Fudge which sets everything constant once T =30 K
c
      delmin=4.d-4
      nf=6
      tmin=10.d0
      timin=30.0d0
      ftu0=0.0d0
      isis=0
c
c refactor to stop repeat testing nmod
c
      if (nmod.eq.'EQUI') then
c
c    ***GUESS AN IMPROVED VALUE FOR THE TEMPERATURE
c
      teinit=dmax1(timin,tei)
      tef=teinit
      tm1=teinit
c
      tl1=dlog(tm1)
      call equion (tm1, edens, hdens)
      call cool (tm1, edens, hdens)
c
      dl0=dlos
      alos=dabs(dlos)
c
      dlos=dsign(dmin1(alos,maxdloss),dlos)
      if (alos.gt.0.06d0) nf=nf+2
      if (alos.gt.0.20d0) nf=nf+3
c
      c1=arctanh(dlos)
c
      tl2=tl1-dlos
      t2=dmax1(dexp(tl2),4.0d0*tmin)
      tl2=dlog(t2)
      tti=t2
      tdef=tm1
c
      dl1=dlos
      dlodef=dl1
      varf=0.02d0+(alos**0.70d0)
      jok=0
c
c     ***USING 2 TEMP. (TM1,T2)  AND 2 FRACT. RESID. (DLOS1,DLOS2)
c     IT FITS THE FUNCTION : ARCTANH(DLOS)=B+A*LN(T)
c     NEXT VALUE OF T=DEXP(-B/A)
c
      do n=1,nf

        dlpr=dlos
        call equion (t2, edens, hdens)
        call cool (t2, edens, hdens)
c
        alos=dabs(dlos)
        dlos=dsign(dmin1(alos,maxdloss),dlos)
        if (alos.le.dabs(dlodef)) then
          dlodef=dlos
          tdef=t2
        endif
c
        tef=t2
        alos=dabs(dlos)
        if (alos.lt.1.d-6) return
c
        fadl=dmin1(100.0d0,dmax1(0.5d0,dabs(dlpr)/(alos+1.d-5)))
c
        delexi=5.0d-5+(1.0d-5*dmin1(5.d0,6.d-1*fadl))
        if (alos.lt.5.d-5) jok=jok+1
        if ( ((alos.lt.delexi).or.(t2.lt.tmin))
     &   .or.((jok.gt.4).and.(alos.lt.(dble(jok)*0.6d-5)))
     &     ) goto 30
c
c didnt converge = retry...
c
        c2=arctanh(dlos)
        csub=c2-c1
        tsub=tl2-tl1
        if (dabs(tsub).lt.1.0d-16) tsub=dsign(1.0d-16,tsub)
c
c     **DOES NOT ALLOW  A  TO BE NEGATIVE
c
        a=dabs(csub/tsub)
        b=c1-(a*tl1)
        cc=c1
        c1=c2
        tl1=tl2
        tm1=t2
        tl2a=-(b/(dmax1(a,dabs(b)*0.05d0)))
        dt12=tl2a-tl1
        tl2=tl1+dsign(dmin1(varf,dabs(dt12)),dt12)
        t2=dexp(tl2)
        ftu=(t2-tm1)/dmax1(t2,tm1,tmin*0.1d0)
c
        iconsis=idint(((1.1d0*ftu0)*ftu)/(1.d-20+dabs(ftu0*ftu)))
c
        ftu0=ftu
        dvv=dabs(tl2-tl1)
c
        if (iconsis.lt.0) then
          isis=isis+1
          varf=varf/(2.0d0+(1.d0/(isis*isis)))
          tl2=tl1+dsign(dmin1(varf,dabs(dt12)),dt12)
          t2=dexp(tl2)
          goto 20
        endif
        if (iconsis.gt.0) then
          varf=dmin1(1.1d0,
     &     dmax1(5.0d-4,(1.3d0*varf)*
     &     (dmax1(1.5d-1,dmin1(1.d0,dvv/varf))**0.2d0)))
        endif
   20 continue
c n=1,nf
      enddo
c
c     ***IF CONVERGENCE POOR , USES TEMP. WITH MIN. ABS(DLOS)
c
   30 if (alos.lt.0.01d0) goto 40
      if (expertmode.gt.0) then
      write(*,*) 'DLOS CONVERGENCE POOR <30K ',dl0,teinit,
     &            dlos,t2,dlodef,tdef
      endif
      t2=tdef
   40 continue
c
c     ***USES FINAL TEMPERATURE
c
      if (alos.gt.(2.0d0*dabs(dlodef))) t2=tdef
      tef=dmax1(t2,10.d0)
c
      call equion (tef, edens, hdens)
      call cool (tef, edens, hdens)

      return
c
      endif

      if (nmod.eq.'TIM') then
        call copypop (pop, popul)
c
c    ***GUESS AN IMPROVED VALUE FOR THE TEMPERATURE
c
c      te0 = dmax1(timin,tei,dsign(2.d4,-tei))
      teinit=dmax1(timin,tei)
      tef=teinit
      tm1=teinit
c
      tl1=dlog(tm1)
      call timion (tm1, edens, hdens, xhyf, tstep)
      call cool (tm1, edens, hdens)
c
      dl0=dlos
c
c      if (dabs(dlos).lt.delmin) goto 500
c
      if (dabs(dabs(dlos)-1.0d0).lt.1.d-6) dlos=dsign(1.0d0-1.d-6,dlos)
      if (dabs(dlos).gt.0.06d0) nf=nf+2
      if (dabs(dlos).gt.0.20d0) nf=nf+3
      c1=arctanh(dlos)
      tl2=tl1-dlos
      t2=dmax1(dexp(tl2),4.0d0*tmin)
      tl2=dlog(t2)
      tti=t2
      dl1=dlos
      tdef=tm1
      dlodef=dl1
      varf=0.02d0+(dabs(dl1)**0.70d0)
      jok=0
c
c     ***USING 2 TEMP. (TM1,T2)  AND 2 FRACT. RESID. (DLOS1,DLOS2)
c     IT FITS THE FUNCTION : ARCTANH(DLOS)=B+A*LN(T)
c     NEXT VALUE OF T=DEXP(-B/A)
c
      do n=1,nf
        dlpr=dlos
        call copypop (popul, pop)
        call timion (t2, edens, hdens, xhyf, tstep)
        call cool (t2, edens, hdens)
        if (dabs(dabs(dlos)-1.0d0).lt.1.d-6) dlos=dsign(1.0d0-1.d-6,
     &   dlos)
        if (dabs(dlos).le.dabs(dlodef)) then
          dlodef=dlos
          tdef=t2
        endif
c
        tef=t2
        if (dabs(dlos).lt.1.d-6) return
c
        fadl=dmin1(100.0d0,dmax1(0.5d0,dabs(dlpr)/(dabs(dlos)+1.d-5)))
c
        delexi=5.0d-5+(1.0d-5*dmin1(5.d0,6.d-1*fadl))
        if (dabs(dlos).lt.5.d-5) jok=jok+1
        if (((dabs(dlos).lt.delexi).or.(t2.lt.tmin)).or.((jok.gt.4)
     &   .and.(dabs(dlos).lt.(dble(jok)*0.6d-5)))) goto 130
c
c didnt converge = retry...
c
        c2=arctanh(dlos)
        csub=c2-c1
        tsub=tl2-tl1
        if (dabs(tsub).lt.1.0d-16) tsub=dsign(1.0d-16,tsub)
c
c     **DOES NOT ALLOW  A  TO BE NEGATIVE
c
        a=dabs(csub/tsub)
        b=c1-(a*tl1)
        cc=c1
        c1=c2
        tl1=tl2
        tm1=t2
        tl2a=-(b/(dmax1(dabs(a),dabs(b)/20.0d0)*dsign(1.d0,a)))
        dt12=tl2a-tl1
        tl2=tl1+dsign(dmin1(varf,dabs(dt12)),dt12)
        t2=dexp(tl2)
        ftu=(t2-tm1)/dmax1(t2,tm1,tmin/10.d0)
        iconsis=idint(((1.1d0*ftu0)*ftu)/(1.d-20+dabs(ftu0*ftu)))
        ftu0=ftu
c
        dvv=dabs(tl2-tl1)
        if (iconsis.lt.0) then
          isis=isis+1
          varf=varf/(2.0d0+(1.d0/(isis*isis)))
          tl2=tl1+dsign(dmin1(varf,dabs(dt12)),dt12)
          t2=dexp(tl2)
        else if (iconsis.gt.0) then
          varf=dmin1(1.1d0,dmax1(5.0d-4,(1.3d0*varf)*(dmax1(1.5d-1,
     &     dmin1(1.d0,dvv/varf))**0.2d0)))
        endif
       enddo
c
c     ***IF CONVERGENCE POOR , USES TEMP. WITH MIN. ABS(DLOS)
c
  130 if (dabs(dlos).lt.0.01d0) goto 140
      if (expertmode.gt.0) then
      write(*,*) 'TDLOS CONVERGENCE POOR <30K ',dl0,teinit,
     &            dlos,t2,dlodef,tdef
      endif
      t2=tdef
  140 continue
c
c     ***USES FINAL TEMPERATURE
c
      if (dabs(dlos).gt.(2.0d0*dabs(dlodef))) t2=tdef
      tef=dmax1(t2,10.d0)
      call copypop (popul, pop)
      call timion (tef, edens, hdens, xhyf, tstep)
      call cool (tef, edens, hdens)
c
      endif
c
      return
c
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
