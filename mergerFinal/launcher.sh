#!/bin/bash -e
cd $CONDA_PATH 
cd bin 
source activate shybox_base_libraries
cd /app/shybox/workflow/merger
export PYTHONPATH="${PYTHONPATH}:/app/shybox"

python /app/shybox/workflow/merger/mergerFinal/app_merger_by_domain_workflow_hmc_et.py -settings /app/shybox/workflow/merger/app_merger_by_domain_workflow_hmc_et.json
