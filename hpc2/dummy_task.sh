#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <time_start> <time_end> <out>"
    exit 1
fi

time_start="$1"
time_end="$2"
out="$3"

time_start=${time_start//T/ }
time_end=${time_end//T/ }

echo "start: $time_start, end $time_end" >> $out
