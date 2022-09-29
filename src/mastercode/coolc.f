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
      subroutine coolc ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     subroutine to compute cooling curves for collsional ionisation
c     equilibrium.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 popz(mxion, mxelem),dift
      real*8 t,tfin,tinc
      real*8 cab,cspd,de,dh,dr,dv,en,epotmi
      real*8 rho, mu, csum, tmin
      real*8 press, rad,rhotot,tnloss
      real*8 trea,tstep1,tstep2,tstep3
      real*8 ue,wmol,invn,n
      real*8 b0,b1,b2,b3,b4,blum,pe,binlum,wid
c
      integer*4 l,luop,m,i,j,jnorm,nt,idx,np
      integer*4 luions(mxelem)
c
      character caller*4, n2*12, norm*12
      character imod*4, lmod*4, model*64
      character spmod*4, jeqnenh*4
      character fn*64,jsaveatoms*4,jcoolelems*4,jsavespecs*4
      character fl*64,filn(mxelem)*64,cfiln(mxelem)*64
      character ilgg*4,jprin*4,ill*4
      character pfx*32,sfx*4,tab*4
c
c     External Functions
c
      real*8 fpresse, frho, fmua
      integer*4 mlen
c
   10 format(/,a,$)
   20 format(a)
c
      luop=21
c
      do i=1,atypes
        luions(i)=21+i
      enddo
c
      write (*,10) ' Initial temperature (log10):'
      read (*,*) tmin
c
      write (*,10) ' Final temerature (log10):'
      read (*,*) tfin
c
      write (*,10) ' Temperature step factor (log10):'
      read (*,*) tinc
c
      nt=idnint(dabs(tfin-tmin)/tinc)
      tinc=(tfin-tmin)/dble(nt)
c
      write (*,10) ' Hydrogen Density (log10):'
      read (*,*) dh
      dh=10.d0**dh
c
      trea=epsilon
      model='CIE cooling'
      caller='CC'
c
      jeqnenh='N'
      jprin='N'
      jsaveatoms='N'
      jcoolelems='N'
      jnorm=0
      tab=','
c
      if (expertmode.gt.0) then
        write (*,10) ' Set n_e = n_H (for C8 comparison) (Y/N):'
        read (*,20) jeqnenh
        call toup (jeqnenh(1:1), jeqnenh)
      endif
c
   30 format(' Normalisation:',/
     &       ' 0: ne.nH',/, ' 1: nH^2',/
     &       ' 2: ne.ni',/, ' 3: n^2',/
     &       ' 4: ne^2      :: ',$)
      write (*,30)
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
      write (*,10) ' Save element cooling files (Y/N):'
      read (*,20) jcoolelems
      call toup (jcoolelems(1:1), jcoolelems)
c
      write (*,10) ' Save element ionisation files (Y/N):'
      read (*,20) jsaveatoms
      call toup (jsaveatoms(1:1), jsaveatoms)
c
      write (*,10) ' Save .emi emissivity files (Y/N):'
      read (*,20) jsavespecs
      call toup (jsavespecs(1:1), jsavespecs)
c
      write (*,10) ' Run/code name for this calculation:'
      read (*,20) runname
      np=mlen(runname)
      write (*,*) ''
c
      if (jsaveatoms.eq.'Y') then
        do i=1,atypes
          j=i
          fn=' '
          pfx='Ion'//elem(j)
          sfx='csv'
          call newfile (pfx, elem_len(j)+3, sfx, 3, fn)
          filn(i)=fn(1:(elem_len(j)+3+5+3))
          open (luions(i),file=filn(i),status='NEW')
          write (luions(i),'(" Run        : ",a80)') runname(1:np)
          write (luions(i),'(" Element    : ",a2)') elem(i)
          write (luions(i),'(" Ionisation : ")')
   40   format(6x,a6,a2,31(6x,a6,a2))
          write (luions(i),40) ' LogTe',tab,(rom(j),tab,j=1,maxion(i))
          close (luions(i))
        enddo
      endif
