%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILE INCLUSION

include "../core/data.mzn";
include "../core/heuristics.mzn";
include "../core/instance_output.mzn";

include "../dual/dual_heuristics.mzn";
include "../dual/dual_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTANCE DATA

%% C is the complement graph of G
%% H is the digraph built from C by directing edges consistently with the dominance ordering

% nodes of H (excluding virtual vertices)
set of int: NODE = R_VERTEX;

% number of arcs in H (= number of edges in C)
int: nr_arcs = ((nr_vertices*(nr_vertices-1)) div 2) - ((sum(v in R_VERTEX)(card(neighbours[v]))) div 2);

% set of arcs in H
set of int: ARC = 1..nr_arcs;

% successors of each node in H
array[NODE] of set of NODE: successors = [{j | j in NODE where weight[j]<weight[i] \/ (weight[j]=weight[i] /\ j>i)} diff neighbours[i] | i in NODE];

% tail and head of each arc in H
array[ARC] of NODE: tail = [i | i in NODE, j in successors[i]];
array[ARC] of NODE: head = [j | i in NODE, j in successors[i]];

% incoming and outgoing arcs for each node
array[NODE] of set of ARC: outs = [{a | a in ARC where i=tail[a]} | i in NODE];
array[NODE] of set of ARC: ins = [{a | a in ARC where i=head[a]} | i in NODE];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% the arc (i,j) is kept in the dual solution iff y_arc[ij]=1
array[ARC] of var 0..1: y_arc;

% the score of the dual solution
var D_SCORE: y_score;

% [auxilliary variable] the WVCP score of the primal solution corresponding to the dual solution
var P_SCORE: yx_score;

% [auxilliary variable] the number of simplical stars in the dual solution
var W_R_VERTEX: y_stars;

% [auxilliary variable] the number of colors in the primal solution
var W_COLOR: yx_opened_colors;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS

% Constraint (11) in [Cornaz 2017]
% Two arcs with the same tail may be kept only if they form a simplicial pair of arcs
% Equivalent CP formulation with generator changed
constraint
forall(i in NODE, ij,ik in outs[i] where ij<ik /\ not(head[ik] in successors[head[ij]]) /\ not(head[ij] in successors[head[ik]]))(
  y_arc[ij] + y_arc[ik] <= 1
);


% Constraint (12) in [Cornaz 2017]
% Arcs cannot be chained in the dual solution
% Equivalent CP formulation
constraint
forall(j in NODE where ins[j]!={} /\ outs[j]!={})(
	sum(ij in ins[j])(y_arc[ij]) * sum(jk in outs[j])(y_arc[jk]) = 0 
);

% Constraint (13) in [Cornaz 2017]
% A node has at most one incoming arc in the dual solution
% Equivalent CP formulation
constraint
forall(j in NODE where ins[j]!={})(
	sum(ij in ins[j])(y_arc[ij]) <= 1 
);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCORE

% The score of the dual solution
constraint
y_score = sum(a in ARC)(weights[head[a]] * y_arc[a]);

% The score of the primal solution
constraint
yx_score = sum(weights) - y_score;

% The number of simplical stars in the dual solution
constraint
y_stars = count(u in NODE where outs[u]!={})(exists(a in outs[u])(y_arc[a] != 0));

% The number of colors in the primal solution
constraint
yx_opened_colors = y_stars + length(cliqued) + count(u in NODE diff array2set(cliqued))(forall(a in ins[u] union outs[u])(y_arc[a] = 0));
