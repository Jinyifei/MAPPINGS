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
      subroutine wbal (caller, pfx, np, p)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     writes out a machine readable ionisation balance.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 p(mxion,mxelem)
c
      character* (*) caller
      character tab*4
      character fn*64
      character pfx*32,sfx*4,fl*64
      integer*4 lunt,i,np,nentries,j
c
      tab=char(9)
      lunt=99
c
c     write out balance file
c
      fn=' '
      sfx='bln'
      call newfile (pfx, np, sfx, 3, fn)
      fl=fn(1:(np+3+5))
c
      open (lunt,file=fl,status='NEW')
c
c
      write (lunt,'("%")')
      write (lunt,'("% Ionisation Balance File")')
      write (lunt,'("%")')
      write (lunt,'("%")')
c
      write (lunt,10) runname
   10 format('% RUN:',a80)
      write (lunt,'("%")')
c
      write (lunt,*) 'Produced by ',caller,' :MAPPINGS V ',theversion
c
      nentries=0
c
      do i=1,atypes
        do j=1,maxion(i)
          nentries=nentries+1
        enddo
      enddo
c
      write (lunt,*) nentries
c
      do i=1,atypes
        do j=1,maxion(i)
   20       format(i2,1x,i2,1x,1pg14.6)
          write (lunt,20) mapz(i),j,p(j,i)
        enddo
      enddo
      close (lunt)
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wabund (lunt)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   Writes just the abundances
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 lunt,i
c
      real*8 totmass, xi(mxelem)
c
   10 format(' Abundances:',i2,' Elements:'//,
     &       ' El.,log[X/H],12+[X/H],log[Del],',
     &       'log[Dep],log[Gas],12+[Gas], Mass Fr.')
   20 format(  2x,a2,6(',',0pf8.3)',',1pe10.3)
c
   30 format( '  Base Mass Fractions:',/,
     &        '  Mass  X, ',0pf10.5,', Y,',0pf10.5,', Z,',0pf10.5)
   40 format( '  Gas Phase Mass Fractions:',/,
     &        '  Mass  X, ',0pf10.5,', Y,',0pf10.5,', Z,',0pf10.5)
      write (lunt,10) atypes
c
      totmass=0.d0
      do i=1,atypes
        totmass=totmass+zion0(i)*atwei(i)
      enddo
      do i=1,atypes
        xi(i)=zion0(i)*atwei(i)/totmass
      enddo
c
      do i=1,atypes
        if (grainmode.eq.0) dion(i)=1.0d0
        write (lunt,20) elem(i),dlog10(zion0(i)),12.d0+dlog10(zion0(i)),
     &   dlog10(deltazion(i)),dlog10(dion(i)),dlog10(zion(i)),12.d0+
     &   dlog10(zion(i)),xi(i)
      enddo
c
      write (lunt,50)
   50 format(  ' ==================================',
     &         '==================================')
c
      write (lunt,30) xi(1),xi(2),(1.d0-(xi(1)+xi(2)))
c
      totmass=0.d0
      do i=1,atypes
        totmass=totmass+zion(i)*atwei(i)
      enddo
      do i=1,atypes
        xi(i)=zion(i)*atwei(i)/totmass
      enddo
      write (lunt,40) xi(1),xi(2),(1.d0-(xi(1)+xi(2)))
c
      write (lunt,50)
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wionabal (lunt, po)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    These are the standarised methods for writing out
c    element abundances and population data.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 lunt,ionmax,i,j
      real*8 po(mxion, mxelem)
      real*8 chcksum
c
      call wabund (lunt)
c
      write (lunt,10) (elem(i),i=1,atypes)
   10 format(/t8,30(4x,a2,4x))
c
c    find highest ionisation
c
      ionmax=0
      do i=1,atypes
        if (maxion(i).ge.ionmax) ionmax=maxion(i)
      enddo
      if (ionmax.gt.31) ionmax=31
c
c
   20 format(' ',a6,2x,30(1pg10.3))
      do j=1,ionmax
        chcksum=0.0d0
        do i=1,atypes
          chcksum=chcksum+po(j,i)
        enddo
        if (chcksum.gt.epsilon) then
          write (lunt,20) rom(j),(po(j,i),i=1,atypes)
        endif
      enddo
c
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wionabal2 (lunt, po)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c      Same as wionabal, but doesn't call wabund to write abundances.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 lunt,ionmax,i,j
      real*8 po(mxion, mxelem)
      real*8 chcksum
c
      write (lunt,10) (elem(i),i=1,atypes)
   10 format(/t8,30(4x,a2,4x))
c
c    find highest ionisation
c
      ionmax=0
      do i=1,atypes
        if (maxion(i).ge.ionmax) ionmax=maxion(i)
      enddo
      if (ionmax.gt.31) ionmax=31
c
c
   20 format(' ',a6,2x,30(1pg10.3))
      do j=1,ionmax
        chcksum=0.0d0
        do i=1,atypes
          chcksum=chcksum+po(j,i)
        enddo
        if (chcksum.gt.epsilon) then
          write (lunt,20) rom(j),(po(j,i),i=1,atypes)
        endif
      enddo
c
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wionpop (lunt, po)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    This will become the standarised method for writing out
c    just population data.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 lunt,ionmax,i,j
      real*8 po(mxion, mxelem),chcksum
c
c    if lunt > 0 then writing to a file
c
      write (lunt,10) (elem(i),i=1,atypes)
   10 format(' ',t8,30(4x,a2,4x)/)
