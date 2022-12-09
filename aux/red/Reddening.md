Reddening Function Notes: (DRAFT 1.0.8 )
========================================

RSS

Typical Reddening Functions are normalised by E(B-V), and are relative
to 'color' in astronomical tradition.  But E(B-V) is not really useful for
object without strong continua, or not observed through broad filters,
for line spectra what we want is the monochromatic extinction/attenuation.
The amount in magnitudes (or just scaling factors) that we enhance or reduce the
observed fluxes as a function of wavelength.

The fundamental quantity is A(lambda), or for us the closely related F(lambda).
We need to reduce all the kappas and E(B-V) relative reddenings etc etc
to A(lambda) before we can apply all the functions available in a uniform way.

We want to use:

* CCM89
* Fitzpatrick 1999 (fixed near IR points - see original code, convert to A(l) with splines)
* Calzetti 2000/2001  (converted to A(l) just one R_v)
* Fitzpatrick 2005/2007 (more complete data - convert to A(l) with splines)
* Fishera 2005 (fixed to allow any R_V, and any wavelength - convert to A(l))

 There is an ancient 1970 Piembert F(l) for Orion that I think we can ignore
 and the Blagrave 2007 modified CCM89 is only for Orion as well.

Converting 'colour relative' to monochromatic
---------------------------------------------

We want to transform relative colour function to absolute extinction,A(l)
and then make it relative to just AV, (not a colour),
then relative to A(Heta) to get a logarithmic form good for nebula  spectra: C*F(l)

Given the colour relative form of reddening:  [ Im leaving off brackets for A(l)
and A(B) etc for the text, Al = A(l) and AB = A(B) etc, they can go back in LaTeX]

      Al/E(B-V) and RV = AV/E(B-V)

      [ E(B-V) = AB - AV ]
->

      Al/(AB-AV)

Subtract RV = AV/E(B-V)

      Al/(AB-AV) - RV

      Al/(AB-AV) - AV/E(B-V)

      Al/(AB-AV) - AV/(AB-AV)

      (Al-AV)/(AB-AV)

Gives:

      E(l-V)/E(B-V)

Then divide out by RV to get just the extinction

      E(l-V)/E(B-V)/RV

->

      (Al-AV)/E(B-V)  *  E(B-V)/AV

      (Al-AV)/AV

      Al/AV - AV/AV

Finally:

      Al/AV - 1

Now AB is gone, and it is all relative to just AV (or any other reference
wavelength), and the real monochromatic information is all in Al = A(lambda)
 the mag lost at each wavelength. AV is just A(l) at V (~5480A) and this
expression is 0.0 at V, because 0.0 is zero mag different, and x 1.0 in linear
space.  Monochromatic functions suit line work for obvious reasons.


f(l)
---------------------

Convert to f(l), logarithmic reddening, relative to f(Hb) = 0.0
Deceptively simple:

      f(l) = (Al/AV)/(AHb/AV) - 1
           = Al/AHb -1

So for any Al/E(B-V) relative function and RV we can get an f(l)
to scale with C, and we choose to make f(Hbeta) = 0.0

It doesn't matter what AV is( much, unless A(l) changes a lot as AV
increases), just the logarithmic shape function f(l).

Nebula Line Dereddening:
------------------------------------------

For nebula lines we just scale f(l) with a scaling factor C, in log space,
(ie making line intensity ratios a little like magnitudes, but really to get
 log behaviour to handle ratios compactly)

Using: Observed intensity *ratio* I_0(l), get the dereddened *ratio* I(l)

       log(I(l)) = log(I_0(l)) + C*f(l)

or

        I(l)  = 10^[log(I_0(l)) + C*f(l)]

if and only if `f(l)` is the right shape, there should be a *single*
`C` for the entire spectrum, and `C` is like `AV`, [you can work out
that if you like, but it doesn't matter, since we are working in
ratios anyway]  All the nonsense about mags being `0.4dex` is taken
into the constant `C`.  If you use different logs, `C` will change, but
who cares.

We just need `f(l)` for each line wavelength `l`, and apply a `C`
to deredden the spectrum.

For different RV values and `AV/E(B-V))`, the *slope* of f changes
so you get C to move it up and down in log fluxes, and RV to
tilt it.  Fitting a reddening is then a matter of choosing the
best `RV` and `C`.

Summary:
---------------------

