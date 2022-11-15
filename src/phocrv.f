cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.txt'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine phocrv ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     subroutine to compute cooling curves for photo-ionisation
c     equilibrium.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 band1,band2,band3,band4,bandall,cab,cspd,dr
      real*8 dv,epotmi, tauav
      real*8 press,rad,rhotot,tf,tl,tnloss,trea,trec
      real*8 tstep,ue,wmol
c     real*8 ab,t,de,dh,en,fhi,fhii
      real*8 t,de,dh,en,fhi,fhii
      real*8 poplog(mxion, mxelem),rlow,rhigh,rinc
      real*8 sv,qlow,qhigh,qinc
      real*8 q0,q1,q2,q3,mu,invn,n
      real*8 qt,qh1,qhe1,qhe2
      real*8 b0,b1,b2,b3,b4,blum,widnu,pe,binlum
c
      integer*4 l,luop,lupb
      integer*4 m,i,j,idx,np,jnorm,flen
      integer*4 luions(mxelem)
c
      character caller*4, n2*12, norm*12
      character imod*4, lmod*4, model*64
      character nmod*4, mmod*4
      character ilgg*4, ill*4, filn(mxelem)*64
      character jsaveatoms*4
      character fn*128,fl*128,fb*128
      character pfx*64,sfx*16,tab*4,fmod*4
c
c           Functions
c
      real*8 frectim,frho,feldens,fmua
      integer*4 mlen
c
   10 format(//,a,$)
   20 format(a)
c
      luop=21
      lupb=22
c
      do i=1,atypes
        luions(i)=22+i
      enddo
c
      call zer
c
      fn=' '
      pfx='phocv'
      sfx='csv'
      call newfile (pfx, sfx, fn, flen)
      fl=fn(1:flen)
c
      fn=' '
      pfx='phopb'
      sfx='csv'
      call newfile (pfx, sfx, fn, flen)
      fb=fn(1:13)
c
      cab=0.0d0
      epotmi=iphe
      model='Photo CV'
      caller='QC'
c
      jsaveatoms='N'
      tab=','
c
      trea=epsilon
c
      jspot='N'
      jcon='Y'
c
      write (*,30)
   30 format(//' Photoionisation Equilibrium Curves.'/
     &'  ( Optically thin single slabs )'/
     &' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//)
      cab=0.0d0
      epotmi=iphe
c
      open (luop,file=fl,status='NEW')
      open (lupb,file=fb,status='NEW')
c
      write (*,40)
   40 format(//' Choose a photo-curve model type :'/
     &' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/
     &'     A :  Fixed radiation, variable density.'/
     &'     B :  Fixed density, variable radiation.'/
     &'  :: ',$ )
      read (*,20) ilgg
      ilgg=ilgg(1:1)
c
      if (ilgg.eq.'a') ilgg='A'
      if (ilgg.eq.'b') ilgg='B'
c
      fmod='dens'
c
      if (ilgg.eq.'A') then
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     variable density
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        fmod='dens'
c
        write (*,10) ' Initial (H) density (low, <=0 as log):'
        read (*,*) rlow
c
        if (rlow.le.0.d0) rlow=10.d0**rlow
c
        write (*,10) ' Final (H) density (high, <=0 as log):'
        read (*,*) rhigh
c
        if (rhigh.le.0.d0) rhigh=10.d0**rhigh
c
c
        write (*,10) ' Density step factor (<=1 as log):'
        read (*,*) rinc
c
        if (rinc.gt.1.d0) rinc=dlog10(rinc)
c
        dh=10.d0**(dlog10(rlow)-rinc)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     variable density
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      endif
c
      if (ilgg.eq.'B') then
c
        fmod='rads'
c
c     variable radiation
c
        write (*,10) ' Hydrogen density (<=0 as log):'
        read (*,*) dh
c
        if (dh.le.0.d0) dh=10.d0**dh
c
        write (*,10) ' Initial ionisation parameter','(Q low, <=10 as lo
     &g):'
        read (*,*) qlow
c
        if (qlow.le.10.d0) qlow=10.d0**qlow
c
        write (*,10) ' Final Ionisation parameter',' (Q high, <=100 as l
     &og):'
        read (*,*) qhigh
c
        if (qhigh.le.100.d0) qhigh=10.d0**qhigh
c
c
        write (*,10) ' Ionisation parameter step factor (<=1 as log):'
        read (*,*) qinc
c
        if (qinc.gt.1.d0) qinc=dlog10(qinc)
c
        qlow=10.d0**(dlog10(qlow)-qinc)
c
c     variable radiation
c
      endif
