cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.inc'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
<<<<<<< HEAD:src/mastercode/coloss.f
c       MAPPINGS V.  An Astrophysical Plasma Modelling Code.
c
c
c     Creative Commons v4.0 International
c     By Attribution, Share Alike
c     CC-BY-SA-4.0Intl https://creativecommons.org
c     1976 -- 2022+ Ralph Sutherland,
c     Michael Dopita, Luc Binette, Ian Evans,
c     Brent Groves, David Nicholls,
c     Adam D. Thomas, Yi-Fei Jin
c
c
c       Version v5.1.21
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
=======

c****************************************************************
c> @brief The subroutine coloss
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        de  XXX-meaning
c! @param [in,out]   real*8        dh  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

>>>>>>> dev:src/coloss.f
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
