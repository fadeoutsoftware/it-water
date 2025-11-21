#!/bin/bash

# ----------------------------------------------------------------------------------------
# user arguments 
periods=$1

# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running merger orchestrator with periods from "${periods}


iPeriods=$(wc -l < ${periods})
for (( i = 1; i < $iPeriods; i++ )) 
do
    time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
    time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
    days=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')


	calendar=${time_start:0:7}	
	calendar=/g100_work/IscrC_ITWATER2/calendar/reanalysis/${calendar//-/}.time

	echo " ==> Scheduling merger by domain with calendar file "${calendar}" ..."
	if [ $i == 1 ]; then
		m1_job_id=$(sbatch --parsable --ntasks=${days} merger-archive-reanalysis.slurm ${calendar})
	elif [ -v m1_job_id ]; then
		m1_job_id=$(sbatch --parsable --ntasks=${days} --dependency=afterok:$m1_job_id merger-archive-reanalysis.slurm ${calendar})			
	fi
	echo " ==> Merger by domain scheduled with job id "${m1_job_id}"."

done


echo " ==> Merger orchestrator completed, jobs scheduled with SLURM"
echo " ===================================================================================" 


