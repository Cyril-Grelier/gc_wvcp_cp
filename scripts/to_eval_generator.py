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
instances_set = ("instance_list_wvcp", "all")
instances_set = ("../instances_try_hard", "try_hard")

# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

output_directory = f"outputs/cp_1h_{instances_set[1]}"

# 1h run, 8Go RAM, 1 CPU
# E0 original vs reduced
rep_primal_h1_none_no_bounds_original = "primal_h1_none_no_bounds_original"
rep_dual_h1_none_no_bounds_original = "dual_h1_none_no_bounds_original"
rep_joint_h1_none_no_bounds_original = "joint_h1_none_no_bounds_original"
# E1 color/score bounds
rep_primal_h1_none_no_bounds = "primal_h1_none_no_bounds"
rep_primal_h1_none_lb_color = "primal_h1_none_lb_color"
rep_primal_h1_none_ub_color = "primal_h1_none_ub_color"
rep_primal_h1_none_lb_score = "primal_h1_none_lb_score"
rep_primal_h1_none_ub_score = "primal_h1_none_ub_score"
rep_primal_h1_none_all_bounds = "primal_h1_none_all_bounds"
rep_dual_h1_none_no_bounds = "dual_h1_none_no_bounds"
rep_dual_h1_none_lb_color = "dual_h1_none_lb_color"
rep_dual_h1_none_ub_color = "dual_h1_none_ub_color"
rep_dual_h1_none_lb_score = "dual_h1_none_lb_score"
rep_dual_h1_none_ub_score = "dual_h1_none_ub_score"
rep_dual_h1_none_all_bounds = "dual_h1_none_all_bounds"
rep_joint_h1_none_no_bounds = "joint_h1_none_no_bounds"
rep_joint_h1_none_lb_color = "joint_h1_none_lb_color"
rep_joint_h1_none_ub_color = "joint_h1_none_ub_color"
rep_joint_h1_none_lb_score = "joint_h1_none_lb_score"
rep_joint_h1_none_ub_score = "joint_h1_none_ub_score"
rep_joint_h1_none_all_bounds = "joint_h1_none_all_bounds"
# E2 none/static/dynamic
rep_primal_h1_DG_MLS_no_bounds = "primal_h1_DG_MLS_no_bounds"
rep_joint_h1_DG_LS_MLS_no_bounds = "joint_h1_DG_LS_MLS_no_bounds"
# E3 none/static/dynamic + bounds
rep_primal_h1_DG_MLS_all_bounds = "primal_h1_DG_MLS_all_bounds"
rep_joint_h1_DG_LS_MLS_all_bounds = "joint_h1_DG_LS_MLS_all_bounds"

# 1h run, 8Go RAM, 10 CPU
# E4 parallelism
rep_primal_h1_DG_MLS_all_bounds_parallel = "primal_h1_DG_MLS_all_bounds_parallel"
rep_dual_h1_none_all_bounds_parallel = "dual_h1_none_all_bounds_parallel"
rep_joint_h1_DG_LS_MLS_all_bounds_parallel = (
    "joint_h1_DG_LS_MLS_all_bounds_parallel"
)

