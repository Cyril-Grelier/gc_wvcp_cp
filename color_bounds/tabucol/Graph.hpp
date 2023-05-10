#pragma once

#include <memory>
#include <string>
#include <vector>

/**
 * @brief Struct Graph use information from .col files to create the instance
 *
 */
struct Graph {
    /** @brief Number of vertices in the graph*/
    const int nb_vertices;

    /** @brief Number of edges in the graph*/
    const int nb_edges;

    /** @brief Adjacency matrix, true if there is an edge between vertex i and vertex j*/
    const std::vector<std::vector<bool>> adjacency_matrix;

    /** @brief For each vertex, the list of its neighbors*/
    const std::vector<std::vector<int>> neighborhood;

    /** @brief For each vertex, its degree*/
    const std::vector<int> degrees;

    explicit Graph(const int nb_vertices_,
                   const int nb_edges_,
                   const std::vector<std::vector<bool>> &adjacency_matrix_,
                   const std::vector<std::vector<int>> &neighborhood_,
                   const std::vector<int> &degrees_);

    Graph(const Graph &other) = delete;
};

/**
 * @brief Load a graph from instances/reduced_gcp directory
 */
std::shared_ptr<Graph> load_graph(const std::string &instance_name);
