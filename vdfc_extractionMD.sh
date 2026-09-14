#!/bin/bash
#SBATCH --job-name=vdfcMD
#SBATCH --output=vdfcMD%j.out
#SBATCH --error=vdfcMD%j.err
#SBATCH --partition=large
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=50G
#SBATCH --time=06:00:00

module load matlab
matlab -nodisplay -nosplash -noFigureWindows -r "run('/iitjhome/p25ai0202/swat/vdfc_extractionMD.m'); exit;"
