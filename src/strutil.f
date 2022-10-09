cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     MAPPINGS V.  An Astrophysical Plasma Modelling Code.
c
c     Creative Commons By Attribution, Share Alike
c     v4.0 International https://creativecommons.org
c
c     1975 Ralph Sutherland, Michael Dopita, Luc Binette,
c     Ian Evans, Stephen Mettheringham
c     Brent Groves, David Nicholls,
c     Jin Yi-Fei, Adam D. Thomas,
c
c     Version: v5.2.0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine newfile (pref, p, suff, s, filena)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     This utility subroutine will return a filename that is
c     unique in the current directory.
c     It accepts a prefix and suffix.  Prefixes can be up to 16 chars
c     and suffixes can be 4.  The final filename will be a character*64
c     string.  Multiple of four are used for SPARC and RISC optimisation.
c
c     p and s are integers, indicated the length of the prefix and suff
c
c     RSS 10/90
c
c     ksl 2210 - Modified to use trim and adjustl to strip leading and
c     trailing characters of stings. p and s not indicate the 
c     maximum lenght of the input strings after trimming.  If
c     pref or suff are too long, and error message is printed, 
c     and pref and suff will cut to their maximum lengths.  An
c     alternative which might be better is to simply exit
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      include 'const.inc'
c
      character* (*) filena
      character pref*32,suff*4,s1*32,s2*32
      integer*4 p,s,i,j,l
      logical iexi
c
c
      pref=adjustl(pref)
      pref=trim(pref)
      if (len(pref)>p) then
          write(*,*) 'Error: length of pref ', pref, 
     &      'greater than allowed ', p
          pref=pref(1:p)
      endif
      suff=adjustl(suff);
      suff=trim(suff)
      if (len(suff)>s) then
          write(*,*) 'Error: length of suff', suff, 
     &      'greater than allowed ', p
          suff=suff(1:s)
      endif

   10 format(i4.4)
      filena=' '
      l=p+4+1+s
      filena(1:l+1)=' '
c
      i=0
   20 i=i+1
      s2=' '
      write (s2,10) i
      filena=trim(pref)//trim(s2)//'.'//trim(suff)
c
      inquire (file=filena,exist=iexi)
c
      if (iexi) goto 20

      return
c
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      integer*4 function mlen(s)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  returns length of s, discarding only trailing spaces and invalid
c  returns the last valid char index, s can contain garbage before last
c  char
c
c  explicitly lists valid chars to remain encoding independent
c
c  chief advantages:
c  * unlike lenv allows spaces in string, good for runnames etc
c  * will handle any kind of blank or garbage chars even unknown ones
c  * rejects any awkward filename chars like (),: etc
c  * uses plain vanilla f77, no implementation dependent
c    trim function etc, works with f2c/gcc and newer
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
c
      character* (*) s
      integer*4 i,sl
      integer*4 lastchar
      character c
c
      lastchar=0
      i=0
      sl=len(s)
      if (sl.lt.1) then
        mlen=0
        return
      endif
c
      do i=1,sl
        c=s(i:i)
c
        if (c.eq.',') goto 10
        if (c.eq.'/') goto 10
        if (c.eq.'.') goto 10
        if (c.eq.'_') goto 10
        if (c.eq.'-') goto 10
        if (c.eq.'+') goto 10
        if (c.eq.'=') goto 10
        if (c.eq.'!') goto 10
        if (c.eq.'@') goto 10
        if (c.eq.'#') goto 10
        if (c.eq.'$') goto 10
        if (c.eq.'%') goto 10
        if (c.eq.'^') goto 10
        if (c.eq.'&') goto 10
        if (c.eq.'*') goto 10
        if (c.eq.'(') goto 10
        if (c.eq.')') goto 10
        if (c.eq.'|') goto 10
        if (c.eq.'[') goto 10
        if (c.eq.']') goto 10
c digits
        if (c.eq.'0') goto 10
        if (c.eq.'1') goto 10
        if (c.eq.'2') goto 10
        if (c.eq.'3') goto 10
        if (c.eq.'4') goto 10
        if (c.eq.'5') goto 10
        if (c.eq.'6') goto 10
        if (c.eq.'7') goto 10
        if (c.eq.'8') goto 10
        if (c.eq.'9') goto 10
