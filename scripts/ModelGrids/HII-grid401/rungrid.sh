#!/bin/bash
# MV v5.2.0 v4.02 bash looped and slotted PID version
#
########################################################################
#
# New Local Galactic Concordance abundance grid with
# Jenkins 2014 based depletion +SB spectrum file inputs
#
########################################################################
#
# Run a 0.05 <= Z <= 2.0  6.5 <= Q <= 8.5 hii region grid
# and produce gridXX.csv file of log ratios to plot
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
m_vers="v5.2.0"
map_exe="map52"
map_path="${HOME}/mappings520/bin"
#
########################################################################
#
# Set the type, geometry, of the MV model scripts
#
# "pp"  = plane parallel
# "sph" = spherical
#
type="sph"
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
# Abundances
#
# set 5 abundance file names
# set type name for runname string: "AG89", "AG89S", "GCZFe", "GCZO", "AS09"
abn_type="GCZO"
#
# set corresponding abundance file names for mv script
#
# Z/Z0 ~ 0.05: SB99 scale, for sb_005 below
# one of: "GC_ZFe_M1150.abn", "GC_ZO_M1130.abn", "AG89_M1300.abn", "AG89S_M1300.abn" "AS09_M1300.abn"
abn1="GC_ZO_M1130.abn"
# Z/Z0 ~ 0.20: SB99 scale, for sb_020 below
# one of: "GC_ZFe_M0550.abn", "GC_ZO_M0530.abn", "AG89_M0700.abn", "AG89S_M0700.abn" "AS09_M1300.abn"
abn2="GC_ZO_M0530.abn"
# Z/Z0 ~ 0.40: SB99 scale, for sb_040 below
# one of: "GC_ZFe_M0250.abn", "GC_ZO_M0230.abn", "AG89_M0400.abn", "AG89S_M0400.abn" "AS09_M1300.abn"
abn3="GC_ZO_M0230.abn"
# Z/Z0 ~ 1.00: SB99 scale, for sb_100 below
# one of: "GC_ZFe_P0150.abn", "GC_ZO_P0170.abn", "AG89_P0000.abn", "AG89S_P0000.abn" "AS09_M1300.abn"
abn4="GC_ZO_P0170.abn"
# Z/Z0 ~ 2.00: SB99 scale, for sb_200 below
# one of: "GC_ZFe_P0450.abn", "GC_ZO_P0470.abn", "AG89_P0300.abn", "AG89S_P0300.abn" "AS09_M1300.abn"
abn5="GC_ZO_P0470.abn"
#
########################################################################
#
# Depletion File std: "1sol.dpl",
#            jenkins: "jenkinsf35.dpl"
#               Full: "Depln_Fe_1.50.txt"
#
# depletion code for runname: d_vers '1sol' 'JF35' 'FE15' etc
#
depl="Depln_Fe_1.50.txt"
d_vers="FE15"
#
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
#  cont - continuous
#  coeval - coeval formation
#
sb_sf="cont"
#
# 0...10Myr in 0.5Myr steps:
#
# 1Myr sb_step = 3
# 2Myr sb_step = 5
# 4Myr sb_step = 9
# Myr = 2n+1
# 5Myr
sb_step="11"
#
# Atmosphere setting, sb_atmos = a03 = 'lejeune + Schmutz WRs'
# a01=BlackBody, a02=LEJ, a03=LEJ+SCH, a04=LEJ+SMI, a05=PAU+SMI:
sb_atmos="a03"
#
# Assign tracks to zeta values sb_XXX = track for zetaXXX
# METALLICITY + TRACKS:                                        [IZ]
# GENEVA STD: t11=0.001;  t12=0.004; t13=0.008; t14=0.020; t15=0.040
# GENEVA HIGH:t21=0.001;  t22=0.004; t23=0.008; t24=0.020; t25=0.040
# PADOVA STD: t31=0.0004; t32=0.004; t33=0.008; t34=0.020; t35=0.050
# PADOVA AGB: t41=0.0004; t42=0.004; t43=0.008; t44=0.020; t45=0.050
# GENEVA v00: t51=0.001;  t52=0.002; t53=0.008; t54=0.014; t55=0.040
# GENEVA v40: t61=0.001;  t62=0.002; t63=0.008; t64=0.014; t65=0.040
#
sb_005="t21"
sb_020="t22"
sb_040="t23"
sb_100="t24"
sb_200="t25"
#
# isp = Salpeter IMF, ikr = Kroupa IMF
#
sb_imf="isp"
#
# SB code version:
#
sb_vers="vm802"
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
# if more than one argument set, use the last one
# $0 = whole line, 1 = 1st arg after command, 2 - 2nd arg etc
#
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
ngrid=9
echo " Running isobaric grid of ${ngrid} HII Regions, ${n} at a time..."
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
# http://stackoverflow.com/questions/1455695/forking-multi-threaded-processes-bash
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
# get name for Q run, decimal and integer:
# (using zero based counter idx)
#
q0=$( echo "8.50-${idx}*0.25" | bc )
q1=$( echo "850-${idx}*25" | bc )
#
# make copy of Q template and cd into it
#
[ -d "Q"${q1} ] || cp -r Q "Q"${q1}
cd "Q"${q1}
#
#
########################################################################
#
# edit the MV template script for log Q and log p/k
# make the script and run it
#
sed -e s/LPKVALUE/${pres}/g \
    -e s/LQVALUE/${q0}/g \
    -e s/SIDES/${sides}/g \
    -e s/GEOM/${type}/g \
    -e s/ABTYPE/${abn_type}/g \
    -e s/ABN01/${abn1}/g \
    -e s/ABN02/${abn2}/g \
    -e s/ABN03/${abn3}/g \
    -e s/ABN04/${abn4}/g \
    -e s/ABN05/${abn5}/g \
    -e s/SBTYPE/${sb_sf}/g \
    -e s/SBSTEP/${sb_step}/g \
    -e s/_ATMVALUE/${sb_atmos}/g \
    -e s/_TR005/${sb_005}/g \
    -e s/_TR020/${sb_020}/g \
    -e s/_TR040/${sb_040}/g \
    -e s/_TR100/${sb_100}/g \
    -e s/_TR200/${sb_200}/g \
    -e s/_IMFVALUE/${sb_imf}/g \
    -e s/SBVERSION/${sb_vers}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  scripts/"photAQ-${type}".mv > "photAQ${q1}PK${pres}-${type}".mv
