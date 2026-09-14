#!/bin/bash
#SBATCH --job-name=compress
#SBATCH --output=%j.log
#SBATCH --error=%j.err
#SBATCH --partition=large # Partition Name
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=26
#SBATCH --mem=100G
#SBATCH --time=07:00:00

cd /scratch/data/p25ai0202/swat/cam_data/rst_pt1_v2

pigz -7 -p 25 -rf .
