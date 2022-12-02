%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRY BREAKING RULES

% - Rule SR2 restricts the color of every vertex v to the first d(v)+1 greatest colors where d(v) denotes the degree of v.
% - Rule DR2 assigns to every vertex v its greatest s-dominating color (s-GDC).


	
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
