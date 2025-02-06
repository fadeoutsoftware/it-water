#!/bin/bash -e

source $PYTHON_ENV_FILE

export PYTHONPATH="${PYTHONPATH}:/app/shybox"

pip install tabulate

python app_runner_workflow_s3m_base_main.py -settings app_runner_workflow_s3m_base.json