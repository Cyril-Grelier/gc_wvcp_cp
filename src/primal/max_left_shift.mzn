%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MAX_LEFT_SHIFT CONSTRAINT PREDICATE


include "nvalue_fn.mzn";

%% (M1-M4)
%% max_left_shift(y, [x1,...,xn]) <-> y = min(k in 1..n+1)({k | xi!=k for i=1..n})
% checks (M0) xi>0 (i=1..n)
% entails (M1) y!=xi (i=1..n)

predicate max_left_shift(var int: y, array[int] of var int: x) =
	if length(x) == 0
	then
		y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x));
			int: n = length(x);
			% (M2)
			array[1..n] of var 0..1: x_A :: is_defined_var;
			array[1..n] of var 0..n+1: z :: is_defined_var;
		} in
				% (M0) assertion on positiveness of the x variables
				forall(i in l..u)(x[i] > 0)
		/\
 				% (M1) disequalities
				forall(i in l..u)(y != x[i]) :: domain
		/\
				% (M3)
				forall(i in l..u)(x_A[i] = (y > x[i])) :: bounds
				/\
				forall(i in l..u)(z[i] = x_A[i] * x[i]) :: domain
		/\
				% (M4)
				y = nvalue([0] ++ z) :: domain
	endif
;


%%%%%%%%%%%%
%% Alternative relaxations of MAX_LEFT_SHIFT:
% disabling (M1) - coloring constraints already enforced by (P7)
% disabling (M0) - vertex variables positive in WVCP context

%% Compared to MAX_LEFT_SHIFT:
% - variant v1 simply disables (M0)-(M1)
% - variant v2
% - variant v3 uses gcc and arg_min instead of nvalue.


%% Variant 1
predicate max_left_shift_v1(var int: y, array[int] of var int: x) =
	if length(x) == 0
	then
		y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x));
			int: n = length(x);
			% (M2)
			array[1..n] of var 0..1: x_A :: is_defined_var;
			array[1..n] of var 0..n+1: z :: is_defined_var;
		} in
				% (M0) assertion on positiveness of the x variables
% 				forall(i in l..u)(x[i] > 0)
% 		/\
 				% (M1) disequalities
% 				forall(i in l..u)(y != x[i]) :: domain
% 		/\
				% (M3)
				forall(i in l..u)(x_A[i] = (y > x[i])) :: bounds
				/\
				forall(i in l..u)(z[i] = x_A[i] * x[i]) :: domain
		/\
				% (M4)
				y = nvalue([0] ++ z) :: domain
	endif
;


%
set of int: DEGREE = 1..max(degree);
% neighbour lookup data for variant of MAX_LEFT_SHIFT
array[int] of V: flattened_neighbours = flatten(N[V]);
%
function V: lookup_neighbour(V: v, DEGREE: i) =
	let {
		constraint assert(i <= degree[v], "assertion failed: neighbour beyond vertex' degree");
	} in
		flattened_neighbours[sum(u in V where u<v)(degree[u]) + i];



%% Variant 2
predicate max_left_shift_v2_global() =
	let {
		array[V,DEGREE] of var 0..1: x_A :: is_defined_var;
		constraint
			forall(u in V, i in DEGREE)(
				if i>degree[u]
				then
					x_A[u,i] = 0
				else
					forall(v in V where v=lookup_neighbour(u,i))(
						if u<v
						then
							x_A[u,i] = (x_U[u] > x_U[v]) :: bounds
						else
							% !! x_A[u,i] = (x_U[u] >= x_U[v])
							x_A[u,i] = 1 - x_A[v, arg_max(k in 1..degree[v])(lookup_neighbour(v,k) = u)]
						endif
					)
				endif
			)
		} in
			forall(u in V, i in DEGREE)(
	 			max_left_shift_v2(x_U[u], x_A[u, 1..degree[u]], [x_U[v] | v in N[u]])
	 		)
 	;
 	
%
predicate max_left_shift_v2(var int: y, array[int] of var 0..1: x_A, array[int] of var int: x) =
	if length(x) == 0
	then
		y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x));
			int: n = length(x);
			array[1..n] of var 0..n+1: z :: is_defined_var;
		} in
				% (M3) x_A = (y > x[i]) or x_A = (y >= x[i])
				forall(i in l..u)(z[i] = x_A[i] * x[i]) :: domain
		/\
				% (M4)		
				y = nvalue([0] ++ z) :: domain
	endif
;


%% Variant 3
include "arg_min.mzn";
include "global_cardinality_fn.mzn";

predicate max_left_shift_v3(var int: y, array[int] of var int: x) =
	if length(x)=0
	then y = 1
	else
		let {
			int: l = min(index_set(x));
			int: u = max(index_set(x)) + 1; 
			int: n = length(x);
			array[l..u] of int: y_dom = [i | i in 1..n+1];
			% !! do not close counting with gcc_closed
			array[l..u] of var 0..n: z = global_cardinality(x, y_dom) :: is_defined_var :: domain;
		} in
		y = arg_min(z)
	endif;
