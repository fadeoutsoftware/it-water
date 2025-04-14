#!/bin/bash -e
cd $CONDA_PATH 
cd bin 
source activate shybox_base_libraries
cd /app/shybox/workflow/runner
export PYTHONPATH="${PYTHONPATH}:/app/shybox"
echo -----------------------------------------------------
echo JSON PATH : 
echo $JSON_PATH
echo -----------------------------------------------------

python /app/shybox/workflow/runner/app_runner_workflow_s3m_base_main.py -settings $JSON_PATH