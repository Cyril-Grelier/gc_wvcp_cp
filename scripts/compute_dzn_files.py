"""
Create all dzn files see README for more informations

The clique is computed with fast cliques, at least one clique per vertex

FastCliques from :
Cai, Shaowei, and Jinkun Lin.
Fast Solving Maximum Weight Clique Problem in Massive Graphs.
In Proceedings of the
Twenty-Fifth International Joint Conference on Artificial Intelligence, 568–74.
IJCAI’16. New York, New York, USA: AAAI Press, 2016.

"""
from __future__ import annotations
from dataclasses import dataclass, field
import subprocess
import os
import time

from joblib import Parallel, delayed


def main():
    """for each instance, compute the dzn files"""
    instances_file = "instances/instance_list_wvcp.txt"
    instances_file = "instance_feasible.txt"

    instances_names: list[str] = []
    with open(instances_file, "r", encoding="utf8") as file:
        instances_names = file.read().splitlines()

    Parallel(n_jobs=15)(
        delayed(conversion_dzn)(instance_name, i, len(instances_names))
        for i, instance_name in enumerate(instances_names + instances_names)
    )


def run_tabu(subgraph_file: str, subgraph_file_out: str):
    """perform tabucol on the subgraph"""
    subprocess.run(
        ["color_bounds/build/tabucol", subgraph_file, subgraph_file_out],
        check=True,
    )


def conversion_dzn(instance_name: str, i: int, nb_instances: int):
    """convert instance"""
    start = time.time()

    is_original = i >= nb_instances

    if is_original:
        print(instance_name, "original start")
        repertory: str = "original_wvcp_dzn"
        instance_file: str = f"instances/original_graphs/{instance_name}.col"
    else:
        print(instance_name, "reduced start")
        repertory: str = "reduced_wvcp_dzn"
        instance_file: str = f"instances/reduced_wvcp/{instance_name}.col"

    # load the graph
    graph: Graph = Graph(instance_file, instance_file + ".w", to_sort=is_original)

    if is_original:
        # convert the graph to dzn
        graph.save_graph_dzn_sort_vertices(f"{repertory}/{instance_name}.dzn")
    else:
        # convert the graph to dzn
        graph.save_graph_dzn(f"{repertory}/{instance_name}.dzn")

    # convert the cliques to dzn
    graph.save_cliques_dzn(f"{repertory}/{instance_name}.clq.dzn")
    # graph.save_cliques(f"{repertory}/{instance_name}.clq")

    # convert the colors bounds to dzn
    graph.compute_color_bounds(repertory)

    # bounds
    base = f"{repertory}/{instance_name}."

    # colors
    with open(f"{base}lb_colors_default.dzn", "w", encoding="utf8") as file:
        file.write(f"lb_colors={graph.lb_colors_default};")

    with open(f"{base}lb_colors_max_size_clique.dzn", "w", encoding="utf8") as file:
        file.write(f"lb_colors={graph.lb_colors_max_size_clique};")

    with open(f"{base}ub_colors_default.dzn", "w", encoding="utf8") as file:
        file.write(f"ub_colors={graph.ub_colors_default};")

    with open(f"{base}ub_colors_sum_chromatic.dzn", "w", encoding="utf8") as file:
        file.write(f"ub_colors={graph.ub_colors_sum_chromatic};")

    with open(f"{base}ub_colors_max_degree.dzn", "w", encoding="utf8") as file:
        file.write(f"ub_colors={graph.ub_colors_max_degree};")

    with open(
        f"{base}ub_colors_min_degree_chromatic.dzn", "w", encoding="utf8"
    ) as file:
        file.write(f"ub_colors={graph.ub_colors_min_degree_chromatic};")

    # score
    with open(f"{base}lb_score_default.dzn", "w", encoding="utf8") as file:
        file.write(f"lb_score={graph.lb_score_default};")

    with open(f"{base}lb_score_sum_cliques.dzn", "w", encoding="utf8") as file:
        file.write(f"lb_score={graph.lb_score_sum_cliques};")

    with open(f"{base}ub_score_default.dzn", "w", encoding="utf8") as file:
        file.write(f"ub_score={graph.ub_score_default};")

    with open(
        f"{base}ub_score_sum_weights_chromatic.dzn", "w", encoding="utf8"
    ) as file:
        file.write(f"ub_score={graph.ub_score_sum_weights_chromatic};")

    with open(f"{base}ub_score_bks.dzn", "w", encoding="utf8") as file:
        file.write(f"ub_score={graph.ub_score_bks};")

    if is_original:
        print(instance_name, f"original done ({int(time.time() - start)}s)")
    else:
        print(instance_name, f"reduced done ({int(time.time() - start)}s)")


