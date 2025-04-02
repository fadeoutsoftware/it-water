#!/bin/bash -e
cd $CONDA_PATH 
cd bin 
source activate shybox_base_libraries
cd /app/shybox/workflow/converter
export PYTHONPATH="${PYTHONPATH}:/app/shybox"



python /app/shybox/workflow/converter/app_converter_workflow_s3m_base_main.py -settings /app/shybox/workflow/converter/app_converter_workflow_s3m_base.json -time "2025-03-26 12:00"