#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --account=IscrC_ITWATER2
#SBATCH --ntasks=1
#SBATCH --mem=8G
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/HMC_converter_forcing_logs/reanalysis/jobs/converter_%A.out
#SBATCH --partition=g100_usr_prod
#SBATCH --cpus-per-task=24
#SBATCH --time=0-8:00:00                        # Time limit days-hrs:min:sec
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments
domain_name=$1
time_start=$2
time_end=$3
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# folders
path_data="/g100_work/IscrC_ITWATER2/converter-forcing/reanalysis"
path_input_cmcc="/g100_work/IscrC_IT-WATER/data_CMCC/reanalysis/"
path_input_s3m="/g100_work/smr_prod/a07smr01/IT-WATER/S3M_data/reanalysis"
path_destination="/g100_work/smr_prod/a07smr01/IT-WATER/HMC_input/reanalysis/"
path_log="/g100_scratch/userexternal/mmenapac/shared/HMC_converter_forcing_logs/reanalysis/"
path_geo="/g100_work/IscrC_ITWATER2/HMC_static"
# ----------------------------------------------------------------------------------------

echo " ==================================================================================="
echo " ==> Running converter FORCING for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"


srun  --ntasks=1 --nodes=1 --cpus-per-task=$SLURM_CPUS_PER_TASK singularity exec --writable-tmpfs \
 --env PATH_APP=/app/exec/ \
 --env PATH_SRC_BY_BIAS_CORRECTION=/app/exec/data/input/cmcc \
 --env PATH_SRC_BY_S3M=/app/exec/data/input/s3m \
 --env PATH_DST=/app/exec/data/output/${domain_name} \
 --env PATH_TMP=/app/exec/data/tmp/${domain_name} \
 --env PATH_LOG=/app/exec/data/logs/${domain_name} \
 --env PATH_GEO=/app/exec/data/static \
 --env DOMAIN_NAME=${domain_name} \
 --env TIME_START=${time_start} \
 --env TIME_END=${time_end} \
 --bind ${path_data}:/app/exec/data/,${path_input_cmcc}:/app/exec/data/input/cmcc,${path_input_s3m}:/app/exec/data/input/s3m,${path_destination}:/app/exec/data/output,${path_geo}:/app/exec/data/static,${path_log}:/app/exec/data/logs,\
 hmc-converter-forcing.sif /app/shybox/workflow/converter/launcher.sh

echo " ==> Cleaning temp folder "${path_data}/tmp/${domain_name}
rm -rf ${path_data}/tmp/${domain_name}


echo " ==> Completed converter FORCING for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"
echo " ==================================================================================="
