#!/bin/bash -e
cd $CONDA_PATH 
cd bin 
source activate shybox_base_libraries
cd /app/shybox/workflow/converter
export PYTHONPATH="${PYTHONPATH}:/app/shybox"

## To be checked if already present 
pip install tabulate
pip install rioxarray
pip install pyresample
pip install repurpose