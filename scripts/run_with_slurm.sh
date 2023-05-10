#!/bin/bash

echo "dont exec this file"
exit 1

# steps to runs all jobs

# 1 : generate folders and list of commands
python3 scripts/to_eval_generator_cp.py

# 2 : split the to_eval file
split -l 1000 -d to_eval_cp to_eval_cp

# 3 : launch each jobs by 1000 and add the job id after launching each command
# edit the following line in slurm_cp.sh if less than 1000 jobs in the file
# #SBATCH --array=1-1000 (1 et 1000 included)

sbatch scripts/slurm_cp.sh to_eval_cp

# 4 : check for problems
find output_slurm/ -size 0 -delete
find output_slurm/ -ls -exec cat {} \;
find output_test_slurm -name "*.csv.running" -ls

rm scratch/grelier_c/slurm_output/*.out
find scratch/grelier_c/slurm_output/*.out -size 0 -delete
find scratch/grelier_c/slurm_output/*.out -not -size 0
find scratch/grelier_c/slurm_output/*.out -not -size 0 -ls -exec cat {} \;
python3 scripts/to_flat_generator.py
split -l 1000 -d to_flat to_flat
sbatch scripts/slurm_cp.sh to_flatx
