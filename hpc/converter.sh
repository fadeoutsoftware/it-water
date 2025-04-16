#!/bin/bash


# ----------------------------------------------------------------------------------------
# user arguments 
domain_name=$1
time_start=$2
time_end=$3
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# folders
path_data="/g100_work/IscrC_IT-WATER/converter"
path_input="/g100_work/IscrC_IT-WATER/data_CMCC/reanalysis/"
path_destination="/g100_work/IscrC_IT-WATER/S3M_input/"
path_log="/g100_work/IscrC_IT-WATER/S3M_converter_logs/"
path_geo="/g100_work/IscrC_IT-WATER/S3M_static/asc/"
# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running converter for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"


singularity exec --writable-tmpfs \
 --env PATH_APP=/app/exec/ \
 --env PATH_SRC=/app/exec/data/input \
 --env PATH_DST=/app/exec/data/output/${domain_name} \
 --env PATH_TMP=/app/exec/data/tmp \
 --env PATH_LOG=/app/exec/logs \
 --env PATH_GEO=/app/exec/data/static \
 --env DOMAIN_NAME=${domain_name} \
 --env TIME_START=${time_start} \
 --env TIME_END=${time_end} \
 --bind ${path_data}:/app/exec/data/,${path_input}:/app/exec/data/input,${path_destination}:/app/exec/data/output,${path_geo}:/app/exec/data/static,${path_log}:/app/exec/data/logs,\
 converter.sif /app/shybox/workflow/converter/launcher.sh

echo " ==> Completed converter for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"
echo " ===================================================================================" 
