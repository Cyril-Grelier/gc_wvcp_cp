%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS

%%%%%%%%%%%%
%% CHANNELING CONSTRAINTS

% channeling constraint between color and vertex variables
include "int_set_channel.mzn";
constraint
int_set_channel(x_color, x_vertices);


%%%%%%%%%%%%
%% COLORING CONSTRAINTS

% fixed coloring of virtual vertices based on vertex id
constraint
forall(v in V_VERTEX)( 
  x_color[v] = v - min(V_VERTEX) + 1
);


% binary coloring constraint between adjacent vertices
include "alldifferent.mzn";
constraint
	if (M_CLIQUES in WVCP_M)
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
	else % not({M_CLIQUES} intersect WVCP_M != {})
		% default coloring constraints
		forall(v in VERTEX, u in neighbours[v] where u<v)(
			(x_color[u] != x_color[v]) %:: bounds
		)
	endif;



%%%%%%%%%%%%
% WEIGHTING CONSTRAINTS

% dominant vertex of a color (wrt. >_{w})
constraint
forall(c in COLOR)(
	x_dominant[c] = greatest(x_vertices[c])
);

% weight of a color
constraint
forall(c in COLOR)(
	x_weight[c] = weight[x_dominant[c]]
);


%%%%%%%%%%%%
% BOUND CONSTRAINTS ON COLORS

%
constraint x_opened = [card(x_vertices[c]) != 1 | c in COLOR];

%
constraint x_opened_colors = sum(x_opened);

% upper-bound constraint based on disconnected nodes
constraint	x_opened_colors <= max(COLOR) - length(disconnected) + 1;

% lower-bound constraint based on cliqued nodes
constraint x_opened_colors >= length(cliqued);

% (redundant) lower-bound constraint based on cliqued nodes
include "alldifferent.mzn";
constraint all_different([x_color[v] | v in array2set(cliqued)]);

