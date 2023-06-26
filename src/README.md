# CONTENTS

- [Software](#software)

  - [Minizinc](#minizinc)
  - [OR-Tools](#ort)
  - [Alternative CP solvers](#other_cp_solvers)

- [Datasets](#datasets)

- [CP models for WVCP](#cpmodels)

- [Customizing models](#model_configuration)

  - [Parameters](#parameters)
  - [Options](#options)
    - [Upper bounds](##oub)
    - [Cliques, vertex ordering, and symmetry breaking](##cliques)
    - [Search strategies and heuristics](##ssh)
    - [Primal model: decision variables, search strategies, and heuristics](##pmssh)
    - [Dual model: decision variables, search strategies, and heuristics](##dmssh)
    - [Joint model: decision variables, search strategies, and heuristics](##jmssh)

- [Running models from the command line](#cli)

  - [Running the primal model](#rpm)
  - [Running the dual model](#rdm)
  - [Running the joint model](#rjm)

- [Extracting results](#rpm)

- [Tuning the solver](#solver)

- [Running models from the IDE](#ide)

---

# Software

---

## Minizinc

CP models for WVCP have been implemented and tested with Minizinc 2.6.4 using OR-Tools plugin 9.2.9972 on Mac OS Monterey 12.4.

To install the Minizinc distribution and IDE, visit [Minizinc](https://www.minizinc.org/software.html).

Second option (you can add the exports to your .bashrc):

```
cd
mkdir logiciels
cd logiciels
wget https://github.com/MiniZinc/MiniZincIDE/releases/download/2.6.4/MiniZincIDE-2.6.4-bundle-linux-x86_64.tgz
tar xzf MiniZincIDE-2.6.4-bundle-linux-x86_64.tgz

export PATH=~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/bin:$PATH
export LD_LIBRARY_PATH=~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/lib:$LD_LIBRARY_PATH
export QT_PLUGIN_PATH=~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/plugins:$QT_PLUGIN_PATH
```

---

## OR-Tools

You can use one of the following options to install ortools.

### From binary

Select the right binary from [ortools release archive](https://github.com/google/or-tools/releases/tag/v9.4).

For Ubuntu20.04:

```
cd ~/logiciels
wget https://github.com/google/or-tools/releases/download/v9.4/or-tools_amd64_ubuntu-20.04_cpp_v9.4.1874.tar.gz
tar xzf or-tools_amd64_ubuntu-20.04_cpp_v9.4.1874.tar.gz
```

Then you need to link the solver to Minizinc.

Create the file:

```
nano ~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/share/minizinc/solvers/com.google.or-tools.msc
```

and paste the following contents (edit YOUR_USER_NAME):

```
{
  "id": "com.google.or-tools",
  "name": "OR Tools",
  "description": "Google's Operations Research tools FlatZinc interface",
  "version": "9.4.9999",
  "mznlib": "../../../../or-tools_cpp_Ubuntu-20.04-64bit_v9.4.1874/share/minizinc/",
  "executable": "/home/YOUR_USER_NAME/logiciels/or-tools_cpp_Ubuntu-20.04-64bit_v9.4.1874/bin/fzn-ortools",
  "tags": ["ortools", "cp", "lcg", "float", "int"],
  "stdFlags": ["-a","-f","-n","-p","-r","-s","-v","-l"],
  "extraFlags": [
    ["--cp_model_params", "Provide parameters interpreted as a text SatParameters proto", "string", ""],
  ],
  "supportsMzn": false,
  "supportsFzn": true,
  "needsSolns2Out": true,
  "needsMznExecutable": false,
  "needsStdlibDir": false,
  "isGUIApplication": false
}
```

### From source

```
cd ~/logiciels
wget https://github.com/google/or-tools/archive/refs/tags/v9.4.tar.gz
tar xzf v9.4.tar.gz

cd or-tools-9.4/

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release .. -DBUILD_DEPS:BOOL=ON
make -j 8
```

then to link to Minizinc (edit YOUR_USER_NAME):

```
{
  "id": "com.google.or-tools",
  "name": "OR Tools",
  "description": "Google's Operations Research tools FlatZinc interface",
  "version": "9.4.9999",
  "mznlib": "../../../../or-tools-9.4/ortools/flatzinc/mznlib",
  "executable": "/home/YOUR_USER_NAME/logiciels/or-tools-9.4/build/bin/fzn-ortools",
  "tags": ["ortools", "cp", "lcg", "float", "int"],
  "stdFlags": ["-a","-f","-n","-p","-r","-s","-v","-l"],
  "extraFlags": [
    ["--cp_model_params", "Provide parameters interpreted as a text SatParameters proto", "string", ""],
  ],
  "supportsMzn": false,
  "supportsFzn": true,
  "needsSolns2Out": true,
  "needsMznExecutable": false,
  "needsStdlibDir": false,
  "isGUIApplication": false
}
```

### Check your installation

You can try ortools by running the following program (`test.mzn`):

```
var 1..3: x;
var 1..3: y;
constraint x+y > 3;
solve satisfy;
```

```
minizinc test.mzn  --solver ortools
```

it should print the values of x and y in the console.

---

## Alternative CP solvers

The CP solvers packaged in the Minizinc distribution (Gecode, Chuffed, etc.) may be equally used to run the WVCP models.

Note

- Some annotations of the Minizinc language are not supported by some solvers or require custom file inclusions and therefore cannot be used in a solver-agnostic model. For instance, random variable or value selection heuristics are supported differently by Gecode and Chuffed and do not seem supported by OR-Tools.

---

# Datasets

Each WVCP instance may be reduced by removing redundant vertices using precomputed cliques. Instances and their reduced forms are provided in separate directories

- `../original_wvcp_dzn` - contains the original instances
- `../reduced_wvcp_dzn` - contains the reduced instances

Each variant is encoded using one or two `dzn` files sharing the same instance name (eg. `C2000.5`) but having different extensions:

- the file with extension `dzn` solely encodes the instance
- the file with extension `clq.dzn` provides the list of computed cliques on the instance graph.

Note

- Vertices in reduced instances are sorted in descending order of weight which is not the case in the original instances. The models systematically check whether vertices are readily sorted and sets an internal flag (`D_SORTED`) to adapt constraints accordingly.

---

# CP models for WVCP

Three alternative models are provided to solve WVCP instances (see IJCAI article):

1. The _primal_ model whose main file is `./primal/primal_solve.mzn`
2. The _dual_ model whose main file is `./dual/dual_solve.mzn`
3. The _joint_ model whose main file is `./joint/joint_solve.mzn`


---

# Customizing models

Each model is customizable using parameters to tailor the search strategy and flags to switch constraints on or off. Some parameters and flags are common to the 3 models while others are model-specific. All must be passed separately from the instance and model files either as command line arguments or using additional DZN/JSON files.

---

## Parameters

The following parameters _must_ be defined for each model

- `lb_colors (int)`- lower bound on the number of colors
- `ub_colors (int)`- upper bound on the number of colors
- `lb_score (int)`- lower bound on the score
- `ub_score (int)`- upper bound on the score
- `nr_cliques (int)`- the number of pre-computed cliques
- `cliques (array of set of ints)`- the precomputed set of cliques

The following data files _may_ be used to enforce default values

- `./core/default_lb_colors.dzn` sets `lb_colors` to 1
- `./core/default_ub_colors.dzn` sets `ub_colors` to the number of vertices
- `./core/default_lb_score.dzn` sets `lb_score` to the maximum of the weights of the vertices
- `./core/default_ub_score.dzn` sets `ub_score` to the sum of the weights of the vertices
- `./core/no_cliques.dzn` sets `nr_cliques` to 0 and `cliques` to the empty array


---

### Flags for constraints

Option `WVCP_M` regroups various flags that switch on or off different fragments of the model. Its value _must_ be any subset of the following enumeration cases

- `M_DG` - enforces the upper-bound equal to the degree of the graph plus 1 on the number of colors (Corollary 2 - see `./core/core.mzn`)
- `M_MLS` - enforces solution compactness in primal and joint models using constraint (P11) with MAX\_LEFT\_SHIFT (see `./primal/primal.mzn` and `./primal/max_left_shift.mzn`)
- `M_LS` - enforces solution compactness in primal and joint models using constraint (J4) (see `./primal/primal.mzn` and `./primal/left_shift.mzn`)
- `M_R2` - enforces reduction rule R2 adapted to primal and joint models using constraint (J5) (see `./primal/primal.mzn` and `./primal/left_shift.mzn`)
- `M_AUX` - enforces redundant constraints (see `./primal/primal.mzn`)
<!-- `M_GCP` - searches for chromatic number (ie. solves Graph Coloring Problem instead of WVCP) -->

Notes

- The range of colors `K` is set to `1..ub_colors` by default or `1..min(ub_colors, degree+1)` if `M_DG` is switched on.

---

### Flags for search strategies and heuristics

The models include flags to set the search strategy, the restart strategy, the variable selection heuristics, and the value selection heuristics. Each flag is typed by a model-specific enumeration which may include generic values in addition to model-specific values. For instance, the heuristics selecting the vertex variables to branch on in the primal model may be set to a generic value (eg, first-fail) or a primal-specific value (eg, descending-weight-degree).

Technically, model-specific flags are Minizinc enumerations that extend generic enumerations. The flags are defined and documented in the following files

- `core/core.mzn` - generic restart strategies and selection heuristics for variables and values
- `primal/primal.mzn` - primal search and restart strategies, variable and value selection heuristics
- `dual/dual.mzn` - dual search and restart strategies, variable and value selection heuristics
- `joint/joint.mzn` - joint search and restart strategies, variable and value selection heuristics

---

### Primal model: decision variables, search strategies, and heuristics

The primal model exposes the following variables:

- the color of each vertex
- the vertices of each color
- the weight of each color
- the dominant vertex of each color (the heaviest vertex of the color with the smallest id)
- the number of opened colors (colors including at least one vertex)
- the WVCP score of the coloring

The following options set the search and restart strategies

- `PRIMAL_STRATEGY` - the search strategy,
- `PRIMAL_RESTART`- the restart strategy

See `primal/primal.mzn` for the list of available search and restart strategies.

The following options set the variable selection heuristics

- `PRIMAL_H_VAR_VERTICES`- the prioritization of vertices to color
- `PRIMAL_H_VAR_COLORS`- the de-facto selection of the single variable modeling the number of colors to open
- `PRIMAL_H_VAR_WEIGHTS`- the prioritization of colors to weigh

The following options set the value selection heuristics

- `PRIMAL_H_VAL_COLORS`- the heuristics to set the number of colors to open
- `PRIMAL_H_VAL_VERTICES`- the prioritization of colors for vertices
- `PRIMAL_H_VAL_WEIGHTS`- the prioritization of weights for colors

---

### Dual model: decision variables, search strategies, and heuristics

The dual model exposes the following variables:

- the decision to include or exclude an arc of the dual graph
- the MWSSP score of the dual solution
- the WVCP score of the dual solution (of is corresponding primal soluiton)
- the number of opened colors in the corresponding primal solution

The following options set the search and restart strategies

- `DUAL_STRATEGY` - the search strategy
- `DUAL_RESTART`- the restart strategy

See `dual/dual.mzn` for the list of available search and restart strategies.

The following option sets the variable selection heuristics

- `DUAL_H_VAR_ARCS`- the prioritization of arcs to include/exclude

The following option sets the value selection heuristics

- `DUAL_H_VAL_ARCS`- the prioritization of inclusion vs. exclusion decisions for arcs

---

### Joint model: decision variables, search strategies, and heuristics

The joint model inherits the sets of variables from the primal and dual models.

The joint model supports the same variable and value selection heuristics as the dual and primal models. In addition, the following option sets the search and restart strategies

- `JOINT_STRATEGY` - the search strategy
- `JOINT_RESTART`- the restart strategy

The first flag allows to choose between a primal search strategy (value `PRIMAL`) or a dual search strategy (value `DUAL`), ie. the search will either be branching on primal variables or branching on dual variables.

---

# Running models from the command line

We provide below samples of commands to run each model and discuss additional options to extract results from the output. Each command _must_ launched from the source code directory `src`.

Notes

1. For Minizinc option `solver`, use either `com.google.or-tools`, `org.gecode.gecode` or `org.chuffed.chuffed`
2. Time-out values for Minizinc option `time-limit` should be given in milliseconds

---

## Running the primal model

This command

```bash
minizinc \
--solver or-tools \
--time-limit 300000 \
--parallel 1 \
--compiler-statistics --solver-statistics \
--intermediate \
-D "PRIMAL_STRATEGY=VERTICES_BY_WEIGHT" \
-D "PRIMAL_RESTART=RESTART_NONE" \
-D "PRIMAL_H_VAR_VERTICES=WVCPSV(FIRST_FAIL)" \
-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" \
-D "PRIMAL_H_VAR_COLORS=INPUT_ORDER" \
-D "PRIMAL_H_VAL_COLORS=INDOMAIN_MIN" \
-D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER" \
-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_MAX" \
-D "WVCP_M={M_DG,M_MLS}" \
-d core/default_lb_colors.dzn \
-d core/default_ub_colors.dzn \
-d core/default_lb_score.dzn \
-d core/default_ub_score.dzn \
-d core/no_cliques.dzn \
-d ../original_wvcp_dzn/p06.dzn \
-m ./primal/primal_solve.mzn
```

- runs the primal model [`-m primal/primal_solve.mzn`]
- on original instance `p06` [`-d ../original_wvcp_dzn/p06.dzn`]
- using OR-Tools [`--solver or-tools`] with 8 threads [`--parallel 8`]
- using a 5 minutes timeout [`--time-limit 300000`]
- not modeling any cliques [no flag `M_CLIQUES`] neither supplying any clique [`-d core/no_cliques.dzn`]
- enforcing upper-bound constraint on vertex variables [flag `M_DG`] and compactness constraint (P11) using MAX\_LEFT\_SHIFT [flag `M_MLS`]
- using
  - the search strategy grouping vertices by descending weight values [`-D PRIMAL_STRATEGY=VERTICES_BY_WEIGHT`]
  - the first-fail variable selection heuristics applied in each group of vertices [`-D "PRIMAL_H_VAR_VERTICES=WVCPSV(FIRST_FAIL)"`]
  - the domain bisection value selection heuristics [`-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT"`]
- displaying flattener statistics [`--compiler-statistics`] and solver [`--solver-statistics`] statistics
- and displaying intermediate solutions [`--intermediate`]

Note

- All heuristic options supported in the primal model _must_ be set although some will be ignored based on the selected search strategy. For instance, `PRIMAL_H_VAR_COLORS`, `PRIMAL_H_VAL_COLORS`, `PRIMAL_H_VAR_WEIGHTS`, `PRIMAL_H_VAL_WEIGHTS` will be ignored in the above command since the search strategy is to branch on vertices (`PRIMAL_STRATEGY=VERTICES_BY_WEIGHT`).

- The selection of a generic Minizinc heuristics for vertex variables (`PRIMAL_H_VAR_VERTICES`)  _must_ be coerced with `WVCPSV` (`"WVCPSV(FIRST_FAIL)"` in the above command). If the heuristics is WVCP-specific (e.g. `DESC_WEIGHT_DEGREE`), no coercion is needed. See `primal/primal.mzn` for the list of primal-specific heuristics and `core.mzn` for the list of generic heuristics.

---

## Running the dual model

Running the dual model on original instance `p40`:

```bash
minizinc \
--solver or-tools \
--time-limit 300000 \
--parallel 1 \
--compiler-statistics --solver-statistics \
--intermediate \
-D "DUAL_STRATEGY=ARCS_SPECIFIC" \
-D "DUAL_RESTART=RESTART_NONE" \
-D "DUAL_H_VAR_ARCS=DESC_WEIGHT_TAIL" \
-D "DUAL_H_VAL_ARCS=INDOMAIN_MAX" \
-D "WVCP_M={}" \
-d core/default_lb_colors.dzn \
-d core/default_ub_colors.dzn \
-d core/default_lb_score.dzn \
-d core/default_ub_score.dzn \
-d core/no_cliques.dzn \
-d ../original_wvcp_dzn/p40.dzn \
-m dual/dual_solve.mzn
```

---

## Running the joint model

Running the dual model on original instance `p06`:

```bash
minizinc \
--solver or-tools \
--time-limit 300000 \
--parallel 1 \
--compiler-statistics --solver-statistics \
--intermediate \
-D "JOINT_STRATEGY=PRIMAL" \
-D "PRIMAL_STRATEGY=VERTICES_BY_WEIGHT" \
-D "PRIMAL_RESTART=RESTART_NONE" \
-D "PRIMALH_VAR_VERTICES=WVCPSV(FIRST_FAIL)" \
-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" \
-D "PRIMALH_VAR_COLORS=WVCPSV(INPUT_ORDER)" \
-D "PRIMAL_H_VAL_COLORS=INDOMAIN_MIN" \
-D "PRIMALH_VAR_WEIGHTS=WVCPSV(INPUT_ORDER)" \
-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" \
-D "DUAL_STRATEGY=ARCS_SPECIFIC" \
-D "DUAL_RESTART=RESTART_NONE" \
-D "DUALH_VAR_ARCS=DESC_WEIGHT_TAIL" \
-D "DUAL_H_VAL_ARCS=INDOMAIN_MAX" \
-D "WVCP_M={M_DG,M_MLS}" \
-d core/default_lb_colors.dzn \
-d core/default_ub_colors.dzn \
-d core/default_lb_score.dzn \
-d core/default_ub_score.dzn \
-d core/no_cliques.dzn \
-d ../original_wvcp_dzn/p06.dzn \
-m joint/joint_solve.mzn
```

---

# Extracting results

To disable the output of intermediate solution, use option `--no-intermediate` in your commands.

To output results as json objects, use option `--output-mode json`.

To output a stream of json objects rather than unstructured text, use option `--json-stream`.

To extract the score of the optimal solution (if found) and the solver run time (excludes Minizinc flattening time), use `jq` by piping the output of your command. For instance, to extract score and run time for a run with the primal model, use

```bash
minizinc --solver or-tools ... -m ./primal/primal_solve.mzn \
--no-intermediate \
--output-mode json \
--json-stream \
 | tail -n 1 | jq '.statistics.objective, .statistics.solveTime'
```

---

# Tuning the solver

Default solver configurations and options set in the files `primal/primal.mpc`, `dual/dual.mpc`, and `joint/joint.mpc` may be adapted and passed on the command line or used from the IDE.

---

# Running models from the IDE

3 Minizinc project files to launch from the IDE are supplied for each model: `primal/primal.mzp`, `dual/dual.mzp`, and `joint/joint.mzp`.

The projects include the default color/score bound files (`core/default_lb_colors.dzn`, `core/default_ub_colors.dzn`, `core/default_lb_score.dzn` and `core/default_ub_score.dzn`) that may be customized.
