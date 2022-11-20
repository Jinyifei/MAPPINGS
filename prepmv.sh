#!/bin/bash
# v1.0.8 for MV 520 or newer
# run inside mappings_V
# ../atmos must be present
#   run with one arg - id number/string
#
result=${PWD##*/}
if [[ ${result} != "mappings_V" ]]
then
      echo " WARNING: Can be destructive if used improperly."
      echo " Must be run inside the mappings_V-dev directory "
      exit -1
fi
#
if [[ ! -d "../atmos" ]]
then
      echo " WARNING: Can be destructive if used improperly."
      echo " The standardised atmos directory must exist"
      exit -1
fi
#
if (( $# < 1 )); then
      echo " WARNING: Can be destructive if used improperly."
      echo " Run with 1 arg for version number "
      echo " eg > ./prepmv.sh 520  "
      echo " "
      exit -1
fi
#
vers=${1}
# get up and out of main dev directory
cd ../
#
echo "Preparing "mappings_V-${vers}
#
cp -PR mappings_V mappings_V-${vers}
cd mappings_V-${vers}
rm -rf .git*
# clean out optional files not for distrib
echo "removing priv files"
rm prepmv.sh
rm for_bashrc.txt
rm for_tcshrc.txt
# clean
echo "preparing lab"
cd lab
pwd
rm -rf 00ignore
rm -f map52*
echo "cleaning data"
cd data
pwd
rm -f switches.txt
cd ../..
echo "cleaning bin"
cd bin
pwd
rm  -f map52*
cd ..
#
# and zip it up
echo "zipping archive"
cd ..
rm mappings_V-${vers}/.DS_Store
rm mappings_V-${vers}/*/.DS_Store
rm mappings_V-${vers}/*/*/.DS_Store
rm mappings_V-${vers}/*/*/*/.DS_Store
zip -r -9 mappings_V-${vers} mappings_V-${vers}
cp -r mappings_V-${vers} M_V-${vers}
rm -rf M_V-${vers}/lab/atmos
zip -r -9 M_V-${vers} M_V-${vers}
#rm -rf M_V-${vers}
#rm -rf mappings_V-${vers}
