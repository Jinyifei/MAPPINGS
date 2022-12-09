cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.inc'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine phion
c! XXXX - add one line purpose here
c! @param This routine has no parameters
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine phion ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******to calculate photoionisation rates in rphot(mxion, mxelem) ,
c     photoheating rates in heaph(5,28,16) and
c     basis for secondary ionisation in anr(2,28,16),wnr(2,28,16)
c
c     uses local mean intensity of radiation jnu contained
c     in vector : tphot     ( number of cross sections : ionum )
c     it multiplies jnu by 4pi and integrates the number of photons
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           variables
c
      real*8 augen,augerg,augt,dain
      real*8 daiau,daip,dait,e0,eau2,eau2ev,ed,etr
      real*8 cedge,nedge,oedge,hiedge
      real*8 wid,q,rr1
c
      integer*4 i,inl,n,atom,ion
      integer*4 oxie, niie, cbie
c
      parameter(cedge=2.80d+02)
      parameter(nedge=3.95d+02)
      parameter(oedge=5.33d+02)
      parameter(hiedge=1.32d+03)
c
c
c   **  eff(a,b,ed)=b+1.0/(ed/a+1.0/(1.0-b+1.0d-12))
c   **  coefficients a,b from shull,m.j. apj.234,p761 (1979)
c
      real*8 eff1, eff2, eff3, eff4, eff5
c
c
      eff1(ed)=1.0d0
      eff2(ed)=0.708d0+(1.0d0/((ed*0.03225806451612903d0)+
     &3.424657534246576d0))
      eff3(ed)=0.383d0+(1.0d0/((ed*0.0617283950617284d0)+
     &1.620745542949757d0))
      eff4(ed)=0.194d0+(1.0d0/((ed*0.1388888888888889d0)+
     &1.240694789081886d0))
      eff5(ed)=0.113d0+(1.0d0/((ed*0.3076923076923077d0)+
     &1.127395715896280d0))
c
c not params as will vary depending on map,prefs
c
      oxie=zmap(8)
      niie=zmap(7)
      cbie=zmap(6)
c
      eau2=30.0d0
      eau2ev=eau2*ev
      qtosoh=0.0d0
c
      do atom=1,atypes
        do ion=1,maxion(atom)
          rasec(ion,atom)=0.0d0
          auphot(ion,atom)=0.0d0
          rphot(ion,atom)=0.0d0
          do n=1,2
            anr(n,ion,atom)=0.0d0
            wnr(n,ion,atom)=0.0d0
            heaph(n,ion,atom)=0.0d0
          enddo
          do n=3,5
            heaph(n,ion,atom)=0.0d0
          enddo
        enddo
      enddo
cc
c in zero field mode there is no photoionsation
c
      if (photonmode.eq.0) return
c
c    if there is dust include atoms contained in dust above auger limit
c
c
      do inl=ionstartbin,infph-1
c
        if (tphot(inl).gt.epsilon) then
c
          e0=cphotev(inl)
          wid=widbinnu(inl)
          q=fpi*(wid*tphot(inl)/cphote(inl))
          if (e0.ge.iph) then
            qtosoh=qtosoh+q
          endif
c
c do i=1,ionum
c
          do i=1,ionum
c
c inl.ge.photbinstart(i)
c
            if (inl.ge.photbinstart(i)) then
c
              atom=atpho(i)
              ion=ionpho(i)
c
              augen=augpho(i)
              dain=q*photxsec(i,inl)
c
c if grain mode
c
              if (grainmode.ne.0) then
                if ((atom.eq.cbie).and.(e0.gt.cedge)) then
                  dain=dain*invdion(atom)
                elseif ((atom.eq.niie).and.(e0.gt.nedge)) then
                  dain=dain*invdion(atom)
                elseif ((atom.eq.oxie).and.(e0.gt.oedge)) then
                  dain=dain*invdion(atom)
                elseif ((mapz(atom).gt.8).and.(e0.gt.hiedge)) then
                  dain=dain*invdion(atom)
                endif
              endif
