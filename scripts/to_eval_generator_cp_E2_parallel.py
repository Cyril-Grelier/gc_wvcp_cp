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
instances_set = ("instance_list_wvcp", "test")

# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

output_directory = f"outputs/cp_1h_E2_{instances_set[1]}"
output_directory = f"/scratch/LERIA/grelier_c/cp_1h_E2_parallel_{instances_set[1]}"

rep_primal_static_h1_both = "E2_primal_static_h1_both_bounds_parallel"
rep_joint_static_h1_both = "E2_joint_static_h1_both_bounds_parallel"
rep_primal_static_h1_both_bks = "E2_primal_static_h1_both_bounds_bks_parallel"
rep_joint_static_h1_both_bks = "E2_joint_static_h1_both_bounds_bks_parallel"
rep_dual_ortools = "E2_dual_ortools_parallel"

os.mkdir(f"{output_directory}")
os.mkdir(f"{output_directory}/{rep_primal_static_h1_both}")
os.mkdir(f"{output_directory}/{rep_joint_static_h1_both}")
os.mkdir(f"{output_directory}/{rep_primal_static_h1_both_bks}")
os.mkdir(f"{output_directory}/{rep_joint_static_h1_both_bks}")
os.mkdir(f"{output_directory}/{rep_dual_ortools}")

time_limit_s = 3600 * 1
time_limit_ms = time_limit_s * 1000
parallel = 8


primal_h1 = (
    '-D "PRIMAL_STRATEGY=VERTICES_GENERIC" '
    '-D "PRIMAL_RESTART=RESTART_NONE" '
    '-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" '
    '-D "PRIMALH_VAL_COLORS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" '
    '-D "PRIMALH_VAL_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_VERTICES=WVCPSV(FIRST_FAIL)" '
    '-D "PRIMALH_VAL_VERTICES=INDOMAIN_SPLIT" '
)

dual_h1 = (
    '-D "DUAL_STRATEGY=ARCS_SPECIFIC" '
    '-D "DUAL_RESTART=RESTART_NONE" '
    '-D "DUAL_H_VAR_ARCS=DESC_WEIGHT_TAIL" '
    '-D "DUALH_VAL_ARCS=INDOMAIN_MAX" '
)

joint_h1 = '-D "JOINT_STRATEGY=PRIMAL" ' + primal_h1 + dual_h1

propagation_none = '-D "WVCP_M={}" '
propagation_static = '-D "WVCP_M={M_DG}" '

model_primal = "-m src/primal/primal_solve.mzn "
model_joint = "-m src/joint/joint_solve.mzn "
model_dual = "-m src/dual/dual_solve.mzn "


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


instance_types = ["reduced"]

with open("to_solve", "w", encoding="UTF8") as file:
    for instance in instances:
        for instance_type in instance_types:
            # primal static h1 both
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
                    repertory=rep_primal_static_h1_both,
                    # "default" "max_size_clique"
                    lb_colors="max_size_clique",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="min_degree_chromatic",
                    # "default" "sum_cliques"
                    lb_score="sum_cliques",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="sum_weights_chromatic",
                )
            )

            # joint static h1 both
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
                    repertory=rep_joint_static_h1_both,
                    # "default" "max_size_clique"
                    lb_colors="max_size_clique",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="min_degree_chromatic",
                    # "default" "sum_cliques"
                    lb_score="sum_cliques",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="sum_weights_chromatic",
                )
            )

            # primal static h1 both bks
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
                    repertory=rep_primal_static_h1_both_bks,
                    # "default" "max_size_clique"
                    lb_colors="max_size_clique",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="min_degree_chromatic",
                    # "default" "sum_cliques"
                    lb_score="sum_cliques",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="bks",
                )
            )

            # joint static h1 both bks
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
                    repertory=rep_joint_static_h1_both_bks,
                    # "default" "max_size_clique"
                    lb_colors="max_size_clique",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="min_degree_chromatic",
                    # "default" "sum_cliques"
                    lb_score="sum_cliques",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="bks",
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
                    lb_colors="max_size_clique",
                    # "default" "max_degree" "min_degree_chromatic" "sum_chromatic"
                    ub_colors="min_degree_chromatic",
                    # "default" "sum_cliques"
                    lb_score="sum_cliques",
                    # "default" "bks" "sum_weights_chromatic"
                    ub_score="sum_weights_chromatic",
                )
            )
