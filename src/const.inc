cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     MAPPINGS V.  An Astrophysical Plasma Modelling Code.
c
c
c     Creative Commons v4.0 International
c     By Attribution, Share Alike
c     CC-BY-SA-4.0Intl https://creativecommons.org
c     1976 -- 2022+ Ralph Sutherland,
c     Michael Dopita, Luc Binette, Ian Evans,
c     Brent Groves, David Nicholls,
c     Adam D. Thomas, Yi-Fei Jin, Knox Long
c
c
c       Version v5.2.0
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   include file for global constants.
c   (2018 CODATA recommended values, IAU2015/2012 Astron Const)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      implicit none
c
c Math-Floating point limits and constants
c
      real*8 pi,ftpi
      real*8 rt2,euler
      real*8 twopi,itwopi
      real*8 fpi,ifpi
      real*8 epi,iepi
      real*8 pi8rt3
      real*8 epsilon, logepsilon
      real*8 khuge, logkhuge, maxdekt
      real*8 ioepsilon, lg10ioepsilon
c
c Physical-Chemical constants
c
      real*8 plk,cls,ev,eesu
      real*8 me,mp,amu,mh,mh1,alphafs
      real*8 bohr,stefan,nav,rgas
      real*8 r_inf,r_infe,t_ryd
      real*8 iph,iphe,iphlam
      real*8 lmev,evplk,pzlimit,log10pz
      real*8 rka,rkb,ffk,fk,kbb
      real*8 kev,kkev,kevhz
      real*8 gammaEOS,gammaEOSU,gammaEOSg,gammaEOSx
c
c Astro constants
c
      real*8 aunit, pars
      real*8 rsun,msun,lsun,tsun,GMsun
      real*8 grav,rgm,ledd
c
c     maximum array sizes
c
      integer*4 mxinfph,mxelem,mxion
      integer*4 mxdust,mxdtype,pahi
      integer*4 mxtempbin,mxnnorad
      integer*4 mxnl,mxtr,mxmspecs,mxnspl
      integer*4 mxmonlines, mxmonmlions
      integer*4 mxkappas,mxspeclines
      integer*4 mxnsteps,dinfph
      integer*4 mxnegdes,mxnrec,mxncol
      integer*4 mxfespecs,mxfenl,mxfetr
      integer*4 mxifsteps
      integer*4 minpcits,mxpcits,mxshockits
      integer*4 min_zones,minifsteps
c
c Hydrogenic Spectra, n lines and n series
c
      real*8 alphahb
      real*8 alphaheb
      real*8 mintemp
      real*8 s5rmstol
c
      integer*4 mxnhlines,mxnhs   ! 15/6
      integer*4 mxnhelines,mxnhes ! 15/6
      integer*4 mxnxhlines,mxnxhs ! 10/2
c
      integer*4 mxh42linete       ! abs hbeta
      integer*4 mxh42linede       ! abs hbeta
      integer*4 mxhlinete         ! ratios to hbeta
      integer*4 mxhlinede         ! ratios to hbeta
      integer*4 mxhlinetehr       ! ratios to hbeta hires
      integer*4 mxhlinedehr       ! ratios to hbeta hires
c
      integer*4 mxhe43linete      ! abs hbeta
      integer*4 mxhe43linede      ! abs hbeta
      integer*4 mxhelinete        ! ratios to h4686
      integer*4 mxhelinede        ! ratios to h4686
c
c V3 HHe Resonance Collisions data
c
      integer*4 mxhheions
      integer*4 mxhhelvls
      integer*4 mxhhecols
      integer*4 mxhhenspl
c
      integer*4 mxfenspl
c
c V3 Xray Resonance lines data
c
      integer*4 mxxr3ions
      integer*4 mxxr3lvls
      integer*4 mxxr3cols
      integer*4 mxxr3casc
      integer*4 mxxr3lines
      integer*4 mxxr3nspl
c
c V4 Xray Resonance lines data
c
      integer*4 mxxrlions
      integer*4 mxxrllvls
      integer*4 mxxrlcols
      integer*4 mxxrlcasc
      integer*4 mxxrllines
      integer*4 mxxrlnspl
