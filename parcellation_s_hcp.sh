#!/bin/bash
#SBATCH --job-name=par
#SBATCH --output=parShcp%j.out
#SBATCH --error=parShcp%j.err
#SBATCH --partition=large
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --mem=90G
#SBATCH --time=04:00:00

module load python
source /scratch/data/p25ai0202/swat/envs/nilearn/bin/activate


python -u /iitjhome/p25ai0202/swat/parcellation_s_hcp.py
