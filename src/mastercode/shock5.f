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
      subroutine shock5 ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     SHOCK5: Shock model with steady Rankine-Hugoniot solution for
c     each step.  Time steps based on fastest atomic, cooling or
c     photon absorbion timescales.
c
c     Full continuum and diffuse field, auto preionisation
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 iterations,iterationindex
   10 format(//,
     & ' *********************************************************',/,
     & '  SHOCK 5    Global Iteration: ',i2.2,' of ',i2.2)
   20 format(/,
     & '  SHOCK 5 Completed Iteration: ',i2.2,' of ',i2.2,/,
     & ' *********************************************************',/)
   30 format(/,
     & ' *********************************************************',/,
     & '  SHOCK 5 Model Completed',/,
     & ' *********************************************************',/)
c
      iterations=3
      ieln=4
c
      call shock5setup   (iterations)
      call shock5headers (iterations)
c
      iterationindex=0
      converged=0
      finalit=0
c
      if (iterations.le.1) finalit=1
c
      call compsh5 (0, iterations)
c
      if (iterations.gt.1) then
c
   40   iterationindex=iterationindex+1
c
        write (*,10) iterationindex,iterations
c
        call shock5precursor (iterationindex, iterations)
        call compsh5 (iterationindex, iterations)
        call shock5check (iterationindex, iterations)
c
        write (*,20) iterationindex,iterations
c
        if ((converged.eq.0).and.(iterations.lt.mxshockits)) goto 40
c
c repeat a final model for outputs
c
        finalit=1
        iterationindex=iterationindex+1
c
        call shock5precursor (iterationindex, iterationindex)
        call compsh5         (iterationindex, iterationindex)
        call shock5check     (iterationindex, iterationindex)
c
      endif
c
      call closeS5files()
c
      write (*,30)
c
      return
c
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine shock5setup (iterations)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Run the user initialisation and set global flags
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 iterations,i,nl,nel,elok(mxelem)
      integer*4 idx,npx
      real*8 vapprox,tpr,tpo,va,eps
      character outsettings*64,outshow*64
      character px*32,readname*32
c
c functions
c
      real*8 feldens,fpresse
      real*8 frho,velshock2
      integer*4 mlen
c
   10 format(a)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      photonmode=1
c
c clear everything first
c
      call zer ()
c
c   calculation modes - older so YES not Y
c
      jspot='N'
      jcon='Y'
c
      ispo='SII'
c
      jden='B'
      jgeo='P'
      wdil=0.5d0
c
      jtrans='LODW'
      specmode='DW'
      alphacoolmode=0
c
      subname='Shock 5'
      jnorm=0
c
      mtype='A'
      magparam=0.d0
      Pmag=0.0d0
      Bmag=0.d0
c
      vmod='NONE'
      s5pfx='v100sh'
      nprefix=6
      useprecfile=1
c
      wdil=0.5d0
      wdilt0=1.d4
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     INTRO - Define Input Parameters
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   20 format(///,
     & ' ********************************************************'/
     & ' SHOCK 5 model selected:',/,
     & ' Shock code with auto-preionisation.',/,
     & ' ********************************************************')
      write (*,20)
c
c     get ionisation balance to work with...
c
      subname='proto-ionisation'
      call popcha (subname)
      call copypop (pop0, pop)
      call copypop (pop0, pop_neu)
      call copypop (pop0, pop_pre)
      call copypop (pop0, pop_pre0)
      call zeroemiss
      subname='Shock 5'
c
c     set up current field conditions
c
      call photsou (subname)
      do i=1,infph
        prefield(i)=soupho(i)
      enddo
c
c     Shock model preferences
c
   30 format(///,
     & ' ********************************************************'/
     & ' Setting the shock conditions',/,
     & ' ********************************************************'/)
      write (*,30)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Shock Jump Definition
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      stype='V'
   40 format(//,
     & ' Choose Shock Jump Parameter:',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    T  : Shock jump in terms of Temperature jump',/,
     & '    V  : Shock jump in terms of flow Velocity.',//,
     & ' :: ',$)
c
   50 write (*,40)
      read (*,10) stype
      call toup(stype(1:1),stype)
c
      if ((stype.ne.'T').and.(stype.ne.'V')) goto 50
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Shock Magnetic Field Parameters
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      magparam=1.0d0
      malpha=1.0d0
      mageta=1.0d0
      mmach=0.d0
c
      mtype='B'
   60 format(//,
     & ' Choose Shock Magnetic Parameter Type:',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    B  : Magnetic field in microGauss at shockfront',/,
     & '    A  : Magnetic Alpha_0 = Pmag/Pgas in protostate',/,
     & '    M  : Magnetic Alfven Mach Number, Ma',/,
     & '    C  : Magnetic Alpha Pmag/Pgas at shockfront',/,
     & '    R  : Magnetic Eta 2Pmag/Pram =1/Ma^2 at shockfront',/,
     & ' :: ',$)
   70 write (*,60)
      read (*,10) mtype
      call toup(mtype(1:1),mtype)
c
      if ((mtype.ne.'A').and.
     &    (mtype.ne.'B').and.
     &    (mtype.ne.'C').and.
     &    (mtype.ne.'M').and.
     &    (mtype.ne.'R')) goto 70
c
      if (mtype.eq.'B') then
c       Preshock magnetic field at shockfront in uG
   80   format(//,
     & ' Specify the magnetic field at shockfront, B: ',/,
     & ' (microgauss): ', $ )
        write (*,80)
        read (*,*) magparam
        Bmag=dabs(magparam)
        magparam=Bmag
        Bmag=Bmag*1e-6
        Pmag=(Bmag*Bmag)/epi
      endif
c
      if (mtype.eq.'A') then
c     Preshock magnetic fields expressed as Alpha = Pmag/Pgas
c     Alpha = 1.0 is equipartition, Alpha = 10.0 is strong magnetic
c     Alpha = 0.1 is weak magnetic field. Alpha = 0.0 is no magnetic
   90   format(//,
     & ' Specify the magnetic Alpha_0 in proto-state',/,
     & ' ( >= 0.0: Pmag/Pgas): ', $)
        write (*,90)
        read (*,*) magparam
        malpha=magparam
        if (magparam.lt.0.0d0) then
          Bmag=-magparam
          Bmag=Bmag*1e-6
          Pmag=(Bmag*Bmag)/epi
          mtype='B'
          magparam=dabs(magparam)
          mageta=1.0d0
          malpha=1.0d0
        endif
      endif
c
      if (mtype.eq.'C') then
  100   format(//,
     & ' Specify the magnetic Alpha at shockfront',/,
     & ' ( >= 0.0: Pmag/Pgas): ', $)
        write (*,100)
        read (*,*) magparam
        malpha=magparam
        if (magparam.lt.0.0d0) then
          Bmag=-magparam
          Bmag=Bmag*1e-6
          Pmag=(Bmag*Bmag)/epi
          mtype='B'
          magparam=dabs(magparam)
          mageta=1.0d0
          malpha=1.0d0
          mmach=0.d0
        endif
      endif
c
      if (mtype.eq.'M') then
c       Preshock magnetic field expressed as magnetic Alfven Mach number
  110   format(//,
     & ' Specify the magnetic Alfven Mach Number, Ma',/,
     & ' ( v/sqrt(Pmag/rho), Ma>= 0.0 ) ', $)
        write (*,110)
        read (*,*) magparam
        mmach=magparam
        if (magparam.lt.0.0d0) then
          Bmag=-magparam
          Bmag=Bmag*1e-6
          Pmag=(Bmag*Bmag)/epi
          mtype='B'
          magparam=dabs(magparam)
          mageta=1.0d0
          malpha=1.0d0
          mmach=0.d0
        endif
      endif
c
      if (mtype.eq.'R') then
c       Preshock magnetic field expressed as magnetic eta.
c       eta = 2Pmag/Pram = 1/Ma^2
c       Pram = rho*vs*vs; Pmag = (B^2)/8pi
  120   format(//,
     & ' Specify the magnetic Eta at shockfront',/,
     & ' ( >= 0.0: 2Pmag/Pram): ', $)
        write (*,120)
        read (*,*) magparam
        mageta=magparam
        if (magparam.lt.0.0d0) then
          Bmag=dabs(magparam)*1e-6
          Pmag=(Bmag*Bmag)/epi
          mtype='B'
          magparam=dabs(magparam)
          mageta=1.0d0
          malpha=1.0d0
          mmach=0.d0
        endif
      endif
c
c always  plane parallel
c
      wdil=0.5d0
      wdilt0=1.d4
c
      if (stype.eq.'V') then
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  Velocity  - Tshock adjusts as presionisation changes
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  130   format(//,
     & ' Specify the proto-shock conditions:',/,
     & '  T (K), dh (N), v (< 1e5 km/s, >= 1e5 cm/s)',/,
     & ' (T<10 taken as a log, dh <= 0 taken as a log),',/,
     & ' : ',$)
        write (*,130)
        read (*,*) t,dh,ve
c
        dr=1.d0
        de=feldens(dh,pop_neu)
c
        if (ve.lt.1.d5) ve=ve*1.d5
        if (t.le.10.d0) t=10.d0**t
        if (dh.le.0.d0) dh=10.d0**dh
c
        Pgas=fpresse(t,de,dh)
        de=feldens(dh,pop_neu)
        rh_neu=frho(de,dh)
        Pram=rh_neu*ve*ve
c
        if (mtype.eq.'B') then
          Bmag=magparam*1.0d-6
          Pmag=(Bmag*Bmag)/epi
        endif
        if (mtype.eq.'A') then
          Pmag=malpha*Pgas
          Bmag=dsqrt(epi*Pmag)
        endif
        if (mtype.eq.'C') then
          Pmag=malpha*Pgas
          Bmag=dsqrt(epi*Pmag)
        endif
        if (mtype.eq.'M') then
          va=ve/mmach
          Pmag=(0.5*rh_neu*va*va)
          Bmag=dsqrt(epi*Pmag)
        endif
        if (mtype.eq.'R') then
          Pmag=0.5d0*mageta*Pram
          Bmag=dsqrt(epi*Pmag)
        endif
c
        vshoc=ve
c
        bm_neu=Bmag
        te_neu=t
        de_neu=de
        dh_neu=dh
        vs_neu=ve
        pr_neu=fpresse(te_neu,de_neu,dh_neu)
        rh_neu=frho(de_neu,dh_neu)
c
c     fill in other default parameters
c
        dt=0.d0
        tloss=0.d0
c
        call shockcmpf (t, de, dh, ve, Bmag)
c
        tm00=te0
c
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (stype.eq.'T') then
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  Temperature Jump - Adjusts as presionisation changes
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  140   format(//,
     & ' Specify the proto-shock conditions:',/,
     & ' (T<10 taken as a log, dh <= 0 taken as a log)',/,
     & ' T (K), dh (N) : ',$)
        write (*,140)
        read (*,*) tpr,dh
        wdil=0.5d0
c
        if (tpr.le.10.d0) tpr=10.d0**tpr
        if (dh.le.0.0d0) dh=10.d0**dh
c
  150   format(//,
     & ' Specify the post-shock temperature:',/,
     & ' (T<10 taken as a log) T (K) : ',$)
        write (*,150)
        read (*,*) tpo
c
        if (tpo.le.10.d0) tpo=10.d0**tpo
c
        te0=tpr
        te1=tpo
c       Partially set up proto-state
        te_neu=tpr
        dh_neu=dh
        de_neu=feldens(dh_neu,pop_neu)
        Pgas=fpresse(te_neu,de_neu,dh_neu)
        rh_neu=frho(de_neu,dh_neu)
c
        if (mtype.eq.'B') then
          Bmag=magparam*1.0d-6
          Pmag=(Bmag*Bmag)/epi
        endif
        if (mtype.eq.'A') then
          Pmag=malpha*Pgas
          Bmag=dsqrt(epi*Pmag)
        endif
        if (mtype.eq.'C') then
          Pmag=malpha*Pgas
          Bmag=dsqrt(epi*Pmag)
        endif
c
        vapprox=velshock2(dh_neu,tpr,0.d0,tpo)
        rh_neu=frho(de_neu,dh_neu)
        Pram=rh_neu*vapprox*vapprox
        if (mtype.eq.'R') then
          Pmag=0.5d0*mageta*Pram
          Bmag=dsqrt(epi*Pmag)
        endif
c
c       We need to iterate for a consistent solution.  We have the
c       density and T jump; solve for shock speed and magnetic field.
c
  160   bm0=Bmag
c
        vshoc=velshock2(dh_neu,tpr,Bmag,tpo)
        ve=vshoc
        Pram=rh_neu*ve*ve
c
        if (mtype.eq.'M') then
          va=vshoc/mmach
          Pmag=(0.5*rh_neu*va*va)
          Bmag=dsqrt(epi*Pmag)
          eps=dabs(2.0*(Bmag-bm0)/(Bmag+bm0))
          if (eps.gt.1.0d-6) goto 160
        endif
c
        if (mtype.eq.'R') then
c
c iterate for rampressure/alpha_r
c
          Pmag=0.5d0*mageta*Pram
          Bmag=dsqrt(epi*Pmag)
c           write(*,*) vshoc,Pram,Pmag,bm0,Bmag,te1
          eps=dabs(2.0*(Bmag-bm0)/(Bmag+bm0))
C         write (*,*) eps,Bmag,bm0
          if (eps.gt.1.0d-6) goto 160
        endif
c
        dt=0.d0
        tloss=0.d0
c
        call shockcmpf (te_neu, de_neu, dh_neu, ve, Bmag)
c
        tm00=te0
        bm_neu=Bmag
        vs_neu=vshoc
        pr_neu=fpresse(te_neu,de_neu,dh_neu)
        rh_neu=frho(de_neu,dh_neu)
c
      endif
