%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION AND BOUND CONSTRAINTS

% the score is equal to the sum of the weights of the colors since unused colors have weight 0
constraint
x_score = sum(x_weight);

% input upper bound on the number of colors
constraint
if (UB_COLORS in WVCP_B /\ ub_colors<card(COLOR))
% empties ub_colors+1-th color (restricts it to its virtual vertex) and successive colors due to symmetry breaking constraint
then card(x_vertices[ub_colors+1]) == 1
endif;

% input upper bound on score
constraint
if (UB_SCORE in WVCP_B)
then (x_score <= ub_score)
endif;

% heaviest clique provides lower bound on score
constraint
if (M_CLIQUES in WVCP_M /\ CLIQUE!={})
then
x_score >= max(k in CLIQUE)(sum([weight[u] | u in clique[k]]))
endif;

% % upper bound on score derived on the number of colors from the score
% % TODO review
% var R_VERTEX: x_ub_used;
% constraint
% x_nr_used <= x_ub_used
% /\
% x_score > sum(i in R_VERTEX)(bool2int(i<x_ub_used)*(weight[max(R_VERTEX)-i+1]))
% /\
% x_score <= sum(i in R_VERTEX)(bool2int(i<=x_ub_used)*(weight[max(R_VERTEX)-i+1]))
% ;