c
c legacy line arrays
c
c      integer*4 mxxlines
c      integer*4 mxxilines
c      integer*4 mxxhelines
c
c stellar libraries
c
      integer*4 mxflxbins
      integer*4 mxoptxbins
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        Universal constants: CODATA 2018 Values
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   speed of light in vacuum (cm/s) exact
c
      parameter  (cls = 2.99792458d+10)
c
c   planck's constant (erg seconds) now *exact*
c
      parameter  (plk = 6.62607015d-27)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     rest mass of an electron me (g)
c
      parameter (me = 9.1093837015d-28)
c
c     rest mass of a proton mp (g)
c
      parameter (mp = 1.67262192369d-24)
c
c     atomic mass unit assuming C12 = 12
c
      parameter (amu = 1.66053906660d-24)
c
c     mean mass of a H atom : 1.00794 amu NIST
c
      parameter (mh = 1.6737237467888d-24)
c
c     mass of a 1H atom : 1.007825 amu
c
      parameter (mh1 = 1.67353278479614d-24)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     1 electron Volt in ergs now *exact*
c
      parameter (ev = 1.602176634d-12)
c
c other const for optxagnf
c
      parameter (kev   = 1.602176634d-09)
c kev/k
      parameter( kkev  = 1.160452215600825d+07)
c
      parameter( kevhz = 2.417989242084918164374d37 )
c
c     1 electron Volt/h exact with roundoff
c
      parameter (evplk = 2.417989242084918059531d14)
c
c   electron volt in esu units ev*c*1e-8 statVolt
c
      parameter (eesu = 4.803204712570263515977d-10)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Nav Avogadro's number *now exact*
c
      parameter (nav = 6.02214076d23)
c
c   boltzman's constant k, ergs per kelvin now exact
c
      parameter (rkb = 1.380649d-16)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   Rydberg Constant R_inf
c
      parameter (r_inf  = 13.605693122994d+00)
      parameter (r_infe = r_inf*ev)
      parameter (t_ryd  = r_infe/rkb)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   Hydrogen Rydberg Constant, R_H
c
c   Ionisation potential of hydrogen (ev) Primary Def.
c   109678.77174307 cm-1 NIST = 1.359843459970247d1 eV
c
      parameter ( iph = 1.359843459970247d1 )
c
c   Ionisation potential of hydrogen (ergs)
c
      parameter ( iphe = iph*ev )
c
c
c   Wavelength of Hydrogen Limit (Angstroms) Secondary
c   9.11753463416392 using 1/NIST value
c
      parameter ( iphlam = 9.11753463416392d2 )
c
c   Wavelength (Angstoms) to Energy (eV) Primary Def.
c   12398.41984332... using CODATA 2018 now exact
c
      parameter ( lmev = 1.239841984332e+04 )
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   Blackbodies:
c
c   Stefan-Boltzmann constant now exact rounded due to pi:
c   5.670374419d-8
c   (ergs cm^-2 s^-1 K^-4)
c   also:
c      2 pi^5 k^4
c   = ------------
c      15 c^2 h^3
c
c    5.67037441918442945398b-5
c
      parameter ( stefan = 5.67037441918442945398d-5 )
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   Notes on BB analytical emission, no analytical zeta(3)
c   https://apps.dtic.mil/sti/pdfs/AD0845194.pdf
c
c   emissivty BB  = (12pi k^4)/(c^2 h^3) zeta(4) T^4,
c         zeta(4) = pi^4/90
c                 = s T^4
c                 ≈ 5.67037441918443e-05 T^4
c
c     photons BB  = (4pi k^3)/(c^2 h^3) zeta(3) T^3
c         zeta(3) ≈ 1.20205690315959428540....
c                 = r T^3
c                 ≈ 1.52046085939314e+11 T^3
c
c constant for planck function 1/(c^2 h^3)
c now exact with roundoff to double
c
      parameter ( kbb = 3.824639498513004615265d57)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c alphafs = (2pi eesu^2 /(hc))
