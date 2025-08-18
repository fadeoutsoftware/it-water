#!/bin/bash

# ----------------------------------------------------------------------------------------
# user arguments 
periods=$1
id=$2

# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running merger orchestrator with periods from "${periods}

# Array to hold all the job ids
aiJobIds=()

iPeriods=$(wc -l < ${periods})
for (( i = 1; i < $iPeriods; i++ )) 
do
    time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
    time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
    days=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')


	calendar=${time_start:0:7}	
	calendar=/g100_work/IscrC_ITWATER2/calendar/rcp85/${calendar//-/}.time

	echo " ==> Scheduling merger by domain with calendar file "${calendar}" ..."
	if [ $i == 1 ]; then
		m1_job_id=$(sbatch --parsable --ntasks=${days} merger-domain-rcp85.slurm ${calendar})
	elif [ -v m1_job_id ]; then
		m1_job_id=$(sbatch --parsable --ntasks=${days} --dependency=afterok:$m1_job_id merger-domain-rcp85.slurm ${calendar})			
	fi
	echo " ==> Merger by domain scheduled with job id "${m1_job_id}"."

	echo " ==> Scheduling merger by time with calendar file "${calendar}" ..."
	if [ $i == 1 ]; then
		m2_job_id=$(sbatch --parsable --ntasks=1 --dependency=afterok:$m1_job_id merger-time-rcp85.slurm ${time_start} ${time_end})
	elif [ -v m2_job_id ]; then
		m2_job_id=$(sbatch --parsable --ntasks=1 --dependency=afterok:$m1_job_id,$m2_job_id merger-time-rcp85.slurm ${time_start} ${time_end})
	fi
	echo " ==> Merger by time scheduled with job id "${m2_job_id}"."
	# Accumulate jobid 
	aiJobIds+=($m2_job_id)

done

echo " ==> List of merger job Ids (with commas)"
echo " $(IFS=,; echo "${aiJobIds[*]}")"

# Schedule another launch with a dependency to the jobIds accumulated above
# 1) regenerate periods file with the generator
# 2) If not STOP (to be handled, it can be the presence of a file, for example) re-invoke orchestrator with the new periods

file="stopfile-merger-rcp85."
file="${file}${id}"

# Check if the file exists
if [ -e "$file" ]; then
  echo "Scheduled job. Iteration stopped by the presence of stop.rcp85 file ! "
else
  echo "Scheduling another period..."
  scheduler_job_id=$(sbatch --parsable --dependency=afterok:$(IFS=,; echo "${aiJobIds[*]}") scheduler-merger-rcp85.slurm ${id})
fi


echo " ==> Merger orchestrator completed, jobs scheduled with SLURM"
echo " ===================================================================================" 


