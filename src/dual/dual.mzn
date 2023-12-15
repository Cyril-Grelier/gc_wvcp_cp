%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Lesaint (david.lesaint@univ-angers.fr)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FILE INCLUSION

include "../core/core.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DUAL DATA

% MWSSP SCORE

% domain for MWSSP score
set of int: D_SCORE = sum(w)-max(P_SCORE)..sum(w)-min(P_SCORE);

%% C(G) is the complement graph of G
%% H is the digraph built from C(G) by directing edges consistently with the dominance ordering

% nodes of H
set of int: NODE = V;

% number of arcs in H (= number of edges in C(G))
int: nr_arcs = ((nr_vertices*(nr_vertices-1)) div 2) - ((sum(v in V)(degree[v])) div 2);

% set of arcs in H
set of int: ARC = 1..nr_arcs;

% successors of each node in H
array[NODE] of set of NODE: successors = [{j | j in NODE where dominates(i,j)} diff N[i] | i in NODE];

% tail and head of each arc in H
array[ARC] of NODE: tail = [i | i in NODE, j in successors[i]];
array[ARC] of NODE: head = [j | i in NODE, j in successors[i]];

% incoming and outgoing arcs for each node
array[NODE] of set of ARC: outs = [{a | a in ARC where i=tail[a]} | i in NODE];
array[NODE] of set of ARC: ins = [{a | a in ARC where i=head[a]} | i in NODE];

% source nodes in H
set of NODE: S = {i | i in NODE where outs[i]!={}};
% target nodes in H
set of NODE: T = {i | i in NODE where ins[i]!={}};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRIMAL CONSTRAINTS

%% (D1) the arc (i,j) is kept in the dual solution iff y_arc[ij]=1
array[ARC] of var 0..1: y_A;

%% (D2) the score of the dual solution
var D_SCORE: y_o;

%% (D2a) auxilliary variables used for reformulation (omitted in IJCAI model)
array[NODE] of var 0..1: z_S;
constraint
		forall(j in S)(
			z_S[j] = max(jk in outs[j])(y_A[jk])
		)
	/\
		forall(j in NODE diff S)(
			z_S[j] = 0
		)
;

%% (D2b) auxilliary variables used for reformulation (omitted in IJCAI model)
% entails (D6)
% !! uses sum instead of max !!
array[NODE] of var 0..1: z_T;
constraint
		forall(j in T)(
			z_T[j] = sum(ij in ins[j])(y_A[ij])
		)
	/\
		forall(j in NODE diff T)(
			z_T[j] = 0
		)
;

%% (D3) The score of the dual solution
constraint
	y_o = sum(a in ARC)(w[head[a]] * y_A[a]);


%% (D4) Constraint (11) in [Cornaz 2017]
% Two arcs with the same tail may be kept only if they form a simplicial pair of arcs
% Equivalent CP formulation with generator changed
constraint
	forall(i in S, ij,ik in outs[i] where ij<ik /\ not(head[ik] in successors[head[ij]]) /\ not(head[ij] in successors[head[ik]]))(
		y_A[ij] + y_A[ik] <= 1
	);


%% (D5) Constraint (12) in [Cornaz 2017]
% Arcs cannot be chained in the dual solution
% Equivalent CP formulation
constraint
	forall(j in S intersect T)(
		z_T[j] * z_S[j] = 0 
	);

%% (D6) Constraint (13) in [Cornaz 2017]
% A node has at most one incoming arc in the dual solution
% Equivalent CP formulation made redundant by (D2b)
% constraint
% 	forall(j in T)(
% 		z_T[j] <= 1 
% 	);

%% (D7) whether node is dominant (z_V=1) or not (z_V=0)
array[V] of var 0..1: z_V;

%% (D8) a target node in H is dominant iff it is not the target of any arc in the solution
constraint
	forall(j in T)( 
		z_V[j] = 1 - z_T[j]
	); 

%% (D8a) redundant constraint (omitted in IJCAI model - makes a difference!)
constraint
	forall(j in S)(
		z_V[j] >= z_S[j]
	);

%% (D9) a node that is not a target in H cannot be dominated
constraint
	forall(j in NODE diff T)( 
		z_V[j] = 1
	);

%% (D10) the number of dominants is upper bounded by the maximum number of colors |K|
var K: y_KOS;
constraint
	y_KOS = sum(z_V);


%%% ADDITIONAL CONSTRAINTS

%% (D11) the number of dominants is lower bounded by input parameter `lb_colors` (omitted in IJCAI model)
constraint
	y_KOS >= lb_colors;

%% (D12) [auxiliary variable for display] the WVCP score of the primal solution corresponding to the dual solution
var P_SCORE: yx_o;
constraint
	sum(w) = yx_o + y_o;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DUAL SEARCH


%% SEARCH STRATEGIES

% Example of command line fragment to set the strategy
% -D "DUAL_STRATEGY=ARCS_SPECIFIC"			-D "DUAL_RESTART=RESTART_NONE" \
% -D "DUAL_H_VAR_ARCS=DESC_WEIGHT_TAIL"	-D "DUAL_H_VAL_ARCS=INDOMAIN_MAX" \


% Search strategy (enum) to use on the command line
DUAL_SEARCH: DUAL_STRATEGY;


