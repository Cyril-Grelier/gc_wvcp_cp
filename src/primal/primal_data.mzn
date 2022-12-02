%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

% sorts the set of (real) vertices U in descending order of weight with >_{w}
array[int] of R_VERTEX: sort_by_desc_weight(set of R_VERTEX: U) =
	if I_SORT
	then
		set2array(U)
	else
		let {
			array[int] of R_VERTEX: s2a = set2array(U);
			% sort in descending order of weights
			array[index_set(s2a)] of R_VERTEX: as = arg_sort([-weight[s2a[i]] | i in index_set(s2a)]);
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
R_VERTEX: greatest(set of R_VERTEX: U) =
	if	I_SORT
	then
		min(U)
	else
		sort_by_desc_weight(U)[1]
	endif;


%% var version
array[VERTEX] of VERTEX: sorted_vertices =
if I_SORT
then
	set2array(VERTEX)
else
	sort_by_desc_weight(R_VERTEX) ++ set2array(V_VERTEX)
endif;
	
var VERTEX: greatest(var set of VERTEX: U) =
	if I_SORT
	then
		min(U)
	else
		sorted_vertices[arg_min(i in index_set(sorted_vertices))(not(sorted_vertices[i] in U))]
	endif;


% the non-adjacent vertices of a vertex
array[R_VERTEX] of set of R_VERTEX: NA = [R_VERTEX diff ({v} union neighbours[v]) | v in R_VERTEX];

% amongst the non-adjacent vertices of a vertex, the vertices greater than the vertex
array[R_VERTEX] of set of R_VERTEX: GNA = [{u | u in NA[v] where greater(u,v)} | v in R_VERTEX];
