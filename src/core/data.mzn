%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTANCE DATA

% instance name
string: name;
% number of vertices
int: nr_vertices;
% number of edges
int: nr_edges;
% neighborhoods (!! vertices indexed from 0 in `neighborhoods` -> re-indexed from 1 in `neighbours`)
array[int] of set of int: neighborhoods;
% weights (!! vertices may not be sorted in descending order of weights)
array[int] of int: weights;

% number of cliques
int: nr_cliques;
% cliques (!! vertices indexed from 0 in `cliques` -> re-indexed from 1 in `clique`)
array[int] of set of int: cliques;

% lower bound on colors
int: lb_colors;
% number of colors (!! this may be any precomputed upper bound on the number of colors)
int: ub_colors;
% lower bound on score
int: lb_score;
% upper bound on score
int: ub_score;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA ASSERTIONS

constraint assert(nr_vertices>0, "assertion failed: at least one vertex");

constraint assert(2*nr_edges = sum(i in index_set(neighborhoods))(card(neighborhoods[i])), "assertion failed: nr_edges inconsistent with total size of neighborhoods");
constraint assert(forall(i in index_set(neighborhoods))(neighborhoods[i] subset 0..nr_vertices-1), "assertion failed: neighbor out of bounds");
% constraint assert(forall(i in index_set(neighborhoods))(neighborhoods[i] != {}), "assertion failed: empty neighborhood");

constraint assert(forall(i in index_set(weights))(weights[i]>=0), "assertion failed: negative vertex weight");
% setting flag to indicate whether vertices are readily sorted in descending order of weight
bool: I_SORT = forall(i in index_set(weights) where i<max(index_set(weights)))(weights[i]>=weights[i+1]);

constraint assert(nr_cliques = card(index_set(cliques)), "assertion failed: nr_cliques inconsistent with size of array of cliques");
constraint assert(forall(i in index_set(cliques))(cliques[i] subset 0..nr_vertices-1), "assertion failed: clique vertices out of bounds");
constraint assert(forall(i in index_set(cliques))(i-min(index_set(cliques)) in cliques[i]), "assertion failed: i-th vertex must belong to i-th clique");

constraint assert(ub_colors in 1..nr_vertices, "assertion failed: ub_colors out of bounds");
constraint assert(lb_colors in 1..ub_colors, "assertion failed: lb_colors out of bounds");
constraint assert(ub_score in 0..sum(weights), "assertion failed: ub_score out of bounds");
constraint assert(lb_score in 0..ub_score, "assertion failed: lb_score out of bounds");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINT MODEL OPTIONS

% Model features
% TODO WVCP-specific flags (?) -> move elsewhere
enum WVCP_MODEL = {
	M_CLIQUES, % models each input clique with an all-different constraint instead of a clique of binary coloring disequality constraints
	M_SR1, % enforces Static Greatest Dominating Vertex rule
	M_DR1_v1, % enforces Dynamic Greatest Dominating Vertex rule variant 1
	M_SR2, % enforces Static Heaviest Dominating Color rule
	M_DR2_v1, % enforces Dynamic Heaviest Dominating Color rule variant 1
	M_DR2_v2, % enforces Dynamic Heaviest Dominating Color rule variant 2
	M_DR2_v3, % enforces Dynamic Heaviest Dominating Color rule variant 3
	M_GCCW, % enforce gcc on colors' weights
};

% Instance options
set of WVCP_MODEL: WVCP_M;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% META-MODEL ASSERTIONS

% constraint assert(card({M_DR1_v1} intersect WVCP_M) <= 1, "assertion failed: choose one of M_DR1_v*");
constraint assert(card({M_DR2_v1, M_DR2_v2, M_DR2_v3} intersect WVCP_M) <= 1, "assertion failed: choose one of M_DR2_v*");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEL DATA

% range of real vertices
set of int: R_VERTEX = 1..nr_vertices;
% count of real vertices
set of int: W_R_VERTEX = 0..card(R_VERTEX);

% range of colors (!! upper-bounded by ub_colors)
set of int: COLOR = 1..ub_colors;
% count of colors
set of int: W_COLOR = 0..card(COLOR);

% range of virtual vertices
% one virtual vertex is defined per color
% virtual vertex of i-th color identified by max(R_VERTEX)+i
set of int: V_VERTEX = max(R_VERTEX)+1..max(R_VERTEX)+card(COLOR);

% range of all vertices (real and virtual)
set of int: VERTEX = min(R_VERTEX)..max(V_VERTEX);
% count of all vertices
set of int: W_VERTEX = 0..card(VERTEX);

% NEIGHBORHOODS
% !! vertices indexed from 0 in instance file -> re-indexed from min(R_VERTEX)
% virtual vertices are disconnected
array[VERTEX] of set of VERTEX: neighbours = [{min(R_VERTEX)+j | j in neighborhoods[i]} | i in index_set(neighborhoods)] ++ [{} | v in V_VERTEX];