% Cases for primal search strategy to set on the command line
enum DUAL_SEARCH = {
  ARCS_GENERIC,	% branching on arc variables using
  								% 		generic CP heuristics for variables (based on DUAL_H_VAR_ARCS) 
  								%		generic CP heuristics for values (based on DUAL_H_VAL_ARCS)
  								
  ARCS_SPECIFIC	% branching on arc variables using
  								%		MWSSP-specific static heuristics (digraph- or weight-based) for variables (based on DUAL_H_VAR_ARCS)
  								%		generic CP heuristics for values (based on DUAL_H_VAL_ARCS)

};

% Dual search strategy
function ann: mwssp_search() =
  if      DUAL_STRATEGY == ARCS_GENERIC
  then    int_search(y_A, mwssp_heuristic_variables(DUAL_H_VAR_ARCS), heuristic_domain(DUAL_H_VAL_ARCS))

  elseif  DUAL_STRATEGY == ARCS_SPECIFIC
  then    int_search(sort_arc_variables(), input_order, heuristic_domain(DUAL_H_VAL_ARCS))

  else    int_search(y_A, input_order, indomain)
  endif;


%% VARIABLE HEURISTICS

% Variable heuristics (enums) to use on the command line
DUAL_H_VAR: DUAL_H_VAR_ARCS;

% Cases for dual vertex variable heuristics to set on the command line
enum DUAL_H_VAR = 
	MWSSPSV(H_VAR)
	++
	{
	% static MWSSP-specific heuristics (!! may only be used with strategy ARCS_SPECIFIC)
			DESC_DEGREE_TAIL,  % sort arc variables in descending order of tail node degrees (in original graph)
			DESC_TAIL,         % sort arc variables in descending order of tail node weights breaking ties by descending order of  tail node degrees (in original graph)
			DESC_WEIGHT_TAIL,  % sort arcs in descending order of tail node weights
			ASC_WEIGHT_GAP			% sort arcs in ascending order of gaps between weights of their two nodes
};

%
function ann: mwssp_heuristic_variables(DUAL_H_VAR: flag) =
  heuristic_variables(MWSSPSV^-1(flag));

%
function array[int] of var 0..1: sort_arc_variables() = 
  let {
  array[index_set(y_A)] of index_set(y_A): permutation = array1d(index_set(y_A),sort_arcs(set2array(index_set(y_A))));
  } in
  [y_A[permutation[i]] | i in index_set(permutation)];

%
function array[int] of int: sort_arcs(array[int] of int: A) = 
  if      DUAL_H_VAR_ARCS == DESC_WEIGHT_TAIL
  then    sort_by(A,[-w[tail[A[i]]] | i in index_set(A)])
  
  elseif  DUAL_H_VAR_ARCS == DESC_DEGREE_TAIL
  then    sort_by(A,[-degree[tail[A[i]]] | i in index_set(A)])
  
  elseif  DUAL_H_VAR_ARCS == DESC_TAIL
  then    sort_by(A,[-card(NODE)*w[tail[A[i]]] - degree[tail[A[i]]] | i in index_set(A)])
  
  elseif  DUAL_H_VAR_ARCS == ASC_WEIGHT_GAP
  then    sort_by(A,[(w[tail[A[i]]] - w[head[A[i]]]) | i in index_set(A)])
  
  else    A
  endif;


%% VALUE HEURISTICS

% Value heuristics (enums) to use on the command line
H_VAL: DUAL_H_VAL_ARCS;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESTART STRATEGY

% Restart strategy (enums) to use on the command line
RESTART: DUAL_RESTART;


%
function ann: mwssp_restart() =
  let {
    par int: scale = card(ARC); %TODO not tested/tuned
    float: base = 1.5;
  } in
  restart(DUAL_RESTART,scale,base);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY

%%
function array[int] of string: show_mwssp_strategy() =
	["Dual strategy"]
	++		STAB
	++	[show(DUAL_STRATEGY) ++ ""] ++ STAB ++ STAB ++ [ show(DUAL_RESTART)]
	;

%%
function array[int] of string: show_mwssp_heuristics() =
	["Dual heurist."]
	++	STAB	++			["ARCS    "] ++ STAB ++ [ show(DUAL_H_VAR_ARCS) ++ " / " ++ show(DUAL_H_VAL_ARCS)]
	;

%%
function array[int] of string: show_mwssp_solution() =
	["Dual solution"]
	++		STAB
	++ ["Stars"] ++ STAB ++ STAB ++ [if fix(y_A[e])=1 then "(" ++ show(tail[e]) ++ "," ++ show(head[e]) ++ ") " else "" endif | e in ARC]
% 	++		SNL
% 	++		STAB	++	STAB	++  ["(" ++ show(tail[e]) ++ "," ++ show(head[e]) ++ ") " | e in sort_arcs(set2array(index_set(ARC)))]
	;

%%
function array[int] of string: show_mwssp_score() =
			["WVCP score"]
	++		STAB
	++		[show(yx_o)] ++ STAB ++ STAB ++ [show(lb_score) ++ " <= " ++ show(yx_o) ++ " <= " ++ "ub=" ++ show(ub_score) ++ " <= " ++ "sum(w)=" ++ show(sum(w))]
	++  SNL
	++		STAB	++	STAB
	++		[show(y_KOS) ++ " colors"] ++ STAB ++ [show(lb_colors) ++ " <= " ++ show(y_KOS) ++ " <= " ++ "ub=" ++ show(card(K))]
	;
