from __future__ import print_function, division
from collections import OrderedDict as OD # Can use inbuilt collections.OrderedDict
                                          # in python >= 2.7
from itertools import product as it_product # Cartesian product
import logging # To write out a log file when we're done.
import multiprocessing as mp # Multiple processes to use many cores
import os  # for chdir
import subprocess # For calling MAPPINGS from python
import time # For using sleep and the time
import traceback # To trace errors in worker processes

import numpy as np
import pandas as pd


"""
A module to help run MAPPINGS, including running a grid of models and
running in parallel if desired.
Note: To have correct terminal output, run at command line ("python script.py"),
NOT in the interpreter.  This is for technical reasons I don't understand.

v2.4  NLR
ADT 2016 04 08: Fixed a major bug concerning the "'here' file" method
                of initialising MAPPINGS
ADT 2016 04 12: Refactored to use a more object-oriented approach,
                and iterations to allow desired pressure.
ADT 2017 08 02: Used absolute paths to abund and spec files
ADT 2020 06 04: Updated with improvements from shock and HII grid codes
"""


PRINT_EVERY = 100  # Print one in this many MAPPINGS output lines to log/terminal
LINK_DIRS = ["abund", "data"]  # "atmos",
DELETE_FILES = []  # Delete these outputs for every gridpoint
RAISE_ON_DIR_EXIST = False  # Treat an existing gridpoint dir as a completed run, or an error?




