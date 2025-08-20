#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --mem=64G
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-12:00:00			 	 # Time limit days-hrs:min:sec
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/merger_time_logs/reanalysis/merger_time_%A.out
#SBATCH --cpus-per-task=2

# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments 
time_start=$1
time_end=$2
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# folders
path_data="/g100_work/IscrC_ITWATER2/merger/time/reanalysis/"
path_input="/g100_scratch/userexternal/mmenapac/shared/merger_domain_output/reanalysis"
path_destination="/g100_work/smr_prod/a07smr01/IT-WATER/S3M_data/reanalysis/"
path_log="/g100_scratch/userexternal/mmenapac/shared/merger_domain_logs/reanalysis/"
path_geo="/g100_work/IscrC_ITWATER2/static"
path_geo_tmp="/g100_scratch/userexternal/mmenapac/shared/merger_time_static/"
dash="'"
# ----------------------------------------------------------------------------------------


echo " ===================================================================================" 
echo " ==> Running Merger by time for "${calendar}


path_data_job=${path_data}/${SLURM_JOBID}
mkdir -p ${path_data_job}
		
path_tmp=${path_data_job}/tmp
mkdir ${path_tmp}

srun  --ntasks=1 --nodes=1 --cpus-per-task=$SLURM_CPUS_PER_TASK singularity exec --writable-tmpfs \
 --env PATH_APP=/app/exec/ \
 --env PATH_SRC=/app/exec/data/input/ \
 --env PATH_DST=/app/exec/data/output/ \
 --env PATH_TMP=/app/exec/data/tmp/ \
 --env PATH_LOG=/app/exec/data/logs/ \
 --env PATH_GEO=/app/exec/data/static \
 --env TIME_START="${time_start}" \
 --env TIME_END="${time_end}" \
 --bind ${path_data_job}:/app/exec/data/,${path_input}:/app/exec/data/input,${path_destination}:/app/exec/data/output,${path_geo}:/app/exec/data/static,${path_tmp}:/app/exec/data/tmp,\
 mergertime.sif /app/shybox/workflow/merger/launcher_days.sh


echo " ==> Cleaning up folders ...."
rm -rf ${path_data_job}

echo " ==> Completed Merger by time [JOB ID "${SLURM_JOBID}"]"
echo " ===================================================================================" 