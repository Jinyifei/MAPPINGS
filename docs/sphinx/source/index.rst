.. mapping documentation master file, created by
   sphinx-quickstart on Sun Jan 14 18:04:35 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

########
*Mappings*
########
--------------------------------------
Astrophysical equilibrium and time-dependent photoinisation and steady supersonic shock spectral emission code.
--------------------------------------

*mappings*is photoionisation and shock modelling code written in FORTRAN. It allows one to
compute nebular emission spectra from the far UV (~300 Å) to the far IR (>600 μ). 

*mappings* was originally written and descrbed by `Dopita and Sutherland (1995) <https://ui.adsabs.harvard.edu/abs/1996ApJS..102..161D/abstract>`_

Major improvements were made by 

* Add papers here.

*mappings*
calculates emission line fluxes for recombination lines, intercombination lines and
collisionally excited lines for all elements from hydrogen to zinc, where these exceed a
(presettable) minimum flux. MAPPINGS began in 1976 as a five-level-atom solver. It has
gone through major upgrades since then and is currently at version 5.1
It can be used to model HII regions, Plane
Planetary Nebulae, AGN emission regions and
shockwaves in the interstellar medium.


The code is is available on `Bitbucket  <https://bitbucket.org/RalphSutherland/mappings/src/master/>`_  

Issues regarding the code and suggestions for improvement the code regarding the should be reported there.  We actively 
encourage other to make use of the code for their own science.  
If anyone has questions about 
whether the code might be useful for a project, we encourage you to contact one of the authors of
the code.


If you make use of *mappings* in your published research we ask that you reference the following papers

* Add a more limited set of 





-------------
Documentation
-------------

Various documentation exists:

* A :doc:`Quick Guide <quick>` describing how to install and run Python (in a fairly mechanistic fashion).

For more information on how this page was generated and how to create documentation for *mapping*,
look at the page for :doc:`documentation on the documentation <meta>`.

-------
Authors
-------
The authors of the *mapping* code and their institutions are:


Ralph S Sutherland
  Research School of Astronomy & Astrophysics
  Australian National University

Add others


----------------------------------------

.. toctree::
   :titlesonly:
   :glob:
   :hidden:
   :caption: Documentation

   quick
   installation
   running_mapping
   input
   output
   operation
   radiation
   wind_models
   coordinate
   examples
   physics
   atomic
   meta
   *
