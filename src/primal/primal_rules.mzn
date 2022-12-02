%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRY BREAKING RULES

%%%%%%%%%%%%
% lexicographic ordering constraint that sorts colors using >>_{c}

% (a) generic constraint formulation that assumes no existing ordering of vertices - uses global constraint lex_chain_greater
constraint
if not(I_SORT)
then
	lex_chain_greater(array2d(1..2, COLOR, x_weight ++ [max(VERTEX) - greatest(x_vertices[c]) | c in COLOR]))
	% alternative custom formulation
	% include "strictly_decreasing.mzn";
	% strictly_decreasing([max(VERTEX)*x_weight[c] - greatest(x_vertices[c] | c in COLOR]);
endif;

% (b) optimized constraint formulation when vertices are sorted in descending order of weights using >>_{w} (check speedup factor against generic formulation on R100_1g.dzn!)
constraint
if I_SORT
then
	strictly_increasing([greatest(x_vertices[c]) | c in COLOR])
endif;



%%%%%%%%%%%%
% - Rule SR1 assigns to every vertex v the color of its greatest dominating vertex (GDV) if it exists.
% - Rule DR1 assigns to every vertex v the color of its greatest s-dominating vertex (s-GDV) if it exists.
% - Rule SR2 restricts the color of every vertex v to the first d(v)+1 greatest colors where d(v) denotes the degree of v.
% - Rule DR2 assigns to every vertex v its greatest s-dominating color (s-GDC).


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

	
%%%%%%%%%%%%
% Rule SR2 (Static Greatest Dominating Color)
constraint if (M_SR2 in WVCP_M) then SGDC() endif;

predicate SGDC() =
	forall(v in R_VERTEX) (
		(x_color[v] <= card(neighbours[v]) + 1)
	)
% 	/\
% 	% !! redundant/alternative
% 	% empties max(card(neighbours[v]) + 1) | v) + 1 -th color (restricts it to its virtual vertex) and successive colors due to symmetry breaking constraint
% 	card(x_vertices[max([card(neighbours[v]) + 1 | v in R_VERTEX]) + 1]) == 1
 	;

% for output only: measures application rate of rule SGDC in a solution
function array[int] of int: count_SGDC() =
	let {
	array[R_VERTEX] of 0..card(R_VERTEX): d = array1d(R_VERTEX, [card(neighbours[v]) | v in R_VERTEX]);
	} in 
	[	%count(v in R_VERTEX where d[v]<max(COLOR))(fix(x_color[v]) <= d[v] + 1),
		card({v | v in R_VERTEX where d[v]<max(COLOR)}),
		card(R_VERTEX)
	];


%%%%%%%%%%%%
% Rule DR2 (Dynamic Greatest Dominating Color)
constraint if (M_DR2 in WVCP_M) then DGDC() endif;

predicate DGDC() =
	let {
	% the s-GDC of each vertex
	array[R_VERTEX] of var COLOR: x_gdc = array1d(R_VERTEX, [GDC(v) | v in R_VERTEX]);
	} in
	%% every vertex is colored by its s-GDC
	forall(v in R_VERTEX) (
		(x_color[v] = x_gdc[v])
	);

% Returns s-GDC of vertex v
function var COLOR: GDC(R_VERTEX: v) =
	let {
	% the neighbours of each vertex
	array[int] of R_VERTEX: SN = neighbours[v];
	% candidate colors for GDC of v
	set of COLOR: C = 1..min(max(COLOR),card(index_set(SN))+1);
	% number of neighbours of v in each color of C
	array[C] of var 0..card(index_set(SN)): x = global_cardinality([x_color[SN[i]] | i in index_set(SN)], set2array(C));
	}
	% return greatest color c that includes no neighbours of v (x[c]=0)
	in arg_min(c in C)(x[c]);


% for output only: measures application rate of rule DGDC in a solution
function array[int] of int: count_DGDC() =
	let {
	array[R_VERTEX] of COLOR: x_gdc = array1d(R_VERTEX, [fix_GDC(v) | v in R_VERTEX]);
	} in 
	[	count(v in R_VERTEX)(fix(x_color[v]) = x_gdc[v]),
		card(R_VERTEX)
	];
	
function COLOR: fix_GDC(R_VERTEX: v) =
	let {
	array[int] of R_VERTEX: SN = neighbours[v];
	set of COLOR: C = 1..min(max(COLOR),card(index_set(SN))+1);
	}
	in arg_min(c in C)(exists(i in index_set(SN))(fix(x_color[SN[i]]) = c));
