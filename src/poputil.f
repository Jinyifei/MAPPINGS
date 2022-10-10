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
c     Adam D. Thomas, Jin Yi-Fei, Knox Long
c
c
c       Version v5.2.0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine showpop (popin)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 popin(mxion, mxelem)
      integer*4 at, ion
      do at=1,atypes
        do ion=1,maxion(at)
          if (popin(ion,at).gt.0.d0) then
            write (*,'(x,a2,x,i2.2,x,i2.2,x,1pg11.4)') elem(at),mapz(at)
     &       ,ion,popin(ion,at)
          endif
        enddo
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine copypop (popin, popout)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 popin(mxion, mxelem), popout(mxion, mxelem)
      integer*4 at, ion
      do at=1,atypes
        do ion=1,mxion
          popout(ion,at)=popin(ion,at)
        enddo
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine addpop (popin, popout)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 popin(mxion, mxelem), popout(mxion, mxelem)
      integer*4 at, ion
      do at=1,atypes
        do ion=1,mxion
          popout(ion,at)=popin(ion,at)+popout(ion,at)
        enddo
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine clearpop (popin)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 popin(mxion, mxelem)
      integer*4 at, ion
      do at=1,atypes
        do ion=1,mxion
          popin(ion,at)=0.0d0
        enddo
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine scalepop (popin, x)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 popin(mxion, mxelem),x
      integer*4 at, ion
      do at=1,atypes
        do ion=1,mxion
           popin(ion,at)=popin(ion,at)*x
        enddo
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine copysteppop (step, popin, popout)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Uses mxifsteps6 instead of mxifsteps
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 popin(mxifsteps, mxion, mxelem), popout(mxion, mxelem)
      integer*4 step,at, ion
      do at=1,atypes
        do ion=1,mxion
          popout(ion,at)=popin(step,ion,at)
        enddo
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine copypopstep (popin, step, popout)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
      real*8 popin(mxion, mxelem), popout(mxifsteps, mxion, mxelem)
      integer*4 step,at, ion
      do at=1,atypes
        do ion=1,mxion
           popout(step,ion,at)=popin(ion,at)
        enddo
      enddo
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine averinto (wei, popw, popco, popout)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c*******TO OUTPUT AVERAGE OF POPW & POPCO IN POPOUT
c     THE WEIGHT OFF POPW IS : WEI (0<=WEI<=1)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
      real*8 popw(mxion, mxelem), popco(mxion, mxelem)
     &                ,popout(mxion, mxelem)
      real*8 wei, weiw, weico
c
      integer*4 i, j
c
      weiw=dmax1(0.0d0,dmin1(1.0d0,wei))
      weico=dmax1(0.d0,1.d0-weiw)
c
      do i=1,atypes
        do j=1,maxion(i)
          popout(j,i)=(weiw*popw(j,i))+(weico*popco(j,i))
        enddo
      enddo
c
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine difpop (popin, popfi, tre, lim, dif)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO DERIVE RELATIVE CHANGE IN IONIC POPULATIONS : DIF
c     LIM : NUMBER OF LAST ELEMENTS TO BE INCLUDED
c     TRE : TRESHOLD FOR MEASURING CHANGE
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c
      real*8 popin(mxion, mxelem), popfi(mxion, mxelem)
      real*8 tre, dif, thresh, maxdif, tmdif,sum,p1,p2
      integer*4 num, idx, ion, lim, matom, mion
c
      dif=0.0d0
      sum=0.d0
      num=0
      thresh=tre
c
      matom=0
      mion=0
      maxdif=0.d0
c
      if (thresh.le.epsilon) thresh=epsilon
      do idx=1,lim
        do ion=1,maxion(idx)
          if ((popin(ion,idx).ge.thresh).and.(popfi(ion,idx).ge.thresh))
     &      then
            p1=dlog10(popin(ion,idx))
            p2=dlog10(popfi(ion,idx))
            tmdif=dabs(p1-p2)
            if (tmdif.ge.maxdif) then
              maxdif=tmdif
              matom=idx
              mion=ion
            endif
            sum=sum+tmdif
            num=num+1
          endif
        enddo
      enddo
c
      dif=sum/(num+epsilon)
c
c     if (expertmode.gt.0) then
c       write (*,*) 'Max difference: ',elem(matom),rom(mion),'=',maxdif
c     endif
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine difhhe (popin, popfi, dif)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c*******TO DERIVE RELATIVE CHANGE IN IONIC POPULATIONS : DIF
c     LIM : NUMBER OF LAST ELEMENTS TO BE INCLUDED
c     TRE : TRESHOLD FOR MEASURING CHANGE
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'cblocks.inc'
c
c
      real*8 popin(mxion, mxelem), popfi(mxion, mxelem)
      real*8 dif, thresh, maxdif, tmdif, sum, p1, p2
      integer*4 num, idx, ion, lim, matom, mion
c
      dif=0.0d0
      sum=0.d0
      num=0
      lim=2
      thresh=1.0d-9
c
      matom=0
      mion=0
      maxdif=0.d0
c
      do idx=1,lim
        do ion=1,maxion(idx)
          if ((popin(ion,idx).ge.thresh).and.(popfi(ion,idx).ge.thresh))
     &      then
            p1=dlog10(popin(ion,idx))
            p2=dlog10(popfi(ion,idx))
            tmdif=dabs(p1-p2)
            if (tmdif.ge.maxdif) then
              maxdif=tmdif
              matom=idx
              mion=ion
            endif
            sum=sum+tmdif
            num=num+1
          endif
        enddo
      enddo
c
      if (num.gt.0) dif=sum/(num+epsilon)
c
      if (expertmode.gt.0) then
        write (*,*) 'Max HHe difference: ',elem(matom),rom(mion),'=',
     &   maxdif
      endif
c
      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
