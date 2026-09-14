#!/bin/bash
#SBATCH --job-name=vdfc
#SBATCH --output=VM%j.log
#SBATCH --error=VM%j.err
#SBATCH --partition=large
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=60G
#SBATCH --time=06:00:00

module load matlab

# Define the path to your MATLAB script
MATLAB_SCRIPT="/iitjhome/p25ai0202/swat/vdfc_extraction.m"

# Run the MATLAB script
matlab -nodisplay -nosplash -noFigureWindows -r "run('$MATLAB_SCRIPT'); exit;"

