
import subprocess
import os
# Load graph
from os import walk
import time

type_instance = "original_graphs"


filepath = "../instances/" + type_instance + "/"

f = []
for (dirpath, dirnames, filenames) in walk(filepath):

    f = filenames
    break;


filenames.sort()


fresult = open("color_bounds_" + type_instance, "a")


already_done = []


# "flat1000_50_0.col",
# "flat1000_60_0.col",
# "flat1000_76_0.col",
# "latin_square_10.col"


for instance in filenames:

    print(instance)

    if(instance not in already_done):

        if os.path.exists(filepath + instance + ".w"):

            list_edges = []

            with open(filepath + instance , "r", encoding="utf8") as f:
                for line in f:
                    x = line.split(sep=" ")
                    if x[0] == "p":
                        size = int(x[2])
                        break
                for line in f:
                    x = line.split(sep=" ")
                    if x[0] == "e":
                        list_edges.append([int(x[1]), int(x[2])])


            # print(list_edges)



            list_weights = []

            with open(filepath + instance  + ".w", "r", encoding="utf8") as f:
                for line in f:
                    x = line.split(sep=" ")

                    list_weights.append(int(x[0]))

            # print(list_weights)

            set_weights = list(set(list_weights))

            set_weights.sort()

            # print("print(set_weights)")
            # print(set_weights)



            if not os.path.exists("subgraphs_kcoloring_results_" + type_instance + "/" + instance):
                os.mkdir("subgraphs_kcoloring_results_" + type_instance + "/" + instance)

            list_empty_subgraph = []

            for w in set_weights:

                # print("weight : " + str(w))

                list_nodes_weight = []

                for i in range(len(list_weights)):

                    if(list_weights[i] == w):

                        list_nodes_weight.append(i+1)

                # print(list_nodes_weight)



                list_edges_weight = []

                for edge in list_edges:

                    if(edge[0] in list_nodes_weight and edge[1] in list_nodes_weight):

                        list_edges_weight.append(edge)

                # print(list_edges_weight)


                #Permet de gérer le cas où certains noeud sont reliés à aucun autre... On les dégage dans ce cas là.
                list_nodes_weight_bis = []

                for node in list_nodes_weight:

                    trouve = False

                    for edge in list_edges_weight:

                        if(edge[0] == node or edge[1] == node):

                            trouve = True

                    if(trouve):
                        list_nodes_weight_bis.append(node)


                #On réordonne les numéro des arcs avec des numéro de noeud qui commence à 1
                list_edges_weight_bis = []

                for edge in list_edges_weight:
                    for idx, node in enumerate(list_nodes_weight_bis):
                        if(edge[0] == node):
                            tail = idx + 1
                        if (edge[1] == node):
                            head = idx + 1

                    list_edges_weight_bis.append((tail,head))


                # print(list_edges_weight_bis)



                name_subgraph = "subgraphs_kcoloring_results_" + type_instance + "/" + instance + "/" + instance + "w" + str(w)

                f = open(name_subgraph, "w")
                f.write("p edge " + str(len(list_nodes_weight_bis)) + " " + str(len(list_edges_weight_bis)) + "\n")

                for edge in list_edges_weight_bis:
                    f.write("e " + str(edge[0]) + " " + str(edge[1]) + "\n")



                f.close()



            for w in set_weights:

                name_subgraph = "subgraphs_kcoloring_results_" + type_instance + "/" + instance + "/" + instance + "w" + str(w)

                while( not os.path.exists(name_subgraph + "results.txt")):

                    print("START " + name_subgraph)
                    subprocess.run(["HEAD/head", name_subgraph, "1000", "-s 10", "-r -1", "-i 8000",
                                    "-o" + name_subgraph + "results.txt"])




            colorBound = 0


            for w in set_weights:

                nameOutput =  "subgraphs_kcoloring_results_" + type_instance + "/" + instance + "/" + instance + "w" + str(w) + "results.txt"

                with open(nameOutput, "r", encoding="utf8") as f:
                    for line in f:

                        colorBound += int(line)

            print(colorBound)

            fresult.write(instance + "," + str(colorBound) + "\n")


fresult.close()



