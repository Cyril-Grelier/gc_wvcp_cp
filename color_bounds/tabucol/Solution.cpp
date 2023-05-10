#include "Solution.hpp"

#include <algorithm>
#include <cassert>
#include <iostream>

#include "utils.hpp"

Solution::Solution(const std::shared_ptr<Graph> &graph_, const int nb_colors)
    : graph(graph_),
      _colors(graph->nb_vertices, 0),
      _penalty(0),
      _nb_conflicts(graph->nb_vertices, 0),
      _delta_colors(graph->nb_vertices, std::vector<int>(nb_colors + 1, 0)),
      _nb_colors(nb_colors) {
    for (int vertex{0}; vertex < graph->nb_vertices; ++vertex) {
        std::vector<int> best_colors;
        int min_conflicts = graph->nb_vertices;
        for (int color{1}; color <= _nb_colors; ++color) {
            bool better = _delta_colors[vertex][color] < min_conflicts;
            bool same = _delta_colors[vertex][color] == min_conflicts;
            if (not same and not better) {
                continue;
            }
            if (better) {
                min_conflicts = _delta_colors[vertex][color];
                best_colors.clear();
            }
            best_colors.emplace_back(color);
        }
        const int color = rd::choice(best_colors);
        add_to_color(vertex, color);
    }

    init_optimized_structures();
}

void Solution::init_optimized_structures() {
    _best_delta = std::vector<int>(graph->nb_vertices, graph->nb_vertices);
    _best_improve_colors = std::vector<std::vector<int>>(graph->nb_vertices);
    for (int vertex = 0; vertex < graph->nb_vertices; vertex++) {
        for (int color{1}; color <= _nb_colors; ++color) {
            const int delta{_delta_colors[vertex][color]};
            if (delta < _best_delta[vertex]) {
                _best_delta[vertex] = delta;
                _best_improve_colors[vertex].clear();
            }
            if (delta == _best_delta[vertex]) {
                _best_improve_colors[vertex].emplace_back(color);
            }
        }
    }
}

int Solution::move_to_color_optimized(const int vertex, const int color) {
    assert(check_solution());
    const int old_color = delete_from_color(vertex);

    add_to_color(vertex, color);

    for (const auto &neighbor : graph->neighborhood[vertex]) {
        // as the vertex leave//enter the color every delta updates
        if (_colors[neighbor] == old_color) {
            ++_best_delta[neighbor];
            ++_best_delta[vertex];
        }
        if (_colors[neighbor] == color) {
            --_best_delta[neighbor];
            --_best_delta[vertex];
        }
        //// ajout pour garder la meilleur transition
        const int best_improve = _best_delta[neighbor];

        if (_delta_colors[neighbor][old_color] < best_improve) {
            _best_delta[neighbor]--;
            _best_improve_colors[neighbor].clear();
            insert_sorted(_best_improve_colors[neighbor], old_color);
        } else if (_delta_colors[neighbor][old_color] == best_improve) {
            insert_sorted(_best_improve_colors[neighbor], old_color);
        }

        if ((_delta_colors[neighbor][color] - 1) == best_improve) {

            if (_best_improve_colors[neighbor].size() > 1) {
                assert(contains(_best_improve_colors[neighbor], color));
                erase_sorted(_best_improve_colors[neighbor], color);
            } else {
                _best_improve_colors[neighbor].clear();
                _best_delta[neighbor] = graph->nb_vertices;
                for (int color_{1}; color_ <= _nb_colors; ++color_) {
                    const int delta{_delta_colors[neighbor][color_]};
                    if (delta < _best_delta[neighbor]) {
                        _best_delta[neighbor] = delta;
                        _best_improve_colors[neighbor].clear();
                    }
                    if (delta == _best_delta[neighbor]) {
                        _best_improve_colors[neighbor].emplace_back(color_);
                    }
                }
            }
        }
    }
    assert(check_solution());

    return old_color;
}

