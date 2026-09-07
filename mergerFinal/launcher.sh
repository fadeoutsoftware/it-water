#!/bin/bash -e
cd /app/shybox
source $CONDA_PATH/shybox_base_settings
cd /app/shybox/workflow/merger
export PYTHONPATH="${PYTHONPATH}:/app/shybox"

python /app/shybox/workflow/merger/app_merger_by_domain_workflow_hmc_et.py -settings /app/shybox/workflow/merger/app_merger_by_domain_workflow_hmc_et.json