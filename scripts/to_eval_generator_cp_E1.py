"""
Generate to_eval file which list all run to perform for CP

"""
# pylint: disable=invalid-name

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
output_directory = f"/scratch/LERIA/grelier_c/cp_1h_E1_{instances_set[1]}"

rep_primal_static_h1 = "E1_primal_static_h1"
rep_primal_static_h2 = "E1_primal_static_h2"
rep_primal_dynamic_h1 = "E1_primal_dynamic_h1"
rep_primal_dynamic_h2 = "E1_primal_dynamic_h2"
rep_joint_static_h1 = "E1_joint_static_h1"
rep_joint_static_h2 = "E1_joint_static_h2"
rep_joint_dynamic_h1 = "E1_joint_dynamic_h1"
rep_joint_dynamic_h2 = "E1_joint_dynamic_h2"
rep_dual_ortools = "E1_dual_ortools"
# rep_dual_coin_bc = "E1_dual_coin_bc"
# rep_dual_cplex = "E1_dual_cplex"

os.mkdir(f"{output_directory}")
os.mkdir(f"{output_directory}/{rep_primal_static_h1}")
os.mkdir(f"{output_directory}/{rep_primal_static_h2}")
os.mkdir(f"{output_directory}/{rep_primal_dynamic_h1}")
os.mkdir(f"{output_directory}/{rep_primal_dynamic_h2}")
os.mkdir(f"{output_directory}/{rep_joint_static_h1}")
os.mkdir(f"{output_directory}/{rep_joint_static_h2}")
os.mkdir(f"{output_directory}/{rep_joint_dynamic_h1}")
os.mkdir(f"{output_directory}/{rep_joint_dynamic_h2}")
os.mkdir(f"{output_directory}/{rep_dual_ortools}")
# os.mkdir(f"{output_directory}/{rep_dual_coin_bc}")
# os.mkdir(f"{output_directory}/{rep_dual_cplex}")

time_limit_s = 3600 * 1
time_limit_ms = time_limit_s * 1000
parallel = 0


primal_h1 = (
    '-D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" '
    '-D "WVCP_SEARCH_RESTART=RESTART_NONE" '
    '-D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" '
    '-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" '
)

primal_h2 = (
    '-D "WVCP_SEARCH_STRATEGY=VERTICES_SPECIFIC" '
    '-D "WVCP_SEARCH_RESTART=RESTART_NONE" '
    '-D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" '
    '-D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "WVCP_SEARCH_VARIABLES_VERTICES=DESC_WEIGHT_DEGREE" '
    '-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" '
)

dual_h1 = (
    '-D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" '
    '-D "MWSSP_SEARCH_RESTART=RESTART_NONE" '
    '-D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" '
    '-D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" '
)

joint_h1 = '-D "MWSSP_WVCP_SEARCH_STRATEGY=WVCP" ' + primal_h1 + dual_h1

joint_h2 = '-D "MWSSP_WVCP_SEARCH_STRATEGY=WVCP" ' + primal_h2 + dual_h1

propagation_none = '-D "WVCP_M={}" '
propagation_static = '-D "WVCP_M={M_SR2}" '
propagation_dynamic = '-D "WVCP_M={M_SR2, M_DR2_v2}" '

model_primal = "-m src/primal/primal_solve.mzn "
model_dual = "-m src/dual/dual_solve.mzn "
model_joint = "-m src/joint/joint_solve.mzn "


solver_ortools = (
    "minizinc --solver or-tools --compiler-statistics --solver-statistics "
    "--intermediate --output-mode json --json-stream "
)


command_minizinc = Template(
    "${solver} --time-limit ${runtime} --parallel ${parallel} "
    "${heuristic} "
    "${static_dynamic} "
    "-d ${instance_type}_wvcp_dzn/${instance}.lb_colors_${lb_colors}.dzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.ub_colors_${ub_colors}.dzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.lb_score_${lb_score}.dzn "
    "-d ${instance_type}_wvcp_dzn/${instance}.ub_score_${ub_score}.dzn "
    "-d src/core/no_cliques.dzn "
    "${model} "
    "-d ${instance_type}_wvcp_dzn/${instance}.dzn "
    "> ${output_dir}/${repertory}/${instance_type}_${instance}.json\n"
)

