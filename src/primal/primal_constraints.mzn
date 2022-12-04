%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS

include "alldifferent.mzn";
include "int_set_channel.mzn";


% channeling constraint between color and vertex variables
constraint
int_set_channel(x_color, x_vertices);


%% COLLORING CONSTRAINTS

% fixed coloring of virtual vertices based on vertex id
constraint
forall(v in V_VERTEX)( 
  x_color[v] = v - min(V_VERTEX) + 1
);


% binary coloring constraint between adjacent vertices
constraint
	if ({M_DR2_v3, M_DR2_v4} intersect WVCP_M != {})
	then
		true % coloring constraints subsume DR2_v3 and DR2_v4
	elseif (M_CLIQUES in WVCP_M)
	then
		% coloring constraints disabled for edges part of cliques
		forall(v in VERTEX, u in neighbours[v] where u<v /\ not(exists(k in CLIQUE)({u,v} subset clique[k])))(
			(x_color[u] != x_color[v])
		)
		/\
		% clique-specific coloring constraints
		forall(k in CLIQUE)(
		  alldifferent([x_color[u] | u in clique[k]]) 
		)
	else % not({M_CLIQUES, M_DR2_v3, M_DR2_v4} intersect WVCP_M != {})
		% default coloring constraints
		forall(v in VERTEX, u in neighbours[v] where u<v)(
			(x_color[u] != x_color[v])
		)
	endif;



%%%%%%%%%%%%
% weights of colors

% (a) optimized constraint formulation when vertices are sorted in descending order of weights using >_{w}
constraint
forall(c in COLOR where I_SORT)(
	x_weight[c] = weight[greatest(x_vertices[c])]
);

%	(b) generic constraint formulation that assumes no vertex ordering
constraint
forall(c in COLOR where not(I_SORT))(
	x_weight[c] = max(u in x_vertices[c])(weight[u])
);
