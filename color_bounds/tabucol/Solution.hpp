#pragma once

#include <string>
#include <vector>

#include "Graph.hpp"

/**
 * @brief Represent the action of moving a vertex to a color
 *
 */
struct Coloration {
    /** @brief vertex to color*/
    int vertex;
    /** @brief color to use*/
    int color;
};

/**
 * @brief A solution is represented by the color of each vertex
 * 0 if the vertex is uncolored
 */
class Solution {
  public:
    std::shared_ptr<Graph> graph;

  private:
    /** @brief for each vertex, its color */
    std::vector<int> _colors;
    /** @brief number of constraint not respected */
    int _penalty;
    /** @brief for each vertex, the number of conflicts in the current color */
    std::vector<int> _nb_conflicts;
    /** @brief set of each vertex in conflicts (sorted vector) */
    std::vector<int> _conflicting_vertices;
    /** @brief for each vertex, for each color
     * the cost on the number of conflicts if its moved there */
    std::vector<std::vector<int>> _delta_colors;
    /** @brief for each vertex, best transition cost */
    std::vector<int> _best_delta;
    /** @brief for each vertex, set of best colors (vector of sorted vector) */
    std::vector<std::vector<int>> _best_improve_colors;
    /** @brief number of colors (k-coloring can not change) */
    int _nb_colors;

  public:
    Solution(const std::shared_ptr<Graph> &graph_, const int nb_colors);

    void init_optimized_structures();

    /**
     * @brief Delete the vertex from its old color and move it to the new one
     * while updating best_improve_color and best_improve_conflicts
     * and return its old color
     *
     * make sure init_optimized_structures have been called before using it
     */
    int move_to_color_optimized(const int vertex, const int color);

    void add_to_color(const int vertex, const int color);

    int delete_from_color(const int vertex);

    bool check_solution() const;

    bool is_legal() const;

    int nb_colors() const;

    int operator[](const int vertex) const;

    int penalty() const;

    const std::vector<int> &conflicting_vertices() const;

    int best_improve_conflicts(const int vertex) const;

    const std::vector<int> &best_improve_colors(const int vertex) const;

    int delta_conflicts_colors(const int vertex, const int color) const;
};
