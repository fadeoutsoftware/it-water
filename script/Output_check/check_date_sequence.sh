#!/bin/bash
# Usage: ./check_date_sequence.sh /path/to/root

ROOT_DIR="$1"

if [ -z "$ROOT_DIR" ]; then
  echo "Usage: $0 /path/to/root"
  exit 1
fi

# Collect all valid date directories
find "$ROOT_DIR" -type d | while read -r dir; do
  IFS='/' read -ra PARTS <<< "$dir"
  len=${#PARTS[@]}
  if [ $len -ge 3 ]; then
    YEAR="${PARTS[$len-3]}"
    MONTH="${PARTS[$len-2]}"
    DAY="${PARTS[$len-1]}"
    if [[ $YEAR =~ ^[0-9]{4}$ && $MONTH =~ ^(0[1-9]|1[0-2])$ && $DAY =~ ^(0[1-9]|[12][0-9]|3[01])$ ]]; then
      echo "$YEAR-$MONTH-$DAY"
    fi
  fi
done | sort | uniq > /tmp/date_list.txt

# Check for consecutive dates
prev=""
while read -r curr; do
  if [ -n "$prev" ]; then
    prev_date=$(date -d "$prev" +%s)
    curr_date=$(date -d "$curr" +%s)
    diff=$(( (curr_date - prev_date) / 86400 ))
    if [ $diff -ne 1 ]; then
      echo "Non-consecutive dates: $prev -> $curr"
    fi
  fi
  prev="$curr"
done < /tmp/date_list.txt

rm /tmp/date_list.txt