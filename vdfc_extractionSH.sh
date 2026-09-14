#!/bin/bash
#SBATCH --job-name=vdfcSH
#SBATCH --output=vdfcSH%j.out
#SBATCH --error=vdfcSH%j.err
#SBATCH --partition=large
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=60G
#SBATCH --time=09:00:00

module load matlab
matlab -nodisplay -nosplash -noFigureWindows -r "run('/iitjhome/p25ai0202/swat/vdfc_extractionSH.m'); exit;"
