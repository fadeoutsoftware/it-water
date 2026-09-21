#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 SSH_TARGET REMOTE_BASE_PATH YEAR MONTH DESTINATION_PATH" >&2
  echo "  SSH_TARGET: user@host (or an SSH alias from ~/.ssh/config)" >&2
  echo "  REMOTE_BASE_PATH: directory containing the domain folders" >&2
}

if [[ $# -ne 5 ]]; then
  usage
  exit 1
fi

SSH_TARGET=$1
REMOTE_BASE=$2
YEAR=$3
MONTH=$4
DESTINATION_BASE=$5

if [[ ! $YEAR =~ ^[0-9]{4}$ ]]; then
  echo "Invalid year: $YEAR" >&2
  exit 1
fi

if [[ ! $MONTH =~ ^(0?[1-9]|1[0-2])$ ]]; then
  echo "Invalid month: $MONTH" >&2
  exit 1
fi
MONTH=$(printf '%02d' "$((10#$MONTH))")

shell_quote() {
  printf "'%s'" "${1//\'/\'\\\'\'}"
}

REMOTE_BASE=${REMOTE_BASE%/}
remote_base_quoted=$(shell_quote "$REMOTE_BASE")
mapfile -t DOMAINS < <(
  ssh "$SSH_TARGET" "find $remote_base_quoted -mindepth 1 -maxdepth 1 -type d -printf '%f\\n' | sort"
)

if [[ ${#DOMAINS[@]} -eq 0 ]]; then
  echo "No domain folders found under ${SSH_TARGET}:${REMOTE_BASE}" >&2
  exit 1
fi

copy_month() {
  local relative_path=$1
  local destination_path=$2
  local remote_path="${REMOTE_BASE}/${relative_path}"
  local destination_parent

  if [[ -d "$destination_path" ]]; then
    echo "Skipping existing destination folder: ${relative_path}"
    return
  fi

  if ! ssh "$SSH_TARGET" "test -d $(shell_quote "$remote_path")"; then
    echo "Skipping missing remote path: ${relative_path}" >&2
    return
  fi

  destination_parent=$(dirname "$destination_path")
  mkdir -p "$destination_parent"
  echo "Downloading ${relative_path}"
  scp -r "${SSH_TARGET}:$(shell_quote "$remote_path")" "$destination_parent/"
}

for domain in "${DOMAINS[@]}"; do

  for model_root in model_results model_state; do
    for frequency in gridded point; do
      relative_path="${domain}/${model_root}/${frequency}/${YEAR}/${MONTH}"
      copy_month "$relative_path" "${DESTINATION_BASE}/${relative_path}"
    done

    relative_path="${domain}/${model_root}/time_series/${YEAR}-${MONTH}"
    copy_month "$relative_path" "${DESTINATION_BASE}/${relative_path}"
  done
done

echo "Selected assets copied to: $DESTINATION_BASE"