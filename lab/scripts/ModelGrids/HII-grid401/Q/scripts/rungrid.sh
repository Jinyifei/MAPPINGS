#!/bin/bash
# v5.1.21  bash looped and simplified version
#
########################################################################
#
# New Local Galactic Concordance abundance grid with
# Jenkins 2014 based depletion +SB spectrum file inputs
#
########################################################################
#
# Run a 0.05 <= Z <= 2.0  6.5 <= Q <= 8.5 hii region grid
# and produce gridXXX.csv file of log ratios to plot
#
# Usage: rungrid.sh 'RunName' n
# creates grid_RunName.csv and model files in RunName_modelfiles/
#
# Using template directory duplication
# and MV script modification.
#
# Could run in tcsh, but running in bash so that the Linux
# /proc/cpuinfo query can discard errors only.
#
########################################################################
#
d=$(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')
echo " "
date

if (( $# < 1 )); then
      echo " Run an MV HII region grid, with runname"
      echo " Run a 0.05 <= Z <= 5.0  6.5 <= Q <= 8.5 hii region grid"
      echo " and produce grid_XXX.csv file of log ratios to plot"
      echo " "
      echo " Usage1: rungrid.sh 'RunName'"
      echo " creates grid_RunName.csv and model files in RunName_modelfiles/"
      echo " "
      echo " Usage2: rungrid.sh 'RunName' n"
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
m_vers="v5.0.13"
#
########################################################################
#
# Set the type, geometry, of the MV model scripts
#
# "pp"  = plane parallel
# "sph" = spherical
#
type="pp"
#
# symmetry for pp models, ignored for sph
#  "one" or "two"
#
sides="two"
#
########################################################################
#
# Set the global pressure regime of the MV model scripts
#
# 5.0 = standard log p/k
#
pres="5.0"
#
########################################################################
#
# Depletion File std: "1sol.dpl",
#            jenkins: "jenkinsf35.dpl"
#               Full: "Depln_Fe_1.50.txt"
#
# depletion code for runname: d_vers '1sol' 'JF35' 'FE15' etc
#
depl="1sol.dpl"
d_vers="1sol"
#
########################################################################
#
# SB parameters, used to generate filenames, will only work if
# the correct SB Spectrum files have been generated and named correctly.
# and placed in Q/inputs/
#
# SB99 parameters Continuous SF 1M0/yr
#
# cont_aXXtYYiZZ_vZZZZ.spectrum  files:
#
sb_sf="cont"
#
# 0...10Myr in 0.5Myr steps:
#
# 1Myr sb_step = 3
# 2Myr sb_step = 5
# 4Myr sb_step = 9
#
sb_step="9"
#
# Atmosphere setting, sb_atmos = a03 = 'lejeune + Schmutz WRs'
#
sb_atmos="a03"
#
# assign tracks to zeta values sb_XXX = track for zetaXXX
#
sb_005="t21"
sb_020="t22"
sb_040="t23"
sb_100="t24"
sb_200="t25"
sb_300="t25"
#
# isp = Salpeter IMF, ikr = Kroupa IMF
#
sb_imf="isp"
#
# SB code version:
#
sb_vers="vms08"
#
########################################################################
# Normally no need to edit below here:
########################################################################
#
echo " MV ${vers} ${type}, log p/k = ${pres} SB Spectrum HII Region Grid."
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
# if second argument set, use that
#
if [ "$#" -eq "2" ]
then
      n=$2
fi

if [ "$n" -lt "1" ]
then
     n=1
fi

if [ $cores -gt 1 ] && [ $n -eq 1 ]
then
      echo " **** $cores CPUs are available,"
      echo " **** consider running on more than one CPU."
      echo " "
      echo " Usage2: rungrid.sh 'RunName' n"
      echo " where n is the number of cpus to run on in parallel"
      echo " "
fi
#
# Hard wired grid of 9 Qs
#
ngrid=9
echo " Running ${type} grid of ${ngrid} Qs, ${n} at a time..."
#
# loop over grid, submitting jobs in the background
# and waiting every n times for completion.
# Not super intelligent about small remainders,
# but good enough for most jobs.
#
for (( idx=0; idx < ${ngrid}; idx++ ))
do
#
# get name for Q run, decimal and integer:
# (using zero based counter idx)
#
q0=$( echo "6.50+${idx}*0.25" | bc )
q1=$( echo "650+${idx}*25" | bc )
#
# make copy of Q template and cd into it
#
cp -r Q "Q"${q1}
cd "Q"${q1}
#
#pwd
# edit the MV template script for log Q and log p/k
# make the script and run it
#
sed -e s/LPKVALUE/${pres}/g \
    -e s/LQVALUE/${q0}/g \
    -e s/SIDES/${sides}/g \
    -e s/SBTYPE/${sb_sf}/g \
    -e s/SBSTEP/${sb_step}/g \
    -e s/_ATMVALUE/${sb_atmos}/g \
    -e s/_TR005/${sb_005}/g \
    -e s/_TR020/${sb_020}/g \
    -e s/_TR040/${sb_040}/g \
    -e s/_TR100/${sb_100}/g \
    -e s/_TR200/${sb_200}/g \
    -e s/_TR300/${sb_300}/g \
    -e s/_IMFVALUE/${sb_imf}/g \
    -e s/SBVERSION/${sb_vers}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  scripts/"photAQ-${type}".mv > "photAQ${q1}PK${pres}-${type}".mv
# background execution
#echo "photAQ"${q1}PK${pres}-${type}.mv
(./runmvscript.sh "photAQ"${q1}PK${pres}-${type}.mv)>&/dev/null&
# uncomment for foreground only execution:
#./runmvscript.sh "photAQ"${q1}PK${pres}-${type}.mv
cd ..
#
# Wait for background jobs to complete, if any
# ( using 1 based counter count )
#
count=$(expr $idx + 1)
#
if [ $(expr $count % $n) -eq 0 ]
then
      wait
      echo " ${count} Completed."
      echo " "$(date)
fi

done

wait
echo " All ${count} Completed. Processing output..."
echo " "$(date)
########################################################################
#
# Collect all the outputs into a global csv, extracting
# from sub directories in order....
#
########################################################################
#
cp Q/scripts/awk_* .
cp Q/scripts/gridrunheader.csv .
cp Q/scripts/getgrid.sh .
#
########################################################################
#
# create QZ order csv
#
########################################################################
echo `date` > grid_QZ-${type}_${1}.csv
echo "MAPPINGS V HII Region Grid: QZ "${1} >> grid_QZ-${type}_${1}.csv
sed -e s/LPKVALUE/${pres}/g \
    -e s/LQVALUE/${q0}/g \
    -e s/SIDES/${sides}/g \
    -e s/SBTYPE/${sb_sf}/g \
    -e s/SBSTEP/${sb_step}/g \
    -e s/_ATMVALUE/${sb_atmos}/g \
    -e s/_TR005/${sb_005}/g \
    -e s/_TR020/${sb_020}/g \
    -e s/_TR040/${sb_040}/g \
    -e s/_TR100/${sb_100}/g \
    -e s/_TR200/${sb_200}/g \
    -e s/_TR300/${sb_300}/g \
    -e s/_IMFVALUE/${sb_imf}/g \
    -e s/SBVERSION/${sb_vers}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  gridrunheader.csv >> grid_QZ-${type}_${1}.csv
#
# collect data into one csv...
#
for (( idx=0; idx < ${ngrid}; idx++ ))
do
q1=$( echo "650+${idx}*25" | bc )
./getgrid.sh Q${q1}/spec*.csv >> grid_QZ-${type}_${1}.csv
echo "c" >>grid_QZ-${type}_${1}.csv
done
########################################################################
#
# create transposed ZQ order csv
#
########################################################################
#
echo `date` > grid_ZQ-${type}_${1}.csv
echo "MAPPINGS V HII Region Grid: ZQ "${1} >> grid_ZQ-${type}_${1}.csv
sed -e s/LPKVALUE/${pres}/g \
    -e s/LQVALUE/${q0}/g \
    -e s/SIDES/${sides}/g \
    -e s/SBTYPE/${sb_sf}/g \
    -e s/SBSTEP/${sb_step}/g \
    -e s/_ATMVALUE/${sb_atmos}/g \
    -e s/_TR005/${sb_005}/g \
    -e s/_TR020/${sb_020}/g \
    -e s/_TR040/${sb_040}/g \
    -e s/_TR100/${sb_100}/g \
    -e s/_TR200/${sb_200}/g \
    -e s/_TR300/${sb_300}/g \
    -e s/_IMFVALUE/${sb_imf}/g \
    -e s/SBVERSION/${sb_vers}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  gridrunheader.csv >> grid_ZQ-${type}_${1}.csv
#
# collect data into one one zeta at a time csv...
#
for (( idx=0; idx < ${ngrid}; idx++ ))
do
q1=$( echo "650+${idx}*25" | bc )
./getgrid.sh Q${q1}/spec0001.csv >> grid_ZQ-${type}_${1}.csv
done
echo "c" >>grid_ZQ-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
q1=$( echo "650+${idx}*25" | bc )
./getgrid.sh Q${q1}/spec0002.csv >> grid_ZQ-${type}_${1}.csv
done
echo "c" >>grid_ZQ-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
q1=$( echo "650+${idx}*25" | bc )
./getgrid.sh Q${q1}/spec0003.csv >> grid_ZQ-${type}_${1}.csv
done
echo "c" >>grid_ZQ-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
q1=$( echo "650+${idx}*25" | bc )
./getgrid.sh Q${q1}/spec0004.csv >> grid_ZQ-${type}_${1}.csv
done
echo "c" >>grid_ZQ-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
q1=$( echo "650+${idx}*25" | bc )
./getgrid.sh Q${q1}/spec0005.csv >> grid_ZQ-${type}_${1}.csv
done
echo "c" >>grid_ZQ-${type}_${1}.csv
for (( idx=0; idx < ${ngrid}; idx++ ))
do
q1=$( echo "650+${idx}*25" | bc )
./getgrid.sh Q${q1}/spec0006.csv >> grid_ZQ-${type}_${1}.csv
done
#
########################################################################
# tidy
mkdir ${1}modelfiles
for (( idx=0; idx < ${ngrid}; idx++ ))
do
q1=$( echo "650+${idx}*25" | bc )
mv Q${q1} ${1}modelfiles/
done
#
# clean up scripts lying around
#
rm gridrunheader.csv
rm getgrid.sh
rm awk_*
########################################################################
echo " Done! Output in grid-${type}_${1}.csv"
date
echo " "
