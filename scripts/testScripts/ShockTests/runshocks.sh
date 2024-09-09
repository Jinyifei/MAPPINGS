#!/bin/bash
# v5.2.0 v2.0.4
# bash version with function fixes timer in linux vs BSD, tcsh vs bash vs builtin vs /usr/bin
# uses POSIX /usr/bin/time -p 2>&1  instead of builtin to avoid shell dependence
#
run_mv_model () {
#
# 3 arg: root of .mv file root of awk files, midroot of shock output
# eg ${1} = $s/testS5050, ${2} = $s/01_shock050, ${3} = v050s
   date | awk '{print " "$0}' > timing.txt
   echo " $HOSTNAME" >> timing.txt
   ( /usr/bin/time -p 2>&1 "${mexe}" < "${1}.mv" >> map5output.txt ) | awk '/real/{rl=1.0*$2};/user/{ul=1.0*$2};/sys/{sl=1.0*$2};END{printf(" %.2fu %.2fs %.2fw %.2f%%\n",ul,sl,rl,(100.0*ul)/(ul+sl))}'>> timing.txt
   cat timing.txt >> "$r/MV52Shocks_$d.txt"
   cat timing.txt
   awk -f "${2}spec.awk"  "specSH${3}_0001.csv" >> "$r/MV52Shocks_$d.txt"
   awk -f "${2}spec.awk"  "specSH${3}_0001.csv"
   awk -f "${2}prec.awk"  "specPC${3}_0001.csv" >> "$r/MV52Shocks_$d.txt"
   awk -f "${2}prec.awk"  "specPC${3}_0001.csv"
   awk -f "${2}struc.awk" "shck_${3}_0001.sh5" >> "$r/MV52Shocks_$d.txt"
   awk -f "${2}struc.awk" "shck_${3}_0001.sh5"
}
#
d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
r="MV52ShockResults"
s="MV52ShockScripts"
i="MV52ShockInputs"
mexe="${HOME}/mappings520/bin/map52"
ext="ph6"
#
echo " MV 5.2 Shock Tests: Clearing Area ..."
rm -f timing.txt map5output.txt
rm -f *.${ext} *.nfn *.lam v*.sou *.bln *.sh5 *.csv
#
echo ""
echo " MV Test 1: Alpha 1.0 50km/s iterative shock..."
run_mv_model "$s/testS5050" "$s/01_shock050" "v050s"
#
echo ""
echo " MV Test 2: Alpha 1.0 100km/s iterative shock..."
run_mv_model "$s/testS5100" "$s/02_shock100" "v100s"
#
echo ""
echo " MV Test 3: Alpha 1.0 200km/s iterative shock..."
run_mv_model "$s/testS5200" "$s/03_shock200" "v200s"
#
echo ""
echo " MV Test 4: Alpha 1.0 400km/s iterative shock..."
run_mv_model "$s/testS5400" "$s/04_shock400" "v400s"
#
echo ""
echo " MV Test 5: Alpha 1.0 800km/s iterative shock..."
run_mv_model "$s/testS5800" "$s/05_shock800" "v800s"
#
echo ""
echo " MV Test 6: B 10 muG 100km/s iterative shock..."
run_mv_model "$s/testKL100" "$s/06_shockx100" "x0100"
#
echo " MV Shock Tests completed. Output in "$r/MV52Shocks_$d.txt""
#
rm -f timing.txt map5output.txt
rm -f *.${ext} *.nfn *.lam v*.sou *.bln *.sh5 *.csv SH*.sou PC*.sou
#
