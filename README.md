# Graph Coloring - Weighted Vertex Coloring Problem - Constraint Programming

This project includes the constraint programming (CP) models presented in the paper _New Bounds and Constraint Programming Models for the Weighted Vertex Coloring Problem, IJCAI 2023_.


# Requirements

The vertex reduction algorithm is coded in Python.
The search for color and score bounds is coded in Python and calls C++ code.
The preparation of the instances for the CP models is coded in Python.
The CP models are implemented using Minizinc and solved with OR-Tools.

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

then to link to Minizinc, create the file :

```bash
nano ~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/share/minizinc/solvers/com.google.or-tools.msc
```

and paste the following in the file (edit YOUR_USER_NAME):

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

Create the python environment and activate it:

```bash
./build_python.sh
source venv/bin/activate
```

Build tabucol :

```bash
./scripts/build_tabu.sh
```

Convert the instances to dzn format.

This operation computes all the cliques, sorts the vertices for the original instances, and computes the lower and upper bounds on the score and number of colors.
By default, it uses 15 CPU - you can change the number of jobs in the script (Parallel(n_jobs=15)).
Note that the operation takes less than a second for most of the instances but might take a long time for the bigger instances(C2000.5/9).

```bash
python scripts/compute_dzn_files.py
```

Once the script has finished, the folders `original_wvcp_dzn` and `reduced_wvcp_dzn` contain for each `instance`:

- `instance.dzn` :

  - the basic information about the instance, the vertices are sorted in descending order of weights then degrees to break ties
    - `name: str`
    - `nr_vertices: int`
    - `nr_edges: int`
    - `neighborhoods: list[list[int]]`

- `instance.clq.dzn` :

  - for each vertex, the heaviest clique with the vertex found
    - `cliques: list[list[int]]`
    - `nr_cliques: int`

- `instance.lb_colors_default.dzn` :

  - the default lower bound on the number of colors to use (1)
    - `lb_colors: int`

- `instance.lb_colors_max_size_clique.dzn` :

  - the lower bound on the number of colors to use (size of the largest clique)
    - `lb_colors: int`

- `instance.ub_colors_default.dzn` :

  - the default upper bounds on the number of colors to use (|V|)
    - `ub_colors: int`

- `instance.ub_colors_max_degree.dzn` :

  - the size of the domain of colors of each vertex based on the degrees (max(degree(v)) + 1 | v in V)
    - `ub_colors: int`

- `instance.ub_colors_sum_chromatic.dzn` :

  - the upper bound on the number of colors to use (sum of the chromatic numbers of the weight subgraphs)
    - `ub_colors: int`

- `instance.ub_colors_min_degree_chromatic.dzn` :

  - the best upper bound between sum_chromatic and max degree (max( min(degree(v) + 1, sum_chromatic) ) | v in V)
    - `ub_colors: int`

- `instance.lb_score_default.dzn` :

  - the default lower bound on the score (max weight)
    - `lb_score: int`

- `instance.lb_score_sum_cliques.dzn` :

  - the lower bound on the score (sum of the heaviest vertex in each clique)
    - `lb_score: int`

- `instance.ub_score_default.dzn` :

  - the default upper bound on the score (sum of weights)
    - `ub_score: int`

- `instance.ub_score_sum_weights_chromatic.dzn` :

  - the upper bound on the score (sum of the weight \* nb colors for weight)
    - `ub_score: int`

- `instance.ub_score_bks.dzn` :

  - the upper bound on the score (best-known score in the literature)
    - `ub_score: int`

All required files to run the models are now ready.

See [`src/README.md`](src/README.md) to go through the parameters for the CP models.

You can also edit the script [`scripts/to_eval_generator.py`](scripts/to_eval_generator.py) to prepare all the jobs you want to perform then use slurm to execute them on a cluster.

The folder `outputs` contains all the raw results reported in the article.

Once the jobs are done and JSON files generated, use the script [`scripts/xlsx_generator.py`](scripts/xlsx_generator.py) to compute spreadsheets of the results.

The output goes in the folder `xlsx_files`. 5 output files are already available:

- `E0_original_vs_reduced_all.xlsx`: comparison between the original version and reduced version of the instances
- `E1_bounds_all.xlsx`: analysis of the impact of each bound
- `E2_static_dynamic_all.xlsx`: analysis of the impact of symmetry breaking constraints in the CP models
- `E3_SD_bounds_all.xlsx`: analysis of E1 + E2
- `E4_parallel_all.xlsx`: analysis of E3 in parallel

The spreadsheets contain 6 sheets :

- `results`: results of each method on each instance. Colors have different meanings :
  - red: reached the BKS already found in the literature but did not prove optimality
  - blue: reached the optimal score and proved optimality as already done in the literature
  - green: proved optimality which was not established in the literature
- `score`: comparison of the methods, the method on the row obtains 1 point if it founds a better score on an instance than the method in the column
- `time`: comparison of the methods, the method on the row obtains 1 point if it founds the same score on an instance as the method in the column but faster
- `optim`: comparison of the methods, the method on the row obtains 1 point if it founds an optimal score on an instance that the method in the column didn't found
- `optim time`: comparison of the methods, the method on the row obtains 1 point if it proved optimality on an instance as the method in the column but faster
- `summary`: same results as the footer of the result sheet
