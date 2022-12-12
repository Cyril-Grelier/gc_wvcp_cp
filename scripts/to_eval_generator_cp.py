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

rep_primal_1 = "E1_primal_static"
rep_primal_2 = "E1_primal_dynamic"
rep_dual_ortools = "E1_dual_ortool"
rep_dual_coin_bc = "E1_dual_coin_bc"
rep_joint = "E1_joint"
rep_joint_v2 = "E1_joint_static"

# os.mkdir(f"{output_directory}")
# os.mkdir(f"{output_directory}/{rep_primal_1}")
# os.mkdir(f"{output_directory}/{rep_primal_2}")
# os.mkdir(f"{output_directory}/{rep_dual_ortools}")
# os.mkdir(f"{output_directory}/{rep_dual_coin_bc}")
# os.mkdir(f"{output_directory}/{rep_joint}")
os.mkdir(f"{output_directory}/{rep_joint_v2}")

time_limit = 3600 * 1000 * 1

bounds = (
    "-d src/core/default_lb_colors.dzn "
    "-d src/core/default_ub_colors.dzn "
    "-d src/core/default_lb_score.dzn "
    "-d src/core/default_ub_score.dzn "
    "-d src/core/no_cliques.dzn "
)


# 1.1 primal avec les bornes par défaut et avec la règle statique bornant
# les domaines des sommets en fonction de leurs degrés (SR2)
command_primal_v1 = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" '
    '-D "WVCP_SEARCH_RESTART=RESTART_NONE" '
    '-D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" '
    '-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" '
    '-D "WVCP_M={M_SR2}" '
    f"{bounds} "
    "-m src/primal/primal_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)

# 1.2 primal avec les bornes par défaut et avec la règle en version statique
# et dynamique v2 bornant les domaines des sommets en fonction de leurs degrés (SR2 + DR2_v2)
command_primal_v2 = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" '
    '-D "WVCP_SEARCH_RESTART=RESTART_NONE" '
    '-D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" '
    '-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" '
    '-D "WVCP_M={M_SR2, M_DR2_v2}" '
    f"{bounds} "
    "-m src/primal/primal_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)

# 1.3 dual avec les bornes par défaut et sans aucune règle (ne sont pas activées de toute façon)
command_dual_ortools = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" '
    '-D "MWSSP_SEARCH_RESTART=RESTART_NONE" '
    '-D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" '
    '-D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" '
    '-D "WVCP_M={}" '
    f"{bounds} "
    "-m src/dual/dual_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)

command_dual_coin_bc = Template(
    "minizinc --solver coin-bc --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" '
    '-D "MWSSP_SEARCH_RESTART=RESTART_NONE" '
    '-D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" '
    '-D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" '
    '-D "WVCP_M={}" '
    f"{bounds} "
    "-m src/dual/dual_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)


# 1.4 joint avec les bornes par défaut et avec la règle en version statique et dynamique v2 bornant les domaines des sommets en fonction de leurs degrés (SR2 + DR2_v2)
command_joint = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "MWSSP_WVCP_SEARCH_STRATEGY=WVCP" '
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
    '-D "WVCP_M={M_SR2,M_DR2_v2}" '
    f"{bounds} "
    "-m src/joint/joint_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)

# 1.5 joint avec les bornes par défaut et avec la règle en version statique bornant les domaines des sommets en fonction de leurs degrés (SR2)
command_joint_v2 = Template(
    "minizinc --solver or-tools --time-limit ${runtime} --parallel 0 --compiler-statistics "
    "--solver-statistics --intermediate --output-mode json --json-stream "
    '-D "MWSSP_WVCP_SEARCH_STRATEGY=WVCP" '
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
    '-D "WVCP_M={M_SR2}" '
    f"{bounds} "
    "-m src/joint/joint_solve.mzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)


instance_types = ["original", "reduced"]


with open("to_solve", "w", encoding="UTF8") as file:
    for instance_type in instance_types:
        for instance in instances:
            # file.write(
            #     command_primal_v1.substitute(
            #         instance_type=instance_type,
            #         instance=instance,
            #         output_dir=output_directory,
            #         runtime=time_limit,
            #         repertory=rep_primal_1,
            #     )
            # )
            # file.write(
            #     command_primal_v2.substitute(
            #         instance_type=instance_type,
            #         instance=instance,
            #         output_dir=output_directory,
            #         runtime=time_limit,
            #         repertory=rep_primal_2,
            #     )
            # )
            # file.write(
            #     command_dual_ortools.substitute(
            #         instance_type=instance_type,
            #         instance=instance,
            #         output_dir=output_directory,
            #         runtime=time_limit,
            #         repertory=rep_dual_ortools,
            #     )
            # )
            # file.write(
            #     command_dual_coin_bc.substitute(
            #         instance_type=instance_type,
            #         instance=instance,
            #         output_dir=output_directory,
            #         runtime=time_limit,
            #         repertory=rep_dual_coin_bc,
            #     )
            # )

            # file.write(
            #     command_joint.substitute(
            #         instance_type=instance_type,
            #         instance=instance,
            #         output_dir=output_directory,
            #         runtime=time_limit,
            #         repertory=rep_joint,
            #     )
            # )

            file.write(
                command_joint_v2.substitute(
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    runtime=time_limit,
                    repertory=rep_joint_v2,
                )
            )
