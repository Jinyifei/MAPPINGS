cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.txt'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine iobal (mod, nel, de, dh, xhy, t, tstep)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     version 2.2, extended ionisation stages
c     Vector subsampling optimisation
c     rationalised loops
c     new charge exchange
c
c     RSS 4/91
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******DERIVES IONIC ABUNDANCES AFTER TIME : TSTEP
c     FOR THE ATOMIC ELEMENTS HEAVIER THAN HYDROGEN .
c     RETURNS RESULTS IN POP(6,11) AND DERIVATIVES IN DNDT(6,11)
c
c     WHEN ARGUMENT MOD SET TO 'EQUI' ,IT MAKES SURE THAT THE
c     SYSTEM REACHES EQUILIBRIUM (TSTEP IRRELEVANT)
c     THE ARGUMENT NEL DETERMINE IF IT COMPUTES FOR ALL ELEMENTS
c     OR ONLY FOR HELIUM .
c
c     THE AVERAGE ELECTRONIC DENSITY : DE  MUST BE GIVEN AS WELL
c     AS THE FRACTIONAL IONISATION OF HYDROGEN : XHY (OR POP2,1))
c     DEFAULT VALUE (USING POP(2,1)) ASSIGNED TO XHY IF SET TO -1
c     CALL SUBROUTINES SDIFEQ,ALLRATES,SPOTAP,IONAB,IONSEC
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 abio,abne,de2,dep,dey,dpio,drec,dyn
      real*8 fhi,fhii
      real*8 ph,ph2,sigab,timt,yh
      real*8 de, dh, xhy, t, tstep
c
      real*8 reco(mxion), pion(mxion), ab(mxion), adndt(mxion)
      real*8 pionau(mxion),rech(mxion),pich(mxion)
      real*8 rc(mxion), pn(mxion), a(mxion), adnt(mxion), pa(mxion)
c
      integer*4 i,idx,ies,j,jdo,ji,jjj
      integer*4 nom,mnde,nde,mxde,mdelta,ion,at
c
      character jjmod*4, mod*4, nel*4
c
c           Functions
c
      real*8 feldens