def read_col_files(instance_file: str) -> tuple[int, list[tuple[int, int]]]:
    """Read .col (DIMACS) file"""
    edges_list: list[tuple[int, int]] = []
    with open(instance_file, "r", encoding="utf8") as file:
        for line_ in file:
            line = line_.strip()
            if line.startswith("c"):
                continue
            if line.startswith("p"):
                _, _, nb_vertices_str, _ = line.split()
                nb_vertices = int(nb_vertices_str)
            elif line.startswith("e"):
                _, vertex1_str, vertex2_str = line.split()
                vertex1_ = int(vertex1_str) - 1
                vertex2_ = int(vertex2_str) - 1
                if vertex1_ == vertex2_:
                    continue
                vertex1 = min(vertex1_, vertex2_)
                vertex2 = max(vertex1_, vertex2_)
                edges_list.append((vertex1, vertex2))
    return nb_vertices, edges_list


def read_weights_file(weights_file: str, nb_vertices: int) -> list[int]:
    """Read weights file and check the number of vertices"""
    if weights_file == "":
        return [1] * nb_vertices

    with open(weights_file, "r", encoding="utf8") as file:
        weights = list(map(int, file.readlines()))
    assert len(weights) == nb_vertices
    return weights


def get_best_known_score(instance: str):
    """read the best score file to find the best score"""
    file = "instances/best_scores_wvcp.txt"
    with open(file, "r", encoding="utf8") as file:
        for line in file.readlines():
            instance_, score, _ = line[:-1].split(" ")
            if instance_ != instance:
                continue
            return int(score)
    print(f"instance {instance} not found in instances/best_scores_wvcp.txt")


@dataclass
class Node:
    """Representation of a Node for graph"""

    old_number: int = -1
    new_number: int = -1
    weight: int = -1
    neighbors_int: list[int] = field(default_factory=list)
    neighbors_nodes: list[Node] = field(default_factory=list)


