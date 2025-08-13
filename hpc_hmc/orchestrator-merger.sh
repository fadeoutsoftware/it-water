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
    restart_flag=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
    time_restart=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
    time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
    time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')
    time_period=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $5}')
    max_time=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $6}')

    #TODO get the number of months from the periods file

	calendar=${time_start:0:7}	
	calendar=/g100_work/IscrC_ITWATER2/calendar/reanalysis/${calendar//-/}.time

	echo " ==> Scheduling merger by domain with calendar file "${calendar}" ..."
	if [ $i == 1 ]; then
		m1_job_id=$(sbatch --parsable --time=${max_time} --ntasks=31 merger-domain-rcp45.slurm ${calendar})
	elif [ -v m1_job_id ]; then
		m1_job_id=$(sbatch --parsable --time=${max_time} --ntasks=31 --dependency=afterok:$m1_job_id merger-domain-rcp45.slurm ${calendar})			
	fi
	echo " ==> Merger by domain scheduled with job id "${m1_job_id}"."

	echo " ==> Scheduling merger by time with calendar file "${calendar}" ..."
	if [ $i == 1 ]; then
		m2_job_id=$(sbatch --parsable --time=${max_time} --ntasks=31 --dependency=afterok:$m1_job_id merger-time-rcp45.slurm  ${calendar})
	elif [ -v m2_job_id ]; then
		m2_job_id=$(sbatch --parsable --time=${max_time} --ntasks=31 --dependency=afterok:$m1_job_id,$m2_job_id merger-time-rcp45.slurm ${calendar})
	fi
	echo " ==> Merger by time scheduled with job id "${m2_job_id}"."
done


echo " ==> Merger orchestrator completed, jobs scheduled with SLURM"
echo " ===================================================================================" 