c
      if (jcoolelems.eq.'Y') then
        do i=1,atypes
          j=i
          fn=' '
          pfx='Loss'//elem(j)
          sfx='csv'
          call newfile (pfx, elem_len(j)+4, sfx, 3, fn)
          cfiln(i)=fn(1:(elem_len(j)+3+5+4))
          open (luions(i),file=cfiln(i),status='NEW')
          write (luions(i),'(" Run     : ",a)') runname(1:np)
          write (luions(i),'(" Element : ",a2)') elem(i)
          write (luions(i),'(" Cooling : ")')
          write (luions(i),120)
          if (jnorm.eq.0) then
            write (luions(i),90) 'T ',tab,'n_e',tab,'n_H',tab,'n_e.n_H',
     &       tab,'rho ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses
     &(L)',tab,'L/(ne.nH)',tab,(rom(j),tab,j=1,maxion(i))
          endif
          if (jnorm.eq.1) then
            write (luions(i),90) 'T ',tab,'n_e',tab,'n_H',tab,'nH^2',
     &       tab,'rho ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses
     &(L)',tab,'L/(nH^2)',tab,(rom(j),tab,j=1,maxion(i))
          endif
          if (jnorm.eq.2) then
            write (luions(i),90) 'T ',tab,'n_e',tab,'n_H',tab,'ne.ni',
     &       tab,'rho ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses
     &(L)',tab,'L/(ne.ni)',tab,(rom(j),tab,j=1,maxion(i))
          endif
          if (jnorm.eq.3) then
            write (luions(i),90) 'T ',tab,'n_e',tab,'n_H',tab,'n^2',tab,
     &       'rho ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)'
     &       ,tab,'L/(n^2)',tab,(rom(j),tab,j=1,maxion(i))
          endif
          if (jnorm.eq.4) then
            write (luions(i),90) 'T ',tab,'n_e',tab,'n_H',tab,'ne^2',
     &       tab,'rho ',tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses
     &(L)',tab,'L/(ne^2)',tab,(rom(j),tab,j=1,maxion(i))
          endif
          write (luions(i),90) '(K)',tab,'(/cm^3)',tab,'(/cm^3)',tab,'(/
     &cm^6)',tab,'(g/cm^3)',tab,' ',tab,' ',tab,'(amu)',tab,'(erg/cm^3/s
     &)',tab,'(erg.cm^3/s)',tab,('(erg.cm^3/s)',tab,j=1,maxion(i))
          close (luions(i))
        enddo
      endif
c
c    ***ZERO BUFFER ARRAYS AND DEFINE MODE
c
      call zer
c
      jspot='N'
      jcon='Y'
      ilgg='B'
c
      cab=0.0d0
      epotmi=iphe
c
      l=1
c
      do 60 i=1,atypes
        do 50 j=1,maxion(i)
   50     pop(j,i)=0.0d0
        if ((ilgg.eq.'C').or.(ilgg.eq.'B')) pop(1,i)=1.0d0
        if (((ilgg.eq.'D').or.(ilgg.eq.'E')).or.(ilgg.eq.'F')) then
          l=1
          if (ipote(1,i).lt.epotmi) l=2
          pop(l,i)=1.0d0
        endif
   60 continue
c
c     need a little kick start so there are some electrons
c     to start with....
c
      pop(2,1)=0.5d0
      pop(1,1)=0.5d0
cc
c      call photsou (model)
cc
      call copypop (pop, pop0)
c
      ill='P'
c
      fn=' '
      pfx='coolcv'
      sfx='csv'
      call newfile (pfx, 6, sfx, 3, fn)
      fl=fn(1:14)
      open (luop,file=fl,status='NEW')
c
   70 format(' Equilibrium Cooling Curve Calculation',
     & '(CIE optically thin):'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' produced by MAPPINGS V ',a8,'  Run:',a/)
      write (luop,70) theversion,runname(1:np)
