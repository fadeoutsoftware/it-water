#!/bin/bash

# ----------------------------------------------------------------------------------------
# user arguments 
domains=$1
periods=$2

# ----------------------------------------------------------------------------------------

echo " ===================================================================================" 
echo " ==> Running S3M orchestrator for domains listed in "${domains}" with periods from "${periods}

iDomains=$(wc -l < ${domains})
iPeriods=$(wc -l < ${periods})
for (( j = 1; j < $iDomains; j++ )) 
do
	domain_name=$(awk -v ArrayTaskID=$j '$1==ArrayTaskID {print $2}' $domains)
	for (( i = 1; i < $iPeriods; i++ )) 
	do
	    s3m_restart_flag=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
	    s3m_time_restart=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
	    s3m_time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
	    s3m_time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')
	    s3m_time_period=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $5}')
	    s3m_max_time=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $6}')
	    s3m_terrdata_flag=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $7}')

		conv_time_start=${s3m_time_start:0:10}
		conv_time_end=${s3m_time_end:0:10}
		s3m_time_start=${s3m_time_start//T/ }
		s3m_time_end=${s3m_time_end//T/ }
		s3m_time_restart=${s3m_time_restart//T/ }

		echo " ==> Scheduling converter reanalysis execution for domain: "${domain_name}" "${conv_time_start}" "${conv_time_end}" ..."
		if [ $i == 1 ]; then
			c1_job_id=$(sbatch --parsable --time=${s3m_max_time} converter-rcp85.slurm ${domain_name} ${conv_time_start} ${conv_time_end})
		elif [ -v s3m1_job_id ]; then
			c1_job_id=$(sbatch --parsable --time=${s3m_max_time} --dependency=afterok:$c1_job_id converter-rcp85.slurm ${domain_name} ${conv_time_start} ${conv_time_end})			
		fi
		echo " ==> Converter rcp85 scheduled with job id "${c1_job_id}"."

		echo " ==> Scheduling S3M rcp85 execution form domain: "${domain_name}" "${s3m_restart_flag}" "${s3m_terrdata_flag}" "${s3m_time_restart}" "${s3m_time_start}" "${s3m_time_end}" "${s3m_time_period}" "${s3m_max_time}" ..."
		if [ $i == 1 ]; then
			s3m1_job_id=$(sbatch --parsable --time=${s3m_max_time} --dependency=afterok:$c1_job_id s3m-rcp85.slurm ${domain_name} ${s3m_restart_flag} ${s3m_terrdata_flag} "${s3m_time_restart}" "${s3m_time_start}" "${s3m_time_end}" ${s3m_time_period})
		elif [ -v s3m1_job_id ]; then
			s3m1_job_id=$(sbatch --parsable --time=${s3m_max_time} --dependency=afterok:$c1_job_id,$s3m1_job_id s3m-rcp85.slurm ${domain_name} ${s3m_restart_flag} ${s3m_terrdata_flag} "${s3m_time_restart}" "${s3m_time_start}" "${s3m_time_end}" ${s3m_time_period})
		fi
		echo " ==> S3M rcp85 scheduled with job id "${s3m1_job_id}"."

				
	done

  
done




echo " ==> S3M orchestrator completed, jobs scheduled with SLURM"
echo " ===================================================================================" 


