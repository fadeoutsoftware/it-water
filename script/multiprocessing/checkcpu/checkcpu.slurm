#!/bin/bash

#SBATCH --nodes=3                    # 3 node
#SBATCH --ntasks-per-node=48         # 48 tasks per node
#SBATCH --time=1:00:00               # time limit: 1 hour
#SBATCH --error=myJob.err            # standard error file
#SBATCH --output=/g100_scratch/userexternal/mmenapac/outcpu.out           # standard output file
#SBATCH --partition=g100_usr_prod

srun checkcpu.sif