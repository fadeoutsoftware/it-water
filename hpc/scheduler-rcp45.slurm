#!/bin/bash

# ----------------------------------------------------------------------------------------
# SLURM directives
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --output=/g100_scratch/userexternal/mmenapac/shared/Scheduler_logs/rcp45/out/Scheduler_%A.out
#SBATCH --partition=g100_usr_prod
#SBATCH --time=0-00:30:00			 	 # Time limit days-hrs:min:sec
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# user arguments
# Launch Generator
# Generator parameters ?!?!?
# 
echo " ==> ALL done."
echo " ===================================================================================" 
