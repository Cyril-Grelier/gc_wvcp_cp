%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Lesaint (david.lesaint@univ-angers.fr)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FILE INCLUSION

include "../core/core.mzn";
include "../primal/max_left_shift.mzn";
include "../primal/left_shift.mzn";
include "../primal/primal_aux.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRIMAL DATA

%% EXTENDED GRAPH

% range of virtual vertices X (X == |V|+1..|V|+|K|): one virtual vertex per color
set of int: X = max(V)+1..max(V)+card(K);

% range of all real and virtual vertices U (U == V \cap X)
set of int: U = min(V)..max(X);

% neighborhood function N_U: virtual vertices are disconnected
array[U] of set of U: N_U = N ++ [{} | u in X];


%% EXTENDED WEIGHTED GRAPH
% weight function w_U: virtual vertices have weight 0
array[U] of int: w_U = w ++ [0 | u in X];

% set of real/virtual vertex weights W_U
set of int: W_U = array2set(w_U);


%% EXTENDED DEGREE
array[U] of int: degree_U = [card(N_U[u]) | u in U];


%% EXTENDED DOMINANCE ORDERING
% checks whether u strictly dominates v
function bool: dominates_U(U: u, U: v) =
	if D_SORTED
	then
		u<v
	else
		(w_U[u]>w_U[v]) \/ (w_U[u]=w_U[v] /\ u<v)
	endif;

% dominant vertex in A
%% par version
U: dominant_U(set of U: A) =
	if		D_SORTED
	then
		min(A)
	else
		let {
			array[int] of U: B = dominance_sort_U(A);
		} in
		B[min(index_set(B))]
	endif;

% sorts vertices of A in descending order of weights
array[int] of U: dominance_sort_U(set of U: A) =
	if		D_SORTED
	then
		set2array(A)
	else
		let {
			array[int] of U: s2a = set2array(A);
			% sort in descending order of weights
			array[index_set(s2a)] of U: as = arg_sort([-w[s2a[i]] | i in index_set(s2a)]);
		} in
		array1d(index_set(s2a), [s2a[as[i]] | i in index_set(as)])
	endif;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRIMAL CONSTRAINTS

%% (P1) the WVCP solution score
var P_SCORE: x_o;

%% (P2) the color of each vertex
array[U] of var K: x_U;

%% (P3) the vertices of each color
array[K] of var set of U: x_K;

%% (P4) the dominant vertex of each color
array[K] of var U: x_D;

%% (P5) channeling constraint between color and vertex variables
include "int_set_channel.mzn";
constraint
	int_set_channel(x_U, x_K) :: domain;

%% (P6) fixed coloring of virtual vertices: one virtual vertex per color
constraint
	forall(u in X)( 
		x_U[u] = u - min(X) + 1
	);

%% (P7) coloring constraints.
% (a) if M_CLIQUES is off, modeled as binary disequalities
% (b) else like (a) except for cliques which are enforced by all-different constraints
include "alldifferent.mzn";
constraint
	if not(M_CLIQUES in WVCP_M)
	then % (a)
		forall(v in V, u in N_U[v] where u<v)(
			(x_U[u] != x_U[v]) :: domain
		)
	else % (b)
		% binary coloring constraints disabled for edges in cliques
		forall(v in V, u in N_U[v] where u<v /\ not(exists(c in index_set(C))({u,v} subset C[c])))(
			(x_U[u] != x_U[v]) :: domain
		)
		/\
		% clique coloring constraints
		forall(c in index_set(C))(
			alldifferent([x_U[v] | v in C[c]]) :: domain
		)
	endif;

%% (P8) dominant vertex of a color
% (a) if D_SORTED is on, uses min constraint
% (b) else uses arg_max constraint
include "arg_max.mzn";
constraint
	if D_SORTED
	then % (a)
		forall(k in K)(
			x_D[k] = min(x_K[k]) :: domain
		)
	else % (b)
		let {
			array[U] of U: sorted_U = array1d(U, dominance_sort_U(V) ++ set2array(X));
		} in
		forall(k in K)(
			x_D[k] = sorted_U[arg_max([sorted_U[i] in x_K[k] | i in U])]
		)
	endif;

%% (P9a) Auxiliary variables (omitted in IJCAI model - serves for search strategy WEIGHTS and reformulations)
% the weight of each color
array[K] of var W_U: x_KW;

%% (P9b) the weight of a color is the weight of its dominant
constraint
	forall(k in K)(
		x_KW[k] = w_U[x_D[k]] :: domain
	);