c
   50 format(//' Lambda Normalisation:',/
     & ' 0: ne.nH',/, ' 1: nH^2',/
     & ' 2: ne.ni',/, ' 3: n^2',/
     & ' 4: ne^2      :: ',$)
      write (*,50)
      read (*,*) jnorm
      if (jnorm.lt.0) jnorm=0
      if (jnorm.gt.4) jnorm=0
      n2='(nH^2)'
      norm='L/(nH^2)'
      if (jnorm.eq.0) n2='(ne.nH)'
      if (jnorm.eq.1) n2='(nH^2)'
      if (jnorm.eq.2) n2='(ne.ni)'
      if (jnorm.eq.3) n2='(n^2)'
      if (jnorm.eq.4) n2='(ne^2)'
      norm='L/'//n2
c
      write (*,10) ' Save element ionisation files (Y/N):'
      read (*,20) jsaveatoms
      call toup (jsaveatoms(1:1), jsaveatoms)
c
      call popcha (model)
      call photsou (model)
c
      q0=qht
      q1=qhi
      q2=qhei
      q3=qheii
c
      if (fmod.eq.'rads') then
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     adjust source to give desired Q
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        sv=qlow*dh/q0
c
        do i=1,infph
          soupho(i)=soupho(i)*sv
        enddo
c
        q1=q1*sv
        q2=q2*sv
        q3=q3*sv
        q0=q0*sv
c
      endif
c
      call copypop (pop, pop0)
c
c
   60 format(//' Give initial conditions:',/
     &'::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/
     &'    t (K), dr (cm)'/
     &'    (t<10 taken as a log),'/
     &'    (dr<100 taken as log)'//
     &' :: ',$)
      write (*,60)
      read (*,*) t,dr
      if (t.le.10.d0) t=10.d0**t
      if (dr.le.100.d0) dr=10.d0**dr
c
c     plane ll only
c
      wdil=0.5d0
c
   70 format(//
     & ' ******************************************'/
     & '  Ionization parameter QHDH:',1pg14.7/
     & ' ******************************************',/)
      write (*,70) ((2.0d0*q0*wdil)/dh)
c
      write (*,10) ' Run/code name for this calculation:'
      read (*,20) runname
      np=mlen(runname)
      write (*,*) '  '
c
      if (jsaveatoms.eq.'Y') then
        do i=1,atypes
          j=i
          fn=' '
          pfx='IonPIE'//elem(j)
          sfx='csv'
          call newfile (pfx, sfx, fn, flen)
          filn(i)=fn(1:flen)
          open (luions(i),file=filn(i),status='NEW')
          write (luions(i),'(" Photoionisation Equilibrium Curve : ")')
          write (luions(i),'(" File       : ",a)') fl(1:13)
          write (luions(i),'(" Run        : ",a)') runname(1:np)
          write (luions(i),'(" Element    : ",a2)') elem(i)
          write (luions(i),'(" Ionisation : ")')
   80     format(3x,', ',5(a11,a2),31(3x,a8,a2))
          write (luions(i),80) '  LogTe   ',tab,'   LogQH  ',tab,'   Log
     &QHI ',tab,'  LogQHeI ',tab,' LogQHeII ',tab,(rom(j),tab,j=1,
     &     maxion(i))
          close (luions(i))
        enddo
      endif
c
      l=1
c
      cab=0.0
c
c     need a little kick start so there are some electrons
c     to start with....
c
      pop(2,1)=0.5d0
      pop(1,1)=0.5d0
c
      ill='P'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   90 format(' Photoionization Curve Calculation (optically thin):'/
     &' Produced by MAPPINGS V ',a12,'  Run:',a/)
      write (luop,90) theversion,runname(1:np)
      write (lupb,90) theversion,runname(1:np)
c
      write (luop,100) n2,norm
  100 format(' QH (cm/s)  , Te (K)     , ne (cm^-3) , nt (cm^-3) ,',
     & a12,', XHI        , XHII       , mu (amu)   ,',
     &' tauav      , fflos      , tloss      , eloss      ,',
     & a12)
  110 format(//,
     & 17(a12,a1))
      write (lupb,110) 'Te',tab,'ne',tab,'nt',tab,n2,tab,'XHI',tab,'XHII
     &',tab,'mu',tab,'tloss',tab,norm,tab,'ff/total',tab,'B0.0-0.1keV',
     &tab,'B0.1-0.5keV',tab,'B0.5-1.0keV',tab,'B1.0-2.0eV',tab,'B2.0-10.
     &0keV',tab,'Ball'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      m=0
      write (*,*) '   log(Q)       Te (K)         ne(cm^-1)   nH(cm^-1)'
     &,'  Free-Free  NetLoss'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  loop head
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  120 if (fmod.eq.'dens') then
        dh=10.d0**(dlog10(dh)+rinc)
        if (dh.gt.rhigh) goto 160
      endif
c
      if (fmod.eq.'rads') then
c
        qlow=10.d0**(dlog10(qlow)+qinc)
c
c     adjust source to give desired Q
c
        sv=qlow*dh/q0
