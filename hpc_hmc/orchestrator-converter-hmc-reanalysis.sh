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
c_job_id=-1
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

            echo " ==> Days "${days}" "
            echo " ==> Calendar "${calendar}" "
            echo " ==> Scheduling converter forcing reanalysis execution for domain: "${domain_name}"..."


            if [ $c_job_id == -1 ]; then
                 c_job_id=$(sbatch --parsable --ntasks=${days} hmc-converter-forcing-reanalysis.slurm ${domain_name} ${calendar})
            else
                 c_job_id=$(sbatch --parsable --ntasks=${days} --dependency=afterok:$c_job_id hmc-converter-forcing-reanalysis.slurm ${domain_name}  ${calendar})
            fi


            echo " ==> Converter reanalysis Forcing scheduled with job id "${c_job_id}" ."

            echo " ==> Scheduling converter Updating reanalysis execution for domain: "${domain_name}" "${calendar}" ..."
                        c_job_id=$(sbatch --parsable --ntasks=${days} --dependency=afterok:$c_job_id hmc-converter-updating-reanalysis.slurm ${domain_name} ${calendar})

            echo " ==> Converter reanalysis updating scheduled with job id "${c_job_id}"."

        done

done




echo " ==> HMC orchestrator completed, jobs scheduled with SLURM"
echo " ==================================================================================="