c lowercase
        if (c.eq.'a') goto 10
        if (c.eq.'b') goto 10
        if (c.eq.'c') goto 10
        if (c.eq.'d') goto 10
        if (c.eq.'e') goto 10
        if (c.eq.'f') goto 10
        if (c.eq.'g') goto 10
        if (c.eq.'h') goto 10
        if (c.eq.'i') goto 10
        if (c.eq.'j') goto 10
        if (c.eq.'k') goto 10
        if (c.eq.'l') goto 10
        if (c.eq.'m') goto 10
        if (c.eq.'n') goto 10
        if (c.eq.'o') goto 10
        if (c.eq.'p') goto 10
        if (c.eq.'q') goto 10
        if (c.eq.'r') goto 10
        if (c.eq.'s') goto 10
        if (c.eq.'t') goto 10
        if (c.eq.'u') goto 10
        if (c.eq.'v') goto 10
        if (c.eq.'w') goto 10
        if (c.eq.'x') goto 10
        if (c.eq.'y') goto 10
        if (c.eq.'z') goto 10
c uppercase
        if (c.eq.'A') goto 10
        if (c.eq.'B') goto 10
        if (c.eq.'C') goto 10
        if (c.eq.'D') goto 10
        if (c.eq.'E') goto 10
        if (c.eq.'F') goto 10
        if (c.eq.'G') goto 10
        if (c.eq.'H') goto 10
        if (c.eq.'I') goto 10
        if (c.eq.'J') goto 10
        if (c.eq.'K') goto 10
        if (c.eq.'L') goto 10
        if (c.eq.'M') goto 10
        if (c.eq.'N') goto 10
        if (c.eq.'O') goto 10
        if (c.eq.'P') goto 10
        if (c.eq.'Q') goto 10
        if (c.eq.'R') goto 10
        if (c.eq.'S') goto 10
        if (c.eq.'T') goto 10
        if (c.eq.'U') goto 10
        if (c.eq.'V') goto 10
        if (c.eq.'W') goto 10
        if (c.eq.'X') goto 10
        if (c.eq.'Y') goto 10
        if (c.eq.'Z') goto 10
        goto 20
   10   lastchar=i
   20   continue
      enddo
      mlen=lastchar
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine mytrim (s, l, t)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c
c  returns length of s, discarding leading and trailing spaces, trimmed
c  result in t
c
c  explicitly lists valid chars to remain encoding independent
c
c  chief advantages:
c  * will reject any kind of blank or garbage chars even unknown ones
c  * rejects any awkward filename chars like (),: etc
c  * uses plain vanilla f77, no implementation dependent
c    trim function etc, works with f2c/gcc and newer
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
c
      character*(*) s
      character*(*) t
      integer*4 l1,l2,l
      integer*4 i,sl,found
      character c
c      integer*4 mlen
      sl=len(s)
      l1=1
      l2=1
      l=1
      found=0
      i=0
   10 i=i+1
      if (i.gt.sl) goto 20
      c=s(i:i)
      if ((c.eq.' ').and.(found.eq.0)) then
        l1=i+1
        goto 10
      endif
      found=1
c file name chars
      if (c.eq.'/') goto 10
      if (c.eq.'.') goto 10
      if (c.eq.'_') goto 10
      if (c.eq.'-') goto 10
      if (c.eq.'+') goto 10
      if (c.eq.'*') goto 10
      if (c.eq.'|') goto 10
      if (c.eq.'[') goto 10
      if (c.eq.']') goto 10
c digits
      if (c.eq.'0') goto 10
      if (c.eq.'1') goto 10
      if (c.eq.'2') goto 10
      if (c.eq.'3') goto 10
      if (c.eq.'4') goto 10
      if (c.eq.'5') goto 10
      if (c.eq.'6') goto 10
      if (c.eq.'7') goto 10
      if (c.eq.'8') goto 10
      if (c.eq.'9') goto 10
c lowercase
      if (c.eq.'a') goto 10
      if (c.eq.'b') goto 10
      if (c.eq.'c') goto 10
      if (c.eq.'d') goto 10
      if (c.eq.'e') goto 10
      if (c.eq.'f') goto 10
      if (c.eq.'g') goto 10
      if (c.eq.'h') goto 10
      if (c.eq.'i') goto 10
      if (c.eq.'j') goto 10
      if (c.eq.'k') goto 10
      if (c.eq.'l') goto 10
      if (c.eq.'m') goto 10
      if (c.eq.'n') goto 10
      if (c.eq.'o') goto 10
      if (c.eq.'p') goto 10
      if (c.eq.'q') goto 10
      if (c.eq.'r') goto 10
      if (c.eq.'s') goto 10
      if (c.eq.'t') goto 10
      if (c.eq.'u') goto 10
      if (c.eq.'v') goto 10
      if (c.eq.'w') goto 10
      if (c.eq.'x') goto 10
      if (c.eq.'y') goto 10
      if (c.eq.'z') goto 10
