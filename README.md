# Graph Coloring - Weighted Vertex Coloring Problem - Constraint Programming

This project is about solving the Weighted Vertex Coloring Problem (WVCP) with constraint programming.

This work is related to the paper: New Bounds and Constraint Programming Models for the Weighted Vertex Coloring Problem. IJCAI 2023.

Which studies the reduction of WVCP benchmark instances, finds color, and score bounds, and seeks to solve the problem with constraint programming.

# Requirements

The reduction part is coded in Python.
The search for color and score bounds is coded in Python and call C++ code.
The preparation of the instances for the CP model is coded in Python.
The CP model is created with Minizinc and solved with OR-Tools.

- Python 3.9+
- CMake 3.20+
- GCC 9+
- Minizinc Minizinc 2.6.4 (https://www.minizinc.org/)
- OR-Tools v9.4 (https://developers.google.com/optimization/)

# Installation

This project has been tested on Mac OS (for the cp models and some scripts) and Linux (for everything).

Make sure Python, CMake, and GCC are installed.

To install Minizinc in a `logiciels` folder in your home directory:

```bash
cd
mkdir logiciels
cd logiciels
wget https://github.com/MiniZinc/MiniZincIDE/releases/download/2.6.4/MiniZincIDE-2.6.4-bundle-linux-x86_64.tgz
tar xzf MiniZincIDE-2.6.4-bundle-linux-x86_64.tgz

# only the first export is useful to run from the command line
export PATH=~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/bin:$PATH
export LD_LIBRARY_PATH=~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/lib:$LD_LIBRARY_PATH
export QT_PLUGIN_PATH=~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/plugins:$QT_PLUGIN_PATH
```

To install OR-Tools in a `logiciels` folder in your home directory:

```bash
cd ~/logiciels
wget https://github.com/google/or-tools/archive/refs/tags/v9.4.tar.gz
tar xzf v9.4.tar.gz

cd or-tools-9.4/

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release .. -DBUILD_DEPS:BOOL=ON
make -j 8
```

then to link to minizinc, create the file :

```bash
nano ~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/share/minizinc/solvers/com.google.or-tools.msc
```

and copy in the file (edit YOUR_USER_NAME):

```json
{
  "id": "com.google.or-tools",
  "name": "OR Tools",
  "description": "Google's Operations Research tools FlatZinc interface",
  "version": "9.4.9999",
  "mznlib": "../../../../or-tools-9.4/ortools/flatzinc/mznlib",
  "executable": "/home/YOUR_USER_NAME/logiciels/or-tools-9.4/build/bin/fzn-ortools",
  "tags": ["ortools", "cp", "lcg", "float", "int"],
  "stdFlags": ["-a", "-f", "-n", "-p", "-r", "-s", "-v", "-l"],
  "extraFlags": [
    [
      "--cp_model_params",
      "Provide parameters interpreted as a text SatParameters proto",
      "string",
      ""
    ]
  ],
  "supportsMzn": false,
  "supportsFzn": true,
  "needsSolns2Out": true,
  "needsMznExecutable": false,
  "needsStdlibDir": false,
  "isGUIApplication": false
}
```

# Instances

The instances are located in the folder `instances` with the scripts for the reduction and the best-known scores reported in the literature.

To load the instances :

```bash
git submodule init
git submodule update
```

Follow the [`instances/README.md`](instances/README.md) to reproduce the reduction.

# Installation

Create the python environment and activate it :

```bash
./build_python.sh
source venv/bin/activate
```

Build tabucol :

```bash
./scripts/build_tabu.sh
```

Convert the instances to dzn format.

This operation uses by default 15 CPU,
you change in the script file the number of jobs in the main (Parallel(n_jobs=15)).
This operation takes less than a second for most of the instances and might take a long time for the bigger instances(C2000.5/9).
This operation computes all the cliques, sort the vertices for the original instances, and computes the lower and upper bound on the score and colors.

```bash
python scripts/compute_dzn_files.py
```

Once the script is executed, the folders `original_wvcp_dzn` and `reduced_wvcp_dzn` contain for each `instance` :

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

- `instance.lb_colors_default.dzn` :

  - the default lower bound on the number of colors to use (1)
  - data :
    - `lb_colors: int`

- `instance.lb_colors_max_size_clique.dzn` :

  - the lower bound on the number of colors to use (size of the largest clique)
  - data :
    - `lb_colors: int`

- `instance.ub_colors_default.dzn` :

  - the default upper bounds on the number of colors to use (|V|)
  - data :
    - `ub_colors: int`

- `instance.ub_colors_max_degree.dzn` :

  - the size of the domain of colors of each vertex based on the degrees (max(d(v)) + 1 | v in V)
  - data :
    - `ub_colors: int`

- `instance.ub_colors_sum_chromatic.dzn` :

  - the upper bound on the number of colors to use (sum of the chromatic number of each weight subgraph)
  - data :
    - `ub_colors: int`

- `instance.ub_colors_min_degree_chromatic.dzn` :

  - the best upper bound between sum_chromatic and max degree (max( min(d(v) + 1, sum_chromatic) ) | v in V)
  - data :
    - `ub_colors: int`

- `instance.lb_score_default.dzn` :

  - the default lower bound on the score (max weight)
  - data :
    - `lb_score: int`

- `instance.lb_score_sum_cliques.dzn` :

  - the lower bound on the score (sum of the heaviest i^est vertex on each clique)
  - data :
    - `lb_score: int`

- `instance.ub_score_default.dzn` :

  - the default upper bound on the score (sum of weights)
  - data :
    - `ub_score: int`

- `instance.ub_score_sum_weights_chromatic.dzn` :

  - the upper bound on the score (sum of the weight \* nb color for weight)
  - data :
    - `ub_score: int`

- `instance.ub_score_bks.dzn` :

  - the upper bound on the score (best-known score in the literature)
  - data :
    - `ub_score: int`

All required files to run the models are now ready.

See [`src/README.md`](src/README.md) to go through the parameter for the model.

You can also edit the script [`scripts/to_eval_generator.py`](scripts/to_eval_generator.py) to prepare all the jobs you want to perform then use slurm to execute them on a cluster.

The folder `outputs` contains all the raw results reported in the article.

Once the jobs are done and JSON files generated, use the script [`scripts/xlsx_generator.py`](scripts/xlsx_generator.py) to compute spreadsheets of the results.

The output goes in the folder `xlsx_files`. 5 results of experiments are already available :

- `E0_original_vs_reduced_all.xlsx`: comparison between the original version and reduced version of the instances
- `E1_bounds_all.xlsx`: analysis of the impact of each bound
- `E2_static_dynamic_all.xlsx`: analysis of symmetry breaking rules
- `E3_SD_bounds_all.xlsx`: analysis of E1 + E2
- `E4_parallel_all.xlsx`: analysis of E3 in parallel

The spreadsheets contain 6 sheets :

- `results`: results of each method on each instance. Colors have different meanings :
  - blue: proved an optimal score already found in the literature
  - red: reached the best-known score in the literature
  - green: new optimal score not proved in the literature
- `score`: comparison between each method, the method on the row obtains 1 point if it founds a better score on an instance than the method in the column
- `time`: comparison between each method, the method on the row obtains 1 point if it founds the same score on an instance as the method in the column but faster
- `optim`: comparison between each method, the method on the row obtains 1 point if it founds an optimal score on an instance that the method in the column didn't found
- `optim time`: comparison between each method, the method on the row obtains 1 point if it proved optimality on an instance as the method in the column but faster
- `summary`: same results as the footer of the result sheet
