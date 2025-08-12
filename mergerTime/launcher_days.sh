#!/bin/bash -e
cd $CONDA_PATH 
cd bin 
source activate shybox_base_libraries
cd /app/shybox/workflow/merger
export PYTHONPATH="${PYTHONPATH}:/app/shybox"



python /app/shybox/workflow/merger/app_merger_by_time_workflow_s3m_base_main_days.py -settings /app/shybox/workflow/merger/app_merger_by_time_workflow_s3m_base.json