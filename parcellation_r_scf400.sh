#!/bin/bash
#SBATCH --job-name=par
#SBATCH --output=parRscf%j.out
#SBATCH --error=parRscf%j.err
#SBATCH --partition=large
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --time=05:00:00

module load python
source /scratch/data/p25ai0202/swat/envs/nilearn/bin/activate


python -u /iitjhome/p25ai0202/swat/parcellation_r_scf400.py
