#!/usr/bin/bash
cppcheck --enable=all -isrc/Third --suppressions-list=suppressions.txt --output-file=cppcheck_txt_report.txt ../vpaint