c
        do i=1,infph
          soupho(i)=soupho(i)*sv
        enddo
c
        q1=q1*sv
        q2=q2*sv
        q3=q3*sv
        q0=q0*sv
c
        if (qlow.gt.(1.01d0*qhigh)) goto 160
c
      endif
c
      tf=t
      t=dabs(t)
c
      tstep=0.0d0
c
      lmod='ALL'
      imod='ALL'
      mmod='TAU'
c
      rad=1.d38
      if (wdil.eq.0.5) rad=0.d0
c
      dv=0.0d0
      fi=1.d0
      de=feldens(dh,pop)
c
      call localem (t, de, dh)
      call totphot (t, dh, rad, dr, dv, wdil, lmod)
      call zetaeff (dh)
c
      caseab(1)=0.0d0
      caseab(2)=0.0d0
c
      tstep=0.0d0
      nmod='EQUI'
      call teequi (t, tf, de, dh, tstep, nmod)
      trec=frectim(tf,de,dh)
      t=tf
c
      call localem (t, de, dh)
      call totphot (t, dh, rad, dr, dv, wdil, lmod)
      call zetaeff (dh)
c
      caseab(1)=0.0d0
      caseab(2)=0.0d0
c
      tstep=0.0d0
      nmod='EQUI'
      call teequi (t, tf, de, dh, tstep, nmod)
      trec=frectim(tf,de,dh)
      t=tf
c
      call localem (t, de, dh)
      call totphot (t, dh, rad, dr, dv, wdil, lmod)
      call zetaeff (dh)
c
      tstep=0.0d0
      nmod='EQUI'
      call teequi (t, tf, de, dh, tstep, nmod)
      trec=frectim(tf,de,dh)
      t=tf
c
      mu=fmua(de,dh)
c
      n=dh*dh
      if (jnorm.eq.0) n=de*dh
      if (jnorm.eq.1) n=dh*dh
      if (jnorm.eq.2) n=de*en
      if (jnorm.eq.3) n=(de+en)**2
      if (jnorm.eq.4) n=de*de
      invn=1.0d0/n
c
      qt=(2.0d0*q0*wdil)/dh
      qh1=(2.0d0*q1*wdil)/dh
      qhe1=(2.0d0*q2*wdil)/dh
      qhe2=(2.0d0*q3*wdil)/dh
c
      qt=dlog10(qt)
      qh1=dlog10(qh1)
      qhe1=dlog10(qhe1)
      qhe2=dlog10(qhe2)
c
      fhi=pop(1,1)
      fhii=pop(2,1)
      en=zen*dh
      write (*,'(1x,6(1pg12.5,x))') qt,t,de,dh,fflos,eloss
c
c     total energy in Jnu
c
      band1=0.d0
      band2=0.d0
      band3=0.d0
      band4=0.d0
      bandall=0.d0
c
  130  format(17(1pg12.5,a1))
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
      write (lupb,130) t,tab,de,tab,en,tab,n,tab,pop(1,1),tab,pop(2,1),
     &tab,mu,tab,tloss,tab,tloss*invn,tab,fflos/tloss,tab,b0,tab,b1,tab,
     &b2,tab,b3,tab,b4,tab,blum,tab
c
      press=(en+de)*rkb*t
      ue=gammaEOSU*press
      tnloss=tloss*invn
c
      rhotot=frho(de,dh)
      cspd=dsqrt(gammaEOS*press/rhotot)
      wmol=(rhotot/(en+de))/amu
c
      tauav=0.0d0
      call taudist (dh, tauav, dr, rad, pop, mmod)
c
      tab=','
c
  140 format(14(1pg12.5,a1))
      write (luop,140) qt,tab,t,tab,de,tab,en,tab,n,tab,pop(1,1),tab,
     &pop(2,1),tab,mu,tab,tauav,tab,fflos,tab,tloss,tab,eloss,tab,
     &tnloss,tab
c
      tl=dlog10(t)
c     ab=zion(i)
c
      if (jsaveatoms.eq.'Y') then
        do i=1,atypes
          open (luions(i),file=filn(i),status='OLD',access='APPEND')
          do j=1,maxion(i)
            poplog(j,i)=log10pz
            if (pop(j,i).gt.pzlimit) then
              poplog(j,i)=dlog10(pop(j,i))
            endif
          enddo
  150 format(i3.3,a1,5(1pg12.5,a1),31(0pg12.5,a1))
          write (luions(i),150) m,tab,tl,tab,qt,tab,qh1,tab,qhe1,tab,
     &     qhe2,tab,(poplog(j,i),tab,j=1,maxion(i))
          close (luions(i))
        enddo
      endif
c
      m=m+1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  loop tail
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      goto 120
c
c
  160 continue
c
c
      close (luop)
      close (lupb)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
