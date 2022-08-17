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
      subroutine coloss (de, dh)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO FIND COLLISIONAL IONISATION COOLING RATE
c     COLOS (ERG.CM-3.S-1)
c     rates setup in allrates
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      integer*4 atom, ion
      real*8 de, dh, pz, cl
c
      colos=0.0d0
c
      if (linecoolmode.eq.1) return
c
      do atom=1,atypes
        do ion=1,maxion(atom)-1
          pz=zion(atom)*pop(ion,atom)
          if (pz.ge.pzlimit) then
            cl=col(ion,atom)*ipote(ion,atom)*pz*de*dh
            colos=colos+cl
            coolz(atom)=coolz(atom)+cl
            coolzion(ion,atom)=coolzion(ion,atom)+cl
          endif
        enddo
      enddo
c
      if (colos.lt.epsilon) colos=0.d0
c
      return
      end