os.mkdir(f"{output_directory}")
os.mkdir(f"{output_directory}/{rep_primal_h1_none_no_bounds_original}")
os.mkdir(f"{output_directory}/{rep_dual_h1_none_no_bounds_original}")
os.mkdir(f"{output_directory}/{rep_joint_h1_none_no_bounds_original}")
os.mkdir(f"{output_directory}/{rep_primal_h1_none_no_bounds}")
os.mkdir(f"{output_directory}/{rep_primal_h1_none_lb_color}")
os.mkdir(f"{output_directory}/{rep_primal_h1_none_ub_color}")
os.mkdir(f"{output_directory}/{rep_primal_h1_none_lb_score}")
os.mkdir(f"{output_directory}/{rep_primal_h1_none_ub_score}")
os.mkdir(f"{output_directory}/{rep_primal_h1_none_all_bounds}")
os.mkdir(f"{output_directory}/{rep_dual_h1_none_no_bounds}")
os.mkdir(f"{output_directory}/{rep_dual_h1_none_lb_color}")
os.mkdir(f"{output_directory}/{rep_dual_h1_none_ub_color}")
os.mkdir(f"{output_directory}/{rep_dual_h1_none_lb_score}")
os.mkdir(f"{output_directory}/{rep_dual_h1_none_ub_score}")
os.mkdir(f"{output_directory}/{rep_dual_h1_none_all_bounds}")
os.mkdir(f"{output_directory}/{rep_joint_h1_none_no_bounds}")
os.mkdir(f"{output_directory}/{rep_joint_h1_none_lb_color}")
os.mkdir(f"{output_directory}/{rep_joint_h1_none_ub_color}")
os.mkdir(f"{output_directory}/{rep_joint_h1_none_lb_score}")
os.mkdir(f"{output_directory}/{rep_joint_h1_none_ub_score}")
os.mkdir(f"{output_directory}/{rep_joint_h1_none_all_bounds}")
os.mkdir(f"{output_directory}/{rep_primal_h1_DG_MLS_no_bounds}")
os.mkdir(f"{output_directory}/{rep_joint_h1_DG_LS_MLS_no_bounds}")
os.mkdir(f"{output_directory}/{rep_primal_h1_DG_MLS_all_bounds}")
os.mkdir(f"{output_directory}/{rep_joint_h1_DG_LS_MLS_all_bounds}")
os.mkdir(f"{output_directory}/{rep_primal_h1_DG_MLS_all_bounds_parallel}")
os.mkdir(f"{output_directory}/{rep_dual_h1_none_all_bounds_parallel}")
os.mkdir(f"{output_directory}/{rep_joint_h1_DG_LS_MLS_all_bounds_parallel}")


time_limit_s = 3600 * 1
time_limit_ms = time_limit_s * 1000
parallel = 0


primal_h1 = (
    '-D "PRIMAL_STRATEGY=VERTICES_GENERIC" '
    '-D "PRIMAL_RESTART=RESTART_NONE" '
    '-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_COLORS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_VERTICES=WVCPSV(FIRST_FAIL)" '
    '-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" '
)

primal_h2 = (
    '-D "PRIMAL_STRATEGY=VERTICES_SPECIFIC" '
    '-D "PRIMAL_RESTART=RESTART_NONE" '
    '-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_COLORS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_VERTICES=DESC_WEIGHT_DEGREE" '
    '-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" '
)

primal_h3 = (
    '-D "PRIMAL_STRATEGY=VERTICES_BY_WEIGHT" '
    '-D "PRIMAL_RESTART=RESTART_NONE" '
    '-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_COLORS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" '
    '-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" '
    '-D "PRIMAL_H_VAR_VERTICES=WVCPSV(FIRST_FAIL)" '
    '-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" '
)

dual_h1 = (
    '-D "DUAL_STRATEGY=ARCS_SPECIFIC" '
    '-D "DUAL_RESTART=RESTART_NONE" '
    '-D "DUAL_H_VAR_ARCS=DESC_WEIGHT_TAIL" '
    '-D "DUAL_H_VAL_ARCS=INDOMAIN_MAX" '
)

joint_h1 = '-D "JOINT_STRATEGY=PRIMAL" ' + primal_h1 + dual_h1

joint_h2 = '-D "JOINT_STRATEGY=PRIMAL" ' + primal_h2 + dual_h1

joint_h3 = '-D "JOINT_STRATEGY=PRIMAL" ' + primal_h3 + dual_h1

propagation_none = '-D "WVCP_M={}" '
# propagation_static = '-D "WVCP_M={M_DG}" '
propagation_dynamic_primal = '-D "WVCP_M={M_DG, M_LS}" '
# propagation_dynamic2 = '-D "WVCP_M={M_DG, M_MLS}" '
propagation_dynamic_joint = '-D "WVCP_M={M_DG, M_LS, M_MLS}" '

