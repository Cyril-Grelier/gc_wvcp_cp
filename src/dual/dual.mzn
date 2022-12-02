include "../core/data.mzn";


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

% disconnected nodes
% !! disconnected nodes are necessarily connected to all vertices of G and individually contribute to the cost of any WVCP solution
set of NODE: disconnected = {j | j in NODE where ins[j] union outs[j] = {}};


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

% BKS for WVCP as LB for WSSP
constraint
if (UB_SCORE in WVCP_BOUNDS)
then (y_score >= sum(weights) - ub_score)
endif;

% Cost of WVCP
constraint
yx_score = sum(weights) - y_score;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUXILLIARY

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
% forall(j in disconnected where trace("DISCO-"++show(j)++" ", j in disconnected))(
% 	x_node[j] = 0
% );

% % (auxilliary) A connected node is active iff at least one of its arcs is active
% constraint
% forall(j in NODE where not(j in disconnected))(
% 	x_node[j] = max(a in ins[j] union outs[j])(y_arc[a])
% );


% % (auxilliary) number of active dominated nodes
% constraint
% forall(j in NODE)(
% 	x_d[j] + x_ci[j] + x_cal[j] + x_cac[j] = 1
% );

% % (auxilliary) disconnected nodes
% constraint
% forall(j in disconnected)(
% 	x_d[j] = 1 - x_node[j]
% );

% % (auxilliary) connected inactive nodes
% constraint
% forall(j in NODE where not(j in disconnected))(
% 	x_ci[j] = 1 - x_node[j]
% );

% % (auxilliary) connected active star leaf nodes
% constraint
% forall(j in NODE where ins[j] != {})(
% 	x_cal[j] = x_node[j] * max(a in ins[j])(y_arc[a])
% );

% % (auxilliary) connected active star center nodes
% constraint
% forall(j in NODE where outs[j] != {})(
% 	x_cac[j] = x_node[j] * max(a in outs[j])(y_arc[a])
% );

% % constraint
% % assert(forall(j in NODE)(ins[j] union outs[j] != {}), "disconnected nodes ... "
% %  ++ "\tNODE=" ++ show(NODE) ++ "\tARC=" ++ show(ARC) ++ "\tsuccessors=" ++ show(successors) ++ "\thead=" ++ show(head) ++ "\tins=" ++ show(ins) ++ "\touts=" ++ show(outs));
