#!/bin/bash
#SBATCH --job-name=vdfc_excel_out
#SBATCH --output=VE%j.log
#SBATCH --error=VE%j.err
#SBATCH --partition=large
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --time=00:30:00

module load matlab

# Define the path to your MATLAB script
MATLAB_SCRIPT="/iitjhome/p25ai0202/swat/vdfc_excel_out_subID_from_mat.m"

# Run the MATLAB script
matlab -nodisplay -nosplash -noFigureWindows -r "run('$MATLAB_SCRIPT'); exit;"

