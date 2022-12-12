#include "Graph.h"

#include <algorithm>
#include <assert.h>
#include <list>

using namespace std;

namespace opt {

Graph::Graph(const int n)
    : weights_(n, 0), total_weight_(0), n_(n), m_(0), adj_l_(n, std::vector<int>()) {
}

void Graph::removeEdge(const int i, const int j) {
    assert(i < n_ && j < n_);

    if (find(adj_l_[i].begin(), adj_l_[i].end(), j) != adj_l_[i].end() && i != j) {
        removeNeighbor(i, j);
        removeNeighbor(j, i);
        m_--;
    }
}

void Graph::addEdge(const int i, const int j) {
    assert(i < n_ && j < n_);
    if (find(adj_l_[i].begin(), adj_l_[i].end(), j) == adj_l_[i].end() && i != j) {
        addNeighbor(i, j);
        addNeighbor(j, i);
        m_++;
    }
}

void Graph::sort() {
    for (int v = 0; v < n_; v++) {
        std::sort(adj_l_[v].begin(), adj_l_[v].end());
    }
}

} // namespace opt