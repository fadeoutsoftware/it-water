#!/bin/bash

# ----------------------------------------------------------------------------------------
# user arguments
domains=$1
periods=$2
id=$3

# ----------------------------------------------------------------------------------------



echo " ==================================================================================="
echo " ==> Running HMC converter orchestrator for domains listed in "${domains}" with periods from "${periods}

# Array to hold all the job ids
aiJobIds=()

iDomains=$(wc -l < ${domains})
iPeriods=$(wc -l < ${periods})

echo " Domains N "${iDomains}" "
echo " Periods N "${iPeriods}" "
c_f_job_id=-1
c_u_job_id=-1

for (( i = 1; i < $iPeriods; i++ ))
     do

          time_start=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}' | sed 's/T00:00//')
          time_end=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}' | sed 's/T00:00//')
          time_period=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
          days=$(cat ${periods}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')

          echo " ==> Days "${days}" "
          echo " ==> Time Start "${time_start}" "
          echo " ==> Time End "${time_end}" "
          echo " ==> Time Period "${time_period}" "
          echo " ==> Scheduling converter forcing reanalysis execution for ALL domains"

          if [ $c_f_job_id == -1 ]; then
               c_f_job_id=$(sbatch --parsable --ntasks=${iDomains} --cpus-per-task=${days} hmc-converter-forcing-reanalysis.slurm ${domains} ${time_start} ${time_end} ${days})
          else
               c_f_job_id=$(sbatch --parsable --ntasks=${iDomains} --cpus-per-task=${days} --dependency=afterok:$c_f_job_id hmc-converter-forcing-reanalysis.slurm ${domains} ${time_start} ${time_end} ${days})
          fi
          
          echo " ==> Converter reanalysis Forcing scheduled with job id "${c_f_job_id}" ."


          echo " ==> Scheduling converter Updating reanalysis execution for ALL domains"
          if [ $c_u_job_id == -1 ]; then
               c_u_job_id=$(sbatch --parsable --ntasks=${iDomains} --cpus-per-task=${days} --dependency=afterok:$c_f_job_id hmc-converter-updating-reanalysis.slurm ${domains} ${time_start} ${time_end} ${days})
          else
               c_u_job_id=$(sbatch --parsable --ntasks=${iDomains} --cpus-per-task=${days} --dependency=afterok:$c_u_job_id,$c_f_job_id hmc-converter-updating-reanalysis.slurm ${domains} ${time_start} ${time_end} ${days})
          fi
          

          # Accumulate jobid 
	     aiJobIds+=($c_u_job_id)
          echo " ==> Converter reanalysis updating scheduled with job id "${c_u_job_id}"."
     
done

file="stopfile-hmc-converter-reanalysis."
file="${file}${id}"

# Check if the file exists
if [ -e "$file" ]; then
  echo "Scheduled job. Iteration stopped by the presence of stop.reanalysis file ! "
else
  echo "Scheduling another period..."
  scheduler_job_id=$(sbatch --parsable --dependency=afterok:$(IFS=,; echo "${aiJobIds[*]}") scheduler-hmc-converter-reanalysis.slurm ${domains} ${id})
fi



echo " ==> HMC converter orchestrator completed, jobs scheduled with SLURM"
echo " ==================================================================================="