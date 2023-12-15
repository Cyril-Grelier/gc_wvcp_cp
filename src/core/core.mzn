%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Lesaint (david.lesaint@univ-angers.fr)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MODEL OPTIONS

% Model features (only effective for primal/joint models)
enum WVCP_FEATURE = {
	M_DG,			% enforces upper-bound ∆+1 on the number of colors (Corollary 1)
	M_MLS,			% enforces solution compactness in primal/joint model using constraint (P11) with MAX_LEFT_SHIFT (Theorem 2)
	M_MLS_v2,	% enforces solution compactness in primal/joint model using constraint (P11) with a variant of MAX_LEFT_SHIFT (Theorem 2)
	M_LS,			% enforces solution compactness in primal/joint model using constraint (J4)
	M_R2,			% enforces reduction rule R2 in primal/joint model to upper-bound the coloring domains of vertex variables
	M_CLIQUES,	% enforces all-different constraints in primal/joint model for pre-computed cliques
	M_AUX,			% enforces redundant constraints
	%% disabled in primal/dual/joint_solve.mzn
% 	M_GCP,			% searches for chromatic number (ie. solves GCP instead of WVCP)
};

% Model configuration
set of WVCP_FEATURE: WVCP_M;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INSTANCE DATA

% instance name
string: name;
% number of vertices
int: nr_vertices;
% number of edges
int: nr_edges;
% neighborhoods (!! vertices are indexed from 0 in `neighborhoods` in data file)
array[int] of set of int: neighborhoods;
% weights (!! vertices may NOT be sorted in descending order of weights in data file)
array[int] of int: weights;

% number of cliques
int: nr_cliques;
% cliques (!! vertices are indexed from 0 in `cliques` in data file)
array[int] of set of int: cliques;

% lower bound on number of colors
int: lb_colors;
% upper bound on number of colors
int: ub_colors;
% lower bound on WVCP score
int: lb_score;
% upper bound on WVCP score
int: ub_score;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DATA ASSERTIONS

constraint assert(nr_vertices>0, "assertion failed: the grap must include at least one vertex");
constraint assert(2*nr_edges = sum(i in index_set(neighborhoods))(card(neighborhoods[i])), "assertion failed: nr_edges inconsistent with total size of neighborhoods");
constraint assert(forall(i in index_set(neighborhoods))(neighborhoods[i] subset 0..nr_vertices-1), "assertion failed: neighbor out of bounds");
constraint assert(forall(i in index_set(weights))(weights[i]>=0), "assertion failed: negative vertex weight");
constraint assert(nr_cliques = card(index_set(cliques)), "assertion failed: nr_cliques inconsistent with size of array of cliques");
constraint assert(forall(i in index_set(cliques))(cliques[i] subset 0..nr_vertices-1), "assertion failed: clique vertices out of bounds");
constraint assert(forall(i in index_set(cliques))(i-min(index_set(cliques)) in cliques[i]), "assertion failed: i-th vertex must belong to i-th clique");
constraint assert(ub_colors in 1..nr_vertices, "assertion failed: ub_colors out of bounds");
constraint assert(lb_colors in 1..ub_colors, "assertion failed: lb_colors out of bounds");
constraint assert(ub_score in 0..sum(weights), "assertion failed: ub_score out of bounds");
constraint assert(lb_score in 0..ub_score, "assertion failed: lb_score out of bounds");

