#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --ntasks=1
#SBATCH --mem=8G
#SBATCH --output=/g100_work/IscrC_IT-WATER/S3M_converter_logs/rcp45/out/converter_%A.out
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
path_data="/g100_work/IscrC_IT-WATER/converter/rcp45"
path_input="/g100_work/IscrC_IT-WATER/data_CMCC/rcp45/"
path_destination="/g100_work/IscrC_IT-WATER/S3M_input/rcp45/"
path_log="/g100_work/IscrC_IT-WATER/S3M_converter_logs/rcp45/"
path_geo="/g100_work/IscrC_IT-WATER/S3M_static/asc/"
# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running converter for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"


singularity exec --writable-tmpfs \
 --env PATH_APP=/app/exec/ \
 --env PATH_SRC=/app/exec/data/input \
 --env PATH_DST=/app/exec/data/output/${domain_name} \
 --env PATH_TMP=/app/exec/data/tmp/${domain_name} \
 --env PATH_LOG=/app/exec/data/logs/${domain_name} \
 --env PATH_GEO=/app/exec/data/static \
 --env DOMAIN_NAME=${domain_name} \
 --env TIME_START=${time_start} \
 --env TIME_END=${time_end} \
 --bind ${path_data}:/app/exec/data/,${path_input}:/app/exec/data/input,${path_destination}:/app/exec/data/output,${path_geo}:/app/exec/data/static,${path_log}:/app/exec/data/logs,\
 converter.sif /app/shybox/workflow/converter/launcher.sh

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

echo " ==> Completed converter for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"
echo " ===================================================================================" 
