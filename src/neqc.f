cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.inc'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine neqc
c! XXXX - add one line purpose here
c! @param This routine has no parameters
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine neqc ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     NEQC; non-equilibrium cooling, simplified code based on Shock5
c     Calls compsh5
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      call neqcsetup ()
c
      call neqcheaders ()
c
      call compsh5 (0, 1)
c
      close (luop)
c
      photonmode=1
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine neqcsetup
c! XXXX - add one line purpose here
c! @param This routine has no parameters
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine neqcsetup ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      real*8 teinit,dhinit
      real*8 frho
      integer*4 elok(mxelem),nel,i,idx
      integer*4 flen
c
      real*8 fpresse,feldens
c
   10 format(a)
c
c     set up logical unit numbers
c
c
c main files, model and specs disable precursors files
c
      luop=20
      lusp=21
      lupt=0
      lupc=0
c
c common files
c
      lucl=24
      lupb=25
      lupb=26
      ludy=27
c
c shock only files
c
      lualsh=28
      lurtsh=29
      lulsh=30
      ieln=4
      do i=1,atypes
        luionsh(i)=30+i
      enddo
c
c precursor only files disabled set to 0
c
      lualpc=0
      lurtpc=0
      lulpc=0
      do i=1,atypes
        luionpc(i)=0
      enddo
c
      fsm=' '
      pfx='neqcl'
      sfx='neq'
      call newfile (pfx, sfx, fn, flen)
      fsm=fn(1:flen)
c
      open (luop,file=fsm,status='NEW')
c
c     zero arrays and define modes: all ions, no on-thespot,
c     full continuum
c     calculations..
c
      call zer
c
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
      s5pfx='neqcl'
      specmode='DW'
      jgeo='P'
      jtrans='LODW'
      jden='B'
      subname='NEQ Cool'
      jnorm=0
c
      photonmode=1
      fi=1.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     INTRO - Define Input Parameters
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
   20 format(///,
     & ' ********************************************************',/,
     & ' Non-equilibrium Cooling model selected:',/,
     & ' Based on v5.1 S5 model',/,
     & ' ********************************************************')
      write (*,20)
c
c     get ionisation balance to work with...
c
      subname='NEQ Cool'