# command_cplex_original = Template(
#     "./MWSS_cplex/cplex -T${runtime} -n${parallel} "
#     "instances/original_graphs/${instance}.col "
#     "instances/original_graphs/${instance}.col.w "
#     "> ${output_dir}/${repertory}/original_${instance}.cplex\n"
# )

# command_cplex_reduced = Template(
#     "./MWSS_cplex/cplex -T${runtime} -n${parallel} "
#     "instances/reduced_wvcp/${instance}.col "
#     "instances/reduced_wvcp/${instance}.col.w "
#     "> ${output_dir}/${repertory}/reduced_${instance}.cplex\n"
# )

instance_types = ["original", "reduced"]


with open("to_solve", "w", encoding="UTF8") as file:
    for instance in instances:
        for instance_type in instance_types:
            # primal static h1
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_primal,
                    heuristic=primal_h1,
                    static_dynamic=propagation_static,
                    repertory=rep_primal_static_h1,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # primal static h2
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_primal,
                    heuristic=primal_h2,
                    static_dynamic=propagation_static,
                    repertory=rep_primal_static_h2,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # primal dynamic h1
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_primal,
                    heuristic=primal_h1,
                    static_dynamic=propagation_dynamic,
                    repertory=rep_primal_dynamic_h1,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # primal dynamic h2
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_primal,
                    heuristic=primal_h2,
                    static_dynamic=propagation_dynamic,
                    repertory=rep_primal_dynamic_h2,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # joint static h1
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_joint,
                    heuristic=joint_h1,
                    static_dynamic=propagation_static,
                    repertory=rep_joint_static_h1,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # joint static h2
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_joint,
                    heuristic=joint_h2,
                    static_dynamic=propagation_static,
                    repertory=rep_joint_static_h2,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # joint dynamic h1
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_joint,
                    heuristic=joint_h1,
                    static_dynamic=propagation_dynamic,
                    repertory=rep_joint_dynamic_h1,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # joint dynamic h2
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_joint,
                    heuristic=joint_h2,
                    static_dynamic=propagation_dynamic,
                    repertory=rep_joint_dynamic_h2,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # dual ortools
            file.write(
                command_minizinc.substitute(
                    solver=solver_ortools,
                    runtime=time_limit_ms,
                    parallel=parallel,
                    instance_type=instance_type,
                    instance=instance,
                    output_dir=output_directory,
                    model=model_dual,
                    heuristic=dual_h1,
                    static_dynamic=propagation_none,
                    repertory=rep_dual_ortools,
                    # "default" "max_size_clique"
                    lb_colors="default",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="max_degree",
                    # "default" "sum_cliques"
                    lb_score="default",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="default",
                )
            )
            # # dual coin-bc
            # file.write(
            #     command_minizinc.substitute(
            #         solver=solver_coin_bc,
            #         runtime=time_limit_ms,
            #         parallel=parallel,
            #         instance_type=instance_type,
            #         instance=instance,
            #         output_dir=output_directory,
            #         bounds=bounds_basic,
            #         model=model_dual,
            #         heuristic=dual_h1,
            #         static_dynamic=propagation_none,
            #         repertory=rep_dual_coin_bc,
            #     )
            # )
            # # dual cplex original
            # if instance_type == "original":
            #     file.write(
            #         command_cplex_original.substitute(
            #             parallel=parallel,
            #             runtime=time_limit_s,
            #             instance=instance,
            #             output_dir=output_directory,
            #             repertory=rep_dual_cplex,
            #         )
            #     )
            # # dual cplex reduced
            # if instance_type == "reduced":
            #     file.write(
            #         command_cplex_reduced.substitute(
            #             parallel=parallel,
            #             runtime=time_limit_s,
            #             instance=instance,
            #             output_dir=output_directory,
            #             repertory=rep_dual_cplex,
            #         )
            #     )