In summary: Take `RV` and `Al/E(B-V)`
->
      Al/AV = (Al/E(B-V)-RV)/RV + 1

then

      f(l) = (Al/AV)/(AHb/AV) - 1

I prefer to get everything like this in terms of `Al/AV` given `RV` and `Al/E(B-V)`
then get `f(l)` from `(Al/AV)/(AHb/AV) - 1`

Once we have `A(l)`, `A(Hb)` for `Hbeta`, and `AV`, we can make `f(l)` for every
line and then apply a `C`.

You make different `f(l)` by changing `RV`.


Practical Steps:
---------------------

 Ultimately we need `A(l)`, ie to get `AV`, `AHbeta` and then `f(l)`

0) Get `RV`, and `Al/E(B-V)`, function of `l`, often expressed as `1/microns`
for a given `l`.

2) get `A(l)/AV` from `(Al/E(B-V)-RV)/RV + 1`. If you choose `AV` then you can
get `A(l)`. Some results are given only for a fixed `RV`, ie `4.05` for Calzetti.
Some just assume `AV` and `A(l)` directly, `RV` being implicit in `A(l)`
`CMM 1989` is the clearest.

3) make `f(l)` from `(Al/AV)/(AHb/AV) - 1`, using `A(l)` to get `A(Hbeta)`
(Remember these are all logarithmic values, so are really in term of ratios)

4) Using `RV` in 2 and `A(l)`, use 3) to get `f(l)` at each line wavelength
(some give `f(l)` right up front, like Piembert 1970, we can make our own lists
of `f(l)` for MAPPINGS lines eg.

5) Choose different `C`s to get H lines to deredden.  *Or* take the `log` of
the observed fluxes and set `log` ded to be `log (hline ratio)` --
this the ideal log dered value --  and solve for `C`
ie:
     log dered = log obs + C*f(l)
so
      C = (log dered - log obs)/f(l)

The ideal `C'` is

      C' = (log(Hline) - log (obs hline)) /f(l)

And we get `log(Hline)` from MAPPINGS or even Osterbrock or
our book, ADU.

If you get `C'` for all the Balmer and Paschen lines,*and* `f(l)` is
correct, there should be one `C'` value for all, with scatter, just average
or some other fit to get a global `C`.

If there are trends in `C`, then `f(l)` is the wrong shape, and if `RV` doesn't
fix it then you need a different extinction/redening function.

6) If we see trends and `RV` wont help, we can fit the `C(l)` trend and divide into `f(l)`
to ge a new `f(l)` that restores the Hline ratios, however the absolute
meaning of `C` and `f(l)` wrt `RV` and `AV` are lost, but we do get better line
ratios.

End Bit:

With the Fischera data, we use the circular fit to make `A(l)/E(B-V)` for
any `RV`, *but* we need to interpolate the function at `Hbeta` accurately.
None of Jorgs data are designed to give values at hydrogen or any other
lines, so we need to use spline interpolation.

I have a spreadsheet that generates `A(l)/E(B-V)` from Fishera 2005 for
any `RV`, so we can make `f(l)` once we have a convenient interpolation.
I also have `A(l)` and/or `f(l)` for Piembert 1970, CCM89 and Blagrave 2007
 as well as Calzetti.

Jorg showed that the shape doesn't change much between `AV 1` and `AV10`, so
we can simply interpolate, but frankly if you work above `AV=1` you are mad!


Refs:
      Piembert 1970
      Mathis 1983 ApJ 267 119
      CCM89: Cardelli, Clayton, & Mathis (1989) , ApJ, 345, 245
      Osterbrock 1989
      Calzetti et al 2000 ApJ 533, 682
      Calzetti  2001 PASP review 113:1449–1485,
       Fischera et al 2005
      Blagrave 2007
      Esteban 2004/Simon Diaz 2011
      + Fitzpatrick refs

Retrieved 13 abstracts, starting with number 1.  Total number selected: 13.

