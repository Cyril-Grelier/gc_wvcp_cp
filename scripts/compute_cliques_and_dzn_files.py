"""
Compute the cliques

The clique is computed with fast cliques, at least one clique per vertex
Cai, Shaowei, and Jinkun Lin. “Fast Solving Maximum Weight Clique Problem in Massive Graphs”
"""
from __future__ import annotations
from dataclasses import dataclass, field
from joblib import Parallel, delayed


def conversion_reduced(problem: str, instance_name: str):
    """convert instance reduced version"""
    repertory_red: str = f"reduced_{problem}_dzn"
    instance_file: str = f"instances/reduced_{problem}/{instance_name}.col"
    weights_file: str = "" if problem == "gcp" else instance_file + ".w"
    graph: Graph = Graph(instance_file, weights_file, to_sort=False)
    graph.save_cliques(f"{repertory_red}/{instance_name}.clq")
    graph.save_cliques_dzn(f"{repertory_red}/{instance_name}.clq.dzn")
    graph.save_graph_dzn(f"{repertory_red}/{instance_name}.dzn")


def conversion_original(problem: str, instance_name: str):
    """convert instance original version"""
    repertory_or: str = f"original_{problem}_dzn"
    instance_file: str = f"instances/original_graphs/{instance_name}.col"
    weights_file: str = "" if problem == "gcp" else instance_file + ".w"
    graph: Graph = Graph(instance_file, weights_file, to_sort=True)
    graph.save_cliques(f"{repertory_or}/{instance_name}.clq")
    graph.save_cliques_dzn(f"{repertory_or}/{instance_name}.clq.dzn")
    graph.save_graph_dzn_sort_vertices(f"{repertory_or}/{instance_name}.dzn")


def conversion(problem: str, instance_name: str, i: int, nb_instances: int):
    """convert instance"""
    if i < nb_instances:
        print(instance_name, "reduced")
        conversion_reduced(problem, instance_name)
    else:
        print(instance_name, "original")
        conversion_original(problem, instance_name)


def main():
    """for each instance of the problem, compute the cliques"""
    problem = "wvcp"
    instances_names: list[str] = []
    # with open(
    #     f"instances/instance_list_{problem}.txt", "r", encoding="utf8"
    # ) as instances_file:
    #     instances_names = instances_file.read().splitlines()
    with open("instance_feasible.txt", "r", encoding="utf8") as instances_file:
        instances_names = instances_file.read().splitlines()

    Parallel(n_jobs=15)(
        delayed(conversion)(problem, instance_name, i, len(instances_names))
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


if __name__ == "__main__":
    main()