c
c    find highest ionisation
c
      ionmax=0
c
      do i=1,atypes
        if (maxion(i).ge.ionmax) ionmax=maxion(i)
      enddo
c
c
   20 format(' ',a6,2x,30(1pg10.3))
      do j=1,ionmax
        chcksum=0.0d0
        do i=1,atypes
          chcksum=chcksum+po(j,i)
        enddo
        if (chcksum.gt.0.0d0) then
          write (lunt,20) rom(j),(po(j,i),i=1,atypes)
        endif
      enddo
c
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wmodel (lunt, t, de, dh, dstep, wmod)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     wmodel:write out current plasma model conditions.
c
c     wmod = 'SCRN'   for vertical format, lunt is not used.
c     wmod = 'FILE'   for side by side format, lunt is
c                     assumed to be open.
c     wmod = 'PROP'   properties only, inline,lunt
c                     assumed to be open.
c     wmod = 'LOSS'   losses and gains only in line, lunt
c                     assumed to be open.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t,de,dh,dstep,rl,fsl,sint,aspd
      real*8 q2los,cspd,ram,mag
      real*8 trec,tcoll,press,en,ue,cts,rhotot,wmol
      real*8 a(50)
      integer*4 lunt,i,atom
      character wmod*4
c
c           Functions
c
      real*8 fcietim,fpresse,frectim,frho
c
c just the header
c
      if (wmod.eq.'LOSH') then
   10 format(' Dist.',t14,'  Te',t28,'  de',t42,'  dh',t56,'  en',t70,
     &    '  Dloss',t84,'  Eloss',t98,'  Egain',t112,'  Coll. H',t126,
     &    '  Chrg. Ex.',t140,'  Reson Casc.',t154,
     &    '  Inter/fine',t168,'  Forbid',t182,'  Fe II',t196,
     &    '  2Photon',t210,'  Free-Free',t224,'  Coll. Ion',t238,
     &    '  Photo.',t252,'  Recomb.',t266,'  Cosmic',t280,
     &    '  GrainsH-C',t294,'  G.Heat',t308,'  G.Cool',t322,'  PAHs')
        write (lunt,10)
        return
      endif
c
      press=fpresse(t,de,dh)
      rhotot=frho(de,dh)
c
      trec=frectim(t,de,dh)
c      tcoll=fcietim(t,de,dh)
      tcoll=fcietim(dh)
c
      ram=rhotot*vel0*vel0
c
      q2los=0.d0
      do atom=1,atypes
        q2los=q2los+h2qbri(atom)
      enddo
c
      en=zen*dh
c
      ue=gammaEOSU*(en+de)*rkb*t
      cts=ue/tloss
c
      cspd=dsqrt(gammaEOS*press/rhotot)
c
      mag=bm0
      aspd=dsqrt(mag*mag/(fpi*rhotot))
c
      wmol=rhotot/(en+de)
c
c     rl=rloss+xrloss+xr3loss+xrlloss
c
      rl=xr3loss+xrlloss
      fsl=fslos+fmloss
c
      if (wmod.eq.'LOSS') then
c
   20 format(24(1pe13.6,x))
c
c old disused resonance line lists
c
c       if (dabs(rloss).gt.ioepsilon) a(12)=rloss
c       if (dabs(xrloss).gt.ioepsilon) a(14)=xrloss
c       if (dabs(cmplos).gt.ioepsilon) a(16)=cmplos
c
        do i=1,24
          a(i)=0.d0
        enddo
        if (dabs(dstep).gt.ioepsilon) a(1)=dstep
        if (dabs(t).gt.ioepsilon) a(2)=t
        if (dabs(de).gt.ioepsilon) a(3)=de
        if (dabs(dh).gt.ioepsilon) a(4)=dh
        if (dabs(en).gt.ioepsilon) a(5)=en
        if (dabs(dlos).gt.ioepsilon) a(6)=dlos
        if (dabs(eloss).gt.ioepsilon) a(7)=eloss
        if (dabs(egain).gt.ioepsilon) a(8)=egain
        if (dabs(hloss).gt.ioepsilon) a(9)=hloss
        if (dabs(chgain).gt.ioepsilon) a(10)=chgain
        if (dabs(xr3loss+xrlloss).gt.ioepsilon) a(11)=xr3loss+xrlloss
        if (dabs(fsl).gt.ioepsilon) a(12)=fsl
        if (dabs(fmloss).gt.ioepsilon) a(13)=fmloss
        if (dabs(feloss).gt.ioepsilon) a(14)=feloss
        if (dabs(q2los).gt.ioepsilon) a(15)=q2los
        if (dabs(fflos).gt.ioepsilon) a(16)=fflos
        if (dabs(colos).gt.ioepsilon) a(17)=colos
        if (dabs(pgain).gt.ioepsilon) a(18)=pgain
        if (dabs(rngain).gt.ioepsilon) a(19)=rngain
        if (dabs(cosgain).gt.ioepsilon) a(20)=cosgain
        if (dabs(gheat-gcool).gt.ioepsilon) a(21)=gheat-gcool
        if (dabs(gheat).gt.ioepsilon) a(22)=gheat
        if (dabs(gcool).gt.ioepsilon) a(23)=gcool
        if (dabs(paheat).gt.ioepsilon) a(24)=paheat
