#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --mem=8G
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-12:00:00			 	 # Time limit days-hrs:min:sec
#SBATCH --output=/g100_work/IscrC_ITWATER2/tmp/merger_time_%A.out
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments 
calendar=$1
# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running Merger by domain for "${calendar}

iDays=$(wc -l < ${calendar})
for (( i = 1; i < $iDays; i++ )) 
do
	    time_start=$(cat ${calendar}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
	    time_end=$(cat ${calendar}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')		

		echo " ==> Scheduling "${time_start}"-"${time_end}" ..."
	    /g100_work/IscrC_ITWATER2/dummy_task.sh ${time_start} ${time_end} /g100_work/IscrC_ITWATER2/tmp/${time_start}-${time_end}_time.log &
done
wait
echo " ==> Completed Merger by domain [JOB ID "${SLURM_JOBID}"]"
echo " ===================================================================================" 