#!/bin/bash -e
source $PYTHON_ENV_FILE

export PYTHONPATH="${PYTHONPATH}:/app/shybox"

path_json=$1
echo "path_json = " ${path_json}

python /app/shybox/workflow/runner/app_runner_workflow_s3m_base_main.py -settings ${path_json}