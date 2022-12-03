%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRY BREAKING RULES

% Rule `Greatest Dominating Color` (R2)
% - _Static_ version `SR2` is a domain constraint.
% - _Dynamic_ version `DR2` is a global constraint entailing `SR2`

% - `SR2` restricts the color of each vertex `v` to the first `d(v)+1` greatest colors where `d(v)` denotes the degree of `v`.
% - `DR2` assigns to each vertex `v` its greatest s-dominating color.

% `DR2` has alternative formulations:
% - variant `v1` combines global cardinality and arg_min constraints
% - variant `v2` uses global constraint `nvalue`.

include "arg_max.mzn"; % !! required by arg_min only!!
include "arg_min.mzn";
include "global_cardinality_fn.mzn"; % for DR2_v1
include "nvalue_fn.mzn"; % for DR2_v2

	
%%%%%%%%%%%%
% Rule SR2
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
% Rule DGDC: every vertex is colored by its s-GDC

constraint
	if (M_DR2_v1 in WVCP_M)
	then
		forall(v in R_VERTEX) (
			x_color[v] = wvcp_gdc_1([x_color[u] | u in neighbours[v]])
		)
	elseif (M_DR2_v2 in WVCP_M)
	then
		forall(v in R_VERTEX) (
			x_color[v] = wvcp_gdc_2([x_color[u] | u in neighbours[v]])
		)
	else true
	endif;


% functional GDC1
function var int: wvcp_gdc_1(array[int] of var int: x)
	::promise_total =
	let {
		var 1..length(x)+1: y::is_defined_var;
		constraint wvcp_gdc_1(x, y)::defines_var(y);
	}
	in y	;

% predicative GDC1
predicate wvcp_gdc_1(array[int] of var int: x, var int: y) =
	if length(x)=0
	then y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x)) + 1; % !! allow 1 feasible slot 
			int: n = length(x);
			array[l..u] of int: y_dom = [i | i in 1..n+1];
			array[l..u] of var 0..n: z = global_cardinality(x, y_dom); % !! do not close counting with gcc_closed
		} in
		y = arg_min(z) % will return the first available slot `y` which necessarily satisfies z[y]=0
	endif;

% functional GDC2
function var int: wvcp_gdc_2(array[int] of var int: x)
	::promise_total =
	let {
		var 1..length(x)+1: y::is_defined_var;
		constraint wvcp_gdc_2(x, y)::defines_var(y);
	}
	in y	;

% predicative GDC2
predicate wvcp_gdc_2(array[int] of var int: x, var int: y) =
	if length(x)=0
	then y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x));
			int: n = length(x);
			int: x_ub = ub_array(x);
			array[1..n+1] of var 0..x_ub: z;
			var 1..n+1: y_ub;
		} in
				z = [(x[i]<y_ub) * x[i] | i in l..u] ++ [0]
		/\		y_ub = nvalue(z)
		/\		y <= y_ub % y is uniquely defined and satisfies x[i]!=y for all i in 1..y_ub
	endif;
	

% for output only: measures application rate of rule DGDC in a solution
function array[int] of int: count_DGDC() =
	[	count(v in R_VERTEX)
			(fix(x_color[v]) = arg_min(c in 1..min(max(COLOR),card(neighbours[v])+1))
													(exists(u in neighbours[v])(fix(x_color[u]) = c))),
		card(R_VERTEX)
	];
