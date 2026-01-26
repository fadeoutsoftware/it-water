#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --account=CNHPC_2363290
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/Scheduler_hmc_logs/reanalysis/scheduler_hmc_converter_%A.out
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-00:30:00                                # Time limit days-hrs:min:sec
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------

# user arguments
domains=$1
id=$2
# Launch Generator with the step required 

# Check directories !
echo " ==================================================================================="
echo " ==> JOB Scheduler activated"

cd /g100_work/CNHPC_2363290

echo " ==> activating python virtual environment"
source .venv/bin/activate


# Generate periods (start stop managed internally by the script, relying on control.json file)
echo " ==> Generating new periods"

control_file="./scheduler/control-hmc-converter-reanalysis-"${id}".json"
periods_file="periods-hmc-converter-reanalysis."
periods_file="${periods_file}${id}"

python3 ./scripts/converter/generator.py --controlFile=$control_file

# Schedule new simulation 
echo " ==> Scheduling new run..."
./orchestrator-converter-reanalysis-auto.sh $domains $periods_file $id

echo " ==> Scheduler completed, bye bye!"
echo " ==================================================================================="
