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
% Rule S|D-R2

constraint
	if {M_SR2, M_DR2_v1, M_DR2_v2, M_DR2_v3} intersect WVCP_M != {}
	then x_opened_colors <= max(r_degree) + 1
	endif;



%%%%%%%%%%%%
% Rule SR2

constraint if (M_SR2 in WVCP_M) then SGDC() endif;

predicate SGDC() =
	forall(v in R_VERTEX) (
		x_color[v] <= r_degree[v] + 1
	)
 	;


%%%%%%%%%%%%
% SGDC metrics

% SGDC gap of input vertex in solution
function 0..max(COLOR): count_SGDC_vertex_gap(R_VERTEX: v) =
	if fix(x_color[v]) <= r_degree[v] + 1
	then
		0
	else
		fix(x_color[v]) - (r_degree[v] + 1)
	endif;

% SGDC gaps in solution
function array[1..2] of int: count_SGDC() =
	let {
		array[R_VERTEX] of 0..max(COLOR): gaps = [count_SGDC_vertex_gap(v) | v in R_VERTEX];
	} in
	[max(gaps), count(v in R_VERTEX)(gaps[v]>0)];


%%%%%%%%%%%%
% Rule DR2

constraint
	if			(M_DR2_v1 in WVCP_M)
	then
		forall(u in R_VERTEX) (
			wvcp_gdc_1(x_color[u], [x_color[v] | v in neighbours[u]])
		)
	elseif (M_DR2_v2 in WVCP_M)
	then
		let {
			% x_arc[u,i]=1 iff x_color[v] < x_color[u] where v=lookup_neighbour(u,i)
			array[R_VERTEX,STRICT_R_DEGREE] of var 0..1: x_arc :: is_defined_var;
			constraint
				forall(u in R_VERTEX, i in STRICT_R_DEGREE where i>r_degree[u])(
					x_arc[u,i] = 0
				);
			constraint
				forall(u in R_VERTEX, i in STRICT_R_DEGREE where i<=r_degree[u])(
					forall(v in R_VERTEX where v=lookup_neighbour(u,i) /\ u<v)(
						let {
							R_DEGREE: j = arg_max(k in 1..r_degree[v])(lookup_neighbour(v,k) = u);
						} in
									x_arc[u,i] = (x_color[v] < x_color[u])
							/\		x_arc[u,i] = 1 - x_arc[v,j]
					)
				);
		} in
			forall(u in R_VERTEX) (
				wvcp_gdc_2(x_color[u], x_arc[u,1..r_degree[u]], [x_color[v] | v in neighbours[u]])
			)
	elseif (M_DR2_v3 in WVCP_M)
	then
			forall(u in R_VERTEX) (
				wvcp_gdc_3(x_color[u], [x_color[v] | v in neighbours[u]])
			)
	else	
			true
	endif;


%%%%%%%%%%%%
% GDC constraint - variant 1

include "arg_max.mzn"; % !! required by arg_min only!!
include "arg_min.mzn";
include "global_cardinality_fn.mzn";

% y satisfies y = 1 + count(i in index_set(x))(x[i]<y)
predicate wvcp_gdc_1(var int: y, array[int] of var int: x) =
	if length(x)=0
	then y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x)) + 1; % !! allow 1 feasible slot 
			int: n = length(x);
			array[l..u] of int: y_dom = [i | i in 1..n+1];
			array[l..u] of var 0..n: z = global_cardinality(x, y_dom) :: is_defined_var; % !! do not close counting with gcc_closed
		} in
		y = arg_min(z) % y is the smallest slot in l..u satisfying z[y]=0
	endif;


%%%%%%%%%%%%
% GDC constraint - variant 2

include "nvalue_fn.mzn";

% y satisfies y = 1 + count(i in index_set(xc))(xc[i]<y)
predicate wvcp_gdc_2(var int: y, array[int] of var int: xa, array[int] of var int: xc) =
	assert(
		index_set(xa) = index_set(xc),
		"xa and xc must have identical index sets",
		if length(xc)=0
		then y = 1
		else
			let {
				int: l = min(index_set(xc));
				int: u = max(index_set(xc));
				int: n = length(xc);
				array[1..n+1] of var 0..n+1: z :: is_defined_var;
			} in
					y <= n + 1
			/\		z[n+1] = 0
% 			/\		forall(j in 1..n) (z[j] in {0} union (1..n+1 intersect dom(xc[l+j-1]))) :: domain
			/\		forall(j in 1..n) (z[j] = xa[l+j-1] * xc[l+j-1]) :: domain
			/\		y = nvalue(z) :: domain % <-> y = sum(i in 0..n+1)(exists(j in 1..n+1)(z[j] == i))
		endif
	);


%%%%%%%%%%%%
% GDC constraint - variant 3

include "nvalue_fn.mzn";

% y satisfies y = 1 + count(i in index_set(xc))(xc[i]<y)
predicate wvcp_gdc_3(var int: y, array[int] of var int: xc) =
	if length(xc)=0
	then y = 1
	else
		let {
			int: l = min(index_set(xc));
			int: u = max(index_set(xc));
			int: n = length(xc);
			array[1..n+1] of var 1..n+1: z :: is_defined_var;
		} in
				z[n+1] = y
		/\		forall(j in 1..n) (z[j] = min(y, xc[l+j-1])) :: bounds
		/\		y = nvalue(z) :: bounds % <-> y <= sum(i in 1..n+1)(exists(j in 1..n)(z[j] == i)) + 1
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
