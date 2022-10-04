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
c       Version v5.2.0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine photsou (model)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO ADD A PHOTOIONISATION SOURCE IN THE VECTOR SOUPHO(I)
c     EACH POINT CORRESPONDS TO THE INTENSITY OF RADIATION
c     AT THE MIDDLE OF THE ENERGY INTERVAL : EPHOT(I),EPHOT(I+1)
c     UNITS : ERGS.CM-2.SEC-1.STERAD-1.HZ-1    (INU )
c
c     Inu in 2D 1/pi units *not* 3D 1/(4pi) like the Jnu
c     diffuse field vectors This is so that geometric
c     dilution is simpler etc
c
c     External files are all 3D Jnu 1/(4pi) because they are
c     generally written from diffuse field vectors.  If
c     external stellar atmosphere files are converted for use
c     in MAPPINGS, the units will have to be checked and
c     either converted to 3D units or scaled down by 4 after
c     readin.
c
c     THE NUMBER OF EMERGENT PHOTONS FOR DIFFERENT SPAN IN
c     ENERGY ARE CONTAINED IN QHI,QHEI,QHEII,QHT(=SUM OF THE 3)
c
c     CALL SUBROUTINE FPOL,INTINU
c
c     **REFERENCES : HUMMER,D.G.,MIHALAS,D.M.(1970)MNRAS,147,P.339
c     SHIELDS,G.A.,SEARLE,L., (1978)APJ.222,P.830
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'cblocks.inc'
c
c           Variables
c
      real*8 bv,etr
      real*8 souvec(mxinfph)
      real*8 readflux(mxinfph)
      real*8 scale,widnu,den,sv
      real*8 blum,ilum,xlum
      real*8 q1,q2,q3,qall,qoii,qx,qi
      real*8 q4,yc
c
      real*8 bflum,iflum,qfall,qfi
      real*8 fratio,ifraction
c
      integer*4 nmetalqs
      integer*4 ionelem(21)
      integer*4 ionion(21)
      real*8 ionlimits(21)
      real*8 ionqs(21)
      real*8 ionis(21)
c
      integer*4 nxqs,np
      real*8 xraylimits(5)
      real*8 xrayqs(5)
      real*8 xrayis(5)
      real*8 qh2
c
      integer*4 fv,iinf,iinto,j,ki,kii,l
      integer*4 kiii,luin,luop,i
c
      character model*64, caract*160
      character ilgg*4,ftype*4
      character sub*4, subsub*4, wmod*4
      character fname*256
c
      logical iexi
c
      integer*4 lenv
c
c     old (Draine 79 UV)
c     real*8 fev,a1,a2,a3,
c     integer*4 fuvmin
c
      luin=17
      luop=18
c
c     ***ZERO VECTOR SOUVEC AND RELATED QUANTITIES
c
      ifraction=0.0d0
      ftype='A'
      do i=1,infph
        souvec(i)=0.0d0
        readflux(i)=0.d0
        skipbin(i)=.true.
      enddo
c
      nMetalQs=21
c     HI
      ionElem(1)=zmap(1)
c     HeI
      ionElem(2)=zmap(2)
c     HeII
      ionElem(3)=zmap(2)
c     CII
      ionElem(4)=zmap(6)
c     CIII
      ionElem(5)=zmap(6)
c     CIV
      ionElem(6)=zmap(6)
c     NII
      ionElem(7)=zmap(7)
c     NIII
      ionElem(8)=zmap(7)
c     NIV
      ionElem(9)=zmap(7)
c     OII
      ionElem(10)=zmap(8)
c     OIII
      ionElem(11)=zmap(8)
c     OIV
      ionElem(12)=zmap(8)
c     NeII
      ionElem(13)=zmap(10)
c     NeIII
      ionElem(14)=zmap(10)
c     NeIV
      ionElem(15)=zmap(10)
c     SII
      ionElem(16)=zmap(16)
c     SIII
      ionElem(17)=zmap(16)
c     SIV
      ionElem(18)=zmap(16)
c     FeII
      ionElem(19)=zmap(26)
c     FeIII
      ionElem(20)=zmap(26)
c     FeIV
      ionElem(21)=zmap(26)
c
c     HI
      ionIon(1)=1
c     HeI
      ionIon(2)=1
c     HeII
      ionIon(3)=2
c     CII
      ionIon(4)=2
c     CIII
      ionIon(5)=3
c     CIV
      ionIon(6)=4
c     NII
      ionIon(7)=2
c     NIII
      ionIon(8)=3
c     NIV
      ionIon(9)=4
c     OII
      ionIon(10)=2
c     OIII
      ionIon(11)=3
c     OIV
      ionIon(12)=4
c     NeII
      ionIon(13)=2
c     NeIII
      ionIon(14)=3
c     NeIV
      ionIon(15)=4
c     SII
      ionIon(16)=2
c     SIII
      ionIon(17)=3
c     SIV
      ionIon(18)=4
c     FeII
      ionIon(19)=2
c     FeIII
      ionIon(20)=3
c     FeIV
      ionIon(21)=4
c
c      eV ionisation limits ion,elem
c
c     HI
      ionLimits(1)=ipotev(1,ionElem(1))
c     HeI
      ionLimits(2)=ipotev(1,ionElem(2))
c     HeII
      ionLimits(3)=ipotev(2,ionElem(3))
c     CII
      ionLimits(4)=ipotev(2,ionElem(4))
c     CIII
      ionLimits(5)=ipotev(3,ionElem(5))
c     CIV
      ionLimits(6)=ipotev(4,ionElem(6))
c     NII
      ionLimits(7)=ipotev(2,ionElem(7))
c     NIII
      ionLimits(8)=ipotev(3,ionElem(8))
c     NIV
      ionLimits(9)=ipotev(4,ionElem(9))
c     OII
      ionLimits(10)=ipotev(2,ionElem(10))
c     OIII
      ionLimits(11)=ipotev(3,ionElem(11))
c     OIV
      ionLimits(12)=ipotev(4,ionElem(12))
c     NeII
      ionLimits(13)=ipotev(2,ionElem(13))
c     NeIII
      ionLimits(14)=ipotev(3,ionElem(14))
c     NeIV
      ionLimits(15)=ipotev(4,ionElem(15))
c     SII
      ionLimits(16)=ipotev(2,ionElem(16))
c     SIII
      ionLimits(17)=ipotev(3,ionElem(17))
c     SIV
      ionLimits(18)=ipotev(4,ionElem(18))
c     FeII
      ionLimits(19)=ipotev(2,ionElem(19))
c     FeIII
      ionLimits(20)=ipotev(3,ionElem(20))
c     FeIV
      ionLimits(21)=ipotev(4,ionElem(21))
c
      do i=1,nMetalQs
        ionQs(i)=0.0d0
        ionIs(i)=0.0d0
      enddo
      nXQs=5
      xrayLimits(1)=100.d0
      xrayLimits(2)=1000.d0
      xrayLimits(3)=2000.d0
      xrayLimits(4)=5000.d0
      xrayLimits(5)=10000.d0
      do i=1,nXQs
        xrayQs(i)=0.0d0
        xrayIs(i)=0.0d0
      enddo
c
      ipho=ipho+1
      zstar=0.0d0
      alnth=0.0d0
      teff=0.0d0
      cut=0.0d0
      srcfile='None'
      scale=1.0d0
      blum=0.0d0
      ilum=0.0d0
      qall=0.0d0
      etr=photev(infph)/iph
c
c     ***CHOICE OF THE TYPE OF SOURCE
c
      write (*,10) model
      write (*,20)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & ' Setting the radiation field for ',a16/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
   20 format(' The initial field is zeroed, successive source types'/
     & ' add to the total field until exit.  The field may be',/
     & ' re-initialised with the (Z) zero option',/)
c
      goto 40
c
c loop back point for new flux
c
c IF = input as a fraction of existing field, ionising intensity
c ifraction > 0  ( others not yet implented, see normalise field)
c
   30 if (ifraction.gt.0.d0) then
c
c get current field, in E and Phots, total, ion and xrays
c
        blum=0.d0
        qall=0.d0
c
        ilum=0.d0
        qi=0.d0
c
        xlum=0.d0
        qx=0.d0
c
        do i=1,infph-1
          if (souvec(i).gt.epsilon) then
            widnu=widbinnu(i)
            blum=blum+souvec(i)*widnu
            qall=qall+souvec(i)*widnu/cphote(i)
            if (photev(i).ge.iph) then
              ilum=ilum+souvec(i)*widnu
              qi=qi+souvec(i)*widnu/cphote(i)
            endif
            do j=1,nMetalQs
              if (photev(i).ge.ionLimits(j)) ionQs(j)=ionQs(j)+souvec(i)
     &         *widnu/cphote(i)
              if (photev(i).ge.ionLimits(j)) ionIs(j)=ionIs(j)+souvec(i)
     &         *widnu
            enddo
            do j=1,nXQs
              if (photev(i).ge.xrayLimits(j)) xrayQs(j)=xrayQs(j)+
     &         souvec(i)*widnu/cphote(i)
              if (photev(i).ge.xrayLimits(j)) xrayIs(j)=xrayIs(j)+
     &         souvec(i)*widnu
            enddo
          endif
        enddo
c
c  souvec is Inu 1/pi units
c
        blum=blum*pi
        ilum=ilum*pi
        xlum=xlum*pi
        qall=qall*pi
        qi=qi*pi
        qx=qx*pi
c
c get readflux field integrals
c
        bflum=0.d0
        iflum=0.d0
        qfall=0.d0
        qfi=0.d0
c
        do i=1,infph-1
          widnu=widbinnu(i)
          bflum=bflum+readflux(i)*widnu
          qfall=qfall+readflux(i)*widnu/cphote(i)
          if (photev(i).ge.iph) then
            iflum=iflum+readflux(i)*widnu
            qfi=qfi+readflux(i)*widnu/cphote(i)
          endif
          do j=1,nMetalQs
            if (photev(i).ge.ionLimits(j)) ionQs(j)=ionQs(j)+readflux(i)
     &       *widnu/cphote(i)
            if (photev(i).ge.ionLimits(j)) ionIs(j)=ionIs(j)+readflux(i)
     &       *widnu
          enddo
          do j=1,nXQs
            if (photev(i).ge.xrayLimits(j)) xrayQs(j)=xrayQs(j)+
     &       readflux(i)*widnu/cphote(i)
            if (photev(i).ge.xrayLimits(j)) xrayIs(j)=xrayIs(j)+
     &       readflux(i)*widnu
          enddo
        enddo
c
c scale these direct Inu  by pi to allow the main subroutine to
c rescale from Inu units.
c
        bflum=bflum*pi
        iflum=iflum*pi
        qfall=qfall*pi
        qfi=qfi*pi
        do j=1,nMetalQs
          ionQs(j)=ionQs(j)*pi
          ionIs(j)=ionIs(j)*pi
        enddo
        do j=1,nXQs
          xrayQs(j)=xrayQs(j)*pi
          xrayIs(j)=xrayIs(j)*pi
        enddo
c
c  default ionising luminosity ratio incase ftype is malformed
c
        fratio=(iflum/ilum)
        if (ftype.eq.'A') fratio=(bflum/blum)
        if (ftype.eq.'B') fratio=(qfall/qall)
        if (ftype.eq.'C') fratio=(iflum/ilum)
        if (ftype.eq.'D') fratio=(qfi/qi)
        if (ftype.eq.'E') fratio=(xrayIs(1)/xlum)
        if (ftype.eq.'F') fratio=(xrayQs(1)/qx)
c
c scale to desired fraction
c
c       write(*,*) ' Ratio, Fraction, Scale:'
c       write(*,'(3(x,1pg12.5))')  fratio, ifraction, ifraction/fratio
c
        fratio=ifraction/fratio
        do i=1,infph-1
          readflux(i)=fratio*readflux(i)
        enddo
c ifraction > 0
      endif
c
c add readflux into existing souvec
c
      do i=1,infph
        if (readflux(i).gt.epsilon) then
          souvec(i)=souvec(i)+readflux(i)
          skipbin(i)=.false.
        endif
      enddo
c
c loop back for operators or cancels
c
   40 continue
c
      souvec(infph)=0.d0
      blum=0.d0
      ilum=0.d0
      qoii=0.d0
      qall=0.d0
      qh2=0.0d0
      do j=1,nMetalQs
        ionQs(j)=0.0d0
        ionIs(j)=0.0d0
      enddo
      do j=1,nXQs
        xrayQs(j)=0.0d0
        xrayIs(j)=0.0d0
      enddo
c
c  Semi-Infinite Integrals
c
      do i=1,infph-1
        if (souvec(i).gt.epsilon) then
          widnu=widbinnu(i)
          blum=blum+souvec(i)*widnu
          qall=qall+souvec(i)*widnu/(cphote(i))
          if (photev(i).ge.iph) then
            ilum=ilum+souvec(i)*widnu
            qh2=qh2+souvec(i)*widnu/(cphote(i))
          endif
c
          do j=1,nMetalQs
            if (photev(i).ge.ionLimits(j)) ionQs(j)=ionQs(j)+souvec(i)*
     &       widnu/cphote(i)
            if (photev(i).ge.ionLimits(j)) ionIs(j)=ionIs(j)+souvec(i)*
     &       widnu
          enddo
          do j=1,nXQs
            if (photev(i).ge.xrayLimits(j)) xrayQs(j)=xrayQs(j)+
     &       souvec(i)*widnu/cphote(i)
            if (photev(i).ge.xrayLimits(j)) xrayIs(j)=xrayIs(j)+
     &       souvec(i)*widnu
          enddo
        else
          souvec(i)=0.d0
        endif
      enddo
c
c     Plane Parallel Inu, pi not 4pi. souvec is 1/4pi sr
c
      qall=pi*qall
      blum=pi*blum
      ilum=pi*ilum
      do j=1,nMetalQs
        ionQs(j)=ionQs(j)*pi
        ionIs(j)=ionIs(j)*pi
      enddo
      do j=1,nXQs
        xrayQs(j)=xrayQs(j)*pi
        xrayIs(j)=xrayIs(j)*pi
      enddo
c
      q1=0.0d0
      q2=0.0d0
      q3=0.0d0
      q4=0.0d0
c
c souvec is Inu 1/pi, use intinu for Inu
c so no longer *0.25 to getintegrals, cf ilum and qht.
c
c   absolute tests for BB
c
c   emissivty BB  = (12pi k^4)/(c^2 h^3) zeta(4) T^4,
c         zeta(4) = pi^4/90
c                 = s T^4 = 5.67037441918443e-05 T^4
c
c     photons BB  = (4pi k^3)/(c^2 h^3) zeta(3) T^3
c         zeta(3) = 1.20205690315959428540....
c                 = r T^3 = 1.52046085939314e+11 T^3
c
      call intinu (souvec, q1, q2, q3, q4)
c
      qhi=q1
      qhei=q2
      qheii=q3
      qht=q4
c
      if (qht.gt.epsilon) then
