#!/bin/bash
# v1.0.0
make prepare
( make -j 4 compile 1>/dev/null ) 2>&1
make clean
