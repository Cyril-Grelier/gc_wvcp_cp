import json
import os

methods = [
    "primal_ortools",
    "dual_ortools",
    "dual_coin_bc",
    "joint_ortools",
]
instance_types = [
    # "original",
    "reduced",
]

instances_set = ("instance_list_wvcp", "all")
instances_set = ("../instance_feasible", "feasible")


def get_best_known_score(instance: str, problem: str) -> tuple[int, bool]:
    """return best know score in the literature and if score optimal"""
    file: str = f"instances/best_scores_{problem}.txt"
    with open(file, "r", encoding="utf8") as f:
        for line in f.readlines():
            instance_, score, optimal = line[:-1].split(" ")
            if instance_ == instance:
                return int(score), optimal == "*"
    raise Exception(f"instance {instance} not found in {file}")


def get_density(instance: str, instance_type: str):
    f = f"density_{instance_type}.csv"
    with open(f, "r", encoding="utf8") as file:
        for line in file.readlines():
            instance_, nb_vertices, nb_edges, density = line[:-1].split(",")
            if instance_ != instance:
                continue
            return instance_, int(nb_vertices), int(nb_edges), float(density)
    print(f"instance {instance} not found in {f}")
    return -1


# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

directory = "outputs/cp_10hfeasible"


def read_file(file: str):
    stats = {}
    with open(file) as f:
        for line in f.readlines():
            l_json = json.loads(line)
            if l_json["type"] == "statistics":
                if "flatTime" in l_json["statistics"]:
                    stats["flatTime"] = round(l_json["statistics"]["flatTime"], 1)
                else:
                    # stats["objective"] = l_json["statistics"]["objective"]
                    # stats["objectiveBound"] = l_json["statistics"]["objectiveBound"]
                    # stats["boolVariables"] = l_json["statistics"]["boolVariables"]
                    # stats["failures"] = l_json["statistics"]["failures"]
                    # stats["propagations"] = l_json["statistics"]["propagations"]
                    stats["solveTime"] = round(l_json["statistics"]["solveTime"], 1)
            elif l_json["type"] == "solution":
                if "x_score" in l_json["output"]["json"]:
                    stats["score"] = l_json["output"]["json"]["x_score"]
                else:
                    stats["score"] = l_json["output"]["json"]["yx_score"]
            elif l_json["type"] == "status":
                stats["status"] = l_json["status"]
    if "status" not in stats:
        stats["status"] = "-"
    if stats["status"] == "OPTIMAL_SOLUTION":
        stats["status"] = "optim"
    return stats


def analysis_primal(stats):
    if "flatTime" not in stats:
        print(",,,", end=",")
        return
    elif "solveTime" not in stats:
        print(f"{stats['flatTime']},,,", end=",")
        return
    print(
        stats["flatTime"],
        stats["solveTime"],
        stats["status"],
        stats["score"] if "score" in stats else "-",
        # stats["objective"],
        # stats["objectiveBound"],
        # stats["boolVariables"],
        # stats["failures"],
        # stats["propagations"],
        sep=",",
        end=",",
    )


print(",,,,primal,,,,dual,,,,dual_coin_bc,,,,joint,,,,")
print(
    "instance,type,BKS,optim,flat_time,solve_time,optim,score,flat_time,solve_time,optim,score,flat_time,solve_time,optim,score"
)

for instance in instances:
    best_score, optimal = get_best_known_score(instance, "wvcp")
    for instance_type in instance_types:
        print(instance, instance_type, best_score, optimal, sep=",", end=",")
        for method in methods:
            try:
                m, s = method.split("_")
            except:
                m = "dual"
                s = "coin_bc"
            file = f"{directory}/{m}_{instance_type}_{instance}_{s}.json"
            stats = read_file(file)
            # print(results)
            # print(stats)
            analysis_primal(stats)
        print()


# print("instance,|V|,|E|,density,optimality")

# def analysis(results, stats):
#     if stats["no_results"] and "flatTime" not in stats:
#         return "no flattening"
#     elif stats["no_results"] and "flatTime" in stats:
#         return "no solution"
#     elif stats["objective"] == stats["objectiveBound"]:
#         return "optimal"
#     else:
#         return "not optimal"


# for instance in instances:
#     for instance_type in instance_types:
#         for method in methods:
#             instance_, nb_vertices, nb_edges, density = get_density(
#                 instance, instance_type
#             )
#             file = f"{directory}/primal_{instance_type}_{instance}.json"
#             stats = read_file(file)
#             # opti = analysis(results, stats)
#             # print(instance, nb_vertices, nb_edges, density, opti, sep=",")
#             print(instance, nb_vertices, nb_edges, density, opti, sep=",")
