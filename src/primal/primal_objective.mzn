%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION AND BOUND CONSTRAINTS

% the score is equal to the sum of the weights of the colors since unused colors have weight 0
constraint
x_score = sum(x_weight);


%%%%%%%%%%%%
% STATIC FLAG-BASED BOUND CONSTRAINTS


% upper-bound constraint based on disconnected nodes
constraint
	if length(disconnected) != 0
	then
		let {
			R_VERTEX: u = greatest(array2set(disconnected));
		} in
			x_score <= sum(r_weight) - sum(i in index_set(disconnected))(r_weight[disconnected[i]]) + r_weight[u]
	endif;

% lower-bound constraint based on disconnected nodes
constraint
	if length(cliqued) != 0
	then
		x_score >= sum(i in index_set(cliqued))(r_weight[cliqued[i]])
	endif;



% % input lower bound on score
% constraint
% if (LB_SCORE in WVCP_B)
% then
% 	(x_score >= lb_score)
% endif;

% % input upper bound on score
% constraint
% if (UB_SCORE in WVCP_B)
% then
% 	(x_score <= ub_score)
% endif;

% heaviest clique provides lower bound on score
constraint
if (M_CLIQUES in WVCP_M /\ CLIQUE!={})
then
	x_score >= max(k in CLIQUE)(sum([weight[u] | u in clique[k]]))
endif;

% % upper bound on score derived on the number of colors from the score
% constraint
% x_opened_colors <= x_ub_used
% /\
% x_score > sum(i in R_VERTEX)((i<x_ub_used)*(weight[max(R_VERTEX)-i+1]))
% /\
% x_score <= sum(i in R_VERTEX)((i<=x_ub_used)*(weight[max(R_VERTEX)-i+1]))
% ;


% %%%%%%%%%%%%
% %  DYNAMIC FLAG-BASED BOUND CONSTRAINTS

% % UPPER-BOUND SCORE CONSTRAINT

% constraint
% if (M_SB_SCORE in WVCP_M)
% then
% 	wvcp_lub_score(x_score, r_weight_scale, r_weight_vertices, r_weight_nr_vertices, x_weight, x_color[R_VERTEX])
% endif;

% % functional constraint GDC
% include "arg_max.mzn";
% include "arg_min.mzn";
% include "global_cardinality_closed_fn.mzn";

% predicate wvcp_lub_score(var int: y, array[int] of int: w, array[int] of set of int: wv, array[int] of int: wn, array[int] of var int: z, array[int] of var int: x) =
% 	%TODO z used?
% 	assert(index_set(w) == index_set(wv), "w and wv index sets do not match\n")
% 	/\
% 	assert(index_set(wv) == index_set(wn), "wv and wn index sets do not match\n")
% 	/\
% 	let {
% 		set of int: W = index_set(w);
% 		set of int: C = index_set(z);
% 		set of int: G = 0..length(x);
% 		% the weight-based vertex count distribution over colors
% 		array[W, C] of var G: x_wcg;
% 		constraint
% 			forall(i in W)(
% 				global_cardinality_closed([x[j] | j in wv[i]], C, x_wcg[i,C]) % !! close counting with gcc_closed
% 			);
% 		% the lower and upper color bounds for the vertices of a given weight
% 		array[W,1..2] of var C: x_lu;
% 		constraint
% 			x_lu[min(W),1] = min(C)
% 			/\	
% 			x_lu[min(W),2] = arg_max(j in C)(x_wcg[min(W),j] = 0) - 1 % !! correct since contiguity of vertices sharing the greatest weight
% 			/\
% 			forall(i in W where i>min(W))(
% 				x_lu[i,1] = arg_max(j in C)(x_wcg[i,j] > 0)
% 				/\
% 				x_lu[i,2] = max(C) - min(C) + arg_max(m in C)(x_wcg[i, max(C)-m+min(C)] = 0) % !! must traverse colors in decreasing order (actually, except for the smallest weight)
% 			);	
% 			%TODO review and carry on ..
% 		constraint
% 			x_lu[min(W),2] <= wn[min(W)]
% 			/\
% 			forall(i in W where i>min(W))(
% 				let {
% 					var C: x_m = max(h in W where h<i)(x_lu[h,2]);
% 				} in
% 					x_lu[i,2] <= x_m + wn[i] - sum(k in C where k>min(C))((k <= x_m) * x_wcg[i,k])
% 			);				
% 	} in
% 	true
%  	;
