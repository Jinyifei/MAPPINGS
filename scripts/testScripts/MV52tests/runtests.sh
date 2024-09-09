#!/bin/bash
# v5.2.0 v2.0.3
# bash version with function fixes timer in linux vs BSD, tcsh vs bash vs builtin vs /usr/bin
# uses POSIX /usr/bin/time -p 2>&1  instead of builtin to avoid shell dependence
#
run_mv_model () {
#
# 1 arg: root of .mv file
#
   date | awk '{print " "$0}' > timing.txt
   echo " $HOSTNAME" >> timing.txt
   ( /usr/bin/time -p 2>&1 "${mexe}" < "${1}.mv" >>map5output.txt) | awk '/real/{rl=1.0*$2};/user/{ul=1.0*$2};/sys/{sl=1.0*$2};END{printf(" %.2fu %.2fs %.2fw %.2f%%\n",ul,sl,rl,(100.0*ul)/(ul+sl))}'>> timing.txt
   cat timing.txt >> "$r/MV52test_$d.txt"
   cat timing.txt
}
#
d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
r="MV52Results"
s="MV52Scripts"
i="MV52Inputs"
mexe="${HOME}/mappings520/bin/map52"
ext="ph6"
#
echo " MV 5.2 Tests: Clearing Area ..."
rm -f timing.txt map5output.txt
rm -f *.${ext} *.nfn *.lam v*.sou *.bln *.sh5 *.csv SH*.csv PC*.csv
#
echo ""
echo " MV 5.2 Test 1: Solar HII region ..."
run_mv_model "$s/01_solhii"
awk -f "$s/01_solhii.awk" photn0001.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/01_solhii.awk" photn0001.ph6
#
echo ""
echo " MV 5.2 Test 2: Primordial HII region ..."
run_mv_model "$s/02_primhii"
awk -f "$s/02_primordial.awk" photn0002.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/02_primordial.awk" photn0002.ph6
#
echo ""
echo " MV 5.2 Test 3: Test Solar Z 100kK PN ..."
run_mv_model "$s/03_testpn2"
awk -f "$s/03_testpn2.awk" photn0003.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/03_testpn2.awk" photn0003.ph6
#
echo ""
echo " MV 5.2 Test 4: Dusty Isobaric Low Z HII region ..."
run_mv_model "$s/04_dustyhii"
awk -f "$s/04_dustyhii.awk" photn0004.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/04_dustyhii.awk" photn0004.ph6
#
echo ""
echo " MV 5.2 Test 5: Dusty Isobaric PAH HII region ..."
run_mv_model "$s/05_dustypah"
awk -f "$s/05_dustypah.awk" photn0005.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/05_dustypah.awk" photn0005.ph6
#
echo ""
echo " MV 5.2 Tests completed. Output in: " "$r/MV52test_$d.txt"
#
rm -f timing.txt map5output.txt
rm -f *.${ext} *.nfn *.lam v*.sou *.bln *.sh5 *.csv SH*.sou PC*.sou
#