c
c all shocks - powerlaw cooling for testing
c
      if (alphacoolmode.eq.1) then
  170  format(//,
     & ' Powerlaw Cooling enabled  Lambda T6 ^ alpha :',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    Give index alpha, Lambda at 1e6K',/,
     & '    (Lambda<0 as log)',/,
     & ' :: ',$)
        write (*,170)
        read (*,*) alphaclaw,alphac0
        if (alphac0.lt.0.d0) alphac0=10.d0**alphac0
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Shock intial state kept for iterations, above numbers are
c reused from step to step
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      te_pre=te0
      te_pst=te1
      de_pre=de0
      de_pst=de1
      dh_pre=dh0
      dh_pst=dh1
      vs_pre=vel0
      vs_pst=vel1
c
      rh_pre=rho0
      rh_pst=rho1
      pr_pre=pr0
      pr_pst=pr1
      bm_pre=bm0
      bm_pst=bm1
      bp0=(bm0*bm0)/epi
      bp1=(bm1*bm1)/epi
c
      Pmag=bp0
      Pgas=pr0
      Pram=rho0*vel0*vel0
c
      machnumber=vel0/dsqrt(gammaEOS*pr0/rho0)
      alfvennumber=vel0/dsqrt(2.0d0*Pmag/rho0)
      malpha=Pmag/Pgas
      gaseta=gammaEOS*Pgas/Pram
      mageta=2.d0*Pmag/Pram
c
      call shocksummary (6)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c set intial shock vars
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      cmpf0=cmpf
      psi0=0.0d0
      psi=0.0d0
c
      te_pre0=te_pre
      de_pre0=de_pre
      dh_pre0=dh_pre
      vs_pre0=vs_pre
      rh_pre0=rh_pre
      pr_pre0=pr_pre
      bm_pre0=bm_pre
c
      te_pst0=te_pst
      de_pst0=de_pst
      dh_pst0=dh_pst
      vs_pst0=vs_pst
      rh_pst0=rh_pst
      pr_pst0=pr_pst
      bm_pst0=bm_pst
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Diffuse field interaction
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      photonmode=1
c
  180 format(//,
     & ' Choose Diffuse Field Option :',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    F  : Full diffuse field interaction (Default).',/,
     & '    Z  : Zero diffuse field interaction.',/,
     & ' :: ',$)
  190 write (*,180)
      read (*,10) ilgg
      call toup(ilgg(1:1),ilgg)
c
      if ((ilgg.ne.'Z').and.(ilgg.ne.'F')) goto 190
