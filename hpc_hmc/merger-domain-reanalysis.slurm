#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --mem=64G
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-12:00:00			 	 # Time limit days-hrs:min:sec
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/merger_domain_logs/reanalysis/merger_domain_%A.out
#SBATCH --cpus-per-task=24
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments 
calendar=$1
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# folders
path_data="/g100_work/IscrC_ITWATER2/merger/domain/reanalysis/"
path_input="/g100_work/smr_prod/a07smr01/IT-WATER/S3M_output/reanalysis/"
path_destination="/g100_scratch/userexternal/mmenapac/shared/merger_domain_output/reanalysis/"
path_log="/g100_scratch/userexternal/mmenapac/shared/merger_domain_logs/reanalysis/"
path_geo="/g100_work/IscrC_ITWATER2/static"
path_geo_tmp="/g100_scratch/userexternal/mmenapac/shared/merger_domain_static/"
# ----------------------------------------------------------------------------------------


echo " ===================================================================================" 
echo " ==> Running Merger by domain for "${calendar}

iDays=$(wc -l < ${calendar})
for (( i = 1; i < $iDays; i++ )) 
do
	    time_start=$(cat ${calendar}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
	    time_end=$(cat ${calendar}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')		

		time_start=${time_start//T/ }
		time_end=${time_end//T/ }

		path_data_i=${path_data}/${SLURM_JOBID}/${i}
		mkdir -p ${path_data_i}
		
		echo " ==> Scheduling "${time_start}"-"${time_end}" ..."
		srun  --ntasks=1 --nodes=1 --cpus-per-task=$SLURM_CPUS_PER_TASK singularity exec --writable-tmpfs \
		 --env PATH_APP=/app/exec/ \
		 --env PATH_SRC=/app/exec/data/input/ \
		 --env PATH_DST=/app/exec/data/output/ \
		 --env PATH_TMP=/app/exec/data/tmp/ \
		 --env PATH_LOG=/app/exec/data/logs/ \
		 --env PATH_GEO=/app/exec/data/static \
		 --env TIME_START="${time_start}" \
		 --env TIME_END="${time_end}" \
		 --bind ${path_data_i}:/app/exec/data/,${path_input}:/app/exec/data/input,${path_destination}:/app/exec/data/output,${path_geo}:/app/exec/data/static \
		 mergerdomain.sif /app/shybox/workflow/merger/launcher_hours.sh &
done

wait

echo " ==> Cleaning up folders ...."
for (( i = 1; i < $iDays; i++ )) 
do
	path_data_i=${path_data}/${SLURM_JOBID}/${i}
	rm -rf ${path_data_i}
done

echo " ==> Completed Merger by domain [JOB ID "${SLURM_JOBID}"]"
echo " ===================================================================================" 