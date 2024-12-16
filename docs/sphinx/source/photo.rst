Photoionization
################

Photoionization computation is a non-trivial task of MAPPINGS.
The MAPPINGS code adpots the ``on-the-spot'' assumption with a ``outward only'' strategy to calculate the radiative field along the radius of the photoionized region.

Two simple geometries are implemented in MAPPINGS, *spherical* and *plane-paralle* geometries.
The spherical photoionized regions are suitable for the cases with a point-like ionizing sources, like the HII regions around star clusters and the narrow line regions (NLRs) around active galactic nucleus (AGN).


.. container::

   .. rubric:: Relevant modules
      :name: photo-modules
      
Historically, MAPPINGS have 4 versions of photoionization modules, P4-P7.
In the latest version of MAPPINGS, only P6 and P7 modules are reserved.
      
**P6:** is the mature module with robust photoionization calculations.

**P7:** is the experimental module with functions under developments. 


