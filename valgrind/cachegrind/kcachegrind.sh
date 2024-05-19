#!/usr/bin/bash

valgrind --tool=cachegrind --cache-sim=yes ../build/src/GUI/.VPaint

kcachegrind cachegrind.out.*
