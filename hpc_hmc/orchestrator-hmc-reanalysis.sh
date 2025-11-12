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
            hmc_restart_flag=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
            hmc_time_restart=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
            hmc_time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
            hmc_time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')
            hmc_time_period=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $5}')
            hmc_max_time=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $6}')
            hmc_terrdata_flag=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $7}')

                conv_time_start=${hmc_time_start:0:10}
                conv_time_end=${hmc_time_end:0:10}
                hmc_time_start=${hmc_time_start//T/ }
                hmc_time_end=${hmc_time_end//T/ }
                hmc_time_restart=${hmc_time_restart//T/ }

                echo " ==> Scheduling converter forcing reanalysis execution for domain: "${domain_name}" "${conv_time_start}" "${conv_time_end}" ..."
                if [ $i == 1 ]; then
                        c1_job_id=$(sbatch --parsable --time=${hmc_max_time} hmc-converter-forcing-reanalysis.slurm ${domain_name} ${conv_time_start} ${conv_time_end})
                elif [ -v hmc1_job_id ]; then
                        c1_job_id=$(sbatch --parsable --time=${hmc_max_time} --dependency=afterok:$c1_job_id hmc-converter-forcing-reanalysis.slurm ${domain_name} ${conv_time_start} ${conv_time_end})
                fi
                echo " ==> Converter reanalysis forcing scheduled with job id "${c1_job_id}"."

                echo " ==> Scheduling converter updating reanalysis execution for domain: "${domain_name}" "${conv_time_start}" "${conv_time_end}" ..."
                if [ $i == 1 ]; then
                        c2_job_id=$(sbatch --parsable --time=${hmc_max_time} hmc-converter-updating-reanalysis.slurm ${domain_name} ${conv_time_start} ${conv_time_end})
                elif [ -v hmc1_job_id ]; then
                        c2_job_id=$(sbatch --parsable --time=${hmc_max_time} --dependency=afterok:$c2_job_id hmc-converter-updating-reanalysis.slurm ${domain_name} ${conv_time_start} ${conv_time_end})
                fi
                echo " ==> Converter reanalysis updating scheduled with job id "${c2_job_id}"."


                echo " ==> Scheduling HMC reanalysis execution form domain: "${domain_name}" "${hmc_time_start}" "${hmc_time_period}" "${hmc_max_time}" ..."
                if [ $i == 1 ]; then
                        hmc1_job_id=$(sbatch --parsable --time=${hmc_max_time} --dependency=afterok:$c1_job_id,afterok:$c2_job_id hmc-reanalysis.slurm ${domain_name} "${hmc_time_start}" ${hmc_time_period})
                elif [ -v hmc1_job_id ]; then
                        hmc1_job_id=$(sbatch --parsable --time=${hmc_max_time} --dependency=afterok:$c1_job_id,afterok:$c2_job_id,afterok:$hmc1_job_id hmc-reanalysis.slurm ${domain_name} "${hmc_time_start}" ${hmc_time_period})
                fi
                echo " ==> HMC reanalysis scheduled with job id "${hmc1_job_id}"."


        done


done




echo " ==> HMC orchestrator completed, jobs scheduled with SLURM"
echo " ==================================================================================="