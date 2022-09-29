#!/bin/bash
# MV v5.1.21 v2.1 v4 bash looped and slotted PID version
#
########################################################################
#
# New Local Galactic Concordance abundance grid with
# Jenkins 2014 based depletion +SB spectrum file inputs
#
########################################################################
#
# Run a 1e6 <= M_SMBH <= 1e9M,  -4.0 <= U_H <= -1.0 AGN  grid
# and produce gridXX.csv file of log ratios to plot
#
# Usage: rungrid.sh 'RunName' n
# creates grid_RunName.csv and model files in RunName_modelfiles/
#
# Using template directory duplication
# and MV script modification.
#
# Could run in tcsh, but running in bash so that the Linux
# /proc/cpuinfo uuery can discard errors only.
#
########################################################################
#
d=$(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')
echo " "
date

if (( $# < 1 )); then
      echo " Run an MV AGN region grid, with runname"
      echo " Run a  1e6 <= M_SMBH <= 1e9M,  -4.0 <= U_H <= -1.0 AGN  grid"
      echo " and produce grid_XXX.csv file of log ratios to plot"
      echo " "
      echo " Usage: rungrid.sh 'RunName' n"
      echo " where n is the number of cpus to run on in parallel"
      echo " Creates grid_RunName.csv and model files in RunName_modelfiles/"
      echo " "
      exit -1
fi
########################################################################
# Edit parameters for the grid:
########################################################################
#
# MAPPINGS version
#
m_vers="v5.1.21"
map_exe="map51"
#
########################################################################
#
# Set the type, geometry, of the MV model scripts
#
# "pp"  = plane parallel
# "sph" = spherical
#
geom="pp"
#
# symmetry for pp models, ignored for sph
#  "one" or "two"
#
sides="one"
#
########################################################################
#
# Set the global pressure regime of the MV model scripts
#
# 8.0 = standard log p/k
#
pres="8.0"
#
########################################################################
# Abundances
#
abun="lgc100.abn"
#
# set corresponding abundance file names for mv script
#
########################################################################
#
# Depletion File std: "1sol.dpl",
#            jenkins: "jenkinsf35.dpl"
#               Full: "Depln_Fe_x.xx.txt"  0.00 - 2.25 see inputs
#
# depletion code for runname: d_vers '1sol' 'JF35' 'FE15' etc
#
depl="Depln_Fe_1.50.txt"
d_vers="FE15"
#
#
########################################################################
#
# AGN parameters, used to generate filenames, will only work if
# the correct Jin et al Spectrum files have been generated and named correctly.
# and placed in U/inputs/CompSED2/
#
# Jin et al AGN photoionisation
#
#  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#   Choose the Accretion Efficiency L/LEdd:
#  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#     1 :   0.01 Eddington   5 :   0.10 Eddington
#     2 :   0.02 Eddington   6 :   0.20 Eddington
#     3 :   0.03 Eddington   7 :   0.30 Eddington
#     4 :   0.05 Eddington   8 :   0.50 Eddington
#     5 :   0.10 Eddington   9 :   1.00 Eddington
#
# 0.1 by default atm
#
agn_ledd="5"
ledd="0.10"
#
#  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#   Choose the Model :
#  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#     N  :   NLS, Narrow Line Seyfert Model.
#     B  :   BLS, Broad Line Seyfert Model.
#
agn_type="N"
type="NLS"
#
# AGN spectra components mixed 0-1 , just thermal bump and nonthermal atm
#
#
agn_thermal="1.0"
agn_intcompton="0.0"
agn_nonthermal="1.0"
#
########################################################################
# Normally no need to edit below here:
########################################################################
#
echo " MV ${vers} ${type} AGN, log p/k = ${pres} Jin 2012 Grid."
#
# should work in LINUX and BSD Unix, ie OSX:
# get the available number of cpus (virtual or otherwise)
#
cores=$( grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu )
#
# number of parallel processes, default 1 if not specified
#
n=1
#
# if more than one argument set, use the last one
# $0 = whole line, 1 = 1st arg after command, 2 - 2nd arg etc

if [ "$#" -ge "2" ]
then
      n="${!#}"
fi
#
if [ "$n" -lt "1" ]
then
     n=1
fi
#
if [ $cores -gt 1 ] && [ $n -eq 1 ] && [ $n -gt $cores ]
then
      echo " **** $cores CPUs are available,"
      echo " **** consider running on more than one CPU."
      echo " "
      echo " Usage: rungrid.sh 'RunName' n"
      echo " where n is the number of cpus to run on in parallel"
      echo " "
fi
#
########################################################################
#
ngrid=16
echo " Running isobaric grid of ${ngrid} AGN Models, ${n} at a time..."
#
# loop over grid, submitting jobs in the background.
# As jobs complete new ones are set going to keep the number running
# up to n as much as possible, until it tapers ofvf at the end.
#
running=0
prunning=0
completed=0
pcompleted=-1
########################################################################
# process monitoring functions
#
# http://stackoverflow.com/uuestions/1455695/forking-multi-threaded-processes-bash
# by haridsv
#
declare -a pids
#
function checkPids() {
#echo  ${#pids[@]}
if [ ${#pids[@]} -ne 0 ]
then
#    echo "Checking for pids: ${pids[@]}"
    local range=$(eval echo {0..$((${#pids[@]}-1))})
    local i
    for i in $range; do
        if ! kill -0 ${pids[$i]} 2> /dev/null; then
#            echo "Done -- ${pids[$i]}"
            unset pids[$i]
            completed=$(expr $completed + 1)
        fi
    done
    pids=("${pids[@]}") # Expunge nulls created by unset.
    running=$((${#pids[@]}))
#    echo "PIDS #:"$running
fi
}
#
function addPid() {
    desc=$1
    pid=$2
    echo " ${desc} - "$(date)
    pids=(${pids[@]} $pid)
}

########################################################################
#
# Loop and report when job changes happen,
# keep going until all are completed.
#
idx=0
while [ $completed -lt ${ngrid} ]
do
#
if [ $running -lt $n ] && [ $idx -lt ${ngrid} ]
then
########################################################################
#
# submit a new model if less than n are running and we haven't finished...
#
# get name for U run, decimal and integer:
# (using zero based counter idx, removing leading -minus signs for directories
# u0 is actual log U(H), a0 is directory name
#
u0=$( echo "-1.00-${idx}*0.25" | bc )
#
a1=$( echo "100+${idx}*25" | bc )
#
# make copy of U template and cd into it
#
[ -d "U"${a1} ] || cp -r A "U"${a1}
cd "U"${a1}
#
#
#
########################################################################
#
# edit the MV template script for log U and log p/k and AGN mass/Ledd/Type
# make the script and run it
#
sed -e s/LPKVALUE/${pres}/g \
    -e s/LUVALUE/${u0}/g \
    -e s/SIDES/${sides}/g \
    -e s/GEOM/${geom}/g \
    -e s/ABUND/${abun}/g \
    -e s/AGNLEDD/${agn_ledd}/g \
    -e s/AGNTYPE/${agn_type}/g \
    -e s/FDISK/${agn_thermal}/g \
    -e s/FINTER/${agn_intcompton}/g \
    -e s/FCORONA/${agn_nonthermal}/g \
    -e s/TYPE/${type}/g \
    -e s/LEDD/${ledd}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  scripts/"photAGN-${geom}".mv > "photAGN${geom}_P${pres}_L${ledd}_${type}".mv
# background execution
    sed -e s/MEXE/${map_exe}/g  runmvtmpl.sh > runmvscript.sh
    chmod +x runmvscript.sh
    (./runmvscript.sh "photAGN${geom}_P${pres}_L${ledd}_${type}".mv)>&/dev/null&
    addPid "${map_exe}_A${u0}" $!
    idx=$(expr $idx + 1)
#
########################################################################
# and go back up for next one .
cd ../
#
fi
#
checkPids
if [ $running -gt $prunning ] || [ $completed -gt $pcompleted ]
then
remain=$(expr $ngrid - $completed)
echo  " Running: "${running}" Submitted: "${idx}\
      " Completed: "$completed" Remaining: "$remain
fi
prunning=${running}
pcompleted=$completed
sleep 1
#
done
#
########################################################################
#
# completed all the grid models
#
echo " All ${count} Completed. Processing output..."
echo " "$(date)
#
########################################################################
#
# Collect all the outputs into a global csv, extracting
# from sub directories in order....
#
########################################################################
#
cp A/scripts/awk_* .
cp A/scripts/gridrunheader.csv .
cp A/scripts/getgrid.sh .
#
########################################################################
#
# create UZ order csv
#
########################################################################
echo `date` > grid_AGN_UM-${type}_${1}.csv
echo "MAPPINGS V AGN Grid: UMLTP "${1} >> grid_AGN_UM-${type}_${1}.csv
sed -e s/LPKVALUE/${pres}/g \
    -e s/KAPPAVALUE/${kappa}/g \
    -e s/SIDES/${sides}/g \
    -e s/GEOM/${geom}/g \
    -e s/ABUND/${abun}/g \
    -e s/TYPE/${type}/g \
    -e s/LEDD/${ledd}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  gridrunheader.csv >> grid_AGN_UM-${type}_${1}.csv
#
########################################################################
#
# collect data into one csv... in UM order
#
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec*.csv >> grid_AGN_UM-${type}_${1}.csv
echo "c" >>grid_AGN_UM-${type}_${1}.csv
done
########################################################################
#
# create transposed MU order csv
#
########################################################################
#
echo `date` > grid_AGN_MU-${type}_${1}.csv
echo "MAPPINGS V AGN Grid: MULTP "${1} >> grid_AGN_MU-${type}_${1}.csv
sed -e s/LPKVALUE/${pres}/g \
    -e s/KAPPAVALUE/${kappa}/g \
    -e s/SIDES/${sides}/g \
    -e s/GEOM/${geom}/g \
    -e s/ABUND/${abun}/g \
    -e s/TYPE/${type}/g \
    -e s/LEDD/${ledd}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  gridrunheader.csv >> grid_AGN_MU-${type}_${1}.csv
#
########################################################################
#
# collect data into one one mass at a time csv...
#
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0001.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0002.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0003.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0004.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0005.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0006.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0007.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0008.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0009.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0010.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0011.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0012.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0013.csv >> grid_AGN_MU-${type}_${1}.csv
done
echo "c" >>grid_AGN_MU-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
./getgrid.sh U${a1}/spec0014.csv >> grid_AGN_MU-${type}_${1}.csv
done
#
########################################################################
# tidy
mkdir ${1}modelfiles
for (( idx=0; idx < ${ngrid}; idx++ ))
do
a1=$( echo "100+${idx}*25" | bc )
mv U${a1} ${1}modelfiles/
done
#
# clean up scripts lying around
#
rm gridrunheader.csv
rm getgrid.sh
rm awk_*
########################################################################
echo " Done! Output in grid_AGN-${type}_${1}.csv"
date
echo " "