%% (P9c) the score is the sum of the weights of the color dominants
constraint
	x_o = sum(x_KW) :: domain
;

%% (P10) dominance ordering on colors
% (a) if D_SORTED is on, uses strictly_increasing
% (b) else uses lex_chain_greater
include "lex_chain_greater.mzn";
include "strictly_increasing.mzn";
constraint
	if D_SORTED
	then % (a)
		strictly_increasing(x_D) :: bounds
	else % (b) 
		lex_chain_greater(array2d(1..2, K, x_KW ++ [max(U) - x_D[k] | k in K]))
	endif;

%% (P11) solution compactness based on MAX_LEFT_SHIFT. Switched on by M_MLS or M_MLS_v2.
constraint
	if M_MLS in WVCP_M
	then
		forall(v in V)(
			max_left_shift_v1(x_U[v], [x_U[u] | u in N[v]])
		)
	elseif M_MLS_v2 in WVCP_M
	then
		max_left_shift_v2_global()
	else
		true
 	endif;

%% (J4) solution compactness using LEFT_SHIFT. Switched on by M_LS
% !! does not entail coloring constraints (P7)
% (J4) /\ (P7) <-> (P11)
constraint
	if M_LS in WVCP_M
	then
		forall(v in V)(
			left_shift(v)
		)
	endif;

%% (J5) static upper bound on vertex color equivalent to Reduction Rule R2. Switched on by M_R2
% useless on pre-reduced instances with R2 or if (J4) is enforced
constraint
	if M_R2 in WVCP_M
	then
		forall(v in V)(
			R2(v)
		)
	endif;


%%% ADDITIONAL DOMAIN BOUND CONSTRAINTS

%% (P12) static lower bound on number of colors (omitted in IJCAI model - note that static upper bound is directly enforced in definition of K)

% whether a color includes a real vertex (color is "opened") or not
array[K] of var bool: x_KO;
constraint x_KO = [(card(x_K[k]) > 1) :: domain | k in K];

% the number of opened colors
var lb_colors..ub_colors: x_KOS;
constraint x_KOS = sum(x_KO) :: bounds;

%% (P13) upper bound on number of colors based on Corollary 1. Entailed by (P11). Switched on by M_DG or M_MLS or M_LS.
% Enforces s(v) <= ∆(v) + 1 for each vertex v.
constraint
	if M_DG in WVCP_M \/ M_MLS in WVCP_M \/ M_MLS_v2 in WVCP_M \/ M_LS in WVCP_M
	then
		forall(v in V) (
			x_U[v] <= degree[v] + 1
		)
	endif;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRIMAL SEARCH


%% SEARCH STRATEGIES

% Example of command line fragment to set the strategy
% -D "PRIMAL_STRATEGY=VERTICES_GENERIC"         -D "PRIMAL_RESTART=RESTART_NONE" \
% -D "PRIMAL_H_VAR_COLORS=INPUT_ORDER"          -D "PRIMAL_H_VAL_COLORS=INDOMAIN_SPLIT" \
% -D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER"         -D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" \
% -D "PRIMAL_H_VAR_VERTICES=WVCPSV(FIRST_FAIL)" -D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" \

% Search strategy (enum) to use on the command line
PRIMAL_SEARCH: PRIMAL_STRATEGY;

% Cases for primal search strategy to set on the command line
enum PRIMAL_SEARCH = {
  VERTICES_GENERIC,			% branching on vertex variables using
  											% 		generic CP heuristics for variables (based on PRIMAL_H_VAR_VERTICES) 
  											%		generic CP heuristics for values (based on PRIMAL_H_VAL_VERTICES)
  											
  VERTICES_SPECIFIC,		% branching on vertex variables using
  											%		WVCP-specific static heuristics (graph- or weight-based) for variables (based on PRIMAL_H_VAR_VERTICES)
  											%		generic CP heuristics for values (based on PRIMAL_H_VAL_VERTICES)
  											
  VERTICES_BY_WEIGHT,		% branching on vertex variables by descending order of weight using
  											%		generic CP heuristics (based on PRIMAL_H_VAR_VERTICES) to discriminate between vertices of the same weight
  											%		generic CP heuristics for values (based on PRIMAL_H_VAL_VERTICES)
  											
  COLORS,							% branching on the number of colors (single variable) using 
  											%		generic CP heuristics for values (based on PRIMAL_H_VAL_COLORS) 
  											%		then on vertex variables using 
  											% 		generic CP heuristics for variables (based on PRIMAL_H_VAR_VERTICES) 
  											%		generic CP heuristics for values (based on PRIMAL_H_VAL_VERTICES)
  											
