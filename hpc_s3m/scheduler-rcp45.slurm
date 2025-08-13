#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/Scheduler_logs/rcp45/Scheduler_%A.out
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-00:30:00                                # Time limit days-hrs:min:sec
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments
# Launch Generator with the step required 

# Check directories !
echo " ==================================================================================="
echo " ==> JOB Scheduler activated"
echo pwd;
cd $WORK

echo " ==> activating python virtual environment"
source .venv/bin/activate


# Generate periods (start stop managed internally by the script, relying on control.json file)
### NOTE Form this 
echo " ==> Generating new periods"
python3 ./scripts/generator.py --controlFile=control-rcp45.json


# Schedule new simulation 
echo " ==> Scheduling new run..."
./orchestrator-rcp45-auto.sh domains periods_rcp45
### To this, for the highest level of safety SHOULD be an atomic operation 

# TODO add some details to the output
echo " ==> Scheduler complted, bye bye!"
echo " ==================================================================================="
