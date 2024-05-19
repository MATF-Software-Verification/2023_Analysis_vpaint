#!/usr/bin/bash

valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --track-origins=yes --log-file=memcheck.txt ../build/src/GUI/VPaint
