#!/usr/bin/bash

cppcheck --enable=all -isrc/Third --suppressions-list=suppressions.txt --output-file=cppcheck_xml_report.xml --xml ../vpaint

cppcheck-htmlreport --file cppcheck_xml_report.xml --report-dir=report

firefox report/index.html

