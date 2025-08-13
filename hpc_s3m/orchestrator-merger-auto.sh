#!/bin/bash

# ----------------------------------------------------------------------------------------
# user arguments 
periods=$1

# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running merger for all domains with periods from "${periods}


iPeriods=$(wc -l < ${periods})
# Array to hold all s3m job Ids
aiJobIds=()
for (( i = 1; i < $iPeriods; i++ )) 
	do
	    
	    merger_time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
	    merger_time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')
	    
	    merger_max_time=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $6}')
	    merger_terrdata_flag=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $7}')

		conv_time_start=${merger_time_start:0:10}
		conv_time_end=${merger_time_end:0:10}
		

		echo " ==> Scheduling merger Domain execution for period:  "${conv_time_start}" "${conv_time_end}" ..."
		if [ $i == 1 ]; then
			c1_job_id=$(sbatch --parsable --time=${merger_max_time} merger-domain.slurm ${conv_time_start} ${conv_time_end})
		elif [ -v s3m1_job_id ]; then
			c1_job_id=$(sbatch --parsable --time=${merger_max_time} --dependency=afterok:$c1_job_id merger-domain.slurm ${conv_time_start} ${conv_time_end})			
		fi
		echo " ==> merger Domain scheduled with job id "${c1_job_id}"."

		echo " ==> Scheduling merger Time execution for period:  "${conv_time_start}" "${conv_time_end}" ..."
		if [ $i == 1 ]; then
			c1_job_id=$(sbatch --parsable --time=${merger_max_time} merger-time.slurm ${conv_time_start} ${conv_time_end})
		elif [ -v s3m1_job_id ]; then
			c1_job_id=$(sbatch --parsable --time=${merger_max_time} --dependency=afterok:$c1_job_id merger-time.slurm ${conv_time_start} ${conv_time_end})			
		fi
		echo " ==> merger Time scheduled with job id "${c1_job_id}"."
		# Accumulate jobid of S3M in an array
		aiJobIds+=($s3m1_job_id)

	

done

echo " ==> List of Merger domain/time job Ids (with commas)"
echo " $(IFS=,; echo "${aiJobIds[*]}")"

# Schedule another launch with a dependency to the jobIds of S3M accumulated above
# 1) regenerate periods file with the generator
# 2) If not STOP (to be handled, it can be the presence of a file, for example) re-invoke orchestrator with the new periods
file="stop.merger"

# Check if the file exists
if [ -e "$file" ]; then
  echo "Scheduled job. Iteration stopped by the presence of stop.rcp45 file ! "
else
  echo "Scheduling another period..."
  scheduler_job_id=$(sbatch --parsable --dependency=afterok:$(IFS=,; echo "${aiJobIds[*]}") scheduler-merger.slurm)
fi


echo " ==> Merger orchestrator done, jobs scheduled with SLURM"
echo " ===================================================================================" 