c
      if (ilgg.eq.'Z') photonmode=0
      if (ilgg.eq.'F') photonmode=1
      photofraction=1.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  200 format(//,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Calculation Limit Settings ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)

      write (*,200)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Set up time step limits
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      tmod='A'
c
c no longer used directly, may return in the future
c
      atimefrac=0.0250d0
      cltimefrac=0.0250d0
      abtimefrac=0.5d0
      utime=0.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  210 format(//,
     & ' ********************************************************'/
     & '  Boundry Conditions  '/
     & ' ********************************************************'/)
      write (*,210)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Choose ending conditions
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  220 format(/,
     & '  Model Ending Condition:',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Standard ending, 1% weighted ionisation',/,
     & '    B  : Species ionisation limit',/,
     & '    C  : Temperature limit',/,
     & '    S  : Temperature limit, and >95% neutral',/,
     & '    D  : Distance limit',/,
     & '    E  : Time limit',/,
     & '    F  : Thermal balance limit',/,
     & '    G  : Heating limit',/,
     & ' :: ',$)
c
  230 write (*,220)
      read (*,10) jend
      call toup(jend(1:1),jend)
c
      if ((jend.ne.'A')
     &.and.(jend.ne.'B')
     &.and.(jend.ne.'C')
     &.and.(jend.ne.'D')
     &.and.(jend.ne.'E')
     &.and.(jend.ne.'F')
     &.and.(jend.ne.'G')
     &.and.(jend.ne.'S')) goto 230
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Secondary info:
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (jend.eq.'B') then
  240   format(//,
     & ' Give atom, ion and limit fraction: ',/,
     & ' (eg 1 2 0.05 = stop when HII < 0.05): ',$)
        write (*,240)
        read (*,*) ielen,jpoen,fren
      endif
      if ((jend.eq.'C').or.(jend.eq.'S')) then
  250   format(//,
     & ' Give final temperature (K > 10, log <= 10): ',$)
        write (*,250)
        read (*,*) tend
        if (tend.le.10.d0) tend=10.d0**tend
      endif
      if (jend.eq.'D') then
  260   format(//,
     & ' Give final distance (cm > 100, log<=100): ',$)
        write (*,260)
        read (*,*) diend
        if (diend.le.100.d0) diend=10.d0**diend
      endif
      if (jend.eq.'E') then
  270   format(//,
     & ' Give time limit (s > 100, log<=100): ',$)
        write (*,270)
        read (*,*) timend
        if (timend.le.100.d0) timend=10.d0**timend
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  280   format(//,
     & '  Choose the minimum number of shock iterations:',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' (<= 1, no iterations) : ',$)
      write (*,280)
      read (*,*) iterations
      if (iterations.le.0) iterations=1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  290 format(//,
     & ' ********************************************************'/
     & '  Output Requirements  '/
     & ' ********************************************************'//)
      write (*,290)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     get final field file prefix
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      readname='.               '
      s5pfx='.               '
  300 format (a16)
  310 format(//,
     & ' Give a prefix for all output files (max 8 chars): ')
      write (*,310)
      read (*,300) readname
      call mytrim (readname, npx, px)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    New output options menu including reset like in shock5files
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call shock5filenames (px)
c
  320 jspec='N'
c
c     Ion Balances
c
      tsrmod='N'
      allmod='N'
c
c    dynamics file
c
      dynmod='N'
c
c    rates file
c
      ratmod='N'
c
c     emission bands
c
      bandsmod='N'
c
c     Cooling Components
c
      fclmod='N'
c
c    monitor 16 lines
c
      jlin='N'
c
c     Upstream fields
c
      lmod='N'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Spectra: F-Lambda plots, ionising and optical default yes
c
  330 outsettings='A'
c
c     Ion Balances
c
      if (tsrmod.eq.'Y') then
        call myappend (outsettings, '+B', outshow)
        outsettings=outshow
      endif
c
c    rates file
c
      if (ratmod.eq.'Y') then
        call myappend (outsettings, '+C', outshow)
        outsettings=outshow
      endif
c
c    dynamics file
c
      if (dynmod.eq.'Y') then
        call myappend (outsettings, '+D', outshow)
        outsettings=outshow
      endif
c
c    final downstream field
c
      if (jspec.eq.'Y') then
        call myappend (outsettings, '+E', outshow)
        outsettings=outshow
      endif
c
c    all up stream fields
c
      if (lmod.eq.'Y') then
        call myappend (outsettings, '+F', outshow)
        outsettings=outshow
      endif
c
c     emission bands
c
      if (bandsmod.eq.'Y') then
        call myappend (outsettings, '+H', outshow)
        outsettings=outshow
      endif
c
c     Cooling Components
c
      if (fclmod.eq.'Y') then
        call myappend (outsettings, '+K', outshow)
        outsettings=outshow
      endif
c
c    monitor 16 lines
c
      if (jlin.eq.'Y') then
        call myappend (outsettings, '+L', outshow)
        outsettings=outshow
      endif
c
  340 format(//,
     & ' Output Multi-Option Menu : ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' :: Current: ',a20,'                       ::',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Standard output - and Reset. ',/,
     & '    B  : Ion balance files.',/,
     & '    C  : All Rates file.',/,
     & '    D  : Dynamics file.',/,
     & '    E  : Final downstream field.',/,
     & '    F  : All upstream fields at each step.',/,
     & '    H  : Cooling in x-ray bands.',/,
     & '    K  : Cooling Components by Elements file.',/,
     & '    L  : Monitor up to ',i3,' lines'/
     & '       :',/,
     & '    R  : Reset',/,
     & '    X  : Exit with Settings',/,
     & ' :: ',$)
  350 write (*,340) outsettings,mxmonlines
      read (*,10) ilgg
      call toup(ilgg(1:1),ilgg)
      write(*,*)
c
      if (ilgg.eq.'Q') ilgg='X'
c
      if ((ilgg.ne.'A')
     &.and.(ilgg.ne.'B')
     &.and.(ilgg.ne.'C')
     &.and.(ilgg.ne.'D')
     &.and.(ilgg.ne.'E')
     &.and.(ilgg.ne.'F')
     &.and.(ilgg.ne.'H')
     &.and.(ilgg.ne.'K')
     &.and.(ilgg.ne.'L')
     &.and.(ilgg.ne.'R')
     &.and.(ilgg.ne.'X')) goto 350
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (ilgg.eq.'A') goto 320
      if (ilgg.eq.'B') tsrmod='Y'
      if (ilgg.eq.'C') dynmod='Y'
      if (ilgg.eq.'D') ratmod='Y'
      if (ilgg.eq.'E') jspec='Y'
      if (ilgg.eq.'F') lmod='Y'
      if (ilgg.eq.'H') bandsmod='Y'
      if (ilgg.eq.'K') fclmod='Y'
      if (ilgg.eq.'L') jlin='Y'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (ilgg.eq.'R') goto 320
      if (ilgg.ne.'X') goto 330
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     B Ion balance files tsrmod, allmod
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     default monitor elements
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      ieln=4
      iel(1)=zmap(1)
      iel(2)=zmap(2)
      iel(3)=zmap(8)
      iel(4)=zmap(16)
c
      allmod='N'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (tsrmod.eq.'Y') then
c
  360   format(//' Monitor ions/columns of max ',i2,' elements:',/
     & '::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
  365   format(' Enter number of elements to track : ',$)
  366   format(/' Elements (Z) : ',$)
        write (*,360) atypes
        write (*,365)
        read (*,*) ieln
        ieln=min(max(ieln,1),atypes)
        write (*,366)
        read (*,*) (iel(i),i=1,ieln)
        do i=1,ieln
           elok(ieln)=0
           do idx=1,atypes
              if (iel(i).eq.mapz(idx)) elok(i)=1
           enddo
        enddo
        nel=ieln
        do i=1,ieln
           if (elok(i).eq.0) nel=idx-1
        enddo
        if (nel.lt.1) tsrmod='N'
        if (tsrmod.eq.'Y') then
        ieln=nel
        do i=1,ieln
           iel(i)=zmap(iel(i))
        enddo
  367   format(/' Monitoring :',30(x,a2),/)
        write(*,367) (elem(iel(i)),i=1,ieln)
c
  370   format(/,' Record all ions file (Y/N)? : ',$)
  375   write (*,370)
        read (*,10) allmod
        call toup(allmod(1:1),allmod)
        if ((allmod.ne.'Y').and.(allmod.ne.'N')) goto 375
      endif
c
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    C timescales and rates file
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     no specific setup - fixed format
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    D flow dynamics file, dynmod
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     no specific setup - fixed format
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Spec List Files - always on
c
c     no specific setup - fixed format
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Upstream fields lmod = Y/N
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c no specific setup - fixed format units from wpsou
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     F-Lambda plots, ionising and optical  jspec = 'Y'/'N'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c no specific setup - fixed format units from wpsou
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Cooling Components File, fclmod
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (fclmod.eq.'Y') then
        jnorm=0
  410  format (' Cooling File Normalisation,',/
     & ' (0=ne.nH, 1=nH^2, 2=ne.ni, 3=n^2, 4=ne^2): ',$)
        write (*,410)
        read (*,*) jnorm
        if (jnorm.lt.0) jnorm=0
        if (jnorm.gt.4) jnorm=0
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    monitor 16 lines, jlin
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      njlines=0
      if (jlin.eq.'Y') then
c
  380   format('   ',a3,a6,' ',f12.3)
  385   format(//' Select up to ',i3,' lines by (A, incl air)   :',/
     & '::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
  390   format(' Enter number of lines to track: ',$)
        write (*,385) mxmonlines
        write (*,390)
        read (*,*) nl
        nl=min(max(nl,1),mxmonlines)
        njlines=nl

  395   format(/' Wavelengths (see spec list files) : ',$)
        write (*,395)
        read (*,*) (emlinlist(i),i=1,njlines)
        do i=1,mxmonlines
          emlindeltas(i)=0.001d0
        enddo
        call speclocallineids (emlinlistatom, emlinlistion)

  396   format(/' Monitoring :')
        write(*,396)
        do i=1,njlines
           write(*,380)
     &    elem(emlinlistatom(i)),
     &    rom(emlinlistion(i)),
     &    emlinlist(i)
        enddo

      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     get screen display mode
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  420 format(//,
     & ' Runtime screen display:',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Standard display ',/,
     & '    B  : Detailed Slab display.',/,
     & '    C  : Full Display (Full slab display + timescales).',/,
     & '    M  : Minimal Display (batch mode).',/,
     & ' :: ',$)
      write (*,420)
      read (*,10) ilgg
      call toup(ilgg(1:1),ilgg)
c
      vmod='NONE'
      if (ilgg.eq.'A') vmod='MINI'
      if (ilgg.eq.'B') vmod='SLAB'
      if (ilgg.eq.'C') vmod='FULL'
      if (ilgg.eq.'M') vmod='NONE'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     get runname
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  430 format(//,
     & ' Set a name/code for this model: ',$)
      write (*,430)
      read (*,'(a)') runname
      np=mlen(runname)
      runname=runname(1:np)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Create User and open main model files
c
      call createS5files ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine shock5headers (iterations)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 i,j,iterations
      integer*4 itr
      character tab*1
c
c function
c
      real*8 feldens
c
      tab=','
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Write Headers, open files to write
c
      call appendS5files()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      de=feldens(dh,pop)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Title
c
   10 format(//,
     & ' SHOCK 5: Steady Rankine-Hugoniot Shock Model ',/,
     & ' ============================================',/,
     & ' Diffuse Field, Full Continuum Calculations.',/,
     & ' Global Shock-Precursor Iterations: ',i2,/,
     & ' Calculated by MAPPINGS V ',a8)
      write (*,10) iterations,theversion
      write (luop,10) iterations,theversion
      write (lupt,10) iterations,theversion
      write (lusp,10) iterations,theversion
      if (ratmod.eq.'Y') write (lurtsh,10) iterations,theversion
      if (dynmod.eq.'Y') write (ludy,10) iterations,theversion
      if (tsrmod.eq.'Y') then
        do i=1,ieln
          write (luionsh(i),10) iterations,theversion
        enddo
      endif
      if (allmod.eq.'Y') write (lualsh,10) iterations,theversion
      if (fclmod.eq.'Y') write (lucl,10) iterations,theversion
      if (jlin.eq.'Y') write (lulsh,10) iterations,theversion
      if (bandsmod.eq.'Y') write (lupb,10) iterations,theversion
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  put runname string and master file name in each file created
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   20 format(//' Run  :',a,/
     & ' File :',a)
      write (luop,20) runname,fsm
      write (lupt,20) runname,fsm
      write (lusp,20) runname,fsm
      if (ratmod.eq.'Y') write (lurtsh,20) runname,fsm
      if (dynmod.eq.'Y') write (ludy,20) runname,fsm
      if (tsrmod.eq.'Y') then
        do i=1,ieln
          write (luionsh(i),20) runname,fsm
        enddo
      endif
      if (allmod.eq.'Y') write (lualsh,20) runname,fsm
      if (fclmod.eq.'Y') write (lucl,20) runname,fsm
      if (jlin.eq.'Y') write (lulsh,20) runname,fsm
      if (bandsmod.eq.'Y') write (lupb,20) runname,fsm
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Write Model Parameters
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   30 format(//,
     & ' Model Parameters:',/,
     & ' =================',//,
     & ' Abundances     : ',a128,/,
     & ' Pre-ionisation : ',a128,/,
     & ' Photon Source  : ',a128)
   40 format(/,' Charge Exchange: ',a12,/,
     & ' Photon Mode    : ',a12,/,
     & ' Collision calcs: ',a12)
   50 format(/,' Charge Exchange: ',a12,/,
     & ' Photon Mode    : ',a12,/,
     & ' Collision calcs: ',a12,/,
     & ' Electron Kappa : ',1pg11.4)
   60 format(//' ',t2,'Jden',t9,'Jgeo',t16,'Jtrans',
     &            t23,'Jend',t29,'Ielen',t35,
     & 'Jpoen',t43,'Fren',t51,'Tend',t57,'DIend',t67,
     & 'TAUen',t77,'Jeq',t84,'Teini')
   70 format('  ',4(a4,3x),2(i2,4x),0pf6.4,0pf6.0,
     &           2(1pg10.3),3x,a4,0pf7.1)
   80 format(//' Photon Source'/
     & ' ============='/)
   90 format(/' MOD',t7,'Temp.',t16,'Alpha',t22,'Turn-on',t30,'Cut-off'
     &,t38,'Zstar',t47,'FQHI',t56,'FQHEI',t66,'FQHEII')
  100 format(' ',a2,1pg10.3,4(0pf7.2),1x,3(1pg10.3))
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (luop,30) abnfile,ionsetup,srcfile
      write (lupt,30) abnfile,ionsetup,srcfile
      write (lusp,30) abnfile,ionsetup,srcfile
c
      if (ratmod.eq.'Y') write (lurtsh,30) abnfile,ionsetup,srcfile
      if (dynmod.eq.'Y') write (ludy,30) abnfile,ionsetup,srcfile
      if (tsrmod.eq.'Y') then
        do i=1,ieln
          write (luionsh(i),30) abnfile,ionsetup,srcfile
        enddo
      endif
      if (allmod.eq.'Y') write (lualsh,30) abnfile,ionsetup,srcfile
      if (fclmod.eq.'Y') write (lucl,30) abnfile,ionsetup,srcfile
      if (jlin.eq.'Y') write (lulsh,30) abnfile,ionsetup,srcfile
      if (bandsmod.eq.'Y') write (lupb,30) abnfile,ionsetup,srcfile
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     abundances file header
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
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
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (usekappa) then
        write (luop,50) cht,pht,clt,kappa
      else
        write (luop,40) cht,pht,clt
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (luop,60)
      write (luop,70) jden,jgeo,jtrans,jend,ielen,jpoen,fren,tend,diend,
     &tauen,tmod,tm00
      write (luop,80)
      write (luop,90)
      write (luop,100) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Shock parameters
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  110 format(//,
     & ' Initial Jump Conditions:',/,
     & ' =========================')
      write (luop,110)
      write (lupt,110)
c
  120 format(//'  T0',1pg14.7,' V0',1pg14.7,/,
     & ' RH0',1pg14.7,' P0',1pg14.7,' B0',1pg14.7,//,
     & '  T1',1pg14.7,' V1',1pg14.7,/,
     & ' RH1',1pg14.7,' P1',1pg14.7,' B1',1pg14.7)
c
      dr=0.d0
      dv=vel1-vel0
c
      write (*,120) te0,vel0*1.d-5,rho0,pr0,bm0*1.d6,te1,
     &   vel1*1.d-5,rho1,pr1,bm1*1.d6
      write (luop,120) te0,vel0*1.d-5,rho0,pr0,bm0*1.d6,te1,
     &   vel1*1.d-5,rho1,pr1,bm1*1.d6
      write (lupt,120) te0,vel0*1.d-5,rho0,pr0,bm0*1.d6,te1,
     &   vel1*1.d-5,rho1,pr1,bm1*1.d6
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      wdilt0=te0
      t=te0
      ve=vel0
      dr=1.0d0
      dv=ve*0.01d0
      fi=1.0d0
      rad=0.0d0
      wdil=0.5d0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     get the electrons...
c
      de=feldens(dh,pop)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     calculate the radiation field and atomic rates
c
      call localem (t, de, dh)
      call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
      call zetaeff (dh)
      call cool (t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call protostate (6)
      call protostate (luop)
      call protostate (lupt)
      call protostate (lusp)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  130 format(//,
     & ' Precursor Conditions and Ionisation State',/
     & ' =========================================',/)
c
      write (luop,130)
      write (lupt,130)
      write (lusp,130)
      call wionpop (luop, pop)
      call wionpop (lupt, pop)
      call wionpop (lusp, pop)
c
C     if (ratmod.eq.'Y') write (lurtsh,130)
C     if (dynmod.eq.'Y') write (ludy,130)
C     if (tsrmod.eq.'Y') then
C       do i=1,ieln
C         write (luionsh(i),130)
C       enddo
C     endif
C     if (allmod.eq.'Y') write (lualsh,130)
C     if (fclmod.eq.'Y') write (lucl,130)
C     if (jlin.eq.'Y') write (lulsh,130)
Cc
C     if (ratmod.eq.'Y') call wionpop (lurtsh, pop)
C     if (dynmod.eq.'Y') call wionpop (ludy, pop)
C     if (tsrmod.eq.'Y') then
C       do i=1,ieln
C         call wionpop (luionsh(i), pop)
C       enddo
C     endif
C     if (allmod.eq.'Y') call wionpop (lualsh, pop)
C     if (fclmod.eq.'Y') call wionpop (lucl, pop)
C     if (jlin.eq.'Y') call wionpop (lulsh, pop)
C     if (bandsmod.eq.'Y') call wionpop (lupb, pop)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (ratmod.eq.'Y') then
        call wmodel (lurtsh, 0.d0, 0.0d0, 0.d0, 0.0d0, 'LOSH')
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (tsrmod.eq.'Y') then
c
c B  : Ion balance files.'
c
  140  format(//,
     & ' #[1], [2] <X>     , [3] DeltaX  , [4] t       , [5] dt      ,',
     & '  [6] <T>    , [7] <ne>    , [8] <nH>    , [9] <nT>    ,',
     & 31(' [',i2,'] ', a6,' ,'))
        do i=1,ieln
          write (luionsh(i),'(//," Element : ",a2)') elem(iel(i))
          write (luionsh(i),140) (j+9,rom(j),j=1,maxion(iel(i)))
        enddo
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  160 format(//,
     & 17(a12,a1))
      if (bandsmod.eq.'Y') then
        write (lupb,160) 'Te',tab,'de',tab,'dh',tab,'en',tab,'XHI',tab,'
     &XHII',tab,'mu',tab,'tloss',tab,'Lambda',tab,'ff/total',tab,'BHI-0
     &.1keV',tab,'B0.1-0.5keV',tab,'B0.5-1.0keV',tab,'B1.0-2.0eV',tab,'B
     &2.0-10.0keV',tab,'Ball'
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  170 format(/'Mean Zone Values'/
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
     & ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     &.nH)',tab,(elem(j),tab,j=1,atypes),'Eloss/ne.nH',tab,'Egain/ne.nH'
     &     ,tab,'Netloss/ne.nH'
c     &    (elem(j),tab,j=1,atypes)
        endif
        if (jnorm.eq.1) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(nH
     &^2)',tab,(elem(j),tab,j=1,atypes),'Eloss/nH^2',tab,'Egain/nH^2',
     &     tab,'Netloss/nH^2'
c     &    (elem(j),tab,j=1,atypes)
        endif
        if (jnorm.eq.2) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     &.ni)',tab,(elem(j),tab,j=1,atypes),'Eloss/ne.ni',tab,'Egain/ne.ni'
     &     ,tab,'Netloss/ne.ni'
        endif
        if (jnorm.eq.3) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(n^
     &2)',tab,(elem(j),tab,j=1,atypes),'Eloss/n2',tab,'Egain/n2',tab,'Ne
     &tloss/n2'
c     &2)',tab,(elem(j),tab,j=1,atypes),'L_5007',tab,'LHalpha',tab,'LLyal
c     &pha'
c     &    (elem(j),tab,j=1,atypes)
        endif
        if (jnorm.eq.4) then
          write (lucl,180) 'T ',tab,'n_e',tab,'n_H',tab,'n_ion',tab,'rho
     & ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     &^2)',tab,(elem(j),tab,j=1,atypes),'L_5007',tab,'LHalpha',tab,'LLya
     &lpha'
c     &    (elem(j),tab,j=1,atypes)
        endif
        write (lucl,190) '(K)',tab,'(/cm^3)',tab,'(/cm^3)',tab,'(/cm^3)'
     &   ,tab,'(g/cm^3)',tab,' ',tab,' ',tab,'(amu)',tab,'(erg/cm^3/s)',
     &   tab,'(erg cm^3/s)',tab,('(erg cm^3/s)',tab,j=1,atypes),'(erg cm
     &^3/s)',tab,'(erg cm^3/s)',tab,'(erg cm^3/s)'
c     &    (elem(j),tab,j=1,atypes)
        write (lucl,200)
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (jlin.eq.'Y') then
c
c L  : Monitor up to ',i3,' lines  - precursor and shocks
c
  210   format(// ,'     ,             ,             ,             ,',
     & '             ,             ,             ,             ',
     &   30(',    ',a2,a6,'    '))
        write (lulsh,'("Run: ",a96)') runname
        write (lulsh,210) (elem(emlinlistatom(itr)),
     &   rom(emlinlistion(itr)),itr=1,njlines)
  220  format(
     & ' # [1] <X>, [2] DeltaX, [3] dX, [4] t, [5] dt,  [6] <T>,'
     & ' [7] <ne>, [8] <nH> , [9]  <nT>, [10] logQH, [11]  logUH,',
     & ' [12]  logQN, [13]   <HB>,',
     &   16(',',f12.3,'[',i2,']'))
        write (lulsh,220) (emlinlist(itr),itr+13,itr=1,njlines)
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call wionabal (luop, pop)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Close all files and flush
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      call closeS5files()
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine shocksummary (lunit)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      real*8 fmua,fpresse,frho
      integer*4 lunit
c
c uses global pop
c
c
c pre = preshock , pst = postshock
c
      te_pre=te0
      te_pst=te1
      de_pre=de0
      de_pst=de1
      dh_pre=dh0
      dh_pst=dh1
      vs_pre=vel0
      vs_pst=vel1
c
      rh_pre=rho0
      rh_pst=rho1
      cmpf=rho1/rho0
      pr_pre=pr0
      pr_pst=pr1
      bm_pre=bm0
      bm_pst=bm1
c
      bp0=(bm0*bm0)/epi
      bp1=(bm1*bm1)/epi
      Pgas=pr0
      Pmag=bp0
      Pram=rh_pre*vs_pre*vs_pre
c
      machnumber=vel0/dsqrt(gammaEOS*pr0/rho0)
      alfvennumber=vel0/dsqrt(2.d0*Pmag/rho0)
      malpha=Pmag/Pgas
      gaseta=gammaEOS*Pgas/Pram
      mageta=2.d0*Pmag/Pram
c
   10   format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    Velocity       :',1pg12.5,' km/s',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    Preshock Mach Number          :',1pg12.5,/,
     & '    Preshock Alfven Mach Number   :',1pg12.5,/,
     & '    Preshock Mag Alpha (Pmag/Pgas):',1pg12.5,/,
     & '    Preshock Gas Eta  (gPgas/Pram):',1pg12.5,/,
     & '    Preshock Mag Eta  (2Pmag/Pram):',1pg12.5,//,
     & '    Preshock     T :',1pg12.5,' K',/,
     & '    Preshock     ne:',1pg12.5,' cm^-3',/,
     & '    Preshock     nH:',1pg12.5,' cm^-3',/,
     & '    Preshock     d :',1pg12.5,' g/cm^-3',/,
     & '    Preshock   Pgas:',1pg12.5,' dyne/cm^2',/,
     & '    Preshock     mu:',1pg12.5,' a.m.u.',/,
     & '    Preshock    XHI:',1pg12.5,/,
     & '    Preshock   XHII:',1pg12.5,/,
     & '    Preshock   XHeI:',1pg12.5,/,
     & '    Preshock  XHeII:',1pg12.5,/,
     & '    Preshock XHeIII:',1pg12.5,/,
     & '    Preshock     B :',1pg12.5,' microGauss',/,
     & '    Preshock   Pmag:',1pg12.5,' dyne/cm^2',/,
     & '    Preshock   Pram:',1pg12.5,' dyne/cm^2',/)
   20   format(
     & '    Postshock Compression Factor   :',1pg12.5,/,
     & '    Postshock    T :',1pg12.5,' K',/,
     & '    Postshock    ne:',1pg12.5,' cm^-3',/,
     & '    Postshock    nH:',1pg12.5,' cm^-3',/,
     & '    Postshock    v :',1pg12.5,' km/s',/,
     & '    Postshock    d :',1pg12.5,' g/cm^-3',/,
     & '    Postshock  Pgas:',1pg12.5,' dyne/cm^2',/,
     & '    Postshock    B :',1pg12.5,' microGauss',/,
     & '    Postshock  Pmag:',1pg12.5,' dyne/cm^2',/,
     & '    Postshock  Pram:',1pg12.5,' dyne/cm^2',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)

