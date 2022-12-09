from __future__ import print_function, division
import numpy as np
import os
import pandas as pd
import re # regular expressions
from collections import OrderedDict as OD
import itertools
from io import StringIO



"""
Loop throught gridpoints of a MAPPINGS grid, where there is a directory for
each gridpoint, and each gridpoint directory is named after its parameters.
Extract line fluxes from the spec csv file in each directory.

Adam D Thomas April 2016- 2020
This version is for MAPPINGS 5.1 output.
It includes summing for line blends.
v3.0
Changes from version 2.0 - modified to use pandas instead of astropy for tables,
                          fix bug with missing lines, and deal with paths more nicely
v3.1 Include extracting model lengths from the photn file
v3.2 20200603  Modernise pandas usage a little
"""


proj_dir = "/Users/silaslee/Desktop/run_MAPPINGS_HII/"  # tosca
gridpath = proj_dir + "grid/"  # g=Gridpoint dirs in here
results_file = proj_dir + "Grid_line_fluxes.csv"  # Output of this script
linelist = proj_dir + "code/Linelist_for_results.csv" # lines to extract from each gridpoint
# We sum the lines in the linelist of blended lines:
bl_linelist = proj_dir + "code/Linelist_blended_lines_for_results.csv"
specfile = "spec0001.csv"  # What the specfiles are called in each gridpoint directory
# photnfile = "photn0001.ph6"
# The number in the specfile varies depending on the number of iterations for a gridpoint.
param_names = ["UH_at_r_inner", "Press_P/k", "abund", "dust_scenario"]  # One for each grid dimension
n_grid_dimensions = len(param_names)



#==============================================================================
dir_list = os.listdir(gridpath) # List all files and subdirectories
grid_pt_dirs = [i for i in dir_list if os.path.isdir(os.path.join(gridpath, i))]
# grid_pt_dirs contains directories only, e.g. "BBB-0.5_Gam1.6_NT_0.4_UH_-2.0"

n = len(grid_pt_dirs)  # Number of gridpoints

# Load table of lines we want to extract:
DF_linelist = pd.read_csv(linelist, sep=",")
# Remove any whitespace from field names:
DF_linelist = DF_linelist.rename(columns={c:c.strip() for c in DF_linelist.columns})
n_lines = len(DF_linelist)

# Load list of blended emission lines:
DF_blends_list = pd.read_csv(bl_linelist, sep=",")#, index_col="Line blend name")

# Initialise results table with nans:
# The first columns are for the gridpoint name and parameter values, and remaining columns are for fluxes
# There is a row for each gridpoint
DF_results = pd.DataFrame( OD(
            [("Gridpoint", np.zeros(n, dtype="|S72"))] +
            [(p, np.zeros(n) + np.nan) for p in param_names[:-1]] + # Gridpoint values numbers columns
            [(param_names[-1], np.zeros(n, dtype="|S72"))] +  # Gridpoint dust value column (string)
            [(l, np.zeros(n) + np.nan) for l in itertools.chain(DF_linelist["Name"],
                                                    DF_blends_list["Line blend name"])] # Line flux columns
                          )  )
# DF_results["D_50pc_ionised_cm"] = np.zeros(n) + np.nan
# DF_results["D_99pc_ionised_cm"] = np.zeros(n) + np.nan

line_results = np.zeros( (n, n_lines) ) + np.nan # Temporary, not including line blends yet

