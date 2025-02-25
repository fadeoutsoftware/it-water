#!/bin/bash -e

source $PYTHON_ENV_FILE

export PYTHONPATH="${PYTHONPATH}:/app/shybox"

pip install tabulate

python /app/shybox/workflow/runner/app_runner_workflow_hmc_base_main.py -settings /app/shybox/workflow/runner/app_runner_workflow_hmc_base.json