from __future__ import print_function, division
from collections import OrderedDict


"""
A module to store MAPPINGS input templates

The dictionary "templates" holds templates that are themselves ordered dicts.
Each template has a version that runs to 50 percent neutral and one that runs
to 99 percent neutral.  The former is for iterations when trying to have the
correct pressure, and the latter is for the final iteration.

"DF" - Dust-Free
"DN" - Dust with No dust destruction
"DD" - Dust with dust Destruction



20170807 ADT - The templates were modified to load spectra for HII regions, not OXAF spectra.
20200603 ADT - Added new DN_99 that uses P6.  Old template is now "DN_99_P7".

"""

templates = {

    "DF_99" : OrderedDict([   # "DF": Dust Free - model with no dust
        # Finishes when H 99% neutral
        # An ordered dictionary of MAPPINGS inputs.
        # A template that must contain the exact number of
        # inputs that will be used for the run, in the correct order.
        # Its values (strings even for numbers) can be overwritten using keywords.
        # The "blank" keywords will be overwritten later.

        # This template has dust turned off

        #### Abundances, dust and depletions:
        ("Change_abund", "yes"),      # change abund
        ("Abund_file", "lgc/BLANK.abn"), # zeta = 2.0?  Is this right?
        ("Change_abund2", "no"),      # change abundance
        ("Abund_offsets", "no"),      # change abundance offsets
        ("kappa_dist", "no"),         # Use Kappa electron distributions  If yes:
        #("kappa", "1000"),           # Global Kappa value (2.0-1000.0, > 1000 = inf)
        ("Include_dust", "no"),       # Include dust?
        # ("Change_dep", "yes"),        # change depletions
        # ("Dep_file", "abund/unified_depletion/Depln_Fe_1.50.txt"),     # If changing depletions
        # ("Change_dep2", "no"),        # Change depletions
        # ("grain_destruct", "yes"),     # ????? Don't destroy grains - but I need free Fe for lines!
        # ("grain_U_limit", "U"),     # If dust destruct: Dust grain photionisation limit in terms of U(H)
        # ("NoDust_UH", "0.0")   # If dust destruct: Give U(H) dust limit (<=100 as log : [0.00] )
        # ("NoDust_T", "5.0")     # If dust destruct: Give dust temperature limit (<=10 as log : [5.00] )
        # ("grain_dist_model", "M"),    # Dust grain distribution model -  MRN distribution
        # ("Include_PAH", "no"),        # Include PAH molecules?  Only if including dust
        # ("C_PAH_dep", "0.3"),         #fraction of Carbon Dust Depletion in PAHs  #If PAH
        # ("PAH_switch", "Q"),          #:  PAH switch on QHDH < Value
        # ("PAH_switch_val", "4e2"),    #???PAH switch on Value
        # ("PAH_cospatial", "no"),      # graphite grains to be cospatial with PAHs
        # ("Eval_dust_temps", "no"),    # Evaluate dust temperatures and IR flux?
        #### Selecting model (P7):
        ("Model", "P7"),                # Photo. Abs. distance step, full cont
        ("Ionisation_balance", "D"),    # Default ionisation values
        #### Input ionising spectrum parameters:
        ("Ionisation_source", "K"),             # K: Input two column flux file (variable POINTS)
        ("In_spectrum_file", "blank"),  # Input spectrum file
        ("Skip_n_lines", "2"),     # Number of header lines to skip in input spectrum file
        ("x-units", "A"),          # F: Energy in keV, A: Wavelength Angstroms
        ("y-units", "B"),          # H: Specific energy flux F_E in (keV/cm^2/s)/keV,  B: Flam (ergs/cm^2/s/A)
        # Note: When/if I change to a spherically symmetric model, I'll need to
        # insert parameters here to scale the input spectrum
        ("Finish_sources", "X"),   # eXit with current source
        #### Other parameters:
        ("Include_CRs", "no"),     # Include cosmic ray heating
        ("Geometry", "p"),         # Geometry:  p=plane parallel, s=spherical
        ("Rad_transfer", "T"),     # Two-sided, outward only (default)
        #### Setting the physical structure:
        ("Density_structure", "B"),  # isoBaric, (const pressure)  ### NEW IN P7
        ("Pressure_structure", "A"), # isobaric, (const pressure)  ### CHANGED IN P7: Put "A" instead of "B" here for isoBaric
        ("Press_P/k", "blank"),         # Pressure (P/k, <10 as log)
        ("Init_temp", "2e5"),       # K, <10 as log.  Initial temperature - suggestion 1e4 is for HII regions, not AGN.  MAPPINGS will figure this out anyway.  Make sure not same as dust destruct temp!
        ("filling_factor", "1"),    # filling factor (0<f<=1) - a fudge factor related to line-of-sight clumpiness
        ("q_or_U_input", "U"),      # Give Ionizing Flux at inner edge by?  U  : Ionisation parameter U(H)
        ("UH_at_r_inner", "blank"), # U(H) at inner radius (Give U(H) at inner edge (<=0 as log) )
        ("Geom_dilution", "0.5"),   # Geometrical dilution factor (<=0.5), plane parallel only.  Should be 0.5 so that diffuse field sees half of the sky (2*pi sterad)
        #### Ionisation balance calculations:
        ("Ionisation_bal", "E"),    # Equilibrium ionization balance.
        ("Step_phot_frac", "0.03"), # Step value of the photon absorption fraction  MAD: 0.03 to 0.05
        ("End_condition", "A"),     # Ionisation bounded, 99% neutral
        ("Output", "A"),            # Standard output (photnxxxx,phapnxxxx)
        #### Finishing up:
        ("Run_name", "blank"),      # Name of run to go in file header - must be unique!
        ("Exit", "E")           ]),  # Exit when finished (when model has been run)



    "DF_50" : OrderedDict([   # "DF": Dust Free - model with no dust
        # Finishes when H 50% neutral
        # An ordered dictionary of MAPPINGS inputs.
        # A template that must contain the exact number of
        # inputs that will be used for the run, in the correct order.
        # Its values (strings even for numbers) can be overwritten using keywords.
        # The "blank" keywords will be overwritten later.

        # This template has dust turned off

        #### Abundances, dust and depletions:
        ("Change_abund", "yes"),      # change abund
        ("Abund_file", "lgc/BLANK.abn"), # zeta = 2.0?  Is this right?
        ("Change_abund2", "no"),      # change abundance
        ("Abund_offsets", "no"),      # change abundance offsets
        ("kappa_dist", "no"),         # Use Kappa electron distributions  If yes:
        #("kappa", "1000"),           # Global Kappa value (2.0-1000.0, > 1000 = inf)
        ("Include_dust", "no"),       # Include dust?
        # ("Change_dep", "yes"),        # change depletions
        # ("Dep_file", "abund/unified_depletion/Depln_Fe_1.50.txt"),     # If changing depletions
        # ("Change_dep2", "no"),        # Change depletions
        # ("grain_destruct", "yes"),     # ????? Don't destroy grains - but I need free Fe for lines!
        # ("grain_U_limit", "U"),     # If dust destruct: Dust grain photionisation limit in terms of U(H)
        # ("NoDust_UH", "0.0")   # If dust destruct: Give U(H) dust limit (<=100 as log : [0.00] )
        # ("NoDust_T", "5.0")     # If dust destruct: Give dust temperature limit (<=10 as log : [5.00] )
        # ("grain_dist_model", "M"),    # Dust grain distribution model -  MRN distribution
        # ("Include_PAH", "no"),        # Include PAH molecules?  Only if including dust
        # ("C_PAH_dep", "0.3"),         #fraction of Carbon Dust Depletion in PAHs  #If PAH
        # ("PAH_switch", "Q"),          #:  PAH switch on QHDH < Value
        # ("PAH_switch_val", "4e2"),    #???PAH switch on Value
        # ("PAH_cospatial", "no"),      # graphite grains to be cospatial with PAHs
        # ("Eval_dust_temps", "no"),    # Evaluate dust temperatures and IR flux?
        #### Selecting model (P7):
        ("Model", "P7"),                # Photo. Abs. distance step, full cont
        ("Ionisation_balance", "D"),    # Default ionisation values
        #### Input ionising spectrum parameters:
        ("Ionisation_source", "K"),             # K: Input two column flux file (variable POINTS)
        ("In_spectrum_file", "blank"),  # Input spectrum file
        ("Skip_n_lines", "2"),     # Number of header lines to skip in input spectrum file
        ("x-units", "A"),          # F: Energy in keV, A: Wavelength Angstroms
        ("y-units", "B"),          # H: Specific energy flux F_E in (keV/cm^2/s)/keV,  B: Flam (ergs/cm^2/s/A)
        # Note: When/if I change to a spherically symmetric model, I'll need to
        # insert parameters here to scale the input spectrum
        ("Finish_sources", "X"),   # eXit with current source
        #### Other parameters:
        ("Include_CRs", "no"),     # Include cosmic ray heating
        ("Geometry", "p"),         # Geometry:  p=plane parallel, s=spherical
        ("Rad_transfer", "T"),     # Two-sided, outward only (default)
        #### Setting the physical structure:
        ("Density_structure", "B"),  # isoBaric, (const pressure)  ### NEW IN P7
        ("Pressure_structure", "A"), # isobaric, (const pressure)  ### CHANGED IN P7: Put "A" instead of "B" here for isoBaric
        ("Press_P/k", "blank"),         # Pressure (P/k, <10 as log)
        ("Init_temp", "2e5"),       # K, <10 as log.  Initial temperature - suggestion 1e4 is for HII regions, not AGN.  MAPPINGS will figure this out anyway.  Make sure not same as dust destruct temp!
        ("filling_factor", "1"),    # filling factor (0<f<=1) - a fudge factor related to line-of-sight clumpiness
        ("q_or_U_input", "U"),      # Give Ionizing Flux at inner edge by?  U  : Ionisation parameter U(H)
        ("UH_at_r_inner", "blank"), # U(H) at inner radius (Give U(H) at inner edge (<=0 as log) )
        ("Geom_dilution", "0.5"),   # Geometrical dilution factor (<=0.5), plane parallel only.  Should be 0.5 so that diffuse field sees half of the sky (2*pi sterad)
        #### Ionisation balance calculations:
        ("Ionisation_bal", "E"),    # Equilibrium ionization balance.
        ("Step_phot_frac", "0.03"), # Step value of the photon absorption fraction  MAD: 0.03 to 0.05
        ("End_condition", "B"),     # Ionisation bounded, XII < Y
        ("End_element", "1"),       # Apply end ionisation condition to element 1 (H)
        ("End_ionisation_frac", "0.5"),  # End model when ionisation fraction of H reaches 0.5
        ("Output", "A"),            # Standard output (photnxxxx,phapnxxxx)
        #### Finishing up:
        ("Run_name", "blank"),      # Name of run to go in file header - must be unique!
        ("Exit", "E")           ]),  # Exit when finished (when model has been run)



    "DN_99" : OrderedDict([   # "DN": Dust with No grain destruction
        # USES P6 not P7
        # Finishes when H 99% neutral
        # An ordered dictionary of MAPPINGS inputs.
        # A template that must contain the exact number of
        # inputs that will be used for the run, in the correct order.
        # Its values (strings even for numbers) can be overwritten using keywords.
        # The "blank" keywords will be overwritten later.

        # This template has dust turned on, and not being destroyed

        #### Abundances, dust and depletions:
        ("Change_abund", "yes"),      # change abund
        ("in_abund_file", "BLANK.abn"), # zeta = 2.0?  Is this right?
        ("Change_abund2", "no"),      # change abundance
        ("Abund_offsets", "no"),      # change abundance offsets
        ("kappa_dist", "no"),         # Use Kappa electron distributions  If yes:
        #("kappa", "1000"),           # Global Kappa value (2.0-1000.0, > 1000 = inf)
        ("Include_dust", "yes"),       # Include dust?
        ("Change_dep", "yes"),        # change depletions
        ("in_depletion_file", "BLANK.txt"),     # If changing depletions
        ("Change_dep2", "no"),        # Change depletions
        ("grain_destruct", "no"),     # ????? Don't destroy grains - but I need free Fe for lines!
        # ("grain_U_limit", "U"),     # If dust destruct: Dust grain photionisation limit in terms of U(H)
        # ("NoDust_UH", "0.0"),   # If dust destruct: Give U(H) dust limit (<=100 as log : [0.00] )
        # ("NoDust_T", "5.0"),     # If dust destruct: Give dust temperature limit (<=10 as log : [5.00] )
        ("grain_dist_model", "M"),    # Dust grain distribution model -  MRN distribution
        ("Include_PAH", "no"),        # Include PAH molecules?  Only if including dust
        # ("C_PAH_dep", "0.3"),         #fraction of Carbon Dust Depletion in PAHs  #If PAH
        # ("PAH_switch", "Q"),          #:  PAH switch on QHDH < Value
        # ("PAH_switch_val", "4e2"),    #???PAH switch on Value
        # ("PAH_cospatial", "no"),      # graphite grains to be cospatial with PAHs
        ("Eval_dust_temps", "no"),    # Evaluate dust temperatures and IR flux?
        #### Selecting model (P7):
        ("Model", "P6"),                # Photo. Abs. distance step, full cont
        ("Ionisation_balance", "D"),    # Default ionisation values
        #### Input ionising spectrum parameters:
        ("Ionisation_source", "K"),             # K: Input two column flux file (variable POINTS)
        ("in_spectrum_file", "BLANK"),  # Input spectrum file
        ("Skip_n_lines", "1"),     # Number of header lines to skip in input spectrum file
        ("x-units", "F"),          # F: Energy in keV, A: Wavelength Angstroms
        ("y-units", "H"),          # H: Specific energy flux F_E in (keV/cm^2/s)/keV,  B: Flam (ergs/cm^2/s/A)
        # Note: When/if I change to a spherically symmetric model, I'll need to
        # insert parameters here to scale the input spectrum
        ("Finish_sources", "X"),   # eXit with current source
        #### Other parameters:
        ("Include_CRs", "N"),     # Include cosmic ray heating
        ("Geometry", "s"),         # Geometry:  p=plane parallel, s=spherical
        ("DF_source_lum", "L"),     # define by source luminosity (only for spherical)
        ("Total_or ion", "T"),     # total or ionising luminosity (only for spherical)
        ("bol_luminosity", "40"),   # bolometric luminosity (<100 as log) (only for spherical)
        # ("Rad_transfer", "T"),     # Two-sided, outward only (default) (only for plane parallel)
        #### Setting the physical structure:
        ("Density_structure", "B"),  # isoBaric, (const pressure)  ### NEW IN P7
        # ("Pressure_structure", "A"), # isobaric, (const pressure)  ### CHANGED IN P7: Put "A" instead of "B" here for isoBaric
        ("Press_P/k", "BLANK"),         # Pressure (P/k, <10 as log)
        ("Init_temp", "1e4"),       # K, <10 as log.  Initial temperature - suggestion 1e4 is for HII regions, not AGN.  MAPPINGS will figure this out anyway.  Make sure not same as dust destruct temp!
        ("filling_factor", "1"),    # filling factor (0<f<=1) - a fudge factor related to line-of-sight clumpiness
        ("q_or_U_input", "U"),      # Give Ionizing Flux at inner edge by?  U  : Ionisation parameter U(H)
        ("UH_at_r_inner", "BLANK"), # U(H) at inner radius (Give U(H) at inner edge (<=0 as log) )
        ("integrat_whole_spher", "y"), #volume integration over the whole spherical? (y/n) (only for spherical)
        # ("Geom_dilution", "0.5"),   # Geometrical dilution factor (<=0.5), plane parallel only.  Should be 0.5 so that diffuse field sees half of the sky (2*pi sterad)
        #### Ionisation balance calculations:
        ("Ionisation_bal", "E"),    # Equilibrium ionization balance.
        ("Step_phot_frac", "0.02"), # Step value of the photon absorption fraction  MAD: 0.03 to 0.05
        ("End_condition", "A"),     # Ionisation bounded, 99% neutral
        ("Output", "A"),            # Standard output (photnxxxx,phapnxxxx)
        #### Finishing up:
        ("run_name", "BLANK"),      # Name of run to go in file header - must be unique!
        ("Exit", "E")           ]),  # Exit when finished (when model has been run)


    "DN_99_P7" : OrderedDict([   # "DN": Dust with No grain destruction
        # Finishes when H 99% neutral
        # An ordered dictionary of MAPPINGS inputs.
        # A template that must contain the exact number of
        # inputs that will be used for the run, in the correct order.
        # Its values (strings even for numbers) can be overwritten using keywords.
        # The "blank" keywords will be overwritten later.

        # This template has dust turned on, and not being destroyed

        #### Abundances, dust and depletions:
        ("Change_abund", "yes"),      # change abund
        ("Abund_file", "lgc/BLANK.abn"), # zeta = 2.0?  Is this right?
        ("Change_abund2", "no"),      # change abundance
        ("Abund_offsets", "no"),      # change abundance offsets
        ("kappa_dist", "no"),         # Use Kappa electron distributions  If yes:
        #("kappa", "1000"),           # Global Kappa value (2.0-1000.0, > 1000 = inf)
        ("Include_dust", "yes"),       # Include dust?
        ("Change_dep", "yes"),        # change depletions
        ("Dep_file", "abund/unified_depletion/Depln_Fe_1.50.txt"),     # If changing depletions
        ("Change_dep2", "no"),        # Change depletions
        ("grain_destruct", "no"),     # ????? Don't destroy grains - but I need free Fe for lines!
        # ("grain_U_limit", "U"),     # If dust destruct: Dust grain photionisation limit in terms of U(H)
        # ("NoDust_UH", "0.0"),   # If dust destruct: Give U(H) dust limit (<=100 as log : [0.00] )
        # ("NoDust_T", "5.0"),     # If dust destruct: Give dust temperature limit (<=10 as log : [5.00] )
        ("grain_dist_model", "M"),    # Dust grain distribution model -  MRN distribution
        ("Include_PAH", "no"),        # Include PAH molecules?  Only if including dust
        # ("C_PAH_dep", "0.3"),         #fraction of Carbon Dust Depletion in PAHs  #If PAH
        # ("PAH_switch", "Q"),          #:  PAH switch on QHDH < Value
        # ("PAH_switch_val", "4e2"),    #???PAH switch on Value
        # ("PAH_cospatial", "no"),      # graphite grains to be cospatial with PAHs
        ("Eval_dust_temps", "no"),    # Evaluate dust temperatures and IR flux?
        #### Selecting model (P7):
        ("Model", "P7"),                # Photo. Abs. distance step, full cont
        ("Ionisation_balance", "D"),    # Default ionisation values
        #### Input ionising spectrum parameters:
        ("Ionisation_source", "K"),             # K: Input two column flux file (variable POINTS)
        ("In_spectrum_file", "blank"),  # Input spectrum file
        ("Skip_n_lines", "2"),     # Number of header lines to skip in input spectrum file
        ("x-units", "A"),          # F: Energy in keV, A: Wavelength Angstroms
        ("y-units", "B"),          # H: Specific energy flux F_E in (keV/cm^2/s)/keV,  B: Flam (ergs/cm^2/s/A)
        # Note: When/if I change to a spherically symmetric model, I'll need to
        # insert parameters here to scale the input spectrum
        ("Finish_sources", "X"),   # eXit with current source
        #### Other parameters:
        ("Include_CRs", "no"),     # Include cosmic ray heating
        ("Geometry", "p"),         # Geometry:  p=plane parallel, s=spherical
        ("Rad_transfer", "T"),     # Two-sided, outward only (default)
        #### Setting the physical structure:
        ("Density_structure", "B"),  # isoBaric, (const pressure)  ### NEW IN P7
        ("Pressure_structure", "A"), # isobaric, (const pressure)  ### CHANGED IN P7: Put "A" instead of "B" here for isoBaric
        ("Press_P/k", "blank"),         # Pressure (P/k, <10 as log)
        ("Init_temp", "2e5"),       # K, <10 as log.  Initial temperature - suggestion 1e4 is for HII regions, not AGN.  MAPPINGS will figure this out anyway.  Make sure not same as dust destruct temp!
        ("filling_factor", "1"),    # filling factor (0<f<=1) - a fudge factor related to line-of-sight clumpiness
        ("q_or_U_input", "U"),      # Give Ionizing Flux at inner edge by?  U  : Ionisation parameter U(H)
        ("UH_at_r_inner", "blank"), # U(H) at inner radius (Give U(H) at inner edge (<=0 as log) )
        ("Geom_dilution", "0.5"),   # Geometrical dilution factor (<=0.5), plane parallel only.  Should be 0.5 so that diffuse field sees half of the sky (2*pi sterad)
        #### Ionisation balance calculations:
        ("Ionisation_bal", "E"),    # Equilibrium ionization balance.
        ("Step_phot_frac", "0.03"), # Step value of the photon absorption fraction  MAD: 0.03 to 0.05
        ("End_condition", "A"),     # Ionisation bounded, 99% neutral
        ("Output", "A"),            # Standard output (photnxxxx,phapnxxxx)
        #### Finishing up:
        ("Run_name", "blank"),      # Name of run to go in file header - must be unique!
        ("Exit", "E")           ]),  # Exit when finished (when model has been run)



    "DN_50" : OrderedDict([   # "DN": Dust with No grain destruction
        # Finishes when H 99% neutral
        # An ordered dictionary of MAPPINGS inputs.
        # A template that must contain the exact number of
        # inputs that will be used for the run, in the correct order.
        # Its values (strings even for numbers) can be overwritten using keywords.
        # The "blank" keywords will be overwritten later.

        # This template has dust turned on, and not being destroyed

        #### Abundances, dust and depletions:
        ("Change_abund", "yes"),      # change abund
        ("Abund_file", "lgc/BLANK.abn"), # zeta = 2.0?  Is this right?
        ("Change_abund2", "no"),      # change abundance
        ("Abund_offsets", "no"),      # change abundance offsets
        ("kappa_dist", "no"),         # Use Kappa electron distributions  If yes:
        #("kappa", "1000"),           # Global Kappa value (2.0-1000.0, > 1000 = inf)
        ("Include_dust", "yes"),       # Include dust?
        ("Change_dep", "yes"),        # change depletions
        ("Dep_file", "abund/unified_depletion/Depln_Fe_1.50.txt"),     # If changing depletions
        ("Change_dep2", "no"),        # Change depletions
        ("grain_destruct", "no"),     # ????? Don't destroy grains - but I need free Fe for lines!
        # ("grain_U_limit", "U"),     # If dust destruct: Dust grain photionisation limit in terms of U(H)
        # ("NoDust_UH", "0.0"),   # If dust destruct: Give U(H) dust limit (<=100 as log : [0.00] )
        # ("NoDust_T", "5.0"),     # If dust destruct: Give dust temperature limit (<=10 as log : [5.00] )
        ("grain_dist_model", "M"),    # Dust grain distribution model -  MRN distribution
        ("Include_PAH", "no"),        # Include PAH molecules?  Only if including dust
        # ("C_PAH_dep", "0.3"),         #fraction of Carbon Dust Depletion in PAHs  #If PAH
        # ("PAH_switch", "Q"),          #:  PAH switch on QHDH < Value
        # ("PAH_switch_val", "4e2"),    #???PAH switch on Value
        # ("PAH_cospatial", "no"),      # graphite grains to be cospatial with PAHs
        ("Eval_dust_temps", "no"),    # Evaluate dust temperatures and IR flux?
        #### Selecting model (P7):
        ("Model", "P7"),                # Photo. Abs. distance step, full cont
        ("Ionisation_balance", "D"),    # Default ionisation values
        #### Input ionising spectrum parameters:
        ("Ionisation_source", "K"),             # K: Input two column flux file (variable POINTS)
        ("In_spectrum_file", "blank"),  # Input spectrum file
        ("Skip_n_lines", "2"),     # Number of header lines to skip in input spectrum file
        ("x-units", "A"),          # F: Energy in keV, A: Wavelength Angstroms
        ("y-units", "B"),          # H: Specific energy flux F_E in (keV/cm^2/s)/keV,  B: Flam (ergs/cm^2/s/A)
        # Note: When/if I change to a spherically symmetric model, I'll need to
        # insert parameters here to scale the input spectrum
        ("Finish_sources", "X"),   # eXit with current source
        #### Other parameters:
        ("Include_CRs", "no"),     # Include cosmic ray heating
        ("Geometry", "p"),         # Geometry:  p=plane parallel, s=spherical
        ("Rad_transfer", "T"),     # Two-sided, outward only (default)
        #### Setting the physical structure:
        ("Density_structure", "B"),  # isoBaric, (const pressure)  ### NEW IN P7
        ("Pressure_structure", "A"), # isobaric, (const pressure)  ### CHANGED IN P7: Put "A" instead of "B" here for isoBaric
        ("Press_P/k", "blank"),         # Pressure (P/k, <10 as log)
        ("Init_temp", "2e5"),       # K, <10 as log.  Initial temperature - suggestion 1e4 is for HII regions, not AGN.  MAPPINGS will figure this out anyway.  Make sure not same as dust destruct temp!
        ("filling_factor", "1"),    # filling factor (0<f<=1) - a fudge factor related to line-of-sight clumpiness
        ("q_or_U_input", "U"),      # Give Ionizing Flux at inner edge by?  U  : Ionisation parameter U(H)
        ("UH_at_r_inner", "blank"), # U(H) at inner radius (Give U(H) at inner edge (<=0 as log) )
        ("Geom_dilution", "0.5"),   # Geometrical dilution factor (<=0.5), plane parallel only.  Should be 0.5 so that diffuse field sees half of the sky (2*pi sterad)
        #### Ionisation balance calculations:
        ("Ionisation_bal", "E"),    # Equilibrium ionization balance.
        ("Step_phot_frac", "0.03"), # Step value of the photon absorption fraction  MAD: 0.03 to 0.05
        ("End_condition", "B"),     # Ionisation bounded, XII < Y
        ("End_element", "1"),       # Apply end ionisation condition to element 1 (H)
        ("End_ionisation_frac", "0.5"),  # End model when ionisation fraction of H reaches 0.5
        ("Output", "A"),            # Standard output (photnxxxx,phapnxxxx)
        #### Finishing up:
        ("Run_name", "blank"),      # Name of run to go in file header - must be unique!
        ("Exit", "E")           ]),  # Exit when finished (when model has been run)



    "DD_99" : OrderedDict([  # "DD": Dust with grain Destruction
        # Finishes when H 99% neutral
        # An ordered dictionary of MAPPINGS inputs.
        # A template that must contain the exact number of
        # inputs that will be used for the run, in the correct order.
        # Its values (strings even for numbers) can be overwritten using keywords.
        # The "blank" keywords will be overwritten later.

        # This template has dust turned on, and also being destroyed

        #### Abundances, dust and depletions:
        ("Change_abund", "yes"),      # change abund
        ("Abund_file", "lgc/BLANK.abn"), # zeta = 2.0?  Is this right?
        ("Change_abund2", "no"),      # change abundance
        ("Abund_offsets", "no"),      # change abundance offsets
        ("kappa_dist", "no"),         # Use Kappa electron distributions  If yes:
        #("kappa", "1000"),           # Global Kappa value (2.0-1000.0, > 1000 = inf)
        ("Include_dust", "yes"),       # Include dust?
        ("Change_dep", "yes"),        # change depletions
        ("Dep_file", "abund/unified_depletion/Depln_Fe_1.50.txt"),     # If changing depletions
        ("Change_dep2", "no"),        # Change depletions
        ("grain_destruct", "yes"),     # ????? Don't destroy grains - but I need free Fe for lines!
        ("grain_U_limit", "U"),     # If dust destruct: Dust grain photionisation limit in terms of U(H)
        ("NoDust_UH", "blank"),   # If dust destruct: Give U(H) dust limit (<=100 as log : [0.00] )
        ("NoDust_T", "10000000"),     # If dust destruct: Give dust temperature limit (<=10 as log : [5.00] )
                                        # This is set to a large value to ensure no dust destruction due to T criterion.
        ("grain_dist_model", "M"),    # Dust grain distribution model -  MRN distribution
        ("Include_PAH", "no"),        # Include PAH molecules?  Only if including dust
        # ("C_PAH_dep", "0.3"),         #fraction of Carbon Dust Depletion in PAHs  #If PAH
        # ("PAH_switch", "Q"),          #:  PAH switch on QHDH < Value
        # ("PAH_switch_val", "4e2"),    #???PAH switch on Value
        # ("PAH_cospatial", "no"),      # graphite grains to be cospatial with PAHs
        ("Eval_dust_temps", "no"),    # Evaluate dust temperatures and IR flux?
        #### Selecting model (P7):
        ("Model", "P7"),                # Photo. Abs. distance step, full cont   ##### NOTE - USING P7!!! #####
        ("Ionisation_balance", "D"),    # Default ionisation values
        #### Input ionising spectrum parameters:
        ("Ionisation_source", "K"),             # K: Input two column flux file (variable POINTS)
        ("In_spectrum_file", "blank"),  # Input spectrum file
        ("Skip_n_lines", "2"),     # Number of header lines to skip in input spectrum file
        ("x-units", "A"),          # F: Energy in keV, A: Wavelength Angstroms
        ("y-units", "B"),          # H: Specific energy flux F_E in (keV/cm^2/s)/keV,  B: Flam (ergs/cm^2/s/A)
        # Note: When/if I change to a spherically symmetric model, I'll need to
        # insert parameters here to scale the input spectrum
        ("Finish_sources", "X"),   # eXit with current source
        #### Other parameters:
        ("Include_CRs", "no"),     # Include cosmic ray heating
        ("Geometry", "p"),         # Geometry:  p=plane parallel, s=spherical
        ("Rad_transfer", "T"),     # Two-sided, outward only (default)
        #### Setting the physical structure:
        ("Density_structure", "B"),  # isoBaric, (const pressure)  ### NEW IN P7
        ("Pressure_structure", "A"), # isobaric, (const pressure)  ### CHANGED IN P7: Put "A" instead of "B" here for isoBaric
        ("Press_P/k", "blank"),         # Pressure (P/k, <10 as log)
        ("Init_temp", "2e5"),       # K, <10 as log.  Initial temperature - suggestion 1e4 is for HII regions, not AGN.  MAPPINGS will figure this out anyway.  Make sure not same as dust destruct temp!
        ("filling_factor", "1"),    # filling factor (0<f<=1) - a fudge factor related to line-of-sight clumpiness
        ("q_or_U_input", "U"),      # Give Ionizing Flux at inner edge by?  U  : Ionisation parameter U(H)
        ("UH_at_r_inner", "blank"), # U(H) at inner radius (Give U(H) at inner edge (<=0 as log) )
        ("Geom_dilution", "0.5"),   # Geometrical dilution factor (<=0.5), plane parallel only.  Should be 0.5 so that diffuse field sees half of the sky (2*pi sterad)
        #### Ionisation balance calculations:
        ("Ionisation_bal", "E"),    # Equilibrium ionization balance.
        ("Step_phot_frac", "0.03"), # Step value of the photon absorption fraction  MAD: 0.03 to 0.05
        ("End_condition", "A"),     # Ionisation bounded, 99% neutral
        ("Output", "A"),            # Standard output (photnxxxx,phapnxxxx)
        #### Finishing up:
        ("Run_name", "blank"),      # Name of run to go in file header - must be unique!
        ("Exit", "E")           ]),  # Exit when finished (when model has been run)



    "DD_50" : OrderedDict([  # "DD": Dust with grain Destruction
        # Finishes when H 50% neutral
        # An ordered dictionary of MAPPINGS inputs.
        # A template that must contain the exact number of
        # inputs that will be used for the run, in the correct order.
        # Its values (strings even for numbers) can be overwritten using keywords.
        # The "blank" keywords will be overwritten later.

        # This template has dust turned on, and also being destroyed

        #### Abundances, dust and depletions:
        ("Change_abund", "yes"),      # change abund
        ("Abund_file", "lgc/BLANK.abn"), # zeta = 2.0?  Is this right?
        ("Change_abund2", "no"),      # change abundance
        ("Abund_offsets", "no"),      # change abundance offsets
        ("kappa_dist", "no"),         # Use Kappa electron distributions  If yes:
        #("kappa", "1000"),           # Global Kappa value (2.0-1000.0, > 1000 = inf)
        ("Include_dust", "yes"),       # Include dust?
        ("Change_dep", "yes"),        # change depletions
        ("Dep_file", "abund/unified_depletion/Depln_Fe_1.50.txt"),     # If changing depletions
        ("Change_dep2", "no"),        # Change depletions
        ("grain_destruct", "yes"),     # ????? Don't destroy grains - but I need free Fe for lines!
        ("grain_U_limit", "U"),     # If dust destruct: Dust grain photionisation limit in terms of U(H)
        ("NoDust_UH", "blank"),   # If dust destruct: Give U(H) dust limit (<=100 as log : [0.00] )
        ("NoDust_T", "10000000"),     # If dust destruct: Give dust temperature limit (<=10 as log : [5.00] )
                                        # This is set to a large value to ensure no dust destruction due to T criterion.
        ("grain_dist_model", "M"),    # Dust grain distribution model -  MRN distribution
        ("Include_PAH", "no"),        # Include PAH molecules?  Only if including dust
        # ("C_PAH_dep", "0.3"),         #fraction of Carbon Dust Depletion in PAHs  #If PAH
        # ("PAH_switch", "Q"),          #:  PAH switch on QHDH < Value
        # ("PAH_switch_val", "4e2"),    #???PAH switch on Value
        # ("PAH_cospatial", "no"),      # graphite grains to be cospatial with PAHs
        ("Eval_dust_temps", "no"),    # Evaluate dust temperatures and IR flux?
        #### Selecting model (P7):
        ("Model", "P7"),                # Photo. Abs. distance step, full cont   ##### NOTE - USING P7!!! #####
        ("Ionisation_balance", "D"),    # Default ionisation values
        #### Input ionising spectrum parameters:
        ("Ionisation_source", "K"),             # K: Input two column flux file (variable POINTS)
        ("In_spectrum_file", "blank"),  # Input spectrum file
        ("Skip_n_lines", "2"),     # Number of header lines to skip in input spectrum file
        ("x-units", "A"),          # F: Energy in keV, A: Wavelength Angstroms
        ("y-units", "B"),          # H: Specific energy flux F_E in (keV/cm^2/s)/keV,  B: Flam (ergs/cm^2/s/A)
        # Note: When/if I change to a spherically symmetric model, I'll need to
        # insert parameters here to scale the input spectrum
        ("Finish_sources", "X"),   # eXit with current source
        #### Other parameters:
        ("Include_CRs", "no"),     # Include cosmic ray heating
        ("Geometry", "p"),         # Geometry:  p=plane parallel, s=spherical
        ("Rad_transfer", "T"),     # Two-sided, outward only (default)
        #### Setting the physical structure:
        ("Density_structure", "B"),  # isoBaric, (const pressure)  ### NEW IN P7
        ("Pressure_structure", "A"), # isobaric, (const pressure)  ### CHANGED IN P7: Put "A" instead of "B" here for isoBaric
        ("Press_P/k", "blank"),         # Pressure (P/k, <10 as log)
        ("Init_temp", "2e5"),       # K, <10 as log.  Initial temperature - suggestion 1e4 is for HII regions, not AGN.  MAPPINGS will figure this out anyway.  Make sure not same as dust destruct temp!
        ("filling_factor", "1"),    # filling factor (0<f<=1) - a fudge factor related to line-of-sight clumpiness
        ("q_or_U_input", "U"),      # Give Ionizing Flux at inner edge by?  U  : Ionisation parameter U(H)
        ("UH_at_r_inner", "blank"), # U(H) at inner radius (Give U(H) at inner edge (<=0 as log) )
        ("Geom_dilution", "0.5"),   # Geometrical dilution factor (<=0.5), plane parallel only.  Should be 0.5 so that diffuse field sees half of the sky (2*pi sterad)
        #### Ionisation balance calculations:
        ("Ionisation_bal", "E"),    # Equilibrium ionization balance.
        ("Step_phot_frac", "0.03"), # Step value of the photon absorption fraction  MAD: 0.03 to 0.05
        ("End_condition", "B"),     # Ionisation bounded, XII < Y
        ("End_element", "1"),       # Apply end ionisation condition to element 1 (H)
        ("End_ionisation_frac", "0.5"),  # End model when ionisation fraction of H reaches 0.5
        ("Output", "A"),            # Standard output (photnxxxx,phapnxxxx)
        #### Finishing up:
        ("Run_name", "blank"),      # Name of run to go in file header - must be unique!
        ("Exit", "E")           ]),  # Exit when finished (when model has been run)


}




 #  Choose a model ending :
 # ::::::::::::::::::::::::::::::::::::::::::::::::::::
 #    A  :   Radiation bounded, HII < 1.00%
 #    B  :   Ionisation bounded, XII < Y
 #    C  :   Temperature bounded, Tmin.
 #    D  :   Optical depth limited, Tau
 #    E  :   Density bounded, Distance
 #    F  :   Column Density limited, atom, ion
 #       :
 #    R  :   (Reinitialise)
 #    G  :   (Reset geometry only)


 #  Choose output settings :
 # :::::::::::::::::::::::::::::::::::::::::::::::::::::
 #    A  :   Standard output (photnxxxx,phapnxxxx).
 #    B  :   Standard + monitor 4 element ionisation.
 #    C  :   Standard + all ions file.
 #    D  :   Standard + final source + nu-Fnu spectrum.
 #    F  :   Standard + first balance.
 #    G  :   Everything



