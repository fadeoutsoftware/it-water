#!/bin/bash -e

source $PYTHON_ENV_FILE

export PYTHONPATH="${PYTHONPATH}:/app/shybox"

python /app/entrypoint/hmc_tool_processing_datasets_merger.py -settings /app/shybox/workflow/runner/merger_workflow.json