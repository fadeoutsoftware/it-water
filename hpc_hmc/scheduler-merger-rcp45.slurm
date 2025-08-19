#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/Scheduler_logs/rcp45/scheduler_merger_%A.out
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-00:30:00                                # Time limit days-hrs:min:sec
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments
id=$1
# Launch Generator with the step required 

# Check directories !
echo " ==================================================================================="
echo " ==> JOB Scheduler activated"

cd /g100_work/IscrC_ITWATER2

echo " ==> activating python virtual environment"
source venv/bin/activate


# Generate periods (start stop managed internally by the script, relying on control.json file)
echo " ==> Generating new periods"

control_file="./scheduler/control-merger-rcp45-"${id}".json"
periods_file="periods-merger-rcp45."
periods_file="${periods_file}${id}"

python3 ./scripts/merger/generator.py --controlFile=$control_file

# Schedule new simulation 
echo " ==> Scheduling new run..."
./orchestrator-merger-rcp45-auto.sh $periods_file $id

echo " ==> Scheduler complted, bye bye!"
echo " ==================================================================================="
