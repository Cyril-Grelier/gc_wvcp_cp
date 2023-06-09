#!/bin/bash

#SBATCH --job-name=cp
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --array=1-1000
#SBATCH --time=01:10:00
#SBATCH --partition=SMP-short
#SBATCH --exclude=cribbar[041-056]
#SBATCH --output=/scratch/LERIA/grelier_c/slurm_output/slurm-%x-%a-%j.out
#SBATCH --mem=8G

./scripts/one_job.sh "${SLURM_ARRAY_TASK_ID}" "$1"