# background execution
# change delimiter % to allow / in paths
#
    sed -e s%MPATH%${map_path}%g \
        -e s%MEXE%${map_exe}%g\
         runmvtmpl.sh > runmvscript.sh
    chmod +x runmvscript.sh
    (./runmvscript.sh "photAQ"${q1}PK${pres}-${type}.mv)>&/dev/null&
    addPid "${map_exe}_Q${q1}" $!
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
    -e s/GEOM/${type}/g \
    -e s/ABTYPE/${abn_type}/g \
    -e s/SBTYPE/${sb_sf}/g \
    -e s/SBSTEP/${sb_step}/g \
    -e s/_ATMVALUE/${sb_atmos}/g \
    -e s/_TR005/${sb_005}/g \
    -e s/_TR020/${sb_020}/g \
    -e s/_TR040/${sb_040}/g \
    -e s/_TR100/${sb_100}/g \
    -e s/_TR200/${sb_200}/g \
    -e s/_IMFVALUE/${sb_imf}/g \
    -e s/SBVERSION/${sb_vers}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  gridrunheader.csv >> grid_QZ-${type}_${1}.csv
#
########################################################################
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
    -e s/GEOM/${type}/g \
    -e s/ABTYPE/${abn_type}/g \
    -e s/SBTYPE/${sb_sf}/g \
    -e s/SBSTEP/${sb_step}/g \
    -e s/_ATMVALUE/${sb_atmos}/g \
    -e s/_TR005/${sb_005}/g \
    -e s/_TR020/${sb_020}/g \
    -e s/_TR040/${sb_040}/g \
    -e s/_TR100/${sb_100}/g \
    -e s/_TR200/${sb_200}/g \
    -e s/_IMFVALUE/${sb_imf}/g \
    -e s/SBVERSION/${sb_vers}/g \
    -e s/MVERSION/${m_vers}/g \
    -e s/DVERSION/${d_vers}/g \
    -e s/DEPLFILE/${depl}/g  gridrunheader.csv >> grid_ZQ-${type}_${1}.csv
#
########################################################################
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
