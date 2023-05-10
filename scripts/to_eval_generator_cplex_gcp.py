"""
Generate to_eval file which list all run to perform for CP
"""

from string import Template
import os

# Choose the set of instances
instances_set = ("instance_list_gcp", "all_gcp")

# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

output_directory = f"/scratch/LERIA/grelier_c/cplex_{instances_set[1]}"

rep_cplex_original = "cplex_original"
rep_cplex_reduced = "cplex_reduced"

os.mkdir(f"{output_directory}")
os.mkdir(f"{output_directory}/{rep_cplex_original}")
os.mkdir(f"{output_directory}/{rep_cplex_reduced}")


command_cplex_original = Template(
    "./MWSS_cplex/cplex -T3600 instances/original_graphs/${instance}.col empty_weights "
    "> ${output_dir}/${repertory}/${instance}.cplex\n"
)

command_cplex_reduced = Template(
    "./MWSS_cplex/cplex instances/reduced_wvcp/${instance}.col empty_weights "
    "> ${output_dir}/${repertory}/${instance}.cplex\n"
)


with open("to_solve_cplex_gcp", "w", encoding="UTF8") as file:
    for instance in instances:
        file.write(
            command_cplex_original.substitute(
                instance=instance,
                output_dir=output_directory,
                repertory=rep_cplex_original,
            )
        )

        file.write(
            command_cplex_reduced.substitute(
                instance=instance,
                output_dir=output_directory,
                repertory=rep_cplex_reduced,
            )
        )
