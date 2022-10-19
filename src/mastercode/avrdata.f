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
c     Adam D. Thomas, Yi-Fei Jin
c
c
c       Version v5.1.21
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine avrdata ()
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO OBTAIN THE AVERAGE TEMP. , IONIC POP.,DENSITIES AND
c       LINE INTENSITIES USING SUM DATA IN  : /SLINE/,/TONLIN/
c       AND /DELIN/
c       CALL SUBR. FINDTDE
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c
      real*8 rno,invbeta
      integer*4 i,j,line,series
c
c    ***AVERAGES IONIC POP,TEMP.,DISTANCES AND DENSITIES
c
      rno=1.d17
      do j=1,atypes
        do i=1,maxion(j)
          teav(i,j)=teav(i,j)/(epsilon+pam(i,j))
          deam(i,j)=deam(i,j)/(epsilon+pam(i,j))
          rdisa(i,j)=(rdisa(i,j)/(epsilon+pam(i,j)))*rno
          pam(i,j)=pam(i,j)/(epsilon+deav)
        enddo
      enddo
c
      deav=dhav/deav
      qhdha=qhdha/(epsilon+dhavv)
c
      zetaeav=zetaeav/(epsilon+dhavv)
      roiii=roiii/(epsilon+weoiii)
      deoiii=deoiii/(epsilon+weoiii)
      rnii=rnii/(epsilon+wenii)
      denii=denii/(epsilon+wenii)
      roii=roii/(epsilon+weoii)
      toii=toii/(epsilon+weoii)
      rsii=rsii/(epsilon+wesii)
      tsii=tsii/(epsilon+wesii)
c
c    ***FIND TNII,TOIII,DESII,DEOII
c
      call findtde
c
c    ***FORM RATIO OF EMISSION LINES RELATIVE TO  H-BETA
c
      invbeta=1.d0/(epsilon+fhbeta)
      do i=1,nfmions
        do j=1,nfmtrans(i)
          fluxm(j,i)=fluxm(j,i)*invbeta
        enddo
      enddo
c
      do i=1,nfeions
        do j=1,nfetrans(i)
          fluxfe(j,i)=fluxfe(j,i)*invbeta
        enddo
      enddo
c
      do i=1,nf3ions
        do j=1,nf3trans
          fluxf3(j,i)=fluxf3(j,i)*invbeta
        enddo
      enddo
c
      do j=1,10
        fluxh(j)=fluxh(j)*invbeta
      enddo
      do j=1,nheilines
        fluxhei(j)=fluxhei(j)*invbeta
      enddo
      do j=1,nheislines
        fluxheis(j)=fluxheis(j)*invbeta
      enddo
      do j=1,nheitlines
        fluxheit(j)=fluxheit(j)*invbeta
      enddo
c CII
      do j=1,nrccii
        fluxrccii_a(j)=fluxrccii_a(j)*invbeta
        fluxrccii_b(j)=fluxrccii_b(j)*invbeta
      enddo
c NII
      do j=1,nrcnii
        fluxrcnii_a(j)=fluxrcnii_a(j)*invbeta
        fluxrcnii_b(j)=fluxrcnii_b(j)*invbeta
      enddo
c OI
      do j=1,nrcoi_q
        fluxrcoi_qa(j)=fluxrcoi_qa(j)*invbeta
        fluxrcoi_qb(j)=fluxrcoi_qb(j)*invbeta
      enddo
      do j=1,nrcoi_t
        fluxrcoi_ta(j)=fluxrcoi_ta(j)*invbeta
        fluxrcoi_tb(j)=fluxrcoi_tb(j)*invbeta
      enddo
c OII
      do j=1,nrcoii
        fluxrcoii_a(j)=fluxrcoii_a(j)*invbeta
        fluxrcoii_b(j)=fluxrcoii_b(j)*invbeta
        fluxrcoii_c(j)=fluxrcoii_c(j)*invbeta
      enddo
c
c NeII
c
      do j=1,nrcneii
        fluxrcneii_a(j)=fluxrcneii_a(j)*invbeta
        fluxrcneii_b(j)=fluxrcneii_b(j)*invbeta
      enddo
c
      heiioiiibfsum=heiioiiibfsum*invbeta
c
      do series=1,nhseries
        do line=1,nhlines
          hydroflux(line,series)=hydroflux(line,series)*invbeta
        enddo
      enddo
c
      do series=1,nheseries
        do line=1,nhelines
          heliflux(line,series)=heliflux(line,series)*invbeta
        enddo
      enddo
c
      do i=1,atypes
        do series=1,nxhseries
          do line=1,nxhlines
            xhydroflux(line,series,i)=xhydroflux(line,series,i)/
     &       (epsilon+fhbeta)
          enddo
        enddo
      enddo
c
c     do j=1,nlines
c       fluxr(j)=fluxr(j)*invbeta
c     enddo
c
      do j=1,mlines
        fluxi(j)=fluxi(j)*invbeta
      enddo
c
      do j=1,nxr3lines
        xr3lines_flux(j)=xr3lines_flux(j)*invbeta
      enddo
c
      do j=1,nxrllines
        xrllines_flux(j)=xrllines_flux(j)*invbeta
      enddo
c
      h2qav=h2qav*invbeta
      hei2qa=hei2qa*invbeta
      heii2qa=heii2qa*invbeta
c
      do i=1,atypes
        h2qflux(i)=h2qflux(i)*invbeta
      enddo
c
      return
      end
