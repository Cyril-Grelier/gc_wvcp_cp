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
instances_set = ("instance_list_wvcp", "all")
instances_set = ("../instance_feasible", "feasible")

# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

output_directory = f"outputs/cp_1h_E1_{instances_set[1]}"
output_directory = f"/scratch/LERIA/grelier_c/cp_1h_E1_{instances_set[1]}"

rep_primal_1 = "E1_primal_static_h2"
rep_primal_2 = "E1_primal_dynamic_h2"
rep_joint_1 = "E1_joint_dynamic_h2"
rep_joint_2 = "E1_joint_static_h2"

# os.mkdir(f"{output_directory}")
os.mkdir(f"{output_directory}/{rep_primal_1}")
os.mkdir(f"{output_directory}/{rep_primal_2}")
os.mkdir(f"{output_directory}/{rep_joint_1}")
os.mkdir(f"{output_directory}/{rep_joint_2}")

time_limit = 3600 * 1000 * 1

bounds = (
    "-d src/core/default_lb_colors.dzn "
    "-d src/core/default_ub_colors.dzn "
    "-d src/core/default_lb_score.dzn "
    "-d src/core/default_ub_score.dzn "
    "-d src/core/no_cliques.dzn "
)


# 1.1 primal avec les bornes par défaut et avec la règle statique bornant
# les domaines des sommets en fonction de leurs degrés (DG)
command_primal_1 = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "PRIMAL_STRATEGY=VERTICES_SPECIFIC" '
    '-D "PRIMAL_RESTART=RESTART_NONE" '
    '-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_COLORS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_VERTICES=DESC_WEIGHT_DEGREE" '
    '-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" '
    '-D "WVCP_M={M_DG}" '
    f"{bounds} "
    "-m src/primal/primal_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)


# 1.2 primal avec les bornes par défaut et avec la règle en version statique
# et dynamique v2 bornant les domaines des sommets en fonction de leurs degrés (DG + MLS)
command_primal_2 = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "PRIMAL_STRATEGY=VERTICES_SPECIFIC" '
    '-D "PRIMAL_RESTART=RESTART_NONE" '
    '-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_COLORS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_VERTICES=DESC_WEIGHT_DEGREE" '
    '-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" '
    '-D "WVCP_M={M_DG, M_MLS}" '
    f"{bounds} "
    "-m src/primal/primal_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)

# 1.4 joint avec les bornes par défaut et avec la règle en version statique et dynamique v2 bornant les domaines des sommets en fonction de leurs degrés (DG + MLS)
command_joint_1 = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "JOINT_STRATEGY=PRIMAL" '
    '-D "PRIMAL_STRATEGY=VERTICES_SPECIFIC" '
    '-D "PRIMAL_RESTART=RESTART_NONE" '
    '-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_COLORS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_VERTICES=DESC_WEIGHT_DEGREE" '
    '-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" '
    '-D "DUAL_STRATEGY=ARCS_SPECIFIC" '
    '-D "DUAL_RESTART=RESTART_NONE" '
    '-D "DUAL_H_VAR_ARCS=DESC_WEIGHT_TAIL" '
    '-D "DUAL_H_VAL_ARCS=INDOMAIN_MAX" '
    '-D "WVCP_M={M_DG,M_MLS}" '
    f"{bounds} "
    "-m src/joint/joint_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)

# 1.5 joint avec les bornes par défaut et avec la règle en version statique bornant les domaines des sommets en fonction de leurs degrés (DG)
command_joint_2 = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "JOINT_STRATEGY=PRIMAL" '
    '-D "PRIMAL_STRATEGY=VERTICES_SPECIFIC" '
    '-D "PRIMAL_RESTART=RESTART_NONE" '
    '-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_COLORS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_VERTICES=DESC_WEIGHT_DEGREE" '
    '-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" '
    '-D "DUAL_STRATEGY=ARCS_SPECIFIC" '
    '-D "DUAL_RESTART=RESTART_NONE" '
    '-D "DUAL_H_VAR_ARCS=DESC_WEIGHT_TAIL" '
    '-D "DUAL_H_VAL_ARCS=INDOMAIN_MAX" '
    '-D "WVCP_M={M_DG}" '
    f"{bounds} "
    "-m src/joint/joint_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)


instance_types = ["original", "reduced"]


with open("to_solve", "w", encoding="UTF8") as file:
    for instance_type in instance_types:
        for instance in instances:
            file.write(
                command_primal_1.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_primal_1,
                )
            )
            file.write(
                command_primal_2.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_primal_2,
                )
            )
            file.write(
                command_joint_1.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_joint_2,
                )
            )

            file.write(
                command_joint_2.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_joint_2,
                )
            )
