# Graph Coloring - Weighted Vertex Coloring Problem - Constraint Programming

Constraint Programing for the Weighted Vertex Coloring Problem.

# Requirements

- Python3.9+
- Minizinc (https://www.minizinc.org/)
- ortools
- CMake

See [`src/README.md`](src/README.md) for more information about the installation of Minizinc and ortools.
The following commands are required before running the project

# Installation

First clone the project

    git clone https://github.com/Cyril-Grelier/gc_wvcp_cp
    cd gc_wvcp_cp

Then import the instances

git submodule init
git submodule update

Create the python environment

    ./build_python.sh
    source venv/bin/activate

Build tabucol

    ./scripts/build_tabu.sh

Convert the instances to dzn format.

This operation use by default 15 CPU,
you change in the script file the number of jobs in the main (Parallel(n_jobs=15)).
This operation take less than a second for most of the instances, see c`conversion_time_dzn.csv` for the the bigger instances.
This operation compute all the cliques, sort the vertices for the original instances and compute lower and upper bound on the score and colors.

    python scripts/compute_dzn_files.py

Once the scripts executed, the folders `original_wvcp_dzn` and `reduced_wvcp_dzn` contain for each `instance` :

- `instance.dzn` :
  - the basic information about the instance, the vertices are sorted per weight and degree
  - data :
    - `name: str`
    - `nr_vertices: int`
    - `nr_edges: int`
    - `neighborhoods: list[list[int]]`
- `instance.clq.dzn` :
  - for each vertex, the heaviest clique with the vertex found
  - data :
    - `cliques: list[list[int]]`
    - `nr_cliques: int`
- `instance.lb_colors.dzn` :
  - the lower bound on the number of colors to use (size of the largest clique)
  - data :
    - `lb_colors: int`
- `instance.ub_colors_min_degree_chromatic.dzn` :
  - the upper bound on the number of colors to use (sum of the chromatic number of each weight subgraph)
  - data :
    - `ub_colors: int`
- `instance.ub_colors_degree.dzn` :
  - the size of the domain of colors of each vertex based on the degrees (max(d(v)) + 1 | v in V)
  - data :
    - `ub_colors: int`
- `instance.ub_colors_chromatic.dzn` :
  - the size of the domain of colors of each vertex based on the ub_colors (max( min(d(v) + 1, ub_colors) ) | v in V)
  - data :
    - `ub_colors: int`
- `instance.lb_score.dzn` :
  - the lower bound on the score (sum of the heaviest i^est vertex on each cliques)
  - data :
    - `lb_score: int`
- `instance.ub_score.dzn` :
  - the upper bound on the score (best known score in the literature)
  - data :
    - `ub_score: int`
