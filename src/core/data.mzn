%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTANCE DATA

% instance name
string: name;
% number of vertices
int: nr_vertices;
% number of edges
int: nr_edges;
% neighborhoods
% !! vertices indexed from 0 in `neighborhoods` -> re-indexed from 1 in `neighbours`
array[int] of set of int: neighborhoods;
% weights
% !! vertices may not be sorted in descending order of weight
array[R_VERTEX] of int: weights;

% number of cliques
int: nr_cliques;
% cliques
% !! vertices indexed from 0 in `cliques` -> re-indexed from 1 in `clique`
array[CLIQUE] of set of int: cliques;
% upper bound on colors
int: ub_colors;
% upper bound on score
int: ub_score;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA ASSERTIONS

constraint assert(nr_vertices>0, "assertion failed: at least one vertex");

constraint assert(2*nr_edges = sum(i in index_set(neighborhoods))(card(neighborhoods[i])), "assertion failed: nr_edges inconsistent with total size of neighborhoods");
constraint assert(forall(i in index_set(neighborhoods))(neighborhoods[i] subset 0..nr_vertices-1), "assertion failed: neighbor out of bounds");
% not required in current instance format version
% constraint assert(forall(i in index_set(neighborhoods))(i < min(neighborhoods[i])), "assertion failed: lower ranked neighbor");

constraint assert(forall(i in index_set(weights))(weights[i]>=0), "assertion failed: negative vertex weight");
% setting flag to indicate whether vertices are readily sorted in descending order of weight
bool: I_SORT = forall(i in index_set(weights) where i<max(index_set(weights)))(weights[i]>=weights[i+1]);

constraint assert(nr_cliques = card(index_set(cliques)), "assertion failed: nr_cliques inconsistent with size of array of cliques");
constraint assert(forall(i in index_set(cliques))(cliques[i] subset 0..nr_vertices-1), "assertion failed: clique vertices out of bounds");
constraint assert(forall(i in index_set(cliques))(i-min(index_set(cliques)) in cliques[i]), "assertion failed: i-th vertex must belong to i-th clique");

constraint assert(ub_colors in 1..nr_vertices, "assertion failed: ub_colors out of bounds");
constraint assert(ub_score in 0..sum(weights), "assertion failed: ub_score out of bounds");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINT MODEL OPTIONS

% Bounds
% TODO generic flag -> rename to remove WVCP prefix
enum WVCP_BOUNDS = {
	UB_COLORS, % upper-bound on the number of colors
	UB_SCORE, % upper-bound on score
};

% Model features
% TODO WVCP-specific flags (?) -> move elsewhere
enum WVCP_MODEL = {
	M_SORT, % indicates if models sorts vertices in descending order of weight
	M_CLIQUES, % models each input clique with an all-different constraint instead of a clique of binary coloring disequality constraints
	M_SR1, % enforces Static Greatest Dominating Vertex rule
	M_DR1, % enforces Dynamic Greatest Dominating Vertex rule
	M_SR2, % enforces Static Heaviest Dominating Color rule
	M_DR2, % enforces Dynamic Heaviest Dominating Color rule
};

% DR2 model
enum DR2_MODEL = {
	M_DR2_GCC_ARGM % uses GCC + ARG_MIN
};

% Instance options
set of WVCP_BOUNDS: WVCP_B;
set of WVCP_MODEL: WVCP_M;
DR2_MODEL: WVCP_DR2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% META-MODEL ASSERTIONS

constraint assert(I_SORT -> (M_SORT in WVCP_MODEL), "assertion failed: sorted intance requires M_SORT flag");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEL DATA

% range of *real vertices*
set of int: R_VERTEX = 1..nr_vertices;
% range of colors
set of int: COLOR = 1..nr_vertices;
% range of *virtual vertices*
% one virtual vertex is defined per color
% virtual vertex of i-th color identified by max(R_VERTEX)+i
set of int: V_VERTEX = max(R_VERTEX)+1..max(R_VERTEX)+ub_colors;
% range of all vertices (real and virtual)
set of int: VERTEX = min(R_VERTEX)..max(V_VERTEX);
% range of weights
set of int: WEIGHT = 0..max(weights);
% set of weights
set of int: WEIGHT_SCALE = array2set(weights);
% range of cliques
set of int: CLIQUE = 1..nr_cliques;

% neighborhoods
% !! vertices indexed from 0 in instance file -> re-indexed from min(R_VERTEX)
% virtual vertices are disconnected
array[VERTEX] of set of VERTEX: neighbours = [{min(R_VERTEX)+j | j in neighborhoods[i]} | i in index_set(neighborhoods)] ++ [{} | v in V_VERTEX];
% weights
% virtual vertices have weight 0
array[VERTEX] of WEIGHT: weight = [weights[i] | i in index_set(weights)] ++ [0 | i in V_VERTEX];
% cliques
% !! clique vertices indexed from 0 in instance file -> re-indexed from min(R_VERTEX)
array[CLIQUE] of set of VERTEX: clique = [{min(R_VERTEX)+v | v in cliques[i]} | i in index_set(cliques)];

% range of WVCP objective function
set of int: SCORE = max(weight)..sum(weight);

% graph density
float: density = sum(v in R_VERTEX)(card(neighbours[v])) / max({1,(card(R_VERTEX)*(card(R_VERTEX)-1))});
