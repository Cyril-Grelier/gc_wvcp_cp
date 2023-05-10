"""
Generate to_eval file which list all run to perform for CP
"""

from string import Template

# Choose the set of instances
instances_set = ("pxx", "pxx")
instances_set = ("rxx", "rxx")
instances_set = ("DIMACS_non_optimal", "dimacs_no")
instances_set = ("DIMACS_optimal", "dimacs_o")
instances_set = ("../instances_coeff", "hard_wvcp_coeff")
instances_set = ("../instances_hard_wvcp", "hard_wvcp")
instances_set = ("instance_list_wvcp", "all")
instances_set = ("../instance_feasible", "feasible")

# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

time_limit = 3600 * 1000 * 1

output_directory = f"outputs/cp_1h_E1_{instances_set[1]}"
output_directory = f"/scratch/LERIA/grelier_c/cp_1h_E1_{instances_set[1]}"

rep_primal_1 = "E1_primal_static"
rep_primal_2 = "E1_primal_dynamic"
rep_dual_ortools = "E1_dual_ortool"
rep_dual_coin_bc = "E1_dual_coin_bc"
rep_joint = "E1_joint"


command_ortools_run = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    "--output-to-file ${output_dir}/${repertory}/${instance_type}_${instance}.json "
    "${output_dir}/${repertory}/${instance_type}_${instance}.fzn\n"
)


command_coin_bc_run = Template(
    "minizinc --solver coin-bc --time-limit ${runtime} --parallel 0 "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    "--output-to-file ${output_dir}/${repertory}/${instance_type}_${instance}.json "
    "${output_dir}/${repertory}/${instance_type}_${instance}.fzn\n"
)


instance_types = ["original", "reduced"]

with open("to_solve", "w", encoding="UTF8") as file:
    for instance_type in instance_types:
        for instance in instances:
            file.write(
                command_ortools_run.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_primal_1,
                )
            )
            file.write(
                command_ortools_run.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_primal_2,
                )
            )
            file.write(
                command_ortools_run.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_dual_ortools,
                )
            )
            file.write(
                command_coin_bc_run.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_dual_coin_bc,
                )
            )

            file.write(
                command_ortools_run.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_joint,
                )
            )
