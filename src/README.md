# CP SOLVER FOR WVCP

Three alternative models are provided

1. Stand-alone WVCP model - main file `./wvcp/wvcp_solve.mzn`
2. Stand-alone MWSSP model - main file `./mwssp/mwssp_solve.mzn`
3. Joint WVCP and MWSSP model - main file `./joint/mwssp_wvcp_solve.mzn`


# DATASETS

Two variants of each instance are provided: 

- the original instance located in `../original_wvcp_dzn`
- the reduced instance obtained by generating cliques and removing redundant vertices and located in `../reduced_wvcp_dzn`.

Each variant is encoded using one or two `dzn` files sharing the name of the instance (eg. `C2000.5`) but having different extensions: 

- the file with extension `dzn` solely encodes the instance,
- the file with extension `clq.dzn` provides the list of computed cliques on the instance graph.

Note that vertices in reduced instances are sorted in descending order of weight. This is not the case in the original instances.



# MODEL AND SOLVER FLAGS

Each of the 3 minizinc models may be run with any CP solver supporting flatzinc (eg. OR-Tools, Chuffed) on any variant of any instance.

Restart strategies may be used.

Each model is configurable with flags and heuristics. Some flags/heuristics are common to the 3 models while others are model-specific. Note that the combined model combines both the flags used for MWSSP and WVCP.

Flags/heuristics are directly set in the following parameter files:

- `./parameters.dzn`
- `./wvcp/wvcp_parameters.dzn`
- `./mwssp/mwssp_parameters.dzn`
- `./mwssp_wvcp/mwssp_wvcp_parameters.dzn`

<!-- Default flag values are provided in the files `wvcp.mpc`, `mwssp.mpc` and `mwssp_wvcp.mpc` which may be overriden when using the commmand-line or the IDE. -->



## Common flags

`WVCP_B` is a flag indicating which of the provided upper bounds should effectively be used in the model. Technically, it is a minizinc set that may include the following enumeration cases

-- `UB_SCORE`: indicates whether the model uses the provided upper bound on the score or not
-- `UB_COLORS`: indicates whether the model uses the provided upper known of the number of colors 

`WVCP_M` is a flag indicating which features of the model should be turned on. Technically, it is a minizinc set that may include the following enumeration cases

-- `M_SORT`: indicates if the model does itself sort vertices in descending order of weight and use this ordering
-- `M_CLIQUES`: indicates if each clique is modeled with an all-different constraint instead of a clique of binary disequality constraints
-- `M_SR1`: indicates if symmetry breaking rule SR1 (Static Greatest Dominating Vertex rule) should be enforced
-- `M_DR1`: indicates if symmetry breaking rule DR1 (Dynamic Greatest Dominating Vertex rule) should be enforced
-- `M_SR2`: indicates if symmetry breaking rule SR2 (Static Greatest Dominating Color rule) should be enforced
-- `M_DR2`: indicates if symmetry breaking rule DR2 (Dynamic Greatest Dominating Color rule) should be enforced.


## WVCP specific flags

Search flags are cases of enumerations defined in `heuristics.mzn` (generic CP heuristics) and `./wvcp/wvcp_heuristics.mzn` (WVCP-specific heuristics).

- enum: WVCP_SEARCH_STRATEGY - variables to branch on
- enum: WVCP_SEARCH_RESTART - restart strategy or none
- enum: WVCP_SEARCH_VARIABLES_COLORS - variable heuristics on colors to open/close
- enum: WVCP_SEARCH_DOMAIN_COLORS - domain heuristics on openness/closure of color variables
- enum: WVCP_SEARCH_VARIABLES_DOMINANTS - variable heuristics on dominating vertices
- enum: WVCP_SEARCH_DOMAIN_DOMINANTS - domain heuristics on coloring of dominating vertex variables
- enum: WVCP_SEARCH_VARIABLES_VERTICES - variable heuristics on vertices to color
- enum: WVCP_SEARCH_DOMAIN_VERTICES - domain heuristics on coloring of vertex variables


## MWSSP specific flags

Search flags are cases of enumerations defined in `heuristics.mzn` (generic CP heuristics) and `mwssp/mwssp_heuristics.mzn` (MWSSP-specific heuristics).

- enum: MWSSP_SEARCH_STRATEGY - variables to branch on
- enum: MWSSP_SEARCH_RESTART - restart strategy or none
- enum: MWSSP_SEARCH_VARIABLES_ARCS - variable heuristics on arc to include/exclude
- enum: MWSSP_SEARCH_DOMAIN_ARCS - domain heuristics on inclusion/exclusion of arc variables


## MWSSP+WVCP specific flags

