#!/bin/bash
#SBATCH --job-name=par
#SBATCH --output=parhcp%j.out
#SBATCH --error=parhcp%j.err
#SBATCH --partition=fat
#SBATCH --nodes=1
#SBATCH --cpus-per-task=3
#SBATCH --ntasks=1
#SBATCH --mem=150G
#SBATCH --time=12:00:00

module load python
source /scratch/data/p25ai0202/swat/envs/nilearn/bin/activate


python /iitjhome/p25ai0202/swat/parcellation_2.py
