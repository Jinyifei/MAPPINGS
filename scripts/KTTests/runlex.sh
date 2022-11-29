#!/bin/tcsh
# v5.2.0
# tcsh for timing format and $HOST (instead of $HOSTNAME for bash)
#
# setenv NCPUS 4

set d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
set s="KTScripts"
set r="KTResults"
set i="KTInputs"
set ext="ph6"
set mexe="${HOME}/mappings520/bin/map52"
#
echo " Cleaning work area..."
rm -f timing.txt map5output.txt
rm -f *.${ext} *.csv *.sou
#echo " Kentucky 2000 Test 1: Table 2 Cool 20kK HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "$mexe" < "$s/kt00T2_h20.mv" >map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/lextest_$d.txt"
cat timing.txt
awk -f "$s/kt00T2.awk" photn0001.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T2.awk" photn0001.${ext}
#echo " Kentucky 2000 Test 2: Table 3 40kK HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/kt00T3_h40.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/lextest_$d.txt"
cat timing.txt
awk -f "$s/kt00T3.awk" photn0002.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T3.awk" photn0002.${ext}
#echo " Kentucky 2000 Test 3: Table 4 40kK PP HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/kt00T4_h40pp.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/lextest_$d.txt"
cat timing.txt
awk -f "$s/kt00T4.awk" photn0003.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T4.awk" photn0003.${ext}
#echo " Kentucky 2000 Test 4: Table 5 Meudon 150kK PN ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/kt00T5_PN150.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/lextest_$d.txt"
cat timing.txt
awk -f "$s/kt00T5.awk" photn0004.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T5.awk" photn0004.${ext}
#echo " Kentucky 2000 Test 5: Table 6 75kK Low Density PN ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/kt00T6_PN75Hi.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >>"$r/lextest_$d.txt"
cat timing.txt
awk -f "$s/kt00T6.awk" photn0005.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T6.awk" photn0005.${ext}
#echo " Kentucky 2000 Test 6: Table 7 75kK High Density PN ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/kt00T7_PN75Lo.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/lextest_$d.txt"
cat timing.txt
awk -f "$s/kt00T7.awk" photn0006.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T7.awk" photn0006.${ext}
#echo " Kentucky 2000 Test 7: Table 8 AGN NLR PP powerlaw ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/kt00T8_NLR.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/lextest_$d.txt"
cat timing.txt
awk -f "$s/kt00T8.awk" photn0007.${ext} >> "$r/lextest_$d.txt"
awk -f "$s/kt00T8.awk" photn0007.${ext}
echo " Kentucky 2000 Tests completed. Output in $r/lextest_$d.txt"
rm -f timing.txt map5output.txt
rm -f *.${ext} *.csv *.sou
