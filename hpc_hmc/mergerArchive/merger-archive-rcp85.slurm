#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --account=IscrC_ITWATER2
#SBATCH --mem=64G
#SBATCH --partition=g100_usr_prod
#SBATCH --time=4:00:00
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/merger_archive_logs/rcp85/merger_archive_%A.out
#SBATCH --cpus-per-task=24
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments
calendar=$1
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# folders
path_data="/g100_work/IscrC_ITWATER2/merger/archive/rcp85/"
path_input="/g100_work/smr_prod/a07smr01/IT-WATER/S3M_output/rcp85/"
path_destination="/g100_work/smr_prod/a07smr01/IT-WATER/S3M_archive/rcp85/"
path_log="/g100_scratch/userexternal/mmenapac/shared/merger_archive_logs/rcp85/"
path_geo="/g100_work/IscrC_ITWATER2/static"
path_geo_tmp="/g100_scratch/userexternal/mmenapac/shared/merger_archive_static/"
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
		 mergerarchive.sif /app/shybox/workflow/merger/launcher.sh &
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
