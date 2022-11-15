cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      include 'credits.txt'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

c****************************************************************
c> @brief The subroutine allrates
c! XXXX - add one line purpose here
c! @param [in,out]   real*8         t  XXX-meaning
c! @param [in,out]   real*8     jjmod  XXX-meaning
c!
c! @return
c!  XXXX Add one or more lines describing what is updated
c!
c! @details
c!  XXXX Enter details here
c***************************************************************

      subroutine allrates (t, jjmod)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO CALCULATE ALL ATOMIC RATES (RECOMBINATION,CHARGE EX.,
c                                    COLLIS. IONIS.,PHOTOIONISATION)
c     USES FLAGS TEM AND IPHOM TO DETERMINE IF PREVIOUS RATES
c     ARE STILL APPLICABLE.
c     (THE PHOTON FIELD IS CONSIDERED CHANGED WHENEVER SUBR. TOTPHOT
c      IS CALLED (IPHO IS RESET))
c
c     JJMOD = 'TEMP' TO CALCULATE ONLY TEMPERATURE DEPENDANT RATES
c     JJMOD = 'PHOT' TO CALCULATE ONLY PHOTOIONISATION/HEATING RATES
c     JJMOD = 'ALL'  TO CALCULATE BOTH TYPES
c
c     CALL SUBR. PHION,COLLION,CHAREX,RECOM
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 t, telc
c
      character jjmod*4
c
      telc=dmax1(t,mintemp)
      if (((jjmod.ne.'ALL').and.(jjmod.ne.'PHOT')).and.(jjmod.ne.'TEMP')
     &) then
        write (*,10) jjmod
   10 format('  MODE WRONGLY DEFINED FOR SUBR. ALLRATES :',a4)
        stop
      endif
c
c
c     always call cosmic first to get sec ion rate, heating unused here
c     so t de dh not relavent, so long as pop is up to date.
c
      call cosmic (0.d0)
c
      if ((iphom.ne.ipho).and.(jjmod.ne.'TEMP')) then
        call phion
        iphom=ipho
      endif
c
      if ((telc.ne.tem).and.(jjmod.ne.'PHOT')) then
        call recom (telc)
        call collion (telc)
        call charex (telc)
        tem=telc
      endif
c
      return
      end
