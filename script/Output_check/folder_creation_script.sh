#!/bin/bash
# Usage: ./create_date_folders.sh START_DATE END_DATE ROOT_DIR
# Example: ./create_date_folders.sh 2024-01-01 2024-01-10 /path/to/root

START_DATE="$1"
END_DATE="$2"
ROOT_DIR="$3"

if [ -z "$START_DATE" ] || [ -z "$END_DATE" ] || [ -z "$ROOT_DIR" ]; then
  echo "Usage: $0 START_DATE(YYYY-MM-DD) END_DATE(YYYY-MM-DD) ROOT_DIR"
  exit 1
fi

current="$START_DATE"
while [[ "$current" < "$END_DATE" || "$current" == "$END_DATE" ]]; do
  YEAR=$(date -d "$current" +%Y)
  MONTH=$(date -d "$current" +%m)
  DAY=$(date -d "$current" +%d)
  mkdir -p "$ROOT_DIR/$YEAR/$MONTH/$DAY"
  current=$(date -I -d "$current + 1 day")
done