  WEIGHTS,							% branching on weight-valued color variables using 
  											%		generic CP heuristics (based on PRIMAL_H_VAR_WEIGHTS)
  											%		then on vertex variables using 
  											% 		generic CP heuristics for variables (based on PRIMAL_H_VAR_VERTICES) 
  											%		generic CP heuristics for values (based on PRIMAL_H_VAL_VERTICES) 
};

% Primal search strategy
function ann: wvcp_search() =
  if      PRIMAL_STRATEGY == VERTICES_GENERIC
  then    int_search(x_U[V], wvcp_heuristic_variables(PRIMAL_H_VAR_VERTICES), heuristic_domain(PRIMAL_H_VAL_VERTICES))
  
  elseif  PRIMAL_STRATEGY == VERTICES_SPECIFIC
  then    int_search(sort_vertex_variables(), input_order, heuristic_domain(PRIMAL_H_VAL_VERTICES))

  elseif  PRIMAL_STRATEGY == VERTICES_BY_WEIGHT
  then    seq_search(split_vertices_by_weight(W_V))

  elseif  PRIMAL_STRATEGY == COLORS
  then    seq_search(
            [int_search([x_KOS], heuristic_variables(PRIMAL_H_VAR_COLORS), heuristic_domain(PRIMAL_H_VAL_COLORS)),
            int_search(x_U[V], wvcp_heuristic_variables(PRIMAL_H_VAR_VERTICES), heuristic_domain(PRIMAL_H_VAL_VERTICES))]
          )
            
  elseif  PRIMAL_STRATEGY == WEIGHTS
  then    seq_search(
            [int_search(x_KW, heuristic_variables(PRIMAL_H_VAR_WEIGHTS), heuristic_domain(PRIMAL_H_VAL_WEIGHTS)),
            int_search(x_U[V], wvcp_heuristic_variables(PRIMAL_H_VAR_VERTICES), heuristic_domain(PRIMAL_H_VAL_VERTICES))]
          )
  
  else    int_search(x_U[V], input_order, indomain)
  endif;


%% VARIABLE HEURISTICS

% Variable heuristics (enums) to use on the command line
PRIMAL_H_VAR: PRIMAL_H_VAR_VERTICES;
H_VAR: PRIMAL_H_VAR_WEIGHTS;
H_VAR: PRIMAL_H_VAR_COLORS;

% Cases for primal vertex variable heuristics to set on the command line
enum PRIMAL_H_VAR = 
	WVCPSV(H_VAR) 
	++
	{
	% static WVCP-specific heuristics (!! may only be used with strategy VERTICES_SPECIFIC)
			DESC_DEGREE, 				% sort vertex variables in descending order of vertex degree
			DESC_WEIGHT, 				% sort vertex variables in descending order of vertex weight
			DESC_WEIGHT_DEGREE, 	% sort vertex variables in descending order of vertex weight breaking ties by descending order of vertex degree
			ASC_WEIGHT_DIFF			% TODO - not implemented
	};

%
function ann: wvcp_heuristic_variables(PRIMAL_H_VAR: flag) =
  heuristic_variables(WVCPSV^-1(flag));
  
%
function array[int] of var K: sort_vertex_variables() = 
  let {
  		array[V] of V: permutation = array1d(V,sort_vertices(set2array(V)));
  } in
  	[x_U[permutation[i]] | i in V];

%
function array[int] of V: sort_vertices(array[int] of V: A) = 
  if      PRIMAL_H_VAR_VERTICES == DESC_WEIGHT
  then    sort_by(A,[-w[A[i]] | i in index_set(A)])
  
  elseif  PRIMAL_H_VAR_VERTICES == DESC_DEGREE
  then    sort_by(A,[-degree[A[i]] | i in index_set(A)])
  
  elseif  PRIMAL_H_VAR_VERTICES == DESC_WEIGHT_DEGREE
  then    sort_by(A,[-card(V)*w[A[i]] - degree[A[i]] | i in index_set(A)])
  
  else    A
  endif;

%
function array[int] of ann: split_vertices_by_weight(array[int] of set of V: wV) =
	[int_search([x_U[i] | i in wV[min(index_set(wV))]], wvcp_heuristic_variables(PRIMAL_H_VAR_VERTICES), heuristic_domain(PRIMAL_H_VAL_VERTICES))]
	++
  if card(index_set(wV)) == 1
  then
  		[]
  	else
		split_vertices_by_weight(wV[min(index_set(wV))+1..max(index_set(wV))])
  endif;