c
        write (*,50) blum,qall,ilum,qht,ilum/(ev*qht),xrayIs(1)/(ev*
     &   xrayQs(1)),qht,qhi,qhei,qheii
   50 format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::',
     & '::::::::::::::::'/
     & '  Total Intensity     : ',1pg12.5,' (ergs/s/cm^2)  '/
     & '  Total Photons       : ',1pg12.5,' (phots/cm^2/s) '/
     & '  Ion. Intensity      : ',1pg12.5,' (ergs/s/cm^2)  * '/
     & '  Ion. Photons (FQ)   : ',1pg12.5,' (phots/cm^2/s) * '/
     & '  <Ion. Photon <100eV>: ',1pg12.5,' (eV) '/
     & '  <X Photon E > 100eV>: ',1pg12.5,' (eV) '/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::',
     & '::::::::::::::::'/
     & '  FQ Total  (>13.6eV) : ',1pg12.5,' (phots/cm^2/s) * '/
     & '  FQHI  (13.6-24.6eV) : ',1pg12.5,' (phots/cm^2/s) '/
     & '  FQHeI (24.6-54.4eV) : ',1pg12.5,' (phots/cm^2/s) '/
     & '  FQHeII    (>54.4eV) : ',1pg12.5,' (phots/cm^2/s) ')
        write (*,60) (ionQs(i),i=4,nMetalQs)
   60 format(
     &  ' :::Key Metal Ions (phots/cm^2/s)::::::::::::::::',
     & '::::::::::::::::'/
     &  '  CII,III,IV :',1pg10.3, 1pg10.3, 1pg10.3, ' : ',
     & '(24.4,47.9,64.5eV) '/
     &  '  NII,III,IV :',1pg10.3, 1pg10.3, 1pg10.3, ' : ',
     & '(29.6,47.4,77.5eV) '/
     &  '  OII,III,IV :',1pg10.3, 1pg10.3, 1pg10.3, ' : ',
     & '(35.1,54.9,77.4eV) '/
     &  '  NeII,III,IV:',1pg10.3, 1pg10.3, 1pg10.3, ' : ',
     & '(41.0,63.4,97.2eV) '/
     &  '  SII,III,IV :',1pg10.3, 1pg10.3, 1pg10.3, ' : ',
     & '(23.3,34.9,47.2eV) '/
     &  '  FeII,III,IV:',1pg10.3, 1pg10.3, 1pg10.3, ' : ',
     & '(16.2,30.7,54.9eV) '/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::',
     & '::::::::::::::::')
        write (*,70) (xrayIs(j),xrayQs(j),j=1,nXQs)
   70 format(
     & '  X-Ray >0.1keV int. : ',1pg12.5,' (ergs/s/cm^2)'/
     & '  X-Ray >0.1keV Phot.: ',1pg12.5,' (phots/cm^2/s'/
     & '  X-Ray >1.0keV int. : ',1pg12.5,' (ergs/s/cm^2)'/
     & '  X-Ray >1.0keV Phot.: ',1pg12.5,' (phots/cm^2/s'/
     & '  X-Ray >2.0keV int. : ',1pg12.5,' (ergs/s/cm^2)'/
     & '  X-Ray >2.0keV Phot.: ',1pg12.5,' (phots/cm^2/s'/
     & '  X-Ray >5.0keV int. : ',1pg12.5,' (ergs/s/cm^2)'/
     & '  X-Ray >5.0keV Phot.: ',1pg12.5,' (phots/cm^2/s'/
     & '  X-Ray >10.keV int. : ',1pg12.5,' (ergs/s/cm^2)'/
     & '  X-Ray >10.keV Phot.: ',1pg12.5,' (phots/cm^2/s'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::',
     & '::::::::::::::::'//)
      endif
c
c These options work but are not listed
c
c     & '    C4 :   WMBASIC O-Star Grid Models (27500-48500K)'/
c     & '    C5 :   CMFGEN Theta1C Models (37000-41000K)'/
c     & '    C6 :   Old polynomial 4G stars from MAPPINGS II'/
c     & '    OX :   AGN (OPTXAGNF, Done et al 2012) '/
c     & '   IFI :   Input as a fraction of ionising intensity'/
      write (*,80) infph-1,infph,infph-1,infph
   80 format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::',
     & '::::::::::::::::'/
     & '  Multiple Component Photoionisation Source: '/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::',
     & '::::::::::::::::'/
     & ' Basic Sources:'/
     & '    A  :   Power Law, non-thermal component (c*nu**Alpha)'/
     & '    B  :   Black Body component'/
     & '    E  :   Bremsstrahlung component (c*exp(-hnu/kT))'/
     & ' Stellar Sources:'/
     & '    C1 :   ATLAS9 Stellar models    (30000 - 50000K)'/
     & '    C2 :   TLUSTY Stellar models    (27500 - 55000K)'/
     & '    C3 :   CMFGEN Stellar models    (27500 - 48500K)'/
     & '    C4 :   WMBASIC Stellar Moont, Westmoquette 2004'/
     & '    P1 :   TNMAP CSPN New HNi models (50kK -  190kK)'/
     & '    P2 :   TNMAP CSPN Old HCa models (50kK - 1000kK)'/
     & ' Non-Stellar Sources:'/
     & '    F  :   Local ISRF (Mathis etal (1993)'/
     & '    G  :   AGN (Bland-Hawthorn et al 2013) '/
     & '    J  :   AGN (Component Library v2, Jin et al 2012) '/
     & '    OX :   OPTXAGNF full AGN model '/
     & ' File I/O Sources:'/
     & '    HS :   Input SLUG2 spectrum file (n*m POINTS)'/
     & '    H  :   Input SB99 spectrum1 file (n*1221 POINTS)'/
     & '    K  :   Input two column flux file (variable POINTS)'/
     & '    I  :   Input sou file    (',i4,'|',i4,' POINTS)'/
     & '    O  :   Output sou file   (',i4,'|',i4,' POINTS)'/
     & ' Operations:'/
     & '    Z  :   Zero (clear) radiation'/
     & '    S  :   Apply overall Scaling factor...'/
     & '    N  :   Normalise fluxes...'/
     & '    X  :   eXit with current source'/
     & ' :: ',$)
      iso='    '
      read (*,90) iso
   90 format(a)
      call toup (iso, iso)
      subsub=iso(3:3)
      sub=iso(2:2)
      iso=iso(1:1)
      if ((iso.eq.'H').and.(sub.eq.'')) sub='9'
      ifraction=0.d0
      if ((sub.eq.'F').or.(subsub.eq.'F')) then
  100 format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Input new source as a fraction of existing : '/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Total Intensity          (ergs/s/cm^2)  '/
     & '    B  : Total Photons            (phots/cm^2/s)   '/
     & '    C  : Ionising Intensity       (ergs/s/cm^2)  '/
     & '    D  : Ionising Photons         (phots/cm^2/s)   '/
     & '    E  : X-Ray >0.1keV Intensity  (ergs/s/cm^2)  '/
     & '    F  : X-Ray >0.1keV Photons    (phots/cm^2/s)   '/
     & ' :: ',$)
        write (*,100)
        ftype='    '
        read (*,90) ftype
        call toup (ftype(1:1), ftype)
        write (*,*)
  110 format( ' Fraction of existing field (>0) :',$)
        write (*,110)
        read (*,*) ifraction
      endif
c
c Basic sources, powerlaw and BB
c
      if (iso.eq.'A') goto 160
      if (iso.eq.'B') goto 150
c Stars
c ATLAS9 Stellar models
      if ((iso.eq.'C').and.(sub.eq.'1')) goto 230
c TLUSTY Stellar models
      if ((iso.eq.'C').and.(sub.eq.'2')) goto 240
c CMFGEN Stellar models
      if ((iso.eq.'C').and.(sub.eq.'3')) goto 250
c WMBASIC Moont, Westmoquette 2004
      if ((iso.eq.'C').and.(sub.eq.'4')) goto 260
c Theta 1C 40M_0 CMFGEN MODELS
      if ((iso.eq.'C').and.(sub.eq.'5')) goto 270
c Theta 1C 40M_0 20 atom solar stars
      if ((iso.eq.'C').and.(sub.eq.'6')) goto 280
c 4G polynomial 'stars'
      if ((iso.eq.'C').and.(sub.eq.'7')) goto 220
      if ((iso.eq.'P').and.(sub.eq.'1')) goto 290
      if ((iso.eq.'P').and.(sub.eq.'2')) goto 300
c  AGN spectra
      if (iso.eq.'G') goto 190
      if (iso.eq.'J') goto 200
      if ((iso.eq.'O').and.(sub.eq.'X')) goto 210
c Misc
      if (iso.eq.'E') goto 170
      if (iso.eq.'F') goto 180
c File IO
      if ((iso.eq.'H').and.(sub.eq.'9')) goto 330
      if ((iso.eq.'H').and.(sub.eq.'S')) goto 350
      if (iso.eq.'H') goto 330
      if (iso.eq.'I') goto 370
      if (iso.eq.'K') goto 310
      if (iso.eq.'O') goto 540
c operations
      if (iso.eq.'N') goto 140
      if (iso.eq.'Z') goto 120
      if (iso.eq.'S') goto 130
c exit
      if (iso.eq.'X') goto 610
c
      write (*,*) 'Unknown Component Type:',iso,' Re-Enter code.'
c
      ifraction=0.d0
      ftype='A'
      do i=1,infph
        readflux(i)=0.d0
      enddo
c
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Zero field
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  120 call zerofield (souvec)
c
      ipho=ipho+1
      zstar=0.0d0
      alnth=0.0d0
      teff=0.0d0
      cut=0.0d0
      srcfile='None'
      scale=1.0000d0
      blum=0.d0
      ilum=0.d0
      etr=photev(infph)/iph
