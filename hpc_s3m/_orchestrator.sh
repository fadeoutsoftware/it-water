#!/bin/bash


# ----------------------------------------------------------------------------------------
# user arguments 
domain_list=$1
time_start=$2
time_end=$3
# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running S3M orchestrator for domains listed in "${domain_list}

for i in {1..20..1}
do
    
	domain_name=$(awk -v ArrayTaskID=$i '$1==ArrayTaskID {print $2}' $domain_list)

	echo " ==> Scheduling converter reanalysis execution for domain: "${domain_name}"."
    c1_job_id=$(sbatch --parsable converter-reanalysis.slurm ${domain_name} 1981-01-01 1981-01-15)
	echo " ==> Converter "${domain_name}" reanalysis jobid is "${c1_job_id}"."

	echo " ==> Scheduling S3M reanalysis execution form domain: "${domain_name}"."
    s3m1_job_id=$(sbatch --parsable --dependency=afterok:$c1_job_id s3m-reanalysis.slurm ${domain_name} "1981-01-01 00:00" "1981-01-15 00:00")
	echo " ==> S3M "${domain_name}" reanalysis jobid is "${s3m1_job_id}"."

	#echo " ==> Scheduling converter rcp45 execution for domain: "${domain_name}"."
    #c2_job_id=$(sbatch --parsable converter-rcp45.slurm ${domain_name} 1981-01-01 1981-01-15)
	#echo " ==> Converter "${domain_name}" rcp45 jobid is "${c2_job_id}"."

	#echo " ==> Scheduling S3M rcp45 execution form domain: "${domain_name}"."
    #s3m2_job_id=$(sbatch --parsable --dependency=afterok:$c2_job_id s3m-rcp45.slurm ${domain_name} "1981-01-01 00:00" "1981-01-15 00:00")
	#echo " ==> S3M "${domain_name}" rcp45 jobid is "${s3m2_job_id}"."

	#echo " ==> Scheduling converter rcp85 execution for domain: "${domain_name}"."
    #c3_job_id=$(sbatch --parsable converter-rcp85.slurm ${domain_name} 1981-01-01 1981-01-15)
	#echo " ==> Converter "${domain_name}" rcp85 jobid is "${c3_job_id}"."

	#echo " ==> Scheduling S3M rcp85 execution form domain: "${domain_name}"."
    #s3m3_job_id=$(sbatch --parsable --dependency=afterok:$c3_job_id s3m-rcp85.slurm ${domain_name} "1981-01-01 00:00" "1981-01-15 00:00")
	#echo " ==> S3M "${domain_name}" rcp85 jobid is "${s3m3_job_id}"."
	
done

echo " ==> S3M orchestrator completed, jobs scheduled with SLURM"
echo " ===================================================================================" 


