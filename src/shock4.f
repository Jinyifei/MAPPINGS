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
      subroutine shock4 ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     SHOCK4: Shock model with explicit Rankine-Hugoiot solution for
c     each step.  Time steps based on fastest atomic, cooling or
c     photon absorbion timescales.
c
c     Full continuum and diffuse field, requires precalculated ionisation
c     input.
c
c     RSS 1992
c     RSS 2010 minor bug fixes and fixed logical unit collisions
c     RSS 2013 improved setup for slow shocks, minor bug fixes
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c           Variables
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      real*8 dr,drdw,drup,dvdw,dvup,frdw,ftime
      real*8 tdw,tlim,tup,xhii,bp0, bp1
      real*8 t, de, dh, dv, rad, wdilt0
      real*8 tt0,l0,l11,l12,l1,cmpf,ue0,ue1
      real*8 r0,p0,v0, tnloss,cspd,wmol,mb
      real*8 hfree, bmag, ve, en,el,ue,rdis,dva
      real*8 pop1(mxion, mxelem),totn,ionbar,abstime
      real*8 press, mu, rhotot,cltime,utime
      real*8 ptime, ctime, rtime, htime,stime,eqtime
      real*8 atimefrac,cltimefrac,abtimefrac,rdvol,irdvol,dvol
      real*8 timend,teq,dheq,tl0,tl1,tt1,netloss
      real*8 band1,band2,band3,band4,band5,band6,bandall,widnu
c
      real*8 meanion(mxelem),zi(mxelem)
c
      integer*4 ie,luop,lusp,lupb,lucl
      integer*4 count,step, np,i,j,lurt,ludy,lual,m,lupf
      integer*4 luions(4),idx1,idx2,idx3,idx4
c
c     time steps - non-standard so commented out
c
c      integer*4 nt0,nt1,time
c      real tarray(2)
c      real dtime,dtarr
c
      character*24 abundtitle
      character fn*64
      character filn(4)*64
      character specmode*4, rmod*4, imod*4, tsrmod*4,spmod*4
      character fl*64, lmod*4, tab*1, ilgg*4, tmod*4, linemod*4
      character fd*64, fr*64, fa*64, fsp*64, allmod*4, ratmod*4,ispo*4
      character pfx*32, sfx*4, caller*4,wmod*4,pollfile*12,vmod*4
      character cht*64,pht*64,clt*64,dynmod*4, mypfx*32, model*64
      character fpf*64, fpb*64, fcl*64, fclmod*4
c
      logical iexi,pseudo
c
c
c           Functions
c
      real*8 fcolltim,feldens,fphotim,fpressu,frectim2,frho
      real*8 fmua
      integer*4 mlen
c
c
c     set up logical unit numbers
c
      lual=20
      luop=21
      lurt=22
      ludy=23
      lusp=24
      lupf=25
      lupb=26
      lucl=27
c
c      nt1 = time()
c      nt0 = nt1
c
      m=0
c
      ieln=4
      do i=1,ieln
        luions(i)=28+i
      enddo
c
      fl=' '
      pfx='shckn'
      sfx='sh4'
      call newfile (pfx, 4, sfx, 3, fn)
      fl=fn(1:12)
c
      open (luop,file=fl,status='NEW')
c
c
c     zero arrays and define modes: all ions, no on-thespot,
c     full continuum
c     calculations..
c
      call zer
      call zerbuf
c
      tab=','
      jspot='N'
      jcon='Y'
      jspec='N'
      ispo='SII'
      allmod='N'
      fclmod='N'
      tsrmod='N'
      ratmod='N'
      dynmod='N'
      vmod='NONE'
      mypfx='psend'
      specmode='DW'
      jgeo='P'
      jtrans='LODW'
      jden='B'
      pseudo=.false.
      model='Shock 4'
      rdvol=1.0d16
      irdvol=1.d0/rdvol
      vunilog=dlog10(rdvol)
c
   10 format(a)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     INTRO - Define Input Parameters
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
   20 format(///,
     & ' SHOCK 4 model selected:',/,
     & ' Shock code with natural coordinates.',/,
     & ' ********************************************************')
      write (*,20)
c
c     get ionisation balance to work with...
c
      model='pre-ionisation'
      call popcha (model)
      model='Shock 4'
c
c     set up current field conditions
c
      call photsou (model)