model_primal = "-m src/primal/primal_solve.mzn "
model_dual = "-m src/dual/dual_solve.mzn "
model_joint = "-m src/joint/joint_solve.mzn "


solver_ortools = (
    "minizinc --solver or-tools --compiler-statistics --solver-statistics "
    "--intermediate --output-mode json --json-stream "
)

# solver_gecode = (
#     "minizinc --solver gecode --compiler-statistics --solver-statistics "
#     "--intermediate --output-mode json --json-stream "
# )

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
    "> ${output_dir}/${repertory}/${instance}.json\n"
)

original = "original"
reduced = "reduced"


default = "default"
colors_lb = "max_size_clique"
colors_ub = "min_degree_chromatic"
score_lb = "sum_cliques"
score_ub = "sum_weights_chromatic"
score_bks = "bks"


with open("to_solve", "w", encoding="UTF8") as file:
    for instance in instances:
        # E0 original vs reduced
        # rep_primal_h1_none_no_bounds_original
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=original,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_none,
                repertory=rep_primal_h1_none_no_bounds_original,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_dual_h1_none_no_bounds_original
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=original,
                instance=instance,
                output_dir=output_directory,
                model=model_dual,
                heuristic=dual_h1,
                static_dynamic=propagation_none,
                repertory=rep_dual_h1_none_no_bounds_original,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_joint_h1_none_no_bounds_original
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=original,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_none,
                repertory=rep_joint_h1_none_no_bounds_original,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # E1 color/score bounds
        # rep_primal_h1_none_no_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_none,
                repertory=rep_primal_h1_none_no_bounds,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_primal_h1_none_lb_color
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_none,
                repertory=rep_primal_h1_none_lb_color,
                lb_colors=colors_lb,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_primal_h1_none_ub_color
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_none,
                repertory=rep_primal_h1_none_ub_color,
                lb_colors=default,
                ub_colors=colors_ub,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_primal_h1_none_lb_score
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_none,
                repertory=rep_primal_h1_none_lb_score,
                lb_colors=default,
                ub_colors=default,
                lb_score=score_lb,
                ub_score=default,
            )
        )
        # rep_primal_h1_none_ub_score
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_none,
                repertory=rep_primal_h1_none_ub_score,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=score_ub,
            )
        )
        # rep_primal_h1_none_all_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_none,
                repertory=rep_primal_h1_none_all_bounds,
                lb_colors=colors_lb,
                ub_colors=colors_ub,
                lb_score=score_lb,
                ub_score=score_ub,
            )
        )
        # rep_dual_h1_none_no_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_dual,
                heuristic=dual_h1,
                static_dynamic=propagation_none,
                repertory=rep_dual_h1_none_no_bounds,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_dual_h1_none_lb_color
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_dual,
                heuristic=dual_h1,
                static_dynamic=propagation_none,
                repertory=rep_dual_h1_none_lb_color,
                lb_colors=colors_lb,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_dual_h1_none_ub_color
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_dual,
                heuristic=dual_h1,
                static_dynamic=propagation_none,
                repertory=rep_dual_h1_none_ub_color,
                lb_colors=default,
                ub_colors=colors_ub,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_dual_h1_none_lb_score
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_dual,
                heuristic=dual_h1,
                static_dynamic=propagation_none,
                repertory=rep_dual_h1_none_lb_score,
                lb_colors=default,
                ub_colors=default,
                lb_score=score_lb,
                ub_score=default,
            )
        )
        # rep_dual_h1_none_ub_score
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_dual,
                heuristic=dual_h1,
                static_dynamic=propagation_none,
                repertory=rep_dual_h1_none_ub_score,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=score_ub,
            )
        )
        # rep_dual_h1_none_all_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_dual,
                heuristic=dual_h1,
                static_dynamic=propagation_none,
                repertory=rep_dual_h1_none_all_bounds,
                lb_colors=colors_lb,
                ub_colors=colors_ub,
                lb_score=score_lb,
                ub_score=score_ub,
            )
        )
        # rep_joint_h1_none_no_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_none,
                repertory=rep_joint_h1_none_no_bounds,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_joint_h1_none_lb_color
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_none,
                repertory=rep_joint_h1_none_lb_color,
                lb_colors=colors_lb,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_joint_h1_none_ub_color
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_none,
                repertory=rep_joint_h1_none_ub_color,
                lb_colors=default,
                ub_colors=colors_ub,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_joint_h1_none_lb_score
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_none,
                repertory=rep_joint_h1_none_lb_score,
                lb_colors=default,
                ub_colors=default,
                lb_score=score_lb,
                ub_score=default,
            )
        )
        # rep_joint_h1_none_ub_score
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_none,
                repertory=rep_joint_h1_none_ub_score,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=score_ub,
            )
        )
        # rep_joint_h1_none_all_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_none,
                repertory=rep_joint_h1_none_all_bounds,
                lb_colors=colors_lb,
                ub_colors=colors_ub,
                lb_score=score_lb,
                ub_score=score_ub,
            )
        )
        # E2 none/static/dynamic
        # rep_primal_h1_DG_MLS_no_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_dynamic_primal,
                repertory=rep_primal_h1_DG_MLS_no_bounds,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # rep_joint_h1_DG_LS_MLS_no_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_dynamic_joint,
                repertory=rep_joint_h1_DG_LS_MLS_no_bounds,
                lb_colors=default,
                ub_colors=default,
                lb_score=default,
                ub_score=default,
            )
        )
        # E3 none/static/dynamic + bounds
        # rep_primal_h1_DG_MLS_all_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_dynamic_primal,
                repertory=rep_primal_h1_DG_MLS_all_bounds,
                lb_colors=colors_lb,
                ub_colors=colors_ub,
                lb_score=score_lb,
                ub_score=score_ub,
            )
        )
        # rep_joint_h1_DG_LS_MLS_all_bounds
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_dynamic_joint,
                repertory=rep_joint_h1_DG_LS_MLS_all_bounds,
                lb_colors=colors_lb,
                ub_colors=colors_ub,
                lb_score=score_lb,
                ub_score=score_ub,
            )
        )