c
        write (lunt,20) (a(i),i=1,24)
        return
      endif
      if (wmod.eq.'PROP') then
c
   30 format(15(1pe13.6,x))
c
        do i=1,15
          a(i)=0.d0
        enddo
        if (dabs(dstep).gt.ioepsilon) a(1)=dstep
        if (dabs(t).gt.ioepsilon) a(2)=t
        if (dabs(de).gt.ioepsilon) a(3)=de
        if (dabs(dh).gt.ioepsilon) a(4)=dh
        if (dabs(en).gt.ioepsilon) a(5)=en
        if (dabs(pop(1,1)).gt.ioepsilon) a(6)=pop(1,1)
        if (dabs(rhotot).gt.ioepsilon) a(7)=rhotot
        if (dabs(press).gt.ioepsilon) a(8)=press
        if (dabs(vel0).gt.ioepsilon) a(9)=vel0
        if (dabs(ram).gt.ioepsilon) a(10)=ram
        if (dabs(cspd).gt.ioepsilon) a(11)=cspd
        if (dabs(dstep).gt.ioepsilon) a(12)=dstep
        if (dabs(aspd).gt.ioepsilon) a(13)=aspd
        if (dabs(bm0).gt.ioepsilon) a(14)=bm0
        if (dabs((avgpot(1)+avgpot(2))*0.5d0).gt.ioepsilon) a(15)=
     &   (avgpot(1)+avgpot(2))*0.5d0
        write (lunt,30) (a(i),i=1,15)
        return
      endif
c
      if (wmod.eq.'FILE') then
        do i=1,8
          a(i)=0.d0
        enddo
        if (dabs(tloss).gt.ioepsilon) a(1)=tloss
        if (dabs(tgain).gt.ioepsilon) a(2)=tgain
        if (dabs(eloss).gt.ioepsilon) a(3)=eloss
        if (dabs(egain).gt.ioepsilon) a(4)=egain
        if (dabs(dlos).gt.ioepsilon) a(5)=dlos
        if (dabs(hloss).gt.ioepsilon) a(6)=hloss
        if (dabs(chgain).gt.ioepsilon) a(7)=chgain
        if (dabs(xrlloss+xr3loss).gt.ioepsilon) a(8)=xrlloss+xr3loss
c       if (dabs(rloss).gt.ioepsilon) a(9)=rloss
        write (lunt,40) (a(i),i=1,8)
