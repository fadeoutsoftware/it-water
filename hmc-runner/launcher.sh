#!/bin/bash -e

source $PYTHON_ENV_FILE

export PYTHONPATH="${PYTHONPATH}:/app/shybox"

pip install tabulate

python app_runner_workflow_hmc_base_main.py -settings app_runner_workflow_hmc_base.json -time "2021-11-26 00:23"