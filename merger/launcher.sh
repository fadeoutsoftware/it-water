#!/bin/bash -e

source $PYTHON_ENV_FILE

export PYTHONPATH="${PYTHONPATH}:/app/shybox"

python workflow/dataset/mergeapp_dataset_workflow_merge_grid_main.py -settings workflow/dataset/merge/app_dataset_workflow_merge_grid_nc_example.json