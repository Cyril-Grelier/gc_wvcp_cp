import statistics

import pandas as pd

instances_names: list[str] = []
with open("instances/instance_list_wvcp.txt", "r", encoding="utf8") as file:
    instances_names = file.read().splitlines()

rep = "instances/original_graphs"
# rep = "instances/reduced_wvcp"

# print("instance,|V|,min,max,median,mean,stdev,|W|,|W|/|V|")


# df = pd.read_csv("instances/instance_info_wvcp.csv", index_col=0).query(
#     "reduced == False"
# )[["|V|", "|E|", "density"]]

df = pd.read_csv("instances/instance_info_gcp.csv", index_col=0).query(
    "reduced == False"
)[["|V|", "|E|", "density"]]

# df = pd.merge(
#     df,
#     df2,
#     on=["instance", "|V|", "|E|", "density"],
# )
# print(df)

# [["instance", "|V|", "|E|", "density"]]
df["w_{min}"] = ""
df["w_{mean}"] = ""
df["w_{max}"] = ""
df["|W|"] = ""
df["|W|/|V|"] = ""
df["BKS WVCP"] = ""
df["optimal WVCP"] = ""
df["BKS GCP"] = ""
df["optimal GCP"] = ""


print(df.columns)
df = df[
    [
        "|V|",
        "|E|",
        "density",
        "w_{max}",
        "w_{mean}",
        "w_{min}",
        "|W|",
        "|W|/|V|",
        "BKS WVCP",
        "optimal WVCP",
        "BKS GCP",
        "optimal GCP",
    ]
]


with open("instances/best_scores_wvcp.txt", encoding="utf8") as file:
    for line in file.readlines():
        instance, score, optim = line.split(" ")
        df.loc[instance, "BKS WVCP"] = score
        df.loc[instance, "optimal WVCP"] = 1 if optim == "*\n" else 0

with open("instances/best_scores_gcp.txt", encoding="utf8") as file:
    for line in file.readlines():
        instance, score, optim = line.split(" ")
        df.loc[instance, "BKS GCP"] = score
        df.loc[instance, "optimal GCP"] = 1 if optim == "*\n" else 0

for instance in instances_names:
    file = f"{rep}/{instance}.col.w"
    with open(file, encoding="utf8") as f:
        weights = [int(w) for w in f.readlines()]
    size = len(weights)
    max_w = max(weights)
    min_w = min(weights)
    mean_w = round(statistics.mean(weights), 1)
    stdev_w = round(statistics.stdev(weights), 1)
    median_w = round(statistics.median(weights), 1)
    nb_weights = len(set(weights))
    ratio_nb_weights_size = round(nb_weights / size, 2)
    # print(
    #     instance,
    #     size,
    #     min_w,
    #     max_w,
    #     median_w,
    #     mean_w,
    #     stdev_w,
    #     nb_weights,
    #     ratio_nb_weights_size,
    #     sep=",",
    # )
    df.loc[instance, "w_{min}"] = min_w
    df.loc[instance, "w_{mean}"] = mean_w
    df.loc[instance, "w_{max}"] = max_w
    df.loc[instance, "|W|"] = nb_weights
    df.loc[instance, "|W|/|V|"] = ratio_nb_weights_size

print(df)
df.to_csv("instances_info_wvcp.csv")
