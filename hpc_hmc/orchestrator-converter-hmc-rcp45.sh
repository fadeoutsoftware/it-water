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
f_job_id=-1
u_job_id=-1


        for (( i = 1; i < $iPeriods; i++ ))
        do

                    time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
                    time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
                    time_period=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
                    days=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')

                        

            echo " ==> Days "${days}" "
            echo " ==> Scheduling converter forcing reanalysis execution for domain: "${domain_name}"..."


            if [ $f_job_id == -1 ]; then
                 f_job_id=$(sbatch --parsable --ntasks=${iDomains} hmc-converter-forcing-rcp45.slurm ${domains} ${time_start} ${time_end} ${days})
            else
                 f_job_id=$(sbatch --parsable --ntasks=${iDomains} --dependency=afterok:$f_job_id hmc-converter-forcing-rcp45.slurm ${domains} ${time_start} ${time_end} ${days})
            fi


            echo " ==> Converter reanalysis Forcing scheduled with job id "${f_job_id}" ."

            if [ $u_job_id == -1 ]; then
                 u_job_id=$(sbatch --parsable --ntasks=${iDomains} hmc-converter-updating-rcp45.slurm ${domains} ${time_start} ${time_end} ${days})
            else
                 u_job_id=$(sbatch --parsable --ntasks=${iDomains} --dependency=afterok:$u_job_id hmc-converter-updating-rcp45.slurm ${domains} ${time_start} ${time_end} ${days})
            fi
            echo " ==> Converter reanalysis updating scheduled with job id "${u_job_id}"."

        done

done




echo " ==> HMC orchestrator completed, jobs scheduled with SLURM"
echo " ==================================================================================="


