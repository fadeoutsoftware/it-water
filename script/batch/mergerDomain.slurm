#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --ntasks=1
#SBATCH --mem=8G
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/merger_domain_logs/rcp45/jobs/converter_%A.out
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-01:00:00                                # Time limit days-hrs:min:sec
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments
#domain_name=$1 Removed we should always merge on "italy" domain
domain_name='italy'
time_start=$1
time_end=$2
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# folders
path_input="/g100_scratch/userexternal/mmenapac/shared/S3M_output/rcp45"
path_destination="/g100_scratch/userexternal/mmenapac/shared/merger_domain_out/rcp45/"
path_log="/g100_scratch/userexternal/mmenapac/shared/merger_domain_logs/rcp45/"
path_tmp="/g100_scratch/userexternal/mmenapac/shared/merger_domain_tmp/rcp45/"
# ----------------------------------------------------------------------------------------

echo " ==================================================================================="
echo " ==> Running merger on domain for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"


singularity exec --writable-tmpfs \
 --env PATH_SRC=/app/exec/data/input \
 --env PATH_DST=/app/exec/data/output/${domain_name} \
 --env PATH_TMP=/app/exec/data/tmp/${domain_name} \
 --env DOMAIN_NAME=${domain_name} \
 --env TIME_START=${time_start} \
 --env TIME_END=${time_end} \
 #--bind ${path_input}:/app/exec/data/input,${path_destination}:/app/exec/data/output,${path_log}:/app/exec/data/logs\ not sure binding is required !
 mergerdomain.sif /app/shybox/workflow/merger/launcher.sh


# echo " ==> Cleaning temp folder "${path_data}/tmp/${domain_name}
# rm -rf ${path_data}/tmp/${domain_name}

# dest_owner=$(stat -c %G ${path_destination}${domain_name})
# if [ $dest_owner != "IscrC_IT-WATER" ]; then
#         echo " ==> Assign group ownership to "${path_destination}${domain_name}
#         chown -R :IscrC_IT-WATER ${path_destination}${domain_name}
# fi
# dest_owner=$(stat -c %G ${path_log}${domain_name})
# if [ $dest_owner != "IscrC_IT-WATER" ]; then
#         echo " ==> Assign group ownership to "${path_log}${domain_name}
#         chown -R :IscrC_IT-WATER ${path_log}${domain_name}
# fi

# echo " ==> Uptading permissions on "${path_destination}${domain_name}
# chmod -R 774 ${path_destination}${domain_name}
# echo " ==> Uptading permissions on "${path_log}${domain_name}
# chmod -R 774 ${path_log}${domain_name}

echo " ==> Completed converter for "${domain_name}" [JOB ID "${SLURM_JOBID}"]"
echo " ==================================================================================="