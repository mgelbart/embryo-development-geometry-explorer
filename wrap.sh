#!/bin/bash
mv DATA_INFO.csv DATA_INFO_TEMP.csv
mv DATA_INFO_DEFAULT.csv DATA_INFO.csv
zip -r EDGE-$1.zip DATA_INFO.csv install.m java1 Matlab Measurements
mv DATA_INFO.csv DATA_INFO_DEFAULT.csv
mv DATA_INFO_TEMP.csv DATA_INFO.csv