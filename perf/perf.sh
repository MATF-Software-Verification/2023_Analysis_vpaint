#!/usr/bin/bash

sudo perf record --call-graph dwarf ./../build/src/Gui/VPaint

sudo perf report
