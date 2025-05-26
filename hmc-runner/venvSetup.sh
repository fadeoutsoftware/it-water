#!/bin/bash -e
cd $CONDA_PATH 
cd bin 
source activate shybox_base_libraries
cd /app/shybox/workflow/runner
export PYTHONPATH="${PYTHONPATH}:/app/shybox"

pip install tabulate
pip install rioxarray
pip install pyresample
pip install repurpose