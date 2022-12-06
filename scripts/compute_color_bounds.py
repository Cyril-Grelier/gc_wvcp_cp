"""
Compute an upper bound on the number of colors to use for a graph
"""
from __future__ import annotations
import subprocess
import os

from joblib import Parallel, delayed


def run_tabu(subgraph_file: str, subgraph_file_out: str):
    subprocess.run(
        ["color_bounds/build/tabucol", subgraph_file, subgraph_file_out],
        check=True,
    )


def find_nb_color_reduced(problem: str, instance_name: str):
    """compute color reduced version"""
    repertory_red: str = f"reduced_{problem}_dzn"
    instance_file: str = f"instances/reduced_{problem}/{instance_name}.col"
    weights_file: str = "" if problem == "gcp" else instance_file + ".w"
    graph: Graph = Graph(instance_file, weights_file)
    nb_color = 0
    for weight in graph.set_of_weights:
        subgraph_file = f"{repertory_red}/{instance_name}_{weight}.col"
        subgraph_file_out = f"{repertory_red}/{instance_name}_{weight}.k"
        graph.convert_graph(weight, subgraph_file)
        run_tabu(subgraph_file, subgraph_file_out)
        with open(subgraph_file_out, "r", encoding="utf8") as file:
            nb_color += int(file.readline())
        os.remove(subgraph_file)
        os.remove(subgraph_file_out)
    color_file = f"{repertory_red}/{instance_name}.k"
    with open(color_file, "w", encoding="utf8") as file:
        file.write(f"nb_max_color={nb_color}")


def find_nb_color_original(problem: str, instance_name: str):
    """compute color original version"""
    repertory_ori: str = f"original_{problem}_dzn"
    instance_file: str = f"instances/original_graphs/{instance_name}.col"
    weights_file: str = "" if problem == "gcp" else instance_file + ".w"
    graph: Graph = Graph(instance_file, weights_file)
    nb_color = 0
    for weight in graph.set_of_weights:
        subgraph_file = f"{repertory_ori}/{instance_name}_{weight}.col"
        subgraph_file_out = f"{repertory_ori}/{instance_name}_{weight}.k"
        graph.convert_graph(weight, subgraph_file)
        run_tabu(subgraph_file, subgraph_file_out)
        with open(subgraph_file_out, "r", encoding="utf8") as file:
            nb_color += int(file.readline())
        os.remove(subgraph_file)
        os.remove(subgraph_file_out)
    color_file = f"{repertory_ori}/{instance_name}.k"
    with open(color_file, "w", encoding="utf8") as file:
        file.write(f"nb_max_color={nb_color}")


def find_nb_colors(problem: str, instance_name: str, i: int, nb_instances: int):
    """convert instance"""
    if i < nb_instances:
        print(instance_name, "reduced")
        find_nb_color_reduced(problem, instance_name)
    else:
        print(instance_name, "original")
        find_nb_color_original(problem, instance_name)


def main():
    """for each instance of the problem, find the bound"""
    problem = "wvcp"
    instances_names: list[str] = []
    # with open(
    #     f"instances/instance_list_{problem}.txt", "r", encoding="utf8"
    # ) as instances_file:
    #     instances_names = instances_file.read().splitlines()
    with open("instance_feasible.txt", "r", encoding="utf8") as instances_file:
        instances_names = instances_file.read().splitlines()
    Parallel(n_jobs=15)(
        delayed(find_nb_colors)(problem, instance_name, i, len(instances_names))
        for i, instance_name in enumerate(instances_names + instances_names)
    )


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


class Graph:
    """Representation of a graph"""

    def __init__(self, instance_file: str, weights_file: str) -> None:
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

        # load instance
        self.name = instance_file.split("/")[-1][:-4]
        self.nb_vertices, self.edges_list = read_col_files(instance_file)

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

        self.set_of_weights = sorted(list(set(self.weights)))

    def convert_graph(self, weight: int, subgraph_file: str):
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
