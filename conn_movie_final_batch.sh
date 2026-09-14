#!/bin/bash
#SBATCH --job-name=mov_prec
#SBATCH --output=movexc%j.log
#SBATCH --error=movexc%j.err
#SBATCH --partition=fat
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --ntasks=1
#SBATCH --mem=400G
#SBATCH --time=09:00:00

module load matlab

# Define the path to your MATLAB script
MATLAB_SCRIPT="/iitjhome/p25ai0202/swat/conn_movie_final_batch.m"

# Run the MATLAB script
matlab -nodisplay -nosplash -noFigureWindows -r "run('$MATLAB_SCRIPT'); exit;"