c
      parameter (alphafs = 7.29735256531d-3)
c
c   First Bohr radius  (cm)
c
c   a0 = h^2/(4 pi^2 me e^2)
c
c
      parameter ( bohr = 5.29177210903d-9 )
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   collection of constants for coll.
c         rate = sqrt((2*pi*hbar^4)/(k me^3))
c
c   in ergs and cm units (SI use d-12)
c
      parameter ( rka = 8.629133680865427904126d-6 )
c
c     continuum emission constant
c
c    16/3 (pi/6)^0.5 (eesu^6 / (c^3 me^2)) (me/k)^0.5
c  = 16/3 (pi/(6 k me^3))^0.5  (e^2 / c )^3
c
      parameter( ffk = 5.444367728055553024031d-39 )
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     total FreeFree emission constant
c
c    (16/(3 hbar me)) ((2 pi  k )/(3 me))^(1/2)  ((eesu^2)/c)^3
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      parameter( fk = 1.425556442965325250733d-27 )
c
c   universal gas constant exact with roundoff
c
      parameter ( rgas = 8.31446261815324d+7 )
c
c ideal atomic gas poly index gamma, gammaEOS
c
      parameter ( gammaEOS   = (5.d0/3.d0) )
      parameter ( gammaEOSU  = (1.d0/(gammaEOS-1.d0)) )
      parameter ( gammaEOSg  = (gammaEOS*gammaEOSU) )
      parameter ( gammaEOSx  = ((gammaEOS+1.d0)/(gammaEOS-1.d0)) )
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c astro quantities, IAU2012, IAU2015
c
c     cm exact IAU2012
      parameter ( aunit = 1.49597870700d+13)
c     cm exact IAU2012
      parameter ( pars  = 3.085677581491368d+18)
c     cm  exact IAU2015
      parameter ( rsun  = 6.957d+10)
c     g derived from IAU2015 GMsun
      parameter ( msun  = 1.988409870698051d+33 )
c     ergs/s exact  IAU2015
      parameter ( lsun  = 3.828d+33 )
c      m^3/s^2 exact IAU2015
      parameter ( GMsun = 1.3271244d26 )
c
c L = (4*pi*rsun^2stefan*tsun^4):
c tsun = (lsun/(4*pi*rsun^2*stefan))^0.25
c 5772 K IAU2015 + CODATA2018 rounded
c
c      K
      parameter ( tsun = 5772.00d+00 )
c
c universal gravity constant not exact
c
      parameter( grav = 6.67430d-08)

c gravitational radius per solar mass , GM/c^2 cm GM exact rounded to dp
      parameter( rgm  = 1.47662503805012d+05)
c Eddington Luminosity per solar mass
c
c 4*pi*G*Msun*mp*c/Thomson  exact rounded to dp
c
      parameter( ledd = 1.25706517984679d+38)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        Mathematical constants
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   pi and four thirds pi
c   pi with datan to match best to compiler math library
c
      parameter (    pi = 4.d0*datan(1.0d0), ftpi = (4.d0/3.d0)*pi )
      parameter ( twopi = 2.d0*pi        , itwopi = 1.d0/(2.d0*pi) )
      parameter (   fpi = 4.d0*pi          , ifpi =  1.d0/(4.d0*pi))
      parameter (   epi = 8.d0*pi          , iepi =  1.d0/(8.d0*pi))
c      8pi/sqrt(3)
      parameter ( pi8rt3=epi*0.5773502691896258d0)

c
c   Euler' constant to 20 places
c
      parameter ( euler = 0.57721566490153286061d0 )
c
c   square root of 2
c
      parameter ( rt2 = 1.4142135623730950488d0 )
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        Program constants
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   epsilon is a small number to prevent division by zero
c   and nasty logs. it is also used to test quantities to see
c   if they are worth calculating (see intvec), 1.0d-38 was chosen
c   to match 1E-38 in single precision on a VAX, note:
c   smallest single precision number on sun is ~1.17e-38
c
      parameter (  epsilon =1.0d-99, logepsilon=dlog(epsilon))
      parameter ( khuge    =1.0d+99, logkhuge   =dlog(khuge)   )
      parameter ( ioepsilon=1.0d-99, lg10ioepsilon=dlog10(ioepsilon))