c uppercase
      if (c.eq.'A') goto 10
      if (c.eq.'B') goto 10
      if (c.eq.'C') goto 10
      if (c.eq.'D') goto 10
      if (c.eq.'E') goto 10
      if (c.eq.'F') goto 10
      if (c.eq.'G') goto 10
      if (c.eq.'H') goto 10
      if (c.eq.'I') goto 10
      if (c.eq.'J') goto 10
      if (c.eq.'K') goto 10
      if (c.eq.'L') goto 10
      if (c.eq.'M') goto 10
      if (c.eq.'N') goto 10
      if (c.eq.'O') goto 10
      if (c.eq.'P') goto 10
      if (c.eq.'Q') goto 10
      if (c.eq.'R') goto 10
      if (c.eq.'S') goto 10
      if (c.eq.'T') goto 10
      if (c.eq.'U') goto 10
      if (c.eq.'V') goto 10
      if (c.eq.'W') goto 10
      if (c.eq.'X') goto 10
      if (c.eq.'Y') goto 10
      if (c.eq.'Z') goto 10
   20 l2=i-1
      l1=min(sl,max(1,l1))
      l2=min(sl,max(1,l2))
      l=l2-l1+1
      l=min(sl,max(1,l))
      t(1:l)=s(l1:l2)
      if (l.lt.sl) then
        t(l+1:sl)=' '
      endif
      sl=l
      t=t(1:sl)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine myappend (s, a, t)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  returns length of s, discarding leading and trailing spaces, trimmed
c  apends a also trimmed - result in t
c
c  explicitly lists valid chars to remain encoding independent
c
c  chief advantages:
c  * will reject any kind of blank or garbage chars even unknown ones
c  * rejects any awkward filename chars like (),: etc
c  * uses plain vanilla f77, no implementation dependent
c    trim function etc, works with f2c/gcc and newer
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
c
      character*(*) s
      character*(*) a
      character*(*) t
      integer*4 l1,l2,l3,mlen
      l1=mlen(s)
      l2=mlen(a)
      s(l1+1:l1+1+l2)=a(1:l2)
      call mytrim (s, l3, t)
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      integer*4 function lenv(s)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  returns length up to last valid filename char
c
c  explicitly lists valid chars to remain encoding independent
c
c  chief advantages:
c  * will reject any kind of blank or garbage chars even unknown ones
c  * rejects any awkward filename chars like (),: etc
c  * uses plain vanilla f77, no implementation dependent
c    trim function etc, works with f2c/gcc and newer
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
c
      integer*4 i
      character* (*) s
      character c
      i=0
   10 i=i+1
      if (i.gt.512) goto 20
      c=s(i:i)
c file name chars
      if (c.eq.'/') goto 10
      if (c.eq.'.') goto 10
      if (c.eq.'_') goto 10
      if (c.eq.'-') goto 10
      if (c.eq.'+') goto 10
      if (c.eq.'*') goto 10
      if (c.eq.'|') goto 10
      if (c.eq.'[') goto 10
      if (c.eq.']') goto 10
c digits
      if (c.eq.'0') goto 10
      if (c.eq.'1') goto 10
      if (c.eq.'2') goto 10
      if (c.eq.'3') goto 10
      if (c.eq.'4') goto 10
      if (c.eq.'5') goto 10
      if (c.eq.'6') goto 10
      if (c.eq.'7') goto 10
      if (c.eq.'8') goto 10
      if (c.eq.'9') goto 10
