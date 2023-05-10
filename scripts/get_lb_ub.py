instances_names: list[str] = []

with open("instances/instance_list_wvcp.txt", "r", encoding="utf8") as file:
    instances_names = file.read().splitlines()

bounds = [
    "lb_colors_default",
    "lb_colors_max_size_clique",
    "ub_colors_default",
    "ub_colors_max_degree",
    "ub_colors_min_degree_chromatic",
    "ub_colors_sum_chromatic",
    "lb_score_default",
    "lb_score_sum_cliques",
    "ub_score_bks",
    "ub_score_default",
    "ub_score_sum_weights_chromatic",
]

print("instance," + ",".join(bounds), sep="")
rep = "original_wvcp_dzn"
rep = "reduced_wvcp_dzn"


for instance in instances_names:
    csv_line = instance
    for bound in bounds:
        file = f"{rep}/{instance}.{bound}.dzn"
        with open(file) as f:
            line = f.readline()
            val = line.split("=")[1][:-1]
            # print(file, val)
            csv_line += "," + str(val)
    print(csv_line)
