%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

% sorts the set of vertices U in descending order of weight with >_{w}
array[int] of VERTEX: sort_by_desc_weight(set of VERTEX: U) =
	if I_SORT
	then
		set2array(U)
	else
		let {
			array[int] of VERTEX: s2a = set2array(U);
			% sort in descending order of weights
			array[index_set(s2a)] of VERTEX: as = arg_sort([-weight[s2a[i]] | i in index_set(s2a)]);
		} in
			array1d(index_set(s2a), [s2a[as[i]] | i in index_set(as)])
	endif;


% checks whether u is greater than v (u>_{w}v)
function bool: greater(VERTEX: u, VERTEX: v) =
	if I_SORT
	then
		u<v
	else
		(weight[u]>weight[v]) \/ (weight[u]=weight[v] /\ u<v)
	endif;


% returns greatest of (real) vertices in U with >_{w}
%% par version
R_VERTEX: greatest(set of VERTEX: U) =
	if	I_SORT
	then
		min(U)
	else
		let {
			array[int] of VERTEX: V = sort_by_desc_weight(U);
		} in
		V[min(index_set(V))]
	endif;


%% var version
% !! this is made global to reduce overhead
array[VERTEX] of VERTEX: sorted_vertices = array1d(VERTEX, sort_by_desc_weight(R_VERTEX) ++ set2array(V_VERTEX));

var VERTEX: greatest(var set of VERTEX: U) =
	if I_SORT
	then
		min(U)
	else
		sorted_vertices[arg_min(i in index_set(sorted_vertices))(not(sorted_vertices[i] in U))]
	endif;