c
      if (mod.eq.'EQUI') then
        timt=1.d37
      else
        timt=tstep
        if (timt.lt.0.0d0) then
          write (*,10)
   10         format(/' STOP : NEGATIVE TIME STEP'//)
          stop
        endif
      endif
c
      fhii=pop(2,1)
      fhi=pop(1,1)
      if ((xhy.lt.0.0d0).or.(xhy.gt.1.0d0)) goto 20
      fhii=xhy
      fhi=1.0d0-xhy
   20 continue
c
c
c    ***COMPUTES NEW RATES IF TEMP. OR PHOTON FIELD HAVE CHANGED
c
      jjmod='ALL'
      call allrates (t, jjmod)
c
c
c    ***CALCULATE RATES DUE TO SECONDARY IONISATION
c
      call ionsec
c
      dyn=1.d12
c      dyn = 1.d10
      jjj=atypes
      if (nel.eq.'HE') jjj=2
c
      do 100 idx=2,jjj
        if (zion(idx).le.0.0d0) goto 100
        nde=maxion(idx)
        nom=0
        jdo=1
c
c    ***SET INITIAL ABUNDANCES IN AB(6) FOR ELEMENT : IEL
c
        do i=1,nde
          ab(i)=pop(i,idx)*zion(idx)*dh
        enddo
c
c     reentry point.
c
c
        do i=1,mxion
   30     rech(i)=0.d0
          pich(i)=0.d0
          reco(i)=0.d0
          pion(i)=0.d0
          pionau(i)=0.d0
        enddo
c
c    ***SET POPULATION RATES FOR EACH IONIC SPECIES OF ELEM : IEL
c
        do i=2,nde
          reco(i-1)=rec(i,idx)*de
        enddo
c
c    ***SET DEPOPULATION RATES FOR EACH IONIC SPECIES OF ELEM : IEL
c
        do i=1,nde-1
          pion(i)=rphot(i,idx)+(col(i,idx)*de)
        enddo
c
c     Auger rates, off diagnal terms.
c
        do i=1,nde-2
          pionau(i)=auphot(i,idx)
        enddo
c
c    ***ADD CORRECTION DUE TO SECONDARY IONISATION
c
        do i=1,min0(3,nde-1)
          pion(i)=pion(i)+rasec(i,idx)
        enddo
c
c    ***ADD CHARGE EXCHANGE RATES WITH HYDROGEN
c
        if (chargemode.eq.2) then
c
c     ancient mappings charge rates
c
          do 50 j=1,nchxold
            if (idint(charte(1,j)).ne.idx) goto 50
            ji=idint(charte(2,j))
            if (reco(ji).le.0.0d0) goto 50
c
c     abne = abund of neutral H or He
c     abio = abund of single ionised H or He
c
c     He III not considered
c
c
            ies=idint(charte(5,j))
            abne=(dh*zion(ies))*pop(1,ies)
            abio=(dh*zion(ies))*pop(2,ies)
            drec=abne*charte(4,j)
            dpio=abio*charte(3,j)
c
            rech(1)=reco(ji)+drec
            pich(1)=pion(ji)+dpio
c
c      *COMPRESS RECH TO FIT INTO DYNAMIC RANGE (IF NECESSARY)
c
            if (reco(ji).ge.(rech(1)/dyn)) goto 40
            if ((mod.eq.'EQUI').and.(nom.lt.1)) then
              jdo=2
              goto 50
            endif
            reco(ji)=reco(ji)*dyn
            pion(ji)=pich(1)*(reco(ji)/rech(1))
c
            goto 50
   40       pion(ji)=pich(1)
            reco(ji)=rech(1)
   50     continue
c
        endif
c
c     end old reactions
c
        if (chargemode.eq.1) then
c
c     Legacy AR1985 Rates
c     First, recombination reactions
c     with neutral H and He
c
          do at=1,nlegacychxr
c
c     abne = abund of neutral H or He
c     abio = abund of single ionised H or He
c
c
            if (chxrlegacyat(at).eq.idx) then
              if (chxrlegacy(at).gt.0.d0) then
                ies=chxrlegacyx(at)
                ion=chxrlegacyio(at)-1
                abne=dh*zion(ies)*pop(1,ies)
                drec=abne*chxrlegacy(at)
                rech(ion)=rech(ion)+drec
              endif
            endif
c
c     end at
c
          enddo
c
c     Ionising reactions
c     with ionised H and He
c
c
          do at=1,nlegacychxi
c
c     abne = abund of neutral H or He
c     abio = abund of single ionised H or He
c
c
            if (chxilegacyat(at).eq.idx) then
              if (chxilegacy(at).gt.0.d0) then
                ies=chxilegacyx(at)
                ion=chxilegacyio(at)
                abio=(dh*zion(ies))*pop(2,ies)
                dpio=abio*chxilegacy(at)
                pich(ion)=pich(ion)+dpio
              endif
            endif
c
c     end at
c
          enddo
c
c     renormalise to fit dynamic range
c
          do ion=1,maxion(idx)
c
            rech(ion)=reco(ion)+rech(ion)
            pich(ion)=pich(ion)+pion(ion)
c
            if (reco(ion).ge.(rech(ion)/dyn)) goto 60
            if ((mod.eq.'EQUI').and.(nom.lt.1)) then
              jdo=2
              goto 70
            endif
            reco(ion)=reco(ion)*dyn
            pion(ion)=pich(ion)*(reco(ion)/rech(ion))
c
            goto 70
   60       pion(ion)=pich(ion)
            reco(ion)=rech(ion)
   70       continue
          enddo
c
        endif
c
        if (chargemode.eq.0) then
c
c     New Kingdon Rates
c     First, recombination reactions
c     with neutral H and He
c
          do at=1,nchxr
c
c     abne = abund of neutral H or He
c     abio = abund of single ionised H or He
c
c
            if (chxrat(at).eq.idx) then
              if (chxr(at).gt.0.d0) then
                ies=chxrx(at)
                ion=chxrio(at)-1
                abne=dh*zion(ies)*pop(1,ies)
                drec=abne*chxr(at)
                rech(ion)=rech(ion)+drec
              endif
            endif
c
c     end at
c
          enddo
c
c     Ionising reactions
c     with ionised H and He
c
c
          do at=1,nchxi
c
c     abne = abund of neutral H or He
c     abio = abund of single ionised H or He
c
c
            if (chxiat(at).eq.idx) then
              if (chxi(at).gt.0.d0) then
                ies=chxix(at)
                ion=chxiio(at)
                abio=(dh*zion(ies))*pop(2,ies)
                dpio=abio*chxi(at)
                pich(ion)=pich(ion)+dpio
              endif
            endif
c
c     end at
c
          enddo
c
c     renormalise to fit dynamic range
c
          do ion=1,maxion(idx)
c
            rech(ion)=reco(ion)+rech(ion)
            pich(ion)=pich(ion)+pion(ion)
c
            if (reco(ion).ge.(rech(ion)/dyn)) goto 80
            if ((mod.eq.'EQUI').and.(nom.lt.1)) then
              jdo=2
              goto 90
            endif
            reco(ion)=reco(ion)*dyn
            pion(ion)=pich(ion)*(reco(ion)/rech(ion))
c
            goto 90
   80       pion(ion)=pich(ion)
            reco(ion)=rech(ion)
   90       continue
          enddo
c
c     end char exchange rates
c
        endif
c
c
c    ***ALTER RECOMB. RATES FOR HE WHEN ON THE SPOT APPROX. USED
c
        if ((jspot.eq.'Y').and.(idx.eq.zmap(2))) then
c
          call spotap (de, dh, fhi, t, yh, ph, ph2, dey, dep, de2)
          reco(1)=reco(1)-((de*(1.0d0-yh))*(rec(2,2)-rec(4,2)))
          reco(2)=reco(2)-(de*(rec(3,2)-rec(5,2)))
c
        endif
c
c    ***COMPUTES NEW IONIC ABUNDANCES FOR ELEMENT : IEL
c
c     first calculation done in full
c
c      if (nom.eq.0) then
c
c
c      call ionab(reco, pion, pionau, ab, adndt, nde, timt)
c
c      else
c
c
c      if (mapz(idx).eq.2) then
c         write(*,*) 'Helium rates (t,de,dh):',t,de,dh
c         do i = 1,nde
c            write(*,*) rom(i),pion(i),reco(i)
c         enddo
c      endif
c
        mnde=1
        mxde=2
c
c     find max and min ionisation stages that matter
c
c
        do i=1,nde
          if (pop(i,idx).ge.1.d-6) mxde=i
          if (pop(nde-i+1,idx).ge.1.d-6) mnde=nde-i+1
          if (pion(i).gt.0.d0) then
            if (reco(i)/pion(i).lt.1.d3) mxde=i
          endif
          if (pionau(i).gt.0.d0) then
            if (reco(i)/pionau(i).lt.1.d3) mxde=i
          endif
c
c     pull up the minimun, esp for Nickel and Iron with their
c     fairly flat rates
c
c            if (reco(nde-i+1).gt.0.d0) then
c               if (pion(nde-i+1)/reco(nde-i+1).lt.1.d3) mnde = nde-i+1
c            endif
        enddo
c
        mxde=min0(mxde+1,nde)
        mnde=max0(mnde-1,1)
c
c         if  (idx.eq.2) write(*,*) elem(idx),mnde,mxde
c         write(*,*) 'Min rates:',pion(mnde),reco(mnde)
c         write(*,*) 'Max rates:',pion(mxde),reco(mxde)
c         write(*,*) 'min/max pops:',pop(mnde,idx),pop(mxde,idx)
c
        mdelta=mxde-mnde+1
c
c     copy section into ab
c
        sigab=0.d0
        do i=1,mdelta
          a(i)=ab(i+mnde-1)
          sigab=sigab+pop(i+mnde-1,idx)
          pn(i)=pion(i+mnde-1)
          rc(i)=reco(i+mnde-1)
          pa(i)=pionau(i+mnde-1)
        enddo
        if (sigab.le.0.99d0) then
          write (*,*) 'IOBAL VECTOR SAMPLING OPT. FAILED'
          write (*,*) 'Significant population missed:',1.d0-sigab
          write (*,*) elem(idx),'min:',mnde,'Max:',mxde
          do i=1,maxion(idx)
            write (*,*) i,pop(i,idx),ab(i),pion(i),reco(i),pionau(i)
          enddo
          stop
        endif
c
c     do ionab with shortened vector
c
        call ionab (rc, pn, pa, a, adnt, mdelta, timt)
c
c     copy results back into their correct positions
c
        do i=1,mdelta
          adndt(i+mnde-1)=adnt(i)
          ab(i+mnde-1)=a(i)
        enddo
c
        if (mnde.gt.1) then
          do i=1,mnde-1
            adndt(i)=0.0d0
            ab(i)=0.0d0
          enddo
        endif
c
        if (mxde.lt.maxion(idx)) then
          do i=mxde+1,maxion(idx)
            adndt(i)=0.d0
            ab(i)=0.0d0
          enddo
        endif
c
c
c     endif
c
c    ***CHECK IF IT HAS TO RE-DO COMPUTATION TO REACH EQUILIBRIUM
c
        nom=nom+1
        if ((mod.eq.'EQUI').and.(nom.lt.jdo)) goto 30
c
c    ***COPY FINAL IONIC POPULATIONS AND TIME DERIVATIVE FOR EL. IEL
c
        do i=1,nde
          dndt(i,idx)=adndt(i)
          pop(i,idx)=(ab(i)/(dh*zion(idx)))
          if (pop(i,idx).lt.pzlimit) then
            pop(i,idx)=0.d0
            dndt(i,idx)=0.d0
          endif
        enddo
c
  100 continue
c
c
c    ***UPDATES ELECTRONIC DENSITY
c
      de=feldens(dh,pop)
c
      return
      end
