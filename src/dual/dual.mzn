%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILE INCLUSION

include "../core/data.mzn";
include "../core/heuristics.mzn";
include "../core/instance_output.mzn";

include "../dual/dual_heuristics.mzn";
include "../dual/dual_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTANCE DATA

%% C is complementary graph of G
%% H is directed complementary graph of G

% nodes of G (excluding virtual vertices)
set of int: NODE = R_VERTEX;

% number of arcs (= number of edges of C)
int: nr_arcs = ((nr_vertices*(nr_vertices-1)) div 2) - ((sum(v in R_VERTEX)(card(neighbours[v]))) div 2);

% set of arcs
set of int: ARC = 1..nr_arcs;

% successors of nodes by orientating each arc by decreasing weights (!! mandatory)
array[NODE] of set of NODE: successors = [{j | j in NODE where weight[j]<weight[i] \/ (weight[j]=weight[i] /\ j>i)} diff neighbours[i] | i in NODE];

% arc tails and heads
% !! ARC is implicitly defined by the tail/head generators which must be identical
array[ARC] of NODE: tail = [i | i in NODE, j in successors[i]];
array[ARC] of NODE: head = [j | i in NODE, j in successors[i]];

% incoming/outgoing arcs per node
array[NODE] of set of ARC: outs = [{a | a in ARC where i=tail[a]} | i in NODE];
array[NODE] of set of ARC: ins = [{a | a in ARC where i=head[a]} | i in NODE];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% an arc ij is active (y_arc[ij]=1) or not (y_arc[ij]=0)
array[ARC] of var 0..1: y_arc;

% score of the solution to the MWSSP instance
var 0..sum(weights): y_score;

% (auxilliary) WVCP score inferred from the MWSSP solution
var 0..sum(weights): yx_score;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS

% Constraint (11) in [Cornaz 2017]
% Two arcs with the same tail may be active only if they form a simplicial pair of arcs

% %%% Original MIP formulation
% constraint
% forall(ij,ik in ARC where ij<ik /\ tail[ij]=tail[ik] /\ not(head[ik] in successors[head[ij]]) /\ not(head[ij] in successors[head[ik]]))( 
% % forall(ij,ik in ARC where ij<ik /\ tail[ij]=tail[ik] /\ not(head[ik] in successors[head[ij]]))( % alternative correcte du fait de l'ordonnancement des arcs
%   y_arc[ij] + y_arc[ik] <= 1 
% );

%%% Equivalent MIP formulation with generator changed
constraint
forall(i in NODE, ij,ik in outs[i] where ij<ik /\ not(head[ik] in successors[head[ij]]) /\ not(head[ij] in successors[head[ik]]))(
  y_arc[ij] + y_arc[ik] <= 1
);


% Constraint (12) in [Cornaz 2017]
% Every node either has active incoming arcs (i.e. is dominated), active outgoing arcs (i.e. is dominant), or neither (i.e. the node is disconnected).

%%% Original MIP formulation
% constraint
% forall(j in NODE, ij in ins[j], jk in outs[j])( 
%   y_arc[ij] + y_arc[jk] <= 1 
% );

%% CP formulation
constraint
forall(j in NODE)(
	sum(ij in ins[j])(y_arc[ij]) * sum(jk in outs[j])(y_arc[jk]) = 0 
);

% Constraint (13) in [Cornaz 2017]
% Every node has at most one active incoming arc (ie. one dominant node)

%%% Original MIP formulation
% constraint
% forall(j in NODE, hj,ij in ins[j] where hj<ij)( 
%   y_arc[hj] + y_arc[ij] <= 1 
% );

%% CP formulation
constraint
forall(j in NODE where ins[j]!={})(
	sum(ij in ins[j])(y_arc[ij]) <= 1 
);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COST

% Cost of MWSSP
constraint
y_score = sum(a in ARC)(weights[head[a]] * y_arc[a]);% + sum(j in NODE)(x_d[j] * weights[j]);

% Cost of WVCP
constraint
yx_score = sum(weights) - y_score;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % AUXILLIARY

% % (auxilliary) a node j is active (x_node[j]=1) iff at least one of its arcs is active
% array[NODE] of var 0..1: x_node;

% % (auxilliary) disconnected node
% array[NODE] of var 0..1: x_d;

% % (auxilliary) connected inactive node
% array[NODE] of var 0..1: x_ci;

% % (auxilliary) connected active start leaf node
% array[NODE] of var 0..1: x_cal;

% % (auxilliary) connected active start center node
% array[NODE] of var 0..1: x_cac;

% % (auxilliary) Every disconnected node is disabled.
% constraint
% forall(i in index_set(fully_connected) where trace("DISCO-"++show(i)++" ", i in index_set(fully_connected)))(
% 	x_node[fully_connected[i]] = 0
% );

% % (auxilliary) A connected node is active iff at least one of its arcs is active
% constraint
% forall(u in NODE where not(v in fully_connected))(
% 	x_node[u] = max(a in ins[u] union outs[u])(y_arc[a])
% );

% % (auxilliary) number of active dominated nodes
% constraint
% forall(u in NODE)(
% 	x_d[u] + x_ci[u] + x_cal[u] + x_cac[u] = 1
% );

% % (auxilliary) disconnected nodes
% constraint
% forall(i in index_set(fully_connected))(
% 	x_d[fully_connected[i]] = 1 - x_node[fully_connected[i]]
% );

% % (auxilliary) connected inactive nodes
% constraint
% forall(u in NODE where not(u in fully_connected))(
% 	x_ci[u] = 1 - x_node[u]
% );

% % (auxilliary) connected active star leaf nodes
% constraint
% forall(u in NODE where ins[u] != {})(
% 	x_cal[u] = x_node[u] * max(a in ins[u])(y_arc[a])
% );

% % (auxilliary) connected active star center nodes
% constraint
% forall(u in NODE where outs[u] != {})(
% 	x_cac[u] = x_node[u] * max(a in outs[u])(y_arc[a])
% );
