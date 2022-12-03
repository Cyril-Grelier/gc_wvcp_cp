%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS

include "alldifferent.mzn";
include "int_set_channel.mzn";


% channeling constraint
constraint
int_set_channel(x_color, x_vertices);

% fixed coloring of virtual vertices based on vertex id
constraint
forall(v in V_VERTEX)( 
  x_color[v] = v - min(V_VERTEX) + 1
);

% (1) binary coloring constraint between adjacent vertices unless they are part of a clique and clique-specific coloring constraints are enforced 
constraint
forall(v in VERTEX, u in neighbours[v] where u<v /\ (exists(k in CLIQUE)({u,v} subset clique[k]) -> not(M_CLIQUES in WVCP_M)) ) (% /\ not(M_DR2_v1 in WVCP_M) )(
  (x_color[u] != x_color[v])
);

% (2) clique-specific coloring constraints
constraint
forall(k in CLIQUE where (M_CLIQUES in WVCP_M)) ( % /\ not(M_DR2_v1 in WVCP_M))( 
  alldifferent([x_color[u] | u in clique[k]]) 
);

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
