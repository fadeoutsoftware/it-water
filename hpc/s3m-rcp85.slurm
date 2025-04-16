#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --ntasks=1
#SBATCH --mem=8G
#SBATCH --output=/g100_work/IscrC_IT-WATER/S3M_logs/rcp85/out/S3M_%A.out
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-01:00:00			 	 # Time limit days-hrs:min:sec
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments 
domain_name=$1
time_start=$2
time_end=$3
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# folders
path_data="/g100_work/IscrC_IT-WATER/s3m/rcp85"
path_app="/g100_work/IscrC_IT-WATER/s3m/rcp85"
path_input="/g100_work/IscrC_IT-WATER/S3M_input/rcp85/"
path_destination="/g100_work/IscrC_IT-WATER/S3M_output/rcp85/"
path_log="/g100_work/IscrC_IT-WATER/S3M_logs/rcp85/"
path_static="/g100_work/IscrC_IT-WATER/S3M_static/present/"${domain_name}
path_config="/g100_work/IscrC_IT-WATER/S3M_config/present"
# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running S3M for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"


singularity exec --writable-tmpfs \
 --env PATH_APP=/app/exec/ \
 --env PATH_SRC=/app/exec/data/input/${domain_name}  \
 --env PATH_DST=/app/exec/data/output/${domain_name} \
 --env PATH_TMP=/app/exec/data/tmp/${domain_name} \
 --env PATH_LOG=/app/exec/data/logs/${domain_name} \
 --env PATH_NAMELIST=/app/exec \
 --env PATH_STATIC=/app/exec/data/static/ \
 --env DOMAIN_NAME=${domain_name} \
 --env JSON_PATH=/app/exec/data/config/app_runner_workflow_s3m_${domain_name}.json \
 --env S3M_RESTART=0 \
 --env TIME_RUN="$time_start" \
 --env TIME_START="$time_start" \
 --env TIME_RESTART="$time_start" \
 --env TIME_END="$time_end" \
 --env TIME_PERIOD=360 \
 --bind ${path_data}:/app/exec/data/,${path_input}:/app/exec/data/input,${path_destination}:/app/exec/data/output,${path_config}:/app/exec/data/config,${path_static}:/app/exec/data/static,${path_log}:/app/exec/data/logs,\
 s3m.sif /app/shybox/workflow/runner/launcher.sh

echo " ==> Cleaning temp folder "${path_data}/tmp/${domain_name}
rm -rf ${path_data}/tmp/${domain_name}

dest_owner=$(stat -c %G ${path_destination}${domain_name}) 
if [ $dest_owner != "IscrC_IT-WATER" ]; then
	echo " ==> Assign group ownership to "${path_destination}${domain_name}
	chown -R :IscrC_IT-WATER ${path_destination}${domain_name}
fi
dest_owner=$(stat -c %G ${path_log}${domain_name})
if [ $dest_owner != "IscrC_IT-WATER" ]; then
	echo " ==> Assign group ownership to "${path_log}${domain_name}
	chown -R :IscrC_IT-WATER ${path_log}${domain_name}
fi

echo " ==> Uptading permissions on "${path_destination}${domain_name}
chmod -R 774 ${path_destination}${domain_name}
echo " ==> Uptading permissions on "${path_log}${domain_name}
chmod -R 774 ${path_log}${domain_name}


echo " ==> Completed S3M for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"
echo " ===================================================================================" 