c
c     limit for abundant ions: ab * pop
c
      parameter ( pzlimit = 1.0d-12 )
      parameter ( log10pz = dlog10(pzlimit) )
c      50 max DeltaE/kt for collisions
      parameter ( maxdekt = 40.d0 )
c
c     maximum number of atoms (elements)
c
      parameter (mxelem = 30)
c
c     maximum number of ionization stages
c
      parameter (mxion = 31)
c
c     maximum number of kappa values in spline tables
c
      parameter (mxkappas = 9)
c
c     maximum number of dust sizes (36=MRN, 81=FULL)
c     need to change DUSTDAT files as well (.mrn <==>.full)
c
      parameter (mxdust = 81)
c
c     maximum number of dust types (ie graphite,silicate etc)
c
      parameter (mxdtype = 2)
c
c     Number of PAH ions
c
      parameter(pahi=5)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     radiative and dielectronic recombination rates vector size
c     must matchup in data files, 209 in older 16
c     elements, 465 for full 30 elements
c     mxnnorad is for the subset of NORAD ions, = 26 for C,N,O, Fe 2-6
c
      parameter (mxnrec  = 465)
      parameter (mxnnorad = 26)
c
c     Dere 2007 collisional ionisation rates vector size
c     must matchup with mxnrec data files
c
      parameter (mxncol = 465)
c
c     photoionsation edges vector size, not same as nrec ncol etc
c     696 for std 16 elements, 1696 for full 30 elements
c
      parameter (mxnegdes = 1696)
c
c     radiation vector size, up to 10240 for max photdat
c     1802 for Brents old std and dust must include at least the
c     bin edges for the edges in use.
c
      parameter (mxinfph = 10240)
c
c     model stucture step array limits
c
      parameter (mxnsteps = 4096)
c
c min and max number of preallocated steps
c in S5 ionisation front flow models
c
      parameter (minifsteps = 6)
      parameter (mxifsteps = 1280)
c
c number of preallocated steps in S5 ionisation front flow models
c
c minimum number of precursor zones
      parameter (min_zones = 6)