c
   80 format(' Abundances (by number H = 1.0)'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
      write (luop,80)
      call wabund (luop)
c
      tab=', '
   90 format(45(2x,a12,a2))
  100 format(15(1pg14.7,a2))
  110 format(45(1pg14.7,a2))
  120 format(' Lambda Cooling Function and X-ray Fractions:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
      write (luop,120)
      if (jnorm.eq.0) then
        write (luop,90) 'T ',tab,'n_e',tab,'n_H',tab,'ne.nH',tab,'rho ',
     &   tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     &.nH)',tab,'0.0-0.1keV',tab,'0.1-0.5keV',tab,'0.5-1.0keV',tab,'1.0-
     &2.0keV',tab,'2.0-10.0keV'
      endif
      if (jnorm.eq.1) then
        write (luop,90) 'T ',tab,'n_e',tab,'n_H',tab,'nH^2',tab,'rho ',
     &   tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(nH
     &^2)',tab,'0.0-0.1keV',tab,'0.1-0.5keV',tab,'0.5-1.0keV',tab,'1.0-2
     &.0keV',tab,'2.0-10.0keV'
      endif
      if (jnorm.eq.2) then
        write (luop,90) 'T ',tab,'n_e',tab,'n_H',tab,'ne.ni',tab,'rho ',
     &   tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     & ni)',tab,'0.0-0.1keV',tab,'0.1-0.5keV',tab,'0.5-1.0keV',tab,'1.0-
     &2.0keV',tab,'2.0-10.0keV'
      endif
      if (jnorm.eq.3) then
        write (luop,90) 'T ',tab,'n_e',tab,'n_H',tab,'n^2',tab,'rho ',
     &   tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(n^
     &2)',tab,'0.0-0.1keV',tab,'0.1-0.5keV',tab,'0.5-1.0keV',tab,'1.0-2.
     &0keV',tab,'2.0-10.0keV'
      endif
      if (jnorm.eq.4) then
        write (luop,90) 'T ',tab,'n_e',tab,'n_H',tab,'ne^2',tab,'rho ',
     &   tab,'XHI   ',tab,'XHII  ',tab,'mu ',tab,'Losses (L)',tab,'L/(ne
     &^2)',tab,'0.0-0.1keV',tab,'0.1-0.5keV',tab,'0.5-1.0keV',tab,'1.0-2
     &.0keV',tab,'2.0-10.0keV'
      endif
      write (luop,90) '(K)',tab,'(/cm^3)',tab,'(/cm^3)',tab,'(/cm^6)',
     &tab,'(g/cm^3)',tab,' ',tab,' ',tab,'(amu)',tab,'(erg/cm^3/s)',tab,
     &'(erg.cm^3/s)',tab,'(fraction)',tab,'(fraction)',tab,'(fraction)',
     &tab,'(fraction)',tab,'(fraction)'
c
      write (*,120)
      if (jnorm.eq.0) then
        write (*,*) 'T             n_e           n_H         ne.nH
     & ',' mu          Losses (L)   L/(ne.nH)    ',' 0.5-1.0keV   1.0-2
     &.0keV   2.0-10.0keV'
      endif
      if (jnorm.eq.1) then
        write (*,*) 'T             n_e           n_H         nH^2
     & ',' mu          Losses (L)   L/(nH^2)     ',' 0.5-1.0keV   1.0-2
     &.0keV   2.0-10.0keV'
      endif
      if (jnorm.eq.2) then
        write (*,*) 'T             n_e           n_H         ne.ni
     & ',' mu          Losses (L)   L/(ne.ni)    ',' 0.5-1.0keV   1.0-2
     &.0keV   2.0-10.0keV'
      endif
      if (jnorm.eq.3) then
        write (*,*) 'T             n_e           n_H         n^2
     & ',' mu          Losses (L)   L/(n^2)      ',' 0.5-1.0keV   1.0-2
     &.0keV   2.0-10.0keV'
      endif
      if (jnorm.eq.4) then
        write (*,*) 'T             n_e           n_H         ne^2
     & ',' mu          Losses (L)   L/(ne^2)     ',' 0.5-1.0keV   1.0-2
     &.0keV   2.0-10.0keV'
      endif
c
      do m=0,nt
c
        t=10.d0**(tmin+m*tinc)
c
        wdil=0.5000d0
        dr=1.0d0
c
        de=dh*zion(mapz(1))
        tstep1=0.0d0
        tstep2=0.0d0
        tstep3=0.0d0
c
        lmod='LOCL'
        imod='ALL'
        rad=1.d38
        if (wdil.eq.0.d0) rad=0.d0
        dv=0.0d0
        fi=1.d0
c
        do i=1,atypes
          caseab(i)=cab
        enddo
c
        call equion (t, de, dh)
        if (jeqnenh.eq.'Y') de=dh
c
        if (jsavespecs.eq.'Y') then
c
c     Update Radiation Fields
c
          call localem (t, de, dh)
          lmod='LOCL'
          wdil=0.5000d0
          call totphot2 (t, dh, rad, dr, dv, wdil, lmod)
c
        else
          call cool (t, de, dh)
        endif
c
        i=0
c
        trea=pzlimit
        dift=0.d0
c
  130   call copypop (pop, popz)
c
        call equion (t, de, dh)
        if (jeqnenh.eq.'Y') de=dh
c
        if (jsavespecs.eq.'Y') then
c
c     Update Radiation Fields
c
          call localem (t, de, dh)
          lmod='LOCL'
          wdil=0.500d0
          call totphot2 (t, dh, rad, dr, dv, wdil, lmod)
c
        else
          call cool (t, de, dh)
        endif
c
        call difpop (pop, popz, trea, atypes, dift)
        call copypop (pop, popz)
c
        i=i+1
c
        if ((dift.ge.1.0d-6).and.(i.le.5)) goto 130
c
        call equion (t, de, dh)
        if (jeqnenh.eq.'Y') de=dh
