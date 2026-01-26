#!/bin/bash

# ----------------------------------------------------------------------------------------
# user arguments
domains=$1
periods=$2

# ----------------------------------------------------------------------------------------

echo " ==================================================================================="
echo " ==> Running HMC orchestrator for domains listed in "${domains}" with periods from "${periods}

iDomains=$(wc -l < ${domains})
iPeriods=$(wc -l < ${periods})
for (( j = 1; j < $iDomains; j++ ))
do
        domain_name=$(awk -v ArrayTaskID=$j '$1==ArrayTaskID {print $2}' $domains)
        for (( i = 1; i < $iPeriods; i++ ))
        do

			time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
		    time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
		    time_period=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
		    days=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')



			calendar=${time_start:0:7}	
			calendar=/g100_work/IscrC_ITWATER2/calendar/reanalysis/${calendar//-/}.time


            hmc_time_start=${time_start//T/ }
            hmc_time_end=${time_end//T/ }
            

            echo " ==> Scheduling HMC reanalysis execution form domain: "${domain_name}" "${hmc_time_start}" "${hmc_time_period}" "${hmc_max_time}" ..."
            if [ $i == 1 ]; then
                    hmc1_job_id=$(sbatch --parsable hmc-reanalysis.slurm ${domain_name} "${hmc_time_start}" ${time_period})
            elif [ -v hmc1_job_id ]; then
                    hmc1_job_id=$(sbatch --parsable --dependency=afterok:$hmc1_job_id hmc-reanalysis.slurm ${domain_name} "${hmc_time_start}" ${time_period})
            fi
            echo " ==> HMC reanalysis scheduled with job id "${hmc1_job_id}"."

        done

done




echo " ==> HMC orchestrator completed, jobs scheduled with SLURM"
echo " ==================================================================================="