c
   40 format(/
     &'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'% TOTAL LOSS  :',1pe12.5,' : TOTAL GAIN  :',1pe12.5,' % '/
     &'% EFF.  LOSS  :',1pe12.5,' : EFF.  GAIN  :',1pe12.5,' % '/
     &'% FRAC. RESID :',1pe12.5,' :(DLOS)%%%%%%%%%%%%%%%%%%%%%'/
     &'% COLEXC HYD. :',1pe12.5,' : CHARGE EX.  :',1pe12.5,' %'/
     &'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'% CASC. RES.  :', 1pe12.5,':%%%%%%%%%%%%%%%%%%%%%%%%%%%'/)
c
        do i=1,27
          a(i)=0.d0
        enddo
        if (dabs(t).gt.ioepsilon) a(1)=t
        if (dabs(rhotot).gt.ioepsilon) a(2)=rhotot
        if (dabs(fsl).gt.ioepsilon) a(3)=fsl
        if (dabs(f3loss).gt.ioepsilon) a(4)=f3loss
        if (dabs(en).gt.ioepsilon) a(5)=en
        if (dabs(de).gt.ioepsilon) a(6)=de
        if (dabs(fmloss).gt.ioepsilon) a(7)=fmloss
        if (dabs(feloss).gt.ioepsilon) a(8)=feloss
        if (dabs(pop(1,1)).gt.ioepsilon) a(9)=pop(1,1)
        if (dabs(press).gt.ioepsilon) a(10)=press
        if (dabs(q2los).gt.ioepsilon) a(11)=q2los
        if (dabs(cmplos).gt.ioepsilon) a(12)=cmplos
        if (dabs(vel0).gt.ioepsilon) a(13)=vel0
        if (dabs(ram).gt.ioepsilon) a(14)=ram
        if (dabs(fflos).gt.ioepsilon) a(15)=fflos
        if (dabs(colos).gt.ioepsilon) a(16)=colos
        if (dabs(cspd).gt.ioepsilon) a(17)=cspd
        if (dabs(dstep).gt.ioepsilon) a(18)=dstep
        if (dabs(pgain).gt.ioepsilon) a(19)=pgain
        if (dabs(rngain).gt.ioepsilon) a(20)=rngain
        if (dabs(aspd).gt.ioepsilon) a(21)=aspd
        if (dabs(mag).gt.ioepsilon) a(22)=mag
        if (dabs(cosgain).gt.ioepsilon) a(23)=cosgain
        if (dabs(paheat).gt.ioepsilon) a(24)=paheat
        if (dabs(avgpot(1)).gt.ioepsilon) a(25)=avgpot(1)
        if (dabs(avgpot(2)).gt.ioepsilon) a(26)=avgpot(2)
        if (dabs(gheat-gcool).gt.ioepsilon) a(27)=(gheat-gcool)
        write (lunt,50) (a(i),i=1,27)
c
   50 format(
     &'% CASC. RES.  %', 1pe12.5,'% OLD RESON.  %',1pe12.5,' %'/
     &'% TEMP.       %', 1pe12.5,'% DENSITY     %',1pe12.5,' %'/
     &'% INTER.      %', 1pe12.5,'% 3 LEV. FINE %',1pe12.5,' %'/
     &'% N IONS      %', 1pe12.5,'% N ELECTRONS %',1pe12.5,' %'/
     &'% MULTI-LVL.  %', 1pe12.5,'% MULTI_IRON  %',1pe12.5,' %'/
     &'% FRAC. N. H  %', 1pe12.5,'% PRESSURE    %',1pe12.5,' %'/
     &'% 2PHOTON     %', 1pe12.5,'% COMPTON     %',1pe12.5,' %'/
     &'% FLOW VELOC. %', 1pe12.5,'% RAM PRESS.  %',1pe12.5,' %'/
     &'% FREFRE      %', 1pe12.5,'% COLION      %',1pe12.5,' %'/
     &'% SOUND SPEED %', 1pe12.5,'% SLAB DEPTH  %',1pe12.5,' %'/
     &'% PGAIN       %', 1pe12.5,'% RNGAIN      %',1pe12.5,' %'/
     &'% ALFEN SPEED %', 1pe12.5,'% MAG. FIELD  %',1pe12.5,' %'/
     &'% COSMIC      %', 1pe12.5,'% PHOTO.  PAH %',1pe12.5,' %'/
     &'% GRA GRN POT %', 1pe12.5,'% SIL GRN POT %',1pe12.5,' %'/
     &'% PHOT. GRN   %', 1pe12.5,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'//)
        return
      endif
c
      if (wmod.eq.'SCRN') then
c
        write (*,60) tloss,tgain,eloss,egain,dlos,t,rhotot,en,de,pop(1,
     &   1),press,vel0,ram,cspd,dstep
        write (*,70) aspd,mag,avgpot(1),avgpot(2),sint,wdil,teff,alnth,
     &   turn,cut
   60 format(/
     &'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'% TOTAL LOSS %', 1pe12.5,' % EFF. LOSS   %',1pe12.5,' %'/
     &'% EFF. GAIN  %', 1pe12.5,' % FRAC. RESID.%',1pe12.5,' %'/
     &'% FRAC.RESID %', 1pe12.5,' %(DLOS)%%%%%%%%%%%%%%%%%%%%%'/
     &'% TEMP.      %', 1pe12.5,' % DENSITY     %',1pe12.5,' %'/
     &'% N IONS     %', 1pe12.5,' % N ELECTRONS %',1pe12.5,' %'/
     &'% FRAC. N. H %', 1pe12.5,' % PRESSURE    %',1pe12.5,' %'/
     &'% FLOW VELOC.%', 1pe12.5,' % RAM PRESS.  %',1pe12.5,' %'/
     &'% SOUND SPEED%', 1pe12.5,' % SLAB DEPTH  %',1pe12.5,' %')
   70 format(
     &'% ALFEN SPEED%', 1pe12.5,' % MAG. FIELD  %',1pe12.5,' %'/
     &'% GRA GRN POT%', 1pe12.5,' % SIL GRN POT.%',1pe12.5,' %'/
     &'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'% SOURCE INT.%', 1pe12.5,' % DILUT. F.   %',1pe12.5,' %'/
     &'% STAR TEMP. %', 1pe12.5,' % ALPHA       %',1pe12.5,' %'/
     &'% TURN-ON    %', 1pe12.5,' % CUT-OFF     %',1pe12.5,' %')
c
        write (*,80) tloss,hloss,chgain,xr3loss,xrlloss,q2los,f3loss,
     &   fmloss,feloss,fflos,colos,pgain,rngain,cosgain,paheat,(gheat-
     &   gcool)
   80 format(
     &'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'% TOTAL LOSS%', 1pe12.5,' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'% COLEXC H. %', 1pe12.5,' % CHARGE EX.  %', 1pe12.5,' %'/
     &'% CASC. RES.%', 1pe12.5,' % X. RESON.   %', 1pe12.5,' %'/
     &'% 2PHOTON   %', 1pe12.5,' % 3 LEV. FINE %', 1pe12.5,' %'/
     &'% MULIT-LVL.%', 1pe12.5,' % MULTI-IRON  %', 1pe12.5,' %'/
     &'% FREFRE    %', 1pe12.5,' % COLION      %', 1pe12.5,' %'/
     &'% PGAIN     %', 1pe12.5,' % RNGAIN      %', 1pe12.5,' %'/
     &'% COSMIC    %', 1pe12.5,' % PHOTO. PAH  %', 1pe12.5,' %'/
     &'% DUST  H-C %', 1pe12.5,' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        return
      endif
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wemiss2 (caller, pfx, np, t, de, dh, dr, scale, tp)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    Output Vector Units: Lambda(E)  = ergs cm3 /s/eV
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 tp(mxinfph),tl(mxinfph),t,de,dh,dr
      real*8 widnu,scale
c
      integer*4 lunt,i,j,np
c
      character* (*) caller
      character tab*4
      character fn*64
      character pfx*32,sfx*4,fps*64
c
      tab=char(9)
      lunt=99
c
      fps=' '
c
c     output upstream field photon source file
c
      fn=' '
      sfx='emi'
      call newfile (pfx, np, sfx, 3, fn)
      fps=fn(1:(np+3+5))
c
      open (lunt,file=fps,status='NEW')
      i=infph-1
c
      write (lunt,10) scale
   10 format('% EMISSIVITY SPECTRUM ',/,
     & '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     & '% UNITS% eV (bin centre) vs                          %'/
     & '%      % 1e23/ne^2 * L(bin)                          %'/
     & '%      % ',1pe12.5,' * L(bin) (ergs cm3/s)          %')
c
   20 format(
     & '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     & '% TOTAL LOSS:',1pe12.5,' % EFF. LOSS  :',1pe12.5,' %'/
     & '% EFF.  GAIN:',1pe12.5,' % FRAC. RESID:',1pe12.5,' %'/
     & '% TEMP.     :',1pe12.5,' % EL. DENSITY:',1pe12.5,' %'/
     & '% H. DENSITY:', 1pe12.5,'                            %'/
     & '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
c
      write (lunt,20) tloss,eloss,egain,dlos,t,de,dh
c
      write (lunt,*) 'Produced by ',caller,' :MAPPINGS V ',theversion
   30 format(' Temperature(K) =',1pe12.5,' Log(Ne)=',1pe12.5)
      write (lunt,30) t,dlog10(de)
c
      do j=1,infph-1
        if (scale.gt.0.d0) then
          widnu=1.d0*evplk
          tl(j)=(scale*fpi*tp(j)*widnu/dr)
          if (tl(j).lt.ioepsilon) then
            tl(j)=0.d0
          endif
        else
          tl(j)=0.d0
        endif
c   40   format(1pe14.7,x,1pe14.7)
c        write (lunt,40) cphotev(j),tl(j)
      enddo
c
c 10 col output for genx
c
   40 format(10(x,1pe11.4))
      write (lunt,40) (tl(j),j=1,(infph-1))
c
      close (lunt)
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wpsoufile (caller, fname, wmod, t, de, dh, dr, scale,
     &tp)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     standard routine to write out a source vector, given the
c     field in tphot.
c
c     Vector Units: Fnu  = ergs/s/cm2/Hz/sr
c     wmod = 'PSOU' .sou Jnu 1/4pi units from photsou
c     if tp in 1/pi  Inu scale = 0.25d0
c     if tp in 1/4pi Jnu scale = 1.00d0
c
c     External files are all 3D flux units 1/(4pi) because they are
c     generally written from diffuse field vectors.  2D (1/pi) units
c     are only used internally for source vectors and are converted
c     when files are read in in photsou.f
c
c     wmod = 'REAL' use total emission from slab, don't use dr
c     wmod = 'NORM' then normalise to 1cm slab, use dr
c     wmod = 'NFNU' then write nu v nuFnu (ergs/s/cm2/sr)
c     wmod = 'LFLM' then write lam (A) v Flam (ergs/s/cm2/A)
c     wmod = 'PSOU' .sou Jnu 1/4pi units from photsou
c
c     Now puts out two columns in the files: energy in eV and flux.
c
c     same as wpsou but uses given file name and appends to file if old
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 tp(mxinfph),tl(mxinfph),scale,t,de,dh,dr
      real*8 bv, blum, ilum, widnu, clam, lambda
c
      integer*4 lunt,i,j,np
c
      character wmod*4,tab*4
      character* (*) fname
      character* (*) caller
c
      logical iexi
c
c functions
c
      real*8 fnair
      integer*4 lenv,mlen
c
      tab=char(9)
      lunt=99
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     total energy in scale*tp should be 1/4pi jnu
c     scale = 0.25 for souvec, 1.0 for tphot
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      blum=0.d0
      ilum=0.d0
      np=mlen(runname)
c
c     scale units in tl and sum
c
      do i=1,infph-1
c
        tl(i)=0.d0
        if (tp(i).ge.ioepsilon) then
          tl(i)=scale*tp(i)
        endif
c
        widnu=widbinnu(i)
        blum=blum+tl(i)*widnu
        if (photev(i).ge.iph) ilum=ilum+tl(i)*widnu
c
      enddo
c
      i=infph-1
c
      inquire (file=fname,exist=iexi)
      if (.not.iexi) then
        open (lunt,file=fname,status='NEW')
        if (wmod.eq.'LFLM') then
          write (lunt,10) runname(1:np),wmod,t,de,dh
   10    format('% LFLAM SPECTRUM '/
     &     '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &     '% RUN :',a45,' %'/
     &     '% MODE:',a4,'                                        %'/
     &     '% UNITS: Lambda (Air) vs Flambda (ergs/s/cm2/A)      %'/
     &     '% UNITS: bin centre wavelengths                      %'/
     &     '% TEMP.    :',1pe12.5,'                             %'/
     &     '% El. DENS.:',1pe12.5,'                             %'/
     &     '% H.  DENS.:',1pe12.5,'                             %')
        elseif (wmod.eq.'NFNU') then
          write (lunt,20) runname(1:np),wmod,t,de,dh
   20    format('% NUFNU SPECTRUM '/
     &     '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &     '% RUN :',a45,' %'/
     &     '% MODE:',a4,'                                        %'/
     &     '% UNITS: nu (Hz) v nuFnu (Hz v ergs/s/cm2/sr)        %'/
     &     '% UNITS: bin lower/left edge frequencies             %'/
     &     '% TEMP.    :',1pe12.5,'                             %'/
     &     '% El. DENS.:',1pe12.5,'                             %'/
     &     '% H.  DENS.:',1pe12.5,'                             %')
        elseif (wmod.eq.'NORM') then
          write (lunt,30) runname(1:np),wmod,t,de,dh
   30    format('% COOLING SPECTRUM '/
     &     '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &     '% RUN :',a45,' %'/
     &     '% MODE:',a4,'                                        %'/
     &     '% UNITS: E (eV) vs L(E) (ergs/s cm3)                 %'/
     &     '% (4pi nu Fnu/dr)/(n^2)                              %'/
     &     '% UNITS: bin lower/left edge energies                %'/
     &     '% TEMP.    %',1pe12.5,'                             %'/
     &     '% El. DENS.%',1pe12.5,'                             %'/
     &     '% H.  DENS.%',1pe12.5,'                             %')
        elseif (wmod.eq.'XRAY') then
          write (lunt,40) runname(1:np),wmod,t,de,dh
   40    format('% CMFGEN XRAY SPECTRUM '/
     &     '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &     '% RUN :',a45,' %'/
     &     '% MODE:',a4,'                                        %'/
     &     '% UNITS: E (eV) vs F_E (ergs/s/cm2/ev)               %'/
     &     '% UNITS: bin centre energies                         %'/
     &     '% TEMP.    %',1pe12.5,'                             %'/
     &     '% El. DENS.%',1pe12.5,'                             %'/
     &     '% H.  DENS.%',1pe12.5,'                             %')
        else
          write (lunt,50) runname(1:np),wmod
   50    format('%PHOTON SOURCE FILE '/
     &     '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &     '% DIFFUSE FIELD PLUS SOURCE                          %'/
     &     '% RUN :',a45,' %'/
     &     '% MODE:',a4,'                                          %'/
     &     '% UNITS:eV vs Fnu (ergs/s/cm2/Hz/sr)                 %'/
     &     '% Fnu in 3D units Jnu (1/(4pi)) sr not               %'/
     &     '% 2D source Inu (1/pi) units.                        %'/
     &     '% bin energies are lower/left edge of bins.          %'/
     &     '% fluxes are average over bin.                       %')
        endif
      else
        open (lunt,file=fname,status='OLD',access='APPEND')
      endif
c
      call fieldsummary (lunt, 0, tl)
c
      np=lenv(caller)
      write (lunt,*) 'Produced by ',caller(1:np),' :MAPPINGS V ',
     &theversion
      if ((wmod.eq.'REAL').or.(wmod.eq.'PSOU')) then
        write (lunt,*) fieldversion
        write (lunt,*) infph-1
      endif
c
   60  format(1pe14.7,' ',1pe14.7)
   70  format(1pe14.7,', ',1pe14.7)
c
      if (wmod.eq.'LFLM') then

         write (lunt,*) ' Wavelength   , Flambda Flux  '
         write (lunt,*) ' (A, air,vac) , (ergs/s/cm2/A)'

        do j=infph,1,-1
c
          bv=cphotev(j)*evplk
          clam=1.0d8*cls/(bv*evplk)
          tl(j)=0.d0
          tl(j)=fpi*(scale*bv*tp(j)/clam)
          if (tl(j).lt.ioepsilon) then
            tl(j)=0.d0
          endif
c
          lambda=1.0d8*cls/(cphotev(j)*evplk)
          if (lambda.ge.1000.d0) then
            if (lambda.le.50000.d0) then
              if (tl(j).gt.0.d0) then
                lambda=lambda/fnair(lambda)
                write (lunt,70) lambda,tl(j)
              endif
            endif
          endif
c
        enddo
      else
c
        if (wmod.eq.'NFNU') then
           write (lunt,*) ' Frequency    ,   nuFnu Flux    '
           write (lunt,*) '    (Hz)      , (ergs/s/cm2/sr) '
        elseif (wmod.eq.'NORM') then
           write (lunt,*) '   Energy     ,        L(E)     '
           write (lunt,*) '    (eV)      ,   (ergs/s cm3)  '
        elseif (wmod.eq.'XRAY') then
           write (lunt,*) ' Mid Energy         Flux(E)     '
           write (lunt,*) '    (eV)        (ergs/s/cm2/ev) '
        endif
c
        do j=1,infph-1
c
          bv=cphotev(j)*evplk
          clam=1.0d8*cls/(bv*evplk)
          tl(j)=0.d0
c
          if ((tp(j).ge.ioepsilon).and.(dr.gt.0.d0)) then
            if (wmod.eq.'NORM') tl(j)=fpi*(scale*bv*tp(j)/dr)
            if (wmod.eq.'XRAY') tl(j)=fpi*(scale*evplk*tp(j)/dr)
            if (wmod.eq.'REAL') tl(j)=(scale*tp(j))
            if (wmod.eq.'PSOU') tl(j)=(scale*tp(j))
            if (wmod.eq.'NFNU') tl(j)=(scale*bv*tp(j))
          endif
c
          if (tl(j).lt.ioepsilon) tl(j)=0.d0
c
          if (wmod.eq.'NFNU') then
            if (tl(j).gt.ioepsilon) then
              write (lunt,70) photev(j)*evplk,tl(j)
            endif
          elseif (wmod.eq.'NORM') then
            write (lunt,70) photev(j),tl(j)
          elseif (wmod.eq.'XRAY') then
            if (tl(j).gt.0.d0) then
              write (lunt,60) cphotev(j),tl(j)
            endif
          else
            write (lunt,60) photev(j),tl(j)
          endif
c
        enddo
      endif
c
      close (lunt)
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wpsou (caller, pfx, np, wmod, t, de, dh, dr, scale, tp)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     standard routine to write out a source vector, given the
c     field in tphot.
c
c     Vector Units: Fnu  = ergs/s/cm2/Hz/sr
c     wmod = 'PSOU' .sou Jnu 1/4pi units from photsou
c     if tp in 1/pi  Inu scale = 0.25d0
c     if tp in 1/4pi Jnu scale = 1.00d0
c
c     External files are all 3D flux Jnu units 1/(4pi) because they are
c     generally written from diffuse field vectors.  2D (1/pi) units
c     are only used internally for source vectors and are converted
c     when files are read in in photsou.f
c
c     wmod = 'REAL' use total emission from slab, don't use dr, .sou
c     wmod = 'NORM' then normalise to 1cm slab, use dr, .csv
c     wmod = 'NFNU' then write nu v nuFnu (ergs/s/cm2/sr), .csv
c     wmod = 'LFLM' then write lam (A) v Flam (ergs/s/cm2/A) .csv
c     wmod = 'PSOU' .sou Jnu 1/4pi units from photsou
c
c     Now puts out two columns in the files: energy in eV and flux.
c
c     old form with just the prefix, calls wpsoufile above
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 tp(mxinfph),t,de,dh,dr,scale
c
      integer*4 np
c
      character wmod*4
      character fn*64
      character* (*) caller
      character* (*) pfx
      character sfx*4,fps*64
c
      fps=' '
      if (wmod.eq.'LFLM') then
c
        fn=' '
        sfx='lam'
        call newfile (pfx, np, sfx, 3, fn)
        fps=fn(1:(np+3+5))
c
      elseif (wmod.eq.'NFNU') then
c
        fn=' '
        sfx='nfn'
        call newfile (pfx, np, sfx, 3, fn)
        fps=fn(1:(np+3+5))
c
      elseif (wmod.eq.'NORM') then
c
        fn=' '
        sfx='emi'
        call newfile (pfx, np, sfx, 3, fn)
        fps=fn(1:(np+3+5))
c
      elseif (wmod.eq.'XRAY') then
c
        fn=' '
        sfx='dat'
        call newfile (pfx, np, sfx, 3, fn)
        fps=fn(1:(np+3+5))
c
      elseif (wmod.eq.'PSOU') then
c
c raw file as is
c
        fps=pfx(1:np)
c
      else
c
c     output upstream field photon source file
c
        fn=' '
        sfx='sou'
        call newfile (pfx, np, sfx, 3, fn)
        fps=fn(1:(np+3+5))
c
      endif
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      call wpsoufile (caller, fps, wmod, t, de, dh, dr, scale, tp)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wplam4 (caller, pfx, np, t, de, dh, dr, scale)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Routine to write out a 4 flambda vectors, given the
c     fields in tp1, total, tp2 , neblula only, tp3, src, tp4 nebcont.
c
c     Vector Units: Fnu  = ergs/s/cm2/Hz/sr
c     wmod = 'LFLM' then write lam (A) v Flam (ergs/s/cm2/A) .lam
c
c     Now puts out 5 columns in the files: lambda tp1,..tp4 in flabda
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      character* (*) caller
      character* (*) pfx
      real*8 t,de,dh,dr,scale
c
      character sfx*4,fps*64
c
      real*8 tl(mxinfph)
      real*8 bv, blum, ilum, widnu, clam, lambda
c
      integer*4 lunt,i,j,np
      logical iexi
c
      character fn*64
c
c functions
c
      real*8 fnair
      integer*4 lenv,mlen
c
      fps=' '
c
      fn=' '
      sfx='csv'
      call newfile (pfx, np, sfx, 3, fn)
      fps=fn(1:(np+3+5))

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c     write lam (A) v Flam (ergs/s/cm2/A)
c     total, src, neb, neb continum
c
c     Now puts out 5 columns in the files: wave in A fluxs in flambda
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
      lunt=99
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      np=mlen(runname)
c
      i=infph-1
c
      inquire (file=fps,exist=iexi)
      if (.not.iexi) then
          open (lunt,file=fps,status='NEW')
          write (lunt,10) runname(1:np),t,de,dh
   10     format('% 4FLAM SPECTRUM '/
     &     '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'/
     &     '% RUN :',a45,' %'/
     &     '% UNITS: Lambda (Air) vs 4 Flambda (ergs/s/cm2/A)    %'/
     &     '% UNITS: bin centre wavelengths                      %'/
     &     '% TEMP.    :',1pe12.5,'                             %'/
     &     '% El. DENS.:',1pe12.5,'                             %'/
     &     '% H.  DENS.:',1pe12.5,'                             %')
      else
        open (lunt,file=fps,status='OLD',access='APPEND')
      endif
c
      call fieldsummary (lunt, 0, tp1)
c
      np=lenv(caller)
      write (lunt,*) 'Produced by ',caller(1:np),' :MAPPINGS V ',
     &theversion
      write (lunt,*) ' Wavelength  ,  Total Model  ,  Source Only  ',
     & ',  Nebula Only  ,  Nebual Cont. '
      write (lunt,*) ' (A, air,vac), (ergs/s/cm2/A), (ergs/s/cm2/A)',
     & ', (ergs/s/cm2/A), (ergs/s/cm2/A)'
c
   20  format(1pe14.7,4(', ',1pe14.7))
c
       do j=infph,1,-1
c
         bv=cphotev(j)*evplk
         clam=1.0d8*cls/(bv*evplk)
         tp1(j)=fpi*(scale*bv*tp1(j)/clam)
         if (tp1(j).lt.ioepsilon) then
           tp1(j)=0.d0
         endif
c
         tp2(j)=fpi*(scale*bv*tp2(j)/clam)
         if (tp2(j).lt.ioepsilon) then
           tp2(j)=0.d0
         endif
c
         tp3(j)=fpi*(scale*bv*tp3(j)/clam)
         if (tp3(j).lt.ioepsilon) then
           tp3(j)=0.d0
         endif
c
         tp4(j)=fpi*(scale*bv*tp4(j)/clam)
         if (tp4(j).lt.ioepsilon) then
           tp4(j)=0.d0
         endif
c
         lambda=1.0d8*cls/(cphotev(j)*evplk)
         if (lambda.ge.1000.d0) then
           if (lambda.le.50000.d0) then
             if (tp1(j).gt.0.d0) then
               lambda=lambda/fnair(lambda)
               write (lunt,20) lambda,tp1(j),tp2(j),tp3(j),tp4(j)
             endif
           endif
         endif
c
       enddo
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      close (lunt)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wrspec (caller, pfx, np, t, de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t,de,dh
      integer*4 np
      character* (*) caller
      character pfx*32
c
      integer*4 lunt
c
      character fsp*64
      character fn*64, sfx*4
      character linemod*4, spmod*4
c
      lunt=99
c
      fn=' '
      sfx='csv'
      call newfile (pfx, np, sfx, 3, fn)
      fsp=fn(1:(np+3+5))
      open (lunt,file=fsp,status='NEW')
   10 format(
     &'::::::::::::::::::::::::::::::::::::'
     &,'::::::::::::::::::::::::::::::::::::',/
     & ' Spectrum File, MAPPINGS V ',a12,/
     &'::::::::::::::::::::::::::::::::::::'
     &,'::::::::::::::::::::::::::::::::::::',/
     &,t5,' Run   : ,',a)
      write (lunt,10) theversion,runname
   20  format('%::::::::::::::::::::::::::'/
     &'% TEMP.       :,' ,1pe11.4/'% H DENSITY   :,' ,1pe11.4/
     &'% ELECTR. DENS:,' ,1pe11.4/'% ION DENSITY :,' ,1pe11.4/
     &'%::::::::::::::::::::::::::')
      write (lunt,20) t,dh,de,zen
      write (lunt,*) 'Produced by ',caller
      spmod='REL'
      linemod='LAMB'
      call spec2 (lunt, linemod, spmod)
      close (lunt)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine wrsppop (lunt)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO OUTPUT ON MEDIUM*lunt  THE EMISSION SPECTRUM AND
c    THE AVERAGE TEMPERATURES AND IONIC POPULATIONS
c    CALL SUBROUTINE SPECTRUM
c
c
c     modified for var  able numbers of elemnts and ionisation stages
c
c     RSS 8/90
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 achh,dhas,dhtt
      integer*4 lunt
      character mode*4
c
c     FOR population total calculation
c      real*8 popintot(mxion, mxelem)
c      integer*4 i,j
c
c           Functions
c
      real*8 densnum,favcha
c
      achh=favcha(pam)
      dhtt=densnum(1.d0)
      dhas=deav/((dhtt*achh)+epsilon)
      write (lunt,10) zgas
c
c
   10 format(/' ',t9,'Abundances of the elements relative',
     &' to Hydrogen and their average state of ionisation :','  (Zgas='
     &,f7.4,' Zsun)'/)
      call wionabal (lunt, pam)
c
c
      write (lunt,20)
   20 format(/' ',t9,'Average distances for a given state ',
     &'of ionisation :'/)
c
      call wionpop (lunt, rdisa)
c
c
      write (lunt,30)
   30 format(/' ',t9,'Average ionic temperatures :'/)
c
      call wionpop (lunt, teav)
c
      write (lunt,40)
   40 format(/' ',t9,'Integrated column densities:'/)
c
      call wionpop (lunt, popint)
c
c
      write (lunt,50) deav,dhas,achh,dhtt
   50 format(/,' ',t9,'Average ionic electron dens. :',2x,'<ne>='
     & ,1pe10.3,3x,'<nH>=',1pe10.3,3x,'<CHARGE>=',1pe10.3,3x,'num/H :'
     & ,1pe11.4,/)
c
      call wionpop (lunt, deam)
c
      write (lunt,60)
   60 format(/' ',t9,
     &        'Legacy Fit Line Flux Weighted averaged quantities :')
      write (lunt,70)
   70 format(' ',t11,
     &       '<T>NII',t21,'<ne>NII',t31,'<T>OIII',t41,'<ne>OIII')
      write (lunt,80) tnii,denii,toiii,deoiii
   80 format(' ',t8,2(0pf10.0,1pe10.3)/)
c
      write (lunt,90)
   90 format(' ',t9,'Photon field averaged quantities :'/)
      write (lunt,100)
  100 format(' ',t11,'<ZETAE>',t21,'<QHDH>'/)
      write (lunt,110) zetaeav,qhdha
  110 format(' ',t8,2(1pe10.3)/)
c
c    ***OUTPUT EMISSION SPECTRUM RELATIVE TO H-BETA
c
      mode='REL'
c
      call spectrum (lunt, mode)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
