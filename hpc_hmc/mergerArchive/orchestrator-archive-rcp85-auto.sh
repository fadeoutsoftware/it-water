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

	echo " ==> Scheduling merger archive with calendar file "${calendar}" ..."
	if [ $i == 1 ]; then
		m1_job_id=$(sbatch --parsable --ntasks=${days} merger-archive-rcp85.slurm ${calendar})
	elif [ -v m1_job_id ]; then
		m1_job_id=$(sbatch --parsable --ntasks=${days} --dependency=afterok:$m1_job_id merger-archive-rcp85.slurm ${calendar})
	fi
	echo " ==> Merger archive scheduled with job id "${m1_job_id}"."

        # Accumulate jobid
        aiJobIds+=($m2_job_id)

done

echo " ==> List of merger job Ids (with commas)"
echo " $(IFS=,; echo "${aiJobIds[*]}")"

# Schedule another launch with a dependency to the jobIds accumulated above
# 1) regenerate periods file with the generator
# 2) If not STOP (presence of file) re-invoke orchestrator with the new periods

file="stopfile-merger-rcp85."
file="${file}${id}"

# Check if the file exists
if [ -e "$file" ]; then
  echo "Scheduled job. Iteration stopped by the presence of stop.rcp85 file ! "
else
  echo "Scheduling another period..."
  scheduler_job_id=$(sbatch --parsable --dependency=afterok:$(IFS=,; echo "${aiJobIds[*]}") scheduler-archive-rcp85.slurm ${id})
fi


echo " ==> Merger orchestrator completed, jobs scheduled with SLURM"
echo " ==================================================================================="