c
      goto 40
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     scale factor
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  130 call scalefield (souvec)
      goto 40
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Normalise
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  140 call normalisefield (souvec)
      goto 40
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    ***STAR WITH BLACK BODY DISTRIBUTION
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  150 call blackbody (readflux)
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    ***NON-THERMAL SOURCE ; INTENSITY PROPORTIONAL TO NU**ALPHA
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  160 call powerlaw (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    ***X-Ray Thermal Bremsstrahlung ; A exp (-h nu/kT)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  170 call bremss (readflux)
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c      Local Interstellar Radiation Field
c           Mathis, Mezger, Panagia 1983
c
c     in photons cm-2 sr-1 eV-1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  180 call interstellar (readflux)
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c ***AGN QUASAR SOURCE ; INTENSITY Big Blue Bump + Powerlaw and cutoffs
c
c  L = k1 e^(-alpha1) exp(-e/e1)
c    + k2 e^(-alpha2) exp(-e/e2) H(e - e1)
c
c  L = k1 e^(-alpha1) exp(-e/e1)
c    + k2 e^(-alpha2) exp(-e/e2) exp(6.0*(e - e1)/e1
c
c  H is the heavyside operator  Spectrum in photons
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  190 call jbhagn (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c read AGN Model Files 2012MNRAS,425,907J
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  200 call componentagn2 (readflux)
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Full OPTXAGNF AGN Model Files 2012MNRAS,425,907J
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  210 call doneagn (readflux)
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    *** HUMMER,D.G.,MIHALAS,D.M.(1970) 4G polynomial 'stars'
cc    ***STELLAR ATMOSPHERE MODELS
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
  220 call stellar (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***ATLAS9 STELLAR ATMOSPHERE MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  230 call atlas (readflux)
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***TLUSTY STELLAR ATMOSPHERE MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  240 call tlusty (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***CMFGEN Ostar Grid Atmosphere MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
  250 call cmfgenostars (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***WMBASIC Moont, Westmoquette 2004 STELLAR ATMOSPHERE MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
  260 call wmbasic (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***Theta 1C 40M_0 CMFGEN MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
  270 call theta1c (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***Theta 1C 40M_0 CMFGEN MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
  280 call mocassin18 (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***Rauch CSPN current HNi Grid Atmospheres
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
  290 call cspn_hni (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***Rauch CSPN older HCa Grid Atmospheres
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
  300 call cspn_hca (readflux)
      goto 30
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c read  generic flux files
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  310 fname=' '
  320 format(/' Enter two column flux file name : ',$)
      write (*,320)
      read (*,'(a)') fname
      write (*,*)
      l=lenv(fname)
      inquire (file=fname(1:l),exist=iexi)
      if (iexi) then
        write (*,*) ' Reading: ',fname(1:l)
      else
        write (*,*) fname(1:l),' NOT FOUND. Retry...'
        goto 30
      endif
c
      do i=1,infph
        readflux(i)=0.d0
      enddo
c
      srcfile=fname
c     format 2 = generic two column file
      call readrebin (fname, 3, readflux)
c
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c read  lambda-L_lam SB99 spectrum luminous flux files
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  330 continue
c
      do i=1,infph
        readflux(i)=0.d0
      enddo
c
      fname=' '
  340 format(/' Enter SB99 spectrum file name : ',$)
      write (*,340)
      read (*,'(a)') fname
      write (*,*)
      l=lenv(fname)
      inquire (file=fname(1:l),exist=iexi)
      if (iexi) then
        write (*,*) ' Reading: ',fname(1:l)
      else
        write (*,*) fname(1:l),' NOT FOUND. Retry...'
        goto 30
      endif
c
      do i=1,infph
        readflux(i)=0.d0
      enddo
c
      srcfile=fname
c format 1 = lambda-L_lam SB99 spectrum
      call readrebin (fname, 1, readflux)
c
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c read  lambda-L_lam SLUG2 5 column spectrum luminous flux files
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  350 continue
c
      do i=1,infph
        readflux(i)=0.d0
      enddo
c
      fname=' '
  360 format(/' Enter SLUG2 5 column file name : ',$)
      write (*,360)
      read (*,'(a)') fname
      write (*,*)
      l=lenv(fname)
      inquire (file=fname(1:l),exist=iexi)
      if (iexi) then
        write (*,*) ' Reading: ',fname(1:l)
      else
        write (*,*) fname(1:l),' NOT FOUND. Retry...'
        goto 30
      endif
c
      do i=1,infph
        readflux(i)=0.d0
      enddo
c
      srcfile=fname
      call readrebin (fname, 11, readflux)
c
      goto 30
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     ***READ SOURCE FROM EXTERNAL FILE
c
c     file NEEDS "PHOTON SOURCE FILE" in header to be recognized
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  370 continue
c
      do i=1,infph
        readflux(i)=0.d0
      enddo
c
  380 fname=' '
      write (*,390)
  390 format(/' Enter file name : ',$)
      read (*,400) fname
  400 format(a)
      write (*,*)
      l=lenv(fname)
      inquire (file=fname(1:l),exist=iexi)
      if (iexi) then
        write (*,*) ' Reading: ',fname(1:l)
      else
        write (*,*) fname(1:l),' NOT FOUND. Retry...'
        goto 40
      endif
c
      if (iexi) then
c
c     found the file...
c
c     get turn on
c
        etr=photev(1)
  410   write (*,420) etr
  420 format(/' Turn-on energy (Min.:',1pg12.5,' eV.) : ',$)
        read (*,*) yc
        write (*,*)
        if (yc.lt.0.0d0) goto 410
        turn=yc
c
c     get turn off
c
        etr=photev(infph)
  430   write (*,440) etr
  440 format(/' Cut-off energy (Max.:',1pg12.5,' eV) : ',$)
c
        read (*,*) yc
        write (*,*)
        if (yc.lt.0.0d0) goto 430
        cut=yc
c
        open (luin,file=fname,status='OLD')
  450 format(a)
        do 460 j=1,300
          read (luin,450) caract
          ki=index(caract,'PHOTON')
          if (ki.gt.0) then
            kii=index(caract,'SOURCE')
            kiii=index(caract,'FILE')
            if ((kiii.gt.kii).and.(kii.gt.ki)) goto 480
          endif
  460   continue
        write (*,470) fname
  470 format(/'STRING : " PHOTON SOURCE FILE" NOT FOUND IN FILE:',a)
        goto 30
c
  480   continue
c
c     read and display any header..
c
        read (luin,450) caract
c        write (*,*) caract
        if (caract(1:1).eq.'%') goto 480
c
c   Check for v2.0.0+ Field Verions ID (<0)
c
        read (luin,*) fv
        if (fv.ne.fieldversion) then
c
c Special case old files if old style compatibility PHOTDAT.old is used.
c
          if ((fv.eq.359).and.(fieldversion.eq.0)) then
            iinto=infph-1
            iinf=fv
            if (iinf.ne.iinto) then
              write (*,490) iinf,iinto
  490          format(/,' Mismatch number of data points (',i6,').',
     &         ' Require :',i5,' points')
              stop
            endif
            do j=1,iinto
              read (luin,*) sv
              den=cphotev(j)
              if ((den.ge.turn).and.(den.lt.cut)) then
                readflux(j)=readflux(j)+sv
              endif
            enddo
            goto 30
          else
            read (luin,*) iinto
            write (*,500) fv,fieldversion,iinto,infph
  500         format(/' WARNING: Mismatched source vector ID',i4,
     &        ' needed ',i4,/
     &        ' Rebin:',i4,' to : ',i4,' bins'/)
          endif
cc
cc ID missmatch , attempt to rebin using wev in .sou file as is
cc
          close (luin)
c
          call readrebin (fname, 5, readflux)
          goto 30
c
        else
c
c     Input matched the current field ID, assume the
c     bins are OK and ignore energies, only reading
c     fluxes.  This avoids failing to compare energies when the
c     input file may just not have enough decimals.
c
c     WARNING: All source vector with a given binning *must*
c     have a unique Field Version.
c                 Old = 0, only works with fv read as 359
c                 Std = -2
c               Short = -3
c            reserved = -4...-1024
c        free for use   -1025... -max int
c
          iinto=infph-1
          iinf=0
          read (luin,*) iinf
c
c     error
c
          if ((iinf.ne.iinto).and.(iinf.ne.infph)) then
            write (*,510) iinf,iinto,infph
  510 format(/' Invalid number of data points (',i6,').',
     &     ' Require :',i6,' or ', i6,' points')
            stop
          endif
c
c     Multiply by 4 to convert 1/4pi sr in files to
c     1/pi for Inu source field.
c
          do j=1,iinto
            read (luin,*) bv,sv
            den=cphotev(j)
            if ((den.ge.turn).and.(den.lt.cut)) then
              readflux(j)=sv*4.d0
            endif
          enddo
          close (luin)
c
        endif
c
        srcfile=fname
        goto 30
c
      else
c
  520   write (*,530)
  530    format(/,' File Not Found: Try again or cancel (a/c): ',$)
        read (*,400) ilgg
        write (*,*)
        call toup (ilgg(1:1), ilgg)
        if (ilgg.eq.'A') goto 380
        if (ilgg.eq.'C') goto 40
        goto 520
c
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     ***WRITE A SOURCE FILE OF CURRENT FIELD
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  540 continue
  550 fname=' '
      write (*,560)
  560    format(/' Enter new source file name : ',$)
      read (*,570) fname
      np=lenv(fname)
      fname=fname(1:np)
  570 format(a)
      write (*,*) fname(1:np)
      inquire (file=fname(1:np),exist=iexi)
c
      if (iexi) then
c
  580   write (*,590)
  590 format(//,
     & ' File Already Exists: Try again or cancel(a/c): ',$)
        read (*,570) ilgg
        write (*,*)
        call toup (ilgg(1:1), ilgg)
        if (ilgg.eq.'A') goto 550
        if (ilgg.eq.'C') goto 40
        goto 580
c
      else
c
c     Valid file name...
c
        write (*,600)
  600   format(/' Give code/identifier for source file (40chars): ')
        read (*,570) runname
c
        wmod='PSOU'
c
c     as Jnu = Inu*0.25
c     uses raw name - no newfil and 0000 counters.sfx
c
        call wpsou ('Source Menu', fname, np, wmod, 0.d0, 0.d0, 0.d0,
     &   1.d0, 0.25d0, souvec)
c
      endif
c  nothing to add
      goto 40
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   End of sources, tidy up vector:
c
c   ***DETERMINATION OF HIGH ENERGY CUT-OFF
c
c   untis returned in souvec/soupho is Inu 1/pi source units not
c   Jnu 1/4pi emissivity  units, invec expects Jnu hence * 0.25 below
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
  610 continue
c
c    ***FIND actual CUT-OFF FREQUENCY
c
      cut=0.0d0
      do i=infph,1,-1
        if (souvec(i).le.epsilon) then
          souvec(i)=0.d0
        else
          cut=photev(i)/iph
          goto 620
        endif
      enddo
  620 continue
c
c    ***FIND actual TURN-ON FREQUENCY
c
      turn=photev(infph)
      do i=1,infph
        if (souvec(i).le.epsilon) then
          souvec(i)=0.d0
        else
          turn=photev(i)/iph
          goto 630
        endif
      enddo
  630 continue
c
c    ***PUT PHOTON SOURCE IN VECTOR SOUPHO IN /PHOTDAT/
c    as Inu soupho
c
      do i=1,infph
        soupho(i)=souvec(i)
      enddo
c
      q1=0.0d0
      q2=0.0d0
      q3=0.0d0
      q4=0.0d0
c
      call intinu (soupho, q1, q2, q3, q4)
c
      qhi=q1
      qhei=q2
      qheii=q3
      qht=q4
c
      write (*,640)
  640 format(/' Mod',t7,'Temp.',t16,'Alpha',t22,'Turn-on',t30,'Cut-off'
     &,t38,'Zstar',t47,'FQHI',t56,'FQHeI',t66,'FQHeII')
      write (*,650) iso,teff,alnth,turn,cut,zstar,qhi,qhei,qheii
  650 format(' ',a2,1pg10.3,4(0pf7.2),1x,3(1pg10.3))
c
c     cosmic ray event rate disabled by default
c
      crate=0.d0
c
      if (expertmode.gt.1) then
c
c need upgrade
c
  660   write (*,670)
  670 format(/' Include cosmic ray heating? (Y/N): ',$)
        read (*,400) ilgg
        call toup (ilgg(1:1), ilgg)
c
        if ((ilgg.ne.'Y').and.(ilgg.ne.'N')) goto 660
c
        if (ilgg.eq.'Y') then
c
  680     write (*,690)
  690 format(/' Give event rate per second (~1e-17): ',$)
          read (*,*) crate
          if (crate.lt.0.d0) goto 680
        endif
      endif
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Simple Operations
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine zerofield (flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 flux(mxinfph)
      integer*4 idx
      do idx=1,infph
        flux(idx)=0.0d0
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine scalefield (flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 flux(mxinfph)
      real*8 scale
      integer*4 idx
      write (*,10)
   10 format(/' Give overall source scaling factor (>=0): ',$)
      read (*,*) scale
      if (scale.le.0.d0) scale=1.0d0
      do idx=1,infph
        flux(idx)=flux(idx)*scale
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine normalisefield (flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
      include 'cblocks.inc'
c
      real*8 flux(mxinfph)
      real*8 scale,q1,q2,q3,q4,blum,ilum,xlum,qall
      real*8 ts,widnu
      integer*4 idx,i
      character ilgg*4,nf*4
c
      write (*,10)
   10 format(//' Multiple Component Photoionisation Sources'/
     & '  Choose the normalisation range :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :   Photons from H  I  up (1 Ryd+, 13.6 - Inf eV)'/
     & '    B  :   Photons from H  I  (1-1.8 Ryd, 13.6 - 24.6eV)'/
     & '    C  :   Photons from He I  (1.8-4 Ryd, 24.6 - 54.4eV)'/
     & '    D  :   Photons from He II (4 Ryd +,   54.4 - Inf eV)'/
     & '    F  :   Photons over all energies, total spectrum'//
     & '    E  :   Intensity over all energies, total spectrum'/
     & '    I  :   Ionising Intensity (1 Ryd+, 13.6 - Inf eV)'/
     & '    X  :   X-ray Intensity    (100 - Inf eV)'/
     & ' :: ',$)
      read (*,'(a)') ilgg
      call toup (ilgg(1:1), ilgg)
      write (*,*)
c
      q1=0.0d0
      q2=0.0d0
      q3=0.0d0
      q4=0.0d0
c
c    assumes 1/4pi units and souvec is 1/pi plane parallel units.
c
      call intvec (flux, q1, q2, q3, q4)
c
      qhi=q1*0.25d0
      qhei=q2*0.25d0
      qheii=q3*0.25d0
      qht=q4*0.25d0
c
      blum=0.d0
      ilum=0.d0
      xlum=0.d0
      qall=0.d0
c
      do i=1,infph-1
        widnu=widbinnu(i)
        blum=blum+flux(i)*widnu
        qall=qall+flux(i)*widnu/cphote(i)
        if (photev(i).ge.iph) ilum=ilum+flux(i)*widnu
        if (photev(i).ge.100.d0) xlum=xlum+flux(i)*widnu
      enddo
c
c scale these direct integrals by pi to allow the main subroutine to
c rescale from Inu units.
c
      blum=blum*pi
      ilum=ilum*pi
      xlum=xlum*pi
      qall=qall*pi
c
      write (*,20)
   20 format(//' Multiple Component Photoionisation Sources'/
     & '  Normalise Flux to :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  : Normalise to 1.0 (photon or erg)/cm^2/s'/
     & '    B  : Normalise to U(H) = 1.0 (at 1 cm^-3)'/
     & '    C  : Normalise to BB intensity, sigma T^4',//
     & '    NOTE "A" works for photons or intensities.'/
     & '    NOTE "B" if the range is an intensity it is '/
     & '          over-ridden to "F" or "A" in photons.'/
     & '    NOTE "C" the range is always over-ridden to "E".'/
     & ' :: ',$)
      read (*,'(a)') nf
      call toup (nf(1:1), nf)
      write (*,*)
c
      scale=1.d0
      if (nf.eq.'B') then
        scale=cls
        if (ilgg.eq.'E') ilgg='F'
        if (ilgg.eq.'I') ilgg='A'
        if (ilgg.eq.'X') ilgg='F'
      endif
      if (nf.eq.'C') then
   30   format(' Give scale effective temperature (K): ',$)
        write (*,30)
        read (*,*) ts
        scale=stefan*(ts**4)
   40   format(' BB intensity:',1pg12.5,'(erg/s/cm^2)')
        write (*,40) scale
        ilgg='E'
      endif
      if (ilgg.eq.'A') scale=scale/qht
      if (ilgg.eq.'B') scale=scale/qhi
      if (ilgg.eq.'C') scale=scale/qhei
      if (ilgg.eq.'D') scale=scale/qheii
      if (ilgg.eq.'F') scale=scale/qall
      if (ilgg.eq.'E') scale=scale/blum
      if (ilgg.eq.'I') scale=scale/ilum
      if (ilgg.eq.'X') scale=scale/xlum
c
      do idx=1,infph
        flux(idx)=flux(idx)*scale
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Basic Sources
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine blackbody (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    ***STAR WITH BLACK BODY DISTRIBUTION
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 yc,etr,sv
      real*8 scale,rnuh0,rnuh,rnuh1
      integer*4 idx
      real*8 fplank
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
   10 write (*,20)
   20 format(//' Give the black body temperature : ',$)
c
      srcfile='Black Body'
c
      read (*,*) teff
      write (*,*)
      if (teff.le.10) teff=10**teff
      if (teff.lt.1.0d0) goto 10
c
c     get turn on
c
      etr=photev(1)/iph
   30 write (*,40) etr
   40 format(/' Turn-on energy (Min.:',1pg10.3,
     & ' in Ryd [13.59844eV]) : ',$)
      read (*,*) yc
      write (*,*)
      if (yc.lt.0.0d0) goto 30
      turn=yc
c
c     get turn off
c
      etr=photev(infph)/iph
      write (*,50) etr
   50 format(/' Cut-off energy (Max.:',1pg10.3,
     & ' in Ryd [13.59844eV]) : ',$)
c
      read (*,*) yc
      write (*,*)
      if (yc.lt.0.0d0) yc=0.d0
      cut=yc
c
   60 write (*,70)
   70 format(/' Give component scaling factor (>0): ',$)
      read (*,*) scale
      write (*,*)
      if (scale.le.0.d0) goto 60
c
c   integrate with Simpsons (1-4-1)/6 quadrature
c
      do idx=1,infph-1
        rnuh0=photev(idx)/iph
        rnuh=cphotev(idx)/iph
        rnuh1=photev(idx+1)/iph
        if ((rnuh1.lt.cut).and.(rnuh0.ge.turn)) then
          sv=fplank(teff,rnuh0)
          sv=sv+4.0d0*fplank(teff,rnuh)
          sv=(sv+fplank(teff,rnuh1))/6.d0
          readflux(idx)=sv*scale
        endif
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine powerlaw (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    ***NON-THERMAL SOURCE ; INTENSITY PROPORTIONAL TO NU**ALPHA
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 etr,flu,sv
      real*8 yc,ze,den,scale
      integer*4 idx
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//' Give spectral index, Alpha : ',$)
      read (*,*) alnth
c
      srcfile='Non-Thermal'
c
      write (*,20)
   20 format(/' Give zero point intensity I(E), E :'/
     & '   I(E) in Inu 1/pi units (<0 as log),'/
     & '   E in eV  (<0 as -Rydbergs)'/
     & ':::: ',$ )
      read (*,*) yc,ze
      write (*,*)
c
      if (yc.lt.0.d0) yc=10.d0**yc
      flu=yc
c
      if (ze.lt.0.d0) ze=-r_inf*ze
c
c     get turn on
c
      etr=photev(1)
   30 write (*,40) etr
   40 format(/' Turn-on energy  (Min.:',1pg10.3,' eV.) : ',$)
      read (*,*) yc
      write (*,*)
      if (yc.lt.0.0d0) goto 30
      turn=yc
c
c     get turn off
c
      etr=photev(infph)
   50 write (*,60) etr
   60 format(/' Cut-off energy (Max.:',1pg10.3,' eV.) : ',$)
c
      read (*,*) yc
      write (*,*)
      if (yc.lt.0.0d0) goto 50
      cut=yc
c
   70 write (*,80)
   80 format(/' Give component scaling factor (>0): ',$)
      read (*,*) scale
      if (scale.le.0.d0) goto 70
c
      do idx=1,infph-1
        den=cphotev(idx)
        sv=flu*((den/ze)**alnth)
        if (sv.gt.epsilon) then
          if ((den.ge.turn).and.(den.lt.cut)) then
            readflux(idx)=sv*scale
          endif
        endif
      enddo
c
      write (*,90) ze,flu
   90 format(/' @ ',1pg10.3, ' eV : Intensity :',1pg10.3)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Non Stellar Sources
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine bremss (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    ***X-Ray Thermal Bremsstrahlung ; A exp (-h nu/kT)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 den,sv,yc
      real*8 const,scale,etr,blum,inu
      integer*4 i,idx
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
      const=1.d0
c
      write (*,10)
   10 format(//' Give electron temperature'/
     & '(<=10 as log(K), <=1e5 as eV, >1e5 as K )',$)
      read (*,*) teff
c
      srcfile='Bremsstrah'
c
      if (teff.le.10.d0) then
        teff=10.d0**teff
        goto 20
      endif
c
      if (teff.le.1.d5) then
        teff=teff*(ev/rkb)
        goto 20
      endif
c
   20 write (*,30)
   30    format(/' Give total intensity, ( ergs/cm^2/s ) ',$ )
      read (*,*) yc
      if (yc.lt.0.0d0) goto 20
      inu=yc
c
c     get turn on
c
      etr=photev(1)
c
   40 write (*,50) etr
   50 format(/' Turn-on energy (Min.:',1pg10.3,' eV.) : ',$)
      read (*,*) yc
      if (yc.lt.0.0d0) goto 40
      turn=yc
c
c     get turn off
c
      etr=photev(infph)
c
   60 write (*,70) etr
   70 format(/' Cut-off energy (Max.:',1pg10.3,' eV.) : ',$)
c
      read (*,*) yc
      if (yc.lt.0.0d0) goto 60
      cut=yc
c
   80 write (*,90)
   90 format(/' Give component scaling factor (>0): ',$)
      read (*,*) scale
      write (*,*)
      if (scale.le.0.d0) goto 80
c
      blum=0.d0
      do i=1,infph-1
        den=cphotev(i)
        if (den.ge.turn) then
          if (den.lt.cut) then
            sv=const*dexp(-(den*ev)/(teff*rkb))
            if (sv.gt.epsilon) then
              blum=blum+sv*widbinnu(i)
            endif
          endif
        endif
      enddo
      blum=pi*blum
      scale=scale*inu/blum
c
      do i=1,infph-1
        readflux(i)=0.d0
        den=cphotev(i)
        sv=scale*const*dexp(-(den*ev)/(teff*rkb))
        if (den.ge.turn) then
          if (den.lt.cut) then
            if (sv.gt.epsilon) then
              readflux(i)=sv
            endif
          endif
        endif
      enddo
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine interstellar (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c      Local Interstellar Radiation Field
c           Mathis, Mezger, Panagia 1983
c
c     in photons cm-2 sr-1 eV-1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 den,sv,rnuh,scale
      integer*4 idx,i
      real*8 fplank
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
   10 write (*,20)
   20 format(/' Give component scaling factor (>0): ',$)
      read (*,*) scale
      write (*,*)
      if (scale.le.0.d0) goto 10
      i=1
      rnuh=cphotev(i)/iph
c     lambda > 0.246 mum:
      do while (rnuh.lt.0.3706314d0)
        sv=1.0d-14*fplank(7.5d3,rnuh)+1.65d-13*fplank(4.0d3,rnuh)+4.0d-
     &   13*fplank(3.0d3,rnuh)
        if (sv.gt.epsilon) then
          readflux(i)=sv
        endif
        i=i+1
        rnuh=cphotev(i)/iph
      enddo
c     den=wave in mum
      den=cls*1d4/(cphotev(i)*evplk)
c     0.246>L_mum>0.134
      do while (den.lt.0.134d0)
c      factor of den**2/cls for J_Lam to J_nu
        sv=7.115d-4*den**(0.3322d0)
        if (sv.gt.epsilon) then
          readflux(i)=sv/(cls*1d4)
        endif
        i=i+1
        den=cls*1e4/(cphotev(i)*evplk)
      enddo
      do while (den.lt.0.110d0)
        sv=2.045d-2*den**2
        if (sv.gt.epsilon) then
          readflux(i)=sv/(cls*1d4)
        endif
        i=i+1
        den=cls*1d4/(cphotev(i)*evplk)
      enddo
c     0.110>L_mum>0.0912- upto 13.6 eV
      do while (cphotev(i).lt.iph)
c       factor of den**2/cls for J_Lam to J_nu
        sv=38.57d0*den**(5.4172d0)
        if (sv.gt.epsilon) then
          readflux(i)=sv/(cls*1d4)
        endif
        i=i+1
        den=cls*1d4/(cphotev(i)*evplk)
      enddo
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c AGN Sources
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine jbhagn (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c ***AGN QUASAR SOURCE ; INTENSITY Big Blue Bump + Powerlaw and cutoffs
c
c  L = k1 e^(-alpha1) exp(-e/e1) + k2 e^(-alpha2) exp(-e/e2) H(e - e1)
c  L = k1 e^(-alpha1) exp(-e/e1) + k2 e^(-alpha2) exp(-e/e2) exp(6.0*(e - e1)/e1
c
c  H is the heavyside operator  Spectrum in photons
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 fe1, fk1, fk2, fe2, alpha1, alpha2
      real*8 sv,sv1,sv2,cutlow,yc,etr,scale,den,eta
      real*8 w1,w2,a,g1,g2,ratio,k1,k2
      integer*4 i,idx
      character inlr*4
c
      real*8 fincgamma
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  AGN SED model, Bland-Hawthorn '/
     & '   - alpha_1, BBB red side -slope, set to 2/3'/
     & '   - E_1, BBB cutoff energy ( ~30 eV)'/
     & '   - alpha_2, hard power law -slope, < 2.0, ~1.9'/
     & '   - E_2,  hard power law  cutoff energy (~1.0e5 eV)'/
     & '   - Eta: BBB/power law luminosity ratio'/
     & '   -    Eta_i = ionising luminosity ratio'/
     & '   -    Eta_1 = E_1+ luminosity ratio'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
   20 write (*,30)
   30 format(/' Give BBB component photon Alpha 1: ',/
     & ' (default 2/3, -ve of slope = +ve value): ',$ )
      read (*,*) alpha1
      write (*,*)
      write (*,40)
   40 format(' Give warm component cutoff energy, E_1,',/
     & ' (~30 eV, < 0 as log): ',$ )
      read (*,*) fe1
      write (*,*)
      write (*,50)
   50 format(/' Give power law photon Alpha 2 : ',/
     & ' (default 1.9, < 2.0, -ve of slope = +ve value): ',$ )
      read (*,*) alpha2
      write (*,*)
      write (*,60)
   60 format(' Give power law component cutoff energy, E_2,',/
     &         ,' (~ 1e5 eV, <0 as log): ',$ )
      read (*,*) fe2
      write (*,*)
c
      write (*,70)
   70 format(/' Ionising or E_1 luminosity ratio (I/E):',$ )
      read (*,*) inlr
      inlr=inlr(1:1)
      if (inlr.eq.'i') inlr='I'
      if (inlr.eq.'e') inlr='E'
      if ((inlr.ne.'E').and.(inlr.ne.'I')) inlr='I'
c
      write (*,80)
   80 format(/' Give eta, luminosity ratio:',$ )
      read (*,*) eta
      inlr=inlr(1:1)
      if (inlr.eq.'i') inlr='I'
      if (inlr.eq.'e') inlr='E'
      if ((inlr.ne.'E').and.(inlr.ne.'I')) inlr='I'
c
c compute relevant k1 and k2 for given eta and type
c
      if (inlr.eq.'I') then
c Ionising  luminosity ratio
c     eta_i
        w1=iph/fe1
      endif
      if (inlr.eq.'E') then
c E_1+ luminosity ratio
c     eta_1
        w1=1.0
      endif
c
      a=2.d0-alpha1
      g1=fincgamma(a,w1)
c
      w2=fe2/fe1
      a=2.d0-alpha2
      g2=fincgamma(a,w2)
c k1/k2
      ratio=eta*((fe2*fe2)/(fe1*fe1))*g2/g1
      k1=(eta/(1.d0+eta))*(1.d0/(fe1*fe1*g1))
      k2=k1/ratio
c
      fk1=k1*(fe1**(alpha1))
      fk2=k2*(fe2**(alpha2))
      fk1=fk1/(fk1+fk2)
      fk2=1.d0-fk1
c
      srcfile='JBH AGN'
c
   90 format(/' JBH AGN Spectrum Parameters:',/
     & '  E_1  : ',1pg12.5,' (eV)     alpha_1: ',1pg12.5,/
     & '  E_2  : ',1pg12.5,' (eV)     alpha_2: ',1pg12.5)
      write (*,90) fe1,alpha1,fe2,alpha2
      if (inlr.eq.'I') then
c Ionising  luminosity ratio
  100 format('  eta_i: ',1pg12.5)
        write (*,100) eta
      endif
      if (inlr.eq.'E') then
c E_1+ luminosity ratio
  110 format('  eta_1: ',1pg12.5)
        write (*,110) eta
      endif
c
  120 format('  Derived values:',/
     & '  k_1/k_2 : ',1pg12.5,' (log10)  ',1pg12.5,' (linear)',/
     & '       k_1: ',1pg12.5,'   k_2: ',1pg12.5,/
     & '  Normalised fractions:',/
     & '      k_1p: ',1pg12.5,'  k_2p: ',1pg12.5,/)
      write (*,120) dlog10(ratio),ratio,k1,k2,fk1,fk2
c
c     get turn on
c
      etr=photev(1)
      write (*,130) etr
  130 format(/' Turn-on energy  (Min.:',1pg10.3,' eV) : ',$)
      read (*,*) yc
      write (*,*)
      if (yc.lt.0.0d0) goto 20
      turn=yc
c
c     get turn off
c
      etr=photev(infph)
      write (*,140) etr
  140 format(' Cut-off energy (Max.:',1pg10.3,' eV) : ',$)
c
      read (*,*) yc
      write (*,*)
      if (yc.lt.0.0d0) goto 20
      cut=yc
c
      write (*,150)
  150 format(' Give component scaling factor (>0): ',$)
      read (*,*) scale
      write (*,*)
      if (scale.le.0.d0) goto 20
c
      do i=1,infph-1
        den=cphotev(i)
        cutlow=dexp(-6.d0*fe1/(6.d0*den))
        sv1=fk1*(den**(-alpha1))*dexp(-den/fe1)
        sv2=(fk2*(den**(-alpha2))*dexp(-den/fe2))*cutlow
        sv=sv1+sv2
c        convert photons to energy Inu
        sv=sv*den*ev/pi
        if (sv.gt.epsilon) then
          if ((den.ge.turn).and.(den.lt.cut)) then
            readflux(i)=readflux(i)+sv*scale
          endif
        endif
      enddo
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine componentagn (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c read AGN Model Files 2012MNRAS,425,907J
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      integer*4 idx,bmass,bheps
      character bhtype*4
      character agnfile*64
c
      logical iexi
      integer*4 l
      integer*4 lenv
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Component AGN SED models, Jin et al 2012 '/
     & '   - 14 Masses:  1e6 -  1e9'/
     & '   - 9 L/LEdd : 0.01 - 1.00'/
     & '   - BLS/NLS models rescaled from 413.5Mpc z = 0.1'/
     & '              to 1.0e16cm z = 0.0'/
     & '   - Variable Bump, Intermediate and High Energy components'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Select a Black Hole Mass (M0) [Edd. Lum. ~ 1.26e38/M0]     '/
     & '  (* indicates models also in original library)              '/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '   1: 1.0e6*   2: 2.0e6*    3: 3.0e6*   4: 4.0e6   5: 5.0e6*'/
     & '   6: 1.0e7*   7: 2.0e7*    8: 3.0e7               9: 5.0e7*'/
     & '  10: 1.0e8*  11: 2.0e8*   12: 3.0e8              13: 5.0e8*'/
     & '  14: 1.0e9* '/
     & ' :: ',$)
      read (*,*) bmass
      bmass=min(14,max(1,bmass))
c
      agnfile=''
c
      if (bmass.eq.1) agnfile='M1e6_'
      if (bmass.eq.2) agnfile='M2e6_'
      if (bmass.eq.3) agnfile='M3e6_'
      if (bmass.eq.4) agnfile='M4e6_'
      if (bmass.eq.5) agnfile='M5e6_'
      if (bmass.eq.6) agnfile='M1e7_'
      if (bmass.eq.7) agnfile='M2e7_'
      if (bmass.eq.8) agnfile='M3e7_'
      if (bmass.eq.9) agnfile='M5e7_'
      if (bmass.eq.10) agnfile='M1e8_'
      if (bmass.eq.11) agnfile='M2e8_'
      if (bmass.eq.12) agnfile='M3e8_'
      if (bmass.eq.13) agnfile='M5e8_'
      if (bmass.eq.14) agnfile='M1e9_'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write (*,20)
   20 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Choose the Accretion Efficiency L/LEdd:'/
     & '  (* indicates models also in original library)              '/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    1 :   0.01 Eddington*'/
     & '    2 :   0.02 Eddington*'/
     & '    3 :   0.03 Eddington'/
     & '    4 :   0.05 Eddington*'/
     & '    5 :   0.10 Eddington*'/
     & '    6 :   0.20 Eddington*'/
     & '    7 :   0.30 Eddington'/
     & '    8 :   0.50 Eddington*'/
     & '    9 :   1.00 Eddington*'/
     & ' :: ',$)
      read (*,*) bheps
      write (*,*)
      bheps=min(9,max(1,bheps))
c
      if (bheps.eq.1) agnfile=agnfile(1:5)//'E0.01_'
      if (bheps.eq.2) agnfile=agnfile(1:5)//'E0.02_'
      if (bheps.eq.3) agnfile=agnfile(1:5)//'E0.03_'
      if (bheps.eq.4) agnfile=agnfile(1:5)//'E0.05_'
      if (bheps.eq.5) agnfile=agnfile(1:5)//'E0.10_'
      if (bheps.eq.6) agnfile=agnfile(1:5)//'E0.20_'
      if (bheps.eq.7) agnfile=agnfile(1:5)//'E0.30_'
      if (bheps.eq.8) agnfile=agnfile(1:5)//'E0.50_'
      if (bheps.eq.9) agnfile=agnfile(1:5)//'E1.00_'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write (*,30)
   30 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Choose the Model :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    N  :   NLS, Narrow Line Seyfert Model. '/
     & '    B  :   BLS, Broad Line Seyfert Model. '/
     & ' :: ',$)
      read (*,'(a)') bhtype
      call toup (bhtype(1:1), bhtype)
      write (*,*)
c
      if ((bhtype.ne.'N').and.(bhtype.ne.'B')) then
        write (*,*) ' Unknown Model, using NLS.'
        bhtype='N'
      endif
c
      if (bhtype.eq.'N') agnfile=agnfile(1:11)//'NLS1.txt'
      if (bhtype.eq.'B') agnfile=agnfile(1:11)//'BLS1.txt'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/compSED/'//agnfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/compSED/'//agnfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/compSED/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c     format 2 = compSED File v1
c
      call readrebin (srcfile, 2, readflux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine componentagn2 (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c read AGN Model Files 2012MNRAS,425,907J
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      integer*4 idx,bmass,bheps
      character bhtype*4
      character agnfile*64
c
      logical iexi
      integer*4 l
      integer*4 lenv
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Component AGN SED 2 models, Jin et al 2012 '/
     & '   - 14 Masses:  1e6 -  1e9'/
     & '   - 9 L/LEdd : 0.01 - 1.00'/
     & '   - BLS/NLS models:'/
     & '   - Variable Bump, Intermediate and High Energy components'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Select a Black Hole Mass (M0) [Edd. Lum. ~ 1.26e38/M0]     '/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    1: 1.0e6   2: 2.0e6    3: 3.0e6    4: 4.0e6    5: 5.0e6'/
     & '    6: 1.0e7   7: 2.0e7    8: 3.0e7                9: 5.0e7'/
     & '   10: 1.0e8  11: 2.0e8   12: 3.0e8               13: 5.0e8'/
     & '   14: 1.0e9 '/
     & ' :: ',$)
      read (*,*) bmass
      bmass=min(14,max(1,bmass))
c
      agnfile=''
c
      if (bmass.eq.1) agnfile='M1e6_'
      if (bmass.eq.2) agnfile='M2e6_'
      if (bmass.eq.3) agnfile='M3e6_'
      if (bmass.eq.4) agnfile='M4e6_'
      if (bmass.eq.5) agnfile='M5e6_'
      if (bmass.eq.6) agnfile='M1e7_'
      if (bmass.eq.7) agnfile='M2e7_'
      if (bmass.eq.8) agnfile='M3e7_'
      if (bmass.eq.9) agnfile='M5e7_'
      if (bmass.eq.10) agnfile='M1e8_'
      if (bmass.eq.11) agnfile='M2e8_'
      if (bmass.eq.12) agnfile='M3e8_'
      if (bmass.eq.13) agnfile='M5e8_'
      if (bmass.eq.14) agnfile='M1e9_'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write (*,20)
   20 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Choose the Accretion Efficiency L/LEdd:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    1 :   0.01 Eddington   5 :   0.10 Eddington'/
     & '    2 :   0.02 Eddington   6 :   0.20 Eddington'/
     & '    3 :   0.03 Eddington   7 :   0.30 Eddington'/
     & '    4 :   0.05 Eddington   8 :   0.50 Eddington'/
     & '    5 :   0.10 Eddington   9 :   1.00 Eddington'/
     & ' :: ',$)
      read (*,*) bheps
      write (*,*)
      bheps=min(9,max(1,bheps))
c
      if (bheps.eq.1) agnfile=agnfile(1:5)//'E0.01_'
      if (bheps.eq.2) agnfile=agnfile(1:5)//'E0.02_'
      if (bheps.eq.3) agnfile=agnfile(1:5)//'E0.03_'
      if (bheps.eq.4) agnfile=agnfile(1:5)//'E0.05_'
      if (bheps.eq.5) agnfile=agnfile(1:5)//'E0.10_'
      if (bheps.eq.6) agnfile=agnfile(1:5)//'E0.20_'
      if (bheps.eq.7) agnfile=agnfile(1:5)//'E0.30_'
      if (bheps.eq.8) agnfile=agnfile(1:5)//'E0.50_'
      if (bheps.eq.9) agnfile=agnfile(1:5)//'E1.00_'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write (*,30)
   30 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  Choose the Model :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    N  :   NLS, Narrow Line Seyfert Model. '/
     & '    B  :   BLS, Broad Line Seyfert Model. '/
     & ' :: ',$)
      read (*,'(a)') bhtype
      call toup (bhtype(1:1), bhtype)
      write (*,*)
c
      if ((bhtype.ne.'N').and.(bhtype.ne.'B')) then
        write (*,*) ' Unknown Model, using NLS.'
        bhtype='N'
      endif
c
      if (bhtype.eq.'N') agnfile=agnfile(1:11)//'NLS1.txt'
      if (bhtype.eq.'B') agnfile=agnfile(1:11)//'BLS1.txt'
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/compSED2/'//agnfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/compSED2/'//agnfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/compSED2/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c     format 4 = compSED2 File v2
c
      call readrebin (srcfile, 4, readflux)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine doneagn (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Full Done etal 2012 Mon. Not. R. Astron. Soc. 420, 1848–1860 (2012)
c OPTXAGNF model from XSPEC 12, transplanted to MAPPINGS!
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 param(12)
c
c     Input paramters:
c
c     param(1) BH mass in solar
c     param(2) distance, default 1.5e18 cm, in cm not Mpc!
c     param(3) log mass accretion rate in L/LEdd
c     param(4) black hole astar rotation : usually 0.0
c     param(5) rcorona/rg
c     param(6) log10 rout/rg
c     param(7) opt thick kte  keV
c     param(8) opt thick tau  0-20+
c     param(9) power law gamma
c     param(10) frac of coronal power in power law.
c     11,12 unused atm, 11 used to be redshift
c
      real*8 bhmass
      real*8 distcm
      real*8 lonledd
      real*8 bhastar
      real*8 rc,router
      real*8 comptte, compttau
      real*8 nonthgamma, nonthfrac
c
      integer*4 idx
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '  OPTXAGNF AGN SED, Done et al 2012 '/
     & '   - Variable Bump, Intermediate and High Energy components'/
     & '   - Scaled to Distance = 1.5e18 cm'/
     & '   NOTE: OPTXAGNF may produce luminosity outside the ',/
     & '   MAPPINGS PHOTDAT range, so the integrated total ',/
     & '   may miss a fraction of the expected ',/
     & '   luminosity, depending on.the value of gamma.',/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::')
c
   20 format('  Black hole mass  (Solar masses, <= 10.0 as log): ',$)
      write (*,20)
      read (*,*) bhmass
      if (bhmass.le.10.d0) bhmass=10.d0**bhmass
      param(1)=bhmass
      write (*,*)
c
c     cm,1e4rgat10^9
      distcm=1.5d18
c  125 format('  Source distance                            (cm): ',$)
c      write(*,125)
c      read (*,*) distcm
c      if (distcm.le.0.d0) distcm=1.5d18
c in cm not mpc unlike normal optxagnf
      param(2)=distcm
c
   30 format('  Luminosity Fraction     (L/LEdd, <= 0.0 as log): ',$)
      write (*,30)
      read (*,*) lonledd
c actually optxagnf takes lonledd always a log10.  Quite inconsistent.
      if (lonledd.gt.0.d0) lonledd=dlog10(lonledd)
      param(3)=lonledd
      write (*,*)
c
      bhastar=0.d0
c       = 0-M where M(G=c=1) = GM/c^2 = Rg = 1/2 Rs
c  140 format('  Black hole rotation parameter(A* = 0.0 default): ',$)
c      write(*,140)
c      read (*,*) bhastar
c      if (bhastar.lt.0.d0) bhastar=0.d0
      param(4)=bhastar
c
   40 format('  Corona Radius Rc (units Rg, GM/c^2 grav. radii)',/
     & '      ( > 6.0 Rg, 6-100 Rg, NLS: 40.0 BLS: 60.0): ',$)
      write (*,40)
      read (*,*) rc
      if (rc.lt.6.d0) rc=6.d0
      param(5)=rc
      write (*,*)
c
   50 format('  Outer Radius Ro (units Rg, gravitational radii)',/
     & '                          (log10 Rg, NLS/BLS 4.0): ',$)
      write (*,50)
      read (*,*) router
      if (router.gt.10.d0) router=dlog10(router)
      param(6)=router
      write (*,*)
c
   60 format('  Compton gas temperature keV       (default 0.2): ',$)
      write (*,60)
      read (*,*) comptte
      if (comptte.lt.0.d0) comptte=0.0d0
      param(7)=comptte
      write (*,*)
c
   70 format('  Compton Optical Depth    (default 15.0, >= 0.0): ',$)
      write (*,70)
      read (*,*) compttau
      if (compttau.lt.0.d0) compttau=0.0d0
      param(8)=compttau
      write (*,*)
c
   80 format('  Nonthermal power law Gamma:',/
     & '     (-ve photon slope, JBH 1.9 NLS 2.2 BLS 1.8 ): ',$)
      write (*,80)
      read (*,*) nonthgamma
      if (nonthgamma.lt.0.d0) nonthgamma=0.0d0
      param(9)=nonthgamma
      write (*,*)
c
   90 format('  Nonthermal power law corona fraction, Fpl:',/
     & '                       ( 0 -- 1, NLS 0.2 BLS 0.4): ',$)
      write (*,90)
      read (*,*) nonthfrac
      if (nonthfrac.lt.0.d0) nonthfrac=0.0d0
      param(10)=nonthfrac
c
      param(11)=0.d0
      param(12)=0.d0
c
      srcfile='OPTXAGNF'
c
      call optxagnf (param, readflux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Stellar Sources
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine stellar (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    ***STELLAR ATMOSPHERE MODELS
c    HUMMER,D.G.,MIHALAS,D.M.(1970) SHIELDS,G.A.,SEARLE,L., (1978)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 xx(5), yy(5), al(5), cc(5)
      real*8 del,dt0,dt1,dtot,etr,den,tm1,pt0,gr,scale,sv
      real*8 rnuh,tnu,yc,zmod
      integer*4 i,j,jg,jmax,n,n1,idx
      character kstr*4
c
      real*8 fplank
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
      do i=1,5
        xx(i)=0.d0
        yy(i)=0.d0
        al(i)=0.d0
        cc(i)=0.d0
      enddo
      pt0=0.d0
c
   10 write (*,20)
   20 format(//' Give effective temperature : (26000<Teff<56000) : ',$)
      read (*,*) teff
c
      if ((teff.lt.2.6d4).or.(teff.gt.5.6d4)) goto 10
c
   30 write (*,40) zgas
   40 format(/' Give the metalicity of the star ',
     &     /'(Zgas =',1pg10.3,'Zsun)   Zstar : ',$ )
c
      read (*,*) zstar
c
      if ((zstar.lt.0.d0).or.(zstar.gt.1.d1)) goto 30
      zmod=zstar/0.3216d0
c
c    ***CALCULATES RATIOS OF TEMPERATURE (AT THE EDGES)
c       TO EFFECTIVE TEMPERATURE
c
      gr=4.0d0
      kstr='TNO4'
      if (gr.eq.5.d0) kstr='TNO5'
c
      do i=1,16
        call fpol (kstr, tm1, i)
        tedge(i,1)=tno4(i,1)
        tedge(i,2)=tno4(i,2)
        tedge(i,3)=tm1
      enddo
c
      kstr='TMET'
c
      i=1
      call fpol (kstr, pt0, i)
      do i=2,8
c
        j=idint(tmet(i,1))
c
        dt1=tedge(j,3)-pt0
c
        if (dt1.lt.1.0d-17) dt1=1.d-17
c
        call fpol (kstr, del, i)
        if (del.lt.0.0d0) del=0.0d0
        dt0=dt1+del
        dtot=dt0*((1.d0+((((dt0/dt1)**2)-1.d0)*zmod))**(-0.5d0))
        tedge(j,3)=pt0+dtot
c
      enddo
c
c     get turn on!
c
      etr=photev(1)/iph
   50 write (*,60) etr
   60 format(/' Give the turn-on energy  (Min.:',f6.2,' Ryd.) : ',$)
      read (*,*) yc
      if (yc.lt.0.0d0) goto 50
      turn=yc
c
c     get turn off!
c
      etr=photev(infph)/iph
   70 write (*,80) etr
   80 format(/' Give high energy cut-off (Max.:',f6.2,'Ryd.) : ',$)
c
      read (*,*) yc
      if (yc.lt.0.0d0) goto 70
      cut=yc
c
c
   90 write (*,100)
  100 format(/' Give component scaling factor (>0): ',$)
      read (*,*) scale
      if (scale.le.0.d0) goto 90
c
c    ***INTERPOLATES BETWEEN EDGES TO GET TNU
c
      j=1
      jmax=16
      jg=0
c
      do i=1,infph-1
        den=cphotev(i)
        rnuh=den/iph
c
  110   if (tedge(j+1,2).lt.den) j=j+1
        if (j.gt.jmax-1) goto 130
        if (tedge(j+1,2).lt.den) goto 110
        if (jg.eq.j) goto 120
c
        do n=1,2
          n1=(j+n)-1
          xx(n)=dlog(tedge(n1,2))
          yy(n)=dlog(tedge(n1,3))
        enddo
c
        al(1)=(yy(2)-yy(1))/(xx(2)-xx(1))
        cc(1)=((yy(1)*xx(2))-(yy(2)*xx(1)))/(xx(2)-xx(1))
        jg=j
c
  120   tnu=teff*dexp(cc(1)+(al(1)*dlog(den)))
        sv=fplank(tnu,rnuh)
c
        if ((rnuh.ge.turn).and.(rnuh.lt.cut)) then
          readflux(i)=sv*scale
        endif
c
      enddo
c
  130 continue
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine atlas (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***ATLAS9 STELLAR ATMOSPHERE MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 flux0(mxinfph)
      real*8 flux1(mxinfph)
      real*8 xt0,xt1
      integer*4 iabn,ig,iteff,iteff0,iteff1
      integer*4 idx
      character feh*4, logg*4, pat*4
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//
     & '  ATLAS9 ODFNEW Atmosphere Grid:'/
     & '       - Log(g) = 4.0, 4.5, 5.0'/
     & '       - Solar and Alpha Enhanced (+0.4) Ratios'/
     & '       - [Fe/H] = -4.0(a) ; -2.5 ... +0.3 (all)'/
     & '       - Teff   = 30kK ... 50kK'/
     & ' :::::::::::::::::::::::::::::::::::::::s:::::::::::::::::::'//
     & '  Choose the abundance pattern :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :   Standard Solar Ratios'/
     & '    B  :   Alpha Elements Enhanced (a)'/
     & ' :: ',$)
      read (*,'(a)') pat
      pat=pat(1:1)
      write (*,*)
c
      if (pat.eq.'a') pat='A'
      if (pat.eq.'b') pat='B'
      if ((pat.ne.'A').and.(pat.ne.'B')) then
        write (*,*) 'Unknown abundance pattern, using solar pattern.'
        pat='A'
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (pat.eq.'A') then
c
c   Standard Solar Ratios
c
        write (*,20)
   20 format(//' Solar Composition: Choose [Fe/H]:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  [Fe/H] = +0.5    B  :  [Fe/H] = +0.2'/
     & '    C  :  [Fe/H] = +0.0    (Solar)'/
     & '    D  :  [Fe/H] = -0.5    E  :  [Fe/H] = -1.0'/
     & '    F  :  [Fe/H] = -1.5    G  :  [Fe/H] = -2.0'/
     & '    H  :  [Fe/H] = -2.5'/
     & ' :: ',$)
c
        read (*,'(a)') feh
        feh=feh(1:1)
        write (*,*)
c
        if (feh.eq.'a') feh='A'
        if (feh.eq.'b') feh='B'
        if (feh.eq.'c') feh='C'
        if (feh.eq.'d') feh='D'
        if (feh.eq.'e') feh='E'
        if (feh.eq.'f') feh='F'
        if (feh.eq.'g') feh='G'
        if (feh.eq.'h') feh='H'
c
        if ((feh.ne.'A').and.(feh.ne.'B').and.(feh.ne.'C').and.(feh.ne.'
     &D').and.(feh.ne.'E').and.(feh.ne.'F').and.(feh.ne.'G')
     &   .and.(feh.ne.'H')) then
          write (*,*) 'Unknown [Fe/H], using solar [Fe/H].'
          feh='C'
        endif
c
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (pat.eq.'B') then
c
c   Alpha Enhanced  Ratios
c
        write (*,30)
   30 format(//' Alpha Enhanced: Choose [Fe/H]:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  [Fe/H] = +0.5    B  :  [Fe/H] = +0.2'/
     & '    C  :  [Fe/H] = +0.0    (Solar)'/
     & '    D  :  [Fe/H] = -0.5    E  :  [Fe/H] = -1.0'/
     & '    F  :  [Fe/H] = -1.5    G  :  [Fe/H] = -2.0'/
     & '    H  :  [Fe/H] = -2.5    I  :  [Fe/H] = -4.0'/
     & ' :: ',$)
        read (*,'(a)') feh
        feh=feh(1:1)
        write (*,*)
        if (feh.eq.'a') feh='A'
        if (feh.eq.'b') feh='B'
        if (feh.eq.'c') feh='C'
        if (feh.eq.'d') feh='D'
        if (feh.eq.'e') feh='E'
        if (feh.eq.'f') feh='F'
        if (feh.eq.'g') feh='G'
        if (feh.eq.'h') feh='H'
        if (feh.eq.'i') feh='I'
        if ((feh.ne.'A').and.(feh.ne.'B').and.(feh.ne.'C').and.(feh.ne.'
     &D').and.(feh.ne.'E').and.(feh.ne.'F').and.(feh.ne.'G')
     &   .and.(feh.ne.'H').and.(feh.ne.'I')) feh='C'
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      iabn=0
      if (feh.eq.'A') iabn=+5
      if (feh.eq.'B') iabn=+2
      if (feh.eq.'C') iabn=+0
      if (feh.eq.'D') iabn=-5
      if (feh.eq.'E') iabn=-10
      if (feh.eq.'F') iabn=-15
      if (feh.eq.'G') iabn=-20
      if (feh.eq.'H') iabn=-25
      if (feh.eq.'I') iabn=-40
c
      write (*,40)
   40 format(//' Choose Log(g) (not all Teff avail for all Log(g)):'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  Log(g) = 4.0'/
     & '    B  :  Log(g) = 4.5'/
     & '    C  :  Log(g) = 5.0'/
     & ' :: ',$)
      read (*,'(a)') logg
      logg=logg(1:1)
      write (*,*)
      if (logg.eq.'a') logg='A'
      if (logg.eq.'b') logg='B'
      if (logg.eq.'c') logg='C'
      if ((logg.ne.'A').and.(logg.ne.'B').and.(logg.ne.'C')) logg='C'
c
      ig=45
      iteff=40
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'A') then
        write (*,50)
c
   50 format(//' Logg = 4.0, Choose Teff: 30-39 kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 1000K will read direct from grid files    :'/
     & ' : non-multiples of 1000K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.3.0d4) teff=3.0d4
        if (teff.gt.3.9d4) teff=3.9d4
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.001d0)
        iteff0=iteff
        if (iteff0.eq.39) iteff0=38
        ig=40
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'B') then
        write (*,60)
   60 format(//' Logg = 4.5, Choose Teff: 30-49 kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 1000K will read direct from grid files    :'/
     & ' : non-multiples of 1000K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.3.0d4) teff=3.0d4
        if (teff.gt.4.9d4) teff=4.9d4
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.001d0)
        iteff0=iteff
        if (iteff0.eq.49) iteff0=48
        ig=45
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'C') then
        write (*,70)
   70 format(//' Logg = 5.0, Choose Teff: 30-50 kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 1000K will read direct from grid files    :'/
     & ' : non-multiples of 1000K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.3.0d4) teff=3.0d4
        if (teff.gt.5.0d4) teff=5.0d4
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.001d0)
        iteff0=iteff
        if (iteff0.eq.50) iteff0=49
        ig=50
      endif
      iteff1=iteff0+1
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      xt0=1.0d3*iteff0
      xt1=1.0d3*iteff1
      if (dabs(xt0-teff).lt.1.d0) then
        call readatlasmodel (pat, iabn, iteff0, ig, readflux)
      elseif (dabs(xt1-teff).lt.1.d0) then
        call readatlasmodel (pat, iabn, iteff1, ig, readflux)
      else
        call readatlasmodel (pat, iabn, iteff0, ig, flux0)
        call readatlasmodel (pat, iabn, iteff1, ig, flux1)
        call intpstellartemp (xt0, xt1, teff, flux0, flux1, readflux)
      endif
c
c Check normalisation
c
      call renormestellar (teff, readflux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine tlusty (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***TLUSTY STELLAR ATMOSPHERE MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 flux0(mxinfph)
      real*8 flux1(mxinfph)
      real*8 xt0,xt1
      integer*4 iabn,ig,iteff,iteff0,iteff1
      integer*4 idx
      character feh*4, logg*4
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//
     & '  TLUSTY Ostar Atmosphere Grid:'/
     & '      - Log(g) = 3.00,3.25,3.50,3.75,4.00,4.25,4.50,4.75'/
     & '      - [Fe/H] = -3.0,-2.0,-1.7,-1.5,-1.0,-0.7,-0.3,0.0m+0.3'/
     & '      - Teff   = 27.5kK ... 55kK'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   Standard Solar Ratios
c
      write (*,20)
   20 format(//' Choose Abundance grid [Fe/H]:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  [Fe/H] = +0.3    B  :  [Fe/H] = +0.0 (Solar)'/
     & '    C  :  [Fe/H] = -0.3    D  :  [Fe/H] = -0.7'/
     & '    E  :  [Fe/H] = -1.0    F  :  [Fe/H] = -1.5'/
     & '    G  :  [Fe/H] = -1.7'/
     & '    H  :  [Fe/H] = -2.0    I  :  [Fe/H] = -3.0'/
     & ' :: ',$)
c
      read (*,'(a)') feh
      feh=feh(1:1)
      write (*,*)
c
      if (feh.eq.'a') feh='A'
      if (feh.eq.'b') feh='B'
      if (feh.eq.'c') feh='C'
      if (feh.eq.'d') feh='D'
      if (feh.eq.'e') feh='E'
      if (feh.eq.'f') feh='F'
      if (feh.eq.'g') feh='G'
      if (feh.eq.'h') feh='H'
      if (feh.eq.'i') feh='I'
c
      if ((feh.ne.'A').and.(feh.ne.'B').and.(feh.ne.'C').and.(feh.ne.'D'
     &).and.(feh.ne.'E').and.(feh.ne.'F').and.(feh.ne.'G').and.(feh.ne.'
     &H').and.(feh.ne.'I')) then
        write (*,*) 'Unknown [Fe/H], using solar [Fe/H].'
        feh='B'
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      iabn=0
      if (feh.eq.'A') iabn=+3
      if (feh.eq.'B') iabn=+0
      if (feh.eq.'C') iabn=-3
      if (feh.eq.'D') iabn=-7
      if (feh.eq.'E') iabn=-10
      if (feh.eq.'F') iabn=-15
      if (feh.eq.'G') iabn=-17
      if (feh.eq.'H') iabn=-20
      if (feh.eq.'I') iabn=-30
c
      write (*,30)
   30 format(//' Choose Log(g) (not all Teff avail for all Log(g)):'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  Log(g) = 3.00, Teff 27.5-30.0kK'/
     & '    B  :  Log(g) = 3.25, Teff 27.5-35.0kK'/
     & '    C  :  Log(g) = 3.50, Teff 27.5-40.0kK'/
     & '    D  :  Log(g) = 3.75, Teff 27.5-47.5kK'/
     & '    E  :  Log(g) = 4.00, Teff 27.5-55.0kK'/
     & '    F  :  Log(g) = 4.25, Teff 27.5-55.0kK'/
     & '    G  :  Log(g) = 4.50, Teff 27.5-55.0kK'/
     & '    H  :  Log(g) = 4.75, Teff 27.5-55.0kK'/
     & ' :: ',$)
      read (*,'(a)') logg
      logg=logg(1:1)
      write (*,*)
      if (logg.eq.'a') logg='A'
      if (logg.eq.'b') logg='B'
      if (logg.eq.'c') logg='C'
      if (logg.eq.'d') logg='D'
      if (logg.eq.'e') logg='E'
      if (logg.eq.'f') logg='F'
      if (logg.eq.'g') logg='G'
      if (logg.eq.'h') logg='H'
c
      if ((logg.ne.'A').and.(logg.ne.'B').and.(logg.ne.'C')
     &.and.(logg.ne.'D').and.(logg.ne.'E').and.(logg.ne.'F')
     &.and.(logg.ne.'G').and.(logg.ne.'H')) then
        write (*,*) 'Unknown Log(g), Log(g) = 4.0.'
        logg='E'
      endif
c
      ig=400
      iteff=400
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'A') then
        write (*,40)
   40 format(//' Logg = 3.0, Choose Teff: 27.5-30.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K           :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.30.0d3) teff=30.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0004d0)
        iteff=iteff*25
        iteff0=275
        ig=300
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'B') then
        write (*,50)
   50 format(//' Logg = 3.25, Choose Teff 27.5-35.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.35.0d3) teff=35.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0004d0)
        iteff=iteff*25
        iteff0=iteff
        if (iteff0.eq.350) iteff0=325
        ig=325
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'C') then
        write (*,60)
   60 format(//' Logg = 3.50, Choose Teff: 27.5-40.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.40.0d3) teff=40.0d3
        iteff=idint(teff*0.0004d0)
        iteff=iteff*25
        iteff0=iteff
        if (iteff0.eq.400) iteff0=375
        ig=350
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'D') then
        write (*,70)
   70 format(//' Logg = 3.75, Choose Teff: 27.5-47.5kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K           :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.47.5d4) teff=47.5d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0004d0)
        iteff=iteff*25
        iteff0=iteff
        if (iteff0.eq.475) iteff0=450
        ig=375
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'E') then
        write (*,80)
   80 format(//' Logg = 4.00, Choose Teff: 27.5-55.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.55.0d3) teff=55.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0004d0)
        iteff=iteff*25
        iteff0=iteff
        if (iteff0.eq.550) iteff0=525
        ig=400
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'F') then
        write (*,90)
   90 format(//' Logg = 4.25, Choose Teff: 27.5-55.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated using      :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.55.0d3) teff=55.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0004d0)
        iteff=iteff*25
        iteff0=iteff
        if (iteff0.eq.550) iteff0=525
        ig=425
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'G') then
        write (*,100)
  100 format(//' Logg = 4.50, Choose Teff: 27.5-55.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.55.0d3) teff=55.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0004d0)
        iteff=iteff*25
        iteff0=iteff
        if (iteff0.eq.550) iteff0=525
        ig=450
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'H') then
        write (*,110)
  110 format(//' Logg = 4.75, Choose Teff: 27.5-55.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated using      :'/
     & ' : conservative optimal quartic weighting ( err(I) << 1%) :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.55.0d3) teff=55.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0004d0)
        iteff=iteff*25
        iteff0=iteff
        if (iteff0.eq.550) iteff0=525
        ig=475
      endif
      iteff1=iteff0+25
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      xt0=1.0d2*iteff0
      xt1=1.0d2*iteff1
      if (dabs(xt0-teff).lt.1.d0) then
        call readtlustymodel (iteff0, iabn, ig, readflux)
      elseif (dabs(xt1-teff).lt.1.d0) then
        call readtlustymodel (iteff1, iabn, ig, readflux)
      else
        call readtlustymodel (iteff0, iabn, ig, flux0)
        call readtlustymodel (iteff1, iabn, ig, flux1)
        call intpstellartemp (xt0, xt1, teff, flux0, flux1, readflux)
      endif
c
c Check normalisation
c
      call renormestellar (teff, readflux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wmbasic (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***WMBASIC Moont, Westmoquette 2004 STELLAR ATMOSPHERE MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 flux0(mxinfph)
      real*8 flux1(mxinfph)
       real*8 xt0,xt1
       integer*4 iteff0,iteff1
      integer*4 iabn,ig,iteff
      integer*4 idx
      character feh*4, logg*4, testar*4
c
      do idx=1,infph
        readflux(idx)=0.d0
        flux0(idx)=0.d0
        flux1(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//
     & '  WMBASIC Ostar Atmosphere Grid:'/
     & '  Moont, Westmoquette 2004 (Pauldrach 2003) after SNC 2002'/
     & '      - Dwarf/Sub-Giant sequence'/
     & '      - [Fe/H] = -1.3,-0.7,-0.4,0.0,0.3'/
     & '      - Teffs   = 25.0kK ... 51kK'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   Standard Solar Ratios
c
      write (*,20)
   20 format(//' Choose Abundance grid [Fe/H]:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  [Fe/H] = +0.3',/
     & '    B  :  [Fe/H] = +0.0 (Solar)'/
     & '    C  :  [Fe/H] = -0.4',/
     & '    D  :  [Fe/H] = -0.7'/
     & '    E  :  [Fe/H] = -1.3'/
     & ' :: ',$)
c
      read (*,'(a)') feh
      feh=feh(1:1)
      write (*,*)
c
      if (feh.eq.'a') feh='A'
      if (feh.eq.'b') feh='B'
      if (feh.eq.'c') feh='C'
      if (feh.eq.'d') feh='D'
      if (feh.eq.'e') feh='E'
c
      if ((feh.ne.'A').and.(feh.ne.'B').and.(feh.ne.'C').and.(feh.ne.'D'
     &).and.(feh.ne.'E')) then
        write (*,*) 'Unknown [Fe/H], using solar [Fe/H].'
        feh='B'
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      iabn=0
      if (feh.eq.'A') iabn=+3
      if (feh.eq.'B') iabn=+0
      if (feh.eq.'C') iabn=-4
      if (feh.eq.'D') iabn=-7
      if (feh.eq.'E') iabn=-13
c
      write (*,30)
   30 format(//' Choose Sequence:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    D  :    Dwarf     : Logg 4.0     Teff 25.0-50.0kK'/
     & '    G  :    SubGiant  : Logg 3.0-3.9 Teff 25.0-51.4kK'/
     & ' :: ',$)
      read (*,'(a)') logg
      logg=logg(1:1)
      write (*,*)
      if (logg.eq.'d') logg='D'
      if (logg.eq.'g') logg='G'
c
      if ((logg.ne.'D').and.(logg.ne.'G')) then
        write (*,*) 'Unknown Sequence, using Dwarf models'
        logg='D'
      endif
c
      ig=400
      iteff=400
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'D') then
        write (*,40)
   40 format(//' Dwarf Sequence Logg = 4.00,  Teff: 25-50.0kK     :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : Exact values: 25,26.3,28.1,30.2,32.3,34.6,37.2,40.0kK, :'/
     & ' : 42.6,45.7,50.0kK will read direct from grid files.     :'/
     & ' : others will be interpolated using conservative optimal :'/
     & ' : quartic weighting ( err(I) << 1%)                      :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.25.0d3) teff=25.0d3
        if (teff.gt.50.0d3) teff=50.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.01d0)
        iteff0=iteff
        if (iteff0.ge.500) then
          iteff1=iteff0
        elseif (iteff0.le.250) then
          iteff1=iteff0
        elseif (iteff.le.263) then
          iteff0=250
          iteff1=263
        elseif (iteff.le.281) then
          iteff0=263
          iteff1=281
        elseif (iteff.le.302) then
          iteff0=281
          iteff1=302
        elseif (iteff.le.323) then
          iteff0=302
          iteff1=323
        elseif (iteff.le.346) then
          iteff0=323
          iteff1=346
        elseif (iteff.le.372) then
          iteff0=346
          iteff1=372
        elseif (iteff.le.400) then
          iteff0=372
          iteff1=400
        elseif (iteff.le.426) then
          iteff0=400
          iteff1=426
        elseif (iteff.le.457) then
          iteff0=426
          iteff1=457
        elseif (iteff.lt.500) then
          iteff0=457
          iteff1=500
        endif
        ig=40
        write (*,*) iteff0,iteff1,teff
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (logg.eq.'G') then
        write (*,50)
   50 format(//' Subgiant Sequence, Choose Fixed Teff: 25-51.4kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :   Teff 25.0kK  Logg = 3.0'/
     & '    B  :   Teff 26.3kK  Logg = 3.0'/
     & '    C  :   Teff 28.1kK  Logg = 3.1'/
     & '    D  :   Teff 30.2kK  Logg = 3.1'/
     & '    E  :   Teff 32.3kK  Logg = 3.2'/
     & '    F  :   Teff 34.6kK  Logg = 3.3'/
     & '    G  :   Teff 37.2kK  Logg = 3.4'/
     & '    H  :   Teff 40.0kK  Logg = 3.5'/
     & '    I  :   Teff 42.6kK  Logg = 3.7'/
     & '    J  :   Teff 45.7kK  Logg = 3.7'/
     & '    K  :   Teff 51.4kK  Logg = 3.9'/
     & ' :: ',$)
        read (*,*) testar
        call toup (testar(1:1), testar)
        write (*,*)
c
        iteff=400
        ig=35
c
        if (testar.eq.'A') then
          iteff=250
          iteff0=250
          iteff1=250
          ig=30
        endif
        if (testar.eq.'B') then
          iteff=263
          iteff0=250
          iteff1=250
          ig=30
        endif
        if (testar.eq.'C') then
          iteff=281
          iteff0=281
          iteff1=281
          ig=31
        endif
        if (testar.eq.'D') then
          iteff=302
          iteff0=302
          iteff1=302
          ig=31
        endif
        if (testar.eq.'E') then
          iteff=323
          iteff0=323
          iteff1=323
          ig=32
        endif
        if (testar.eq.'F') then
          iteff=346
          iteff0=346
          iteff1=346
          ig=33
        endif
        if (testar.eq.'G') then
          iteff=372
          iteff0=372
          iteff1=372
          ig=34
        endif
        if (testar.eq.'H') then
          iteff=400
          iteff0=400
          iteff1=400
          ig=35
        endif
        if (testar.eq.'I') then
          iteff=426
          iteff0=426
          iteff1=426
          ig=37
        endif
        if (testar.eq.'J') then
          iteff=457
          iteff0=457
          iteff1=457
          ig=37
        endif
        if (testar.eq.'K') then
          iteff=500
          iteff0=500
          iteff1=500
          ig=39
        endif
c
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      xt0=1.0d2*iteff0
      xt1=1.0d2*iteff1
c     write (*,*) 'Teff:',xt0,xt1,teff
c     write (*,*) 'Logg:',0.1d0*ig
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (dabs(xt0-teff).lt.1.d0) then
        call readwmbasicmodel (iteff0, iabn, ig, readflux)
      elseif (dabs(xt1-teff).lt.1.d0) then
        call readwmbasicmodel (iteff1, iabn, ig, readflux)
      else
        call readwmbasicmodel (iteff0, iabn, ig, flux0)
        call readwmbasicmodel (iteff1, iabn, ig, flux1)
        call intpstellartemp (xt0, xt1, teff, flux0, flux1, readflux)
      endif
c
c Check normalisation
c
      call renormestellar (teff, readflux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine cmfgenostars (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***CMFGEN Ostar Grid Atmosphere MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 flux0(mxinfph)
      real*8 flux1(mxinfph)
      real*8 xt0,xt1
      integer*4 iabn,ig,iteff,iteff0,iteff1,idx
      character logg*4
c
      do idx=1,infph
        readflux(idx)=0.d0
        flux0(idx)=0.d0
        flux1(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//
     & '  CMFGEN General Solar Ostar Atmosphere Grid:'/
     & '      - Teff   = 27.5kK ... 48.5kK'/
     & '      - Log(g) = 3.0 - 4.25 '/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      iabn=0
      ig=400
      iteff=400
      teff=40.0d3
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (*,20)
   20 format(//' Choose Log(g):'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  Log(g) = 3.00; Teff 27.5-30.0kK'/
     & '    B  :  Log(g) = 3.25; Teff 27.5-35.0kK'/
     & '    C  :  Log(g) = 3.50; Teff 27.5-40.0kK'/
     & '    D  :  Log(g) = 3.75; Teff 27.5-42.5kK'/
     & '    E  :  Log(g) = 4.00; Teff 30.0-48.5kK'/
     & '    F  :  Log(g) = 4.25; Teff 30.0-35.0kK'/
     & ' :: ',$)
      read (*,'(a)') logg
      logg=logg(1:1)
      write (*,*)
      if (logg.eq.'a') logg='A'
      if (logg.eq.'b') logg='B'
      if (logg.eq.'c') logg='C'
      if (logg.eq.'d') logg='D'
      if (logg.eq.'e') logg='E'
      if (logg.eq.'f') logg='F'
c
      if ((logg.ne.'A').and.(logg.ne.'B').and.(logg.ne.'C')
     &.and.(logg.ne.'D').and.(logg.ne.'E').and.(logg.ne.'F')) then
        write (*,*) 'Unknown Log(g), Log(g) = 4.00'
        logg='E'
      endif
c
      ig=400
c
      if (logg.eq.'A') then
        ig=300
        write (*,30)
   30 format(//' Logg = 3.00; Choose Teff: 27.5-30.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K           :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.30.0d3) teff=30.0d3
        iteff0=275
        iteff1=300
      endif
c
      if (logg.eq.'B') then
        ig=325
        write (*,40)
   40 format(//' Logg = 3.25; Choose Teff: 27.5-35.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K           :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.35.0d3) teff=35.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff0=275
        iteff1=300
        if (teff.lt.30.0d3) then
          iteff0=275
          iteff1=300
        elseif (teff.lt.32.0d3) then
          iteff0=300
          iteff1=320
        elseif (teff.le.35.0d3) then
          iteff0=320
          iteff1=350
        endif
      endif
c
      if (logg.eq.'C') then
        ig=350
        write (*,50)
   50 format(//' Logg = 3.50; Choose Teff: 27.5-40.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.40.0d3) teff=40.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff0=275
        iteff1=325
        if (teff.lt.32.5d3) then
          iteff0=275
          iteff1=325
        elseif (teff.lt.35.0d3) then
          iteff0=325
          iteff1=350
        elseif (teff.lt.37.5d3) then
          iteff0=350
          iteff1=375
        elseif (teff.le.40.0d3) then
          iteff0=375
          iteff1=400
        endif
      endif
c
      if (logg.eq.'D') then
        ig=375
        write (*,60)
   60 format(//' Logg = 3.75; Choose Teff: 27.5-42.5kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.27.5d3) teff=27.5d3
        if (teff.gt.40.0d3) teff=40.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff0=275
        iteff1=375
        if (teff.lt.37.5d3) then
          iteff0=275
          iteff1=375
        elseif (teff.le.42.5d3) then
          iteff0=375
          iteff1=425
        endif
      endif
c
      if (logg.eq.'E') then
        ig=400
        write (*,70)
   70 format(//' Logg = 4.00; Choose Teff: 30.0-48.5kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.30.0d3) teff=30.0d3
        if (teff.gt.48.5d3) teff=48.5d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff0=300
        iteff1=325
        if (teff.lt.32.5d3) then
          iteff0=300
          iteff1=325
        elseif (teff.lt.35.0d3) then
          iteff0=325
          iteff1=350
        elseif (teff.lt.40.0d3) then
          iteff0=350
          iteff1=400
        elseif (teff.lt.42.5d3) then
          iteff0=400
          iteff1=425
        elseif (teff.le.48.5d3) then
          iteff0=425
          iteff1=485
        endif
      endif
c
      if (logg.eq.'F') then
        ig=425
        write (*,80)
   80 format(//' Logg = 4.25; Choose Teff: 30.0-35.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.30.0d3) teff=30.0d3
        if (teff.gt.35.0d3) teff=35.0d3
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff0=300
        iteff1=325
        if (teff.lt.32.5d3) then
          iteff0=300
          iteff1=325
        elseif (teff.lt.35.0d3) then
          iteff0=325
          iteff1=350
        endif
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write (*,90)
   90 format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : exact Teff matches will read direct from grid files    :'/
     & ' : other Teffs will interpolated using                    :'/
     & ' : conservative optimal quartic weighting                 :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
      write (*,*) 'Teff:',iteff0,iteff1,teff
      write (*,*) 'Logg:',ig
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      xt0=1.0d2*iteff0
      xt1=1.0d2*iteff1
      if (dabs(xt0-teff).lt.1.d0) then
        call readcmfgenmodel (iteff0, ig, readflux)
      elseif (dabs(xt1-teff).lt.1.d0) then
        call readcmfgenmodel (iteff1, ig, readflux)
      else
        call readcmfgenmodel (iteff0, ig, flux0)
        call readcmfgenmodel (iteff1, ig, flux1)
        call intpstellartemp (xt0, xt1, teff, flux0, flux1, readflux)
      endif
c
c Check normalisation
c
      call renormestellar (teff, readflux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine mocassin18 (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***CMFGEN MOCASSIN Log g 4.0 A09 Solar N18 grid
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 flux0(mxinfph)
      real*8 flux1(mxinfph)
      real*8 xt0,xt1
      integer*4 iabn,ig,iteff,iteff0,iteff1,idx
      character feh*4, logg*4
c
      do idx=1,infph
        readflux(idx)=0.d0
        flux0(idx)=0.d0
        flux1(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//
     & '  CMFGEN log g 4.0 Solar N18 Ostar Atmosphere Grid:'/
     & '      -    z   = 1.0  ( A09 Sol )'/
     & '      - Log(g) = 4.0 '/
     & '      - Teff   = 27.5kK ... 55.0kK'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      iabn=0
      ig=400
      iteff=4000
      teff=40.0d3
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     write (*,20)
c  20 format(//' Choose Abundance Zeta:'/
c    & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/
c    & '    A  :  zeta = 1.0 (~Solar)'/
c    & '    B  :  zeta = 0.5 (~LMC)'/
c    & '    C  :  zeta = 0.2 (~SMC)'/
c    & ' :: ',$)
c
c     read (*,'(a)') feh
c     feh=feh(1:1)
c     write (*,*)
      feh='A'
      feh=feh(1:1)
      write (*,*)
c
      if (feh.eq.'a') feh='A'
      if (feh.eq.'b') feh='B'
      if (feh.eq.'c') feh='C'
c
      if ((feh.ne.'A').and.(feh.ne.'B').and.(feh.ne.'C')) then
        write (*,*) 'Unknown zeta, using solar z = 1.0.'
        feh='A'
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      iabn=100
      if (feh.eq.'A') iabn=100
      if (feh.eq.'B') iabn=50
      if (feh.eq.'C') iabn=20
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     write (*,30)
c  30 format(//' Choose Log(g):'/
c    & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/
c    & '    A  :  Log(g) = 3.90'/
c    & '    B  :  Log(g) = 4.00'/
c    & '    C  :  Log(g) = 4.10'/
c    & '    D  :  Log(g) = 4.20'/
c    & ' :: ',$)
c     read (*,'(a)') logg
c     logg=logg(1:1)
c     write (*,*)
      logg='B'
      if (logg.eq.'a') logg='A'
      if (logg.eq.'b') logg='B'
      if (logg.eq.'c') logg='C'
      if (logg.eq.'d') logg='D'
c
      if ((logg.ne.'A').and.(logg.ne.'B').and.(logg.ne.'C')
     &.and.(logg.ne.'D')) then
        write (*,*) 'Unknown Log(g), Log(g) = 4.10'
        logg='C'
      endif
c
      ig=400
      if (logg.eq.'A') ig=390
      if (logg.eq.'B') ig=400
      if (logg.eq.'C') ig=410
      if (logg.eq.'D') ig=420
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write (*,20)
   20 format(//' Choose Teff: 27.5-55.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 2500K will read direct from grid files    :'/
     & ' : non-multiples of 2500K will be interpolated            :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
      read (*,*) teff
      write (*,*)
      if (teff.lt.1.0d1) teff=10.d0**teff
      if (teff.lt.1.0d3) teff=teff*1.d3
      if (teff.lt.27.5d3) teff=27.5d3
      if (teff.gt.55.0d3) teff=55.0d3
      write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
      iteff=idint(teff*4.0d-04)
      iteff0=iteff*250
      if (iteff0.ge.5500) then
        iteff0=5500
        iteff1=iteff0
      elseif (iteff0.lt.2750) then
        iteff0=2750
        iteff1=iteff0
      else
        iteff1=iteff0+250
      endif
      xt0=1.0d1*iteff0
      xt1=1.0d1*iteff1
      write (*,*) xt0,xt1,teff
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (dabs(xt0-teff).lt.1.d0) then
        call readn18model (iteff0, ig, iabn, readflux)
      elseif (dabs(xt1-teff).lt.1.d0) then
        call readn18model (iteff1, ig, iabn, readflux)
      else
        call readn18model (iteff0, ig, iabn, flux0)
        call readn18model (iteff1, ig, iabn, flux1)
        call intpstellartemp (xt0, xt1, teff, flux0, flux1, readflux)
      endif
c
c Check normalisation
c
      call renormestellar (teff, readflux)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine theta1c (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***Theta 1C 40M_0 CMFGEN MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 flux0(mxinfph)
      real*8 flux1(mxinfph)
      real*8 xt0,xt1
      integer*4 iabn,ig,iteff,iteff0,iteff1,idx
      character feh*4, logg*4
c
      do idx=1,infph
        readflux(idx)=0.d0
        flux0(idx)=0.d0
        flux1(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//
     & '  CMFGEN Theta 1C 40M_0 Ostar Atmosphere Grid:'/
     & '      - Zeta   = 1.0 0.5 0.2 (~Sol, LMC, SMC )'/
     & '      - Log(g) = 3.9 - 4.2 '/
     & '      - Teff   = 37.0kK ... 41.0kK'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      iabn=0
      ig=410
      iteff=400
      teff=40.0d3
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (*,20)
   20 format(//' Choose Abundance Zeta:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  zeta = 1.0 (~Solar)'/
     & '    B  :  zeta = 0.5 (~LMC)'/
     & '    C  :  zeta = 0.2 (~SMC)'/
     & ' :: ',$)
c
      read (*,'(a)') feh
      feh=feh(1:1)
      write (*,*)
c
      if (feh.eq.'a') feh='A'
      if (feh.eq.'b') feh='B'
      if (feh.eq.'c') feh='C'
c
      if ((feh.ne.'A').and.(feh.ne.'B').and.(feh.ne.'C')) then
        write (*,*) 'Unknown zeta, using solar zeta = 1.0.'
        feh='A'
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      iabn=100
      if (feh.eq.'A') iabn=100
      if (feh.eq.'B') iabn=50
      if (feh.eq.'C') iabn=20
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (*,30)
   30 format(//' Choose Log(g):'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  Log(g) = 3.90'/
     & '    B  :  Log(g) = 4.00'/
     & '    C  :  Log(g) = 4.10'/
     & '    D  :  Log(g) = 4.20'/
     & ' :: ',$)
      read (*,'(a)') logg
      logg=logg(1:1)
      write (*,*)
      if (logg.eq.'a') logg='A'
      if (logg.eq.'b') logg='B'
      if (logg.eq.'c') logg='C'
      if (logg.eq.'d') logg='D'
c
      if ((logg.ne.'A').and.(logg.ne.'B').and.(logg.ne.'C')
     &.and.(logg.ne.'D')) then
        write (*,*) 'Unknown Log(g), Log(g) = 4.10'
        logg='C'
      endif
c
      ig=410
      if (logg.eq.'A') ig=390
      if (logg.eq.'B') ig=400
      if (logg.eq.'C') ig=410
      if (logg.eq.'D') ig=420
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write (*,40)
   40 format(//' Choose Teff: 37.0-41.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 500K will read direct from grid files    :'/
     & ' : non-multiples of 500K will be interpolated             :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
      read (*,*) teff
      write (*,*)
      if (teff.lt.1.0d1) teff=10.d0**teff
      if (teff.lt.1.0d3) teff=teff*1.d3
      if (teff.lt.37.0d3) teff=37.0d3
      if (teff.gt.41.0d3) teff=41.0d3
      write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
      iteff=idint(teff*0.002d0)
      iteff0=iteff*5
      if (iteff0.eq.410) then
        iteff1=iteff0
      else
        iteff1=iteff0+5
      endif
c     write (*,*) iteff0,iteff1,teff
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      xt0=1.0d2*iteff0
      xt1=1.0d2*iteff1
      if (dabs(xt0-teff).lt.1.d0) then
        call readt1cmodel (iteff0, ig, iabn, readflux)
      elseif (dabs(xt1-teff).lt.1.d0) then
        call readt1cmodel (iteff1, ig, iabn, readflux)
      else
        call readt1cmodel (iteff0, ig, iabn, flux0)
        call readt1cmodel (iteff1, ig, iabn, flux1)
        call intpstellartemp (xt0, xt1, teff, flux0, flux1, readflux)
      endif
c
c Check normalisation
c
      call renormestellar (teff, readflux)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine cspn_hni (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***RAUCH TNMAP Current H-Ni CSPN MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 flux0(mxinfph)
      real*8 flux1(mxinfph)
      real*8 xt0,xt1
      integer*4 iabn,ig,iteff,iteff0,iteff1,idx
      character feh*4, logg*4
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//
     & '  TNMAP CSPN H-Ni grid:'/
     & '      - [Fe/H] = 0.0, -1.0 (Solar, halo )'/
     & '      - Log(g) = 5.0 - 7.0 '/
     & '      - Teff   = 50.0kK ...190.0kK'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      iabn=100
      ig=70
      iteff=100
      teff=100.0d3
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (*,20)
   20 format(//' Choose Abundances:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  [Fe/H] =  0.0 (Solar)'/
     & '    B  :  [Fe/H] = -1.0 (Halo)'/
     & ' :: ',$)
c
      read (*,'(a)') feh
      feh=feh(1:1)
      write (*,*)
c
      if (feh.eq.'a') feh='A'
      if (feh.eq.'b') feh='B'
c
      if ((feh.ne.'A').and.(feh.ne.'B')) then
        write (*,*) 'Unknown abundances, using solar [Fe/H] = 0.0.'
        feh='A'
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      iabn=100
      if (feh.eq.'A') iabn=100
      if (feh.eq.'B') iabn=10
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (*,30)
   30 format(//' Choose Log(g):'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  Log(g) = 5.0  ( Avail: 50kK <= Teff < 100kK)'/
     & '    B  :  Log(g) = 6.0  ( Avail: 50kK <= Teff < 190kK)'/
     & '    C  :  Log(g) = 7.0  ( Avail: 50kK <= Teff < 190kK)'/
     & '    D  :  Log(g) = 8.0  ( Avail: 50kK <= Teff < 190kK)'/
     & ' :: ',$)
      read (*,'(a)') logg
      logg=logg(1:1)
      write (*,*)
      if (logg.eq.'a') logg='A'
      if (logg.eq.'b') logg='B'
      if (logg.eq.'c') logg='C'
      if (logg.eq.'d') logg='D'
c
      if ((logg.ne.'A').and.(logg.ne.'B').and.(logg.ne.'C')
     &.and.(logg.ne.'D')) then
        write (*,*) 'Unknown Log(g), Log(g) = 7.00'
        logg='C'
      endif
c
      ig=70
      if (logg.eq.'A') ig=50
      if (logg.eq.'B') ig=60
      if (logg.eq.'C') ig=70
      if (logg.eq.'D') ig=80
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (ig.eq.50) then
        write (*,40)
   40 format(//' Choose Teff: 50.0 - 100.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 1e4 K will read direct from grid files    :'/
     & ' : non-multiples of 1e4 K will be interpolated            :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.50.0d3) teff=50.0d3
        if (teff.gt.100.0d3) then
          write (*,*) ' *** WARNING: Max Teff is 100kK, using 100kK'
          teff=100.0d3
        endif
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0001d0)
        iteff0=iteff*10
        if (iteff0.eq.100) iteff0=90
        iteff1=iteff0+10
        write (*,*) iteff0,iteff1,teff
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (ig.gt.50) then
        write (*,50)
   50 format(//' Choose Teff: 50.0 - 190.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 1e4 K will read direct from grid files    :'/
     & ' : non-multiples of 1e4 K will be interpolated using      :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.50.0d3) teff=50.0d3
        if (teff.gt.190.0d3) then
          write (*,*) ' *** WARNING: Max Teff is 190kK, using 190kK'
          teff=190.0d3
        endif
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0001d0)
        iteff0=iteff*10
        if (iteff0.eq.190) iteff0=180
        iteff1=iteff0+10
        write (*,*) iteff0,iteff1,teff
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      xt0=1.0d3*iteff0
      xt1=1.0d3*iteff1
      if (dabs(xt0-teff).lt.100.d0) then
        call readcspn_hni (iteff0, ig, iabn, readflux)
      elseif (dabs(xt1-teff).lt.100.d0) then
        call readcspn_hni (iteff1, ig, iabn, readflux)
      else
        call readcspn_hni (iteff0, ig, iabn, flux0)
        call renormestellar (xt0, flux0)
        call readcspn_hni (iteff1, ig, iabn, flux1)
        call renormestellar (xt1, flux1)
        call intpstellartemp (xt0, xt1, teff, flux0, flux1, readflux)
      endif
c
c Check normalisation
c
      call renormestellar (teff, readflux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine cspn_hca (readflux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc    ***RAUCH TNMAP Older H-Ca CSPN MODELS
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 readflux(mxinfph)
      real*8 flux0(mxinfph)
      real*8 flux1(mxinfph)
      real*8 xt0,xt1
      integer*4 iabn,ig,iteff,iteff0,iteff1,idx
      character feh*4, logg*4
c
      do idx=1,infph
        readflux(idx)=0.d0
      enddo
c
      write (*,10)
   10 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'//
     & '  TNMAP CSPN Older H-Ca grid:'/
     & '      - [Fe/H] = 0.0, -1.0 (Solar, halo )'/
     & '      - Log(g) = 5.0 - 9.0 '/
     & '      - Teff   = 50.0kK ...1000.0kK )'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      iabn=100
      ig=70
      iteff=100
      teff=100.0d3
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (*,20)
   20 format(//' Choose Abundances:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  [Fe/H] =  0.0 (Solar)'/
     & '    B  :  [Fe/H] = -1.0 (Halo)'/
     & ' :: ',$)
c
      read (*,'(a)') feh
      feh=feh(1:1)
      write (*,*)
c
      if (feh.eq.'a') feh='A'
      if (feh.eq.'b') feh='B'
c
      if ((feh.ne.'A').and.(feh.ne.'B')) then
        write (*,*) 'Unknown abundances, using solar [Fe/H] = 0.0.'
        feh='A'
      endif
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      iabn=100
      if (feh.eq.'A') iabn=100
      if (feh.eq.'B') iabn=10
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      write (*,30)
   30 format(//' Choose Log(g):'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & '    A  :  Log(g) = 5.0  ( Avail: 50kK <= Teff < 100kK)'/
     & '    B  :  Log(g) = 6.0  ( Avail: 50kK <= Teff < 190kK)'/
     & '    C  :  Log(g) = 7.0  ( Avail: 50kK <= Teff < 300kK)'/
     & '    D  :  Log(g) = 8.0  ( Avail: 50kK <= Teff < 500kK)'/
     & '    E  :  Log(g) = 9.0  ( Avail: 200kK <= Teff < 1000kK)'/
     & ' :: ',$)
      read (*,'(a)') logg
      logg=logg(1:1)
      write (*,*)
      if (logg.eq.'a') logg='A'
      if (logg.eq.'b') logg='B'
      if (logg.eq.'c') logg='C'
      if (logg.eq.'d') logg='D'
      if (logg.eq.'e') logg='E'
c
      if ((logg.ne.'A').and.(logg.ne.'B').and.(logg.ne.'C')
     &.and.(logg.ne.'D').and.(logg.ne.'E')) then
        write (*,*) 'Unknown Log(g), Log(g) = 7.00'
        logg='C'
      endif
c
      ig=70
      if (logg.eq.'A') ig=50
      if (logg.eq.'B') ig=60
      if (logg.eq.'C') ig=70
      if (logg.eq.'D') ig=80
      if (logg.eq.'E') ig=80
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (ig.eq.50) then
        write (*,40)
   40 format(//' Choose Teff: 50.0 - 100.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 10kK will read direct from grid files    :'/
     & ' : non-multiples of 10kK will be interpolated using      :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.50.0d3) then
          write (*,*) ' *** WARNING: Min Teff is 50kK, using 50kK'
          teff=50.0d3
        endif
        if (teff.gt.100.0d3) then
          write (*,*) ' *** WARNING: Max Teff is 100kK, using 100kK'
          teff=100.0d3
        endif
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
        iteff=idint(teff*0.0001d0)
        iteff0=iteff*10
        if (iteff0.eq.100) iteff0=90
        iteff1=iteff0+10
c       write (*,*) iteff0,iteff1,teff
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (ig.eq.60) then
        write (*,50)
   50 format(//' Choose Teff: 50.0 - 190.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 10kK will read direct from grid files    :'/
     & ' : non-multiples of 10kK will be interpolated using      :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.50.0d3) then
          teff=50.0d3
        endif
        if (teff.gt.190.0d3) then
          teff=190.0d3
        endif
        iteff=idint(teff*0.0001d0)
        iteff0=iteff*10
        if (iteff0.eq.190) iteff0=180
        iteff1=iteff0+10
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (ig.eq.70) then
        write (*,60)
   60 format(//' Choose Teff: 50.0 - 300.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 10kK will read direct from grid files    :'/
     & ' : non-multiples of 10kK will be interpolated             :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.50.0d3) then
          teff=50.0d3
        endif
        if (teff.gt.300.0d3) then
          teff=300.0d3
        endif
        if (teff.gt.200.0d3) then
          iteff=idint(teff*0.00001d0)
          iteff0=iteff*100
          if (iteff0.eq.300) iteff0=200
          iteff1=iteff0+100
        else
          iteff=idint(teff*0.0001d0)
          iteff0=iteff*10
          iteff1=iteff0+10
        endif
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (ig.eq.80) then
        write (*,70)
   70 format(//' Choose Teff: 50.0 - 500.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 10kK will read direct from grid files    :'/
     & ' : non-multiples of 10kK will be interpolated             :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.50.0d3) then
          teff=50.0d3
        endif
        if (teff.gt.500.0d3) then
          teff=500.0d3
        endif
        if (teff.gt.200.0d3) then
          iteff=idint(teff*0.00001d0)
          iteff0=iteff*100
          if (iteff0.eq.500) iteff0=400
          iteff1=iteff0+100
        else
          iteff=idint(teff*0.0001d0)
          iteff0=iteff*10
          iteff1=iteff0+10
        endif
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if (ig.eq.90) then
        write (*,80)
   80 format(//' Choose Teff: 200.0 - 1000.0kK :'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/,
     & ' : multiples of 1e5 K will read direct from grid files    :'/
     & ' : non-multiples of 1e5 K will be interpolated            :'/
     & ' : (< 10 as log10, <= 1000 as kK, > 1000 as K             :'/
     & ' :: Teff: ',$)
        read (*,*) teff
        write (*,*)
        if (teff.lt.1.0d1) teff=10.d0**teff
        if (teff.lt.1.0d3) teff=teff*1.d3
        if (teff.lt.50.0d3) then
          teff=50.0d3
        endif
        if (teff.gt.190.0d3) then
          teff=500.0d3
        endif
        iteff=idint(teff*0.00001d0)
        iteff0=iteff*100
        if (iteff0.eq.1000) iteff0=900
        iteff1=iteff0+100
        write (*,'("# Setting Teff = ",1pg14.6,"K")') teff
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      xt0=1.0d3*iteff0
      xt1=1.0d3*iteff1
      if (dabs(xt0-teff).lt.100.d0) then
        call readcspn_hca (iteff0, ig, iabn, readflux)
      elseif (dabs(xt1-teff).lt.100.d0) then
        call readcspn_hca (iteff1, ig, iabn, readflux)
      else
        call readcspn_hca (iteff0, ig, iabn, flux0)
        call renormestellar (xt0, flux0)
        call readcspn_hca (iteff1, ig, iabn, flux1)
        call renormestellar (xt1, flux1)
        call intpstellartemp (xt0, xt1, teff, flux0, flux1, readflux)
      endif
c
c Check normalisation
c
      call renormestellar (teff, readflux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine readatlasmodel (pat, iabn, iteff, ig, flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Stellar File IO routines  All rebinning is now in rebin.f
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      character pat*4
      integer*4 iabn,iteff,ig
      real*8 flux(mxinfph)
c locals
      character atfile*64
      integer*4 l
      integer*4 coordstype
      logical iexi
c functions
      integer*4 lenv
c
c Standard Solar Ratios
c
      atfile='FP00T40G45.txt'
      if (pat.eq.'A') then
        if (iabn.lt.0) then
          write (atfile,'("std/M",I2.2,"/FM",I2.2,"T",I2.2,"G",I2.2,
     &    ".txt")') -iabn,-iabn,iteff,ig
        else
          write (atfile,'("std/P",I2.2,"/FP",I2.2,"T",I2.2,"G",I2.2,
     &    ".txt")') iabn,iabn,iteff,ig
        endif
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Alpha Enhanced Ratios
c
      if (pat.eq.'B') then
        if (iabn.lt.0) then
          write (atfile,'("alpha/M",I2.2,"/FM",I2.2,"AT",I2.2,"G",I2.2,"
     &.txt")') -iabn,-iabn,iteff,ig
        else
          write (atfile,'("alpha/P",I2.2,"/FP",I2.2,"AT",I2.2,"G",I2.2,"
     &.txt")') iabn,iabn,iteff,ig
        endif
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/ATLAS9/'//atfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/ATLAS9/'//atfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/ATLAS9/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c  format = 0, std atmos lib file
c
      coordstype=0
      call readrebin (srcfile, coordstype, flux)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine readtlustymodel (iteff, iabn, ig, flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c arguments
      integer*4 iabn,iteff,ig
      real*8 flux(mxinfph)
c locals
      character atfile*64
      integer*4 l
      logical iexi
c functions
      integer*4 lenv
c
      atfile='TL_P00T400G400.txt'
      if (iabn.lt.0) then
        write (atfile,'("M",I2.2,"/TL_M",I2.2,"T",I3.3,"G",I3.3,".txt")'
     &   ) -iabn,-iabn,iteff,ig
      else
        write (atfile,'("P",I2.2,"/TL_P",I2.2,"T",I3.3,"G",I3.3,".txt")'
     &   ) iabn,iabn,iteff,ig
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/TLUSTY/'//atfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/TLUSTY/'//atfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/TLUSTY/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(atfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c  format = 6, TLUSTY atmos lib file
c
      call readrebin (srcfile, 6, flux)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine readcmfgenmodel (iteff, ig, flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c read models from CMFGEN Ostar grid 2009
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c arguments
      integer*4 iteff,ig
      real*8 flux(mxinfph)
c locals
      character atfile*64
      integer*4 l
      logical iexi
c functions
      integer*4 lenv
c
      atfile='NT40000_logg400_obs15.txt'
      write (atfile,'("NT",I5.5,"_logg",I3.3,"_obs15.txt")') iteff*100,
     &ig
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/CMFGEN/'//atfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/CMFGEN/'//atfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/CMFGEN/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  format = 8, CMFGEN atmos lib file
c
      call readlinrebin (srcfile, 8, flux)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine readt1cmodel (iteff, ig, iz, flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c arguments
      integer*4 iteff,ig,iz
      real*8 flux(mxinfph)
c locals
      character atfile*64
      integer*4 l
      logical iexi
c functions
      integer*4 lenv
c
      atfile='T400G410Z100_obs.txt'
      write (atfile,'("T",I3.3,"G",I3.3,"Z",I3.3,"_obs.txt")') iteff,ig,
     &iz
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/T1CLibrary/'//atfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/T1CLibrary/'//atfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/T1CLibrary/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c  format = 8, T1C test atmos CMFGEN lib file
c
      call readlinrebin (srcfile, 8, flux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine readn18model (iteff, ig, iz, flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c arguments
      integer*4 iteff,ig,iz
      real*8 flux(mxinfph)
c locals
      character atfile*64
      integer*4 l
      logical iexi
c functions
      integer*4 lenv
c
      atfile='T4000_G400_Z100_obs.txt'
      write (atfile,'("T",I4.4,"_G",I3.3,"_Z",I3.3,"_obs.txt")') iteff,
     &ig,iz
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/N18CMFGEN/'//atfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/N18CMFGEN/'//atfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/N18CMFGEN/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c  format = 10, same as T1C test atmos CMFGEN lib file but 9 headers
c
      call readlinrebin (srcfile, 10, flux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine readwmbasicmodel (iteff, iabn, ig, flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c arguments
      integer*4 iabn,iteff,ig
      real*8 flux(mxinfph)
c locals
      character atfile*256
      integer*4 l
      logical iexi
c functions
      integer*4 lenv
c
   10 format('dwarf/M',i2.2,'/DWM_M',i2.2,'T',i3.3,'G',i2.2,'.txt')
   20 format('dwarf/P',i2.2,'/DWM_P',i2.2,'T',i3.3,'G',i2.2,'.txt')
   30 format('sgiant/M',i2.2,'/SWM_M',i2.2,'T',i3.3,'G',i2.2,'.txt')
   40 format('sgiant/P',i2.2,'/SWM_P',i2.2,'T',i3.3,'G',i2.2,'.txt')
c
      atfile='DWM_P00T400G40.txt'
      if (ig.gt.39) then
        if (iabn.lt.0) then
          write (atfile,10) -iabn,-iabn,iteff,ig
        else
          write (atfile,20) iabn,iabn,iteff,ig
        endif
      else
        if (iabn.lt.0) then
          write (atfile,30) -iabn,-iabn,iteff,ig
        else
          write (atfile,40) iabn,iabn,iteff,ig
        endif
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/WMBASIC/'//atfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/WMBASIC/'//atfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/WMBASIC/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c  format = 7, WMBASIC atmos lib file, no interp yet
c
      call readrebin (srcfile, 7, flux)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine readcspn_hni (iteff, iabn, ig, flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c arguments
      integer*4 iabn,iteff,ig
      real*8 flux(mxinfph)
c locals
      character atfile*256
      integer*4 l
      logical iexi
c functions
      integer*4 lenv
c
      atfile='CSPNT100G50Z100HNi.txt'
   10 format('HNi/CSPNT',i3.3,'G',i2.2,'Z',i3.3,'HNi.txt')
      write (atfile,10) iteff,iabn,ig
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/CSPN/'//atfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/CSPN/'//atfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/CSPN/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c  format = 9, CSPN Rauch TMAF HNi grid
c
c      call readrebin (atfile, 9, flux)
      call readrebin (srcfile, 9, flux)
c
c      write(*,*)' Calling: call readlinrebin (atfile, 9, flux)'
c      call readlinrebin (atfile, 9, flux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine readcspn_hca (iteff, iabn, ig, flux)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c arguments
      integer*4 iabn,iteff,ig
      real*8 flux(mxinfph)
c locals
      character atfile*256
      integer*4 l
      logical iexi
c functions
      integer*4 lenv
c
      atfile='CSPNT0100G50Z100HCa.txt'
   10 format('HCa/CSPNT',i4.4,'G',i2.2,'Z',i3.3,'HCa.txt')
      write (atfile,10) iteff,iabn,ig
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      srcfile='atmos/CSPN/'//atfile
      l=lenv(srcfile)
      inquire (file=srcfile(1:l),exist=iexi)
      if (iexi.eqv..false.) then
        write (*,*) srcfile(1:l),' NOT FOUND.'
        srcfile=datadir(1:dtlen)//'atmos/CSPN/'//atfile
        l=lenv(srcfile)
        write (*,*) ' Looking in ',datadir(1:dtlen)//'atmos/CSPN/'
        inquire (file=srcfile(1:l),exist=iexi)
      endif
      l=lenv(srcfile)
      if (iexi) then
        write (*,*) ' Reading: ',srcfile(1:l)
      else
        write (*,*) srcfile(1:l),' NOT FOUND. Retry...'
      endif
c
c  format = 9, CSPN Rauch TNMAF HCa/HNi grid
c
      call readrebin (srcfile, 9, flux)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine renormestellar (xt, src)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c arguments
c xt in K, src corresponding flux array
c
      real*8 xt
      real*8 src(mxinfph)
c
c  locals
c
      integer*4 i
      real*8 widnu,blum
      real*8 intensity,ratio
c
      blum=0.d0
      do i=1,infph-1
        widnu=widbinnu(i)
        blum=blum+widnu*src(i)
      enddo
      blum=blum*pi
      intensity=stefan*(xt**4.d0)
      ratio=intensity/blum
      if (dabs(ratio-1.d0).gt.0.01d0) then
        write (*,*) ' Renormestellar: more than 1% total intensity '
        write (*,*) ' difference, renormalising.'
        write (*,'(4(1pg12.5,x))') xt,blum,intensity,ratio
        do i=1,infph
          src(i)=src(i)*ratio
        enddo
      endif
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine intpstellartemp (xt0, xt1, xt, src0, src1, dst)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c T^4 weighted interpolation between two stellar/BB sources with same
c logg
c
c
c arguments
c
c xt0,xt1,xt in K
c src0,src1: bounding spectra, dst interpolated result
c
c WARNING: expects xt0, xt1 and xt to be correctly set up
c xt0<=xt<=xt1, xt0 < xt1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 xt0, xt1, xt
      real*8 src0(mxinfph)
      real*8 src1(mxinfph)
      real*8 dst (mxinfph)
c
c  locals
c
      integer*4 i
      real*8 a,b,c
      real*8 f,cf
c set up interp fractions
      f=(xt-xt0)/(xt1-xt0)
      f=dmin1(1.d0,dmax1(0.d0,f))
      cf=1.d0-f
c
      do i=1,infph
        a=dmax1(src0(i),0.d0)**0.25d0
        b=dmax1(src1(i),0.d0)**0.25d0
        c=(a*cf+b*f)**4.d0
        dst(i)=dmax1(c,0.d0)
      enddo
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine fpol (kstr, tm1, i)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******CALCULATES POLYNOME VALUE FOR A GIVEN TEFF
c     COEFFICIENTS IN /STAR/
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      double precision tm1,te4,xt
      character kstr*4
      integer*4 i
c
      te4=teff/1.d4
c
      if (kstr.ne.'TNO4') goto 10
c
      xt=(tno4(i,10)/(te4*te4))+tno4(i,11)
c
      tm1=tno4(i,3)+xt*(tno4(i,4)+xt*(tno4(i,5)+xt*(tno4(i,6)+xt*
     &(tno4(i,7)+xt*(tno4(i,8)+xt*tno4(i,9))))))
c
      goto 30
   10 if (kstr.ne.'TNO5') goto 20
c
      xt=(tno5(i,10)/(te4*te4))+tno5(i,11)
c
      tm1=tno5(i,3)+xt*(tno5(i,4)+xt*(tno5(i,5)+xt*(tno5(i,6)+xt*
     &(tno5(i,7)+xt*(tno5(i,8)+xt*tno5(i,9))))))
c
      goto 30
c
   20 if (kstr.ne.'TMET') goto 30
c
      xt=(tmet(i,10)/(te4*te4))+tmet(i,11)
c
      tm1=tmet(i,3)+xt*(tmet(i,4)+xt*(tmet(i,5)+xt*(tmet(i,6)+xt*
     &(tmet(i,7)+xt*(tmet(i,8)+xt*tmet(i,9))))))
c
   30 return
c
      end
