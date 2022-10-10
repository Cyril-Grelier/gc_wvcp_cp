"""
Compute the cliques

The clique is computed with fast cliques, at least one clique per vertex
Cai, Shaowei, and Jinkun Lin. “Fast Solving Maximum Weight Clique Problem in Massive Graphs”
"""
from __future__ import annotations


def main():
    """for each instance of the problem, compute the cliques"""
    problem = "wvcp"
    instances_names: list[str] = []
    with open(
        f"instances/instance_list_{problem}.txt", "r", encoding="utf8"
    ) as instances_file:
        instances_names = instances_file.read().splitlines()
    for instance_name in instances_names:
        print(instance_name)
        instance_file: str = f"instances/reduced_{problem}/{instance_name}.col"
        weights_file: str = "" if problem == "gcp" else instance_file + ".w"
        graph: Graph = Graph(instance_file, weights_file)
        graph.save_cliques(f"cliques_{problem}/{instance_name}.clq")
        graph.save_cliques_dzn(f"cliques_{problem}/{instance_name}.dzn")


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
        self.reduced_vertices: list[int]
        self.cliques: list[list[int]]
        self.sorted_vertices: list[int]
        self.heaviest_vertex_weight: int

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

        # compute cliques
        self.cliques = [
            self.compute_clique_vertex(vertex) for vertex in range(self.nb_vertices)
        ]

        self.reduced_vertices = []

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
            key=lambda v: (self.weights[v], len(self.neighborhood[v])), reverse=True
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
            file.write(f"nb_cliques={nb_cliques};\n")


if __name__ == "__main__":
    main()
