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

echo " Domains N "${iDomains}" "
echo " Periods N "${iPeriods}" "
c_f_job_id=-1
c_u_job_id=-1
for (( j = 1; j < $iDomains; j++ ))
do      
        echo "Extracting domain name..."
        domain_name=$(awk -v ArrayTaskID=$j '$1==ArrayTaskID {print $2}' $domains)
        echo "Domain name : " ${domain_name}

        for (( i = 1; i < $iPeriods; i++ ))
        do

		    time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
		    time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
		    time_period=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
		    days=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')

			calendar=${time_start:0:7}	
			calendar=/g100_work/IscrC_ITWATER2/calendar/reanalysis/${calendar//-/}.time

            echo " ==> Days "${days}" "
            echo " ==> Calendar "${calendar}" "
            echo " ==> Scheduling converter forcing reanalysis execution for domain: "${domain_name}"..."
            

            if [ $c_f_job_id == -1 ]; then
                 c_f_job_id=$(sbatch --parsable --ntasks=${days} hmc-converter-forcing-reanalysis.slurm ${domain_name} ${calendar})
            else
                 c_f_job_id=$(sbatch --parsable --ntasks=${days} --dependency=afterok:$c_f_job_id hmc-converter-forcing-reanalysis.slurm ${domain_name}  ${calendar})
            fi
            
            echo " ==> Converter reanalysis Forcing scheduled with job id "${c_f_job_id}" ."

            echo " ==> Scheduling converter Updating reanalysis execution for domain: "${domain_name}" "${calendar}" ..."
			if [ $c_u_job_id == -1 ]; then
                 c_u_job_id=$(sbatch --parsable --ntasks=${days} hmc-converter-updating-reanalysis.slurm ${domain_name} ${calendar})
            else
                 c_u_job_id=$(sbatch --parsable --ntasks=${days} --dependency=afterok:$c_u_job_id hmc-converter-updating-reanalysis.slurm ${domain_name}  ${calendar})
            fi

            echo " ==> Converter reanalysis updating scheduled with job id "${c_u_job_id}"."
           
        done

done




echo " ==> HMC orchestrator completed, jobs scheduled with SLURM"
echo " ==================================================================================="
