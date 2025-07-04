#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --ntasks=1
#SBATCH --mem=8G
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/S3M_converter_logs/rcp45/out/converter_%A.out
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-01:00:00			 	 # Time limit days-hrs:min:sec
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments 
time_start=$1
time_end=$2
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# folders
path_data="/g100_work/IscrC_IT-WATER/converter/rcp45" #????? 
path_input="/g100_scratch/userexternal/mmenapac/shared/S3M_input/rcp45/"
path_destination="/g100_scratch/userexternal/mmenapac/shared/MergerTime_input/rcp45/"
path_log="/g100_scratch/userexternal/mmenapac/shared/Merger/rcp45/"
path_geo="/g100_work/IscrC_IT-WATER/S3M_static/asc/"
# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running merger  [JOB ID "${SLURM_JOBID}"]"


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
 mergerdomain.sif /app/shybox/workflow/merger/launcher.sh

echo " ==> Cleaning temp folder "${path_data}/tmp/${domain_name}
rm -rf ${path_data}/tmp/${domain_name}

echo " ==> Completed merger domain for period "${time_start}" <-> "${time_end}" [JOB ID "${SLURM_JOBID}"]"
echo " ===================================================================================" 
