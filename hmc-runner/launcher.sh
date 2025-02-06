#!/bin/bash -e

# Command to be launched within docker
# /app/library/libs_system/hmc/HMC_Model_V3_$RUN.x
#/app/library/libs_system/hmc

source $PYTHON_ENV_FILE

/app/library/libs_system/hmc/HMC_Model_V3_\$RUN.x /app/mnt_in/namelist/marche.info.txt