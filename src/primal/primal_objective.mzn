%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION AND BOUND CONSTRAINTS

% the score is equal to the sum of the weights of the colors since unused colors have weight 0
constraint
x_score = sum(x_weight) :: bounds;


%%%%%%%%%%%%
% STATIC BOUND CONSTRAINTS

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


% heaviest clique provides lower bound on score
constraint
if (M_CLIQUES in WVCP_M /\ CLIQUE!={})
then
	x_score >= max(k in CLIQUE)(sum([weight[u] | u in clique[k]]))
endif;



%%%%%%%%%%%%
%  DYNAMIC FLAG-BASED BOUND CONSTRAINTS

% GCC COLOR WEIGHT CONSTRAINT

include "global_cardinality_closed_fn.mzn";
include "all_different.mzn";

constraint
if (M_GCCW in WVCP_M)
then
	let {
		% x_weight_colors[i] = number of colors taking weight `weight_scale[i]`
		array[WEIGHT_SCALE_RANGE] of var W_COLOR: x_weight_colors;% :: is_defined_var;
		set of int: WSR = index_set(x_weight_colors);
		array[WSR] of var COLOR: x_weight_colors_max :: is_defined_var;
% 		array[WSR] of var COLOR: x_weight_colors_min;
% 		array[WSR] of set of VERTEX: w_cliques = [clique(weight_vertices[i]) | i in WSR];
% 		array[WSR] of W_VERTEX: w_cliques_size = [card(w_cliques[i]) | i in WSR];
	} in
			x_weight_colors = global_cardinality_closed(x_weight, weight_scale) :: bounds % !! close counting with gcc_closed
	/\		x_score = sum(i in min(WSR)..max(WSR)-1)(x_weight_colors[i] * weight_scale[i]) :: bounds
	/\		card(COLOR) = sum(x_weight_colors) :: bounds
	/\		x_opened_colors = sum(x_weight_colors[min(WSR)..max(WSR)-1]) :: bounds

	/\		forall(i in WSR)(x_weight_colors[i] <= weight_nr_vertices[i])
	/\		forall(i in WSR)(x_weight_colors_max[i] = max(k in weight_vertices[i])(x_color[k])) :: bounds
	/\		x_weight_colors[min(WSR)] = x_weight_colors_max[min(WSR)] :: bounds
	/\		forall(i in WSR where i>min(WSR))(x_weight_colors[i] = max(0, x_weight_colors_max[i] - max(x_weight_colors_max[1..i-1]))) :: bounds

% 	/\		forall(i in WSR)(x_weight_colors_min[i] = min(k in weight_vertices[i])(x_color[k]))
% 	/\		forall(i in WSR)(x_weight_colors_max[i] - x_weight_colors_min[i] + 1 >= w_cliques_size[i])
	
% 	/\		x_opened_colors >= w_cliques_size[min(WSR)] + sum(i in WSR where i>min(WSR))(max(0, w_cliques_size[i] - max(j in min(WSR)..i-1)(w_cliques_size[j])))
% 	/\		x_score >= weight_scale[min(WSR)] * w_cliques_size[min(WSR)] + sum(i in WSR where i>min(WSR))(weight_scale[i] * max(0, w_cliques_size[i] - max(j in min(WSR)..i-1)(w_cliques_size[j])))
	
% 	/\		forall(i in WSR)(alldifferent([x_color[u] | u in w_cliques[i]]))

	
	% 	wvcp_lub_score(x_score, weight_scale, weight_vertices, weight_nr_vertices, x_weight, x_color[R_VERTEX])
endif;