Search flags are cases of enumerations defined in `mwssp_wvcp/mwssp_wvcp__heuristics.mzn` (MWSSP-WVCP-specific heuristics).

- enum: MWSSP_WVCP_SEARCH_STRATEGY - either branching on MWSSP variables or on WVCP variables


# COMMAND LINE EXAMPLES

The commands given below must be launched from the minizinc source code directory `src`.

Remarks

1. For minizinc option `solver`, use either `com.google.or-tools`, `org.gecode.gecode` or `org.chuffed.chuffed`
2. For minizinc option `time-limit`, the timeout value should be given in milliseconds
3. In parameter files, heuristic flags (`*_SEARCH_VARIABLES_*`) that are set to generic values (e.g. `INPUT_ORDER`) must be coerced with `WVCPSV` (e.g. `"WVCPSV(INPUT_ORDER)"`) if they are WVCP flags or with `MWSSPSV` if they are MWSSP flags. They must NOT be coerced if they are WVCP- or MWSSP-specific flags (e.g. `DESC_WEIGHT_DEGREE`).


## Running the WVCP model

USING parameter (dzn) files on original instance p06

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate wvcp_solve.mzn ../no_ub_colors.dzn ../no_ub_score.dzn ../no_cliques.dzn ../parameters.dzn wvcp_parameters.dzn ../../original_wvcp_dzn/p06.dzn ; beep`

NOT USING parameter (dzn) files on original instance p06

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate -D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" -D "WVCP_SEARCH_RESTART=RESTART_NONE" -D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_MIN" -D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" -D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" -D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" wvcp_solve.mzn ../no_cliques.dzn ../no_ub_colors.dzn ../no_ub_score.dzn -D "WVCP_B={}" -D "WVCP_M={M_SORT}" ../../original_wvcp_dzn/p40.dzn ; beep`

USING parameter (dzn) files on reduced instance p06 with cliques

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate wvcp_solve.mzn ../no_ub_colors.dzn ../no_ub_score.dzn ../parameters.dzn wvcp_parameters.dzn ../../reduced_wvcp_dzn/p06.dzn ../../reduced_wvcp_dzn/p06.clq.dzn ; beep`


## Running the MWSSP model

USING parameter (dzn) files on original instance p06

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate mwssp_solve.mzn ../no_ub_colors.dzn ../no_ub_score.dzn ../no_cliques.dzn ../parameters.dzn mwssp_parameters.dzn ../../original_wvcp_dzn/p06.dzn ; beep`

NOT USING parameter (dzn) files on original instance p06

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate -D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" -D "MWSSP_SEARCH_RESTART=RESTART_NONE" -D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" -D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" mwssp_solve.mzn ../no_cliques.dzn ../no_ub_colors.dzn ../no_ub_score.dzn -D "WVCP_B={}" -D "WVCP_M={}" ../../original_wvcp_dzn/p40.dzn ; beep`

NOT USING parameter (dzn) files on reduced instance p06 with cliques

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate -D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" -D "MWSSP_SEARCH_RESTART=RESTART_NONE" -D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" -D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" mwssp_solve.mzn ../no_ub_colors.dzn ../no_ub_score.dzn -D "WVCP_B={}" -D "WVCP_M={}" ../../reduced_wvcp_dzn/p40.dzn ../../reduced_wvcp_dzn/p40.clq.dzn ; beep`


## Running the joint model

USING parameter (dzn) files on original instance p06

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate mwssp_wvcp_solve.mzn ../no_ub_colors.dzn ../no_ub_score.dzn ../no_cliques.dzn ../parameters.dzn mwssp_wvcp_parameters.dzn ../../original_wvcp_dzn/p06.dzn ; beep`

NOT USING parameter (dzn) files on original instance p06

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate -D "MWSSP_WVCP_SEARCH_STRATEGY=MWSSP" -D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" -D "WVCP_SEARCH_RESTART=RESTART_NONE" -D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_MIN" -D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" -D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" -D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" -D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" -D "MWSSP_SEARCH_RESTART=RESTART_NONE" -D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" -D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" mwssp_wvcp_solve.mzn ../no_cliques.dzn ../no_ub_colors.dzn ../no_ub_score.dzn -D "WVCP_B={}" -D "WVCP_M={M_SORT}" ../../original_wvcp_dzn/p40.dzn ; beep`

USING parameter (dzn) files on reduced instance p06 with cliques

`date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate mwssp_wvcp_solve.mzn ../no_ub_colors.dzn ../no_ub_score.dzn ../parameters.dzn mwssp_wvcp_parameters.dzn ../../reduced_wvcp_dzn/p06.dzn ../../reduced_wvcp_dzn/p06.clq.dzn ; beep`