class Graph:
    """Representation of a graph"""

    def __init__(self, instance_file: str, weights_file: str, to_sort: bool) -> None:
        """Load graph from file

        Args:
            instance_file (str): file containing the instance (.col file)
            weights_file (str): file containing the weights of the instance (col.w file)
        """

        self.name: str
        self.nb_vertices: int
        self.nb_edges: int
        self.edges_list: list[tuple[int, int]]
        self.adjacency_matrix: list[list[bool]]
        self.neighborhood: list[list[int]]
        self.weights: list[int]
        self.cliques: list[list[int]]
        self.nodes_sorted: list[Node] = []
        # bounds colors
        self.lb_colors_default: int = 1
        self.lb_colors_max_size_clique: int = 0
        self.ub_colors_default: int = 0
        self.ub_colors_sum_chromatic: int = 0
        self.ub_colors_max_degree: int = 0
        self.ub_colors_min_degree_chromatic: int = 0
        # bounds score
        self.lb_score_default: int = 0
        self.lb_score_sum_cliques: int = 0
        self.ub_score_default: int = 0
        self.ub_score_sum_weights_chromatic: int = 0
        self.ub_score_bks: int = 0

        # load instance
        self.name = instance_file.split("/")[-1][:-4]
        self.nb_vertices, self.edges_list = read_col_files(instance_file)

        self.ub_colors_default = self.nb_vertices

        self.nb_edges = 0
        self.adjacency_matrix = [
            [False for _ in range(self.nb_vertices)] for _ in range(self.nb_vertices)
        ]
        self.neighborhood = [[] for _ in range(self.nb_vertices)]
        for vertex1, vertex2 in self.edges_list:
            if not self.adjacency_matrix[vertex1][vertex2]:
                self.nb_edges += 1
                self.adjacency_matrix[vertex1][vertex2] = True
                self.adjacency_matrix[vertex2][vertex1] = True
                self.neighborhood[vertex1].append(vertex2)
                self.neighborhood[vertex2].append(vertex1)

        # load weights
        self.weights = read_weights_file(weights_file, self.nb_vertices)

        if to_sort:
            self.init_sorted_nodes()
            # compute cliques
            self.cliques = [
                self.compute_clique_vertex_sorted(vertex)
                for vertex in range(self.nb_vertices)
            ]
        else:
            self.cliques = [
                self.compute_clique_vertex(vertex) for vertex in range(self.nb_vertices)
            ]

        self.set_of_weights = sorted(list(set(self.weights)))
        self.compute_score_bounds()

    def init_sorted_nodes(self):
        """sort the nodes"""
        # Create the nodes
        nodes: list[Node] = [
            Node(
                old_number=vertex,
                new_number=-1,
                weight=self.weights[vertex],
                neighbors_int=self.neighborhood[vertex][:],
                neighbors_nodes=[],
            )
            for vertex in range(self.nb_vertices)
        ]
        # Add the neighbors to the nodes
        for node in nodes:
            node.neighbors_nodes = [nodes[neighbor] for neighbor in node.neighbors_int]
        # Sort the nodes by weights and degree
        self.nodes_sorted = sorted(
            nodes,
            key=lambda n: (
                n.weight,
                len(n.neighbors_int),
                sum(ne.weight for ne in n.neighbors_nodes),
            ),
            reverse=True,
        )
        # Gives the new numbers to the nodes
        for i, node in enumerate(self.nodes_sorted):
            node.new_number = i

    def compute_clique_vertex(self, vertex) -> list[int]:
        """compute a clique for the vertex"""
        current_clique = [vertex]
        candidates = set(self.neighborhood[vertex])
        while candidates:
            # // choose next vertex than maximize
            # // b(v) = w(v) + (w(N(v) inter candidate) )/2
            best_vertex: int = -1
            best_benefit: float = -1
            for neighbor in candidates:
                commun_neighbors = candidates.intersection(self.neighborhood[neighbor])
                potential_weight = sum(self.weights[n] for n in commun_neighbors)
                benefit: float = self.weights[neighbor] + (potential_weight / 2)
                if benefit > best_benefit:
                    best_benefit = benefit
                    best_vertex = neighbor
            current_clique.append(best_vertex)
            candidates.remove(best_vertex)
            candidates = candidates.intersection(self.neighborhood[best_vertex])
        # if len(current_clique) < 3:
        #     return []

        current_clique.sort(
            key=lambda v: (
                self.weights[v],
                len(self.neighborhood[v]),
            ),
            reverse=True,
        )
        return current_clique

    def compute_clique_vertex_sorted(self, vertex) -> list[int]:
        """compute a clique for the vertex"""
        current_clique = [vertex]
        candidates = set(
            n.new_number for n in self.nodes_sorted[vertex].neighbors_nodes
        )
        while candidates:
            # // choose next vertex than maximize
            # // b(v) = w(v) + (w(N(v) inter candidate) )/2
            best_vertex: int = -1
            best_benefit: float = -1
            for neighbor in candidates:
                commun_neighbors = candidates.intersection(
                    nn.new_number for nn in self.nodes_sorted[neighbor].neighbors_nodes
                )
                potential_weight = sum(
                    self.nodes_sorted[n].weight for n in commun_neighbors
                )
                benefit: float = self.nodes_sorted[neighbor].weight + (
                    potential_weight / 2
                )
                if benefit > best_benefit:
                    best_benefit = benefit
                    best_vertex = neighbor
            current_clique.append(best_vertex)
            candidates.remove(best_vertex)
            candidates = candidates.intersection(
                n.new_number for n in self.nodes_sorted[best_vertex].neighbors_nodes
            )

        # if len(current_clique) < 3:
        #     return []

        current_clique.sort(
            key=lambda v: (
                self.nodes_sorted[v].weight,
                len(self.nodes_sorted[v].neighbors_int),
            ),
            reverse=True,
        )
        return current_clique

    def compute_color_bounds(self, repertory: str):
        """compute bound related to the number of colors"""
        self.lb_colors_max_size_clique = max(len(c) for c in self.cliques)
        self.ub_colors_sum_chromatic = 0
        self.ub_score_sum_weights_chromatic = 0
        for weight in self.set_of_weights:
            subgraph_file = f"{repertory}/{self.name}_{weight}.col"
            subgraph_file_out = f"{repertory}/{self.name}_{weight}.k"
            self.create_subgraph(weight, subgraph_file)
            run_tabu(subgraph_file, subgraph_file_out)
            with open(subgraph_file_out, "r", encoding="utf8") as file:
                # max between 1 and the number gave by tabucol as it need at least one color
                # even if there is only one vertex with the weight
                nb_colors = max(int(file.readline()), 1)
                self.ub_colors_sum_chromatic += nb_colors
                self.ub_score_sum_weights_chromatic += nb_colors * weight
            os.remove(subgraph_file)
            os.remove(subgraph_file_out)
        self.ub_colors_max_degree = (
            max(len(self.neighborhood[v]) for v in range(self.nb_vertices)) + 1
        )
        self.ub_colors_min_degree_chromatic = max(
            min(len(self.neighborhood[v]) + 1, self.ub_colors_sum_chromatic)
            for v in range(self.nb_vertices)
        )

    def compute_score_bounds(self):
        """find the score bounds"""
        max_len = max(len(clique) for clique in self.cliques)
        self.lb_score_default = max(self.weights)
        self.lb_score_sum_cliques = sum(
            max(self.weights[clique[i]] for clique in self.cliques if len(clique) > i)
            for i in range(max_len)
        )
        self.ub_score_default = sum(self.weights)
        self.ub_score_bks = get_best_known_score(self.name)

    def save_cliques(self, output_file: str):
        """save clique to a file, one line per clique"""
        with open(output_file, "w", encoding="utf8") as file:
            for clique in self.cliques:
                if clique == []:
                    continue
                file.write(" ".join(str(v) for v in clique))
                file.write("\n")

    def save_cliques_dzn(self, output_file: str):
        """save clique to a dzn file"""
        with open(output_file, "w", encoding="utf8") as file:
            nb_cliques = 0
            file.write("cliques=[")
            for i, clique in enumerate(self.cliques):
                if clique == []:
                    continue
                nb_cliques += 1
                file.write("{")
                file.write(",".join(str(v) for v in clique))
                file.write("}")
                if i != len(self.cliques) - 1:
                    file.write(",")
            file.write("];\n")
            file.write(f"nr_cliques={nb_cliques};\n")

    def save_graph_dzn(self, output_file: str):
        """convert graph to dzn"""
        with open(output_file, "w", encoding="utf8") as file:

            file.write(f'name="{self.name}";\n')
            file.write(f"nr_vertices={self.nb_vertices};\n")
            file.write(f"nr_edges={self.nb_edges};\n")

            # add edges
            # file.write("edges=[")
            # for i, edge in enumerate(self.edges_list):
            #     file.write("{")
            #     file.write(f"{edge[0]},{edge[1]}")
            #     file.write("}")
            #     if i != len(self.cliques) - 1:
            #         file.write(",")
            # file.write("];\n")

            # add adjacency matrix
            # file.write("adjacency_matrix=[")
            # for i, line in enumerate(self.adjacency_matrix):
            #     file.write("{")
            #     file.write(",".join(str(int(b)) for b in line))
            #     file.write("}")
            #     if i != self.nb_vertices - 1:
            #         file.write(",")
            # file.write("];\n")

            # add neighborhood
            file.write("neighborhoods=[")
            for i, neighbors in enumerate(self.neighborhood):
                file.write("{")
                file.write(",".join(str(n) for n in neighbors))
                file.write("}")
                if i != self.nb_vertices - 1:
                    file.write(",")
            file.write("];\n")

            # add weights
            file.write("weights=[")
            file.write(",".join(str(w) for w in self.weights))
            file.write("];\n")

    def save_graph_dzn_sort_vertices(self, output_file: str):
        """For original graphs, sort vertices per weight and degree before converting it"""
        with open(output_file, "w", encoding="utf8") as file:
            file.write(f'name="{self.name}";\n')
            file.write(f"nr_vertices={self.nb_vertices};\n")
            file.write(f"nr_edges={self.nb_edges};\n")

            # add neighborhood
            file.write("neighborhoods=[")
            for i, node in enumerate(self.nodes_sorted):
                file.write("{")
                file.write(",".join(str(n.new_number) for n in node.neighbors_nodes))
                file.write("}")
                if i != self.nb_vertices - 1:
                    file.write(",")
            file.write("];\n")

            # add weights
            file.write("weights=[")
            file.write(",".join(str(node.weight) for node in self.nodes_sorted))
            file.write("];\n")

    def create_subgraph(self, weight: int, subgraph_file: str):
        """create a subgraph with only vertices with weight weight"""
        vertices = [
            vertex
            for vertex in range(self.nb_vertices)
            if self.weights[vertex] == weight
        ]
        neighbors = [
            [
                neighbor
                for neighbor in self.neighborhood[vertex]
                if self.weights[neighbor] == weight
            ]
            for vertex in vertices
        ]
        vertices_sorted = sorted(
            vertices, key=lambda v: len(neighbors[vertices.index(v)]), reverse=True
        )
        neighbors_sorted = [
            sorted(
                [
                    vertices_sorted.index(neighbor)
                    for neighbor in neighbors[vertices.index(vertex)]
                ]
            )
            for vertex in vertices_sorted
            if neighbors[vertices.index(vertex)]
        ]

        with open(subgraph_file, "w", encoding="utf8") as file:
            file.write(
                f"p edge {len(neighbors_sorted)} {int(sum(len(n) for n in neighbors_sorted)/2)}\n"
            )
            for vertex, neighbors in enumerate(neighbors_sorted):
                for neighbor in neighbors:
                    if vertex < neighbor:
                        file.write(f"e {vertex + 1} {neighbor + 1}\n")


if __name__ == "__main__":
    main()
