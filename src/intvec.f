cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.txt'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine intvec
c! XXXX - add one line purpose here
c! @param [in,out]   real*8    bufpho  XXX-meaning
c! @param [in,out]   real*8      qahi  XXX-meaning
c! @param [in,out]   real*8     qahei  XXX-meaning
c! @param [in,out]   real*8    qaheii  XXX-meaning
c! @param [in,out]   real*8     qatot  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine intvec (bufpho, qahi, qahei, qaheii, qatot)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******INTEGRATES ARRAY BUFPHO THAT CONTAINS THE LOCAL MEAN INTENS.
c   JNU TO DERIVE THE AVAILABLE NUMBER OF PHOTONS TO IONISE H,HE
c   (HENCE INTEGRATES 4PI*JNU/HNU)
c   NB.  BUFPHO MUST BE DEXPRESSED IN Jnu (1/4pi)
c   CALL SUBR. INTERPOL
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 bufpho(mxinfph)
      real*8 qahi, qahei, qaheii, qatot
      real*8 phq(2, 2)
      real*8 wid,q
c
      integer*4 i, j, inl
c
      do i=1,2
        do j=1,2
          phq(j,i)=0.d0
        enddo
      enddo
c
      do inl=1,infph-1
        if (bufpho(inl).gt.epsilon) then
          wid=widbinnu(inl)
          q=fpi*(wid*bufpho(inl)/cphote(inl))
          do i=1,2
            do 10 j=1,maxion(i)-1
              if (cphote(inl).lt.ipote(j,i)) goto 10
              phq(j,i)=phq(j,i)+q
   10       continue
          enddo
        endif
      enddo
c
      qaheii=phq(2,2)
      qahei=dmax1(0.d0,phq(1,2)-phq(2,2))
      qahi=dmax1(0.d0,phq(1,1)-phq(1,2))
c
      qatot=phq(1,1)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine intinu
c! XXXX - add one line purpose here
c! @param [in,out]   real*8    inupho  XXX-meaning
c! @param [in,out]   real*8      qahi  XXX-meaning
c! @param [in,out]   real*8     qahei  XXX-meaning
c! @param [in,out]   real*8    qaheii  XXX-meaning
c! @param [in,out]   real*8     qatot  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine intinu (inupho, qahi, qahei, qaheii, qatot)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 inupho(mxinfph)
      real*8 qahi, qahei, qaheii, qatot
      real*8 phq(2, 2)
      real*8 widnu,q
c
      integer*4 i, j, inl
c
      do i=1,2
        do j=1,2
          phq(j,i)=0.d0
        enddo
      enddo
c
      do inl=1,infph-1
        if (inupho(inl).gt.epsilon) then
          widnu=widbinnu(inl)
c 1/pi Inu
          q=pi*(widnu*inupho(inl)/cphote(inl))
          do i=1,2
            do 10 j=1,maxion(i)-1
              if (cphote(inl).lt.ipote(j,i)) goto 10
              phq(j,i)=phq(j,i)+q
   10       continue
          enddo
        endif
      enddo
c
      qaheii=phq(2,2)
      qahei=dmax1(0.d0,phq(1,2)-phq(2,2))
      qahi=dmax1(0.d0,phq(1,1)-phq(1,2))
c
      qatot=phq(1,1)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine intjnu
c! XXXX - add one line purpose here
c! @param [in,out]   real*8    inupho  XXX-meaning
c! @param [in,out]   real*8      qahi  XXX-meaning
c! @param [in,out]   real*8     qahei  XXX-meaning
c! @param [in,out]   real*8    qaheii  XXX-meaning
c! @param [in,out]   real*8     qatot  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine intjnu (inupho, qahi, qahei, qaheii, qatot)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c           Variables
c
      real*8 inupho(mxinfph)
      real*8 qahi, qahei, qaheii, qatot
      real*8 phq(2, 2)
      real*8 widnu,q
c
      integer*4 i, j, inl
c
      do i=1,2
        do j=1,2
          phq(j,i)=0.d0
        enddo
      enddo
c
      do inl=1,infph-1
        if (inupho(inl).gt.epsilon) then
          widnu=widbinnu(inl)
c 1/4pi Jnu
          q=fpi*(widnu*inupho(inl)/cphote(inl))
          do i=1,2
            do 10 j=1,maxion(i)-1
              if (cphote(inl).lt.ipote(j,i)) goto 10
              phq(j,i)=phq(j,i)+q
   10       continue
          enddo
        endif
      enddo
c
      qaheii=phq(2,2)
      qahei=dmax1(0.d0,phq(1,2)-phq(2,2))
      qahi=dmax1(0.d0,phq(1,1)-phq(1,2))
c
      qatot=phq(1,1)
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine jnulum
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        sp  XXX-meaning
c! @param [in,out]   real*8      blum  XXX-meaning
c! @param [in,out]   real*8      ilum  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine jnulum (sp, blum, ilum)
c     quicksum 1/4pi Jnu vector
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        include 'cblocks.inc'
c
        real*8 sp(mxinfph)
        real*8 blum, ilum
        real*8 widnu
        integer*4 i
c
      blum=0.d0
      ilum=0.d0
c
      do i=1,infph-1
        widnu=widbinnu(i)
        blum=blum+sp(i)*widnu
        if (photev(i).ge.iph) ilum=ilum+sp(i)*widnu
      enddo
c
      blum=fpi*blum
      ilum=fpi*ilum
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine inulum
c! XXXX - add one line purpose here
c! @param [in,out]   real*8        sp  XXX-meaning
c! @param [in,out]   real*8      blum  XXX-meaning
c! @param [in,out]   real*8      ilum  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine inulum (sp, blum, ilum)
c     quicksum 1/pi inu vector
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
        include 'cblocks.inc'
c
        real*8 sp(mxinfph)
        real*8 blum, ilum
        real*8 widnu
        integer*4 i
c
      blum=0.d0
      ilum=0.d0
c
      do i=1,infph-1
        widnu=widbinnu(i)
        blum=blum+sp(i)*widnu
        if (photev(i).ge.iph) ilum=ilum+sp(i)*widnu
      enddo
c
      blum=pi*blum
      ilum=pi*ilum
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