c save final pops for next iteration
        call copypop (pop, popz)
c
c     Update Radiation Fields - calls cool
c
        call localem (t, de, dh)
        lmod='LOCL'
        wdil=0.500d0
        call totphot2 (t, dh, rad, dr, dv, wdil, lmod)
c
        csum=0.d0
        do j=1,atypes
          csum=csum+coolz(j)
        enddo
c
        press=fpresse(t,de,dh)
        rho=frho(de,dh)
        mu=fmua(de,dh)
c
        en=zen*dh
        n=(de*dh)
        if (jnorm.eq.0) n=(de*dh)
        if (jnorm.eq.1) n=(dh*dh)
        if (jnorm.eq.2) n=(de*en)
        if (jnorm.eq.3) n=((de+en)*(de+en))
        if (jnorm.eq.4) n=(de*de)
        if (n.gt.0.d0) then
          invn=1.d0/n
        else
          invn=0.d0
        endif
c
        ue=gammaEOSU*(en+de)*rkb*t
        tnloss=tloss*invn
        rhotot=frho(de,dh)
        cspd=dsqrt(gammaEOS*press/rhotot)
        wmol=(rhotot/(en+de))/amu
c
        b0=0.d0
        b1=0.d0
        b2=0.d0
        b3=0.d0
        b4=0.d0
        blum=0.d0
        do idx=1,infph-1
          wid=widbinnu(idx)
          pe=photev(idx)
          binlum=tphot(idx)*wid*fpi
          blum=blum+binlum
          if ((pe.gt.0.0d0).and.(pe.le.100.0d0)) b0=b0+binlum
          if ((pe.gt.100.0d0).and.(pe.le.500.0d0)) b1=b1+binlum
          if ((pe.gt.500.0d0).and.(pe.le.1000.0d0)) b2=b2+binlum
          if ((pe.gt.1000.0d0).and.(pe.le.2000.0d0)) b3=b3+binlum
          if ((pe.gt.2000.0d0).and.(pe.le.10000.0d0)) b4=b4+binlum
        enddo
c
        b0=b0/tloss
        b1=b1/tloss
        b2=b2/tloss
        b3=b3/tloss
        b4=b4/tloss
        blum=blum/tloss
c
        if (b0.lt.ioepsilon) b0=0.d0
        if (b1.lt.ioepsilon) b1=0.d0
        if (b2.lt.ioepsilon) b2=0.d0
        if (b3.lt.ioepsilon) b3=0.d0
        if (b4.lt.ioepsilon) b4=0.d0
        if (tloss.lt.ioepsilon) tloss=0.d0
c
        write (*,'(x,10(1pg12.5,x))') t,de,dh,n,mu,tloss,tloss*invn,b1+
     &   b2,b3,b4
c
        write (luop,100) t,tab,de,tab,dh,tab,en,tab,rho,tab,pop(1,1),
     &   tab,pop(2,1),tab,mu,tab,tloss,tab,tloss*invn,tab,b0,tab,b1,tab,
     &   b2,tab,b3,tab,b4
c
        if (jsavespecs.eq.'Y') then
c
c     output photon file
c
          caller='CC'
          pfx='cool'
          spmod='NORM'
          pfx='xray'
          call wemiss2 (caller, pfx, 4, t, de, dh, dr, 1d23*invn, tphot)
c
          dr=1.0d0
          call sumdata (t, de, dh, dr, dr, dr, imod)
          call avrdata
          pfx='spec'
          call wrspec (caller, pfx, 4, t, de, dh)
c
        endif
c
        if (jsaveatoms.eq.'Y') then
          do i=1,atypes
            open (luions(i),file=filn(i),status='OLD',access='APPEND')
  140       format(1pe12.5,a2,31(1pe12.5,a2))
            write (luions(i),140) t,tab,(pop(j,i),tab,j=1,maxion(i))
            close (luions(i))
          enddo
        endif
c
        if (jcoolelems.eq.'Y') then
          do i=1,atypes
            open (luions(i),file=cfiln(i),status='OLD',access='APPEND')
            write (luions(i),110) t,tab,de,tab,dh,tab,n,tab,rho,tab,
     &       pop(1,1),tab,pop(2,1),tab,mu,tab,coolz(i),tab,coolz(i)*
     &       invn,(tab,coolzion(j,i)*invn,j=1,maxion(i))
            close (luions(i))
          enddo
        endif
c clear radiation and pops then restore last pop
        call zer
        call copypop (popz, pop)
c
      enddo
      close (luop)
c
      write (*,150) fn
  150 format(//' Output created in : ',a14)
c
      return
      end
