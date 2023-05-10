#include <cassert>
#include <ctime>
#include <fstream>
#include <iostream>
#include <numeric>

#include "Graph.hpp"
#include "Solution.hpp"
#include "utils.hpp"

/**
 * @brief TabuCol optimized
 *
 * Optimizations from :
 * Moalic, Laurent, and Alexandre Gondran.
 * Variations on Memetic Algorithms for Graph Coloring Problems.
 * Journal of Heuristics 24, no. 1 (February 2018): 1–24.
 * https://doi.org/10.1007/s10732-017-9354-9.
 *
 * Based on :
 * Hertz, A., Werra, D., 1987.
 * Werra, D.: Using Tabu Search Techniques for Graph Coloring.
 * Computing 39, 345-351. Computing 39.
 * https://doi.org/10.1007/BF02239976
 *
 * @param solution solution to use, the solution will be modified
 * @param verbose True if print csv line each time new best scores is found
 */
void tabu_col(Solution &solution);

int main(int argc, const char *argv[]) {
    if (argc < 3) {
        std::cerr << "ERROR : Usage : ./main instance_file output_file" << std::endl;
        exit(1);
    }
    const std::string instance_file{argv[1]};
    const std::string output_file{argv[2]};

    const auto graph{load_graph(instance_file)};
    int best_nb_color{graph->nb_vertices};

    for (int nb_color{graph->nb_vertices}; nb_color > 0; --nb_color) {
        Solution solution(graph, nb_color);
        tabu_col(solution);
        assert(solution.check_solution());
        if (solution.penalty() == 0) {
            best_nb_color = nb_color;
        } else {
            break;
        }
    }
    std::ofstream output(output_file);
    output << best_nb_color;
}

void tabu_col(Solution &solution) {

    std::uniform_int_distribution<long> distribution_tabu(0, 10);

    const auto graph = solution.graph;
    const auto nb_colors = solution.nb_colors();

    int best_found{solution.penalty()};
    std::vector<std::vector<long>> tabu_matrix(graph->nb_vertices,
                                               std::vector<long>(nb_colors + 1, 0));

    long turn_no_improve{0};
    long turn{0};
    while (best_found != 0 and turn_no_improve < 1000) {

        ++turn;
        ++turn_no_improve;

        int best_nb_conflicts = std::numeric_limits<int>::max();
        std::vector<Coloration> best_colorations;

        for (const auto vertex : solution.conflicting_vertices()) {
            const int current_best_improve = solution.best_improve_conflicts(vertex);
            if (current_best_improve > best_nb_conflicts) {
                continue;
            }

            const int current_color = solution[vertex];
            bool added = false;

            for (const auto &color : solution.best_improve_colors(vertex)) {
                if (color == current_color) {
                    continue;
                }

                const bool vertex_tabu{(tabu_matrix[vertex][color] >= turn)};
                const bool improve_best_solution{
                    (((current_best_improve + solution.penalty()) < best_found))};

                if (not improve_best_solution and vertex_tabu) {
                    continue;
                }

                added = true;
                if (current_best_improve < best_nb_conflicts) {
                    best_nb_conflicts = current_best_improve;
                    best_colorations.clear();
                }
                best_colorations.emplace_back(Coloration{vertex, color});
            }

            if (added or (current_best_improve >= best_nb_conflicts)) {
                continue;
            }

            // if the bests moves are tabu we have to look for other moves
            for (int color = 1; color <= nb_colors; color++) {
                if (color == current_color) {
                    continue;
                }

                const int conflicts = solution.delta_conflicts_colors(vertex, color);
                if (conflicts > best_nb_conflicts) {
                    continue;
                }

                const bool vertex_tabu{(tabu_matrix[vertex][color] >= turn)};
                const bool improve_best_solution{
                    (((current_best_improve + solution.penalty()) < best_found))};
                if (not improve_best_solution and vertex_tabu) {
                    continue;
                }

                if ((conflicts < best_nb_conflicts)) {
                    best_nb_conflicts = conflicts;
                    best_colorations.clear();
                }
                best_colorations.emplace_back(Coloration{vertex, color});
            }
        }
        if (best_colorations.empty()) {
            continue;
        }

        // select and apply the best move
        const auto [vertex, color]{rd::choice(best_colorations)};
        const int old_color = solution.move_to_color_optimized(vertex, color);

        // update tabu matrix
        tabu_matrix[vertex][old_color] =
            turn + distribution_tabu(rd::generator) +
            static_cast<long>(
                0.6 * static_cast<double>(solution.conflicting_vertices().size()));

        if (solution.penalty() < best_found) {
            best_found = solution.penalty();
            turn_no_improve = 0;
        }
    }
}
