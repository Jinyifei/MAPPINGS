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
   ( /usr/bin/time -p 2>&1 "${mexe}" < "${1}.mv" >>map5output.txt)   | awk '/real/{rl=1.0*$2};/user/{ul=1.0*$2};/sys/{sl=1.0*$2};END{printf(" %.2fu %.2fs %.2fw %.2f%%\n",ul,sl,rl,(100.0*ul)/(ul+sl))}'>> timing.txt
   cat timing.txt >> "$r/lextest_$d.txt"
   cat timing.txt
}
#
d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
s="KTScripts"
r="KTResults"
i="KTInputs"
ext="ph6"
mexe="${HOME}/mappings520/bin/map52"
#
echo " Cleaning work area..."
rm -f timing.txt map5output.txt
rm -f *.${ext} *.csv *.sou
#
echo ""
echo " Kentucky 2000 Test 1: Table 2 Cool 20kK HII region ..."
run_mv_model "$s/kt00T2_h20"
awk -f "$s/kt00T2.awk" photn0001.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T2.awk" photn0001.${ext}
#
echo ""
echo " Kentucky 2000 Test 2: Table 3 40kK HII region ..."
run_mv_model "$s/kt00T3_h40"
awk -f "$s/kt00T3.awk" photn0002.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T3.awk" photn0002.${ext}
#
echo ""
echo " Kentucky 2000 Test 3: Table 4 40kK PP HII region ..."
run_mv_model "$s/kt00T4_h40pp"
awk -f "$s/kt00T4.awk" photn0003.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T4.awk" photn0003.${ext}
#
echo ""
echo " Kentucky 2000 Test 4: Table 5 Meudon 150kK PN ..."
run_mv_model "$s/kt00T5_PN150"
awk -f "$s/kt00T5.awk" photn0004.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T5.awk" photn0004.${ext}
#
echo ""
echo " Kentucky 2000 Test 5: Table 6 75kK Low Density PN ..."
run_mv_model "$s/kt00T6_PN75Hi"
awk -f "$s/kt00T6.awk" photn0005.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T6.awk" photn0005.${ext}
#
echo ""
echo " Kentucky 2000 Test 6: Table 7 75kK High Density PN ..."
run_mv_model "$s/kt00T7_PN75Lo"
awk -f "$s/kt00T7.awk" photn0006.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T7.awk" photn0006.${ext}
#
echo ""
echo " Kentucky 2000 Test 7: Table 8 AGN NLR PP powerlaw ..."
run_mv_model "$s/kt00T8_NLR"
awk -f "$s/kt00T8.awk" photn0007.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T8.awk" photn0007.${ext}
echo ""
echo " Kentucky 2000 Tests completed. Output in $r/lextest_$d.txt"
#
rm -f timing.txt map5output.txt
rm -f *.${ext} *.csv *.sou