c
c if dain.gt.1.d-35
c
              if (dain.lt.1.d-36) dain=0.d0
              if (dain.gt.epsilon) then
                if (augen.le.0.0d0) then
                  rphot(ion,atom)=rphot(ion,atom)+dain
                else
                  auphot(ion,atom)=auphot(ion,atom)+dain
                endif
c
                daip=dain*(cphotev(inl)-ipotpho(i))*ev
c
                if (daip.gt.0.0d0) then
                  etr=ipotpho(i)
                  rr1=e0/etr
                  ed=dmax1(1.d-3,(((rr1*etr)+e0)*0.5d0)-(etr+10.2d0))
                  heaph(1,ion,atom)=heaph(1,ion,atom)+(eff1(ed)*daip)
                  heaph(2,ion,atom)=heaph(2,ion,atom)+(eff2(ed)*daip)
                  heaph(3,ion,atom)=heaph(3,ion,atom)+(eff3(ed)*daip)
                  heaph(4,ion,atom)=heaph(4,ion,atom)+(eff4(ed)*daip)
                  heaph(5,ion,atom)=heaph(5,ion,atom)+(eff5(ed)*daip)
                  dait=daip-(dain*iphe)
                  if (dait.ge.0.0d0) then
                    anr(1,ion,atom)=anr(1,ion,atom)+dait
                    wnr(1,ion,atom)=wnr(1,ion,atom)+dain
                    dait=daip-(dain*eau2ev)
                    if (dait.ge.0.0d0) then
                      anr(2,ion,atom)=anr(2,ion,atom)+dait
                      wnr(2,ion,atom)=wnr(2,ion,atom)+dain
                    endif
                  endif
                endif
c
                if (augen.gt.iph) then
                  augt=augen-10.2d0
                  augerg=augen*ev
                  daiau=dain*augerg
                  heaph(1,ion,atom)=heaph(1,ion,atom)+(eff1(augt)*daiau)
                  heaph(2,ion,atom)=heaph(2,ion,atom)+(eff2(augt)*daiau)
                  heaph(3,ion,atom)=heaph(3,ion,atom)+(eff3(augt)*daiau)
                  heaph(4,ion,atom)=heaph(4,ion,atom)+(eff4(augt)*daiau)
                  heaph(5,ion,atom)=heaph(5,ion,atom)+(eff5(augt)*daiau)
                  dait=dain*(augerg-iphe)
                  if (dait.ge.0.0d0) then
                    anr(1,ion,atom)=anr(1,ion,atom)+dait
                    wnr(1,ion,atom)=wnr(1,ion,atom)+dain
                    dait=dain*(augerg-eau2ev)
                    if (dait.ge.0.0d0) then
                      anr(2,ion,atom)=anr(2,ion,atom)+dait
                      wnr(2,ion,atom)=wnr(2,ion,atom)+dain
                    endif
                  endif
                endif
c
c if (dain.gt.1.d-35) then
c
              endif
c
c         if (inl.ge.photbinstart(i)) then
c
            endif
c
c       do i=1,ionum
c
          enddo
c
c       if (tphot(inl).gt.1.d0-50) then
c
        endif
c
c     do inl=ionstartbin,infph-1
c
      enddo
c
c     add cosmic ray ionization rate, crate, to neutral hydrogen
c     and helium
c     crate of order 10^-17, cosphi 0-0.75
c
c      if (crate.gt.0.d0) then
c      rphot(1,1)=rphot(1,1)+crate*(1.d0+cosphi)
c      rphot(1,2)=rphot(1,2)+crate*(1.d0+cosphi)
c      endif
c
c     do i=1,atypes
c       do j=1,maxion(i)
c         if (rphot(j,i).lt.1.d-35) rphot(j,i)=0.d0
c       enddo
c     enddo
c
      return
      end
