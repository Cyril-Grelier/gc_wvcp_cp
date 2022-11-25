include "../core/data.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTANCE DATA

%% C is complementary graph of G
%% H is directed complementary graph of G

% nodes of H (excluding virtual vertices)
set of int: NODE = R_VERTEX;

% number of arcs of H (= number of edges of C)
int: nr_arcs = (nr_vertices*(nr_vertices-1) - sum(i in R_VERTEX)(card(neighbours[i]))) div 2;

% arcs of H
set of int: ARC = 1..nr_arcs;

% successors and predecessors in H
array[NODE] of set of NODE: successors = [{j | j in NODE where j>i} diff neighbours[i] | i in NODE];

% arc tails and heads
array[ARC] of NODE: tail = [i | i in NODE, j in successors[i]];
array[ARC] of NODE: head = [j | i in NODE, j in successors[i]];

% incoming/outgoing arcs per node
array[NODE] of set of ARC: outs = [{e | e in ARC where i=tail[e]} | i in NODE];
array[NODE] of set of ARC: ins = [{e | e in ARC where i=head[e]} | i in NODE];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% 
array[ARC] of var 0..1: y_arc;

%
var 0..sum(weight): y_score;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS

% Constraint (11) in [Cornaz 2017]
% Two arcs with the same tail may only be both active if they form a simplicial pair of arcs

% %%% Original MIP formulation
% constraint
% forall(uv,uw in ARC where uv<uw /\ tail[uv]=tail[uw] /\ not(head[uw] in successors[head[uv]]) /\ not(head[uv] in successors[head[uw]]))( 
% % forall(uv,uw in ARC where uv<uw /\ tail[uv]=tail[uw] /\ not(head[uw] in successors[head[uv]]))( % alternative correcte du fait de l'ordonnancement des arcs
%   y_arc[uv] + y_arc[uw] <= 1 
% );

%%% Equivalent MIP formulation with generator changed
constraint
forall(u in NODE, uv,uw in outs[u] where uv<uw /\ not(head[uw] in successors[head[uv]]) /\ not(head[uv] in successors[head[uw]]))(
  y_arc[uv] + y_arc[uw] <= 1 
);



% Constraint (12) in [Cornaz 2017]
% Every node either has active incoming arcs (i.e. is dominated), active outgoing arcs (i.e. is dominant), or neither (i.e. the node is disconnected).

%%% Original MIP formulation
% constraint
% forall(v in NODE, uv in ins[v], vw in outs[v])( 
%   y_arc[uv] + y_arc[vw] <= 1 
% );

%% CP formulation
constraint
forall(v in NODE)(
	sum(a in ins[v])(y_arc[a]) * sum(a in outs[v])(y_arc[a]) = 0 
);

% Constraint (13) in [Cornaz 2017]
% Every node has at most one active incoming arc (ie. one dominant node)

%%% Original MIP formulation
% constraint
% forall(v in NODE, tv,uv in ins[v] where tv<uv)( 
%   y_arc[tv] + y_arc[uv] <= 1 
% );

%% CP formulation
constraint
forall(v in NODE where ins[v]!={})(
	sum(a in ins[v])(y_arc[a]) <= 1 
);


% Cost of MWSSP
constraint
y_score = sum(e in ARC)(weight[head[e]]*y_arc[e]);


% BKS for WVCP as LB for WSSP
constraint
if (UB_SCORE in WVCP_BOUNDS)
then (y_score >= sum(weight) - ub_score)
endif;
