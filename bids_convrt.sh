#!/bin/bash
#SBATCH --job-name=bids
#SBATCH --output=%x-%j.log
#SBATCH --error=%x-%j.err
#SBATCH --partition=test
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=25G
#SBATCH --time=01:00:00


export OMP_NUM_THREADS=5

module load python

python /iitjhome/p25ai0202/swat/bids_convrt.py
