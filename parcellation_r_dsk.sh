#!/bin/bash
#SBATCH --job-name=par
#SBATCH --output=parRDsk%j.out
#SBATCH --error=parRDsk%j.err
#SBATCH --partition=large
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --mem=60G
#SBATCH --time=12:00:00

module load python
source /scratch/data/p25ai0202/swat/envs/nilearn/bin/activate


python -u /iitjhome/p25ai0202/swat/parcellation_r.py
