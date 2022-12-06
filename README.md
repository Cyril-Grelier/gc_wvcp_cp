# gc_wvcp_cp

Constraint Programing for the Weighted Vertex Coloring Problem.

# Requirements

- Python3.9+
- Minizinc (https://www.minizinc.org/)

# Installation

    # clone the project
    git clone https://github.com/Cyril-Grelier/gc_wvcp_cp
    # go to the project directory
    cd gc_wvcp_cp
    # import the instances
    git submodule init
    git submodule update
    # Create python environment (you can change the python version in scripts/build_python.sh) :
    ./build_python.sh
    source venv/bin/activate
    # compute the cliques and convert it to dzn format (can take around 20min)
    # use 15 CPU !
    python scripts/compute_cliques_and_dzn_files.py
    # build tabucol
    ./scripts/build_tabu.sh
    # compute the color bounds
    # use 15 CPU !
    python scripts/compute_color_bounds.py
