#!/usr/bin/bash

valgrind --tool=cachegrind --cache-sim=yes ../build/src/GUI/.VPaint

cg_annotate cachegrind.out.* > cachegrind-report.txt
