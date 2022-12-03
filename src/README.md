# CONTENTS

- [Software](#software)

  - [Minizinc](#minizinc)
  - [OR-Tools](#ort)
  - [Alternative CP solvers](#other_cp_solvers)

- [Datasets](#datasets)

- [CP models for WVCP](#cp_models)

- [Customizing models](#model_configuration)

  - [Parameters](#parameters)
  - [Options](#options)
    - [Upper bounds](##oub)
    - [Cliques, vertex ordering and symmetry breaking](##cliques)
    - [Search strategies and heuristics](##ssh)
    - [Primal model: decision variables, search strategies and heuristics](##pmssh)
    - [Dual model: decision variables, search strategies and heuristics](##dmssh)
    - [Joint model: decision variables, search strategies and heuristics](##jmssh)

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

second option (ou can add the export to your .bashrc):

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

You can use one of those options to import ortools

### From binary

Select the right binary from [ortools release archive](https://github.com/google/or-tools/releases/tag/v9.4).

For Ubuntu20.04 :

```
cd ~/logiciels
wget https://github.com/google/or-tools/releases/download/v9.4/or-tools_amd64_ubuntu-20.04_cpp_v9.4.1874.tar.gz
tar xzf or-tools_amd64_ubuntu-20.04_cpp_v9.4.1874.tar.gz
```

Then you need to link the solver to minzinc.

Create the file :

```
nano ~/logiciels/MiniZincIDE-2.6.4-bundle-linux-x86_64/share/minizinc/solvers/com.google.or-tools.msc
```

and copy in the file (edit YOUR_USER_NAME):

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

then to link to minizinc (edit YOUR_USER_NAME (path to your home)):

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

### Verification of the installation

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

it should print the value of x and y in the console.

### From the Minizinc IDE

TODO update the paths

1. Download the [ORT v9.2 archive](https://github.com/google/or-tools/releases/tag/v9.2)
2. Extract in the directory of your choosing
3. Start up Minizinc IDE
4. In menu `Preferences > Solvers`, choose `Add new ...` in the drop-down menu then fill in the different fields as follows:

   - Name : Google OR-Tools `[free text]`
   - Id: com.google.or-tools
   - Version : 9.2.9972
   - Executable : [`the path to <or-tools_flatzinc>/bin/fzn-or-tools`]
   - Solver library path : [`the path to <or-tools_flatzinc>/share/minizinc`]
   - Flags : [`check 'Run with mzn2fzn' and 'Run with solns2out`]
   - Command line flags : [check all checkboxes except '-t'`]

Mininzinc IDE will create a configuration file for OR-Tools in your home directory (`~/.minizinc/solvers/com.google.or-tools.msc`) or some other directory (see https://www.minizinc.org/doc-2.3.0/en/fzn-spec.html#solver-configuration-files).

Note

- OR-tools flatzinc plugin version 9.2.9972 is compatible with Minizinc 2.6.4

- OR-tools flatzinc plugin version 9.3.10497 seems incompatible with Minizinc 2.6.4

---

## Alternative CP solvers

The CP solvers packaged in the Minizinc distribution (Gecode, Chuffed, etc.) may be equally used to run the WVCP models.

Note

- Some annotations of the Minizinc language are not supported by certain solvers or require custom file inclusions and therefore cannot be used in a solver-agnostic model. For instance, random variable or value selection heuristics are supported differently by Gecode and Chuffed and do not seem supported by OR-Tools.

---

# Datasets

Each WVCP instance may be reduced by removing redundant vertices using precomputed cliques. Instances and their reduced forms are provided in separate directories

- `../original_wvcp_dzn` - contains the original instances
- `../reduced_wvcp_dzn` - contains the reduced instances

Each variant is encoded using one or two `dzn` files sharing the same instance name (eg. `C2000.5`) but having different extensions:

- the file with extension `dzn` solely encodes the instance
- the file with extension `clq.dzn` provides the list of computed cliques on the instance graph.

Note

- Vertices in reduced instances are sorted in descending order of weight. This is not the case in the original instances.

---

# CP models for WVCP

Three alternative models are provided to solve WVCP instances

1. The _primal_ model whose main file is `./primal/primal_solve.mzn`
2. The _dual_ model whose main file is `./dual/dual_solve.mzn`
3. The _joint_ model whose main file is `./joint/joint_solve.mzn`

The primal model directly handles the labelled graph encoding the input WVCP instance _without any preliminary reformulation_.

The dual model is based on the reduction of the WVCP to the Maximum Weighted Stable set Problem (MWSSP) - see [[1](https://dblp.org/rec/journals/dam/CornazFM17),[2](https://dblp.org/rec/journals/siamdm/CornazM07)]. The dual reasons over a directed graph that it pre-computes by complementing and orientating the input graph.

The joint model couples the primal and dual models and operates both on the original graph and its dual representation.

---

# Customizing models

Each model is customizable using parameters and options to switch between equivalent constraint formulations, enable or disable redundant constraints, or tailor the search strategy. Note that some parameters and options are common to the 3 models while others are model-specific. Values must be passed separately from the instance and model files either as command line arguments or using additional DZN/JSON files.

---

## Parameters

The following parameters _must_ be defined for each model

- `ub_colors (int)`- upper bound on the number of colors
- `ub_score (int)`- upper bound on the score
- `nr_cliques (int)`- the number of pre-computed cliques
- `cliques (array of set of ints)`- the precomputed set of cliques

The following data files _may_ be used to enforce default values

- `core/default_ub_colors.dzn` sets `ub_colors` to the number of vertices
- `core/default_ub_score.dzn` sets `ub_score` to the sum of the weights of the vertices
- `core/no_cliques.dzn` sets `nr_cliques` to 0 and `cliques` to the empty array

---

## Options

Options serve different purposes

- to enforce upper bound constraints
- to enforce coloring and symmetry breaking rules
- to select the search and restart strategies and the variable and value selection heuristics.

<!-- TODO - to exploit a precomputed set of cliques -->

---

### Upper bounds

Option `WVCP_B` indicates whether the user-defined upper bounds should be enforced. Its value _must_ be any subset of the following enumeration cases

- `UB_COLORS` - if supplied, the user-defined upper bound on the number of colors is enforced
- `UB_SCORE` - if supplied, the user-defined upper bound on the score is enforced

---

### Cliques, vertex ordering and symmetry breaking

Option `WVCP_M` regroups various flags that switch on or off different fragments of the model. Its value _must_ be any subset of the following enumeration cases

- `M_CLIQUES` - if supplied, the modeling of each user-defined clique by a clique of binary disequality constraints is replaced with a single all-different constraint
- `M_SR1` - if supplied, enforces symmetry breaking rule SR1 (Static Greatest Dominating Vertex rule)
- `M_DR1` - if supplied, enforces symmetry breaking rule DR1 (Dynamic Greatest Dominating Vertex rule)
- `M_SR2` - if supplied, enforces symmetry breaking rule SR2 (Static Greatest Dominating Color rule)
- `M_DR2_v1` - if supplied, enforces variant 1 of symmetry breaking rule DR2 (Dynamic Greatest Dominating Color rule)
- `M_DR2_v2` - if supplied, enforces variant 2 of symmetry breaking rule DR2 (Dynamic Greatest Dominating Color rule)

Notes

- The model systematically checks whether vertices are readily sorted in the instance and adapts constraint formulations accordingly.

- The dynamic variant of each rule entails its static variant (eg. `DR1` is stronger than `SR1`). For this reason, the model only allows one of them to be checked and exits otherwise. 

- The model checks whether redundant or entailed options are requested (eg. `DR2_v1` and `DR2_v2`) and if so exits. 

- The symmetry breaking rules are implemented in the primal model and documented in file `primal/primal.mzn`.

---

### Search strategies and heuristics

The models include options to set the search strategy, the restart strategy, the variable selection heuristics and the value selection heuristics. Each option is typed by a model-specific enumeration which may include generic values in addition to model-specific values. For instance, the heuristics selecting the vertex variables to branch on in the primal model may be set to a generic value (eg, first-fail) or a primal-specific value (eg, descending-weight-degree).

Technically, model-specific options are Minizinc enumerations that extend generic enumerations. The various options are defined and documented in the following files

- `core/heuristics.mzn` - generic restart strategies and selection heuristics for variables and values
- `primal/primal_heuristics.mzn` - primal search and restart strategies, variable and value selection heuristics
- `dual/dual_heuristics.mzn` - dual search and restart strategies, variable and value selection heuristics
- `joint/joint_heuristics.mzn` - joint search and restart strategies, variable and value selection heuristics

---

### Primal model: decision variables, search strategies and heuristics

The primal model exposes 3 types of variables:

- the number of colors to open (a single variable)
- the weight of each color
- the color of each vertex.

The following options set the search and restart strategies

- `WVCP_SEARCH_STRATEGY` - the search strategy,
- `WVCP_SEARCH_RESTART`- the restart strategy

See `primal/primal_heuristics.mzn` for the list of available search and restart strategies.

The following options set the variable selection heuristics

- `WVCP_SEARCH_VARIABLES_COLORS`- the de-facto selection of the single variable modeling the number of colors to open
- `WVCP_SEARCH_VARIABLES_VERTICES`- the prioritization of vertices to color
- `WVCP_SEARCH_VARIABLES_WEIGHTS`- the prioritization of colors to weigh

The following options set the value selection heuristics

- `WVCP_SEARCH_DOMAIN_COLORS`- the heuristics to set the number of colors to open
- `WVCP_SEARCH_DOMAIN_VERTICES`- the prioritization of colors for vertices
- `WVCP_SEARCH_DOMAIN_WEIGHTS`- the prioritization of weighs for colors

---

### Dual model: decision variables, search strategies and heuristics

The dual model exposes a single type of variables:

- the yes/no decision to include an arc for each arc of the dual graph.

The following options set the search and restart strategies

- `MWSSP_SEARCH_STRATEGY` - the search strategy
- `WVCP_SEARCH_RESTART`- the restart strategy

See `dual/dual_heuristics.mzn` for the list of available search and restart strategies.

The following option sets the variable selection heuristics

- `MWSSP_SEARCH_VARIABLES_ARCS`- the prioritization of arcs to include (or exclude based on the value selection heuristics)

The following option sets the value selection heuristics

- `MWSSP_SEARCH_DOMAIN_ARCS`- the prioritization of inclusion vs. exclusion decisions for arcs

---

### Joint model: decision variables, search strategies and heuristics

In this version, the joint model exposes the same variables as the primal and dual models and supports the same variable and value selection heuristics.

<!--
, the joint model exposes its own type of variables:

- the yes/no decision to make a vertex dominant in its color.
-->

The following option sets the search strategy <!-- TODO and restart strategies -->

- `MWSSP_WVCP_SEARCH_STRATEGY` - the search strategy
<!-- TODO `MWSSP_WVCP_SEARCH_RESTART`- the restart strategy -->

In this version, this option allows to switch for a primal search strategy or a dual search strategy. That is, the search will be either branching on primal variables or branching on dual variables. See `joint/joint_heuristics.mzn` for the list of available search strategies.

---

# Running models from the command line

We provide below samples of commands for each model then discuss additional options to extract results from the output. Each command is assumed to be be launched from the source code directory `src`.

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
--parallel 8 \
--compiler-statistics --solver-statistics \
--intermediate \
-D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" \
-D "WVCP_SEARCH_RESTART=RESTART_NONE" \
-D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" \
-D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_SPLIT" \
-D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" \
-D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" \
-D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" \
-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" \
-D "WVCP_B={UB_COLORS,UB_SCORE}" \
-D "WVCP_M={M_SR1,M_DR2_v2}" \
-d core/default_ub_colors.dzn \
-d core/default_ub_score.dzn \
-d core/no_cliques.dzn \
-d ../reduced_wvcp_dzn/p06.dzn \
-m ./primal/primal_solve.mzn
```

- runs the primal model [`-m primal/primal_solve.mzn`]
- on reduced instance `p06` [`-d ../reduced_wvcp_dzn/p06.dzn`]
- using OR-Tools [`--solver or-tools`] with 8 threads [`--parallel 8`]
- using a 5 minutes timeout [`--time-limit 300000`]
- enforcing upper bound constraints on
  - the number of colors [flag `UB_COLORS`] using the default upper-bound value [`-d core/defaut_ub_colors.dzn`]
  - the score [flag `UB_SCORE`] using the default upper-bound value [`-d core/defaut_ub_score.dzn`]
- not modeling any cliques [no flag `M_CLIQUES`] neither supplying any clique [`-d core/no_cliques.dzn`]
- enforcing symmetry breaking rules SR1 [flag `M_SR1`] and DR2_v2 [flag `M_DR2_v2`]
- using
  - the search strategy labelling vertices based on generic CP heuristics [`-D WVCP_SEARCH_STRATEGY=VERTICES_GENERIC`]
  - the first-fail variable selection heuristics [`-D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)"`]
  - the domain bisection value selection heuristics [`-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT"`]
- displaying flattener [`--compiler-statistics`] and solver [`--solver-statistics`] statistics
- and displaying intermediate solutions [`--intermediate`]

Note

- All heuristic options supported in the primal model _have_ to be set although some will be ignored based on the selected search strategy. For instance, `WVCP_SEARCH_VARIABLES_COLORS`, `WVCP_SEARCH_DOMAIN_COLORS`, `WVCP_SEARCH_VARIABLES_WEIGHTS`, `WVCP_SEARCH_DOMAIN_WEIGHTS` in the above command since the search strategy is to branch on vertices (`WVCP_SEARCH_STRATEGY=VERTICES_GENERIC`).

- Heuristics options (`*_SEARCH_VARIABLES_*`) that are set to generic values (e.g. `INPUT_ORDER`) _must_ be coerced with `WVCPSV` (.g. `"WVCPSV(INPUT_ORDER)"` in the above command. They _must not_ be coerced if they are primal-specific heuristics (eg. `DESC_WEIGHT_DEGREE`). See `primal/primal_heuristics.mzn` for the list of primal-specific heuristics and `heuristics.mzn` for the list of generic heuristics.

---

## Running the dual model

Running the dual model on original instance `p40`

```bash
minizinc \
--solver or-tools \
--time-limit 3600000 \
--parallel 8 \
--compiler-statistics --solver-statistics \
--intermediate \
-D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" \
-D "MWSSP_SEARCH_RESTART=RESTART_NONE" \
-D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" \
-D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" \
-D "WVCP_B={UB_COLORS,UB_SCORE}" \
-D "WVCP_M={}" \
-d core/default_ub_colors.dzn \
-d core/default_ub_score.dzn \
-d core/no_cliques.dzn \
-d ../original_wvcp_dzn/p40.dzn \
-m dual/dual_solve.mzn
```

---

## Running the joint model

Running the dual model on original instance `p06`

```bash
minizinc \
--solver or-tools \
--time-limit 3600000 \
--parallel 8 \
--compiler-statistics --solver-statistics \
--intermediate \
-D "MWSSP_WVCP_SEARCH_STRATEGY=MWSSP" \
-D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" \
-D "WVCP_SEARCH_RESTART=RESTART_NONE" \
-D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" \
-D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_MIN" \
-D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" \
-D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" \
-D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" \
-D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" \
-D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" \
-D "MWSSP_SEARCH_RESTART=RESTART_NONE" \
-D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" \
-D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" \
-D "WVCP_B={UB_COLORS,UB_SCORE}" \
-D "WVCP_M={}" \
-d core/default_ub_colors.dzn \
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

To extract the score of the optimal solution (if found) and the solver run time (excludes minzinc flattening time), use `jq` by piping the output of your command. For instance, to extract score and run time for a run with the primal model, use

```bash
minizinc --solver or-tools ... -m ./primal/primal_solve.mzn \
--no-intermediate \
--output-mode json \
--json-stream \
 | tail -n 1 | jq '.statistics.objective, .statistics.solveTime'
```

---

# Tuning the solver

Default solver configurations and options set in the files `primal/primal.mpc`, `dual/dual.mpc` and `joint/joint.mpc` may be adapted and passed on the command line or used from the IDE.

---

# Running models from the IDE

3 Minizinc project files to launch from the IDE are supplied for each model: `primal/primal.mzp`, `dual/dual.mzp` and `joint/joint.mzp`.
