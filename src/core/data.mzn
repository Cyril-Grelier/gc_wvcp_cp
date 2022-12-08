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
	M_SB_SCORE, % enforce static lower/upper bound constraints on objective function
	M_CLIQUES, % models each input clique with an all-different constraint instead of a clique of binary coloring disequality constraints
	M_SR1, % enforces Static Greatest Dominating Vertex rule
	M_DR1_v1, % enforces Dynamic Greatest Dominating Vertex rule variant 1
	M_SR2, % enforces Static Heaviest Dominating Color rule
	M_DR2_v1, % enforces Dynamic Heaviest Dominating Color rule variant 1
	M_DR2_v2, % enforces Dynamic Heaviest Dominating Color rule variant 2
	M_DR2_v3, % enforces Dynamic Heaviest Dominating Color rule variant 3
	M_DR2_v4, % enforces Dynamic Heaviest Dominating Color rule variant 4
};

% Instance options
set of WVCP_MODEL: WVCP_M;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% META-MODEL ASSERTIONS

% constraint assert(card({M_DR1_v1} intersect WVCP_M) <= 1, "assertion failed: choose one of M_DR1_v*");
constraint assert(card({M_DR2_v1, M_DR2_v2, M_DR2_v3, M_DR2_v4} intersect WVCP_M) <= 1, "assertion failed: choose one of M_DR2_v*");


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

% CLIQUES
% range of cliques
set of int: CLIQUE = 1..nr_cliques;
% !! clique vertices indexed from 0 in instance file -> re-indexed from min(R_VERTEX)
array[CLIQUE] of set of VERTEX: clique = [{min(R_VERTEX)+v | v in cliques[i]} | i in index_set(cliques)];

% SCORE
% range of WVCP objective function
set of int: SCORE = lb_score..ub_score;

% GRAPH METRICS
% graph density
float: density = sum(v in R_VERTEX)(card(neighbours[v])) / max({1,(card(R_VERTEX)*(card(R_VERTEX)-1))});
