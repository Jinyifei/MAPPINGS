#!/bin/bash
#
# v1.0.6 updated awks
#
# use:  ./getgrid.sh *.csv
#
for i
do
awk -f awk_rats $i
done