c
   30 format(///,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' Setting the Initial Conditions',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
      write (*,30)
c
      teinit=1.0d9
      dhinit=1.0d-4
      magparam=1.0d0
      machnumber=1.0d0
   40   format(//,
     & ' Initial state:',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Temperature, H density, Mach number, Magnetic Alpha',/,
     & '  (T<10 taken as a log10, dh <0.0 as log10, )',/,
     & '  (Mach>=0.0, Alpha>=0.0 Pmag/Pgas, < 0.0 as -microgauss)',/,
     & ' : T (K), dh (N), M, Alpha',/,
     & ' :: ',$)
      write (*,40)
      read (*,*) teinit,dhinit,machnumber,magparam
c
      if (teinit.le.10.d0) teinit=10.d0**teinit
      if (dhinit.lt.0.d0) dhinit=10.d0**dhinit
c
      if (machnumber.lt.0.d0) machnumber=0.0d0
c
      call ciepops (teinit, dhinit)
c
c sets t, de, dh
c
      call copypop (pop, pop0)
      call copypop (pop0, pop_neu)
      call copypop (pop0, pop_pre)
      call copypop (pop0, pop_pre0)
      call zeroemiss
      subname='NEQ Cooling 5'
c
      t=teinit
      dh=dhinit
c
c Now set constant values at steady velocity, no shock.
c
      de=feldens(dh,pop0)
      rho0=frho(de,dh)
      pgas=fpresse(t,de,dh)
c
      wdil=0.5d0
c
c     Magnetic fields expressed as Alpha = Pmag/Pgas
c     Alpha = 1.0 is equipartition, Alpha = 10.0 is strong magnetic
c     Alpha = 0.1 is weak magnetic field. Alpha = 0.0 is no magnetic
c     Alpha = 1.0/Beta where Beta is the usual magnetic parameter, but
c     Alpha allows Alpha = 0.0 for the non-magnetic limit
c
c
      if (magparam.lt.0.0d0) then
        bmag=-magparam
      endif
      if (dr.le.0.d0) dr=1.d0
      if (wdil.gt.0.5d0) wdil=0.5d0
      if (magparam.ge.0.d0) then
        pmag=magparam*pgas
        bmag=dsqrt(epi*pmag)*1.0d6
      else
        bmag=-magparam
      endif
      bmag=bmag*1.d-6
c
      ve=dsqrt(gammaEOS*Pgas/rho0)*machnumber
c
c set compsh5 gobals
c
      te_neu=t
      de_neu=de
      dh_neu=dh
      vs_neu=ve
      pr_neu=fpresse(t,de,dh)
      rh_neu=frho(de,dh)
      bm_neu=Bmag
c
      te_pre=t
      de_pre=de
      dh_pre=dh
      vs_pre=ve
      pr_pre=pr_neu
      rh_pre=rh_neu
      bm_pre=Bmag
c
      call shockcmpf (t, de, dh, ve, Bmag)
      call shocksummary (6)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (alphacoolmode.eq.1) then
   50  format(//,
     & ' Powerlaw Cooling enabled  Lambda T6 ^ alpha :',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    Give index alpha, Lambda at 1e6K',/,
     & '    (Lambda<0 as log)',/,
     & ' :: ',$)
        write (*,50)
        read (*,*) alphaclaw,alphac0
        if (alphac0.lt.0.d0) alphac0=10.d0**alphac0
      endif
c
c     Diffuse field interaction
c
   60 format(//,
     & ' Choose Diffuse Field Option :',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    F  : Full diffuse field interaction (Default).',/,
     & '    Z  : Zero diffuse field interaction.',/,
     & ' :: ',$)
      write (*,60)
   70 read (*,10) ilgg
      call toup (ilgg(1:1), ilgg)
c
      if ((ilgg.ne.'Z').and.(ilgg.ne.'F')) goto 70
c
      if (ilgg.eq.'Z') photonmode=0
      if (ilgg.eq.'F') photonmode=1
c
      tmod='A'
      atimefrac=0.1d0
      cltimefrac=0.05d0
      abtimefrac=1.0d0
      utime=0.d0
c
   80 format(//,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Boundry Conditions ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,80)
c
c     Choose ending
c
   90 format(/,
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
  100 write (*,90)
      read (*,10) jend
      call toup (jend(1:1), ilgg)
c
      if ((jend.ne.'A').and.(jend.ne.'B').and.(jend.ne.'C')
     &.and.(jend.ne.'D').and.(jend.ne.'E').and.(jend.ne.'F')
     &.and.(jend.ne.'G')) goto 100
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     Secondary info:
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (jend.eq.'B') then
  110   format(//,
     & ' Give Atom, Ion and limit fraction: ')
        write (*,110)
        read (*,*) ielen,jpoen,fren
      endif
      if (jend.eq.'C') then
  120   format(//,
     & ' Give final temperature (K > 10, log <= 10): ')
        write (*,120)
        read (*,*) tend
        if (tend.le.10.d0) tend=10.d0**tend
      endif
      if (jend.eq.'D') then
  130   format(//,
     & ' Give final distance (cm > 100, log<=100): ')
        write (*,130)
        read (*,*) diend
        if (diend.le.100.d0) diend=10.d0**diend
      endif
      if (jend.eq.'E') then
  140   format(//,
     & ' Give time limit (s > 100, log<=100): ')
        write (*,140)
        read (*,*) timend
        if (timend.le.100.d0) timend=10.d0**timend
      endif
c
  150 format(//,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Output Requirements ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,150)
c
c     default monitor elements
c
      ieln=4
      iel(1)=zmap(1)
      iel(2)=zmap(2)
      iel(3)=zmap(6)
      iel(4)=zmap(8)
      s5pfx='neqcl'
      nprefix=5
c
c      ilgg='J'/'B'
c
c     Cooling Components File
c
      fclmod='Y'
c
c     Ionisation Files
c
      allmod='N'
      tsrmod='Y'
c
c     Upstream fields
c
      lmod='N'
c
c     F-Lambda plots, ionising and optical
c
      jspec='N'
c
c     timescales and rates file
c
      ratmod='N'
c
c     flow dynamics file
c
      dynmod='N'
c
      if (ratmod.eq.'Y') then
        ratmod='Y'
        pfx='rates'
        sfx='csv'
        call newfile (pfx, sfx, fn, flen)
        fr=fn(1:flen)
        open (lurtsh,file=fr,status='NEW')
      endif
c
      if (fclmod.eq.'Y') then
        jnorm=3
  160  format (/' Cooling as total and by Element:'/
     & '::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/
     & ' Cooling File Normalisation,',/
     & ' (0=ne.nH, 1=nH^2, 2=ne.ni, 3=n^2, 4=ne^2):')
        write (*,160)
        read (*,*) jnorm
        if (jnorm.lt.0) jnorm=3
        if (jnorm.gt.4) jnorm=3
        fclmod='Y'
        pfx='neqc'
        sfx='csv'
        fcl=' '
        call newfile (pfx, sfx, fn, flen)
        fcl=fn(1:flen)
        open (lucl,file=fcl,status='NEW')
      endif
c
      if (dynmod.eq.'Y') then
        pfx='dyn'
        sfx='csv'
        fd=' '
        call newfile (pfx, sfx, fn, flen)
        fd=fn(1:flen)
        open (ludy,file=fd,status='NEW')
      endif
c
      pfx='spec'
      sfx='csv'
      fsh=' '
      call newfile (pfx, sfx, fn, flen)
      fsh=fn(1:flen)
      open (lusp,file=fsh,status='NEW')
c
c     ionbalance files
c
c
      if (tsrmod.eq.'Y') then
  170   format(//,
     & ' Choose max',a2,' Element Ionisation Files by Z: ',/,
     & '::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
        write (*,170) atypes
  180   format(' Enter number of elements to track : ',$)
  190   format(/' Elements (Z) : ',$)
        write (*,180)
        read (*,*) ieln
        ieln=min(max(0,ieln),atypes)
        if (ieln.le.0) tsrmod='N'
        if (tsrmod.eq.'Y') then
          write (*,190)
          read (*,*) (iel(i),i=1,ieln)
          do i=1,ieln
            elok(i)=0
            do idx=1,atypes
              if (iel(i).eq.mapz(idx)) elok(i)=1
            enddo
          enddo
          nel=ieln
          do i=1,ieln
            if (elok(i).eq.0) nel=nel-1
          enddo
          if (nel.lt.1) tsrmod='N'
          if (tsrmod.eq.'Y') then
            ieln=nel
            do i=1,ieln
              iel(i)=zmap(iel(i))
            enddo
  200         format(/' Monitoring :',30(x,a2),/)
            write (*,200) (elem(iel(i)),i=1,ieln)
          else
            write (*,'("Unable to monitor element ions")')
          endif
        endif
      endif
c
c     get screen display mode
c
      vmod='MINI'
c      if (ilgg.eq.'A') vmod='MINI'
c      if (ilgg.eq.'B') vmod='SLAB'
c      if (ilgg.eq.'C') vmod='FULL'
c
c     get runname
c
  210 format (a80)
  220 format(//,
     & ' Give a name/code for this run: ')
      write (*,220)
      read (*,210) runname
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c****************************************************************
c> @brief The subroutine neqcheaders
c! XXXX - add one line purpose here
c! @param This routine has no parameters
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine neqcheaders ()
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 i,j,flen
      character tab*1
      real*8 feldens
      integer*4 lenv,mlen
c
      tab=','
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Write Headers
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
   10   format(//' Flow Properties',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '   Velocity    :',1pg12.5,' km/s',/,
     & '   Mach Number           :',1pg12.5,/,
     & '   Mag. Alpha (Pmag/Pgas):',1pg12.5,//,
     & '   ne  :',1pg12.5,' cm^-3',/,
     & '   nH  :',1pg12.5,' cm^-3',/,
     & '    d  :',1pg12.5,' g/cm^-3',/,
     & '    T  :',1pg12.5,' K',/,
     & '    B  :',1pg12.5,' microGauss',//,
     & '   Pgas:',1pg12.5,' dyne/cm^2',/,
     & '   Pmag:',1pg12.5,' dyne/cm^2',/,
     & '   Pram:',1pg12.5,' dyne/cm^2',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
c
c     write ion balance files if requested
c
      if (tsrmod.eq.'Y') then
        do i=1,atypes
c         ie=iel(i)
          fn=' '
          pfx=elem(i)
          sfx='csv'
          call newfile (pfx, sfx, fn, flen)
          fionsh(i)=fn(1:flen)
        enddo
c
        np=mlen(runname)
        do i=1,ieln
          open (luionsh(i),file=fionsh(iel(i)),status='NEW')
          write (luionsh(i),*) fl,', ',runname(1:np)
   20 format('Step [1], <X> [2], dX [3], <T> [4]',31(',',a6,'[',i2,']'))
          write (luionsh(i),20) (rom(j),j+4,j=1,maxion(iel(i)))
          close (luionsh(iel(i)))
        enddo
c
c     end trsmod = 'Y'
c
      endif
c
      de=feldens(dh,pop)
c
      fpb=' '
      pfx='bands'
      sfx='csv'
      call newfile (pfx, sfx, fn, flen)
      fpb=fn(1:flen)
      open (lupb,file=fpb,status='NEW')
c
c     Title
c
   30 format(' Nonequilibrium Cooling',/,
     & ' ============================================',/,
     & ' Diffuse Field, Full Continuum Calculations.',/,
     & ' Calculated by MAPPINGS V ',a12)
      write (*,30) theversion
      write (luop,30) theversion
      write (lusp,30) theversion
      write (lupb,30) theversion
      if (ratmod.eq.'Y') write (lurtsh,30) theversion
      if (dynmod.eq.'Y') write (ludy,30) theversion
      if (allmod.eq.'Y') write (lualsh,30) theversion
      if (fclmod.eq.'Y') write (lucl,30) theversion
   40 format(//' Run  :',a,/
     & ' File :',a)
      write (luop,40) runname,fl
      write (lusp,40) runname,fl
      write (lupb,40) runname,fl
      if (ratmod.eq.'Y') write (lurtsh,40) runname,fl
      if (dynmod.eq.'Y') write (ludy,40) runname,fl
      if (allmod.eq.'Y') write (lualsh,40) runname,fl
      if (fclmod.eq.'Y') write (lucl,40) runname,fl
c
c     Write Model Parameters
c
   50 format(//,
     & ' Model Parameters:',/,
     & ' =================',//,
     & ' Abundances     : ',a128,/,
     & ' Pre-ionisation : ',a128,/,
     & ' Photon Source  : ',a128)
   60 format(/,' Charge Exchange: ',a12,/,
     & ' Photon Mode    : ',a12,/,
     & ' Collision calcs: ',a12)
   70 format(/,' Charge Exchange: ',a12,/,
     & ' Photon Mode    : ',a12,/,
     & ' Collision calcs: ',a12,/,
     & ' Electron Kappa : ',1pg11.4)
   80 format(//' ',t2,'Jden',t9,'Jgeo',t16,'Jtrans',
     &            t23,'Jend',t29,'Ielen',t35,
     & 'Jpoen',t43,'Fren',t51,'Tend',t57,'DIend',t67,
     & 'TAUen',t77,'Jeq',t84,'Teini')
   90 format('  ',4(a4,3x),2(i2,4x),0pf6.4,0pf6.0,
     &           2(1pg10.3),3x,a4,0pf7.1)
  100 format(//' Photon Source'/
     & ' ============='/)
  110 format(/' MOD',t7,'Temp.',t16,'Alpha',t22,'Turn-on',t30,'Cut-off'
     &,t38,'Zstar',t47,'FQHI',t56,'FQHEI',t66,'FQHEII')
  120 format(' ',a2,1pg10.3,4(0pf7.2),1x,3(1pg10.3))
c
      write (luop,10) vel0*1.d-5,machnumber,magparam,de,dh,rho0,te0,bm0*
     &1.d6,pr0,bp0,rho0*vel0*vel0
c
      write (lupb,10) vel0*1.d-5,machnumber,magparam,de,dh,rho0,te0,bm0*
     &1.d6,pr0,bp0,rho0*vel0*vel0
c
      if (ratmod.eq.'Y') then
        write (lurtsh,10) vel0*1.d-5,machnumber,magparam,de,dh,rho0,te0,
     &   bm0*1.d6,pr0,bp0,rho0*vel0*vel0
      endif
c
      if (dynmod.eq.'Y') then
        write (ludy,10) vel0*1.d-5,machnumber,magparam,de,dh,rho0,te0,
     &   bm0*1.d6,pr0,bp0,rho0*vel0*vel0
      endif
c
      if (allmod.eq.'Y') then
        write (lualsh,10) vel0*1.d-5,machnumber,magparam,de,dh,rho0,te0,
     &   bm0*1.d6,pr0,bp0,rho0*vel0*vel0
      endif
c
      if (fclmod.eq.'Y') then
        write (lucl,10) vel0*1.d-5,machnumber,magparam,de,dh,rho0,te0,
     &   bm0*1.d6,pr0,bp0,rho0*vel0*vel0
      endif
c
      write (luop,50) abnfile,ionsetup,srcfile
      write (lupb,50) abnfile,ionsetup,srcfile
      write (lusp,50) abnfile,ionsetup,srcfile
      if (ratmod.eq.'Y') write (lurtsh,50) abnfile,ionsetup,srcfile
      if (dynmod.eq.'Y') write (ludy,50) abnfile,ionsetup,srcfile
      if (allmod.eq.'Y') write (lualsh,50) abnfile,ionsetup,srcfile
      if (fclmod.eq.'Y') write (lucl,50) abnfile,ionsetup,srcfile
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     abundances file header
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
      call wabund (lusp)
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
      if (usekappa) then
        write (luop,70) cht,pht,clt,kappa
      else
        write (luop,60) cht,pht,clt
      endif
      write (luop,80)
      write (luop,90) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,diend,
     &tauen,tmod,te0
      write (luop,100)
      write (luop,110)
      write (luop,120) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
      write (lupb,60) cht,pht,clt
      write (lupb,80)
      write (lupb,90) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,diend,
     &tauen,tmod,te0
      write (lupb,100)
      write (lupb,110)
      write (lupb,120) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
      if (ratmod.eq.'Y') then
        write (lurtsh,60) cht,pht,clt
        write (lurtsh,80)
        write (lurtsh,90) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &   diend,tauen,tmod,te0
        write (lurtsh,100)
        write (lurtsh,110)
        write (lurtsh,120) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
      endif
c
      if (dynmod.eq.'Y') then
        write (ludy,60) cht,pht,clt
        write (ludy,80)
        write (ludy,90) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &   diend,tauen,tmod,te0
        write (ludy,100)
        write (ludy,110)
        write (ludy,120) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
      endif
c
      if (allmod.eq.'Y') then
c
        write (lualsh,60) cht,pht,clt
        write (lualsh,80)
        write (lualsh,90) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &   diend,tauen,tmod,te0
        write (lualsh,100)
        write (lualsh,110)
        write (lualsh,120) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
      endif
c
      if (fclmod.eq.'Y') then
c
        write (lucl,60) cht,pht,clt
        write (lucl,80)
        write (lucl,90) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,
     &   diend,tauen,tmod,te0
        write (lucl,100)
        write (lucl,110)
        write (lucl,120) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
      endif
c
c     Shock parameters
c
  130 format(//,
     & ' Jump Conditions:',/,
     & ' ================')
      write (luop,130)
      write (lupb,130)
      write (lusp,130)
      if (ratmod.eq.'Y') write (lurtsh,130)
      if (dynmod.eq.'Y') write (ludy,130)
      if (allmod.eq.'Y') write (lualsh,130)
      if (fclmod.eq.'Y') write (lucl,130)
c
  140 format(//' T1',1pg14.7,' V1',1pg14.7,
     & ' RH1',1pg14.7,' P1',1pg14.7,' B1',1pg14.7/
     & ' T2',1pg14.7,' V2',1pg14.7,
     & ' RH2',1pg14.7,' P2',1pg14.7,' B2',1pg14.7)
c
      dr=0.d0
      dv=vel1-vel0
c
      write (*,140) te0,vel0,rho0,pr0,bm0,te1,vel1,rho1,pr1,bm1
      write (luop,140) te0,vel0,rho0,pr0,bm0,te1,vel1,rho1,pr1,bm1
      write (lupb,140) te0,vel0,rho0,pr0,bm0,te1,vel1,rho1,pr1,bm1
      write (lusp,140) te0,vel0,rho0,pr0,bm0,te1,vel1,rho1,pr1,bm1
      if (ratmod.eq.'Y') write (lurtsh,140) te0,vel0,rho0,pr0,bm0,te1,
     &vel1,rho1,pr1,bm1
      if (dynmod.eq.'Y') write (ludy,140) te0,vel0,rho0,pr0,bm0,te1,
     &vel1,rho1,pr1,bm1
      if (fclmod.eq.'Y') write (lucl,140) te0,vel0,rho0,pr0,bm0,te1,
     &vel1,rho1,pr1,bm1
c
      close (lusp)
c
      wdilt0=te0
      t=te0
      ve=vel0
      dr=1.0d0
      dv=ve*0.01d0
      rad=1.d38
      if (wdil.eq.0.5d0) rad=0.d0
c
c     get the electrons...
c
      de=feldens(dh,pop)
c
c     calculate the radiation field and atomic rates
c
      call localem (t, de, dh)
      call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
      if (photonmode.ne.0) then
        call zetaeff (dh)
      endif
      call cool (t, de, dh)
c
c
  150 format(//,
     & ' Precursor Conditions and Ionisation State',/
     & ' =========================================',/)
      write (luop,150)
      write (lupb,150)
      if (fclmod.eq.'Y') write (lucl,150)
c
      if ((vmod.eq.'FULL').or.(vmod.eq.'SLAB')) then
        wmod='SCRN'
        call wmodel (luop, t, de, dh, dr, wmod)
      endif
c
      wmod='FILE'
      call wmodel (luop, t, de, dh, dr, wmod)
      call wmodel (lupb, t, de, dh, dr, wmod)
      if (ratmod.eq.'Y') then
        call wmodel (lurtsh, t, de, dh, dr, wmod)
        call wmodel (lurtsh, 0.d0, 0.0d0, 0.d0, 0.0d0, 'LOSH')
      endif
c
      call wionabal (luop, pop)
      call wionabal (lupb, pop)
      if (allmod.eq.'Y') call wionabal (lualsh, pop)
      if (fclmod.eq.'Y') call wionabal (lucl, pop)
c
      close (luop)
  160 format(17(a12,a1))
      write (lupb,160) 'Te',tab,'de',tab,'dh',tab,'en',tab,'FHI',tab,'FH
     &II',tab,'mu',tab,'tloss',tab,'Lambda',tab,'ff/total',tab,'B0.0-0.1
     &keV',tab,'B0.1-0.5keV',tab,'B0.5-1.0keV',tab,'B1.0-2.0eV',tab,'B2.
     &0-10.0keV',tab,'Ball'
      close (lupb)
  170 format(//'Mean Zone Values'/
     & '================'/)
  180 format(10(a12,a2),30(a12,a2),33(a12,a2))
  190 format(10(a12,a2),30(a12,a2),33(1pg12.5,a2))
c
  200 format('=======================================================',
     & '=======================================================',
     & '=======================================================',
     & '=======================================================',
     & '=======================================================',
     & '=======================================================',
     & '=======================================================',
     & '=======================================================',
     & '=======================================================',
     & '=======================================================',
     & '======================================')
c
      if (fclmod.eq.'Y') then
        write (lucl,170)
        if (jnorm.eq.0) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'FHI   ',tab,'FHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     &.nH)',tab,(elem(j),tab,j=1,atypes),'L_5007',tab,'LHalpha',tab,'LLy
     &alpha'
        endif
        if (jnorm.eq.1) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'FHI   ',tab,'FHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(nH
     &^2)',tab,(elem(j),tab,j=1,atypes),'L_5007',tab,'LHalpha',tab,'LLya
     &lpha'
        endif
        if (jnorm.eq.2) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'FHI   ',tab,'FHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     &.ni)',tab,(elem(j),tab,j=1,atypes),'L_5007',tab,'LHalpha',tab,'LLy
     &alpha'
        endif
        if (jnorm.eq.3) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'FHI   ',tab,'FHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(n^
     &2)',tab,(elem(j),tab,j=1,atypes),'L_5007',tab,'LHalpha',tab,'LLyal
     &pha'
        endif
        if (jnorm.eq.4) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'FHI   ',tab,'FHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     &^2)',tab,(elem(j),tab,j=1,atypes),'L_5007',tab,'LHalpha',tab,'LLya
     &lpha'
        endif
        write (lucl,190) '(K)',tab,'(/cm^3)',tab,'(/cm^3)',tab,'(/cm^3)'
     &   ,tab,'(g/cm^3)',tab,' ',tab,' ',tab,'(amu)',tab,'(erg/cm^3/s)',
     &   tab,'(erg cm^3/s)',tab,('(erg cm^3/s)',tab,j=1,atypes),'(erg cm
     &^3/s)',tab,'(erg cm^3/s)',tab,'(erg cm^3/s)'
        write (lucl,200)
      endif
      if (ratmod.eq.'Y') close (lurtsh)
      if (dynmod.eq.'Y') close (ludy)
      if (allmod.eq.'Y') close (lualsh)
      if (fclmod.eq.'Y') close (lucl)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
