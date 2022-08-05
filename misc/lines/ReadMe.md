# _lines_ - a nebula line list fitting command line utility
v1.0.4 build 19

Developed by Dr Ralph Sutherland, Mount Stromlo Observatory.

[rsaa.anu.edu.au](https://rsaa.anu.edu.au)

_lines_ is for text file based, command–line, gaussian line fitting.
An input list of spectral patches is used to measure lines in a simple two column text file spectrum.

Output is as simple text, suitable for creating csv files in subsequent use.

# Download

Get the lines code archive here: [lines.zip](https://miocene.anu.edu.au/lines/lines.zip),
or the Bitbucket repository:  [downloads area](https://bitbucket.org/RalphSutherland/lines/downloads)

Get the zipped code archive, `unzip`, `cd` into it and `make` it.

There are no dependencies other than having a unix/linux like environment
(eg OSX) and a working C compiler (gcc 4.8 or newer, or the Xcode cc compiler etc).

* lines homepage URL: [https://miocene.anu.edu.au/lines](https://miocene.anu.edu.au/lines)
* lines Bitbucket URL: [https://bitbucket.org/RalphSutherland/lines](https://bitbucket.org/RalphSutherland/lines)

# Build

      > make
      > sudo make install
      > make clean

### lines

# Useage:

     lines: Spectral line measurements.
     Useage: lines [-c -d -s subFile -p n[:m] -b n[:m] -r n[:m]] -l patchList [-n nlines ] spectrumFile
       Args: required: -l patchList (see example list.txt for format)
             required: spectrumFile, two cols, wavelength - flambda
                       file can be text or text.gz file
                       n header lines (default 0) and then two columns:
                       Lambda  Flambda\n\n");
             optional: -n number of header lines in spectrumfile, default 0
             optional: -r n or -r n:m print output for just line #n or lines #n:m
             optional: -c output the continuum quadratic coefficients, a, b, c: a + bx + cx^2
             optional: -s output the spectrum with all gaussian lines subtracted, leaving residual continuum
             optional: -p n or -p n:m print out line fit +/- 3FWHM,
                        for line #n or #n to #m, -p 0 for all lines
             optional: -f as p but prinout each line fit over full patch, not just  +/- 3FWHM
             optional: -b as p but with patch centred on the line
             optional: -d output debugging information - especially to renumber patches
     Output: std out line fits suitable for csv/text file, redirect to a csv filename for example

### lines Useage Options

* The spectrum and/or the line list files may be gzipped or not, output is alway uncompressed.
* spectrum file name must be the last argument

        -l patchList        The file that lists all patches to measure,
                            patches outside the range of the spectrum are ignored.

        -s subFile         output a spectrum into subFile with all gaussian lines subtracted,
                           leaving just continuum data, patch continuua are not subtracted.

        -r n or -r n:m     print output for just line #n or lines #n to m inclusive
                           uses line number as shown in the output list, __NOT__ patch numbers
                           useful to limit output to a few problem lines while adjusting the patch file.

        -d                 output debugging information - printing warnings,
                           and printing out the patches as the code read them,
                           very useful to clean and renumber patch files that are becoming messy

        -p n or -p n:m     print out full line fits for line #n or #n to #m, use 0 for all lines
                           uses line number as shown in the output list, __NOT__ patch numbers.
                           Prints the just the region within 3 FWHM of the line centre for each line.

        -f                 Same as p but with printout over full patch. not just +/- 3FHWM

        -b                 Same as p but with coordinates centred on the line centre

        -n                 number of header lines in spectrumfile to skip over,
                           default 0, optional

        -c                 output the continuum quadratic coefficients,
                           a, b, c: a + bx + cx^2, otional

### listlines

In addition a utility called `listlines` that reads a patch file and lists it as a table or as a renumbered patch file
is made at the same time:

     listlines: Tabulate a summary of a patchfile
       Useage: listlines [-d] patchList
           Args: required: patchList (see example list.txt for format)
                 optional: -d re-output as patches - especially to renumber patches
         Output: std out line fits suitable for csv/text file, redirect to a csv filename for example

### listlines Useage Options

* patchlist file name must be the last argument

        -d                 output debugging information -
                           printing out the patches as the code read them,
                           and renumbering the patches.  Applies global settings
                           and writes the equivalent individual patches generated
                           - useful for checking global resolution

### Basic lines Examples
eg

    > lines -l list.txt spectrum.txt

or

    > lines -l list.txt spectrum.txt > output.csv
    > open output.csv
to save the output and open it with an app, say Excel or other spreadsheet.


To plot the solutions over the original spectrum, save the patch fit details with `-p 0` to a file and plot
with your favourite plotter, eg Graf.

    > lines -p 0 -l list.txt  spectrum.txt > solutions.txt
then open spectrum.txt and solutions.txt with the plotter and plot...

![Spectrum with Solutions overplotted.](fit.png)

To get a copy of the spectrum with the fitted lines removed, use -s to
specify the new file name;

    > lines -s subtracted.txt -l list.txt  spectrum.txt > solutions.txt
then open spectrum.txt and subtracted.txt and plot to compare.

# Line measurement line target list format

  The spectrum is divided into patches, each patch has a
  left and right continuum region, which is fit and
  subtracted before one or more gaussian components are fit.

  Residual RMS is computed after subtracting the line and continuum
  fit from the patch and averaging over 3&times;FWHM centred on the line centre,
  and ratiod with the line peak in the output.

  Covariance values of 1 sigma for the gaussian height and width coefficients,
  and the continuum constant coefficient 1 sigma, are added in quadrature to get
  an estimate of the 1 sigma uncertainty in the line total flux, expressed as a percentage
  of the total flux in the output.

  The line list is made of `keyword = value` pairs and any
  number of comment and blank lines.  Keywords can appear in
  any order, and can be grouped for convenience.

  Ranges are denoted with a colon, ie `-1.00:3.00` is a range
  from -1 to +3 comments are protected with a # character in
  any line

#  Keywords:

Keywords are CaSe sensitive!

The input patch list file is a commentable list of keywords and values, as a plain text file.
The keywords are case sensitive. Keywords can appear in any order.  `#` characters comment to the end of the line they eppear in.

lines will scan the patch list file for as many patches as it can find.  Each used the number in the file
as an ID number: patchNumber.lineNumber, eg 004.01 is patch 4 line 1.  when actually read in not all patch numbers may
or need be present, patch 003 may be missing.  The code will take the lines in increasing order as found.  Use the -d option to
create output that renumbers the patches back to starting with 001 and increasing in order.

A patch is found when at a minimum a `Patch_XXX_Line` or `Patch_XXX_nLines` keyword is found.  The other keywords for the patch are
then searched for, and default values are used for any missing information.

So the minimum patch (and minimum entire patchFile) is like this, an approximate wavelength and an estimated width:

        Patch_001_Line   = 3697:0.7

There are many more keywords available to control the continuum selection,
masking, fitting order, and deblending options for patches with multiple close lines.

Once all the patches that can be found are read, the code looks for each one in the spectrum,
and lists the results for each line found in the patches, counting the lines in the output,
and noting which patch they came from so they can be traced back to the patch list if needed.

### Keywords for All Patches:

There are a couple of global keywords that allow defaults to be set, to use if a patch doens't specify a parameter explicitly:

        Global_Order   = n         # n = 0, 1, 2, order of fit to use unless overridden in a patch

        Global_Width   = width     # width of a line to use if not specified, ie
                                   # if  Patch_XXX_Line   = centre  and no width paramter is used, not
                                   # recommended unless desperate. :)

        Global_Resolution = res    #  res > 0.0, preferably equal to the instrumental, eg 5000.0
                                   # if  Patch_XXX_Line   = centre  and no width paramter is used,
                                   # a width is computed from the resolving power,
                                   # width = centre/res, assuming the real line
                                   # is unresolved, eg in HII regions.

These keywords are optional and can be left out.  Order defaults to 2, Width to 1.0 and resolution is set to 0.0 so that
if it is not specified and a patch line is incomplete an error will occur.

### Keywords for each Patch:

* Within a patch there can be either a single line, as a range:

        Patch_XXX_Line   = centre:width

  The centre and width can be approximate, accurate enough only to get the algorithm to converge initially.
  the line number is 01 implicitly, so the line id will be XXX.01.
  This scheme works best if the intial line centre estimate is accurate within  &plusmn; a single spectrum resolution bin

* or, a list of lines for the patch using an optional `nLines` keyword for the number of lines to find in the patch.

        Patch_XXX_nLines  = nl  #  (nl > 0)
        Patch_XXX_Line_00 = centre:width
        Patch_XXX_Line_01 = centre:width
                      ....
        Patch_XXX_Line_NL = centre:width

   for line `NN` of patch `XXX`, etc  the line ID will be XXX.NL, leading zeros are kept.

The continuum region can be specified:

  * If the line is isolated and surrounded by good continuum, all that is needed is the initial
line centre and a line FWHM value, and *lines* will assume the continuum starts at -5 FWHM to
 -2.5 FWHM and then again at 2.5 FWHM - 5 FWHM, either side of the line centre.
In this case a line is specified simply as:

            Patch_XXX_Line    =  centre:width

  Note, it is important to check the fit (use the `-p [n [:m] | 0 ]` option to print the solutions )

  * If the line has a more complex patch then you should manually specify the left and right continuum regions:

            Patch_XXX_Left    = l0:l1  # range of left continuum area in patch XXX (include leading 0s)
            Patch_XXX_Right   = r0:r1  # of right continuum area in patch XXX (include leading 0s)
This is the preferred method, and the regions should be wide enough to cover several or more spectrum points each, and can even be
quite far from the target line if necessary. Use the range limits to avoid fitting nearby lines or spectrum defects, where the
automatic continuum specifiction above can fail.

  * If the left and right continuum regions are specified with a single number, not a range:

            Patch_XXX_Left    = l0  # left continuum point patch XXX
            Patch_XXX_Right   = r0  # right continuum point patch XXX
or the ranges will only cover one spectrum point each, a linear continuum fit, a straight line between l0 and r0
will be used instead of a quadratic fit.

  * A linear fit can be forced even with a range of continuum with the
`Order` keyword:

            Patch_XXX_Order   = 1      # order of continuum fit override, 0 = const (fit), 1 = linear, 2 or more quadratic

  * If the patch specifies a constant continuum value, this value is simply subtracted and only the line is fit
over a patch &plusmn;1 FWHM, or over the Left and Right ranges if specified.

            Patch_XXX_Continuum = value  # continuum constant for entire patch XXX, *not fit*, order = 0

  * If the patch specifies a constant continuum _range_, this value is simply subtracted and only the line is fit
over a patch.  The continuum range is given as the
estimated continuum at the left and right limts of the patch, or at &plusmn;1 FWHM if no patch limits are given

            Patch_XXX_Continuum = leftValue:rightValue   # continuum constant+  linear slope for entire patch XXX, *not fit*, order = 1

  * If the patch part of the patch contains a bad region, those points can be excluded with a mask region.

            Patch_XXX_Mask = m0:m1  # range of masked points, must be a range not a single point

   *lines* will find the nearest data points to the ranges given in an inclusive way.

### Examples:

#### A single line patch, auto continuum selection,

       # Balmer line
       Patch_001_Line   = 3750.0:0.7

#### A single line patch, manual continuum ranges, quadratic continuum fit,

       # High Balmer line quadratic continuum
       Patch_001_Left   = 3689.0:3689.5
       Patch_001_Right  = 3693.5:3694.0
       Patch_001_Line   = 3691.5:0.5

#### A single line patch, manual continuum ranges, linear continuum fit,

       # High Balmer line - linear continuum
       Patch_001_Left   = 3689.0
       Patch_001_Right  = 3694.0
       Patch_001_Line   = 3691.5:0.5

#### A single line patch, constant continuum, for most difficult fits

       # High Balmer line - fixed continuum
       Patch_001_Line   = 3691.5:0.5
       Patch_001_Continuum  = 5.0

#### Multiple lines in a patch, with auto continuum

       #
       # [OII] doublet
       #
       Patch_001_nLines  = 2
       Patch_001_Line_01 = 3726.0:0.7
       Patch_001_Line_02 = 3729.0:0.7

#### Multiple lines in a patch, with manual continuum

       #
       # [OII] doublet
       #
       Patch_001_Left    = 3723:3724.5
       Patch_001_Right   = 3730.5:3733
       Patch_001_nLines  = 2
       Patch_001_Line_01 = 3726.0:0.7
       Patch_001_Line_02 = 3729.0:0.7

#### A single line patch, manual continuum ranges, masking out a subrange!,

       # Paschen Line
       Patch_001_Left  = 8308.0:8312.0
       Patch_001_Right = 8316.5:8318.0
       Patch_001_Mask  = 8310.0:8312.5 # mask out a dip
       Patch_001_Line  = 8314.1:1.4

#   Optional Advanced keywords:

 When deblending lines it is sometimes helpful to fix the width and/or the line centres of the lines in a patch.  The algorithm always solves for the peak height.

 To fix the widths, add:

        Patch_XXX_Fixed_Widths = 1  # >0 fixed, 0 free

 to a patch group. Any integer > 0 with cause the widths to be
 fixed -- the line widths are then held constant in the solutions.
 To free the widths set `Fixed_Widths` to 0 or delete it:

        Patch_XXX_Fixed_Widths = 0

 To fix the centres, add:

        Patch_XXX_Fixed_Centres = 1  # >0 fixed, 0 free

 to a patch group. Any integer > 0 with cause the centres to be
 fixed -- the line widths are then held constant in the solutions.
 To free the centres, set `Fixed_Centres` to 0, or delete it:

        Patch_XXX_Fixed_Centres = 0

Fixed Widths and Centres can be set both or either independently.

Note  'Centers' in keywords works as well as 'Centres' :)

## Gaussian or Lorentzian

The default patch line fitting option is to fit gaussian line profiles.
The keyword:


        Patch_XXX_Lorentz = 1  # >0 fit Lorentzians instead, 0 don't

Changes all the lines in a patch to be fit with Lorentzian profiles instead.
The Lorentzian profile is numerically less stable when fitting than a Gaussian profile,
so more care is needed with the initial estimates of parameters and fixing of centres and or widths is also
commonly needed.  Check the resulting fit carefully!

Future versions will allow mixing of Lorentzians and Gaussians in a single patch.