parallel = 10
# 1h run, 8Go RAM, 10 CPU
with open("to_solve_parallel", "w", encoding="UTF8") as file:
    for instance in instances:
        # E4 parallelism
        # rep_primal_h1_DG_MLS_all_bounds_parallel
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_primal,
                heuristic=primal_h1,
                static_dynamic=propagation_dynamic_primal,
                repertory=rep_primal_h1_DG_MLS_all_bounds_parallel,
                lb_colors=colors_lb,
                ub_colors=colors_ub,
                lb_score=score_lb,
                ub_score=score_ub,
            )
        )
        # rep_dual_h1_none_all_bounds_parallel
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_dual,
                heuristic=dual_h1,
                static_dynamic=propagation_none,
                repertory=rep_dual_h1_none_all_bounds_parallel,
                lb_colors=colors_lb,
                ub_colors=colors_ub,
                lb_score=score_lb,
                ub_score=score_ub,
            )
        )
        # rep_joint_h1_DG_LS_MLS_all_bounds_parallel
        file.write(
            command_minizinc.substitute(
                solver=solver_ortools,
                runtime=time_limit_ms,
                parallel=parallel,
                instance_type=reduced,
                instance=instance,
                output_dir=output_directory,
                model=model_joint,
                heuristic=joint_h1,
                static_dynamic=propagation_dynamic_joint,
                repertory=rep_joint_h1_DG_LS_MLS_all_bounds_parallel,
                lb_colors=colors_lb,
                ub_colors=colors_ub,
                lb_score=score_lb,
                ub_score=score_ub,
            )
        )
