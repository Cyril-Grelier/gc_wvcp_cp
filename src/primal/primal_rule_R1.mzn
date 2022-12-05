%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRY BREAKING RULES

% Rule `Greatest Dominating Vertex` (R1)
% - _Static_ version `SR1` is a domain constraint.
% - _Dynamic_ version `DR1` is a global constraint entailing `SR1`

% - `SR1` assigns to each vertex `v` the color of its greatest dominating vertex (GDV) if it exists.
% - `DR1` assigns to each vertex `v` the color of its greatest s-dominating vertex (s-GDV) if it exists.

% `DR1` has alternative formulations:
% - variant `v1` uses global constraint arg_min.



%%%%%%%%%%%%
% Rule SR1

constraint if (M_SR1 in WVCP_M) then SGDV() endif;

predicate SGDV() =
	let {
		% the non-adjacent vertices of a vertex
		array[R_VERTEX] of set of R_VERTEX: NA = [R_VERTEX diff ({v} union neighbours[v]) | v in R_VERTEX];
		% the vertices non-adjacent to, and greater than, a vertex
		array[R_VERTEX] of set of R_VERTEX: GNA = [{u | u in NA[v] where greater(u,v)} | v in R_VERTEX];
		% the dominating vertices for each vertex (>>)
		array[R_VERTEX] of set of R_VERTEX: DGNA = [{u | u in GNA[v] where neighbours[v] subset neighbours[u]} | v in R_VERTEX];
		% the GDV of a vertex if it exists, otherwise the vertex itself
		array[R_VERTEX] of R_VERTEX: GDV = [greatest(DGNA[v] union {v}) | v in R_VERTEX];
	} in
		% every dominated vertex has the color of its GDV if it exists or else its own color (tautology)
		forall(v in R_VERTEX)(
			x_color[v] = x_color[GDV[v]]
		);


%%%%%%%%%%%%
% S-GDV metrics

% S-GDV gap of input vertex in solution
function 0..max(COLOR): count_SGDV_vertex_gap(R_VERTEX: v) =
	let {
		% the non-adjacent vertices of v
		set of R_VERTEX: NA = R_VERTEX diff ({v} union neighbours[v]);
		% the vertices non-adjacent to, and greater than, v
		set of R_VERTEX: GNA = {u | u in NA where greater(u,v)};
		% the dominating vertices of v (>>)
		set of R_VERTEX: DGNA = {u | u in GNA where neighbours[v] subset neighbours[u]};
		% the GDV of v if it exists, otherwise v itself
		R_VERTEX: GDV = greatest(DGNA union {v});
	} in
	if v == GDV
	then		0
	else		abs(fix(x_color[v]) - fix(x_color[GDV]))
	endif;

% S-GDV gaps in solution
function array[1..2] of int: count_SGDV() =
	let {
		array[R_VERTEX] of 0..max(COLOR): gaps = [count_SGDV_vertex_gap(v) | v in R_VERTEX];
	} in
		[max(gaps), count(v in R_VERTEX)(gaps[v]>0)];



%%%%%%%%%%%%
% Rule DR1

% rule GDV
constraint
	if ({M_DR1_v1} intersect WVCP_M != {})
	then
		let {
			% the non-adjacent vertices of a vertex
			array[R_VERTEX] of set of R_VERTEX: NA = [R_VERTEX diff ({v} union neighbours[v]) | v in R_VERTEX];
			% the vertices non-adjacent to, and greater than, a vertex
			array[R_VERTEX] of set of R_VERTEX: GNA = [{u | u in NA[v] where greater(u,v)} | v in R_VERTEX];
		} in
			forall(v in R_VERTEX) (
				let {
					% the GNA vertices of vertex v sorted in descending order with >_{w} and to which v is appended
					array[int] of R_VERTEX: GNAv = sort_by_desc_weight(GNA[v]) ++ [v];
					% the NA vertices of each GNA of v that are adjacent to v
					array[int] of set of R_VERTEX: Av = [NA[GNAv[i]] diff ({v} union NA[v]) | i in index_set(GNAv)];
				} in
				x_color[v] = x_color[wvcp_gdv(v, Av, GNAv, x_color[R_VERTEX])]
			)
	else
		true
	endif;

% functional constraint GDV
function var int: wvcp_gdv(int: v, array[int] of set of int: Av, array[int] of int: GNAv, array[int] of var int: x)
	::promise_total =
	let {
		var 1..length(x): y::is_defined_var;
		constraint
			if			(M_DR1_v1 in WVCP_M)
			then
				wvcp_gdv_1(v, Av, GNAv, x, y)::defines_var(y)
			else
				true
			endif;
	}
	in y	;
	
	
%%%%%%%%%%%%
% GDV constraint - variant 1

include "arg_max.mzn"; % !! required by arg_min only!!
include "arg_min.mzn";

% returns color of s-GDV of vertex v in current solution s if it exists else returns v
predicate wvcp_gdv_1(int: v, array[int] of set of int: Av, array[int] of int: GNAv, array[int] of var int: x, var int: y) =
	assert(index_set(Av) = index_set(GNAv), "error: inconsistent index sets for Av and GNAv")
% 	/\
% 	assert(forall(i in index_set(GNAv))(Av[i] intersect array2set(GNAv) = {}), "error: overlapping sets Av and GNAv")
	/\
	let {
			int: l = min(index_set(GNAv));
			int: u = max(index_set(GNAv));
			array[l..u] of var bool: z = [exists(w in Av[i])(x[w] = x[GNAv[i]]) | i in l..u];
	} in
	y = GNAv[arg_min(i in l..u)(z[i])]
% 	/\
% 	forall(i in l..u) (z[i] -> (x[y] != x[GNAv[i]]))
	;



%%%%%%%%%%%%
% D-GDV metrics

% D-GDV gap of input vertex in solution
function 0..max(COLOR): count_DGDV_vertex_gap(R_VERTEX: v) =
	let {
		% the non-adjacent vertices of v
		set of R_VERTEX: NA = R_VERTEX diff ({v} union neighbours[v]);
		% the vertices non-adjacent to, and greater than, v
		set of R_VERTEX: GNA = {u | u in NA where greater(u,v)};
		% the dominating vertices of v (>>)
		set of R_VERTEX: DGNA = {u | u in GNA where neighbours[v] subset neighbours[u]};
		% the GDV of v if it exists, otherwise v itself
		R_VERTEX: GDV = greatest(DGNA union {v});
	} in
	if v == GDV
	then		0
	else		abs(fix(x_color[v]) - fix(x_color[GDV]))
	endif;

% D-GDV gaps in solution
function array[1..2] of int: count_DGDV() =
	let {
		array[R_VERTEX] of 0..max(COLOR): gaps = [count_SGDV_vertex_gap(v) | v in R_VERTEX];
	} in
		[max(gaps), count(v in R_VERTEX)(gaps[v]>0)];
