#!/bin/bash
#SBATCH --job-name=rst_proc
#SBATCH --output=rst%j.log
#SBATCH --error=rst%j.err
#SBATCH --partition=fat
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --time=01:00:00

module load matlab

# Define the path to your MATLAB script
MATLAB_SCRIPT="/iitjhome/p25ai0202/swat/conn_rest_batch.m"

# Run the MATLAB script
matlab -nodisplay -nosplash -noFigureWindows -r "run('$MATLAB_SCRIPT'); exit;"