%% VALUE HEURISTICS

% Value heuristics (enums) to use on the command line
H_VAL: PRIMAL_H_VAL_VERTICES;
H_VAL: PRIMAL_H_VAL_WEIGHTS;
H_VAL: PRIMAL_H_VAL_COLORS;


%% RESTART STRATEGY

% Restart strategy (enums) to use on the command line
RESTART: PRIMAL_RESTART;

%
function ann: wvcp_restart() =
  let {
    par int: scale = card(V); %TODO not tested/tuned
    float: base = 1.5;
  } in
  	restart(PRIMAL_RESTART, scale, base);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY

%%
function array[int] of string: show_wvcp_strategy() =
			["Primal strategy"]
	++		STAB
	++		[show(PRIMAL_STRATEGY)] ++ STAB ++ [show(PRIMAL_RESTART)]
	;

%%
function array[int] of string: show_wvcp_heuristics() =
			["Primal heurist."]
	++		STAB	++	["VERTICES"] ++	STAB ++ [show(PRIMAL_H_VAR_VERTICES)
	++ " / " ++ show(PRIMAL_H_VAL_VERTICES)]
	++		SNL
	++		STAB	++	STAB	++	["WEIGHTS "] ++ STAB ++ [ show(PRIMAL_H_VAR_WEIGHTS)
	++ " / " ++ show(PRIMAL_H_VAL_WEIGHTS)]
	++		SNL
	++		STAB	++	STAB	++	["COLORS  "] ++ STAB ++ [ show(PRIMAL_H_VAR_COLORS) ++ " / "
	++ show(PRIMAL_H_VAL_COLORS)]
	;

%%
function array[int] of string: show_wvcp_solution() =
			["Primal solution"]
	++		STAB
	++		["Coloring"] ++ STAB ++ [show(v) ++ "=" ++ show(x_U[v]) ++ " " | v in V]
	++		SNL
	++		STAB	++	STAB
	++  ["Partitioning"] ++ STAB ++ [show(k) ++ "=" ++ show(x_K[k]) ++ " " | k in K where fix(x_KO[k])]
	++  SNL
	++		STAB	++	STAB
	++  ["Weighting"] ++ STAB ++ [show(k) ++ "=" ++ show(x_KW[k]) ++ " " | k in K where fix(x_KO[k])]
	;

%%
function array[int] of string: show_wvcp_score() =
			["WVCP score"]
	++		STAB
	++		[show(x_o)] ++ STAB ++ STAB ++ [show(lb_score) ++ " <= " ++ show(x_o) ++ " <= " ++ "ub=" ++ show(ub_score) ++ " <= " ++ "sum(w)=" ++ show(sum(w))]
	++  SNL
	++		STAB	++	STAB
	++		[show(x_KOS) ++ " colors"] ++ STAB ++ [show(lb_colors) ++ " <= " ++ show(x_KOS) ++ " <= " ++ "ub=" ++ show(card(K))]
	;

%%
function array[int] of string: show_wvcp_metrics() =
			["Primal compact."]
	++		STAB
 	++  [if(M_DG in WVCP_M) then show(M_DG) else "!(M_DG)}" endif ++ "="] ++ [show(check_vertices_positioning())]
	++		STAB
	++  [if(M_MLS in WVCP_M) then show(M_MLS) else "!(M_MLS)" endif ++ "="] ++ [show(check_vertices_compactness())]
	++		STAB
	++  [if(M_LS in WVCP_M) then show(M_LS) else "!(M_LS)" endif]
	++		STAB
	++  [if(M_R2 in WVCP_M) then show(M_R2) else "!(M_R2)" endif ++ "="] ++ [show(check_R2())]
	;
	
%% COMPACTNESS METRICS
% number of vertices v colored beyond ∆(v)+1
function array[1..2] of int: check_vertices_positioning() =
	let {
		array[V] of 0..max(K): gaps = [if fix(x_U[v]) <= degree[v] + 1 then 0 else fix(x_U[v]) - (degree[v] + 1) endif | v in V];
	} in
	[max(gaps), count(v in V)(gaps[v]>0)];


% number of vertices v colored beyond lowest possible color
function array[1..2] of int: check_vertices_compactness() =
	let {
		array[V] of 0..max(K): gaps = [if fix(x_U[v])=1 then 1 else arg_min(i in 1..fix(x_U[v])-1)(exists(u in N[v])(fix(x_U[u]) == i)) endif | v in V];
	} in
	[max(gaps) - 1, count(v in V)(gaps[v]>1)];