void Solution::add_to_color(const int vertex, const int color) {
    _colors[vertex] = color;

    // affect of the vertex entering in the new color
    for (const auto &neighbor : graph->neighborhood[vertex]) {
        ++_delta_colors[neighbor][color];
        if (_colors[neighbor] == color) {
            ++_nb_conflicts[vertex];
            ++_nb_conflicts[neighbor];
            ++_penalty;
            if (_nb_conflicts[neighbor] == 1) {
                insert_sorted(_conflicting_vertices, neighbor);
            }
            if (_nb_conflicts[vertex] == 1) {
                insert_sorted(_conflicting_vertices, vertex);
            }
            // as the presence of the vertex in the color increase the number of
            // conflicts in the color, the delta is better for all other colors
            for (int color_ = 1; color_ <= _nb_colors; color_++) {
                --_delta_colors[neighbor][color_];
                --_delta_colors[vertex][color_];
            }
        }
    }
}

int Solution::delete_from_color(const int vertex) {
    const int color = _colors[vertex];
    assert(vertex >= 0);
    assert(vertex < graph->nb_vertices);
    assert(_colors[vertex] != 0);
    _colors[vertex] = 0;

    // Update conflict score
    const int nb_conflicts_vertex = _nb_conflicts[vertex];
    _penalty -= nb_conflicts_vertex;
    if (nb_conflicts_vertex != 0) {
        erase_sorted(_conflicting_vertices, vertex);
    }
    _nb_conflicts[vertex] = 0;

    // update conflicts for neighbors
    for (const int neighbor : graph->neighborhood[vertex]) {
        --_delta_colors[neighbor][color];
        if (color == _colors[neighbor]) {
            --_nb_conflicts[neighbor];
            if (_nb_conflicts[neighbor] == 0) {
                erase_sorted(_conflicting_vertices, neighbor);
            }
            for (int color_ = 1; color_ <= _nb_colors; ++color_) {
                ++_delta_colors[neighbor][color_];
                ++_delta_colors[vertex][color_];
            }
        }
    }

    return color;
}

bool Solution::check_solution() const {
    int penalty{0};
    for (int vertex = 0; vertex < graph->nb_vertices; vertex++) {
        int current_color{_colors[vertex]};

        int min_delta{graph->nb_vertices};
        std::vector<int> best_colors;
        for (int color{1}; color <= _nb_colors; ++color) {
            int nb_conflicts{0};
            for (const auto neighbor : graph->neighborhood[vertex]) {
                if (_colors[neighbor] == color) {
                    ++nb_conflicts;
                }
            }
            int delta = nb_conflicts - _nb_conflicts[vertex];
            assert(_delta_colors[vertex][color] == delta);
            if (color == current_color) {
                penalty += nb_conflicts;
                assert(_nb_conflicts[vertex] == nb_conflicts);
                if (nb_conflicts != 0) {
                    assert(contains(_conflicting_vertices, vertex));
                }
            }
            if (delta < min_delta) {
                best_colors.clear();
                min_delta = delta;
            }
            if (delta == min_delta) {
                best_colors.emplace_back(color);
            }
        }
        assert(best_colors == _best_improve_colors[vertex]);
        assert(min_delta == _best_delta[vertex]);
    }
    return true;
}

bool Solution::is_legal() const {
    return _conflicting_vertices.empty();
}

int Solution::nb_colors() const {
    return _nb_colors;
}

int Solution::operator[](const int vertex) const {
    return _colors[vertex];
}

int Solution::penalty() const {
    return _penalty;
}

const std::vector<int> &Solution::conflicting_vertices() const {
    return _conflicting_vertices;
}

int Solution::best_improve_conflicts(const int vertex) const {
    return _best_delta[vertex];
}

const std::vector<int> &Solution::best_improve_colors(const int vertex) const {
    return _best_improve_colors[vertex];
}

int Solution::delta_conflicts_colors(const int vertex, const int color) const {
    return _delta_colors[vertex][color];
}
