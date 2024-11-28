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
c       Version v5.2.1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Shock 5 shared Variables
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      real*8 dr,drdw,drup,dvdw,dvup,frdw,dt,absdr
      real*8 tdw,tlim,tup,xhii,bp0,bp1,psi
      real*8 t,de,dh,dv,netloss,rad,wdilt0
      real*8 tt0,l0,l11,l12,l1,cmpf,ue0,ue1
      real*8 r0,p0,v0,tnloss,cspd,wmol,mb,malpha,pram,mageta,gaseta
      real*8 pgas,pmag,magparam,bmag,ve,en,ue,rdis,dva,mmach
      real*8 pop1(mxion,mxelem),totn,ionbar,abstime
      real*8 press,mu,rhotot,cltime,utime
      real*8 ptime,ctime,rtime,stime,eqtime
      real*8 atimefrac,cltimefrac,abtimefrac
      real*8 timend,teq,dheq,tl0,tl1,tt1
      real*8 band1,band2,band3,band4,band5,band6,bandall,widnu
      real*8 meanion(mxelem),zi(mxelem)
      real*8 machnumber,alfvennumber
      real*8 prefield(mxinfph)
c       real*8 absf
c       parameter(absf=0.02d0)
c
c Shock intial state kept for iterations
c
      real* 8  te_pre,te_pst,de_pre,de_pst,dh_pre,dh_pst
      real* 8  vs_pre,vs_pst,rh_pre,rh_pst,pr_pre,pr_pst
      real* 8  bm_pre,bm_pst,pop_pre(mxion,mxelem)
c Shock state from last iteration for convergence
      real* 8  te_pre0,te_pst0,de_pre0,de_pst0,dh_pre0,dh_pst0
      real* 8  vs_pre0,vs_pst0,rh_pre0,rh_pst0,pr_pre0,pr_pst0
      real* 8  psi0,cmpf0
      real* 8  bm_pre0,bm_pst0,pop_pre0(mxion,mxelem)
c Shock proto state
      real* 8  bm_neu,te_neu,de_neu,dh_neu,vs_neu
      real* 8  rh_neu,pr_neu,pop_neu(mxion,mxelem)
c
c Shock Precursor State
c
      common /shock5init/
     & te_pre,te_pst,de_pre,de_pst,dh_pre,dh_pst,
     & vs_pre,vs_pst,rh_pre,rh_pst,pr_pre,pr_pst,
     & bm_pre,bm_pst,pop_pre,
     & te_pre0,te_pst0,de_pre0,de_pst0,dh_pre0,dh_pst0,
     & vs_pre0,vs_pst0,rh_pre0,rh_pst0,pr_pre0,pr_pst0,
     & bm_pre0,bm_pst0,pop_pre0,psi0,cmpf0,
     & te_neu,de_neu,dh_neu,vs_neu,pop_neu,bm_neu,rh_neu,pr_neu
c
      common /shock5R/
     & dr,drdw,drup,dvdw,dvup,frdw,dt,absdr,
     & tdw,tlim,tup,xhii,bp0,bp1,psi,
     & t,de,dh,dv,netloss,rad,wdilt0,
     & tt0,l0,l11,l12,l1,cmpf,ue0,ue1,mmach,
     & r0,p0,v0,tnloss,cspd,wmol,mb,malpha,pram,mageta,gaseta,
     & pgas,pmag,magparam,bmag,ve,en,ue,rdis,dva,machnumber,
     & meanion,zi,pop1,totn,ionbar,abstime,alfvennumber,
     & press,mu,rhotot,cltime,utime,
     & ptime,ctime,rtime,stime,eqtime,
     & atimefrac,cltimefrac,abtimefrac,
     & timend,teq,dheq,tl0,tl1,tt1,
     & band1,band2,band3,band4,band5,band6,bandall,widnu,
     & prefield
c
c      real*8 feii_flux,feii_bri,feii_ratio,feii_bratio
c
c unit numbers
c
c
c main files, model and specs
c
      integer*4 luop,lusp,lupt,lupc
c
c common files
c
      integer*4 ludy,lucl,lupb,lupf
c
c shock only files
c
      integer*4 lualsh,lurtsh,lulsh,luionsh(mxelem)
c
c precursor only files
c
      integer*4 lualpc,lurtpc,lulpc,luionpc(mxelem)
c
      integer*4 ie,jnorm,converged,useprecfile
      integer*4  count,step,np,finalit
c
      common /shock5I/ ie,jnorm,converged,
     & count,step,np,finalit,useprecfile
c
      common /shock5L/ luop,lusp,lupt,lupc,
     & ludy,lucl,lupb,lupf,
     & lualsh,lurtsh,lulsh,luionsh,
     & lualpc,lurtpc,lulpc,luionpc
c
c file names
c
      character abundtitle*24
c
      character fn*128,fsh*64,fsp*64
      character flsh*64,flpc*64
      character fionsh(mxelem)*64
      character fionpc(mxelem)*64
      character fl*128,fd*64,fr*64,fa*64
c
      character frpc*64,frsh*64,fash*64
c
      character fpb*64,fcl*64
      character fpm*64,fsm*64
      character fpc*64,fpt*64
      character fapc*64,fpf*64
c
      character pfx*64,sfx*16,caller*64
      character s5pfx*64,subname*64,pollfile*64
      character cht*64,pht*64,clt*64
c
      common /shock5C/ abundtitle,
     & fn,fsh,fsp,flsh,flpc,
     & fionsh,fionpc,fl,fd,fr,fa,
     & frpc,frsh,fash,fpb,fcl,
     & fpm,fsm,fpc,fpt,fapc,fpf,
     & pfx,sfx,caller,
     & s5pfx,subname,pollfile,
     & cht,pht,clt
c
c modes
c
      character lmod*4,ilgg*4,tmod*4,linemod*4,bandsmod*4
      character specmode*4,rmod*4,imod*4,tsrmod*4,spmod*4
      character allmod*4,ratmod*4,ispo*4, wmod*4,vmod*4
      character fclmod*4,stype*4,mtype*4,dynmod*4
      common /shock5M/ lmod,ilgg,tmod,linemod,bandsmod,
     & specmode,rmod,imod,tsrmod,spmod,
     & allmod,ratmod,ispo,wmod,vmod,
     & fclmod,stype,mtype,dynmod
c
c precursor iterations
c
c front structure arrays
c
      integer*4 nfs,n100,nrms
      real*8 rms,invnfs

      real*8 frdr,absf
      real*8 predr(mxifsteps)
      real*8 fra(mxifsteps)
      real*8 x(mxifsteps),nte(mxifsteps),ne(mxifsteps)
      real*8 nh(mxifsteps),fh(mxifsteps)
      real*8 foi(mxifsteps),foii(mxifsteps),foiii(mxifsteps)
      real*8 p1(mxion, mxelem)
      real*8 p2(mxion, mxelem)
      real*8 popfr(mxifsteps, mxion, mxelem)
      real*8 popintfr(mxifsteps, mxion, mxelem)
      real*8 src(mxinfph), attcol(mxinfph), sigcol(mxinfph)
      common /shock5PreI/ nfs, n100, nrms
      common /shock5PreR1/ src, attcol, sigcol
      common /shock5PreR2/ rms, invnfs,
     & fra, x, nte, ne, nh, fh, foi,foii,foiii,
     & p1, p2, popfr, popintfr, frdr, absf, predr
