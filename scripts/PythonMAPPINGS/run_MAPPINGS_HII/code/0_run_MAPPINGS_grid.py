from __future__ import print_function, division
from collections import OrderedDict  # OrderedDict isn't included in the standard library in Python 2
import input_templates  # Stores default MAPPINGS inputs
import grid_caller   # Calls MAPPINGS in parallel


"""
A script for running MAPPINGS grids using "multiprocessing".
Note: For correct terminal output, run at command line ("python script.py"),
NOT in the interpreter.  This is for technical reasons I don't understand.
"""


cpus = 20           # Number of cpus to use
LOCAL_TEST = False   # Doing a local test?
DRY_RUN = False     # Skip actually running MAPPINGS, but create scripts?


parent_dir = "/avatar/silaslee/run_MAPPINGS_HII/"  # tosca
# The "grid", "scripts", "custom_inputs" dirs are below parent_dir
grid_config = {
    # Grid is run in the "parent_dir" listed here, unless test == True
    # This dir must contain empty "grid" and "spectra" dirs
    "parent_dir" : parent_dir,
    # No. of iterations to achieve target total pressure where H is 50% ionized
    "n_P_iters" : 0,  # Total number of MAPPINGS runs for a gridpoint is n_P_iters + 1.
    "table_OH" : "custom_inputs/Table_log_OH_12_Z_and_depletion.csv",  # under parent_dir
    # Input parameters - these are manipulated (e.g. un-logarithmed)) before input.
    # Numbers are represented here as floats, not strings.  A run will be done
    # with every possible combination of parameters in the provided lists.
    # If key names in the ordered dict below identical to keys in the relevant
    # template dictionary from input_templates.py -> those values overriden.
    "param_dict" : OrderedDict([
        # ("E_peak", [-2.0, -1.75, -1.5, -1.25, -1.0, -0.75]), # log10(E/keV)  # Epeak set to 18, 33, 43 eV
        # ("Gamma", [1.3, 1.6, 1.9, 2.2, 2.5]), # Photon index
        #        # Negative of power law slope for high-energy component (dimensionless)
        #        # See Fig 4 in http://dx.doi.org/10.1051/0004-6361:20042592
        #        #   for Gamma distribution of X-ray bright sources
        # ("p_NT", [0.15]),#[0.05, 0.15, 0.35, 0.7]), # Frac of total power in hard non-thermal component
        ("UH_at_r_inner", [-4.00, -3.75, -3.50, -3.25, -3.00, -2.75,
                           -2.50, -2.25, -2.00]),  # U(H) at inner radius. LOG HERE OVER WHOLE RANGE
        ("Press_P/k",  [4.0, 5.4, 5.8, 6.2, 6.6, 7.0, 7.4, 8.0]),  # log10 pressure (P/k)
        ("abund", [7.150, 7.750, 8.150, 8.427, 8.632, 8.760, 8.850, 8.943, \
                   8.997, 9.096, 9.180, 9.252]), # Abundances
        # ("NoDust_UH", []), #[-1.5] Cutoff U(H) value at which dust is destroyed.  Log10 over whole range.
        ("dust_scenario", ["DN"]), #["DN","DF","DD"]),
                # DF: Dust Free, DN: Dust with No destruction, DD: Dust with Destruction
                # Keys for template ordered dicts in input_templates.templates dict
                # contain these dust scenario codes.
        ]),
}



#============================================================================
MAPPINGS_config = {
    "version" : "5.1.18",
    # "parent_dir" - parent directory of "lab" directory
    "parent_dir" : "/home/silaslee/MAPPINGS/",
    "executable_name" : "map51", # Name of executable in lab directory
}
MAPPINGS_config["dry_run?"] = DRY_RUN


#============================================================================
if LOCAL_TEST:
    print("\n\n=========== RUNNING LOCAL TEST!!!!! ===========\n\n")
    # "test_MAPPINGS_dir - parent directory of "lab" directory
    test_MAPPINGS_dir = "/Users/silaslee/MAPPINGS/"
    MAPPINGS_config["parent_dir"] = test_MAPPINGS_dir
    test_grid_dir = "/Users/silaslee/Desktop/run_MAPPINGS_HII/"
    grid_config["parent_dir"] = test_grid_dir
    grid_config["n_P_iters"] = 0
    cpus = 1
    # Make a much smaller grid:
    n_gridpoints = 1
    for p, p_list in grid_config["param_dict"].items():
        if len(p_list) > 2: # For a long list, include only the first value
            limit = 2 if n_gridpoints < 5 else 1
            grid_config["param_dict"][p] = grid_config["param_dict"][p][:limit]
            n_gridpoints *= limit



#============================================================================
# Dictionary of MAPPINGS input templates, one for each dust scenario
templates = input_templates.templates

# Actually run the grid:
if __name__ == '__main__':
    # Shouldn't really need this check - this file should only be used as a script.
    Grid = grid_caller.MAPPINGS_grid(templates, grid_config, MAPPINGS_config)
    grid_caller.run_grid( Grid, n_cpu=cpus )

print("Done.")