c
      en=zen*dh0
      pr0=fpresse(te0,de0,dh0)
      rho0=frho(de0,dh0)
      cspd=dsqrt(gammaEOS*pr0/rho0)
      wmol=rho0/(en+de0)
      mu=fmua(de0,dh0)
c
      Pgas=pr0
      Pmag=(bm0*bm0)/epi
      Pram=rho0*vel0*vel0
c
      machnumber=vel0/dsqrt(gammaEOS*pr0/rho0)
      alfvennumber=vel0/dsqrt(2.0d0*Pmag/rho0)
      malpha=Pmag/Pgas
      gaseta=gammaEOS*Pgas/Pram
      mageta=2.d0*Pmag/Pram
c
      write (lunit,10) vel0*1.0d-5,machnumber,alfvennumber,malpha,
     &gaseta,mageta,te0,de0,dh0,rho0,pr0,mu,pop(1,zmap(1)),pop(2,zmap(1)
     &),pop(1,zmap(2)),pop(2,zmap(2)),pop(3,zmap(2)),bm0*1.d6,bp0,Pram
c
      Pram=rho1*vel1*vel1
      write (lunit,20) cmpf,te1,de1,dh1,vel1*1d-5,rho1,pr1,bm1*1.d6,bp1,
     &Pram
c
      return
      end
c
      subroutine shock5jump ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      real*8 tj,dej,dhj,tpo,va,eps
      real*8 feldens,fpresse,frho,velshock2
c
c     Now get revised shock solution for changed pre shock values:
c     Shock in term of flow velocity
c
      call copypop (pop_neu, pop)
      rh_neu=frho(de_neu,dh_neu)
      call copypop (pop_pre, pop)
      rh_pre=frho(de_pre,dh_pre)
c
      Pram=rh_pre*vs_pre*vs_pre
c
      if (stype.eq.'V') then
c
        dr=1.d0
c
        if (mtype.eq.'B') then
c         Specified B field in uG.  Won't change between iterations.
          Bmag=magparam*1.0d-6
          Pmag=(Bmag*Bmag)/epi
        endif
c
        if (mtype.eq.'A') then
c         Specified protostate malpha. B won't change between iterations
          Pram=rh_neu*vs_pre*vs_pre
          Pgas=fpresse(te_neu,de_neu,dh_neu)
          Pmag=magparam*Pgas
          Bmag=dsqrt(epi*Pmag)
        endif
c
        if (mtype.eq.'C') then
c         Specified shockfront malpha.  B will change between iterations
c         as the gas pressure at the back of the precursor changes.
          Pgas=fpresse(te_pre,de_pre,dh_pre)
          Pmag=magparam*Pgas
          Bmag=dsqrt(epi*Pmag)
        endif
c
        if (mtype.eq.'M') then
c         Specified Alfven Mach number
          va=vs_pre/mmach
          Pmag=(0.5*rh_pre*va*va)
          Bmag=dsqrt(epi*Pmag)
        endif
c
        if (mtype.eq.'R') then
c         Specified magnetic eta = 2Pmag/Pram.  Bmag shouldn't change
c         between iterations since Pram doesn't change.
          Pmag=0.5d0*mageta*Pram
          Bmag=dsqrt(epi*Pmag)
        endif
c
        bm_pre=Bmag
c
c       Now call post-shock state always P_pre, alpha may change for A
c
c        vshoc=vs_pre
c
        tj=te_pre
        dhj=dh_pre
        dej=de_pre
c
c jump is the new exact quadratric with no dx time or losses
c pre and post 0,1 globals are set in routine
c
        call shockcmpf (tj, dej, dhj, vshoc, Bmag)
c
        tm00=te0
c
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Shock in term of temperature
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (stype.eq.'T') then
c
        dr=1.d0
c
c
        if (mtype.eq.'B') then
c         Specified B field in uG.  Won't change between iterations.
          Bmag=magparam*1.0d-6
          Pmag=(Bmag*Bmag)/epi
        endif
c
        if (mtype.eq.'A') then
c         Specified malpha in protostate
          Pgas=fpresse(te_neu,de_neu,dh_neu)
          Pmag=magparam*Pgas
          Bmag=dsqrt(epi*Pmag)
        endif
c
        if (mtype.eq.'C') then
c         Specified shockfront malpha.  B will change between iterations
c         as the gas pressure at the back of the precursor changes.
          Pram=rh_neu*vs_pre*vs_pre
          Pgas=fpresse(te_pre,de_pre,dh_pre)
          Pmag=magparam*Pgas
          Bmag=dsqrt(epi*Pmag)
        endif
c
        if (mtype.eq.'M') then
          va=vs_pre/mmach
          Pmag=(0.5*rh_pre*va*va)
          Bmag=dsqrt(epi*Pmag)
        endif
c
        if (mtype.eq.'R') then
          Pmag=0.5d0*mageta*Pram
          Bmag=dsqrt(epi*Pmag)
        endif
c
        bm_pre=Bmag
c
c       Now call velshock2 to find the shock speed
c
        Pgas=fpresse(te_pre,de_pre,dh_pre)
        vshoc=vs_pre
        t=te_pre
        tpo=te_pst
        dh=dh_pre
        de=feldens(dh,pop)
        tloss=0.0d0
        dt=0.0d0
c
   10   bm0=Bmag
c
c       Call function velshock2 to find the new shock speed
c       N.B. velshock2 calls subroutine rankhug
        vshoc=velshock2(dh,t,Bmag,tpo)
c
        Pram=rh_neu*vshoc*vshoc
c
        if (mtype.eq.'M') then
          va=vshoc/mmach
          Pmag=(0.5*rh_pre*va*va)
          Bmag=dsqrt(epi*Pmag)
          eps=dabs(2.0*(Bmag-bm0)/(Bmag+bm0))
          if (eps.gt.1.0d-6) goto 10
        endif
c
        if (mtype.eq.'R') then
c iterate for rampressure/alpha_r
          Pmag=0.5d0*mageta*Pram
          Bmag=dsqrt(epi*Pmag)
          eps=dabs(2.0*(Bmag-bm0)/(Bmag+bm0))
          if (eps.gt.1.0d-6) goto 10
        endif
c
        vs_neu=vel0
        bm_neu=Bmag
        tm00=te0
      endif
c
c Shock intial state kept for iterations, above numbers are
c reused from step to step
c
      te_pre=te0
      te_pst=te1
      de_pre=de0
      de_pst=de1
      dh_pre=dh0
      dh_pst=dh1
      vs_pre=vel0
      vs_pst=vel1
c
      rh_pre=rho0
      rh_pst=rho1
      pr_pre=pr0
      pr_pst=pr1
      bm_pre=bm0
      bm_pst=bm1
c
      bp0=(bm0*bm0)/epi
      bp1=(bm1*bm1)/epi
      Pmag=bp0
      Pgas=pr0
      Pram=rho0*vel0*vel0
c
      machnumber=vel0/dsqrt(gammaEOS*pr0/rho0)
      malpha=Pmag/Pgas
      gaseta=gammaEOS*Pgas/Pram
      mageta=2.d0*Pmag/Pram
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine shock5check (its, maxits)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c     Check if the global shock-precursor iterations have converged.
c     Compares the current iteration with the previous iteration.
c     Saves the current shock state on either side of the shock jump,
c     for a future comparison.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 its,maxits
c
      real*8 delhhe,rmserr,term
