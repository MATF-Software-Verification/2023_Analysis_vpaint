#!/usr/bin/bash

valgrind --tool=cachegrind --cache-sim=yes ../../build/src/Gui/VPaint

cg_annotate cachegrind.out.* > cachegrind-report.txt
