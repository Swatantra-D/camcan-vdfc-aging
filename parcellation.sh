#!/bin/bash
#SBATCH --job-name=par
#SBATCH --output=parDsk%j.out
#SBATCH --error=parDsk%j.err
#SBATCH --partition=large
#SBATCH --nodes=1
#SBATCH --cpus-per-task=6
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --time=06:00:00

module load python
source /scratch/data/p25ai0202/swat/envs/nilearn/bin/activate


python -u /iitjhome/p25ai0202/swat/parcellation.py