#=============================================================================
def check_for_repeat_lines( text_string ):
    """
    Check for repeats in a block of text.  If a set of lines is repeated,
    (directly after itself) this function returns True, otherwise False.
    This is used to check that the MAPPINGS setup worked, i.e.
    that no MAPPINGS command line prompts were repeated because
    there was a bad input.
    """
    mrl = 4  # Minimum length of repeated block (number of lines)
    text_list = text_string.split('\n')  # List of lines of text
    text_list = [l for l in text_list if l != ""] # Remove blank lines
    n = len( text_list )
    for i, line_i in enumerate(text_list):
        for j, line_j in enumerate( text_list[i+mrl:(n-i)//2], start=i+mrl ):
            # Search through lines for a line matching "line_i"
            # i and j are both line numbers (indices of text_list)
            if line_j == line_i:  # Lines match!
                for k in range(1,j-i):   # From 1 to j-i-1 inclusive
                    if text_list[j+(j-i)-k] != text_list[j-k]:
                        break
                else:
                    # If we've reached this point, we didn't break out of the
                    # "for" loop.  There was a repeat of length j-i lines!
                    print("Repeated text:", text_list[i:j])
                    return True

    return False



#=============================================================================
class MAPPINGS_grid(object):
    """
    An object representing a MAPPINGS grid.
    """
    def __init__(self, templates, grid_config, MAPPINGS_config):
        """
        Initialise MAPPINGS grid object

        templates: a dictionary with values being template ordered dictionaries.
                   Each ordered dictionary has the exact number of parameters
                   that will be used to run MAPPINGS, in the order they'll be
                   used.  The dictionary keywords are arbitrary parameter names
                   (as strings), and the dictionary values are the associated
                   input (as strings, even for numbers).
        grid_config: a dictionary with keys "parent_dir" (giving the path
                    of the parent directory of "grid", "custom_inputs" dirs),
                    "n_P_iters" (number of iterations to
                    achieve desired pressure), and "param_dict".  The
                    "param_dict" is an ordered dictionary of parameter names,
                    but with each
                    dictionary value being a list of all values (as numbers, not
                    strings) to use for that parameter. All possible combinations of
                    the parameter values listed in custom_dict will be made, and
                    if they have appropriate names will override the corresponding
                    default/filler values in the relevant template.  The keywords of
                    custom_dict should obviously correspond to the keywords in
                    the relevant template where required.  MAPPINGS will be run for
                    each possible combination of parameter values.
        MAPPINGS_config: a dictionary with keys "parent_dir" (giving the path
                    of the MAPPINGS directory (parent dir of "lab" dir),
                    "executable_name", and "version".
        """

        # Check types:
        if not type(templates) == dict:
            raise TypeError("templates must be a dict")
        for template in templates:
            if not type(templates[template]) == OD:
                raise TypeError("Each template must be an OrderedDict")
        if not type(grid_config) == dict:
            raise TypeError("grid_config must be a dict")
        if not type(grid_config["param_dict"]) == OD:
            raise TypeError("grid_config['param_dict'] must be an OrderedDict")
        if not type(MAPPINGS_config) == dict:
            raise TypeError("MAPPINGS_config must be a dict")

        # Create relevant attributes:
        self.templates = templates
        self.grid_config = grid_config
        self.MAPPINGS_config = MAPPINGS_config

        # Check that paths exist
        table_path = os.path.join(grid_config["parent_dir"], grid_config["table_OH"])
        for path_i in [MAPPINGS_config["parent_dir"], grid_config["parent_dir"],
                       table_path]:
            if not os.path.exists(path_i):
                raise ValueError("Path doesn't exist: " + path_i)

        # Set up grid inputs:
        # Create iterator giving all combinations of variables
        # N.B. grid_dict.values() is a list of lists which we use "*" to unpack
        # The lists are in order of grid parameters (it's an ordered dict)
        grid_dict = grid_config["param_dict"]
        param_tuple_iterator = it_product( *grid_dict.values() )

        grid_params = list(grid_dict.keys())  # in order (it's an ordered dict)
        grid_n = len(grid_params) # dimension of grid

        # Set up inputs for each gridpoint:
        gridpt_param_dicts = []  # List of grid parameter dicts for each gridpt
        for params in param_tuple_iterator:  # param tuple for each gridpoint
            dict_i = OD( [ (grid_params[a],params[a]) for a in range(grid_n) ] )
            gridpt_param_dicts.append( dict_i )

        self.gridpoint_dicts = gridpt_param_dicts
        self.n_gridpoints = len(gridpt_param_dicts)  # Number of gridpoints
        DF_abund_map = pd.read_csv(table_path)
        # Round the index to avoid floating point annoyances
        vals_OH = np.around(DF_abund_map["12 + log(O/H) nebular"], 3)
        DF_abund_map["12 + log(O/H) nebular"] = vals_OH
        DF_abund_map.set_index("12 + log(O/H) nebular", inplace=True)
        self.DF_abund_map = DF_abund_map



#=============================================================================
def run_grid(Grid, n_cpu=1):
    """
    Function that takes parameters for running MAPPINGS and
    then runs a MAPPINGS grid.
    To run a grid, create a MAPPINGS_grid object and then call run_grid()

    n_cpu: the number of cpus to distribute the runs over.  There will be a
               run for each possible combination of input parameters from
               grid_dict.  The default is 1 cpu.
    Note that this routine writes a log file.
    """

    # Change directory into the correct grid directory to run MAPPINGS:
    os.chdir(Grid.grid_config["parent_dir"])

    # Set up logging to both a log file and the console:
    logger1 = logging.getLogger('caller')  # "caller" - logger name
    logging.basicConfig( level=logging.DEBUG, filename=("MAPPINGS_grid_" +
                         time.strftime("%Y_%m_%d-%H_%M_%S") + ".log"),
                         filemode="w", format="%(message)s")
    # level=DEBUG: log everything,  filemode="w": write new file each time
    # format="%(message)s": Show just the message.  To include the time and
    # logging level can use "%(asctime)s %(levelname)s %(message)s".
    # Add a handler to logger, to log to the console as well as the file:
    ch = logging.StreamHandler() # StreamHandler logs to console
    ch.setLevel( logging.DEBUG )
    ch.setFormatter( logging.Formatter("%(message)s") )
    logger1.addHandler(ch)
    logger1.info("Initialising...")
    logger1.info("Using MAPPINGS version " + Grid.MAPPINGS_config["version"])
    t_0 = time.time()


    #----------------------------------------------------------------------
    # Run multiprocessing pool
    cpus_to_use = min(n_cpu, mp.cpu_count(), Grid.n_gridpoints)
    # N.B. number of cpus reported may be doubled due to "hyperthreading"
    logger1.info( "Running MAPPINGS grid of " + str(Grid.n_gridpoints) +
                  " gridpoints using " + str(cpus_to_use) + " cores"     )
    try:
        pool = mp.Pool(processes=cpus_to_use)
        manager = mp.Manager()
        tq = manager.Queue() # timing queue - to time and track worker runs
        lq = manager.Queue() # logging queue
        current_q_size = 0 # To track queue length (no. of finished gridpts)
        args = [(Grid, d, tq, lq) for d in Grid.gridpoint_dicts]
        #args = [1,2,3]
        #print("Running grid...")
        #print(args)
        #print(gridpoint_worker)
        # result = pool.map_async(gridpoint_worker, args) # Run grid!
        result = pool.map_async(gridpoint_worker, args) # Run grid!


        while True:  # A monitoring loop, to monitor the parallel runs:
            if lq.qsize() > 0:
                # If at least one log message was sent since last checked
                log_msg = lq.get()
                if log_msg[0:5] == "ERROR":
                    logger1.error( log_msg )
                else: logger1.info( log_msg )
            elif tq.qsize() > current_q_size:
                # If at least one run has completed since last checked
                while tq.qsize() > current_q_size:
                    current_q_size += 1
                    logger1.info( "--------- Completed " + str(current_q_size)
                                  + " of " + str(Grid.n_gridpoints) +
                                  " gridpoints ({0:%}) --------- ".format(
                                  current_q_size*1.0/Grid.n_gridpoints) )
            elif result.ready(): # If all gridpoints are finished
                break # Leave monitoring loop (all gridpoints are finished)
            time.sleep(0.01)  # So I'm not looping 100% of the time
    except KeyboardInterrupt:  # Probably need this or Ctrl+c doesn't work!
        logger1.error( "Caught KeyboardInterrupt, terminating workers" )
        pool.terminate()
        pool.join()
    except Exception as e: # Other exceptions
        traceback.print_exc()
        pool.terminate()
        pool.join()
        logger1.error( "ERROR: " + str(e) )
        raise e

    # Record final timing information once grid is finished:
    timings = []  # Initialise
    while tq.qsize() > 0:
        t_i = tq.get()
        if t_i > 0:  # If actual run (not a skipped gridpoint)
            timings.append(t_i)
    timings = np.array( timings )  # For stats
    if len( timings ) > 0:
        logger1.info( "Gridpoint times (s):  (min, median, max) = " +
                      "( {0:.2f}, {1:.2f}, {2:.2f} )".format( np.min(timings),
                                    np.median(timings), np.max(timings)) )
        logger1.info( "Mean gridpoint time (s): {0:.2f}".format(np.mean(timings)) )
    else: logger1.info( "No runs were successful" )
    logger1.info( "Time elapsed (s):  {0:.2f}".format( time.time() - t_0 ) )
    logger1.removeHandler(ch)  # Finish up

    print("Grid finished")



#=============================================================================
def gridpoint_worker(args):
    """
    This is a gridpoint worker, which runs one instance of MAPPINGS at a
    time, and performs any iterations for one gridpoint.

    gridpt_dict contains the single value for each grid parameter for this
    gridpoint.

    When the worker finishes all runs for a gridpoint, it will add the
    total run length for the gridpoint to the "timing" queue. Messages
    (including error messages) are added to the logging queue.

    Note: Only the photn*.ph(6/7) and spec*.csv output files are kept!
          All other MAPPINGS outputs are deleted.
    """
    # Useful:  http://sharats.me/the-ever-useful-and-neat-subprocess-module.html
    # Also :   http://stackoverflow.com/questions/6541109/send-string-to-stdin
    # And:     http://blog.endpoint.com/2015/01/getting-realtime-output-using-python.html
    #          http://seasonofcode.com/posts/python-multiprocessing-and-exceptions.html
    try:
        Grid, gridpt_dict, timing_queue, logging_queue = args  # Unpack args
        current_proc = mp.current_process()
        proc_num = current_proc._identity[0]  # Number of the current worker process
        start_time = time.time()


        #------------------------------------------------------------------
        # Set up the gridpoint:
        logging_queue.put("Worker " + str(proc_num) +
                             " is setting up a gridpoint..." )

        gridpt_name, spectrum_file, gridpt_exists = initialise_gridpoint(Grid,
                                          gridpt_dict, proc_num, logging_queue)
        if gridpt_exists:
            if RAISE_ON_DIR_EXIST:
                raise OSError("Directory " + gridpt_name + " already exists")
            else:
                # Gridpoint already existed, but we don't want an error.
                # Skip this gridpoint
                gridpt_time = -99  # Indicates gridpoint finished but wasn't run
                timing_queue.put(gridpt_time)
                logging_queue.put("--------- Worker " + str(proc_num) +
                  " skipping existing gridpoint " + gridpt_name + " ---------")
                return

        dust_scenario = gridpt_dict["dust_scenario"]  # "DF", "DN" or "DD"
        templates = Grid.templates.copy()
        n_P_iters = Grid.grid_config["n_P_iters"] # Number of pressure-correcting iterations

        # Make dictionary of common input values for all iterations
        common_dict = {}
        template_a = templates[ dust_scenario + "_99" ]
        for x, val in gridpt_dict.items(): # key x should always be a string
            if x in template_a:
                # N.B. Not all custom inputs are direct inputs into MAPPINGS
                # Also the param "NoDust_UH" is only used for "DD" dust scenario
                common_dict[x] = val  # N.B. Not converted to a string yet
        inputs_dir = os.path.join(Grid.grid_config["parent_dir"], "custom_inputs")

        log_OH_12 = np.around(gridpt_dict["abund"], 3)  # 12 + log O/H
        linear_O_zeta = Grid.DF_abund_map.at[log_OH_12, "linear_zeta_O_nebular"]
        abund_file = os.path.join(inputs_dir, "abundances",
                            "GC_ZO_{0:0>4.0f}.abn".format(linear_O_zeta*1000))
        if not os.path.exists(abund_file):
            raise ValueError("File not found: " + abund_file)
        common_dict["in_abund_file"] = abund_file

        DFe = Grid.DF_abund_map.at[log_OH_12, "log10(Fe_free/Fe_tot)"]
        depletion_file = os.path.join(inputs_dir, "depletions",
                                    "Depletions_Fe{0:0.2f}.txt".format(DFe))
        if not os.path.exists(depletion_file):
            raise ValueError("File not found: " + depletion_file)
        common_dict["in_depletion_file"] = depletion_file

        common_dict["in_spectrum_file"] = spectrum_file
        common_dict["run_name"] = gridpt_name

        # We need to translate values to match what MAPPINGS expects,
        # e.g. log over specified range
        # Translate U(H) values:  Log values over 0 need to be
        # un-logarithmed, as MAPPINGS expects <=0 as log, linear for >0
        UH = common_dict["UH_at_r_inner"]
        if UH > 0:  common_dict["UH_at_r_inner"] = str( 10**UH )
        if dust_scenario == "DD":
            UH_cut = common_dict["NoDust_UH"]
            if UH_cut > 100:
                common_dict["NoDust_UH"] = str( 10**UH_cut ) #(<=100 as log)
        # Note: MAPPINGS takes pressures < 10 as log.
        # This bit will need to be refactoresd if we want higher pressures:
        desired_P = float(common_dict["Press_P/k"])  # log10(P/k)

        #------------------------------------------------------------------
        # Do iterative MAPPINGS runs, adjusting pressure each time:
        iter_num = 0   # Initialise
        excess_P = 0   # Excess pressure in P/k
        while iter_num < n_P_iters:  # For all but the last iteration:
            # Do iterations that run MAPPINGS to 50% neutral
            run_dict = templates[ dust_scenario + "_50" ].copy()
            # Overwrite values in run_dict with input params for this run:
            for x, val in common_dict.items():
                run_dict[x] = val  # N.B. Not strings yet
            # Correct the pressure for this iteration:
            run_dict["Press_P/k"] = float(run_dict["Press_P/k"]) - excess_P
            # Check there are no more "blank" values
            if "blank" in run_dict.values() or "BLANK" in run_dict.values():
                raise ValueError("Not all parameters specified")
            #Ensure all the values are strings:
            for x in run_dict:  run_dict[x] = str( run_dict[x] )
            # Build the list of MAPPINGS inputs as a "'here' file" string:
            lines = []
            for k,v in run_dict.items():
                comment = "" if ("file" in k) else ("     : " + k)
                lines.append(v + comment)
            input_string = "\n".join(lines)
            # There are line breaks between commands in input_string,
            # but there aren't line breaks at the beginning or end.

            # Run MAPPINGS
            call_MAPPINGS(Grid, input_string, logging_queue, proc_num, gridpt_name)

            # Find the final pressure of the iteration, when H is 50% ionised
            # File suffix is "ph6" or "ph7" depending on whether we use P6 or P7
            f = "photn{:04d}.ph6".format(iter_num + 1)  # The new photn file
            process = subprocess.Popen( 'grep -B 3 "Model ended" ' + f,
                shell=True, stdout=subprocess.PIPE) # Remove symlinks
            grep_result = process.communicate()[0]
            list_results = grep_result.split()
            # The first 16-ish items in list_results are from the
            # last row of the table with details for each model step
            # (i.e. physical quantities for the last model step)
            # frac_HI  = float(list_results[11])  # Fraction of HI # P6 only
            # frac_HII = float(list_results[12])  # Fraction of HII # P6 only
            log_P = float(list_results[11])  # In log10(P/k)
            # Here the P/k index is 13 for P6 output and 11 for P7 output.
            excess_P = log_P - desired_P  # dex(P/k)
            # print("Worker " + str(proc_num) + " excess P of " +
            #       str(excess_P) + ", (HI, HII) = ", frac_HI, frac_HII)

            iter_num += 1


        #------------------------------------------------------------------
        # Do final MAPPINGS run, for last iteration
        run_dict = templates[ dust_scenario + "_99" ].copy()
        # Overwrite values in run_dict with input params for this run:
        for x, val in common_dict.items(): # key x should always be a string
            run_dict[x] = val  # N.B. val possibly not a string yet
        # Correct the pressure for the final iteration:
        run_dict["Press_P/k"] = float(run_dict["Press_P/k"]) - excess_P
        # Check there are no more "blank" values
        if "blank" in run_dict.values() or "BLANK" in run_dict.values():
            raise ValueError("Not all parameters specified")
        # Ensure all the values are strings:
        for x in run_dict:  run_dict[x] = str( run_dict[x] )
        # Build the list of MAPPINGS inputs as a "'here' file" string:
        lines = []
        for k,v in run_dict.items():
            comment = "" if ("file" in k) else ("     : " + k)
            lines.append(v + comment)
        input_string = "\n".join(lines)
        # There are line breaks between commands in input_string,
        # but there aren't line breaks at the beginning or end.

        # Run MAPPINGS
        call_MAPPINGS(Grid, input_string, logging_queue, proc_num, gridpt_name)


        #------------------------------------------------------------------
        # Finalise this gridpoint
        # Clean up some files:   # I take less care here than when creating
        # the symlinks, since it doesn't really matter if this fails
        command = ("rm " + " ".join(LINK_DIRS + DELETE_FILES) + " " +
                   Grid.MAPPINGS_config["executable_name"] )#+
                   # " phapn*.ph6 phlss*.ph6 phsem*.ph6 ")
        # File suffixes are "ph6" or "ph7" depending on whether we use P6 or P7
        if n_P_iters > 0:
            range_a = "000[1-" + str(n_P_iters) + "]"
            command += "spec" + range_a + ".csv photn" + range_a + ".ph6"
        subprocess.Popen(command, shell=True, stdout=subprocess.PIPE) # Remove symlinks

        counter = 0
        while counter < 5:
            # Try to change working dir 5 times before throwing error
            os.chdir("../../") # Need to return to starting directory
            if os.path.split(os.getcwd())[1] != run_dict["run_name"]:
                # Check we've left the run_dir
                break # Exit the while loop, since we're done
            else:
                time.sleep(0.05*proc_num+0.01) # Short wait before retrying
                counter += 1
        else:
            # Executed if the "while" condition becomes false, because we
            # didn't "break" the while loop successfully
            raise Exception( "ERROR: Unable to change working dir out of "
                             + gridpt_name )

        end_time = time.time()
        gridpt_time = end_time - start_time  #Run time in seconds
        logging_queue.put( "--------- Worker " + str(proc_num) +
                           " finished a gridpoint, in " +
                           str(int(gridpt_time)) + "s ---------" )
        timing_queue.put(gridpt_time)  # Indicates gridpoint is finished,
                                       # and contrubutes to timing stats
        logging_queue.put( "Worker " + str(proc_num) +
                           " finished gridpoint " + run_dict["run_name"])

    except KeyboardInterrupt:  # Probably need this or Ctrl+c doesn't work!
        raise Exception
    except Exception as e: # Other exceptions. N.B. Need this to see errors!
        exc1 = traceback.format_exc()  # Return traceback as string
        logging_queue.put( "ERROR (worker process " + str(proc_num)
                           + "): " + exc1 )
        raise e



#=============================================================================
def initialise_gridpoint(Grid, gridpt_dict, proc_num, logging_queue):
    """
    Do tasks to set up a run (or iterated runs) for one
    gridpoint of the grid.  This method is called by gridpoint_worker.
    - Construct the gridpoint name from gridpt_dict (ordered dictionary of
      parameter values for the gridpoint)
    - Create and setup the gridpoint directory, using the gridpoint name
      and the MAPPINGS parent directory and executable name from the
      Grid.MAPPINGS_config dictionary
    - Generate the spectrum for this gridpoint using the oxaf model and the
      parameters for this gridpoint, and save out the spectrum text file
    Returns (gridpoint_name, spectrum_filename, exists), where "exists" is
    True or False depending on whether the gridpoint dir already exists.
    Initialisation is skipped if the dir already exists.
    """
    import oxaf  # For making an input spectrum
    from shutil import copyfileobj # To help with saving out spectrum
    from io import BytesIO   # To help with saving out spectrum


    #--------------------------------------------------------------------------
    # Construct the run_name, which we need to be unique.
    gridpt_name_list = []   # Initialise
    for x, val in gridpt_dict.items(): # key x should always be a string
        gridpt_name_list.append(x[0:3])
        # Add x and val to run name:
        if type(val) == str:
            gridpt_name_list.append(val)
        else:  # Assume number if not string
            # We must include all decimal places, without truncating.  This is
            # because param values are parsed from gridpoint names.
            indices = np.arange(10)
            round_arr = np.array([np.round(val,i) for i in indices])
            precision = indices[round_arr == round_arr[-1]][0]
            str_val = "{0:.{1}f}".format(val, precision)
            gridpt_name_list.append(str_val)
    gridpoint_name = "_".join(gridpt_name_list)
    spec_file_name = os.path.join(Grid.grid_config["parent_dir"],
                                  "spectra/" + gridpoint_name + "_spec.txt")


    #--------------------------------------------------------------------------
    # Create a directory for this run, change into dir, and make symlinks:
    # Note that I'm being careful, since creating symlinks often didn't
    # work using "ln" with subprocess.Popen
    run_dir = "grid/" + gridpoint_name
    if os.path.exists(run_dir):
        return gridpoint_name, spec_file_name, True

    counter_1 = 0
    while counter_1 < 5:  # Try to make dir 5 times before throwing error
        try:
            os.mkdir(run_dir)
        except OSError:
            continue
        if os.path.exists(run_dir):   # Check dir was created:
            break # Exit the while loop, since we're done
        else:
            time.sleep(0.05*proc_num+0.01)  # Wait a little before retrying
            counter_1 += 1
    else:
        # This is executed if the "while" condition becomes false, because
        # we didn't "break" the while loop successfully
        logging_queue.put("#### CWD  " + os.getcwd())
        raise Exception("ERROR: Unable to create directory " + run_dir)

    counter_2 = 0
    while counter_2 < 5:
        # Try to change working dir 5 times before throwing error
        os.chdir(run_dir)
        if os.path.split(os.getcwd())[1] == gridpoint_name:
            # Check we're in the run_dir
            break # Exit the while loop, since we're done
        else:
            time.sleep(0.05*proc_num+0.01)  # Wait a little before retrying
            counter_2 += 1
    else:
        # This is executed if the "while" condition becomes false, because
        # we didn't "break" the while loop successfully
        raise Exception("ERROR: Unable to change working dir to " + run_dir)

    MAPPINGS_dir = Grid.MAPPINGS_config["parent_dir"]
    if not os.path.exists(MAPPINGS_dir):
        raise Exception("MAPPINGS dir (parent of lab dir) doesn't exist!")
    MAPPINGS_exe_name = Grid.MAPPINGS_config["executable_name"]
    counter_3 = 0
    while counter_3 < 5:
        # Try to create symlinks 5 times before throwing error
        # Create symbolic links to set up a MAPPINGS "lab" directory:
        link_list = LINK_DIRS + [MAPPINGS_exe_name]
        for x in link_list:
            if not os.path.exists("./" + x):
                # Note that os.path.exists returns False for broken symlinks
                os.symlink(MAPPINGS_dir + "lab/" + x, "./" + x)
        # Check links were created:
        if sum([os.path.exists(i) for i in link_list]) == len(link_list):
            break # Exit the while loop, since we're done
        else:
            print({i: os.path.exists("./" + i) for i in link_list})
            time.sleep(0.05*proc_num+0.01)  # Wait a little before retrying
            counter_3 += 1
    else:
        # This is executed if the "while" condition becomes false, because
        # we didn't "break" the while loop successfully
        raise Exception("ERROR: Unable to make symlinks in dir " + run_dir)


    #--------------------------------------------------------------------------
    # Create an oxaf input spectrum for this gridpoint:
    E_peak = np.float(gridpt_dict["E_peak"])     # log10(E/keV)
    Gamma  = np.float(gridpt_dict["Gamma"])    # dimensionless
    p_NT   = np.float(gridpt_dict["p_NT"])  # dimensionless
    E, B, F = oxaf.full_spectrum(E_peak, Gamma, p_NT)
    # Bin energy, bin width, total energy flux in keV, keV, keV/cm2/s
    F = F * 1.0 / B *1.0E29 # Convert to differential (specific) flux, F_E in
                    # (keV/cm^2/s)/keV (for MAPPINGS input)
    # The following is a slightly elaborate workaround to print a header when
    # saving out the spectrum using np.savetxt() with an older version of numpy:
    f_temp = BytesIO()  # A string buffer object; behaves like a file
    np.savetxt(f_temp, np.column_stack((E,F)), fmt="%.6e")
    # Add in header
    f_temp = BytesIO(b"Energy       Flux\n" +
                     b"keV          (keV/cm2/s)/keV\n"+f_temp.getvalue())
    with open(spec_file_name, "wb") as spec_file:
        copyfileobj(f_temp, spec_file) # Write into spectrum text file
        f_temp.close() # Close BytesIO file-like object

    return gridpoint_name, spec_file_name, False



#=============================================================================
def call_MAPPINGS(Grid, input_string, logging_queue, proc_num, gridpt_name):
    """
    Run a single MAPPINGS run in the current dir (gripoint dir), using
    input_string as a "'here' file".  Log to logging_queue, a multiprocessing
    queue.  This method is called by gridpoint_worker.
    """
    try:
        MAPPINGS_exe_name = Grid.MAPPINGS_config["executable_name"]
        logging_queue.put("Worker " + str(proc_num) + " is running MAPPINGS...")
        stdout_filename = gridpt_name + "_stdout.txt"
        subprocess_command = ('./' + MAPPINGS_exe_name +
                    ' <<ENDMARKER &> ' + stdout_filename + ' \n' +
                    # "&>" means to redirect both stdout and stderr
                    # Commands start here:
                    input_string + '\n' +  # Need line break after last command
                    'ENDMARKER')           # "'here' file" ends on this line.
        # Can print the "herefile" for debugging:
        # print("\nSUBPROCESS COMMAND:\n", subprocess_command)
        # Write script into run dir and separate dir for convenience
        script_filename = gridpt_name + ".sh"
        for script_file in [script_filename, "../../scripts/" + script_filename]:
            with open(script_file, "w") as f_script:
                f_script.write(subprocess_command)
        if Grid.MAPPINGS_config["dry_run?"]:
            print("Dry run: Skipping gridpoint", gridpt_name)
            return
        ### Actually call MAPPINGS here:
        process = subprocess.Popen(subprocess_command, shell=True,
                                                         stdout=subprocess.PIPE)

        # We use a "'here' file" to input data into MAPPINGS
        # Use this one instead for testing:
        # process = subprocess.Popen('sleep 2; echo "Hello"',
        #                             shell=True, stdout=subprocess.PIPE)

        # I use the following machinery to have realtime line-by-line output
        # from MAPPINGS, as opposed to receiving it all at the end.
        initialised = False  # We track if MAPPINGS has started the model
        setup_output = ""
        while True:  # a monitoring loop:
            output = process.stdout.readline().decode()  # stdout from MAPPINGS
            if "#" in output[:5]:  # The two header lines!
                logging_queue.put("W    " + output +
                                  " "*5 + process.stdout.readline().decode())
                continue
            # process.poll() returns None until the process has ended,
            # when it returns the return value
            if output == '' and process.poll() is not None:
                # MAPPINGS has finished!
                #retcode = process.poll()  # return code; not used presently
                logging_queue.put( "--------- Worker " + str(proc_num) +
                                   " finished an iteration ---------" )
                time.sleep(0.01)# Hack: try to make messages come out in order
                break  # leave the monitoring loop (the run has finished)
            elif output[:5].strip() == "Step":
                if initialised == False:
                    # MAPPINGS has now finished setup and started running
                    initialised = True
                    if check_for_repeat_lines( setup_output ):
                        raise ValueError( "MAPPINGS setup didn't work!" )
                if proc_num == 1:
                    # Print a header row
                    logging_queue.put( "Worker " + output.strip() )
            else:
                if initialised == False:
                    # We keep track of the MAPPINGS output during initialisation
                    setup_output += output
                try:
                    step_no = int(output[0:5])
                    if step_no % PRINT_EVERY == 0:
                        # Print 1 in PRINT_EVERY rows of output:
                        logging_queue.put(str(proc_num) + "    " +
                                          output.strip()            )
                except ValueError:
                    pass
            time.sleep(0.01)   # So I'm not looping 100% of the time

    except KeyboardInterrupt:  # Need this or Ctrl+c doesn't work!
        process.terminate()
    except Exception as e: # Other exceptions.  N.B.  Need this to see errors!
        exc1 = traceback.format_exc()  # Return traceback as string
        logging_queue.put( "ERROR (worker process " + str(proc_num) + "): " + exc1 )
        raise e

