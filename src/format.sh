#!/bin/bash
# v1.0.0
make prepare
cp mastercode/tidy.ini workcode/
cd workcode/
for i in *.f
do
srcbase=${i%.*}
result=$( /usr/local/bin/tidy72 ${srcbase}.f | grep "Warning")
error=$( grep "FATAL ERROR" ${srcbase}.lis )
echo ${error}
if [[ ${error} ]]
then
 echo "${error}"
 cat "${srcbase}.lis"
 exit -1
fi
if [[ ${result} ]]
then
 echo "${result}"
 echo "${srcbase}.tid "
 exit -1
 else
 echo "OK"
 echo "${srcbase}.tid "
#
# clean up elseif if to elseif bug in old tidy72 code..
#
 sed s/elseif\ if/elseif/g ${srcbase}.tid > tst_${srcbase}.f
 sed s/^c\ $/c/g tst_${srcbase}.f > ${srcbase}.f
 rm tst_${srcbase}.f
 fi
done
cd ..
#
# make sure it builds
#
make -j compile
#
# cleanup
#
rm workcode/*.o
rm workcode/*.lis
rm workcode/*.tid
rm workcode/tidy.ini
make clean