array[R_VERTEX] of int: r_degree = [card(neighbours[u]) | u in R_VERTEX];
set of int: STRICT_R_DEGREE = 1..max(r_degree);
set of int: R_DEGREE = 0..card(STRICT_R_DEGREE);

% WEIGHTS
% real vertex weights
array[R_VERTEX] of int: r_weight = weights;
% range of real vertex weights
set of int: R_WEIGHT_RANGE = min(r_weight)..max(r_weight);
% scale of real vertex weights
set of int: R_WEIGHT_SCALE = array2set(r_weight);
% range of scale of real vertex weights
set of int: R_WEIGHT_SCALE_RANGE = 1..card(R_WEIGHT_SCALE);
% scale of real vertex weights
array[R_WEIGHT_SCALE_RANGE] of R_WEIGHT_SCALE: r_weight_scale = reverse(set2array(R_WEIGHT_SCALE)); % !! sorting weights in descending order
% weight-based distribution of real vertices
array[R_WEIGHT_SCALE_RANGE] of set of R_VERTEX: r_weight_vertices = [{ v | v in R_VERTEX where r_weight[v]=r_weight_scale[i]} | i in R_WEIGHT_SCALE_RANGE];
% weight-based count of real vertices
array[R_WEIGHT_SCALE_RANGE] of W_R_VERTEX: r_weight_nr_vertices = [card(r_weight_vertices[i]) | i in R_WEIGHT_SCALE_RANGE];

% range of real/virtual vertex weights: virtual vertices have weight 0
array[VERTEX] of int: weight = r_weight ++ [0 | i in V_VERTEX];
% range of real/virtual vertex weights
set of int: WEIGHT_RANGE = min(weight)..max(weight);
% scale of real/virtual vertex weights
set of int: WEIGHT_SCALE = array2set(weight);
% range of scale of real/virtual vertex weights
set of int: WEIGHT_SCALE_RANGE = 1..card(WEIGHT_SCALE);
% scale of real/virtual vertex weights
array[WEIGHT_SCALE_RANGE] of WEIGHT_SCALE: weight_scale = reverse(set2array(WEIGHT_SCALE)); % !! sorting weights in descending order
% weight-based distribution of real/virtual vertices
array[WEIGHT_SCALE_RANGE] of set of VERTEX: weight_vertices = [{ v | v in VERTEX where weight[v]=weight_scale[i]} | i in WEIGHT_SCALE_RANGE];
% weight-based count of real/virtual vertices
array[WEIGHT_SCALE_RANGE] of W_VERTEX: weight_nr_vertices = [card(weight_vertices[i]) | i in WEIGHT_SCALE_RANGE];

% CLIQUES
% range of cliques
set of int: CLIQUE = 1..nr_cliques;
% !! clique vertices indexed from 0 in instance file -> re-indexed from min(R_VERTEX)
array[CLIQUE] of set of VERTEX: clique = [{min(R_VERTEX)+v | v in cliques[i]} | i in index_set(cliques)];

% SCORE
% range of WVCP objective function
set of int: P_SCORE = lb_score..ub_score;
% range of MWSSP objective function
set of int: D_SCORE = sum(r_weight)-max(P_SCORE)..sum(r_weight)-min(P_SCORE);

% GRAPH METRICS
% graph density
float: density = sum(v in R_VERTEX)(card(neighbours[v])) / max({1,(card(R_VERTEX)*(card(R_VERTEX)-1))});

% GRAPH PROPERTIES
% disconnected vertices (!! vertices with empty neighborhoods may all be placed in the heaviest color)
array[int] of R_VERTEX: disconnected = [v | v in R_VERTEX where neighbours[v] = {}];

% fully-connected vertices (!! any vertex connected to all other vertices is necessarily placed in a color of its own)
array[int] of R_VERTEX: cliqued = [v | v in R_VERTEX where neighbours[v] = R_VERTEX diff {v}];

% some clique in V
function set of VERTEX: clique(set of VERTEX: V) =
	if card(V)<=1
	then		V
	else
		let {
			VERTEX: u = arg_max(v in V)(card(V intersect neighbours[v]));
		} in
		  {u} union clique(V intersect neighbours[u])
	endif;

% neighbour lookup function
array[int] of R_VERTEX: flattened_neighbours = flatten_sets(neighbours[R_VERTEX]);

function array[int] of R_VERTEX: flatten_sets(array[int] of set of R_VERTEX: tab) =
	if length(tab) = 1
	then		set2array(tab[min(index_set(tab))])
	else		set2array(tab[min(index_set(tab))]) ++ flatten_sets(tab[min(index_set(tab))+1..max(index_set(tab))])
	endif;

function R_VERTEX: lookup_neighbour(R_VERTEX: v, STRICT_R_DEGREE: i) =
	let {
		constraint assert(i <= r_degree[v], "assertion failed: neighbour id beyond vertex' degree");
	} in
		flattened_neighbours[sum(u in R_VERTEX where u<v)(r_degree[u]) + i];
