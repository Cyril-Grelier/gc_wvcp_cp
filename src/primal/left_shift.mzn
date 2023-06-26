%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Lesaint (david.lesaint@univ-angers.fr)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LEFT_SHIFT CONSTRAINT PREDICATES


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reduction rule R2

% the attractor of v = the heaviest dominating non-adjacent vertex u of v s.t. every neighbor of v is a neighbor of u
%% v may be its own attractor
%% every vertex v may be colored with the color of its attrator in any solution without incurring any score increase or coloring constraint violation

function V: attractor(V: v) =
	let {
		% the non-adjacent vertices of vertex v
		set of V: NA = V diff ({v} union N[v]);
		% the dominating non-adjacent vertices (DNAs) of vertex v
		set of V: DNA = {u | u in NA where dominates(u,v)};
		% the DNAs of v it can take the color of in any solution (ADNA) 
		set of V: ADNA = {u | u in DNA where N[v] subset N[u]};
	} in
		% the dominant of the set of DNAs of vertex v if non empty, otherwise v itself
		dominant_U(ADNA union {v})
;

% (R2) enforces v and its attractor be colored identically
predicate R2(V: v) =
	x_U[v] = x_U[attractor(v)]
;


%% R2 metrics
% number of vertices not attracted and max attraction gap
function array[1..2] of int: check_R2() =
	let {
		array[V] of 0..max(K): gaps = [if v == u then 0 else abs(fix(x_U[v]) - fix(x_U[u])) endif | v in V, u in V where u=attractor(v)];
	} in
	[max(gaps), count(v in V)(gaps[v]>0)];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LEFT_SHIFT CONSTRAINT PREDICATE

%% left_shift(v) <-> forall u in V\N(v) s.t. u dominates v: (x_U[v] <= x_U[u]) <- (forall h in N(v)\cap(V\N(u)): x_U[h] != x_U[v])
predicate left_shift(V: v) =
	let {
		% the non-adjacent vertices of vertex v
		set of V: NA = V diff ({v} union N[v]);
		% the dominating non-adjacent vertices (DNAs) of vertex v
		set of V: DNA = {u | u in NA where dominates(u,v)};
		% the DNA vertices of vertex v sorted in descending dominance ordering
		array[int] of V: DNAv = dominance_sort_U(DNA);
		% for each DNA u of v, the neighbors of v that are not adjacent to u
		array[index_set(DNAv)] of set of V: H = [N[v] intersect (V diff N[u]) | u in DNAv];
		array[index_set(DNAv)] of var bool: z :: is_defined_var;
	} in
		if (length(DNAv)) = 0
		then
			x_KW[x_U[v]] = w[v]
		else
			forall(i in index_set(z))(
						(z[i] = forall(h in H[i])(x_U[h] != x_U[DNAv[i]])) :: domain
				/\
						(z[i] -> x_U[v] <= x_U[DNAv[i]]) :: domain
			)
		endif
;