c lowercase
      if (c.eq.'a') goto 10
      if (c.eq.'b') goto 10
      if (c.eq.'c') goto 10
      if (c.eq.'d') goto 10
      if (c.eq.'e') goto 10
      if (c.eq.'f') goto 10
      if (c.eq.'g') goto 10
      if (c.eq.'h') goto 10
      if (c.eq.'i') goto 10
      if (c.eq.'j') goto 10
      if (c.eq.'k') goto 10
      if (c.eq.'l') goto 10
      if (c.eq.'m') goto 10
      if (c.eq.'n') goto 10
      if (c.eq.'o') goto 10
      if (c.eq.'p') goto 10
      if (c.eq.'q') goto 10
      if (c.eq.'r') goto 10
      if (c.eq.'s') goto 10
      if (c.eq.'t') goto 10
      if (c.eq.'u') goto 10
      if (c.eq.'v') goto 10
      if (c.eq.'w') goto 10
      if (c.eq.'x') goto 10
      if (c.eq.'y') goto 10
      if (c.eq.'z') goto 10
c uppercase
      if (c.eq.'A') goto 10
      if (c.eq.'B') goto 10
      if (c.eq.'C') goto 10
      if (c.eq.'D') goto 10
      if (c.eq.'E') goto 10
      if (c.eq.'F') goto 10
      if (c.eq.'G') goto 10
      if (c.eq.'H') goto 10
      if (c.eq.'I') goto 10
      if (c.eq.'J') goto 10
      if (c.eq.'K') goto 10
      if (c.eq.'L') goto 10
      if (c.eq.'M') goto 10
      if (c.eq.'N') goto 10
      if (c.eq.'O') goto 10
      if (c.eq.'P') goto 10
      if (c.eq.'Q') goto 10
      if (c.eq.'R') goto 10
      if (c.eq.'S') goto 10
      if (c.eq.'T') goto 10
      if (c.eq.'U') goto 10
      if (c.eq.'V') goto 10
      if (c.eq.'W') goto 10
      if (c.eq.'X') goto 10
      if (c.eq.'Y') goto 10
      if (c.eq.'Z') goto 10
   20 lenv=i-1
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine toup (s, t)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  raises string to uppercase iff lowercase chars
c
      character* (*) s
      character* (*) t
c
      integer*4 i,sl
      character c
      sl=len(s)
      s=s(1:sl)
      i=0
c
   10 i=i+1
      if (i.gt.sl) goto 20
c
      c=s(i:i)
      if (c.eq.'') goto 20
c
c lowercase
c
      if (c.eq.'a') then
        s(i:i)='A'
        goto 10
      endif
      if (c.eq.'b') then
        s(i:i)='B'
        goto 10
      endif
      if (c.eq.'c') then
        s(i:i)='C'
        goto 10
      endif
      if (c.eq.'d') then
        s(i:i)='D'
        goto 10
      endif
      if (c.eq.'e') then
        s(i:i)='E'
        goto 10
      endif
      if (c.eq.'f') then
        s(i:i)='F'
        goto 10
      endif
      if (c.eq.'g') then
        s(i:i)='G'
        goto 10
      endif
      if (c.eq.'h') then
        s(i:i)='H'
        goto 10
      endif
      if (c.eq.'i') then
        s(i:i)='I'
        goto 10
      endif
      if (c.eq.'j') then
        s(i:i)='J'
        goto 10
      endif
      if (c.eq.'k') then
        s(i:i)='K'
        goto 10
      endif
      if (c.eq.'l') then
        s(i:i)='L'
        goto 10
      endif
      if (c.eq.'m') then
        s(i:i)='M'
        goto 10
      endif
      if (c.eq.'n') then
        s(i:i)='N'
        goto 10
      endif
      if (c.eq.'o') then
        s(i:i)='O'
        goto 10
      endif
      if (c.eq.'p') then
        s(i:i)='P'
        goto 10
      endif
      if (c.eq.'q') then
        s(i:i)='Q'
        goto 10
      endif
      if (c.eq.'r') then
        s(i:i)='R'
        goto 10
      endif
      if (c.eq.'s') then
        s(i:i)='S'
        goto 10
      endif
      if (c.eq.'t') then
        s(i:i)='T'
        goto 10
      endif
      if (c.eq.'u') then
        s(i:i)='U'
        goto 10
      endif
      if (c.eq.'v') then
        s(i:i)='V'
        goto 10
      endif
      if (c.eq.'w') then
        s(i:i)='W'
        goto 10
      endif
      if (c.eq.'x') then
        s(i:i)='X'
        goto 10
      endif
      if (c.eq.'y') then
        s(i:i)='Y'
        goto 10
      endif
      if (c.eq.'z') then
        s(i:i)='Z'
        goto 10
      endif
      goto 10
   20 t=s(1:sl)
      return
      end
