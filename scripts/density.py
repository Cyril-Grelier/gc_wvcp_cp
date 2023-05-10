from glob import glob

import igraph

# instance_file = f"instances/wvcp_reduced/{instance_name}.edgelist"

instances_set = ("instance_list_wvcp", "all")
instances_set = ("instance_list_gcp", "all")
# i,instance
with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
    instances = [line[:-1] for line in file.readlines()]

print("instance,|V|,|E|,density")

for instance in instances:
    instance_file = f"instances/reduced_wvcp/{instance}.edgelist"
    instance_file = f"instances/original_graphs/{instance}.edgelist"
    instance_file = f"instances/original_graphs/{instance}.edgelist"
    instance_file = f"instances/reduced_gcp/{instance}.edgelist"
    graph_g = igraph.Graph.Read_Edgelist(instance_file, directed=False)
    print(
        f"{instance},{graph_g.vcount()},{graph_g.ecount()},{round(graph_g.density(),3)}"
    )
