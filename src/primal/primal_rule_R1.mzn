%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRY BREAKING RULES

% - Rule SR1 assigns to every vertex v the color of its greatest dominating vertex (GDV) if it exists.
% - Rule DR1 assigns to every vertex v the color of its greatest s-dominating vertex (s-GDV) if it exists.

include "arg_max.mzn"; % !! required by arg_min only!!
include "arg_min.mzn";


% the non-adjacent vertices of a vertex
array[R_VERTEX] of set of R_VERTEX: NA = [R_VERTEX diff ({v} union neighbours[v]) | v in R_VERTEX];

% amongst the non-adjacent vertices of a vertex, the vertices greater than the vertex
array[R_VERTEX] of set of R_VERTEX: GNA = [{u | u in NA[v] where greater(u,v)} | v in R_VERTEX];



%%%%%%%%%%%%
% Rule SR1 (Static Greatest Dominating Vertex)
constraint if (M_SR1 in WVCP_M) then SGDV() endif;

predicate SGDV() =
	let {
	% the dominating vertices for each vertex (>>)
	array[R_VERTEX] of set of R_VERTEX: DGNA = array1d(R_VERTEX, [{u | u in R_VERTEX where u in GNA[v] /\ neighbours[v] subset neighbours[u]} | v in R_VERTEX]);
	% the GDV of a vertex if it exists, otherwise the vertex itself
	array[R_VERTEX] of R_VERTEX: GDV = array1d(R_VERTEX, [greatest(DGNA[v] union {v}) | v in R_VERTEX]);
	} in
	% every dominated vertex has the color of its GDV if it exists or else its own color (tautology)
	forall(v in R_VERTEX)(
		x_color[v] = x_color[GDV[v]]
	);

% for output only: measures application rate of rule SGDV in a solution
function array[int] of int: count_SGDV() =
	[	
		card({v | v in R_VERTEX where GNA[v]!={}}),
		card(R_VERTEX)
	];


%%%%%%%%%%%%
% Rule DR1 (Dynamic Greatest Dominating Vertex)
constraint if (M_DR1 in WVCP_M) then DGDV() endif;

predicate DGDV() =
	let {
	% the s-GDV of each vertex if it exists, otherwise the vertex itself
	array[R_VERTEX] of var R_VERTEX: x_GDV = array1d(R_VERTEX, [xGDV(v, GNA[v]) | v in R_VERTEX]);
	} in
	% every s-dominated vertex has the color of its s-GDV if it exists or else its own color (tautology)
	forall(v in R_VERTEX)(
		x_color[v] = x_color[x_GDV[v]]
	);
	
% returns s-GDV of vertex v in current solution s if it exists else returns v
% U=GNA[v]
function var R_VERTEX: xGDV(R_VERTEX: v, set of R_VERTEX: U) =
	let {
	% the GNA vertices of vertex v sorted in descending order with >_{w} and to which v is appended
	array[int] of R_VERTEX: GNAv = sort_by_desc_weight(U) ++ [v];
	% x[i]=0 iff (i<max(index_set(GNAv)) -> GNAv[i] s-dominates v)
	% VERSION 1
	array[index_set(GNAv)] of var bool: x = [exists(w in NA[GNAv[i]] diff ({v} union NA[v]))(x_color[w] = x_color[GNAv[i]]) | i in index_set(GNAv)];
	% VERSION 2
	% 	array[index_set(GNAv)] of var bool: x = [member([x_color[w] | w in NA[GNAv[i]] diff ({v} union NA[v])], x_color[GNAv[i]]) | i in index_set(GNAv)];
	} in
	GNAv[arg_min(i in index_set(GNAv))(x[i])];

% for output only: measures application rate of rule DGDV in a solution
function array[int] of int: count_DGDV() =
	let {
	array[R_VERTEX] of R_VERTEX: fix_GDV = array1d(R_VERTEX, [fixGDV(v, GNA[v]) | v in R_VERTEX]);
	} in
	[	count(v in R_VERTEX where GNA[v]!={})(fix_GDV[v] != v /\ fix(x_color[fix_GDV[v]]) = fix(x_color[v])),
		count(v in R_VERTEX where GNA[v]!={})(fix_GDV[v] != v),
		card({v | v in R_VERTEX where GNA[v]!={}}),
		card(R_VERTEX)
	];

function int: fixGDV(R_VERTEX: v, set of R_VERTEX: U) =
	let {
	array[int] of R_VERTEX: GNAv = sort_by_desc_weight(U) ++ [v];
	array[index_set(GNAv)] of bool: x = [exists(w in NA[GNAv[i]] diff ({v} union NA[v]))(fix(x_color[w]) = fix(x_color[GNAv[i]])) | i in index_set(GNAv)];
	} in GNAv[arg_min(i in index_set(GNAv))(x[i])];