# Iterate over all gridpoints:
for j, dir_j in enumerate(grid_pt_dirs, start=0):
    # if j < 5: # To do a small number of iterations for debugging
    print("Processing for " + dir_j + "...")

    # First record parameters for this gridpoint in the results table:
    DF_results.at[j, "Gridpoint"] = dir_j
    # Convert 'E_p_-1.25_Gam_1.90_p_N_0.20_UH__-1.50_abu_050_NoD_-1.50_dus_DD'
    #    ->  ['', '_-1.25', '_1.90', '_0.20', '_-1.50', '_050', '_-1.50', '_DD']:
    val_strs = re.split( "|_".join([m[:3] for m in param_names]), dir_j )
    # Convert  ->  ['-0.75', '1.30', '0.10', '-1.00', 'DD'] :
    val_strs = [v[1:] for v in val_strs[1:]]
    for i, (param, val) in enumerate(zip(param_names, val_strs)):
        if param == "dust_scenario":  # Treat dust param differently
            DF_results.at[j, param] = val
        else:
            DF_results.at[j, param] = float(val)

    # # Extract model length from photn file.  We wrangle the text data first.
    # with open(os.path.join(gridpath, dir_j, photnfile)) as phtn_file_j:
    #     text_photn_j = phtn_file_j.read()  # Read all into memory
    # # Split at top of table of interest:
    # part_list =  text_photn_j.split("Description of each space step:")
    # # Split at bottom of table of interest:
    # part_list2 =  part_list[1].split("Model ended       Tfinal  DISfin    FHXF"
    #                                  "      TAUXF     Ending")
    # text_table =  part_list2[0][2:-3] # Remove line breaks at start and end
    # # Remove empty extra columns from header:
    # text_table = re.sub(r"     Log\<Q\(N\)\>     Log\<U\(N\)", "", text_table)
    # # Fix header alignments (probably doesn't matter...):
    # text_table = re.sub(r"Log\<P\/k\> ", " Log<P/k>", text_table)
    # text_table = re.sub(r"nt ", " nt", text_table)
    # # Too much precision in scientific notation!  It isn't read correctly
    # # by pandas.  We fix this:
    # text_table = re.sub(r"(\d{3})(\d{4})(E...)", r"\1\3    ", text_table)
    # # We crudely truncate precision by removing 4 digits before "E+03" etc.!
    # # Needed to replace the 4 removed digits with 4 spaces at end (fixed width)
    # table_buffer = StringIO(text_table)

    # # The data is now clean enough to read in to a table:
    # DF_j = pd.read_fwf(table_buffer, usecols=["<X>", "F_HII"])  # Fixed-width format
    # # Extract the model length, in terms of where the nebula is 50% and 99%
    # # ionised (if the model didn't run long enough, leave as NaNs)
    # if DF_j["F_HII"].min() <= 0.5:
    #     ind_50 = np.argmin(np.abs(DF_j["F_HII"].values - 0.5))
    #     DF_results.at[j, "D_50pc_ionised_cm"] = DF_j.loc[ind_50, "<X>"]
    # if DF_j["F_HII"].min() <= 0.01:
    #     ind_99 = np.argmin(np.abs(DF_j["F_HII"].values - 0.01))
    #     DF_results.at[j, "D_99pc_ionised_cm"] = DF_j.loc[ind_99, "<X>"]

    # Next extract the line fluxes from the spec file:
    # Note: in MAPPINGS 5.1, the output table (fixed-width csv) has
    # ", *" appended to some rows (i.e. an extra column with asterisks)
    # I do the following to remove it:
    with open(os.path.join(gridpath, dir_j, specfile)) as file_j:
        text_j = file_j.read()  # Read all into memory - the file size is in the tens of Kb.
        # Remove occasional extra column with asterisk at end of a row
        text_j = re.sub(r", \*", "", text_j)
        # The data should now be clean enough to be read in to a table:
        DF_spec_j = pd.read_csv(StringIO(text_j), skiprows=56,
                    # data_start seems not to count blank lines, so we're skipping
                    # the first ~12 lines of the table, which is fine.
                    names=["Lambda(A)", "E (eV)", "Flux (HB=1.0)",
                           "Species", "Kind", "Accuracy (1-5)"],
                    usecols=["Lambda(A)", "Flux (HB=1.0)"], sep=",")

    # Join the tables:
    DF_joined_j_0 = pd.merge(DF_linelist, DF_spec_j, how="left",
                             left_on="Lambda(A)", right_on="Lambda(A)")
    # Has cols 'Lambda(A)', 'Name', 'Flux (HB=1.0)'
    # The "left" join type ensures we have every row from the left table
    # Check to see if there was more than one match for any emission line:
    n_lines_found = len(DF_joined_j_0)
    if n_lines != n_lines_found:
        # At least one emission line must have been found at least twice
        # We will sum up all the fluxes of the same line
        # Create a new table, which won't have duplicates:
        joined_table_j = pd.DataFrame( OD([
                    ("Lambda(A)",     np.zeros(n_lines, dtype="<f8")         ),
                    ("Name",          np.zeros(n_lines, dtype="S9")          ),
                    ("Flux (HB=1.0)", np.zeros(n_lines, dtype="<f8") + np.nan),
                                          ])  ) # dtypes same as joined_table_j
        joined_table_j["Lambda(A)"] = DF_linelist["Lambda(A)"]
        joined_table_j["Name"]      = DF_linelist["Name"]
        # Go through the emission lines, summing up all instances of each:
        for k, name in enumerate(joined_table_j["Name"]):
            count = np.sum(DF_joined_j_0["Name"] == name)
            if count > 1:
                print("WARNING: " + str(count) + " fluxes found for line "
                      + name + ", they'll be summed...")
            joined_table_j.at[k, "Flux (HB=1.0)"] = 0 # Initialise
            for row in np.arange( n_lines_found ): # Iterate over rows of the table with duplicates
                if DF_joined_j_0.at[row, "Name"] == name: # This will be true at least once
                    joined_table_j.at[k, "Flux (HB=1.0)"] = \
                            (joined_table_j.at[k, "Flux (HB=1.0)"] +
                             DF_joined_j_0.at[row,"Flux (HB=1.0)"] )
                    # Note that if any of the values are nans, we'll end up with a nan.
    else:
        joined_table_j = DF_joined_j_0 # Just copy, as we don't need to sum duplicates

    # Write the table into temporary results array
    line_results[j][:] = joined_table_j["Flux (HB=1.0)"].values

# Fill in results table from line_results
for c in np.arange( line_results.shape[1] ):  # Iterate over columns
    col = DF_results.columns[1+n_grid_dimensions+c]
    DF_results[col] = line_results[:,c]

# Add up the blended line columns:
for row, blend in enumerate(DF_blends_list["Line blend name"]):
    blend_list = []  # Initialise list of names of lines in blend
    for i in ["1", "2", "3", "4"]:
        line_name = DF_blends_list.at[row, "Line "+i]
        if isinstance(line_name, str):
            if len(line_name) > 0:
                blend_list.append( line_name )
    for gridpt in np.arange(n):  # Iterate over rows of results table
        DF_results.at[gridpt, blend] = 0  # Initialise
        for line in blend_list:
            line_flux = DF_results.at[gridpt, line]
            if np.isfinite(line_flux):
                DF_results.at[gridpt, blend] = DF_results.at[gridpt, blend]+line_flux

# Warn if one column in DF_results has no data in it (the emission line was never found):
for i, col_name in enumerate(DF_results.columns, start=0):
    if i > n_grid_dimensions:  # Skip first (including text) columns:
        # print(col_name + ":  " + str(DF_results[col_name].values[0:3]))
        if np.sum(np.isfinite(DF_results[col_name])) == 0:
            print("WARNING: no data found for emission line " + col_name)

# Write out results:
DF_results.to_csv(results_file, float_format="%.4e", index=False)

print("Done.")
