#!/bin/tcsh
# v5.2.00
# tcsh for timing format and $HOST (instead of $HOSTNAME for bash)
#
set d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
set r='MV52ShockResults'
set s='MV52ShockScripts'
set i='MV52ShockInputs'
set mexe="${HOME}/mappings520/bin/map52"
#
echo " MV 5.2 Shock Tests: Clearing Area ..."
rm -f timing.txt map5output.txt
rm -f *.ph6 *.nfn *.lam v*.sou *.bln *.sh5 *.csv
#
echo " MV 5.2 Test 1: Alpha 1.0 50km/s iterative shock..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" > timing.txt
(time "${mexe}" < "$s/testS5050.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52Shocks_$d.txt"
cat timing.txt
awk -f "$s/01_shock050spec.awk" specSHv050s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/01_shock050spec.awk" specSHv050s_0001.csv
awk -f "$s/01_shock050prec.awk" specPCv050s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/01_shock050prec.awk" specPCv050s_0001.csv
awk -f "$s/01_shock050struc.awk" shck_v050s_0001.sh5 >> "$r/MV52Shocks_$d.txt"
awk -f "$s/01_shock050struc.awk" shck_v050s_0001.sh5
#
echo " MV 5.2 Test 2: Alpha 1.0 100km/s iterative shock..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" > timing.txt
(time "${mexe}" < "$s/testS5100.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52Shocks_$d.txt"
cat timing.txt
awk -f "$s/02_shock100spec.awk" specSHv100s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/02_shock100spec.awk" specSHv100s_0001.csv
awk -f "$s/02_shock100prec.awk" specPCv100s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/02_shock100prec.awk" specPCv100s_0001.csv
awk -f "$s/02_shock100struc.awk" shck_v100s_0001.sh5 >> "$r/MV52Shocks_$d.txt"
awk -f "$s/02_shock100struc.awk" shck_v100s_0001.sh5
#
echo " MV 5.2 Test 3: Alpha 1.0 200km/s iterative shock..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" > timing.txt
(time "${mexe}" < "$s/testS5200.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52Shocks_$d.txt"
cat timing.txt
awk -f "$s/03_shock200spec.awk" specSHv200s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/03_shock200spec.awk" specSHv200s_0001.csv
awk -f "$s/03_shock200prec.awk" specPCv200s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/03_shock200prec.awk" specPCv200s_0001.csv
awk -f "$s/03_shock200struc.awk" shck_v200s_0001.sh5 >> "$r/MV52Shocks_$d.txt"
awk -f "$s/03_shock200struc.awk" shck_v200s_0001.sh5
#
echo " MV 5.2 Test 4: Alpha 1.0 400km/s iterative shock..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" > timing.txt
(time "${mexe}" < "$s/testS5400.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52Shocks_$d.txt"
cat timing.txt
awk -f "$s/04_shock400spec.awk" specSHv400s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/04_shock400spec.awk" specSHv400s_0001.csv
awk -f "$s/04_shock400prec.awk" specPCv400s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/04_shock400prec.awk" specPCv400s_0001.csv
awk -f "$s/04_shock400struc.awk" shck_v400s_0001.sh5 >> "$r/MV52Shocks_$d.txt"
awk -f "$s/04_shock400struc.awk" shck_v400s_0001.sh5
#
echo " MV 5.2 Test 5: Alpha 1.0 800km/s iterative shock..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" > timing.txt
(time "${mexe}" < "$s/testS5800.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52Shocks_$d.txt"
cat timing.txt
awk -f "$s/05_shock800spec.awk" specSHv800s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/05_shock800spec.awk" specSHv800s_0001.csv
awk -f "$s/05_shock800prec.awk" specPCv800s_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/05_shock800prec.awk" specPCv800s_0001.csv
awk -f "$s/05_shock800struc.awk" shck_v800s_0001.sh5 >> "$r/MV52Shocks_$d.txt"
awk -f "$s/05_shock800struc.awk" shck_v800s_0001.sh5
#
echo " MV 5.2 Test 6: B 10microG 100km/s iterative shock..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" > timing.txt
cp map.prefs map_prev.prefs
cp $i/shockgridmap.prefs map.prefs
(time "${mexe}" < "$s/testKL100.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52Shocks_$d.txt"
cat timing.txt
awk -f "$s/06_shockx100spec.awk" specSHx0100_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/06_shockx100spec.awk" specSHx0100_0001.csv
awk -f "$s/06_shockx100prec.awk" specPCx0100_0001.csv >> "$r/MV52Shocks_$d.txt"
awk -f "$s/06_shockx100prec.awk" specPCx0100_0001.csv
awk -f "$s/06_shockx100struc.awk" shck_x0100_0001.sh5 >> "$r/MV52Shocks_$d.txt"
awk -f "$s/06_shockx100struc.awk" shck_x0100_0001.sh5
cp map_prev.prefs map.prefs
echo " MV 5.2 Shock Tests completed. Output in "$r/MV52Shocks_$d.txt""
rm -f timing.txt map5output.txt
rm -f *.ph6 *.nfn *.lam v*.sou *.bln *.sh5 *.csv SH*.sou PC*.sou
#