% built-in flag indicating whether vertices are sorted in descending order of weights in the data file (true) or not (false)
% the flag is used to adapt dominance ordering checks and constraints of the primal model
bool: D_SORTED = forall(i in index_set(weights) where i<max(index_set(weights)))(weights[i]>=weights[i+1]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UTILITIES

% range(S) = [S] = [1..card(S)]
function set of int: range(set of int: S) = 1..card(S);
% omega(S) = [0..card(S)]
function set of int: omega(set of int: S) = 0..card(S);
% flatten an array of sets
function array[int] of int: flatten(array[int] of set of int: tab) =
	if length(tab) = 0
	then		[]
	elseif length(tab) = 1
	then		set2array(tab[min(index_set(tab))])
	else		set2array(tab[min(index_set(tab))]) ++ flatten(tab[min(index_set(tab))+1..max(index_set(tab))])
	endif;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MODEL DATA

%% GRAPH
% range of vertices V (V == [V])
set of int: V = 1..nr_vertices;
% neighborhood function N (!! vertices indexed from 0 in data file -> re-indexed from min(V) here)
array[V] of set of V: N = [{min(V)+j | j in neighborhoods[i]} | i in index_set(neighborhoods)];


%% WEIGHTED GRAPH
% weight function w
array[V] of int: w = weights;
% set of weights W
set of int: W = array2set(w);
% scale of weights sorted in descending order
array[range(W)] of W: W_scale = reverse(set2array(W));
% weight-based distribution of vertices
array[range(W)] of set of V: W_V = [{ v | v in V where w[v]=W_scale[i]} | i in range(W)];

%% DOMINANCE ORDERING
% checks whether u strictly dominates v
function bool: dominates(V: u, V: v) =
	if D_SORTED
	then
		u<v
	else
		(w[u]>w[v]) \/ (w[u]=w[v] /\ u<v)
	endif;

%% DEGREE & DENSITY
% vertex degree ∆
array[V] of int: degree = [card(N[v]) | v in V];
% graph density
float: density = sum(degree) / max({1,(card(V)*(card(V)-1))});

%% VERTEX CONNECTIVITY
% disconnected vertices
array[int] of V: disconnected = [v | v in V where N[v] = {}];
% fully-connected vertices
array[int] of V: cliqued = [v | v in V where N[v] = V diff {v}];

%% CLIQUES
% set of cliques C (!! clique vertices indexed from 0 in data file -> re-indexed from min(V))
array[1..nr_cliques] of set of V: C = [{min(V)+v | v in cliques[i]} | i in index_set(cliques)];

%% COLORS
% range of colors K (K ==[K]): if M_DG is on, |K| == min(∆+1, \kappa) (Corollary 1) else |K| == \kappa
set of int: K = 
	if M_DG in WVCP_M
	then
				% (a)
				1..min(ub_colors, max(degree) + 1)
	else
				% (b)
				1..ub_colors				
	endif;

%% WVCP SCORE
% domain for WVCP score
set of int: P_SCORE = lb_score..ub_score;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERIC SEARCH STRATEGY ANNOTATIONS

%include "chuffed.mzn"; % for random_order heuristic on variables
%include "gecode.mzn"; % for random heuristic on variables


%% RESTART ANNOTATIONS
% See https://www.minizinc.org/doc-2.6.4/en/lib-stdlib-annotations.html?highlight=restart#restart-annotations
enum RESTART = {
  RESTART_NONE,
  RESTART_CONSTANT,
  RESTART_LINEAR,
  RESTART_GEOMETRIC,
  RESTART_LUBY
};

%
function ann: restart(RESTART: flag, int: scale, float: base) =
  if     flag == RESTART_NONE
  then   restart_none
  elseif flag == RESTART_CONSTANT
  then   restart_constant(scale)
  elseif flag == RESTART_LINEAR
  then   restart_linear(scale)
  elseif flag == RESTART_GEOMETRIC
  then   restart_geometric(base,scale)
  elseif flag == RESTART_LUBY
  then   restart_luby(scale)
  else   restart_none
  endif;
  

%% VARIABLE HEURISTICS
% See https://www.minizinc.org/doc-2.6.4/en/lib-stdlib-annotations.html?highlight=restart#variable-selection-annotations
enum H_VAR = {
  ANTI_FIRST_FAIL,
  DOM_W_DEG,
  FIRST_FAIL,
  IMPACT,
  INPUT_ORDER,
  LARGEST,
  MAX_REGRET,
  MOST_CONSTRAINED,
  OCCURRENCE,
%   RANDOM,% for GECODE
%   RANDOM_ORDER,% for Chuffed
  SMALLEST
};


% variables: anti_first_fail | dom_w_deg | first_fail | impact | input_order | largest | max_regret | most_constrained | occurrence | random (gecode) | random_order (chuffed) | smallest
function ann: heuristic_variables(H_VAR: flag) =
  if      flag == ANTI_FIRST_FAIL
  then    anti_first_fail
  elseif  flag == DOM_W_DEG
  then    dom_w_deg
  elseif  flag == FIRST_FAIL
  then    first_fail
  elseif  flag == IMPACT
  then    impact
  elseif  flag == INPUT_ORDER
  then    input_order
  elseif  flag == LARGEST
  then    largest
  elseif  flag == MAX_REGRET
  then    max_regret
  elseif  flag == MOST_CONSTRAINED
  then    most_constrained
  elseif  flag == OCCURRENCE
  then    occurrence
%   elseif  flag == RANDOM
%   then    random% !! for GECODE
%   elseif  flag == RANDOM_ORDER
%   then    random_order % !! for Chuffed
  elseif  flag == SMALLEST
  then    smallest
  else    input_order
  endif;


%% VALUE HEURISTICS
% See https://www.minizinc.org/doc-2.6.4/en/lib-stdlib-annotations.html?highlight=restart#value-choice-annotations
enum H_VAL = {
  INDOMAIN,
  INDOMAIN_INTERVAL,
  INDOMAIN_MAX,
  INDOMAIN_MEDIAN,
  INDOMAIN_MIDDLE,
  INDOMAIN_MIN,
  INDOMAIN_RANDOM,
  INDOMAIN_REVERSE_SPLIT,
  INDOMAIN_SPLIT,
  INDOMAIN_SPLIT_RANDOM,
  OUTDOMAIN_MAX,
  OUTDOMAIN_MEDIAN,
  OUTDOMAIN_MIN,
  OUTDOMAIN_RANDOM
};


% values:    indomain | indomain_interval | indomain_max | indomain_median | indomain_middle | indomain_min | indomain_random | indomain_reverse_split | indomain_split | indomain_split_random | outdomain_max | outdomain_median | outdomain_min | outdomain_random
function ann: heuristic_domain(H_VAL: flag) =
  if      flag == INDOMAIN
  then    indomain
  elseif  flag == INDOMAIN_INTERVAL
  then    indomain_interval
  elseif  flag == INDOMAIN_MAX
  then    indomain_max
  elseif  flag == INDOMAIN_MEDIAN
  then    indomain_median
  elseif  flag == INDOMAIN_MIDDLE
  then    indomain_middle
  elseif  flag == INDOMAIN_MIN
  then    indomain_min
  elseif  flag == INDOMAIN_RANDOM
  then    indomain_random
  elseif  flag == INDOMAIN_REVERSE_SPLIT
  then    indomain_reverse_split
  elseif  flag == INDOMAIN_SPLIT
  then    indomain_split
  elseif  flag == INDOMAIN_SPLIT_RANDOM
  then    indomain_split_random
  elseif  flag == OUTDOMAIN_MAX
  then    outdomain_max
  elseif  flag == OUTDOMAIN_MEDIAN
  then    outdomain_median
  elseif  flag == OUTDOMAIN_MIN
  then    outdomain_min
  elseif  flag == OUTDOMAIN_RANDOM
  then    outdomain_random
  else    indomain
  endif;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY

array[int] of string: SNL = ["\n"];
array[int] of string: STAB = ["\t"];
array[int] of string: SEP = ["**************************"];

%
function array[int] of string: show_size() =
			["Instance\t" ++ name]
	++  STAB
	++		["K=" ++ show(K)]
% 	++  STAB
	++  [" V=" ++ show(card(V)) ++ " ∆=" ++ show(max(degree)) ++ " (no/all=" ++ show(length(disconnected)) ++ "/" ++ show(length(cliqued)) ++ ")"]
% 	++  STAB
	++		[" density=" ++ show(round(100*density)) ++ "% "]
% 	++		STAB
	++		[" |W|=" ++ show(card(W)) ++ " (" ++ show(min(w)) ++ ",~" ++ show(round(sum(w)/card(V))) ++ "," ++ show(max(w)) ++ ")"]
	;

%
function array[int] of string: show_weights() =
	["w\t\t"] ++ [show(v) ++ "-" ++ show(w[v]) ++ " " | v in V];

%
function array[int] of string: show_neighbours() =
	["N\t"] ++ [show(v) ++ "-" ++ show(N[v]) ++ " " | v in V];

%	
function array[int] of string: show_cliques() =
	if(M_CLIQUES in WVCP_FEATURE)
	then	["Cliques\t\t" ++ show(C)]
	else [""]
	endif;

%
function array[int] of string: show_flags() =
			["Flags\t\t"]
	++		[show(WVCP_M)]
	++  STAB
	++		["[D-SORTED=" ++ show(D_SORTED) ++ "]"];

%
function array[int] of string: show_instance() =
			show_size()
%	++  SNL
% 	++		show_weights()
% 	++  SNL
% 	++		show_neighbours()
% 	++  SNL
% 	++		show_cliques()
;
