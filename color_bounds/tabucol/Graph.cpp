#include "Graph.hpp"

#include <fstream>
#include <iostream>

Graph::Graph(const int nb_vertices_,
             const int nb_edges_,
             const std::vector<std::vector<bool>> &adjacency_matrix_,
             const std::vector<std::vector<int>> &neighborhood_,
             const std::vector<int> &degrees_)
    : nb_vertices(nb_vertices_),
      nb_edges(nb_edges_),
      adjacency_matrix(adjacency_matrix_),
      neighborhood(neighborhood_),
      degrees(degrees_) {
}

std::shared_ptr<Graph> load_graph(const std::string &instance_file) {
    // load the edges and vertices of the graph
    std::ifstream file;
    file.open(instance_file);

    if (!file) {
        std::cerr << "\nERROR : " << instance_file << " not found" << std::endl;
        exit(1);
    }
    int nb_vertices{0}, nb_edges{0}, v1{0}, v2{0};
    std::vector<std::vector<bool>> adjacency_matrix;
    std::vector<std::vector<int>> neighborhood;
    std::string first;
    file >> first;
    while (!file.eof()) {
        if (first == "e") {
            file >> v1 >> v2;
            --v1;
            --v2;

            adjacency_matrix[v1][v2] = true;
            adjacency_matrix[v2][v1] = true;
            neighborhood[v1].push_back(v2);
            neighborhood[v2].push_back(v1);
            ++nb_edges;
        } else if (first == "p") {
            file >> first >> nb_vertices >> nb_edges;
            adjacency_matrix = std::vector<std::vector<bool>>(
                nb_vertices, std::vector<bool>(nb_vertices, false));
            neighborhood =
                std::vector<std::vector<int>>(nb_vertices, std::vector<int>(0));
        } else {
            getline(file, first);
        }
        file >> first;
    }
    file.close();

    std::vector<int> degrees(nb_vertices, 0);
    for (int vertex{0}; vertex < nb_vertices; ++vertex) {
        degrees[vertex] = static_cast<int>(neighborhood[vertex].size());
    }
    return std::make_shared<Graph>(
        nb_vertices, nb_edges, adjacency_matrix, neighborhood, degrees);
}
