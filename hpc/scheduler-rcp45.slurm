  GNU nano 2.9.8                                                                                                                                     scheduler-rcp45.slurm                                                                                                                                                
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

echo pwd;
cd $WORK

# Generate periods (start stop managed internally by the script, relying on control.json file)
### NOTE Form this 
python3 ./orchestratorParameters/generator.py

# Remove old periods 
rm $WORK/periods-rcp45
# Copy new ones
cp ./orchestratorParameters/periods $WORK/periods-rcp45

# Schedule new simulation 
./orchestrator-rcp45-auto.sh domains periods-rcp45
### To this, for the highest level of safety SHOULD be an atomic operation 

# TODO add some details to the output
echo " ==> New period scheduled"
echo " ==================================================================================="
