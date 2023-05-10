import statistics

instances_names: list[str] = []
with open("instances/instance_list_wvcp.txt", "r", encoding="utf8") as file:
    instances_names = file.read().splitlines()

rep = "instances/original_graph"
rep = "instances/reduced_wvcp"

print("instance,|V|,min,max,median,mean,stdev,|W|,|W|/|V|")


for instance in instances_names:
    file = f"{rep}/{instance}.col.w"
    with open(file) as f:
        weights = [int(w) for w in f.readlines()]
    size = len(weights)
    max_w = max(weights)
    min_w = min(weights)
    mean_w = round(statistics.mean(weights), 1)
    stdev_w = round(statistics.stdev(weights), 1)
    median_w = round(statistics.median(weights), 1)
    nb_weights = len(set(weights))
    ratio_nb_weights_size = round(nb_weights / size, 2)
    print(
        instance,
        size,
        min_w,
        max_w,
        median_w,
        mean_w,
        stdev_w,
        nb_weights,
        ratio_nb_weights_size,
        sep=",",
    )