c
c     Shock model preferences
c
c
   30 format(///,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' Setting the shock conditions',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,30)
c
   40 format(//,
     & ' Choose Shock Jump Paramter:',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    T  : Shock jump in terms of Temperature jump',/,
     & '    V  : Shock jump in terms of flow Velocity.',//,
     & ' :: ',$)
c
   50 write (*,40)
      read (*,10) ilgg
      ilgg=ilgg(1:1)
      if (ilgg.eq.'T') ilgg='t'
      if (ilgg.eq.'V') ilgg='v'
c
      if ((ilgg.ne.'t').and.(ilgg.ne.'v')) goto 50
c
c     Shock in term of flow velocity
c
      if (ilgg.eq.'v') then
   60   format(//,
     & ' Give Preshock Conditions:',/,
     & '  T (K), dh (N), v (cm/s), B, Geo. dilution',/,
     & ' (T<10 taken as a log, dh <= 0 taken as a log),',/,
     & ' (B in micro Gauss, Dilution factor <= 0.5)',/,
     & ' : ')
        write (*,60)
        read (*,*) t,dh,ve,bmag,wdil
c
        dr=1.d0
c
        if (t.le.10.d0) t=10.d0**t
        if (dh.le.0.d0) dh=10.d0**dh
        if (wdil.gt.0.5d0) wdil=0.5d0
        wdilt0=0.d0
c
        bmag=bmag*1.d-6
        vshoc=ve
        de=feldens(dh,pop)
c
c     fill in other default parameters
c
        ftime=0.d0
        tloss=0.d0
        rmod='NEAR'
c
        call rankhug (t, de, dh, ve, bmag, tloss, ftime)
        tm00=te0
c
      endif
c
c     Shock in terms of temp jump
c
      if (ilgg.eq.'t') then
c
   70   format(//,
     & ' Give Preshock Conditions:',/,
     & '  (T<10 taken as a log, dh <= 0 taken as a log)',/,
     & '  (B in micro Gauss, Dilution factor <= 0.5)',/,
     & ' : T (K), dh (N), B, Geo. dilution',/,
     & ' : ')
        write (*,70)
        read (*,*) te0,dh,bmag,wdil
c
        if (dr.le.0.d0) dr=1.d0
        if (wdil.gt.0.5d0) wdil=0.5d0
        bmag=bmag*1.d-6
c
   80   format(//,
     & ' Give Postshock Conditions:',/,
     & '  (T<10 taken as a log)',//,
     & ' : T (K)',/,
     & ' : ')
        write (*,80)
        read (*,*) te1
c
        if (te0.le.10.d0) te0=10.d0**te0
        if (te1.le.10.d0) te1=10.d0**te1
c
        bm0=bmag
c
c        write(*,*) 'Calling velshock...'
        call velshock (dh, pop(2,1), te0, te1, bmag)
c        write(*,*) 'Back From velshock: te1 depo dhpo vel0'
c     &  , te1, depo, dhpo, vel0
c
        de0=feldens(dh,pop)
        de1=feldens(dhpo,pop)
        dh0=dh
        dh1=dhpo
        vel0=vshoc
        vel1=vpo
        rho0=frho(de0,dh0)
        rho1=frho(de1,dh1)
        pr0=fpressu(te0,dh0,pop)
        pr1=fpressu(te1,dh1,pop)
        bm1=bm0*rho1/rho0
        tm00=te0
      endif
c
      bp0=(bm0*bm0)/epi
      bp1=(bm1*bm1)/epi
c
   90   format(//' Shock Properties',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '   Velocity:',1pg12.5,' km/s',//,
     & '   Preshock ne:',1pg12.5,' cm^-3',/,
     & '   Preshock nH:',1pg12.5,' cm^-3',/,
     & '   Preshock d :',1pg12.5,' g/cm^-3',/,
     & '   Preshock P :',1pg12.5,' dyne/cm^2',/,
     & '   Preshock T :',1pg12.5,' K',/,
     & '   Preshock B :',1pg12.5,' microGauss',/,
     & '   Preshock BP:',1pg12.5,' dyne/cm^2',//,
     & '   Postshock ne:',1pg12.5,' cm^-3',/,
     & '   Postshock nH:',1pg12.5,' cm^-3',/,
     & '   Postshock d :',1pg12.5,' g/cm^-3',/,
     & '   Postshock P :',1pg12.5,' dyne/cm^2',/,
     & '   Postshock T :',1pg12.5,' K',/,
     & '   Postshock B :',1pg12.5,' microGauss',/,
     & '   Postshock BP:',1pg12.5,' dyne/cm^2',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
      write (*,90) vel0*1d-5,de,dh,rho0,pr0,te0,bm0*1.d6,bp0,de1,dhpo,
     &rho1,pr1,te1,bm1*1.d6,bp1
c
      if (alphacoolmode.eq.1) then
  100  format(//,
     & ' Powerlaw Cooling enabled  Lambda T6 ^ alpha :',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    Give index alpha, Lambda at 1e6K',/,
     & '    (Lambda<0 as log)',/,
     & ' :: ',$)
        write (*,100)
        read (*,*) alphaclaw,alphac0
        if (alphac0.lt.0.d0) alphac0=10.d0**alphac0
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Diffuse field interaction
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      photonmode=1
c
  110 format(//,
     & ' Choose Diffuse Field Option :',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    F  : Full diffuse field interaction (Default).',/,
     & '    Z  : Zero diffuse field interaction.',/,
     & ' :: ',$)
      write (*,110)
  120 read (*,10) ilgg
      ilgg=ilgg(1:1)
c
      if (ilgg.eq.'z') ilgg='Z'
      if (ilgg.eq.'f') ilgg='F'
c
      if ((ilgg.ne.'Z').and.(ilgg.ne.'F')) goto 120
c
      if (ilgg.eq.'Z') photonmode=0
      if (ilgg.eq.'F') photonmode=1
      photofraction=1.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  130 format(//,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' Calculation Settings ',/,
     & ' ,::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,130)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Set up time step limits
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  140 format(//,
     & ' Choose a Time Step Behaviour :',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Auto. time steps, based on Atomic timescales.',/,
     & '    M  : Choose a Maximum time step, Auto otherwise.',/,
     & '    N  : Choose a miNimum time step, Auto otherwise.',/,
     & '    S  : Strict preset timestep. (not recomended)',//,
     & ' :: ',$)
c
  150 write (*,140)
      read (*,10) tmod
      call toup (tmod(1:1), tmod)
c
      if ((tmod.ne.'A').and.(tmod.ne.'M').and.(tmod.ne.'N')
     &.and.(tmod.ne.'S')) goto 150
c
      atimefrac=0.2d0
      cltimefrac=0.2d0
      abtimefrac=0.2d0
c
      if (tmod.ne.'S') then
  160    format(//,
     & ' Give timescale fractions:',/,
     & ' ( 0 < dtau < 1 )',/,
     & ' ( recommend: 0.05 < dtau < 0.25 )',/,
     & ' : atomic, cooling, absorbsion',/,
     & ' : ')
  170   write (*,160)
        read (*,*) atimefrac,cltimefrac,abtimefrac
c
        if (atimefrac.le.0.d0) goto 170
        if (cltimefrac.le.0.d0) goto 170
        if (abtimefrac.le.0.d0) goto 170
c
        if (atimefrac.ge.1.d0) goto 170
        if (cltimefrac.ge.1.d0) goto 170
        if (abtimefrac.ge.1.d0) goto 170
c
      endif
c
      utime=0.d0
      if (tmod.ne.'A') then
  180   format(//,
     & ' Give the time step:',/,
     & ' ( time < 100 taken as a log)',//,
     & ' : time (sec)',/,
     & ' : ')
        write (*,180)
        read (*,*) utime
        if (utime.le.100.d0) utime=10.d0**utime
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  190 format(//,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Boundry Conditions ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,190)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Choose ending conditions
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  200 format(/,
     & '  Choose Ending :',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Standard ending, 1% weighted ionisation.',/,
     & '    B  : Species Ionisation limit.',/,
     & '    C  : Temperature limit.',/,
     & '    D  : Distance limit.',/,
     & '    E  : Time limit.',/,
     & '    F  : Thermal Balance limit.',/,
     & '    G  : Heating limit.',/,
     & ' :: ',$)
c
  210 write (*,200)
      read (*,10) jend
      call toup (jend(1:1), jend)
c
      if ((jend.ne.'A').and.(jend.ne.'B').and.(jend.ne.'C')
     &.and.(jend.ne.'D').and.(jend.ne.'E').and.(jend.ne.'F')
     &.and.(jend.ne.'G')) goto 210
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Secondary info:
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (jend.eq.'B') then
  220   format(//,
     & ' Give Atom, Ion and limit fraction: ')
        write (*,220)
        read (*,*) ielen,jpoen,fren
      endif
      if (jend.eq.'C') then
  230   format(//,
     & ' Give final temperature (K > 10, log <= 10): ')
        write (*,230)
        read (*,*) tend
        if (tend.le.10.d0) tend=10.d0**tend
      endif
      if (jend.eq.'D') then
  240   format(//,
     & ' Give final distance (cm > 100, log<=100): ')
        write (*,240)
        read (*,*) diend
        if (diend.le.100.d0) diend=10.d0**diend
      endif
      if (jend.eq.'E') then
  250   format(//,
     & ' Give time limit (s > 100, log<=100): ')
        write (*,250)
        read (*,*) timend
        if (timend.le.100.d0) timend=10.d0**timend
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  260 format(//,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Output Requirements ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,260)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     default monitor elements
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      iel(1)=zmap(1)
      iel(2)=zmap(2)
      iel(3)=zmap(6)
      iel(4)=zmap(8)
      mypfx='psend'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    Output options menu
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  270 format(//,
     & ' Choose output settings : ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Standard output. ',/,
     & '    B  : Standard plus ion balance files.',/,
     & '    C  : Standard plus dynamics file.',/,
     & '    D  : Standard plus rates file.',/,
     & '    E  : Standard plus final down stream field.',/,
     & '    F  : Standard plus upstream field at each step.',/,
     & '    J  : Cooling Components by Elements file.',/,
     & '       :',/,
     & '    G  : B + E',/,
     & '    H  : B + F',/,
     & '       :',/,
     & '    I  : Everything',//,
     & ' :: ',$)
  280 write (*,270)
      read (*,10) ilgg
      call toup (ilgg(1:1), ilgg)
c
      if ((ilgg.ne.'A').and.(ilgg.ne.'B').and.(ilgg.ne.'C')
     &.and.(ilgg.ne.'D').and.(ilgg.ne.'E').and.(ilgg.ne.'F')
     &.and.(ilgg.ne.'G').and.(ilgg.ne.'H').and.(ilgg.ne.'I')
     &.and.(ilgg.ne.'J')) goto 280
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Upstream fields lmod = Y/N
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      lmod='N'
      if ((ilgg.eq.'F').or.(ilgg.eq.'H').or.(ilgg.eq.'I')) then
        lmod='Y'
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     F-Lambda plots, ionising and optical  jspec = 'Y'/'N'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      jspec='N'
      if ((ilgg.eq.'E').or.(ilgg.eq.'G').or.(ilgg.eq.'I')) then
        jspec='Y'
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     timescales and rates file
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      ratmod='N'
      if ((ilgg.eq.'D').or.(ilgg.eq.'I')) then
        ratmod='Y'
        pfx='rates'
        sfx='sh4'
        call newfile (pfx, 5, sfx, 3, fn)
        fr=fn(1:13)
        open (lurt,file=fr,status='NEW')
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Cooling Components File, fclmod
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      fclmod='N'
      if ((ilgg.eq.'J').or.(ilgg.eq.'I')) then
        fclmod='Y'
        pfx='cc'
        sfx='csv'
        fcl=' '
        call newfile (pfx, 2, sfx, 3, fn)
        fcl=fn(1:10)
        open (lucl,file=fcl,status='NEW')
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     flow dynamics file, dynmod
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      dynmod='N'
      if ((ilgg.eq.'C').or.(ilgg.eq.'I')) then
        dynmod='Y'
        pfx='dyn'
        sfx='sh4'
        fd=' '
        call newfile (pfx, 3, sfx, 3, fn)
        fd=fn(1:11)
        open (ludy,file=fd,status='NEW')
      endif
c
      pfx='spec'
      sfx='csv'
      fsp=' '
      call newfile (pfx, 4, sfx, 3, fn)
      fsp=fn(1:12)
      open (lusp,file=fsp,status='NEW')
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Ion balance files tsrmod, allmod
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      allmod='N'
      tsrmod='N'
c
      if ((ilgg.eq.'B').or.(ilgg.eq.'G').or.(ilgg.eq.'H').or.(ilgg.eq.'I
     &')) then
c
        if ((ilgg.eq.'B').or.(ilgg.eq.'G').or.(ilgg.eq.'H')) then
c
  290    format(//,
     & ' Record all ions file (Y/N)?: ')
          write (*,290)
          read (*,10) allmod
          allmod=allmod(1:1)
          if (allmod.eq.'y') allmod='Y'
        endif
c
        if (ilgg.eq.'I') allmod='Y'
c
        if (allmod.eq.'Y') then
          pfx='allion'
          sfx='sh4'
          call newfile (pfx, 6, sfx, 3, fn)
          fa=fn(1:14)
          open (lual,file=fa,status='NEW')
        endif
c
        if (ilgg.eq.'B') tsrmod='Y'
        if (ilgg.eq.'I') tsrmod='Y'
        if (ilgg.eq.'G') tsrmod='Y'
c       if (ilgg.eq.'B') then
c 300    format(//,
c    & ' Record particular ion balances (Y/N)?: ')
c         write (*,300)
c         read (*,10) tsrmod
c         tsrmod=tsrmod(1:1)
c         if (tsrmod.eq.'y') tsrmod='Y'
c       endif
c
c
        if (tsrmod.eq.'Y') then
  300      format(//,
     &     ' Give 4 elements by atomic number: ')
          write (*,300)
          read (*,*) idx1,idx2,idx3,idx4
          idx1=max(min(idx1,atypes),1)
          idx2=max(min(idx2,atypes),1)
          idx3=max(min(idx3,atypes),1)
          idx4=max(min(idx4,atypes),1)
          iel(1)=zmap(idx1)
          iel(2)=zmap(idx2)
          iel(3)=zmap(idx3)
          iel(4)=zmap(idx4)
c         read (*,*) iel(1),iel(2),iel(3),iel(4)
c         iel(1)=zmap(iel(1))
c         iel(2)=zmap(iel(2))
c         iel(3)=zmap(iel(3))
c         iel(4)=zmap(iel(4))
        endif
      endif
c
c     get final field file prefix
c
  310 format (a8)
  320 format(//,
     & ' Give a prefix for final field file (5chars): ')
      write (*,320)
      read (*,310) mypfx
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     get screen display mode
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
  330 format(//,
     & ' Choose runtime screen display:',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Standard display ',/,
     & '    B  : Detailed Slab display.',/,
     & '    C  : Full Display',/,
     & '       : (Full slab display + timescales).',/,
     & ' :: ',$)
      write (*,330)
      read (*,10) ilgg
      call toup (ilgg(1:1), ilgg)
c
      vmod='NONE'
c
      if (ilgg.eq.'a') ilgg='A'
      if (ilgg.eq.'b') ilgg='B'
      if (ilgg.eq.'c') ilgg='C'
c
      if (ilgg.eq.'A') vmod='MINI'
      if (ilgg.eq.'B') vmod='SLAB'
      if (ilgg.eq.'C') vmod='FULL'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     get runname
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
  340 format(//,
     & ' Give a name/code for this run: ')
      write (*,340)
      read (*,'(a)') runname
      np=mlen(runname)
      runname=runname(1:np)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Write Headers
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     write ion balance files if requested
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (tsrmod.eq.'Y') then
        do i=1,ieln
          ie=iel(1)
          if (i.eq.1) ie=iel(1)
          if (i.eq.2) ie=iel(2)
          if (i.eq.3) ie=iel(3)
          if (i.eq.4) ie=iel(4)
          fn=' '
          pfx=elem(ie)
          sfx='csv'
          call newfile (pfx, elem_len(ie), sfx, 3, fn)
          filn(i)=fn(1:(elem_len(ie)+3+5))
        enddo
c
        do i=1,ieln
          open (luions(i),file=filn(i),status='NEW')
        enddo
c
        do i=1,ieln
          write (luions(i),*) fl,', ',runname
c
  350 format('Step [1], <X> [2], dX [3], <T> [4]',31(',',a6,'[',i2,']'))
          if (i.eq.1) then
            write (luions(i),350) (rom(j),j+4,j=1,maxion(iel(1)))
          endif
          if (i.eq.2) then
            write (luions(i),350) (rom(j),j+4,j=1,maxion(iel(2)))
          endif
          if (i.eq.3) then
            write (luions(i),350) (rom(j),j+4,j=1,maxion(iel(3)))
          endif
          if (i.eq.4) then
            write (luions(i),350) (rom(j),j+4,j=1,maxion(iel(4)))
          endif
c
        enddo
c
        do i=1,ieln
          close (luions(i))
        enddo
c
c     end trsmod = 'Y'
      endif
c
      fpb=' '
      pfx='bands'
      sfx='sh4'
      call newfile (pfx, 5, sfx, 3, fn)
      fpb=fn(1:13)
      open (lupb,file=fpb,status='NEW')
c
c     Title
c
  360 format(/
     & ' SHOCK4: Explicit Rankine-Hugoniot shock code: ',/,
     & ' ============================================',/,
     & ' Diffuse Field, Full Continuum Calculations.',/,
     & ' Calculated by MAPPINGS V ',a12)
      write (*,360) theversion
      write (luop,360) theversion
      write (lusp,360) theversion
      write (lupb,360) theversion
      if (ratmod.eq.'Y') write (lurt,360) theversion
      if (dynmod.eq.'Y') write (ludy,360) theversion
      if (allmod.eq.'Y') write (lual,360) theversion
      if (fclmod.eq.'Y') write (lucl,360) theversion
  370 format(//' Run  :',a,/
     &         ' File :',a)
      write (luop,370) runname,fl
      write (lusp,370) runname,fl
      write (lupb,370) runname,fl
      if (ratmod.eq.'Y') write (lurt,370) runname,fl
      if (dynmod.eq.'Y') write (ludy,370) runname,fl
      if (allmod.eq.'Y') write (lual,370) runname,fl
      if (fclmod.eq.'Y') write (lucl,370) runname,fl
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Write Model Parameters
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
  380 format(//,
     & ' Model Parameters:',/,
     & ' =================',//,
     & ' Abundances     : ',a128,/,
     & ' Pre-ionisation : ',a128,/,
     & ' Photon Source  : ',a128)
  390 format(/
     & ' Charge Exchange: ',a12,/,
     & ' Photon Mode    : ',a12,/,
     & ' Collision calcs: ',a12)
  400 format(/
     & ' Charge Exchange: ',a12,/,
     & ' Photon Mode    : ',a12,/,
     & ' Collision calcs: ',a12,/,
     & ' Electron Kappa : ',1pg11.4)
  410 format(//
     & ' ',t2,'Jden',t9,'Jgeo',t16,'Jtrans',
     &            t23,'Jend',t29,'Ielen',t35,
     & 'Jpoen',t43,'Fren',t51,'Tend',t57,'DIend',t67,
     & 'TAUen',t77,'Jeq',t84,'Teini')
  420 format('  ',4(a4,3x),2(i2,4x),0pf6.4,0pf6.0,
     &           2(1pg10.3),3x,a4,0pf7.1)
  430 format(//
     & ' Photon Source'/
     & ' ============='/)
  440 format(/' MOD',t7,'Temp.',t16,'Alpha',t22,'Turn-on',t30,'Cut-off'
     &,t38,'Zstar',t47,'FQHI',t56,'FQHEI',t66,'FQHEII')
  450 format(' ',a2,1pg10.3,4(0pf7.2),1x,3(1pg10.3))
c
      write (luop,90) vel0*1.d-5,de,dh,rho0,pr0,te0,bm0*1.d6,bp0,de1,
     &dhpo,rho1,pr1,te1,bm1*1.d6,bp1
c
      write (lupb,90) vel0*1.d-5,de,dh,rho0,pr0,te0,bm0*1.d6,bp0,de1,
     &dhpo,rho1,pr1,te1,bm1*1.d6,bp1
c
      if (ratmod.eq.'Y') then
        write (lurt,90) vel0*1.d-5,de,dh,rho0,pr0,te0,bm0*1.d6,bp0,de1,
     &   dhpo,rho1,pr1,te1,bm1*1.d6,bp1
      endif
c
      if (dynmod.eq.'Y') then
        write (ludy,90) vel0*1.d-5,de,dh,rho0,pr0,te0,bm0*1.d6,bp0,de1,
     &   dhpo,rho1,pr1,te1,bm1*1.d6,bp1
      endif
c
      if (allmod.eq.'Y') then
        write (lual,90) vel0*1.d-5,de,dh,rho0,pr0,te0,bm0*1.d6,bp0,de1,
     &   dhpo,rho1,pr1,te1,bm1*1.d6,bp1
      endif
c
      if (fclmod.eq.'Y') then
        write (lucl,90) vel0*1.d-5,de,dh,rho0,pr0,te0,bm0*1.d6,bp0,de1,
     &   dhpo,rho1,pr1,te1,bm1*1.d6,bp1
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     abundances file header
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write (luop,380) abnfile,ionsetup,srcfile
c
      abundtitle=' Initial Abundances :'
      do i=1,atypes
        zi(i)=zion0(i)*deltazion(i)
      enddo
      call dispabundances (luop, zi, abundtitle)
c
      abundtitle=' Gas Phase Abundances :'
      call dispabundances (luop, zion, abundtitle)
c
      write (lupb,380) abnfile,ionsetup,srcfile
      if (ratmod.eq.'Y') write (lurt,380) abnfile,ionsetup,srcfile
      if (dynmod.eq.'Y') write (ludy,380) abnfile,ionsetup,srcfile
      if (allmod.eq.'Y') write (lual,380) abnfile,ionsetup,srcfile
      if (fclmod.eq.'Y') write (lucl,380) abnfile,ionsetup,srcfile
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      cht='New Set'
      if (chargemode.eq.2) cht='Disabled'
      if (chargemode.eq.1) cht='Old Set'
      pht='Normal'
      if (photonmode.eq.0) pht='Zero Field, Decoupled'
      clt='Dere 2007 Collisions'
      if (collmode.eq.1) clt='Old A&R Collision Methods'
      if (collmode.eq.1) clt='LMS Collision Methods'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (usekappa) then
        write (luop,400) cht,pht,clt,kappa
      else
        write (luop,390) cht,pht,clt
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (luop,410)
      write (luop,420) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &diend,tauen,tmod,tm00
      write (luop,430)
      write (luop,440)
      write (luop,450) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
      write (lupb,390) cht,pht,clt
      write (lupb,410)
      write (lupb,420) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &diend,tauen,tmod,tm00
      write (lupb,430)
      write (lupb,440)
      write (lupb,450) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
      if (ratmod.eq.'Y') then
        write (lurt,390) cht,pht,clt
        write (lurt,410)
        write (lurt,420) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &   diend,tauen,tmod,tm00
        write (lurt,430)
        write (lurt,440)
        write (lurt,450) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
      endif
c
      if (dynmod.eq.'Y') then
        write (ludy,390) cht,pht,clt
        write (ludy,410)
        write (ludy,420) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &   diend,tauen,tmod,tm00
        write (ludy,430)
        write (ludy,440)
        write (ludy,450) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
      endif
c
      if (allmod.eq.'Y') then
c
        write (lual,390) cht,pht,clt
        write (lual,410)
        write (lual,420) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &   diend,tauen,tmod,tm00
        write (lual,430)
        write (lual,440)
        write (lual,450) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
      endif
c
      if (fclmod.eq.'Y') then
c
        write (lucl,390) cht,pht,clt
        write (lucl,410)
        write (lucl,420) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &   diend,tauen,tmod,tm00
        write (lucl,430)
        write (lucl,440)
        write (lucl,450) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Shock parameters
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
  460 format(//,
     & ' Jump Conditions:',/,
     & ' ================')
      write (luop,460)
      write (lupb,460)
      write (lusp,460)
      if (ratmod.eq.'Y') write (lurt,460)
      if (dynmod.eq.'Y') write (ludy,460)
      if (allmod.eq.'Y') write (lual,460)
      if (fclmod.eq.'Y') write (lucl,460)
c
  470 format(//
     & ' T1',1pg14.7,' V1',1pg14.7,
     & ' RH1',1pg14.7,' P1',1pg14.7,' B1',1pg14.7/
     & ' T2',1pg14.7,' V2',1pg14.7,
     & ' RH2',1pg14.7,' P2',1pg14.7,' B2',1pg14.7)
c
      dr=0.d0
      dv=vel1-vel0
c
      write (*,470) te0,vel0,rho0,pr0,bm0,te1,vel1,rho1,pr1,bm1
      write (luop,470) te0,vel0,rho0,pr0,bm0,te1,vel1,rho1,pr1,bm1
      write (lupb,470) te0,vel0,rho0,pr0,bm0,te1,vel1,rho1,pr1,bm1
      write (lusp,470) te0,vel0,rho0,pr0,bm0,te1,vel1,rho1,pr1,bm1
      if (ratmod.eq.'Y') write (lurt,470) te0,vel0,rho0,pr0,bm0,te1,
     &vel1,rho1,pr1,bm1
      if (dynmod.eq.'Y') write (ludy,470) te0,vel0,rho0,pr0,bm0,te1,
     &vel1,rho1,pr1,bm1
      if (fclmod.eq.'Y') write (lucl,470) te0,vel0,rho0,pr0,bm0,te1,
     &vel1,rho1,pr1,bm1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      close (lusp)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      wdilt0=te0
      t=te0
      ve=vel0
      dr=1.0
      dv=ve/100.d0
      fi=1.d0
      rad=0.d0
      wdil=0.5d0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     get the electrons...
c
      de=feldens(dh,pop)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     calculate the radiation field and atomic rates
c
      call localem (t, de, dh)
c
      call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
c
      if (photonmode.ne.0) then
        call zetaeff (dh)
      endif
      call cool (t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  480 format(//,
     & ' Precursor Conditions and Ionisation State',/
     & ' =========================================',/)
      write (luop,480)
      write (lupb,480)
      if (fclmod.eq.'Y') write (lucl,480)
c
      if ((vmod.eq.'FULL').or.(vmod.eq.'SLAB')) then
        wmod='SCRN'
        call wmodel (luop, t, de, dh, dr, wmod)
      endif
c
      wmod='FILE'
      call wmodel (luop, t, de, dh, dr, wmod)
      call wmodel (lupb, t, de, dh, dr, wmod)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (ratmod.eq.'Y') then
c header line for model lines
        call wmodel (lurt, 0.d0, 0.0d0, 0.d0, 0.0d0, 'LOSH')
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call wionabal (luop, pop)
      call wionabal (lupb, pop)
      if (allmod.eq.'Y') call wionabal (lual, pop)
      if (fclmod.eq.'Y') call wionabal (lucl, pop)
c
      close (luop)
  490 format(17(a12,a1))
      write (lupb,490) 'Te',tab,'de',tab,'dh',tab,'en',tab,'XHI',tab,'FH
     &II',tab,'mu',tab,'Lambda',tab,'tloss',tab,'ff',tab,'B0.5-2.0keV',
     &tab,'B2.0-8.0keV',tab,'B0.5-8.0keV',tab,'B3.0-10.0eV',tab,'B1.0-2.
     &0keV',tab,'B2.0-3.0keV',tab,'Ball'
      close (lupb)
  500 format(//
     & 'Mean Zone Values'/
     & '================'/)
  510 format(10(a12,a1),30(a12,a1))
  520 format(10(a12,a1),30(a12,a1),30(1pg12.5,a1))
  530 format( '                                                ',
     & '                             ',
     & '                                                ',
     & '                             ',
     & '        ===================== Lambda Cooling Function',
     & ' and Element Components,',
     & ' Components Scale Approximately Linearly with Component',
     & ' Abundances ==========',
     & '=================================================',
     & '============================',
     & '=================================================',
     & '==============================')
  540 format( '==================================================',
     & '===========================',
     & '=================================================',
     & '============================',
     & '=================================================',
     & '============================',
     & '=================================================',
     & '============================',
     & '=================================================',
     & '============================',
     & '=================================================',
     & '============================',
     & '=================================================',
     & '============================',
     & '=================================================',
     & '============================',
     & '=================================================',
     & '============================',
     & '============================================')
      if (fclmod.eq.'Y') then
        write (lucl,500)
        write (lucl,530)
        write (lucl,540)
        write (lucl,510) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho '
     &   ,tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(n
     &_H^2)',tab,(elem(j),tab,j=1,atypes)
        write (lucl,520) '(K)',tab,'(/cm^3)',tab,'(/cm^3)',tab,'(/cm^3)'
     &   ,tab,'(g/cm^3)',tab,' ',tab,' ',tab,'(amu)',tab,'(erg/cm^3/s)',
     &   tab,'(erg cm^3/s)',tab,('(erg cm^3/s)',tab,j=1,atypes),
     &   (atwei(j),tab,j=1,atypes)
        write (lucl,540)
      endif
      if (ratmod.eq.'Y') close (lurt)
      if (dynmod.eq.'Y') close (ludy)
      if (allmod.eq.'Y') close (lual)
      if (fclmod.eq.'Y') close (lucl)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Begin Main Calculation
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      wdilt0=te1
      t=te1
      cmpf=rho1/rho0
      dh=dh*cmpf
      de=feldens(dh,pop)
      dr=1.d0
      ve=vel1
      vpo=vel1
      bmag=bm1
      bm0=bm1
      dv=ve*0.01d0
      fi=1.d0
      rad=0.d0
      wdil=0.d0
c
c     calculate the radiation field and atomic rates
c
      call localem (t, de, dh)
      call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
c
      if (photonmode.ne.0) then
        call zetaeff (dh)
      endif
c
      call cool (t, de, dh)
      netloss=(eloss-egain)
c
      en=zen*dh
c
      ue=gammaEOSU*(en+de)*rkb*t
      tnloss=tloss/(en*de)
c
      cspd=dsqrt(gammaEOS*pr1/rho1)
      wmol=rho1/(en+de)
      mu=fmua(de,dh)
c
      step=0
c
  550 format(//,
     & a4,a1,14(4x,a6,4x,a1))
  560 format(i4.3,a1,14(1pg13.6,a1))
c
  570 format(//
     & ' #',t9,'Te',t21,'ne',t33,'nH',t45,'ni',t57,
     & 'B',t69,'XHI'/t8,'Time',t22,'dt',t32,'Dist',t45,
     & 'dr',t57,'v',t67,'dlos'/)
  580 format (i4,6(1x,1pg11.4)/t4,6(1x,1pg11.4))
      open (luop,file=fl,status='OLD',access='APPEND')
      write (luop,550) 'Step',tab,'Dist.',tab,'Time',tab,'Te',tab,'de',
     &tab,'dh',tab,'en',tab,'mu',tab,'Lambda',tab,'Tloss',tab,'dlos',
     &tab,'XHI',tab,'XHII',tab,'Bbar',tab,'dr',tab
      write (luop,560) step,tab,dist(step+1),tab,timlps(step+1),tab,t,
     &tab,de,tab,dh,tab,en,tab,mu,tab,tloss/(dh*dh),tab,tloss,tab,dlos,
     &tab,pop(1,1),tab,pop(2,1),tab,bm0,tab,dr,tab
      close (luop)
c
      if (vmod.eq.'MINI') then
        write (*,570)
        write (*,580) step,t,de,dh,en,bm0,pop(1,1),timlps(step+1),ftime,
     &   dist(step+1),dr,veloc(step+1),dlos
      endif
c
      en=zen*dh
      press=(en+de)*rkb*t
      ue=gammaEOSU*press
c
c     effective cooling timescale, based on net loss
c
      cltime=dabs(ue/tloss)
c
      rhotot=frho(de,dh)
      wmol=rhotot/(en+de)
      mu=fmua(de,dh)
c
      hfree=bmag*bmag/(4.d0*pi*en)+0.5d0*(wmol*ve*ve)+2.5d0*(rkb*t)/mu
c
      htime=dabs(hfree/tloss)
c
      abstime=1.d0/epsilon
c
      ctime=fcolltim(de)
      rtime=frectim2(de)
      if (photonmode.ne.0) then
        ptime=fphotim()
        eqtime=(1.d0/ctime)+(1.d0/ptime)+(1.d0/rtime)
        stime=(1.d0/ctime)+(1.d0/ptime)-(1.d0/rtime)
      else
        eqtime=(1.d0/ctime)+(1.d0/rtime)
        stime=(1.d0/ctime)-(1.d0/rtime)
      endif
c
      eqtime=dabs(1.d0/eqtime)
      stime=dabs(1.d0/stime)
c
      ftime=1.d0/((1.d0/(stime*atimefrac))+(1.d0/(cltime*cltimefrac)))
c     &             +(1.d0/(abstime*abtimefrac)))
c
      if ((tmod.eq.'M').and.(ftime.gt.utime)) ftime=utime
      if ((tmod.eq.'N').and.(ftime.lt.utime)) ftime=utime
      if (tmod.eq.'S') ftime=utime
c
  590 format ( //
     & ' Tot. Internal :',1pg14.7,/,
     & ' Tot.loss rate :',1pg14.7,/' Eff.loss rate :',1pg14.7,/,
     & ' Enthaply time :',1pg14.7,/' Eff.Cool time :',1pg14.7,/,
     & ' Collis.  time :',1pg14.7,/' Recomb.  time :',1pg14.7,/,
     & ' Photo.   time :',1pg14.7,/' Atomic   time :',1pg14.7,/,
     & ' Equilib  time :',1pg14.7,/' Absorb.  time :',1pg14.7,/,
     & ' Choice   time :',1pg14.7/)
c
      if (vmod.eq.'FULL') then
        write (*,590) ue,tloss,tloss,htime,cltime,ctime,rtime,ptime,
     &   stime,eqtime,abstime,ftime
      endif
c
c      if (ratmod.eq.'Y') then
c        open (lurt,file=fr,status='OLD',access='APPEND')
c        write (lurt,610) ue,tloss,tloss,htime,cltime,ctime,rtime,ptime,
c     &   stime,eqtime,abstime,ftime
c        close (lurt)
c      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Setup Initial first step in post shock-front gas(#1)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      rmod='NEAR'
      call rankhug (t, de, dh, ve, bmag, tloss, ftime)
c
      dr=ftime*(vel0+vel1)*0.5d0
      dv=vel1-vel0
c
c      write(*,200) tloss,dr,dv
c
      step=0
c
c     init arrays first step
c
      xh(1)=0.d0
      xh(2)=pop(2,1)
      veloc(1)=0.d0
      veloc(2)=vel0
c
      te(1)=0.d0
      te(2)=te0
      dhy(1)=0.d0
      dhy(2)=dh
      dist(1)=0.0d0
      dist(2)=0.0d0
      deel(1)=0.d0
      deel(2)=de
      timlps(1)=0.0d0
c
c     prepare for time step in ions
c
c
c     record initial conditions, t0 and l0 and pop
c
      call copypop (pop, pop0)
c
      tt0=te0
      l0=tloss
      l12=0.d0
      l11=0.d0
      r0=rho0
      p0=pr0
      v0=vel0
      de0=de
      dh0=dh
      count=0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     SHOCK Iteration reentry point:
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  600 count=count+1
c
      call copypop (pop0, pop)
c
      cmpf=rho1/rho0
      dh=(dh0+dh1)*0.5d0
      de=feldens(dh,pop)
      t=(te1+te0)*0.5d0
      xhii=pop(2,1)
c
      call timion (t, de, dh, xhii, ftime)
c
      call copypop (pop, pop1)
c
c     after timion on the average t,de,dh, now
c     calculate new lossrate at te1,de1,dh1
c
c     calculate the radiation field and atomic rates
c
      call localem (t, de, dh)
      rad=dist(step+1)
      call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
      if (photonmode.ne.0) then
        call zetaeff (dh)
      endif
c
      t=te1
      dh=dh1
      de=feldens(dh,pop)
c
      call cool (t, de, dh)
c
c     record first guess
c
      l12=l11
      l11=tloss
      l1=dabs(1.d0-dabs(l11)/(epsilon+dabs(l12)))
c
c
c    test for pseudo equilibrium
c
c      if ((eqtime.le.stime).and.
c     &   (eqtime.le.cltime).and.
c     &   (eqtime.le.abstime*abtimefrac).and.
      if ((rtime.le.ctime).and.(ptime.le.ctime).and.(dlos.lt.0.01d0))
     &then
        if (count.gt.1) then
          te1=te0
          dh1=dh0
          vel1=vel0
          bm1=bm0
        endif
        goto 610
      endif
c
      tloss=(l11+l0)*0.5d0
c
c     allow convergence to relax as dlos->0
c
      tlim=(1.d-5)/(dabs(dlos)+epsilon)
c
c     if within limits go and write step
c
      if (l1.le.tlim) then
        write (*,*) '    Converged',l1
        call copypop (pop, pop1)
        call averinto (0.5d0, pop0, pop1, pop)
        t=(te0+te1)*0.5d0
        dh=(dh0+dh1)*0.5d0
        de=feldens(dh,pop)
        call cool (t, de, dh)
        goto 620
      endif
c
c     try 8 times then give up
c
      if (count.gt.7) then
c         count = 0
c         ftime = ftime*0.5d0
        write (*,*) '    Failed to converge',l1
        call copypop (pop, pop1)
        call averinto (0.5d0, pop0, pop1, pop)
        t=(te0+te1)*0.5d0
        dh=(dh0+dh1)*0.5d0
        de=feldens(dh,pop)
        call cool (t, de, dh)
        goto 620
      endif
c
      en=zen*dh+de
      press=en*rkb*t
      ue=gammaEOSU*press
c
      cltime=dabs(ue/tloss)
c
      if (ftime.gt.cltime) then
        ftime=cltime
      endif
c
      t=tt0
      dh=dh0
      de=feldens(dh,pop0)
      ve=v0
      bmag=bm0
c
      call copypop (pop1, pop)
c
      rmod='NEAR'
      call rankhug (t, de, dh, ve, bmag, tloss, ftime)
c
      dr=ftime*(vel0+vel1)*0.5d0
      dv=vel1-vel0
c
c 200  format(t4,4(1pg15.7,x))
c      write(*,200) tloss,ve,dv,vel1
c
c     otherwise continue with the normal NEQ
c     mode
c
      goto 600
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     pseudo equilibrium calculations for case where
c     heating and cooling very nearly match and extrapolation
c     based on net cooling rate is unstable....
c     = photoionized post-shock zone
c
c     pseudo equilibrium entry point
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
  610 continue
c
      write (*,*) 'Equilibrium'
c
      pseudo=.true.
c
      count=count+1
c
      call copypop (pop0, pop)
c
      dh=dh1
      de=feldens(dh,pop)
c
c     initial internal energy /unit mass
c
      en=zen*dh
      ue0=gammaEOSU*(en+de)*rkb*te1
c
      tt0=te1
      t=te1
c
      imod='TIM'
      call teequi2 (tt0, t, de, dh, ftime, imod)
c
      if ((vmod.eq.'FULL').or.(vmod.eq.'SLAB')) then
        wmod='SCRN'
        call wmodel (luop, t, de, dh, dr, wmod)
      endif
c
c     compute new internal energy
c     de is updated
c
      teq=t
      dheq=dh
c
      en=zen*dheq
      ue1=gammaEOSU*(en+de)*rkb*t
c
c     Net Loss
c
      tloss=(ue0-ue1)/ftime
c
c      if (ratmod.eq.'Y') then
c        open (lurt,file=fr,status='OLD',access='APPEND')
c        write (lurt,*) 'pse',ue0,ue1,tloss,tt0,t
c        close (lurt)
c      endif
c
      call copypop (pop, pop1)
      call copypop (pop0, pop)
      t=tt0
      dh=dh1
      de=feldens(dh,pop)
      ve=vel1
      bmag=bm1
      call copypop (pop1, pop)
c
      rmod='NEAR'
      call rankhug (t, de, dh, ve, bmag, tloss, ftime)
c
      if (dabs(1.d0-(teq/te1)).gt.1.d-3) then
        tl0=tloss*0.5
        bmag=bm1
        call rankhug (t, de, dh, ve, bmag, tl0, ftime)
        tt1=te1
        tl1=tloss*0.5
        bmag=bm1
        call rankhug (t, de, dh, ve, bmag, tl1, ftime)
        tl1=tl0+(((teq-tt1)/(te1-tt1))*(tl1-tl0))
        bmag=bm1
        call rankhug (t, de, dh, ve, bmag, tl1, ftime)
        tloss=tl1
      endif
c
      dr=ftime*(vel0+vel1)*0.5d0
      dv=vel1-vel0
c
      call averinto (0.5d0, pop0, pop1, pop)
      t=(te0+te1)*0.5d0
      dh=(dh0+dh1)*0.5d0
      de=feldens(dh,pop)
c
      call cool (t, de, dh)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c End step iterations
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
  620 continue
c
      step=step+1
c
c     record step
c
      xh(step+1)=pop(2,1)
      veloc(step+1)=(vel1+vel0)*0.5d0
      te(step+1)=t
      dhy(step+1)=dh
      deel(step+1)=de
      dist(step+1)=dist(step)+dr
      timlps(step+1)=timlps(step)+ftime
c
c
  630 format(i4,1x,i4)
  640 format(1pg14.7,'K',1x,1pg14.7,'cm/s',1x,1pg14.7,'g/cm3',1x,
     &1pg14.7,'dyne/cm2',1x,1pg14.7,'Gauss',1x,1pg14.7,'ergs/cm3/s')
  650 format(2(1pg14.7,' cm',1x),2(1pg14.7,' s',1x))
  660 format(2(1pg14.7,' ergs/cm^3',1x),1pg14.7,' /cm^3',1x,
     &1pg14.7,' cm/s',1x,1pg14.7,' g ')
      en=zen*dh
c
      ue=gammaEOSU*(en+de)*rkb*t
      tnloss=tloss/(en*de)
c
      cspd=dsqrt(gammaEOS*(pr1+pr0)/(rho1+rho0))
      wmol=(rho1+rho0)/(2.d0*(en+de))
c
      mb=(bm0+bm1)*0.5
c
      if ((vmod.eq.'FULL').or.(vmod.eq.'SLAB')) then
        wmod='SCRN'
        call wmodel (luop, t, de, dh, dr, wmod)
      endif
c
c
  670    format('     Case A-B (HI, HeII): ',2(1pg11.3))
      write (*,670) caseab(1),caseab(2)
c
      if (vmod.eq.'MINI') then
        write (*,580) step,t,de,dh,en,mb,pop(1,1),timlps(step+1),ftime,
     &   dist(step+1),dr,veloc(step+1),dlos
      endif
c
c         dtarr = dtime(tarray)
c         nt1   = time()
c
c
c         write(*,900) tarray(1),nt1-nt0
c
c         nt0 = nt1
c
c
      if (ratmod.eq.'Y') then
        open (lurt,file=fr,status='OLD',access='APPEND')
        wmod='LOSS'
        call wmodel (lurt, t, de, dh, dr, wmod)
        close (lurt)
      endif
c
      if (dynmod.eq.'Y') then
        open (ludy,file=fd,status='OLD',access='APPEND')
        write (ludy,630) step,count
        write (ludy,650) dist(step+1),dr,timlps(step+1),ftime
        write (ludy,640) te0,vel0,rho0,pr0,bm0,l0
        write (ludy,640) te1,vel1,rho1,pr1,bm1,l11
        write (ludy,660) ue,hfree,en,cspd,wmol
        close (ludy)
      endif
c
      open (luop,file=fl,status='OLD',access='APPEND')
      write (luop,560) step,tab,dist(step+1),tab,timlps(step+1),tab,t,
     &tab,de,tab,dh,tab,en,tab,mu,tab,tloss/(dh*dh),tab,tloss,tab,dlos,
     &tab,pop(1,1),tab,pop(2,1),tab,(0.5*(bm0+bm1)),tab,dr,tab
      close (luop)
  680 format(70(1pg12.5,a1))
      if (fclmod.eq.'Y') then
        do i=1,atypes
c
          meanion(i)=0.d0
c
          ionbar=0.d0
          do j=1,maxion(i)
            ionbar=ionbar+(pop(j,i)*j)
          enddo
c
          meanion(i)=dmax1(ionbar-1.0d0,0.0d0)
c
        enddo
c
        open (lucl,file=fcl,status='OLD',access='APPEND')
c
        write (lucl,680) t,tab,de,tab,dh,tab,en,tab,(0.5*(rho0+rho1)),
     &   tab,pop(1,1),tab,pop(2,1),tab,mu,tab,tloss,tab,tloss/(dh*dh),
     &   (tab,coolz(j)/(dh*dh),j=1,atypes),(tab,meanion(j),j=1,atypes)
        close (lucl)
c
      endif
c
      if (allmod.eq.'Y') then
        open (lual,file=fa,status='OLD',access='APPEND')
        write (lual,690)
        write (lual,700) step,t,de,dh,vel1,rho1,pr1,dist(step+1),
     &   timlps(step+1)
  690 format(//,
     & ' Step   Te Ave.(K)   ',
     & '  ne(cm^-3)   ',
     & '  nH(cm^-3)   ',
     & '  V1(cm/s)    ',
     & ' Rho1(g/cm^3) ',
     & ' Pr1(erg/cm^3)',
     & '   Dist.(cm)  ',
     & ' Elps. Time(s)')
  700 format(1x,i4,8(1pg14.7)/)
c
        call wionabal (lual, pop)
        call wionabal (lual, popint)
        close (lual)
      endif
c
      if (tsrmod.eq.'Y') then
        do i=1,ieln
          open (luions(i),file=filn(i),status='OLD',access='APPEND')
c
  710 format(1x,i4,3(', ',1pg12.5),31(', ',1pg12.5))
          if (i.eq.1) then
            write (luions(i),710) step,dist(step)+(dr*0.5),dr,t,(pop(j,
     &       iel(1)),j=1,maxion(iel(1)))
          endif
          if (i.eq.2) then
            write (luions(i),710) step,dist(step)+(dr*0.5),dr,t,(pop(j,
     &       iel(2)),j=1,maxion(iel(2)))
          endif
          if (i.eq.3) then
            write (luions(i),710) step,dist(step)+(dr*0.5),dr,t,(pop(j,
     &       iel(3)),j=1,maxion(iel(3)))
          endif
          if (i.eq.4) then
            write (luions(i),710) step,dist(step)+(dr*0.5),dr,t,(pop(j,
     &       iel(4)),j=1,maxion(iel(4)))
          endif
c
          close (luions(i))
c
        enddo
c
c     end .tsr files
c
      endif
c
c
c     poll for photons file
c
      pollfile='photons'
      inquire (file=pollfile,exist=iexi)
c
      if ((lmod.eq.'Y').or.(iexi)) then
c
c     Local photon field
c
        specmode='LOCL'
        call localem (t, de, dh)
        rad=dist(step+1)
        call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
        caller='S4'
        pfx='plocl'
        np=5
        wmod='REAL'
        call wpsou (caller, pfx, np, wmod, t, de, dh, dr, 1.0d0, tphot)
c
        pfx='slec'
        sfx='sh4'
        fpf=' '
        call newfile (pfx, 4, sfx, 3, fn)
        fpf=fn(1:12)
        write (*,*) 'fpf''',fa,''''
        open (lupf,file=fpf,status='NEW')
        spmod='ABS'
        linemod='LAMB'
        call speclocal (lupf, tloss, eloss, egain, dlos, t, de, dh,
     &   pop(1,1), dist(step+1), dr, linemod, spmod)
        close (lupf)
c
c     reset mode and tphot
c
        specmode='DW'
        rad=dist(step+1)
        call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
      endif
c
      open (lupb,file=fpb,status='OLD',access='APPEND')
c
c     total energy in Inu
c
c
      band1=0.d0
      band2=0.d0
      band3=0.d0
      band4=0.d0
      band5=0.d0
      band6=0.d0
      bandall=0.d0
c
      do i=1,infph-1
        widnu=widbinnu(i)
        bandall=bandall+tphot(i)*widnu
        if ((photev(i).ge.5.0d2).and.(photev(i).lt.2.0d3)) then
          band1=band1+tphot(i)*widnu
        endif
        if ((photev(i).ge.2.0d3).and.(photev(i).lt.8.0d3)) then
          band2=band2+tphot(i)*widnu
        endif
        if ((photev(i).ge.5.0d2).and.(photev(i).lt.8.0d3)) then
          band3=band3+tphot(i)*widnu
        endif
        if ((photev(i).ge.3.0d3).and.(photev(i).lt.10.0d3)) then
          band4=band4+tphot(i)*widnu
        endif
        if ((photev(i).ge.1.0d3).and.(photev(i).lt.2.0d3)) then
          band5=band5+tphot(i)*widnu
        endif
        if ((photev(i).ge.2.0d3).and.(photev(i).lt.3.0d3)) then
          band6=band6+tphot(i)*widnu
        endif
      enddo
c
c     times 4 pi to cover whole sky
c
      band1=band1*fpi/dr
      band2=band2*fpi/dr
      band3=band3*fpi/dr
      band4=band4*fpi/dr
      band5=band5*fpi/dr
      band6=band6*fpi/dr
      bandall=bandall*fpi/dr
c
      if (band1.lt.epsilon) band1=0.d0
      if (band2.lt.epsilon) band2=0.d0
      if (band3.lt.epsilon) band3=0.d0
      if (band4.lt.epsilon) band4=0.d0
      if (band5.lt.epsilon) band5=0.d0
      if (band6.lt.epsilon) band6=0.d0
      if (bandall.lt.epsilon) bandall=0.d0
c
  720 format(17(1pg12.5,a1))
      write (lupb,720) t,tab,de,tab,dh,tab,en,tab,pop(1,1),tab,pop(2,1),
     &tab,mu,tab,tloss/(de*dh),tab,tloss,tab,fflos,tab,band1,tab,band2,
     &tab,band3,tab,band4,tab,band5,tab,band6,tab,bandall
c
      close (lupb)
c
c     get mean ionisation state for step
c
      rdis=(dist(step)+dist(step+1))*0.5d0
      cmpf=rho1/rho0
      fi=1.0d0
c
c     accumulate spectrum
c
      tdw=te0
      tup=te1
      drdw=dr
      dvdw=vel0-vel1
      drup=dist(step+1)
      dvup=dsqrt(vpo*vel0)
      frdw=0.5d0
c
      call localem (t, de, dh)
      if (photonmode.ne.0) then
        call zetaeff (dh)
        call newdif2 (tdw, tup, dh, rad, drdw, dvdw, drup, dvup, frdw,
     &   jtrans)
c
      endif
c
      imod='ALL'
      dvol=dr*irdvol
      call sumdata (t, de, dh, dvol, dr, rdis, imod)
c
c     record line ratios
c
      if (ox3.ne.0) then
        hoiii(step+1)=(fluxm(7,ox3)+fluxm(10,ox3))/(fluxh(2)+epsilon)
      endif
      if (ox2.ne.0) then
        hoii(step+1)=(fluxm(1,ox2)+fluxm(2,ox2))/(fluxh(2)+epsilon)
      endif
      if (ni2.ne.0) then
        hnii(step+1)=(fluxm(7,ni2)+fluxm(10,ni2))/(fluxh(2)+epsilon)
      endif
      if (su2.ne.0) then
        hsii(step+1)=(fluxm(1,su2)+fluxm(1,su2))/(fluxh(2)+epsilon)
      endif
      if (ox1.ne.0) then
        if (ispo.eq.' OI') hsii(step+1)=fluxm(3,ox1)/(fluxh(1)+epsilon)
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Set up initial conditions for the next zone
c     (= end conditions in previous zone)
c     Calculate new cooling times and next step
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call copypop (pop1, pop0)
      call copypop (pop1, pop)
c
      t=te1
      tt0=te1
      l0=l11
      l12=0.d0
      l11=0.d0
      r0=rho1
      p0=pr1
      v0=vel1
      dh0=dh1
      de0=de1
      bm0=bm1
      bmag=bm0
      count=0
c
      call cool (t, de0, dh0)
c
      el=dmax1(0.d0,eloss-egain)
c
c      write(*,*) t,de0,dh0,tloss
c
c     now compute free enthalpy per particle
c
      en=zen*dh0
c
      press=(en+de0)*rkb*t
      ue=gammaEOSU*(en+de0)*rkb*t
c
      cltime=dabs(ue/tloss)
c
      wmol=r0/(en+de0)
      mu=fmua(de0,dh0)
c      mu = en*wmol/((en+de0)*(mp+me))
c
      hfree=bmag*bmag/(4.d0*pi*en)+0.5d0*(wmol*ve*ve)+2.5d0*(rkb*t)/mu
c
c     calculate timescales
c
      htime=dabs(hfree/tloss)
c
      abstime=1.d0/epsilon
c
      ctime=fcolltim(de)
      rtime=frectim2(de)
      ptime=fphotim()
c
      eqtime=(1.d0/ctime)+(1.d0/ptime)+(1.d0/rtime)
      eqtime=dabs(1.d0/eqtime)
c
c     experiment with timescales
c
      stime=(1.d0/ctime)+(1.d0/ptime)-(1.d0/rtime)
      stime=dabs(1.d0/stime)
c
      ftime=1.d0/((1.d0/(stime*atimefrac))+(1.d0/(cltime*cltimefrac)))
c     &             +(1.d0/(abstime*abtimefrac)))
c
      if ((tmod.eq.'M').and.(ftime.gt.utime)) ftime=utime
      if ((tmod.eq.'N').and.(ftime.lt.utime)) ftime=utime
      if (tmod.eq.'S') ftime=utime
c
      if (vmod.eq.'FULL') then
        write (*,590) ue,tloss,tloss,htime,cltime,ctime,rtime,ptime,
     &   stime,eqtime,abstime,ftime
      endif
c
c      if (ratmod.eq.'Y') then
c        open (lurt,file=fr,status='OLD',access='APPEND')
c        write (lurt,610) ue,tloss,tloss,htime,cltime,ctime,rtime,ptime,
c     &   stime,eqtime,abstime,ftime
c        close (lurt)
c      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c     Program endings
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Ionisation, finish when mean ionisation < 1%
c
      if (jend.eq.'A') then
c
        totn=0.d0
c
        totn=zen
c
        ionbar=0.d0
c
        do i=1,atypes
c
          do j=2,maxion(i)
            ionbar=ionbar+(pop(j,i)*zion(i))
          enddo
c
        enddo
c
        ionbar=ionbar/totn
c
        if (ionbar.lt.0.01d0) goto 730
c
      endif
c
c     Specific species ionisation limit
c
c
      if (jend.eq.'B') then
        if (pop(jpoen,ielen).lt.fren) goto 730
      endif
c
c
c     Temperature limit
c
      if ((jend.eq.'C').and.(t.lt.tend)) goto 730
c
c
c     Distance Limit
c
      if ((jend.eq.'D').and.(dist(step+1).ge.diend)) goto 730
c
c
c     Time Limit
c
      if ((jend.eq.'E').and.(timlps(step+1).ge.timend)) goto 730
c
c
c     thermal balance dlos<1e-2
c
      if ((jend.eq.'F').and.(dlos.lt.1.d-2)) goto 730
c
c
c     cooling function test, finish when tloss goes -ve
c
      if ((jend.eq.'G').and.(tloss.lt.0.d0)) goto 730
c
c     poll for terminate file
c
      pollfile='terminate'
      inquire (file=pollfile,exist=iexi)
      if (iexi) goto 730
c
c     otherwise go to normal iteration loop, if interlocks
c     permit
c
      if ((t.gt.100.d0).and.(step.lt.(mxnsteps-1))) then
        goto 600
      endif
c
  730 continue
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     End model
c     write out spectrum etc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (jspec.eq.'Y') then
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Final Downstream Field
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
        caller='S4'
        pfx='spdw'
        np=4
        dva=0
c
        wmod='REAL'
        call wpsou (caller, pfx, np, wmod, t, de, dh, dr, 0.5d0, tphot)
c
        wmod='LFLM'
        call wpsou (caller, pfx, np, wmod, t, de, dh, dr, 0.5d0, tphot)
c
        wmod='NFNU'
        call wpsou (caller, pfx, np, wmod, t, de, dh, dr, 0.5d0, tphot)
c
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Upstream photon field
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      specmode='UP'
      rad=dist(step+1)
      call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
      caller='S4'
      pfx=mypfx
      np=5
      dva=vel1-vel0
c
      wmod='REAL'
      call wpsou (caller, pfx, np, wmod, te1, de1, dh1, dr, wdil, tphot)
c
      wmod='NFNU'
      call wpsou (caller, pfx, np, wmod, te1, de1, dh1, dr, wdil, tphot)
c
      wmod='LFLM'
      call wpsou (caller, pfx, np, wmod, te1, de1, dh1, dr, wdil, tphot)
c
c     dynamics
c
      open (luop,file=fl,status='OLD',access='APPEND')
c
  740 format(//,
     & ' Model ended.',a1,'Distance:',1pg14.7,a1,
     &'Time:',1pg14.7,a1,'Temp:',1pg12.5//)
      write (luop,740) tab,dist(step+1),tab,timlps(step+1),tab,t
c
      call avrdata
      call wrsppop (luop)
      close (luop)
c
      open (lusp,file=fsp,status='OLD',access='APPEND')
      spmod='REL'
      linemod='LAMB'
      call spec2 (lusp, linemod, spmod)
      close (lusp)
c
c     restore photonmode
c
      photonmode=1
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
