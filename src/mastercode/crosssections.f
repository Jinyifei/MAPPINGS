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
      subroutine crosssections (inl, tauso, sigmat)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c tauso is the integrated optical depth back to the source
c sigmat, and dustsigmat are the local crossections per H atom
c for the current zone
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 tauso,sigmat
      integer*4 i,inl
      integer*4 ion,atom
      real*8 pz,crosec,colden
c
      tauso=0.d0
      sigmat=0.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c     ***DERIVES ABSORPTION CROSS-SECTION FOR BIN#INL
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (inl.lt.ionstartbin) return
c
        do i=1,ionum
          if (inl.ge.photbinstart(i)) then
               atom=atpho(i)
               ion=ionpho(i)
               pz=zion(atom)*pop(ion,atom)
               colden=popint(ion,atom)
               if ((pz.gt.pzlimit).or.(colden.gt.1.0d10)) then
               crosec=photxsec(i,inl)
               sigmat=sigmat+(pz*crosec)
               tauso=tauso+(colden*crosec)
               endif
          endif
        enddo
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine crosssectionsdust (inl, tauso, sigmat, dustsigmat)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c tauso is the integrated optical depth back to the source
c sigmat, and dustsigmat are the local crossections per H atom
c for the current zone
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 tauso,sigmat,dustsigmat
      integer*4 i,inl,dtype,m
      integer*4 ion,atom
      real*8 pz,crosec,colden
c
      tauso=0.d0
      sigmat=0.d0
      dustsigmat=0.d0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c     ***DERIVES ABSORPTION CROSS-SECTION FOR BIN#INL
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      if (inl.ge.ionstartbin) then
        do i=1,ionum
          if (inl.ge.photbinstart(i)) then
               atom=atpho(i)
               ion=ionpho(i)
               pz=zion(atom)*pop(ion,atom)
               colden=popint(ion,atom)
               if ((pz.gt.pzlimit).or.(colden.gt.1.0d10)) then
               crosec=photxsec(i,inl)
               sigmat=sigmat+(pz*crosec)
               tauso=tauso+(colden*crosec)
               endif
          endif
        enddo
      endif
c
      if (grainmode.le.0) return
c
c
c   Dust Cross-section
c
c
c   pahs
      if (pahactive.eq.1) then
        do m=1,pahi
          if (pahion(m).gt.0) then
            crosec=pahiext(inl)*pahfrac
          else
            crosec=pahnext(inl)*pahfrac
          endif
          tauso=tauso+pahint(m)*crosec
          sigmat=sigmat+pahz(m)*crosec
        enddo
      endif
c
c   dust grains
      if (clinpah.eq.0) then
        do dtype=1,numtypes
          crosec=dcrosec(inl,dtype)
          tauso=tauso+dustint*crosec
          sigmat=sigmat+crosec
          dustsigmat=dustsigmat+crosec
        enddo
      else
        if (pahactive.eq.1) then
          crosec=dcrosec(inl,1)
          do m=1,pahi
            tauso=tauso+pahint(m)*crosec
          enddo
          sigmat=sigmat+crosec
          dustsigmat=dustsigmat+crosec
        endif
        do dtype=2,numtypes
          crosec=dcrosec(inl,dtype)
          tauso=tauso+dustint*crosec
          sigmat=sigmat+crosec
          dustsigmat=dustsigmat+crosec
        enddo
      endif
c
      return
      end
