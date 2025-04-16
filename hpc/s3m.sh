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
path_app="/g100_work/IscrC_IT-WATER/converter"
path_input="/g100_work/IscrC_IT-WATER/S3M_input/"
path_destination="/g100_work/IscrC_IT-WATER/S3M_output/"
path_log="/g100_work/IscrC_IT-WATER/S3M_logs/"
path_static="/g100_work/IscrC_IT-WATER/S3M_static/history/"${domain_name}
path_config="/g100_work/IscrC_IT-WATER/S3M_config/history"
# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running S3M for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"


singularity exec --writable-tmpfs \
 --env PATH_APP=/app/exec/ \
 --env PATH_SRC=/app/exec/data/input/${domain_name}  \
 --env PATH_DST=/app/exec/data/output/${domain_name} \
 --env PATH_TMP=/app/exec/data/tmp \
 --env PATH_LOG=/app/exec/logs \
 --env PATH_NAMELIST=/app/exec \
 --env PATH_STATIC=/app/exec/data/static \
 --env DOMAIN_NAME=${domain_name} \
 --env JSON_PATH=/app/exec/data/config/app_runner_workflow_s3m_${domain_name}.json \
 --env S3M_RESTART=0 \
 --env TIME_RUN="$time_start" \
 --env TIME_START="$time_start" \
 --env TIME_RESTART="$time_start" \
 --env TIME_END="$time_end" \
 --env TIME_PERIOD=360 \
 --bind ${path_app}:/app/exec,${path_data}:/app/exec/data/,${path_input}:/app/exec/data/input,${path_destination}:/app/exec/data/output,${path_config}:/app/exec/data/config,${path_static}:/app/exec/data/static,${path_log}:/app/exec/data/logs,\
 s3m.sif /app/shybox/workflow/runner/launcher.sh

echo " ==> Completed S3M for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"
echo " ===================================================================================" 
