%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRY BREAKING RULES

% Rule `Greatest Dominating Color` (R2)
% - _Static_ version `SR2` is a domain constraint.
% - _Dynamic_ version `DR2` is a global constraint entailing `SR2`

% - `SR2` restricts the color of each vertex `v` to the first `d(v)+1` greatest colors where `d(v)` denotes the degree of `v`.
% - `DR2` assigns to each vertex `v` its greatest s-dominating color.

% `DR2` has alternative formulations:
% - variant `v1` combines global cardinality and arg_min constraints. Does not entail coloring constraints !
% - variant `v2` uses reformulation of global constraint `nvalue`. Does not entail coloring constraints !
% - variant `v3` uses global constraint `nvalue`. Does entail coloring constraints !
% - variant `v4` uses global constraints `nvalue` and `gcc`. Does entail coloring constraints !

	
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


%%%%%%%%%%%%
% SGDC metrics

% SGDC gap of input vertex in solution
function 0..max(COLOR): count_SGDC_vertex_gap(R_VERTEX: v) =
	if fix(x_color[v]) <= card(neighbours[v]) + 1
	then
		0
	else
		fix(x_color[v]) - (card(neighbours[v]) + 1)
	endif;

% SGDC gaps in solution
function array[1..2] of int: count_SGDC() =
	let {
		array[R_VERTEX] of 0..max(COLOR): gaps = [count_SGDC_vertex_gap(v) | v in R_VERTEX];
	} in
	[max(gaps), count(v in R_VERTEX)(gaps[v]>0)];


%%%%%%%%%%%%
% Rule DR2

% rule GDC
constraint
	if ({M_DR2_v1, M_DR2_v2, M_DR2_v3, M_DR2_v4} intersect WVCP_M != {})
	then
		forall(v in R_VERTEX) (
			x_color[v] = wvcp_gdc(v, set2array(neighbours[v]), [x_color[u] | u in neighbours[v]])
		)
	else
		true
	endif;

% functional constraint GDC
function var int: wvcp_gdc(R_VERTEX: v, array[int] of R_VERTEX: U, array[int] of var int: x)
	::promise_total =
	let {
		var 1..length(x)+1: y::is_defined_var;
		constraint
			if			(M_DR2_v1 in WVCP_M)
			then
				wvcp_gdc_1(x, y)::defines_var(y)
			elseif	(M_DR2_v2 in WVCP_M)
			then
				wvcp_gdc_2(x, y)::defines_var(y)
			elseif	(M_DR2_v3 in WVCP_M)
			then
				wvcp_gdc_3(x, y)::defines_var(y)
			elseif	(M_DR2_v4 in WVCP_M)
			then
				wvcp_gdc_4(v, U, x, y)::defines_var(y) % !! only variant depending on graph (neighborhoods)
			else
				true
			endif;
	}
	in y	;



%%%%%%%%%%%%
% GDC constraint - variant 1

include "arg_max.mzn"; % !! required by arg_min only!!
include "arg_min.mzn";
include "global_cardinality_fn.mzn";

% y satisfies y = 1 + count(i in index_set(x))(x[i]<y)
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
		y = arg_min(z) % y is the smallest slot in l..u satisfying z[y]=0
	endif;


%%%%%%%%%%%%
% GDC constraint - variant 2

include "nvalue_fn.mzn";

% y satisfies y = 1 + count(i in index_set(x))(x[i]<y)
predicate wvcp_gdc_2(array[int] of var int: x, var int: y) =
	if length(x)=0
	then y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x));
			int: n = length(x);
			int: ub_x = ub_array(x);			
			array[1..n+1] of var 0..ub_x: z;
		} in
				forall(j in 1..n) (z[j] = (x[l+j-1] < y) * x[l+j-1])
		/\		z[n+1] = 0
		/\		y = nvalue(z) % <-> y = sum(i in 0..ub_x)(exists(j in 1..n+1)(z[j] == i))
	endif;


%%%%%%%%%%%%
% GDC constraint - variant 3

include "nvalue_fn.mzn";

% !! disables coloring constraints twice
% y satisfies y = 1 + count(i in index_set(x))(x[i]<y)
predicate wvcp_gdc_3(array[int] of var int: x, var int: y) =
	if length(x)=0
	then y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x));
			int: n = length(x);
			int: ub_x = ub_array(x);
			array[1..n+1] of var 0..ub_x: z;
		} in
				forall(j in 1..n) (z[j] = (x[l+j-1] < y) * x[l+j-1])
		/\		z[n+1] = 0
		/\		y = nvalue(z) % <-> y = sum(i in 0..ub_x)(exists(j in 1..n+1)(z[j] == i))
% 		/\		forall(j in 1..n) (x[l+j-1] >= y -> x[l+j-1] > y)
		/\		forall(j in 1..n) (x[l+j-1] != y)
	endif;
	

%%%%%%%%%%%%
% GDC constraint - variant 4

include "nvalue_fn.mzn";
include "global_cardinality_closed_fn.mzn";

% !! disables coloring constraints once
% y satisfies y = 1 + count(i in index_set(x))(x[i]<y)
predicate wvcp_gdc_4(int: v, array[int] of int: U, array[int] of var int: x, var int: y) =
	assert(index_set(U) = index_set(x), "error: inconsistent index sets for U and x")
	/\
	if length(x)=0
	then y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x));
			int: n = length(x);
			int: ub_x = ub_array(x);
			array[1..n+1] of var 0..ub_x: z;
		} in
				forall(j in 1..n) (z[j] = (x[l+j-1] < y) * x[l+j-1])
		/\		z[n+1] = 0
		/\		y = nvalue(z) % <-> y = sum(i in 0..ub_x)(exists(j in 1..n+1)(z[j] == i))
		/\		forall(j in 1..n where U[j]<v) (x[l+j-1] != y) % where clause to avoid duplicating binary disequality constraints
	endif;
	

%%%%%%%%%%%%
% DGDC metrics

% DGDC gap of input vertex in solution
function 0..max(COLOR): count_DGDC_vertex_gap(R_VERTEX: v) =
	if fix(x_color[v])=1
	then		0
	else		arg_min(i in 1..fix(x_color[v])-1)(exists(u in neighbours[v])(fix(x_color[u]) == i))
	endif;

% DGDC gaps in solution
function array[1..2] of int: count_DGDC() =
	let {
		array[R_VERTEX] of 0..max(COLOR): gaps = [count_DGDC_vertex_gap(v) | v in R_VERTEX];
	} in
	[max(gaps), count(v in R_VERTEX)(gaps[v]>1)];
