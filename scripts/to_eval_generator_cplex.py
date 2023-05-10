"""
Generate to_eval file which list all run to perform for CP
"""

from string import Template
import os

# Choose the set of instances
instances_set = ("pxx", "pxx")
instances_set = ("rxx", "rxx")
instances_set = ("DIMACS_non_optimal", "dimacs_no")
instances_set = ("DIMACS_optimal", "dimacs_o")
instances_set = ("../instances_coeff", "hard_wvcp_coeff")
instances_set = ("../instances_hard_wvcp", "hard_wvcp")
instances_set = ("../instance_feasible", "feasible")
instances_set = ("instance_list_wvcp", "all")

# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

output_directory = f"outputs/cp_1h_E1_{instances_set[1]}"
output_directory = f"/scratch/LERIA/grelier_c/cplex_original_{instances_set[1]}"

rep_cplex = "original"

os.mkdir(f"{output_directory}")
os.mkdir(f"{output_directory}/{rep_cplex}")


command_cplex_original = Template(
    "./MWSS_cplex/cplex -T36000 instances/original_graphs/${instance}.col  instances/original_graphs/${instance}.col.w "
    "> ${output_dir}/${repertory}/original_${instance}.json\n"
)

# command_cplex_reduced = Template(
#     "./MWSS_cplex/cplex instances/reduced_wvcp/${instance}.col  instances/reduced_wvcp/${instance}.col.w "
#     "> ${output_dir}/${repertory}/reduced_${instance}.json\n"
# )


with open("to_solve_cplex", "w", encoding="UTF8") as file:
    for instance in instances:
        file.write(
            command_cplex_original.substitute(
                instance=instance,
                output_dir=output_directory,
                repertory=rep_cplex,
            )
        )

        # file.write(
        #     command_cplex_reduced.substitute(
        #         instance=instance,
        #         output_dir=output_directory,
        #         repertory=rep_cplex,
        #     )
        # )