c
   10 format(/,
     & ' ********************************************************',/,
     & '  SHOCK 5  Convergence Test, It.: ',i2.2,' of ',i2.2)
   20 format(
     & '  Result: CONVERGED',/,
     & ' ********************************************************',/)
   30 format(
     & '  Result: NOT CONVERGED',/,
     & ' ********************************************************',/)
   40 format(
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    Psi (Q/v): ',  1pg11.4,'  `Psi      : ',  1pg11.4,/,
     & '    Compress : ',  1pg11.4,'  `Compress : ',  1pg11.4,/,
     & '    T_pre    : ',  1pg11.4,'  `T_pre    : ',  1pg11.4,/,
     & '    T_shock  : ',  1pg11.4,'  `T_shock  : ',  1pg11.4,/,
     & '    ne_pre   : ',  1pg11.4,'  `ne_pre   : ',  1pg11.4,/,
     & '    DelH/He  : ',  1pg11.4,'%',/,
     & '    RMS      : ',  1pg11.4,'%',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
      converged=0
c
      if (its.gt.1) then
c
c uses global pop
c
        call difhhe (pop_pre, pop_pre0, delhhe)
        write (*,10) its,maxits
        term=2.d0*(cmpf-cmpf0)/(cmpf+cmpf0)
        rmserr=term*term
        term=2.d0*(te_pre-te_pre0)/(te_pre+te_pre0)
        rmserr=rmserr+(term*term)
        term=2.d0*(te_pst-te_pst0)/(te_pst+te_pst0)
        rmserr=rmserr+(term*term)
        term=2.d0*(de_pre-de_pre0)/(de_pre+de_pre0)
        rmserr=rmserr+(term*term)
        rmserr=rmserr+(delhhe*delhhe)
        rmserr=dsqrt(rmserr/6.d0)

        write (*,40) psi,psi0,cmpf,cmpf0,te_pre,te_pre0,te_pst,te_pst0,
     &   de_pre,de_pre0,delhhe*100.d0,rmserr*100.d0
        if (rmserr.lt.1.d-4) then
          converged=1
          write (*,20)
        else
          converged=0
          if (its.ge.maxits) maxits=maxits+1
          write (*,30)
        endif

      endif
c
c save current shock for next test
c
        call copypop (pop_pre, pop_pre0)
        psi0=psi
        te_pre0=te_pre
        de_pre0=de_pre
        dh_pre0=dh_pre
        vs_pre0=vs_pre
        rh_pre0=rh_pre
        pr_pre0=pr_pre
        bm_pre0=bm_pre
c
        te_pst0=te_pst
        de_pst0=de_pst
        dh_pst0=dh_pst
        vs_pst0=vs_pst
        rh_pst0=rh_pst
        pr_pst0=pr_pst
        bm_pst0=bm_pst
c
        cmpf0=cmpf
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine shock5precursor (iteration, maxits)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      logical iexi
c
      integer*4 i,idx
      integer*4 nfs0,t0lim
      integer*4 iteration,maxits
      integer*4 itcount
c
      character nmod*4,ratemode*4
      character tab*1
c
      real*8 tf
      real*8 dtime,dtimer,pre_par,qh
      real*8 drr,tstep
      real*8 diff,xhfinal
      real*8 rmserr,rmslimit
      real*8 rdvol,irdvol
      real*8 te_0,de_0,dh_0
      real*8 absf
c
c  functions
c
      real*8 feldens,frectim3
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      call appendS5files()
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
   10 format(
     & ' ********************************************************',/,
     & '  SHOCK 5 Precursor Iteration: ',i2.2,' of ',i2.2,/,
     & ' ********************************************************')
      write (   *,10) ,iteration,maxits
      write (lupt,10) ,iteration,maxits
c
      tab=','
      jspot='N'
      jcon='Y'
      ratemode='ALL'
      absf=0.10d0
c
      rmslimit=5.0d-2
      if (iteration.gt.1) rmslimit=2.0d-2
c
      fi=1.0d0
      wdil=0.5d0
      rdvol=1.0d0
      irdvol=1.d0
      vunilog=0.d0
c
      t=te(step)
      de=deel(step)
      dh=dhy(step)
      Bmag=bmg(step)
c
      rad=dist(step)
      dr=dist(step)-dist(step-1)
      dv=veloc(step)-veloc(step-1)
c
      call localem (t, de, dh)
c
      specmode='UP'
      call totphot2 (t, dh, 1.0d38, 1.0d0, 0.0d0, wdil, specmode)
c
      do idx=1,infph
        soupho(idx)=0.d0
c UP mode is upf=1.0d0, need 0.5x
        tphot(idx)=tphot(idx)*0.5d0
        src(idx)=tphot(idx)
      enddo
c
c  lets see what we got:
c
      write(*,*)
      call fieldsummary (6,1,tphot)
      write(*,*)
      call fieldsummary (lupt,1,tphot)
c
c   compare ion front velocity to shock velocity
c
      ve=vshoc
      viofr=qht/(zen*dh_neu)
      psi0=psi
      psi=viofr/vshoc
c just nH
      qh=qht/dh_neu
      pre_par=viofr/ve
c
   20 format(/,' SHOCK 5 Precursor Parameter: ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '     v_shock       : ',  1pg12.5,' km/s',/,
     & '     Q_ions        : ',  1pg12.5,' km/s',/,
     & '     Psi (Q/v)     : ',  1pg12.5,/,
     & '     Q_H           : ',  1pg12.5,' km/s',/,
     & '     Psi_H (Q_H/v) : ',  1pg12.5,/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
c
      write (*,20)
     &  vshoc*1.d-5,viofr*1.d-5,psi,
     &  qh*1.d-5,qh/vshoc
      write (lupt,20)
     &  vshoc*1.d-5,viofr*1.d-5,psi,
     &  qh*1.d-5,qh/vshoc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c setup for precursor iteration, fill arrays with protoionisation
c and opacities
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c to allow outer edge of ion front to evolve in fast ion front case,
c but reset to neutral for each global interation
c
      te_0=te_neu
      de_0=de_neu
      dh_0=dh_neu
c
      call copypop (pop_pre, pop)
c
      t=te_pre
      de=de_pre
      dh=dh_pre
c
      call allrates (t, ratemode)
c
c  stromgren length if front detatches, recomb rate if ionised gas
c
      dtimer=frectim3(dh)*pre_par
      drr=dtimer*ve
c
      call copypop (pop_neu, pop)
c
      t=te_0
      de=de_0
      dh=dh_0
      ve=vshoc
c
      call allrates (t, ratemode)
c
c  go nfs* distance that absorbs 5% of the field in the neutral medium
c  tau = ~ 10.38 for 100 steps ~6.5 for 50 steps
c
c set up absorbsion fractions and attenuations arrays
c setup ion balance arrays too
c
      absf=0.05d0
C     if (finalit.lt.1) then
        nfs=nint(dlog(1.d-4)/dlog(1.d0-absf))
        nfs=min(nfs,mxifsteps)
        dr=1.0d18
        call absdis2 (dh, absf, dr, 0.0d0, pop_neu)
        frdr=nfs*dr
        invnfs=1.d0/dble(nfs)
C     endif
      dtime=frdr/ve
c
      nfs=mxifsteps
      invnfs=1.d0/dble(nfs)
      absf=0.05d0
      call absdis2 (dh, absf, dr, 0.0d0, pop_pre)
      frdr=nfs*dr
c
c
c index 1 is zone at the source, index nfs is outer edge of front zone
c
        call copypop (pop_neu, p1)
        call copypopstep (p1, 1, popfr)
        call clearpop (p1)
        call copypopstep (p1, 1, popintfr)
        fra(1)=absf
        fh(1)=pop_neu(2,1)
        foi(1)=pop_neu(1,zmap(8))
        foii(1)=pop_neu(2,zmap(8))
        foiii(1)=pop_neu(3,zmap(8))
        att(1)=1.0d0
        x(1)=0.d0
        nh(1)=dh_0
        ne(1)=de_0
        nte(1)=te_0
        do i=2,nfs
          call copypop (pop_neu, p1)
          call copypopstep (p1, i, popfr)
          call scalepop (p1, dr)
          call copysteppop (i-1, popintfr, p2)
          call addpop (p1, p2)
          call copypopstep (p2, i, popintfr)
          fh(i)=pop_neu(2,1)
          foi(i)=pop_neu(1,zmap(8))
          foii(i)=pop_neu(2,zmap(8))
          foiii(i)=pop_neu(3,zmap(8))
          fra(i)=absf
          att(i)=att(i-1)*(1.d0-fra(i-1))
          x(i)=(i-1)*dr
          nh(i)=dh_0
          ne(i)=de_0
          nte(i)=te_0
        enddo
c
      dtime=frdr/vshoc
      nfs=nint(dlog(1.d-4)/dlog(1.d0-absf))
      nfs=min(nfs,mxifsteps)
c
   30 format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Precursor Timescales: '/
     & '    : ',i4,' zone neutral crossing time   : ',1pg11.4,/
     & '    : ',i4,' zone neutral length          : ',1pg11.4,//
     & '    :  Ionised recombination time x Q/v : ',1pg11.4,/
     & '    :  Ionised recombination distance   : ',1pg11.4,/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
c
      if (vmod.ne.'NONE') then
      write (*,30) nfs,dtime,
     &             nfs,frdr,dtimer,drr
      endif
c
      dr=frdr*invnfs
      tstep=(frdr/vshoc)*invnfs
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Iterate, full solution for Psi > 1, inner edge only for Psi <1
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   40 format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Precursor Iteration: ',/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
      if (vmod.ne.'NONE') write (*,40)
c
      xhfinal=pop(1,1)
      itcount=0
      t0lim=0
      nfs0=nfs
c
   50 call copypop (pop_neu, pop)
c
      t=te_0
      de=de_0
      dh=dh_0
c
      nmod='TIM'
      rms=0.d0
c
c integrate from outer edge to source
c
      rmserr=0.d0
      nrms=min(max(3,nfs/3),30)
c
      do i=nfs,1,-1
c
c full column absorption applied to spectrum
c
        call copysteppop (i, popintfr, p1)!getinnerfractioncolumns
        call attsig (dh, 0.d0, p1, attcol, sigcol)
        do idx=1,infph
          tphot(idx)=src(idx)*attcol(idx) ! +prefield(i)*wdil
          skipbin(idx)=.false.
          ipho=1
          iphom=0
          tem=0.d0
        enddo
c redo rates
        call allrates (t, ratemode)
c evolve in attenuated field to inner boundary
        call copypop (pop, p1)
        call teequi2 (t, tf, de, dh, tstep, nmod)
        call copypop (pop, p2)
        call averinto (0.5d0, p1, p2, p1)
c save step state at point, set nte after comparing with tf below
        x(i)=(i-1)*dr
        nh(i)=dh
        ne(i)=feldens(dh,p1)
c find new abs fraction in current zone for next iteration
        call habsfrac(absf, dh, dr, p1)
c        absf=min(absf,0.1d0)
        fra(i)=absf
c
c RMS Error
c
        if (i.le.nrms) then
          call copysteppop (i, popfr, p1)
          call difhhe (pop, p1, diff)
          diff=dabs(1.d0-(10.d0**diff))
          rmserr=rmserr+(diff*diff)
          diff=0.5d0*(tf-nte(i))/(tf+nte(i))
          rmserr=rmserr+(diff*diff)
        endif
c save step temp at point
        nte(i)=tf
c save pop after step = closer to src, ith pop is inner edge of ith zone
        call copypopstep (pop, i, popfr)
        fh(i)=pop(2,1)
        foi(i)=pop(1,zmap(8))
        foii(i)=pop(2,zmap(8))
        foiii(i)=pop(3,zmap(8))
        de=feldens(dh,pop)
        t=tf
      enddo
c
      att(1)=1.0d0
      do i=2,nfs
        att(i)=att(i-1)*(1.d0-fra(i-1))
      enddo
c
   60 format(//,
     & a5,14(a1,2x,a10,1x),/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',
     & ':::::::::::::::::::::::::::::::::::::')
   70 format(i5.3,14(a1,1pg13.6))
c
      if (vmod.ne.'NONE') then
        write (*,60) ' Step',tab,'Dist.(cm)',tab,'dx (cm)',
     &   tab,'Time (s)',tab,'dt (s)',
     &   tab, 'Te (K)',tab,'ne(cm^-3)',tab,'nH(cm^-2)',
     &   tab,'XHI',tab,'XHII',tab,'<abs>',
     &   tab,'XOI',tab,'XOII',tab,'XOIII'
      do i=nfs,1,-1
        call copysteppop (i, popintfr, p1)
        write (*,70) i,tab,x(i),tab,dr,
     &    tab,x(i)/vshoc,tab,dr/vshoc,
     &    tab,nte(i),tab,ne(i),tab,nh(i),tab,1.d0-fh(i),
     &    tab,fh(i),tab,fra(i),
     &    tab,foi(i),tab,foii(i),tab,foiii(i)
      enddo
      endif

      if (vmod.eq.'NONE') then
        write (*,60) ' Step',tab,'Dist.(cm)',tab,'dx (cm)',
     &   tab,'Time (s)',tab,'dt (s)',
     &   tab, 'Te (K)',tab,'ne(cm^-3)',tab,'nH(cm^-2)',
     &   tab,'XHI',tab,'XHII',tab,'<abs>',
     &   tab,'XOI',tab,'XOII',tab,'XOIII'
        i=1
        call copysteppop (i, popintfr, p1)
        write (*,70) i,tab,x(i),tab,dr,
     &    tab,x(i)/vshoc,tab,dr/vshoc,
     &    tab,nte(i),tab,ne(i),tab,nh(i),tab,1.d0-fh(i),
     &    tab,fh(i),tab,fra(i),
     &    tab,foi(i),tab,foii(i),tab,foiii(i)

      endif
c
c get post precursor outward field
c
      rmserr=dsqrt(rmserr/dble(nrms))
c
   80  format(
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' RMS change %: ',1pg11.4,' Iteration: ',i2,/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,80) 100.d0*rmserr,itcount+1
      write (lupt,80) 100.d0*rmserr,itcount+1
c
      t0lim=0
      nfs0=nfs
      n100=nfs
      do i=1,nfs
        if (nte(i).lt.100.d0) then
          n100=i
          goto 90
        endif
      enddo
   90 nfs=max(n100,minifsteps)
      if (popfr(nfs,1,1).lt.0.95d0) then
        nfs=nfs+10
        nfs=min0(nfs,mxifsteps)
      else if (att(nfs).gt.0.2d0) then
        nfs=nfs+50
        nfs=min0(nfs,mxifsteps)
      else if (nte(nfs).gt.1000.d0) then
        t0lim=1
        nfs=nfs+nint(nte(nfs)*0.015d0)+100
        nfs=min0(nfs,mxifsteps)
      else if ((nte(nfs).le.10.d0).and.(att(nfs).lt.0.01d0)) then
        n100=nfs
        do i=nfs,1,-1
          if ((nte(i).le.10.d0).and.(att(i).lt.0.01d0)) n100=i
        enddo
        nfs=max(n100,6)
      endif
c
      att(1)=1.0d0
      do i=2,nfs
        att(i)=att(i-1)*(1.d0-fra(i-1))
      enddo
c
c this will all hopefully all inline with gfortran -flto
c popintfr is columns of previous steps so starts at 0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call clearpop (p1)
c     columns up to inneredge ofzone
      call copypopstep (p1, 1, popintfr)
      do i=2,nfs
c pops at end time of previous zone, nearer source
        call copysteppop (i-1, popfr, p1)
c pops at end time of this zone, further from source
        call copysteppop (i, popfr, p2)
c average of pops from start to end in prev zone
        call averinto (0.5d0, p1, p2, p1)
        call scalepop (p1, dr)
        call copysteppop (i-1, popintfr, p2)
        call addpop (p1, p2)
        call copypopstep (p2, i, popintfr)
      enddo
c
      xhfinal=pop(1,1)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      itcount=itcount+1
c
c     poll for terminate file
c
      inquire (file='terminate',exist=iexi)
      if (iexi) goto 100
c
      if ((iteration.lt.3).and.(itcount.gt.1)) goto 100
c
      if ((iteration.lt.5).and.(itcount.gt.5)) goto 100
c
         if ((iabs(nfs0-nfs).gt.10)
     &      .or.(
     &           (rmserr.gt.rmslimit)
     &      .and.(itcount.lt.mxpcits)
     &      .and.(nfs.gt.minifsteps)
     &          )
     &      .or.(itcount.lt.minpcits)
     &      .or.((nfs.lt.mxifsteps).and.(t0lim.gt.0))
     &   ) goto 50
c
  100 continue
c
      if (finalit.gt.0) then
        do idx=1,infph
          tphot(idx)=src(idx) ! +prefield(i)*wdil
        enddo

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Write out final structure and last RMS
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
           write (   *,60) ' Step',tab,'Dist.(cm)',tab,'dx (cm)',
     &      tab,'Time (s)',tab,'dt (s)',
     &      tab, 'Te (K)',tab,'ne(cm^-3)',tab,'nH(cm^-2)',
     &      tab,'XHI',tab,'XHII',tab,'<abs>',
     &      tab,'XOI',tab,'XOII',tab,'XOIII'
c
         do i=1,nfs0
           write (   *,70) i,tab,x(i),tab,dr,
     &      tab,x(i)/vshoc,tab,dr/vshoc,
     &      tab,nte(i),tab,ne(i),tab,nh(i),tab,1.d0-fh(i),
     &      tab,fh(i),tab,fra(i),
     &      tab,foi(i),tab,foii(i),tab,foiii(i)
         enddo
c
           write (lupt,60) ' Step',tab,'Dist.(cm)',tab,'dx (cm)',
     &      tab,'Time (s)',tab,'dt (s)',
     &      tab, 'Te (K)',tab,'ne(cm^-3)',tab,'nH(cm^-2)',
     &      tab,'XHI',tab,'XHII',tab,'<abs>',
     &      tab,'XOI',tab,'XOII',tab,'XOIII'
c
         do i=1,nfs0
           write (lupt,70) i,tab,x(i),tab,dr,
     &      tab,x(i)/vshoc,tab,dr/vshoc,
     &      tab,nte(i),tab,ne(i),tab,nh(i),tab,1.d0-fh(i),
     &      tab,fh(i),tab,fra(i),
     &      tab,foi(i),tab,foii(i),tab,foiii(i)
         enddo
c
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      te_pre=t
      de_pre=de
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c      put final/inner balance into preionisation array
c
      call copysteppop (1, popfr, pop_pre)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Now get revised shock solution for changed pre shock values:
c     Shock in terms of flow velocity
c
      call shock5jump()
c
c and show the result
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Psi Summary
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  110 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' SHOCK 5 Final Precursor Parameter: ',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '     v_shock       : ',  1pg12.5,' km/s',/,
     & '     Q_ions        : ',  1pg12.5,' km/s',/,
     & '     Psi (Q/v)     : ',  1pg12.5,/,
     & '     Q_H           : ',  1pg12.5,' km/s',/,
     & '     Psi_H (Q_H/v) : ',  1pg12.5,/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
c
c redo Psi as vel0 has changes slightly
c
      psi=viofr/vel0
      write (   *,110) vel0*1.d-5,viofr*1.d-5,psi,qh*1.d-5,qh/vel0
      write (   *, 80) 100.d0*rmserr,itcount+1
      call fieldsummary (6,1,tphot)
      call shocksummary (6)
c
      if (finalit.gt.0)then
c
      write (lupt,110) vel0*1.d-5,viofr*1.d-5,psi,qh*1.d-5,qh/vel0
      write (lupt, 80) 100.d0*rmserr,itcount+1
c
      write (luop,110) vel0*1.d-5,viofr*1.d-5,psi,qh*1.d-5,qh/vel0
      write (luop, 80) 100.d0*rmserr,itcount+1
c
      call fieldsummary (lupt,1,tphot)
      call shocksummary (lupt)
c
      call fieldsummary (luop,1,tphot)
      call shocksummary (luop)
c
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Now clear tphot so it doesn't accumulate in each global iteration
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call zerbuf()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c set *both* the initial population arrays and go back to computing
c post shock flow.
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call copypop (pop_pre, pop )
      call copypop (pop_pre, pop0)
      t=te_pre
      de=dh_pre
      dh=dh_pre
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Close precursor files
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      call closeS5files()
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      real*8 function flocallosses(tm,ne,nh,pp,r,dr,dv,w)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 tm,ne,nh,r,dr,dv,w
      real*8 pp(mxion, mxelem)
      real*8 savepop(mxion, mxelem)
c
c     real*8 nexp,dlosmin,f
c     parameter( nexp=4.d0 )
c     5.0e-4^4
c     parameter( dlosmin=6.25d-14 )
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c loss dampening if close to heating/cooling balance
c prevents wild instability in x-ray neq tails
c
c     f=(dlos**nexp)/(6.25d-14+dlos**nexp)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      character mode*4
      parameter(mode='DW')
c
      call copypop(pop,savepop)
      call copypop(pp,pop)
      call localem (tm, ne, nh)
      call totphot2 (tm, nh, r, dr, dv, w, mode)
      call zetaeff (nh)
      call cool (tm, ne, nh)
      call copypop(savepop,pop)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      flocallosses=(eloss-egain)
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine compsh5 (iteration, maxits)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 iteration, maxits
c
      integer*4 i,j,idx
      logical iexi
      real*8 linfluxes(mxmonlines)
      real*8 n,invn,rdvol,irdvol,dvol
      real*8 b0,b1,b2,b3,b4,blum,binlum,pe
      real*8 hdt,tscale,dt0
      real*8 temp1,temp2,temp3,tav
c save state for step integral, uses pop, pop0 and pop1 in cblocks
      real*8 popstep(mxion,mxelem)
      real*8 tstep,destep,dhstep,xhstep
      real*8 rstep,drstep,velstep,dvstep,bmstep
      real*8 v,b
c
c structural markers
c
      real*8 timMark(7),disMark(7),bmMark(7)
      real*8 prMark(7),rhMark(7),dhMark(7),deMark(7)
      real*8 templim,ft,cft
      integer*4 tempidx
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c           Functions
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      real*8 frho,fmua,fdynamictimestep
      real*8 feldens,fpresse,flocallosses
c
      integer*4 lenv
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      character tab*1
      tab=','
c
      do idx=1,7
          timMark(idx)=0.0d0
          disMark(idx)=0.0d0
          bmMark(idx) =0.0d0
          prMark(idx) =0.0d0
          rhMark(idx) =0.0d0
          dhMark(idx) =0.0d0
          deMark(idx) =0.0d0
      enddo
c
      rdvol=1.0d0
      irdvol=1.d0
      vunilog=0.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c open all main shock files
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call appendS5files()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Begin Main Calculation
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   10 format(
     & ' ********************************************************',/,
     & '  SHOCK 5     Shock Iteration: ',i2.2,' of ',i2.2,/,
     & ' ********************************************************')
      write (*,10) iteration,maxits
      if (finalit.gt.0) then
        write (luop,10) iteration,maxits
        call shocksummary (luop)
      endif
c
   20 format(//'  T0',1pg14.7,' V0',1pg14.7,/,
     & ' RH0',1pg14.7,' P0',1pg14.7,' B0',1pg14.7,//,
     & '  T1',1pg14.7,' V1',1pg14.7,/,
     & ' RH1',1pg14.7,' P1',1pg14.7,' B1',1pg14.7,//)
c
      if (vmod.ne.'NONE') write (*,20) te0,vel0*1.d-5,rho0,pr0,
     &   bm0*1.d6,te1,vel1*1.d-5,rho1,pr1,bm1*1.d6
      if (finalit.gt.0) then
        write (luop,20) te0,vel0*1.d-5,rho0,pr0,
     &   bm0*1.d6,te1,vel1*1.d-5,rho1,pr1,bm1*1.d6
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   30 format(//,
     & ' #  ',
     & ',     Dist(cm),       dr(cm)',
     & ',        Te(K),     ne(/cm3),     nH(/cm3),     ni(/cm3)',
     & ',      mu(amu)',
     & ',      Time(s),        dt(s)',
     & ', L(erg.cm3/s),  Loss(erg/s),       dLoss',
     & ',          XHI,         XHII,        B(G)')
c
      wdilt0=te0
      t=te0
      dh=dh0
      de=de0
      press=fpresse(t,de,dh)
      rhotot=frho(de,dh)
      mu=fmua(de,dh)
      dr=0.d0
      ve=vel0
      vpo=vel1
      Bmag=bm0
      bm0=bm0
      dv=ve*0.01d0
      fi=1.d0
      rad=0.d0
      wdil=0.5d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     calculate the radiation field and atomic rates
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   40 format(i4.3,15(',',1pg13.6))
c
   50 format(/,
     & ' #    Te(K)       ne(/cm3)    nH(/cm3)    ni(/cm3)    ',
     & 'B(G)        XHI         Time(s)     dt(s)       ',
     & 'Dist(cm)    dr(cm)      v(cm/s)     L(erg.cm3/s)')
c
      if (vmod.eq.'MINI') then
        write (*,50)
      endif
   60 format (i4,6(1x,1pg11.4),6(1x,1pg11.4))
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      step=-2
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call copypop(pop_neu,pop)
      en=zen*dh_neu
      cspd=dsqrt(gammaEOS*pr_neu/rh_neu)
      wmol=rh_neu/(en+de_neu)
      mu=fmua(de_neu,dh_neu)
      t =te_neu
      de=de_neu
      dh=dh_neu
      en=zen*dh
c
      netloss=flocallosses(t,de,dh,pop_neu,1.d38,0.d0,0.d0,wdil)
c
      ue=gammaEOSU*(en+de)*rkb*t
      tnloss=tloss/((en+de)*(en+de))
c
      if (finalit.gt.0) then
c
        write (luop,40) step,
     &   0.d0,0.d0,
     &   te_neu,de_neu,dh_neu,en,mu,
     &   0.d0,0.d0,
     &   tnloss,tloss,dlos,
     &   pop(1,1),pop(2,1),bm_neu

       endif
c
C        if (vmod.eq.'MINI') then
           write (*,60) step,te_neu,de_neu,dh_neu,en,bm_neu
     &        ,pop_neu(1,1),0.d0,0.d0,0.0d0,0.d0,vel0,tnloss
C        endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      step=-1
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call copypop(pop_pre,pop)
      call copypop(pop_pre,pop0)
      en=zen*dh_pre
      cspd=dsqrt(gammaEOS*pr_pre/rh_pre)
      wmol=rh_pre/(en+de_pre)
      mu=fmua(de_pre,dh_pre)
      t =te_pre
      de=de_pre
      dh=dh_pre
      en=zen*dh
c
      netloss=flocallosses(t,de,dh,pop_pre,1.d38,0.d0,0.d0,wdil)
c
      ue=gammaEOSU*(en+de)*rkb*t
      tnloss=netloss/((en+de)*(en+de))
c
      rhotot=frho(de,dh)
      wmol=rhotot/(en+de)
      mu=fmua(de,dh)
c
      if (finalit.gt.0) then
        write (luop,40) step,
     &   0.d0,0.d0,
     &   te_pre,de_pre,dh_pre,en,mu,
     &   0.d0,0.d0,
     &   0.0d0,0.0d0,0.d0,
     &   pop_pre(1,1),pop_pre(2,1),bm_pre
      endif
c
C     if (vmod.eq.'MINI') then
        write (*,60) step,te_pre,de_pre,dh_pre,en,bm_pre,
     &   pop_pre(1,1),0.d0,0.d0,0.0d0,0.d0,vel0,tnloss
C     endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      step=0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      ue=gammaEOSU*(en+de)*rkb*t
      tnloss=netloss/((en+de)*(en+de))
c
      tscale=0.001d0
      dt=fdynamictimestep(t,dh,0.d0,ve,pop,netloss)
      dt=tscale*dt
      hdt=0.5d0*dt
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Setup Initial first step in post shock-front gas(#1) zero losses
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      rmod='NEAR'
c      call isochorflow (t, de, dh, ve, Bmag, rmod, netloss, dt)
c      call isobarflow (t, de, dh, ve, Bmag, rmod, netloss, dt)
      call rankhug (t, de, dh, ve, Bmag, 0.d0, 0.d0)
c
      call copypop(pop_pre,pop)
      call copypop(pop_pre,pop0)
c
c sets up 0 and 1 vars
c
      dr=dt*vel1
      dv=vel1-vel0
c
C     write(*,*) 'dt,dr,dv,vel0,vel1',dt,dr,dv,vel0,vel1
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     init arrays coming first step
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      xh(1)=pop(2,1)
      xh(2)=pop(2,1)
      veloc(1)=vel0
      veloc(2)=vel1
c
      te(1)=te0
      te(2)=te1
      deel(1)=de0
      deel(2)=de1
      dhy(1)=dh0
      dhy(2)=dh1
      bmg(1)=bm0
      bmg(2)=bm1
c
      dist(1)=0.0d0
      dist(2)=dr
      timlps(1)=0.0d0
      timlps(2)=dt
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      t=te1
      de=de1
      dh=dh1
      en=zen*dh
      ve=vel1
      rhotot=frho(de,dh)
      wmol=rhotot/(en+de)
      mu=fmua(de,dh)
c
      netloss=flocallosses(t,de,dh,pop_pre,1.d38,0.d0,0.d0,wdil)
c
      ue=gammaEOSU*(en+de)*rkb*t
      tnloss=netloss/((en+de)*(en+de))
c
      if (finalit.gt.0) then
        write (luop,40) step,
     &   0.0d0,0.0d0,
     &   t,de,dh,en,mu,
     &   0.0d0,0.0d0,
     &   tnloss,tloss,dlos,
     &   pop(1,1),pop(2,1),bm1
      endif
c
C     if (vmod.eq.'MINI') then
        write (*,50)
        write (*,60) step,t,de,dh,en,bm1,pop(1,1),
     &   0.0d0,0.0d0,0.0d0,0.0d0,ve,tnloss
C     endif
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   90 format(i4,1x,i4)
  100 format(1pg14.7,'K',1x,1pg14.7,'cm/s',1x,1pg14.7,'g/cm3',1x,
     &1pg14.7,'dyne/cm2',1x,1pg14.7,'Gauss',1x,1pg14.7,'ergs/cm3/s')
  110 format(2(1pg14.7,' cm',1x),2(1pg14.7,' s',1x))
  120 format(1pg14.7,' ergs/cm^3',1x,1pg14.7,' /cm^3',1x,
     &1pg14.7,' cm/s',1x,1pg14.7,' g/particle ')
  135 format(1x,i4,',', 11(1pg12.5,', '),31(1pg12.5,', '))
  140 format(43(1pg12.5,a2))
  150 format(17(1pg12.5,a1))
  160 format(//,
     & ' Step   Te Ave.(K)   ',
     & '  ne(cm^-3)   ',
     & '  nH(cm^-3)   ',
     & '  V1(cm/s)    ',
     & ' Rho1(g/cm^3) ',
     & ' Pr1(erg/cm^3)',
     & '   Dist.(cm)  ',
     & ' Elps. Time(s)')
  170 format(1x,i4,8(1pg14.7)/)
  180 format(1x,i4,41(', ',1pg12.5))
c
      call copypop (pop0, pop)
      de0=feldens(dh0,pop0)
      if (finalit.gt.0) then
        caller='S5'
        pfx=s5pfx(1:nprefix)
        np=nprefix
        call wbal (caller, pfx, np, pop)
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     SHOCK Step/Iteration reentry point:
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      step=1
c
      t=te1
      te0=te1
      rho0=rho1
      pr0=pr1
      vel0=vel1
      dh0=dh1
      de0=de1
      bm0=bm1
      Bmag=bm0
      dist(1)=0.d0
      timlps(1)=0.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (vmod.ne.'NONE') then
        write (*,50)
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (finalit.gt.0) write (luop, 30)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    MAIN STEP LOOP
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   70 count=0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c save step initial condition
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call copypop(pop0,popstep)
      tstep=te0
      dhstep=dh0
      destep=feldens(dh0,pop0)
      xhstep=pop(2,1)
      rstep=dist(step)
      drstep=dr
      velstep=vel0
      dvstep=vel1-vel0
      bmstep=bm0
c
      rad=rstep+drstep
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c set init ionisation and fields and get intial cooling/heating rates
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      specmode='DW'
      wdil=0.5d0
      fi=1.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c get intial time step dt, and hdt = 0.5d0*dt, init t = te0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c initial slow start scaling
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      tscale=dmin1(1.d0,0.01d0*dble(step*step))
      dt0=fdynamictimestep(tstep,dhstep,rad,velstep,popstep,netloss)
      dt=tscale*dt0
      hdt=0.5d0*dt
      drstep=velstep*dt
      dr=drstep
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c      evolve ionisation over hdt to get pop at midpoint
c      allow for iterations - not used as already 3 steps
c      initial midpoint cooling
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  80  count=count+1
c
      call copypop (popstep, pop0)
      call copypop (popstep, pop)
      t=tstep
      de=destep
      dh=dhstep
      v=velstep
      b=bmstep
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     Get midpoint Temp based on initial temp and cooling
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      temp1=t
      netloss=flocallosses(t,de,dh,popstep,rad,dr,dv,wdil)
      call rankhug (t, de, dh, v, b, netloss, hdt)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c from rankhug common block te0/te1 change vars
c midpoint t,de,dh,v,b all in '1' vars, not to get pop1 to match
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      temp2=te1
      tav  =0.5d0*(temp1+temp2)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     reset for ionisation t de dh, pop not changed by rh
c     xhii unused here, new balance in pop at hdt -> pop1
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      call copypop (popstep, pop)
      t=tstep
      de=destep
      dh=dhstep
      xhii=xhstep
      call timion (tav, de, dh, xhii, hdt)
      call copypop(pop,pop1)
c
c  get midpoint cooling at temp2=te1, with improved pop1
c
      de1=feldens(dh1,pop1)
      netloss=flocallosses(te1,de1,dh1,pop1,rad,dr,dv,wdil)
c
c step RH over dt with mid point losses, from start of step
c
      t=tstep
      de=destep
      dh=dhstep
      v=velstep
      b=bmstep
c
      call rankhug (t, de, dh, v, b, netloss, dt)
      temp3=te1
c higher order step temp
      tav =0.5d0*(temp1+temp3)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c now advance ions with whole dt at overall mean tav
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call copypop (popstep, pop)
      de=destep
      dh=dhstep
      xhii=xhstep
      call timion (tav, de, dh, xhii, dt)
      call copypop(pop,pop1)
c
C     write(*,*) 'Full Step Te :',te0,te1,tav
C     write(*,*) 'Full Step Ve :',vel0,vel1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c End step iterations
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     record step
c
      call averinto(0.5d0,pop0,pop1,pop)
c
      te(step)=(te0+te1)*0.5d0
      dhy(step)=(dh0+dh1)*0.5d0
      deel(step)=(de0+de1)*0.5d0
      bmg(step)=(bm0+bm1)*0.5d0
c
      xh(step)=pop(2,1)
      veloc(step)=(vel1+vel0)*0.5d0
c
      dist(step+1)=dist(step)+dr
      timlps(step+1)=timlps(step)+dt
c
      en=zen*dh
c
      ue=gammaEOSU*(en+de)*rkb*t
      tnloss=netloss/((en+de)*(en+de))
c
      cspd=dsqrt(gammaEOS*(pr1+pr0)/(rho1+rho0))
      wmol=(rho1+rho0)/(2.d0*(en+de))
      mu=fmua(de,dh)
c
      mb=(bm0+bm1)*0.5d0
c
      if ((vmod.eq.'FULL').or.(vmod.eq.'SLAB')) then
        wmod='SCRN'
        call wmodel (luop, t, de, dh, dr, wmod)
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c structural markers
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      templim=1.0d7
  130 tempidx=idnint(dlog10(templim))
      if ((te1.le.templim).and.(te0.gt.templim)) then
        ft=(templim-te1)/(te0-te1)
        cft=1.d0-ft
        timmark(tempidx)=cft*timlps(step)+ft*timlps(step)
        dismark(tempidx)=cft*dist(step)+ft*dist(step)
        bmmark(tempidx)=cft*bm0+ft*bm1
        prmark(tempidx)=cft*pr0+ft*pr1
        rhmark(tempidx)=cft*rho0+ft*rho1
        dhmark(tempidx)=cft*dh0+ft*dh1
        demark(tempidx)=cft*de0+ft*de1
      endif
      templim=templim*0.1d0
      if (templim.gt.10.d0) goto 130
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (vmod.eq.'MINI') then
        write (*,60) step,t,de,dh,en,mb,pop(1,1),
     &   timlps(step),dt,
     &   dist(step),dr,
     &   veloc(step),tnloss
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        if (finalit.gt.0) then
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        write (luop,40) step,
     &   dist(step),dr,
     &   t,de,dh,en,mu,
     &   timlps(step),dt,
     &   tnloss,tloss,dlos,
     &   pop(1,1),pop(2,1),bm1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c output to secondary files
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        if (jlin.eq.'Y') then
             call speclocallines (linfluxes)
             write (lulsh,135) step,dist(step),dist(step)+dr*0.5d0,dr,
     &       t,de,dh,de+en,
     &       0.0d0,0.0d0,0.0d0,hydrobri(2,2),
     &       (linfluxes(i),i=1,njlines)
          endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        if (ratmod.eq.'Y') then
          wmod='LOSS'
          call wmodel (lurtsh, t, de, dh, dr, wmod)
        endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        if (dynmod.eq.'Y') then
          write (ludy,90) step,count
          write (ludy,110) dist(step),dr,timlps(step),dt
          write (ludy,100) te0,vel0,rho0,pr0,bm0,l0
          write (ludy,100) te1,vel1,rho1,pr1,bm1,l11
          write (ludy,120) ue,en,cspd,wmol
        endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        if (fclmod.eq.'Y') then
         do i=1,atypes
            meanion(i)=0.d0
            ionbar=0.d0
            do j=1,maxion(i)
              ionbar=ionbar+(pop(j,i)*j)
            enddo
            meanion(i)=dmax1(ionbar-1.0d0,0.0d0)
         enddo
c
          en=zen*dh
          n=(de*dh)
          if (jnorm.eq.0) n=(de*dh)
          if (jnorm.eq.1) n=(dh*dh)
          if (jnorm.eq.2) n=(de*en)
          if (jnorm.eq.3) n=((de+en)*(de+en))
          if (jnorm.eq.4) n=(de*de)
          invn=1.d0/dble(n)
c
          write (lucl,140) t,tab,de,tab,dh,tab,en,tab,(0.5*(rho0+rho1)),
     &     tab,pop(1,1),tab,pop(2,1),tab,mu,tab,tloss,tab,tloss*invn,
     &     (tab,coolz(j)*invn,j=1,atypes),tab,eloss*invn,tab,egain*invn,
     &     tab,netloss*invn
c
        endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (bandsmod.eq.'Y') then
c
         b0=0.d0
         b1=0.d0
         b2=0.d0
         b3=0.d0
         b4=0.d0
         blum=0.d0
         do idx=1,infph-1
            if (tphot(idx).gt.epsilon) then
            widnu=widbinnu(idx)
            pe=photev(idx)
            binlum=tphot(idx)*fpi*widnu/dr
            blum=blum+binlum
            if ((pe.gt.0.0d0).and.(pe.le.100.0d0)) b0=b0+binlum
            if ((pe.gt.100.0d0).and.(pe.le.500.0d0)) b1=b1+binlum
            if ((pe.gt.500.0d0).and.(pe.le.1000.0d0)) b2=b2+binlum
            if ((pe.gt.1000.0d0).and.(pe.le.2000.0d0)) b3=b3+binlum
            if ((pe.gt.2000.0d0).and.(pe.le.10000.0d0)) b4=b4+binlum
            endif
         enddo
c
          b0=b0/tloss
          b1=b1/tloss
          b2=b2/tloss
          b3=b3/tloss
          b4=b4/tloss
          blum=blum/tloss
c
         if (b0.lt.epsilon) b0=0.d0
         if (b1.lt.epsilon) b1=0.d0
         if (b2.lt.epsilon) b2=0.d0
         if (b3.lt.epsilon) b3=0.d0
         if (b4.lt.epsilon) b4=0.d0
         if (blum.lt.epsilon) blum=0.d0
c
        write (lupb,150) t,tab,de,tab,dh,tab,en,tab,pop(1,1),
     &   tab,pop(2,1),tab,mu,tab,tloss,tab,tloss*invn,tab,fflos/tloss,
     &   tab,b0,tab,b1,tab,b2,tab,b3,tab,b4,tab,blum,tab
c
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (allmod.eq.'Y') then
          write (lualsh,160)
          write (lualsh,170) step,t,de,dh,vel1,rho1,pr1,dist(step),
     &     timlps(step)
c
          call wionabal (lualsh, pop)
          call wionabal (lualsh, popint)
      endif
c
      if (tsrmod.eq.'Y') then
c
          do i=1,ieln
            write (luionsh(i),180) step,dist(step),dr,
     &         timlps(step),dt,t,de,dh,en,(pop(j,iel(i)),j=1,
     &         maxion(iel(i)))
          enddo
c
        endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c end finalit
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      endif
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
        rad=dist(step)
        call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
        caller='S5'
        pfx='shlocl'//s5pfx(1:nprefix)
        np=lenv(pfx)
        wmod='NORM'
        dva=vel1-vel0
        en=zen*dh
        n=(de*dh)
        if (jnorm.eq.0) n=(de*dh)
        if (jnorm.eq.1) n=(dh*dh)
        if (jnorm.eq.2) n=(de*en)
        if (jnorm.eq.3) n=((de+en)*(de+en))
        if (jnorm.eq.4) n=(de*de)
        invn=1.d0/n
        call wpsou(caller,pfx,np, wmod, t, de, dh, dr, invn, tphot)
c
c     reset mode and tphot
c
        specmode='DW'
        rad=dist(step)
        call totphot2 (t, dh, rad, dr, dv, wdil, specmode)
      endif
c
c     get mean ionisation state for step
c
      rdis=dist(step)+dr*0.5d0!middleofstep,dist(step)isnowend
c      cmpf=rho1/rho0
      fi=1.0d0
c
c     accumulate spectrum
c
      tdw=te0
      tup=te1
      drdw=dr
      dvdw=vel0-vel1
      drup=dist(step)
      dvup=dsqrt(vpo*vel0)
      frdw=0.5d0
c
      call localem (t, de, dh)
      call zetaeff (dh)
      call newdif2 (tdw, tup, dh, rad, drdw, dvdw, drup, dvup,
     &   frdw, jtrans)
c
      imod='ALL'
      dvol=dr*irdvol
      call sumdata (t, de, dh, dvol, dr, rdis, imod)
c
c     record line ratios
c
      if (ox3.ne.0) then
        hoiii(step)=(fluxm(6,ox3)+fluxm(8,ox3))/(fluxh(2)+epsilon)
      endif
      if (ox2.ne.0) then
        hoii(step)=(fluxm(1,ox2)+fluxm(2,ox2))/(fluxh(2)+epsilon)
      endif
      if (ni2.ne.0) then
        hnii(step)=(fluxm(7,ni2)+fluxm(10,ni2))/(fluxh(2)+epsilon)
      endif
      if (su2.ne.0) then
        hsii(step)=(fluxm(1,su2)+fluxm(1,su2))/(fluxh(2)+epsilon)
      endif
      if (ox1.ne.0) then
        if (ispo.eq.' OI') hsii(step)=fluxm(3,ox1)/(fluxh(1)+epsilon)
      endif
c
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
      te0=te1
      rho0=rho1
      pr0=pr1
      vel0=vel1
      dh0=dh1
      de0=de1
      bm0=bm1
      Bmag=bm0
      count=0
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
c      if (jend.eq.'A') then
c
      totn=0.d0
      totn=zen
      ionbar=0.d0
c
      do i=1,atypes
        do j=2,maxion(i)
          ionbar=ionbar+(pop(j,i)*zion(i))
        enddo
      enddo
c
      ionbar=ionbar/totn
c
      if ((jend.eq.'A').and.(ionbar.lt.0.01d0)) goto 190
c
c     Specific species ionisation limit
c
      if (jend.eq.'B') then
        if (pop(jpoen,ielen).lt.fren) goto 190
      endif
c
c stop first iteration at heating==cooling if maxits>1
c
      if ((iteration.le.1)
     &  .and.(maxits.gt.1)
     &  .and.(dlos.lt.0.5d0)) goto 190
c
c     Temperature limit
c
      if (jend.eq.'C') then
        if (t.lt.tend) goto 190
      endif
c
c     Temperature limit, plus 95% neutral
c
      if ((jend.eq.'S').and.(t.lt.tend)) then
        if (ionbar.lt.0.05d0) goto 190
      endif
c
c     Distance Limit
c
      if ((jend.eq.'D').and.(dist(step).ge.diend)) goto 190
c
c     Time Limit
c
      if ((jend.eq.'E').and.(timlps(step).ge.timend)) goto 190
c
c     thermal balance dlos<1e-2
c
      if ((jend.eq.'F').and.(dlos.lt.1.d-2)) goto 190
c
c     cooling function test, finish when tloss goes -ve
c
      if ((jend.eq.'G').and.(tloss.lt.0.d0)) goto 190
c
c     poll for terminate file
c
      pollfile='terminate'
      inquire (file=pollfile,exist=iexi)
      if (iexi) goto 190
c
c     otherwise go to normal iteration loop, if interlocks
c     permit
c
      step=step+1
      if ((t.gt.100.d0).and.(step.lt.(mxnsteps-1))) then
        goto 70
      endif
c
  190 continue
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Close all files and flush
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call closeS5files()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     End model
c     write out spectrum etc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Reopen all main shock files
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call appendS5files()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Final Downstream Field
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (finalit.gt.0) then
        if (jspec(1:1).eq.'Y') then
c
          caller='S5'
          pfx='SHdw'//s5pfx(1:nprefix)
          np=lenv(pfx)
          dva=0.d0
c
          wmod='LFLM'
          call wpsou(caller, pfx, np, wmod, t, de, dh, dr, wdil, tphot)
c
          wmod='REAL'
          call wpsou(caller, pfx, np, wmod, t, de, dh, dr, wdil, tphot)
c
        if (lmod.eq.'Y') then
c
          wmod='NFNU'
          call wpsou(caller, pfx, np, wmod, t, de, dh, dr, wdil, tphot)
c
          endif
        endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Upstream photon field
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        call localem (t, de, dh)
        specmode='UP'
        rad=dist(step)
        call totphot2 (t, dh, 1.0d38, 1.0d0, 0.d0, wdil, specmode)
c
        call fieldsummary(6,1,tphot)
c
        caller='S5'
        pfx='SHup'//s5pfx(1:nprefix)
        np=lenv(pfx)
        dva=vel1-vel0
c
        wmod='LFLM'
        call wpsou(caller,pfx,np, wmod, te1, de1, dh1, dr, wdil, tphot)
c
        wmod='REAL'
        call wpsou(caller,pfx,np, wmod, te1, de1, dh1, dr, wdil, tphot)
c
        if (lmod.eq.'Y') then
c
        wmod='NFNU'
        call wpsou(caller,pfx,np, wmod, te1, de1, dh1, dr, wdil, tphot)
c
        endif
c
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     dynamics
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call avrdata()
c
      if (finalit.gt.0) then
c
  200 format(//,
     & ' Model ended: , Distance:, ',1pg14.7,
     &', Time:, ',1pg14.7,', Temp:, ',1pg12.5,/)
        write (luop,200) dist(step),timlps(step),t
        write (*,200) dist(step),timlps(step),t
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c structural markers
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  210 format(' Marker',i1,':, ',1pe12.5,' (K)',/,
     & '      t',i1,':, ',1pg12.5,/,
     & '      d',i1,':, ',1pg12.5,/,
     & '      B',i1,':, ',1pg12.5,/,
     & '      P',i1,':, ',1pg12.5,/,
     & '    rho',i1,':, ',1pg12.5,/,
     & '     nH',i1,':, ',1pg12.5,/,
     & '     ne',i1,':, ',1pg12.5,/)
        do idx=7,1,-1
          if (timmark(idx).gt.0.d0) then
            templim=10.0d0**dble(idx)
          write(luop,210) idx,templim
     &              ,idx,timMark(idx)
     &              ,idx,disMark(idx)
     &              ,idx,bmMark(idx)
     &              ,idx,prMark(idx)
     &              ,idx,rhMark(idx)
     &              ,idx,dhMark(idx)
     &              ,idx,deMark(idx)
          write(*,210) idx,templim
     &              ,idx,timMark(idx)
     &              ,idx,disMark(idx)
     &              ,idx,bmMark(idx)
     &              ,idx,prMark(idx)
     &              ,idx,rhMark(idx)
     &              ,idx,dhMark(idx)
     &              ,idx,deMark(idx)
          endif
        enddo
c
        spmod='REL'
        linemod='LAMB'
        call spec2 (lusp, linemod, spmod)
c
c both summary columns and spec/spectrum all in one
c
        call wrsppop (luop)
c
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call closeS5files()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      real*8 function fdynamictimestep(t,dh,x,vel,p,netloss)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t,dh,de,vel,netloss
      real*8 p(mxion, mxelem)
      real*8 en, pr, ue, x
      real*8 cltime, absdr, abstime
      real*8 ctime, rtime, dt, absf
      real*8 feldens, fcolltim, frectim2
      parameter ( absf=0.05d0 )
      real*8 flocallosses
c
      de=feldens(dh,p)
      en=zen*dh+de
      pr=en*rkb*t
      ue=gammaEOSU*pr
c
c initial cooling rate for initial timestep guess
c
      netloss=flocallosses(t, de, dh, p, x, 0.d0, 0.d0, wdil)
c
      cltime=(ue/(dabs(netloss)+epsilon))
      absdr=1.0d38
      abstime=1.d0/epsilon
      if (photonmode.ne.0) then
        absdr=1.0d19/dh0
        call absdis2 (dh, 0.5d0, absdr, 0.0d0, p)
        abstime=absdr/(dabs(vel)+epsilon)
      endif
      ctime=fcolltim(de)
      rtime=frectim2(de)
c
c weighted harmonic sum, coeffs determined empirically
c
      dt=1.d0/((0.5d0/abstime)+(1.d0/(cltime*0.025d0))+(1.d0/(rtime*
     &0.05d0))+(1.d0/(ctime*0.01d0)))
c
      fdynamictimestep=dt
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine protostate (lunit)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      real*8 fmua
      integer*4 lunit
c
   10   format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Shock Proto-State Properties',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    Velocity       :',1pg12.5,' km/s',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    Proto Mach Number          :',1pg12.5,/,
     & '    Proto Alfven Mach Number   :',1pg12.5,/,
     & '    Proto Mag Alpha (Pmag/Pgas):',1pg12.5,/,
     & '    Proto Gas Eta  (gPgas/Pram):',1pg12.5,/,
     & '    Proto Mag Eta  (2Pmag/Pram):',1pg12.5,//,
     & '    Proto        T :',1pg12.5,' K',/,
     & '    Proto        ne:',1pg12.5,' cm^-3',/,
     & '    Proto        nH:',1pg12.5,' cm^-3',/,
     & '    Proto        d :',1pg12.5,' g/cm^-3',/,
     & '    Proto      Pgas:',1pg12.5,' dyne/cm^2',/,
     & '    Proto        mu:',1pg12.5,' a.m.u.',/,
     & '    Proto       XHI:',1pg12.5,/,
     & '    Proto      XHII:',1pg12.5,/,
     & '    Proto      XHeI:',1pg12.5,/,
     & '    Proto     XHeII:',1pg12.5,/,
     & '    Proto    XHeIII:',1pg12.5,/,
     & '    Proto        B :',1pg12.5,' microGauss',/,
     & '    Proto      Pmag:',1pg12.5,' dyne/cm^2',/,
     & '    Proto      Pram:',1pg12.5,' dyne/cm^2',/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)

c
      en=zen*dh_neu
      cspd=dsqrt(gammaEOS*pr_neu/rh_neu)
      wmol=rh_neu/(en+de_neu)
      mu=fmua(de_neu,dh_neu)
c
      Pram=rh_neu*vel0*vel0
      Pgas=pr_neu
      Pmag=(bm_neu*bm_neu)/epi
c
      machnumber=vel0/dsqrt(gammaEOS*pr_neu/rh_neu)
      alfvennumber=vel0/dsqrt(2.0d0*Pmag/rh_neu)
      malpha=Pmag/Pgas
      gaseta=gammaEOS*Pgas/Pram
      mageta=2.d0*Pmag/Pram
c
      write (lunit,10) vel0*1.0d-5,machnumber,alfvennumber,malpha,
     &gaseta,mageta,te_neu,de_neu,dh_neu,rh_neu,pr_neu,mu,pop_neu(1,
     &zmap(1)),pop_neu(2,zmap(1)),pop_neu(1,zmap(2)),pop_neu(2,zmap(2)),
     &pop_neu(3,zmap(2)),bm_neu*1.d6,Pmag,Pram
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine shock5filenames (px)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     set initial file unit numbers and default mode flags
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 i
      character* (*) px
c
      integer*4 mlen,lenv
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     set up file modes
c
      jspec='N'
      lmod='N'
      tsrmod='N'
      allmod='N'
      dynmod='N'
      ratmod='N'
      bandsmod='N'
      fclmod='N'
      jlin='N'
      s5pfx=px
      nprefix=mlen(px)
c
c main model files
c always on full model files
c
      luop=20
c
c     Name "sh5" general output file
c
      fsm=' '
      pfx='shck_'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='sh5'
      call newfile (pfx, np, sfx, 3, fn)
      fsm=fn(1:np+8)
c
      luop=21
c
c     Name "sh5" precursor general output file
c
      fpm=' '
      pfx='prec_'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='sh5'
      call newfile (pfx, np, sfx, 3, fn)
      fpm=fn(1:np+8)
c
c spec line list files
c always in csv files lists
c
      lusp=22
c
      pfx='specSH'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='csv'
      fsh=' '
      call newfile (pfx, np, sfx, 3, fn)
      fsh=fn(1:np+8)
c
c    allions files
c    allmod=Y
c
      lualsh=23
      pfx='ionSH'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='sh5'
      call newfile (pfx, np, sfx, 3, fn)
      fash=fn(1:np+8)
c
c rates fitles , shock and precursors
c ratmod=Y
c
      lurtsh=24
      pfx='ratSH'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='sh5'
      call newfile (pfx, np, sfx, 3, fn)
      frsh=fn(1:np+8)
c
c shock 'dynamics' file
c dynmod=Y
c
      ludy=25
      pfx='dynSH'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='sh5'
      fd=' '
      call newfile (pfx, np, sfx, 3, fn)
      fd=fn(1:np+8)
c
c shock cooling file
c fclmod=Y
c
      lucl=26
      pfx='coolSH'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='csv'
      fcl=' '
      call newfile (pfx, np, sfx, 3, fn)
      fcl=fn(1:np+8)
c
c shock cooling emission bands
c bandsmod=Y
c
      lupb=27
      pfx='bandSH'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='csv'
      fpb=' '
      call newfile (pfx, np, sfx, 3, fn)
      fpb=fn(1:np+8)
c
c line structures, shocks and precursors
c jlin=Y
c
      lulsh=28
c
      pfx='linSH'//s5pfx(1:nprefix)
      np=lenv(pfx)
      sfx='csv'
      flsh=' '
      call newfile (pfx, np, sfx, 3, fn)
      flsh=fn(1:np+8)
c
c       ionisation structure files -  all names a made only 4 are
c       used atm tsrmod=Y  i is 1-mxelem and is effectively the
c       ordinal atom value ie=iel(i) = zmap( of posible choice i=z
c       ), ie is then map id for the ith element in map.prefs or
c       mapz, elem(ie) uses the map id for the elem name all
c       elements in map.prefs  get file names but only ieln=4 are
c       created and used, ieln can change in the future
c
c B  : Ion balance files.' for just the 4 chosen mapping z to i later
c      luionsh(i)=30+i
c
      sfx='csv'
      do i=1,atypes
        luionsh(i)=30+i
c       mapppings internal ids not z, names mapped in prefs
        if (elem_len(i).eq.1) then
          pfx='elSH'//s5pfx(1:nprefix)//elem(i)//'_'
        else
          pfx='elSH'//s5pfx(1:nprefix)//elem(i)
        endif
        np=lenv(pfx)
        fn=' '
        call newfile (pfx, np, sfx, 3, fn)
        fash=fn(1:np+8)
        fionsh(i)=fash
c
      enddo
c
c Final downstream field.'
c jspec=YES
c
c All upstream fields at each step.
c lmod=Y
c
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine createS5files ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 i
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Create shock files incl precursor model file
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      open (luop,file=fsm,status='NEW')
      open (lupt,file=fpm,status='NEW')
      open (lusp,file=fsh,status='NEW')
c
c iel is mapid - all names exist from prefs in id order
c zmap -> iel -> file id
      if (tsrmod.eq.'Y') then
        do i=1,ieln
          open (luionsh(i),file=fionsh(iel(i)),status='NEW')
        enddo
      endif
      if (allmod.eq.'Y') then
        open (lualsh,file=fash,status='NEW')
      endif
      if (dynmod.eq.'Y') then
        open (ludy,file=fd,status='NEW')
      endif
      if (ratmod.eq.'Y') then
        open (lurtsh,file=frsh,status='NEW')
      endif
      if (bandsmod.eq.'Y') then
        open (lupb,file=fpb,status='NEW')
      endif
      if (fclmod.eq.'Y') then
        open (lucl,file=fcl,status='NEW')
      endif
      if (jlin.eq.'Y') then
        open (lulsh,file=flsh,status='NEW')
      endif
c
      return
      end
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine closeS5files()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 i
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Close All Main and Shock files if open
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      logical unitopen
      inquire(unit=luop, opened=unitopen)
      if (unitopen) close (luop)
      inquire(unit=lupt, opened=unitopen)
      if (unitopen) close (lupt)
      inquire(unit=lusp, opened=unitopen)
      if (unitopen) close (lusp)
c
      inquire(unit=lurtsh, opened=unitopen)
      if (unitopen) close (lurtsh)
      inquire(unit=ludy, opened=unitopen)
      if (unitopen) close (ludy)
        do i=1,ieln
      inquire(unit=luionsh(i), opened=unitopen)
      if (unitopen) close (luionsh(i))
        enddo
      inquire(unit=lualsh, opened=unitopen)
      if (unitopen) close (lualsh)
      inquire(unit=lucl, opened=unitopen)
      if (unitopen) close (lucl)
      inquire(unit=lulsh, opened=unitopen)
      if (unitopen) close (lulsh)
      inquire(unit=lupb, opened=unitopen)
      if (unitopen) close (lupb)
c
      return
      end
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine appendS5files()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      include 's5blocks.inc'
c
      integer*4 i
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Open All files APPEND
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      open (luop,file=fsm,status='OLD',access='APPEND')
      open (lupt,file=fpm,status='OLD',access='APPEND')
      open (lusp,file=fsh,status='OLD',access='APPEND')
c
      if (tsrmod.eq.'Y') then
        do i=1,ieln
      open (luionsh(i),file=fionsh(iel(i)),status='OLD',access='APPEND')
        enddo
      endif
      if (allmod.eq.'Y') then
        open (lualsh,file=fash,status='OLD',access='APPEND')
      endif
      if (dynmod.eq.'Y') then
        open (ludy,file=fd,status='OLD',access='APPEND')
      endif
      if (ratmod.eq.'Y') then
        open (lurtsh,file=frsh,status='OLD',access='APPEND')
      endif
      if (bandsmod.eq.'Y') then
        open (lupb,file=fpb,status='OLD',access='APPEND')
      endif
      if (fclmod.eq.'Y') then
        open (lucl,file=fcl,status='OLD',access='APPEND')
      endif
      if (jlin.eq.'Y') then
        open (lulsh,file=flsh,status='OLD',access='APPEND')
      endif
c
      return
      end
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