c
c maxmimum number of global iterations in S5
c
c  Was 16.  Several models converge geometrically (RMS roughly halving
c  each iteration) but land just above the 0.01% threshold right at the
c  old cap, within a factor of ~1.1-1.3x, with no sign of oscillation
c  (issue #7).  Raised to give those a little more room; harmless for
c  genuinely-oscillating models, which just hit the new cap the same
c  way.
c
      parameter (mxshockits = 20)
c
c maxmimum number of precursor iterations in S5
c
      parameter (minpcits = 2)
      parameter (mxpcits  = 16)
c
c maximum lines to monitor radially in a P6 model
c
c     multi-level ion ids
c
      parameter (mxmonlines = 32)
c
c maximum multi-level model ion emissivition files, (4 in P4-5)
c
      parameter (mxmonmlions = 16)
c
      parameter (mxtempbin = 401)
c
      parameter (dinfph = 401)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  multi-level and other collisional line arrays

c
c Badnell 2015 SIII recombination
c
      integer*4 mxdrbd15, mxrrbd15, mxnlbd15
      parameter(mxdrbd15=7)
      parameter(mxrrbd15=6)
      parameter(mxnlbd15=3)

c
c longest spec file list, including all possible lines and some
c padding for safety
c
      parameter (mxspeclines = 120000)
c
c     maximum number of species in multi-level atoms
c     126 for std 16. 173 for full set
c
      parameter (mxmspecs = 174)
c
c     maximum number of levels in multi-level atoms
c
      parameter (mxnl = 9)
c     maximum number of spline nodes in coll str splines
c     minimum 17 for NORAD rec rate splines
c
      parameter (mxnspl    = 17)
c
c     maximum number of transitions in multi-level atoms
c     mxnl = 5 =>10, mxnl=6 =>15, mxnl=9, => 36, (N*(N-1))/2
c
      parameter (mxtr     = 36)
c
c     equiv numbers for Fe like multi-level atoms
c     new solver can handle up to 322 level fe 3 tested.
c     old mdiag gave up around 50-60 levels
c
c      6
      parameter (mxfespecs = 6    )
c      108 std density 217 high for fe3
      parameter (mxfenl    = 108  )
c      5778 std, 23436 high. per ion
      parameter (mxfetr    = 5778 )
c      11 point BT type 3 splines
      parameter (mxfenspl  = 11   )
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      parameter (mxnhlines  = 15)
      parameter (mxnhs      =  6)
c
      parameter (mxnhelines = 15)
      parameter (mxnhes     =  6)
c
      parameter (mxnxhlines = 10)
      parameter (mxnxhs     =  2)
c
      parameter (mxh42linete  = 12 )
      parameter (mxh42linede  =  9 )
      parameter (mxhlinete    = 10 )
      parameter (mxhlinede    =  9 )
c      hires
      parameter (mxhlinetehr  = 41 )
c      hires
      parameter (mxhlinedehr  = 19 )
c
      parameter (mxhe43linete = 12 )
      parameter (mxhe43linede =  9 )
      parameter (mxhelinete   = 12 )
      parameter (mxhelinede   =  9 )

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Resonance line cascades - khuge memory.
c
c      126 std, 189 Full, max ions
      parameter (mxxr3ions=189)
c       86 max levels per ion
      parameter (mxxr3lvls= 86)
c      504 max collisions per ion
      parameter (mxxr3cols=504)
c       72 max lines in single cascade
      parameter (mxxr3casc= 72)
c      18522 full 13990 std prefs
      parameter (mxxr3lines=18522)
c       11 point BT type 3 splines
      parameter (mxxr3nspl= 11)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Resonance line cascades - khuge memory, was split into
c atom size groups to make multi-d array more efficient.
c
c set for full prefs std density by default
c
c mxxrlcols:
c   5532 std density
c   4389 high density
c
c mxxrllines:
c   56718 std prefs std density
c   58747 full prefs std density
c   57728 std prefs high density
c   59757 full prefs high density
c
c      40 std 45 Full ions
      parameter (mxxrlions=45  )
c      668 std max lvls per ion
      parameter (mxxrllvls=668 )
c      5532/4389 max coll. per ion
      parameter (mxxrlcols=5532)
c      86 std max lines in single cascade
      parameter (mxxrlcasc=86  )
c      56718 ss 58747 fs prefs, 59757 fh
      parameter (mxxrllines=58747)
c      11 point BT type 3 splines
      parameter (mxxrlnspl=11)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c HI and HeII collisional cooling (not cascades)
c
c      2
      parameter (mxhheions=2 )
c      25
      parameter (mxhhelvls=25)
c      24
      parameter (mxhhecols=24)
c      h like colls
      parameter (mxhhenspl=11)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c Legacy line data array sizes
c
c      920
c      parameter (mxxlines=4)
c      32
c      parameter (mxxilines=9)
c      26
c      parameter (mxxhelines=26)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c buffer size to read in all atmospheres, can be reduced to
c 25000 if not using CMFGEN inputs.  A major memory hog!
c
c      up to 560000 bins - CMFGEN!
c
      parameter( mxflxbins = 560000)
c
c number of energy bins in OPTXAGNF model
      parameter( mxoptxbins = 5000)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c H and He effective recomb rate for stromgren approx
      parameter( alphahb  = 2.585d-13)
      parameter( alphaheb = 1.533d-12)
      parameter( mintemp  = 1.0d0    )
c
c  S5 global shock<->precursor convergence threshold (issue #7).  Used
c  both as shock5check's outer pass/fail RMS cutoff and as the target
c  the precursor's own inner zone-stepping loop iterates to on the
c  final verification pass -- they must match, or the final pass can
c  consider itself "converged" internally while still landing outside
c  the outer threshold relative to the previous global iteration.
      parameter( s5rmstol = 1.0d-4   )
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