@ARTICLE{2007ApJ...655..299B,
   author = {{Blagrave}, K.~P.~M. and {Martin}, P.~G. and {Rubin}, R.~H. and
	{Dufour}, R.~J. and {Baldwin}, J.~A. and {Hester}, J.~J. and
	{Walter}, D.~K.},
    title = "{Deviations from He I Case B Recombination Theory and Extinction Corrections in the Orion Nebula}",
  journal = {\apj},
   eprint = {astro-ph/0610621},
 keywords = {ISM: Dust, Extinction, ISM: H II Regions, ISM: Abundances, ISM: Individual: Name: Orion Nebula},
     year = 2007,
    month = jan,
   volume = 655,
    pages = {299-315},
      doi = {10.1086/510151},
   adsurl = {http://adsabs.harvard.edu/abs/2007ApJ...655..299B},
  adsnote = {Provided by the SAO/NASA Astrophysics Data System}
}

@ARTICLE{2001PASP..113.1449C,
   author = {{Calzetti}, D.},
    title = "{The Dust Opacity of Star-forming Galaxies}",
  journal = {\pasp},
   eprint = {astro-ph/0109035},
 keywords = {ISM: Dust, Extinction, Galaxies: ISM, Galaxies: Starburst, infrared: galaxies, ultraviolet: galaxies},
     year = 2001,
    month = dec,
   volume = 113,
    pages = {1449-1485},
      doi = {10.1086/324269},
   adsurl = {http://adsabs.harvard.edu/abs/2001PASP..113.1449C},
  adsnote = {Provided by the SAO/NASA Astrophysics Data System}
}

@ARTICLE{2001NewAR..45..601C,
   author = {{Calzetti}, D.},
    title = "{The effects of dust on the spectral energy distribution of star-forming galaxies}",
  journal = {\nar},
   eprint = {astro-ph/0008403},
     year = 2001,
    month = oct,
   volume = 45,
    pages = {601-607},
      doi = {10.1016/S1387-6473(01)00144-0},
   adsurl = {http://adsabs.harvard.edu/abs/2001NewAR..45..601C},
  adsnote = {Provided by the SAO/NASA Astrophysics Data System}
}

@ARTICLE{2000ApJ...533..682C,
   author = {{Calzetti}, D. and {Armus}, L. and {Bohlin}, R.~C. and {Kinney}, A.~L. and
	{Koornneef}, J. and {Storchi-Bergmann}, T.},
    title = "{The Dust Content and Opacity of Actively Star-forming Galaxies}",
  journal = {\apj},
   eprint = {astro-ph/9911459},
 keywords = {GALAXIES: STARBURST, INFRARED: GALAXIES, INFRARED: ISM: CONTINUUM, ISM: DUST, EXTINCTION},
     year = 2000,
    month = apr,
   volume = 533,
    pages = {682-695},
      doi = {10.1086/308692},
   adsurl = {http://adsabs.harvard.edu/abs/2000ApJ...533..682C},
  adsnote = {Provided by the SAO/NASA Astrophysics Data System}
}

@ARTICLE{1989ApJ...345..245C,
   author = {{Cardelli}, J.~A. and {Clayton}, G.~C. and {Mathis}, J.~S.},
    title = "{The relationship between infrared, optical, and ultraviolet extinction}",
  journal = {\apj},
 keywords = {Infrared Spectra, Interstellar Extinction, Ultraviolet Spectra, Visible Spectrum, Computational Astrophysics, Interstellar Matter, Iue},
     year = 1989,
    month = oct,
   volume = 345,
    pages = {245-256},
      doi = {10.1086/167900},
   adsurl = {http://adsabs.harvard.edu/abs/1989ApJ...345..245C},
  adsnote = {Provided by the SAO/NASA Astrophysics Data System}
}

@ARTICLE{2003ApJ...592..947C,
   author = {{Clayton}, G.~C. and {Gordon}, K.~D. and {Salama}, F. and {Allamandola}, L.~J. and
	{Martin}, P.~G. and {Snow}, T.~P. and {Whittet}, D.~C.~B. and
	{Witt}, A.~N. and {Wolff}, M.~J.},
    title = "{The Role of Polycyclic Aromatic Hydrocarbons in Ultraviolet Extinction. I. Probing Small Molecular Polycyclic Aromatic Hydrocarbons}",
  journal = {\apj},
   eprint = {astro-ph/0304025},
 keywords = {ISM: Dust, Extinction, ISM: Lines and Bands, ISM: Molecules, Ultraviolet: ISM},
     year = 2003,
    month = aug,
   volume = 592,
    pages = {947-952},
      doi = {10.1086/375771},
   adsurl = {http://adsabs.harvard.edu/abs/2003ApJ...592..947C},
  adsnote = {





