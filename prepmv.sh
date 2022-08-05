#!/bin/bash
# v1.0.7 for MV 5119 or newer
# run inside mappings_V-dev
# ../atmos must be present
#   run with one arg - id number/string
#
result=${PWD##*/}
if [[ ${result} != "mappings_V-dev" ]]
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
      echo " eg > ./prepmv.sh 5113  "
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
cp -PR mappings_V-dev mappings_V-${vers}
cd mappings_V-${vers}
rm -rf .git*
# clean out optional files not for distrib
echo "removing priv files"

rm prepmv.sh
rm -rf priv
rm mappingswebsite.zip
rm -rf webpage
rm -rf 00Ignore

# clean data
echo "preparing lab"
cd lab
rm -rf 00ignore
rm map51
echo "cleaning data"
cd data
rm hydrogenic/alternates.zip
rm ionisation/alternates.zip
rm lines/alternates.zip
rm lines/newalternates.zip
rm photdatfiles/Experimental.zip
rm photdatfiles/Old_versions.zip
rm switches.txt
cd ..
echo "cleaning abund"
cd abund
rm -rf CMFGEN
rm -rf lgc2014
rm GC2015.zip
cd ..
#
echo "preparing std atmos"
rm -rf atmos
cp -r ../../atmos .
#
echo "cleaning scripts"
cd scripts
rm     fastshock.zip
rm     tests.zip
rm     hvyrectests.zip
rm -rf cooling/cmfgenxrays
rm -rf cooling/coolimage
cd ..
# and zip it up
echo "zipping archive"
cd ../..
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
