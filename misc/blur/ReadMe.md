# blur v1.0.8
RSS

## command: blur

### Convolve spectra and continuum flambda spectra
Convolve a single flambda spectrum or a spectrum and continuum
and make a normalised spectrum - even if both spectra are very different resolutions or ranges.  Start end and Delta Lambda bins can be set plus velocity, gaissian or box or rotation convolution are possibe.

Doxygen:  <a href="blue_html/index.html"> Doxygen Documentation</a>

Reads <cr> terminated lines (classic mac), and <lf> lines (linux, unix, OSX), as well as PC <lf>+<cr> lines.

Reads txt.gz or .txt plain files.

### Build

To build the `blur` command:

      1) >cd blur/

      2) >make

      3) >make clean

### Install

      4) >make install

### Uninstall

      5) >make uninstall


### Usage:

      > ~/mappings520/bin/blur

for the useage info:

  Useage: blur [-s] [-d dlambda][-l headerlines] [-n min lambda] [-m maxlabda] [-r resolvePower] [-f fwhm] [-v vsini] flux25file cont25file

      Args: optional -s use single spectrum - no normalising continuum
            optional resolvePower: positive float, lambda/dlambda
            optional  fwhm: gaussian positive float, km/s
            optional vsini: rotation positive float, km/s
            if -r -f -v are omitted or all <= 0.0, no convolution is performed
            default 3300.25, wave optional min -n minwave
            default 8934.25, wave optional max -m maxwave
            default 0.25 A -d dLam, optional output bin resolution
            default 7 header lines -l lines optional  and then two columns
    Required: Input files can be text or text.gz files
            lambda <3295.0A >9005.0A 0.25A bins
            Lambda   Flambda
    Output: lambda 3300.0A - 9000.0A 0.25A bins
            lambda, flux, continuum, normalised flux
            suitable as a 4 column csv file

## Convolve, Rebin and Normalise Result with Continuum

If -s is not used and two spectra are specified, the second is the continuum, often the MAPPINGS model.  Divide convolved and resampled contiuum into the  same convolved and resampled range. Output is a new binned spectrum, spec, cont, normalised spectrum as a 4 column .csv file with continuum = 1.0.

    > blur -r 6800.0 -l 4 fluxfile contfile

takes fluxfile with 4 header lines and contfile with 4 header lines and creates a R6800 spectrum fro 3300-8950A matching a WiFes spectrum with 0.25A bins.

### Single Spectrum Convolve and Resample

If -s is used and one spectra is specified, the continuum is not used. The spectrum is convolved and resampled as above.  Output is new binned spectrum, spec, spec, and constant column = 1.0 everywhere as a 4 column .csv file in the same format as the first mode, but without a model continuum.

    > blur -s -f 50.0 -l 7 fluxfile

Convolves and rebins a 7 header line file of any resolution to 0.25A bins and 3300-8950A matching a WiFes spectrum, convolved with a 50.0 km/s gaussian.

