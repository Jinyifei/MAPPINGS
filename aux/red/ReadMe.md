<<<<<<< HEAD:misc/dered/ReadMe.md
# DeRed v1.0.8
RSS 2014
=======
# Red v1.0.9
RSS 2022
>>>>>>> rss:aux/red/ReadMe.md

## command: red

### redden or de-redden a spectrum or line list in a text file

Doxygen:  <a href="dered_html/index.html"> Doxygen Documentation</a>

Reads <cr> terminated lines (classic mac), and <lf> lines (linux, unix, OSX), as well as PC <lf>+<cr> lines.

Reads txt.gz or .txt plain files.

#### (NOTE) Default header lines is now 1, not 7

### Build

To build the `red` command:

<<<<<<< HEAD:misc/dered/ReadMe.md
      1) cd dered/
=======
      1) cd red/
>>>>>>> rss:aux/red/ReadMe.md

      2) make

      3) make clean

### Install

      4) sudo make install

### Uninstall

      5) sudo make uninstall


### Usage:

      >red

for the useage info:

      Useage: red [-r Rv] [-c Cn] [-t typeID] [-n skip ] flux25file

      Version: 1.0.0
      Args: optional Rv: AV/E(B-V) > ~2
                       if -r omitted Rv = 3.1

           optional  Cn: Nebula Reddening Constant
                      if -c omitted Cn = 1.0
                      if Cn < 0.0 then deredden

           optional  Scale: Flux Scale Factor > 0.0
                      if -s omitted Scale = 1.0

           optional  typeID: Reddening Function
                      0: CMM89 Stellar Al/Av (default)
                      1: B07 Orion modified CMM89
                      2: F99 Fitzpatrick Al/E(B-V)
                      3: FM07 Fitzpatrick & Massa E(l-V)/E(B-V)
                      4: C00 Calzetti Extinction k(l)
                      5: FD05 Fischera Av=1.0 extinction
                      6: P70 Piembert Rv5.5 Orion Only
                      7: VCG04-14 UV ONLY Modified CMM89

           optional  skip: Input header lines to skip,
                       Defaults to 1 line, use 7 for CMFGEN files

           Required: Input file can be text or text.gz file
                     Default 7 header lines and then two columns
                     Lambda   Flambda
                     or same but with just a 2 column list:
                     LineLambda   flux

           Output: to stdout: lambda, flux, reddened flux, F(l)...
                    suitable as a 7 column csv file

## To de-redden a line list

The input can be just a list of wavelengths and relative fluxes,
the wavelengths dont even have to be in order. Output can just
go to screen if the list is short:

Skip 3 lines, Piembert 1970 F, R 5.5 C 0.4 deredden:

      > red -n 3 -t 6 -r 5.5 -c -0.4 hlines.txt


## To redden an ideal/theory spectrum:

Try the test spectrum, a theoretical MV PN model,
redden with CCM89 at Rv = 5.5:

Skip 9 lines, CCM89 reddening, R 5.5 C 1.0 and scale x1:

      > red -n 9 -r 5.5 -c 1.0 -t 0 -s 1.0 t150k0005.lam > testR55.csv

or with default settings: R 5.5 reddening a theory model:

      > red -n 9 -r 5.5 t150k0005.lam > testR55.csv


You can adjust Rv and Cn and scale factors to process spectra until
you get the best fit, ie Cn = 0.4, Rv = 5.5, B07 reddeing for Orion:

      > red  -n 9 -r 5.5 -c 0.4 -s 1e-8 -t 1 t150k0005.lam > testR55_C04_B07.csv

## To de-redden a spectrum

Just the same as above, but set Cn = -Cn, since the log spectrum is offset
by subtracting Cn*F(l) in log10 space, a -ve Cn will make this a +ve offset
and a +ve Cn will keep it a -ve offset.

Works on text and text.gz input, ie to process a gz compressed file:

      > gzip t150k0005.lam
      > red -n 9 -r 5.5 -c -0.4 t150k0005.lam.gz > testR55dered.csv

