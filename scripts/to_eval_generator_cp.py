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

# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

time_limit = 3600 * 1000 * 10

output_directory = f"/scratch/LERIA/grelier_c/cp_{instances_set[1]}"
output_directory = f"outputs/cp_10h_{instances_set[1]}"

os.mkdir(f"{output_directory}")

command_primal = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics --solver-statistics --no-intermediate --output-mode json --json-stream "
    '-D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" '
    '-D "WVCP_SEARCH_RESTART=RESTART_NONE" '
    '-D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" '
    '-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" '
    '-D "WVCP_B={UB_COLORS,UB_SCORE}" '
    '-D "WVCP_M={M_SR1,M_DR2_v2}" '
    "-d core/default_ub_colors.dzn "
    "-d core/default_ub_score.dzn "
    "-d core/no_cliques.dzn "
    "-m ./primal/primal_solve.mzn "
    "-d ../${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ../${output_dir}/primal_${instance_type}_${instance}.json\n"
)

command_dual = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics --solver-statistics --no-intermediate --output-mode json --json-stream "
    '-D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" '
    '-D "MWSSP_SEARCH_RESTART=RESTART_NONE" '
    '-D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" '
    '-D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" '
    '-D "WVCP_B={UB_COLORS,UB_SCORE}" '
    '-D "WVCP_M={}" '
    "-d core/default_ub_colors.dzn "
    "-d core/default_ub_score.dzn "
    "-d core/no_cliques.dzn "
    "-m dual/dual_solve.mzn "
    "-d ../${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ../${output_dir}/dual_${instance_type}_${instance}.json\n"
)

command_joint = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics --solver-statistics --no-intermediate --output-mode json --json-stream "
    '-D "MWSSP_WVCP_SEARCH_STRATEGY=MWSSP" '
    '-D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" '
    '-D "WVCP_SEARCH_RESTART=RESTART_NONE" '
    '-D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_MIN" '
    '-D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" '
    '-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" '
    '-D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" '
    '-D "MWSSP_SEARCH_RESTART=RESTART_NONE" '
    '-D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" '
    '-D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" '
    '-D "WVCP_B={UB_COLORS,UB_SCORE}" '
    '-D "WVCP_M={}" '
    "-d core/default_ub_colors.dzn "
    "-d core/default_ub_score.dzn "
    "-d core/no_cliques.dzn "
    "-m joint/joint_solve.mzn "
    "-d ../${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ../${output_dir}/joint_${instance_type}_${instance}.json\n"
)


instance_types = ["original", "reduced"]


with open("to_eval_cp", "w", encoding="UTF8") as file:
    for instance_type in instance_types:
        for instance in instances:
            file.write(
                command_primal.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                )
            )
            file.write(
                command_dual.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                )
            )
            file.write(
                command_joint.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                )
            )
