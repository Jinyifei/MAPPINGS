cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     MAPPINGS V.  An Astrophysical Plasma Modelling Code.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Modelling And Prediction in PhotoIonised Nebulae & Gasdynamical Shocks
c M         A   P             P    I       N         G            S
c
c Developed from 1975 mainly at Mt. Stromlo Stromlo and Siding Spring
c Observatories, Institute of Advanced Studies, The Australian National
c University.
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
c       Version v5.1.21rss
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     1975 Ralph Sutherland, Michael Dopita, Luc Binette,
c     Ian Evans, Stephen Mettheringham
c     Brent Groves, David Nicholls,
c     Jin Yi-Fei, Adam D. Thomas,
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Unless otherwise noted for externally sourced public domain code
c
c     Research School of Astronomy & Astrophysics
c     Mount Stromlo Observatory
c     The Australian National University
c     Canberra, Australia
c
c     email:
c     Ralph.Sutherland@anu.edu.au
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      program mappings
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      character ilgg*4, modeltype*12
      character abundtitle*24
      logical initerr
c
      theversion='v5.1.21rss'
c
   10 format(/,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & /
     & '  Welcome to MAPPINGS V ',a12,/
     & /
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,10) theversion
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     call the initialsation routine to read datafiles etc...
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
      initerr=.false.
      call mapinit (initerr)
      if (initerr) goto 90
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (photonmode.eq.0) then
        write (*,*) ' ***********************************************'
        write (*,*) ' *                                             *'
        write (*,*) ' *   WARNING: PHOTON FIELD DISABLED.           *'
        write (*,*) ' *                                             *'
        write (*,*) ' ***********************************************'
      endif
      if ((photofraction.gt.0.d0).and.(photofraction.lt.1.d0)) then
        write (*,*) ' ***********************************************'
        write (*,*) ' *                                             *'
        write (*,*) ' *   WARNING: PARTIAL PHOTON FIELD ENABLED.    *'
        write (*,*) ' *                                             *'
        write (*,*) ' ***********************************************'
      endif
c
      if (alphacoolmode.eq.1) then
        write (*,*) ' ***********************************************'
        write (*,*) ' *                                             *'
        write (*,*) ' *   WARNING: POWERLAW COOLING ENABLED.        *'
        write (*,*) ' *                                             *'
        write (*,*) ' ***********************************************'
c
      endif
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     begin interactive initialisation and then subroutine selector...
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   20 format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & '  Elemental Abundances:'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
   30 write (*,20)
c
      grainmode=0
c
c    ***CHANGE ELEMENTAL ABUNDANCES ?
c      FINDS ZGAS RELATIVE TO THE SUN
c
      call abecha
c
c read in an optional abundance offsets file
c
      call deltaabund
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     *** Setup electron distributions
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call kappainit
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     *** Setup dust grain properties
c
c     Now available (averages over all grainsizes)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      call grainpar
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c    ***SELECT A PROGRAM
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
   40  format(/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & '  MAPPINGS V: End of General Initialisation'/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/)
      write (*,40)
      abundtitle=' Final Gas Abundances :'
      call dispabundances (6, zion, abundtitle)
      modeltype=' '
      if (usekappa) then
        if (grainmode.eq.1) then
          modeltype='Dust, Kappa'
        else
          modeltype='Kappa On'
        endif
      else
        if (grainmode.eq.1) then
          modeltype='Dust Enabled'
        else
          modeltype=' '
        endif
      endif
c
   50 write (*,60) theversion,modeltype
      write (*,70)
   60 format(//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & '  MAPPINGS V ',a12,': Models : ',a,/)
   70  format(
     & ' :::::::::::: Photoionisation Multizone Models ::::::::::'/
     & '    P6  :  Photoionisation, dust + Robust Integrator'/
     & '    P7  :  P6 + Experimental routines and API'//
     & ' :::::::::::: Shockwave and Precursor Models ::::::::::::'/
     & '    S5  :  Shockwaves, adaptive mesh, auto-preionisation'//
     & ' :::::::::::: Single Zone Models ::::::::::::::::::::::::'/
     & '    SS  :  Single slab models'/
     & '    CC  :  CIE Cooling curves'/
     & '    NC  :  NEQ Cooling curves'/
     & '    PP  :  PIE Photoionization curves'//
     & ' :::::::::::: Test Atom Models ::::::::::::::::::::::::::'/
     & '    MM  :  Multi-Level Ion Emissivity'/
     & '    CD  :  Multi-Level Ion 2 level Critical Densities'/
     & '    TE  :  Multi-Level Ion 3 level Te Ratios'//
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & '    R   :  Reinitialise'/
     & '  E,X,Q :  Exit'/
     & ' :: ',$)
c
      read (*,80) ilgg
   80 format(a)
      call toup (ilgg(1:2), ilgg)
c
c clear up any gobbled line feeds...
c
      write (*,*)
c
c     X for exit as well
c
      if (ilgg(1:1).eq.'X') ilgg(1:1)='E'
      if (ilgg(1:1).eq.'x') ilgg(1:1)='E'
c
c     Q for exit as well
c
      if (ilgg(1:1).eq.'Q') ilgg(1:1)='E'
      if (ilgg(1:1).eq.'q') ilgg(1:1)='E'
c
c    ***ZERO BUFFER ARRAYS AND RESET COUNTERS
c
      call zer
c
      runname='Test Run'
c
      if (ilgg(1:2).eq.'S4') call shock4
      if (ilgg(1:2).eq.'S5') call shock5
c
c     if (ilgg(1:2).eq.'P4') call photo4
      if (ilgg(1:2).eq.'P5') call photo5
      if (ilgg(1:2).eq.'P6') call photo6
      if (ilgg(1:2).eq.'P7') call photo7
      if (ilgg(1:1).eq.'E') goto 110
      if (ilgg(1:1).eq.'R') goto 30
      if (ilgg(1:2).eq.'CC') call coolc
      if (ilgg(1:2).eq.'NC') call neqc
      if (ilgg(1:2).eq.'MM') call ionemit
      if (ilgg(1:2).eq.'CD') call critdens
      if (ilgg(1:2).eq.'TE') call tempratios
      if (ilgg(1:2).eq.'SS') call slab
      if (ilgg(1:2).eq.'PP') call phocrv
c
c
      goto 50
c
c error message
c
   90 continue
      write (*,100)
  100 format(/,' ERROR: Failed to Initialise. Immediate Exit.',/)
  110 continue
c
  120 format(//,
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',/
     & '  MAPPINGS V: Session Ended. ',/
     & ' ::::::::::::::::::::::::::::::::::::::::::::::::::::::::',//)
      write (*,120)
      stop
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
