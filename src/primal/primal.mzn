%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILE INCLUSION

include "../core/data.mzn";

include "alldifferent.mzn";
include "arg_min.mzn";
include "arg_max.mzn";
include "arg_sort.mzn";
% include "decreasing.mzn";
include "global_cardinality_fn.mzn";
include "int_set_channel.mzn";
include "lex_chain_greater.mzn";
% include "member.mzn";
include "strictly_increasing.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TERMINOLOGY AND DEFINITIONS
%
% A WVCP instance is a 4-uple (V,E,w) such that
% - (V,E) is an undirected graph, and
% - w:V->\mathbb{N} a function assigning a weight (positive integer) to each vertex.
%
% A k-coloring s of G is a partition {V_{s,1},...,V_{s,k}} of V in k subsets called colors.
%
% A k-coloring s is legal iff adjacent vertices in G have different colors in s. For all e in E, i=1..k: not(e subset V_{s,i}).
% The weight of color V_{s,i} (0<i<=k), denoted by w(V_{s,i}), is the maximum weight of its vertices. For all i=1..k: w(V_{s,i})=max_(u in V_{s,i})(w(u)).
% The score of s, denoted by f(s), is the sum of the weights of its colors. f(s)=sum_(i in 1..k)(w(V_{s,i})).
%
% >_{w} denotes the strict lexicographic ordering of the vertices by descending weights and, in case of ties, by ascending id. For all u,v in V: u>_{w}v <-> (w(u)>w(v) \/ (w(u)=w(v) /\ u<v) where < denotes the predefined order on vertex ids.
%
% Vertex u *dominates* vertex v, denoted by u>>v, iff the following conditions hold:
% (3.1) u and v are not adjacent
% (3.2) u >_{w} v
% (3.3) every vertex adjacent to v is adjacent to u.
%
% Given two vertices u and v and a legal coloring s of G, u *s-dominates* v, denoted by u>>_{s}v, iff the following conditions hold:
% (4.1) u and v are not adjacent
% (4.2) u >_{w} v
% (4.3) every vertex adjacent to v is either adjacent to u or does not have the color of u in s.
%
% Remarks
% - >_{w} is a strict total ordering of V.
% - >> is a strict partial ordering of V.
% - >>_{s} subsumes >>.
%
% Let s be a legal coloring of G, and u and v be two vertices, s[v->u] denotes the coloring which only differs from s on v which is given the color of u in s. For all t in V: (t!=v -> s[v->u](t)=s(t)) /\ s[v->u](v)=s(u).
%
% Let v be a vertex and s a legal coloring of G.
% (5.1) if v has a dominating vertex then s[v->u] is a legal coloring and f(s[v->u])<=f(s) where u=max_(t in V)(t>>v) is the greatest dominating vertex (GDV) of v.
% (5.2) if v has a s-dominating vertex then s[v->u] is a legal coloring and f(s[v->u])<=f(s) where u=max_(t in V)(t>>_{s}v) is the greatest s-dominating vertex (s-GDV) of v.
%
%% - Every color in a legal coloring s includes a *s-dominant* which is the unique vertex that s-dominates all other vertices in the color. d_{s,i} denotes the dominant of color V_{s,i} (i=1..k).
% >_{c} denotes the strict lexicographic ordering of the colors induced by the ordering >_{w} on their dominants. For all i,j s.t. 1<=i,j<=k: V_{s,i}>_{c}V_{s,j} <-> d_{s,i}>_{c}V_{s,j}.
%

% sorts the set of (real) vertices U in descending order of weight with >_{w}
array[int] of R_VERTEX: sort_by_desc_weight(set of R_VERTEX: U) =
	let {
	array[int] of R_VERTEX: s2a = set2array(U);
	% only used for "unsorted" models
	array[int] of R_VERTEX: as = if (M_SORT in WVCP_M) /\ I_SORT then [] else arg_sort([-weight[s2a[i]] | i in index_set(s2a)]) endif;
	} in
	if (M_SORT in WVCP_M) /\ I_SORT
	then s2a	
	else	[s2a[as[i]] | i in index_set(as) ]
	endif;

% checks whether u is greater than v (u>_{w}v)
function bool: greater(VERTEX: u, VERTEX: v) =
	if (M_SORT in WVCP_M) /\ I_SORT
	then	u<v
	else	not(weight[u]>weight[v]) -> (weight[u]=weight[v] /\ u<v)
	endif;

% returns greatest of (real) vertices in U with >_{w}
%% par version
R_VERTEX: greatest(set of R_VERTEX: U) =
	if	(M_SORT in WVCP_M) /\ I_SORT
	then	min(U)
	else	sort_by_desc_weight(U)[1]
	endif;

%% var version
var VERTEX: greatest(var set of VERTEX: U) =
	if 			(M_SORT in WVCP_M) /\ I_SORT
	% (a) constraint formulation when vertices are readily sorted in descending order of weights using >_{w}
	then	min(U)
	elseif	(M_SORT in WVCP_M) /\ not(I_SORT)
	% (b) constraint formulation when the model has sorted vertices in descending order of weights using >_{w}
	then	vertices[arg_max(i in index_set(vertices))(vertices[i] in U)]
	%	(c) constraint formulation that assumes no vertex ordering
	else	arg_max(u in VERTEX)((u in U)*(1+weight[u])) % 1+weight not to nullify virtual vertices
	endif;

% V sorted in descending order of weights with >_{w}
array[VERTEX] of VERTEX: vertices = array1d(VERTEX, sort_by_desc_weight(R_VERTEX) ++ set2array(V_VERTEX));

% the non-adjacent vertices of a vertex
array[R_VERTEX] of set of R_VERTEX: NA = array1d(R_VERTEX, [R_VERTEX diff ({v} union neighbours[v]) | v in R_VERTEX]);

% amongst the non-adjacent vertices of a vertex, the vertices greater than the vertex
array[R_VERTEX] of set of R_VERTEX: GNA = array1d(R_VERTEX, [{u | u in NA[v] where greater(u,v)} | v in R_VERTEX]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% the color of each vertex
%% every color includes a single virtual vertex which is fixed by a one-to-one map
array[VERTEX] of var COLOR: x_color;

% the vertices of each color
%% every unused color includes exactly one vertex which is its virtual vertex
array[COLOR] of var set of VERTEX: x_vertices;

% the weight of each color
%% the weight of a color is the maximum weight of its vertices
%% the weight of an unused color is 0 since all virtual vertices have weight 0
array[COLOR] of var WEIGHT: x_weight;

% whether a color is used or not
array[COLOR] of var bool: x_used = array1d(COLOR, [card(x_vertices[c])!=1 | c in COLOR]);

% the number of used colors
var COLOR: x_nr_used = sum(x_used);

% the score
%% the score is the sum of the weights of the used colors
var SCORE: x_score;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS

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
forall(v in VERTEX, u in neighbours[v] where u<v /\ (exists(k in CLIQUE)({u,v} subset clique[k]) -> not(M_CLIQUES in WVCP_M)) ) (% /\ not(M_DR2 in WVCP_M) )(
  (x_color[u] != x_color[v])
);

% (2) clique-specific coloring constraints
constraint
forall(k in CLIQUE where (M_CLIQUES in WVCP_M)) ( % /\ not(M_DR2 in WVCP_M))( 
  alldifferent([x_color[u] | u in clique[k]]) 
);

%%%%%%%%%%%%
% weights of colors

%	(a) generic constraint formulation that assumes no vertex ordering
constraint
forall(c in COLOR where not(M_SORT in WVCP_M))(
	x_weight[c] = max(u in x_vertices[c])(weight[u])
);
% (b) optimized constraint formulation when vertices are sorted in descending order of weights using >_{w}
constraint
forall(c in COLOR where M_SORT in WVCP_M)(
	x_weight[c] = weight[greatest(x_vertices[c])]
);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRY BREAKING RULES

%%%%%%%%%%%%
% lexicographic ordering constraint that sorts colors using >>_{c}

% (a) generic constraint formulation that assumes no existing ordering of vertices - uses global constraint lex_chain_greater
constraint
if not(M_SORT in WVCP_M)
then
lex_chain_greater(array2d(1..2, COLOR, x_weight ++ [max(VERTEX) - min(x_vertices[c]) | c in COLOR]))
% alternative custom formulation
% include "strictly_decreasing.mzn";
% strictly_decreasing([max(VERTEX)*x_weight[c] - min(x_vertices[c] | c in COLOR]);
endif;

% (b) optimized constraint formulation when vertices are sorted in descending order of weights using >>_{w} (check speedup factor against generic formulation on R100_1g.dzn!)
constraint
if (M_SORT in WVCP_M)
then
strictly_increasing([greatest(x_vertices[c]) | c in COLOR])
endif;



%%%%%%%%%%%%
% - Rule SR1 assigns to every vertex v the color of its greatest dominating vertex (GDV) if it exists.
% - Rule DR1 assigns to every vertex v the color of its greatest s-dominating vertex (s-GDV) if it exists.
% - Rule SR2 restricts the color of every vertex v to the first d(v)+1 greatest colors where d(v) denotes the degree of v.
% - Rule DR2 assigns to every vertex v its greatest s-dominating color (s-GDC).


%%%%%%%%%%%%
% Rule SR1 (Static Greatest Dominating Vertex)
constraint if (M_SR1 in WVCP_M) then SGDV() endif;

predicate SGDV() =
	let {
	% the dominating vertices for each vertex (>>)
	array[R_VERTEX] of set of R_VERTEX: DGNA = array1d(R_VERTEX, [{u | u in R_VERTEX where u in GNA[v] /\ neighbours[v] subset neighbours[u]} | v in R_VERTEX]);
	% the GDV of a vertex if it exists, otherwise the vertex itself
	array[R_VERTEX] of R_VERTEX: GDV = array1d(R_VERTEX, [greatest(DGNA[v] union {v}) | v in R_VERTEX]);
	} in
	% every dominated vertex has the color of its GDV if it exists or else its own color (tautology)
	forall(v in R_VERTEX)(
		x_color[v] = x_color[GDV[v]]
	);

% for output only: measures application rate of rule SGDV in a solution
function array[int] of int: count_SGDV() =
	[	
		card({v | v in R_VERTEX where GNA[v]!={}}),
		card(R_VERTEX)
	];


%%%%%%%%%%%%
% Rule DR1 (Dynamic Greatest Dominating Vertex)
constraint if (M_DR1 in WVCP_M) then DGDV() endif;

predicate DGDV() =
	let {
	% the s-GDV of each vertex if it exists, otherwise the vertex itself
	array[R_VERTEX] of var R_VERTEX: x_GDV = array1d(R_VERTEX, [xGDV(v, GNA[v]) | v in R_VERTEX]);
	} in
	% every s-dominated vertex has the color of its s-GDV if it exists or else its own color (tautology)
	forall(v in R_VERTEX)(
		x_color[v] = x_color[x_GDV[v]]
	);
	
% returns s-GDV of vertex v in current solution s if it exists else returns v
% U=GNA[v]
function var R_VERTEX: xGDV(R_VERTEX: v, set of R_VERTEX: U) =
	let {
	% the GNA vertices of vertex v sorted in descending order with >_{w} and to which v is appended
	array[int] of R_VERTEX: GNAv = sort_by_desc_weight(U) ++ [v];
	% x[i]=0 iff (i<max(index_set(GNAv)) -> GNAv[i] s-dominates v)
	% VERSION 1
	array[index_set(GNAv)] of var bool: x = [exists(w in NA[GNAv[i]] diff ({v} union NA[v]))(x_color[w] = x_color[GNAv[i]]) | i in index_set(GNAv)];
	% VERSION 2
	% 	array[index_set(GNAv)] of var bool: x = [member([x_color[w] | w in NA[GNAv[i]] diff ({v} union NA[v])], x_color[GNAv[i]]) | i in index_set(GNAv)];
	} in
	GNAv[arg_min(i in index_set(GNAv))(x[i])];

% for output only: measures application rate of rule DGDV in a solution
function array[int] of int: count_DGDV() =
	let {
	array[R_VERTEX] of R_VERTEX: fix_GDV = array1d(R_VERTEX, [fixGDV(v, GNA[v]) | v in R_VERTEX]);
	} in
	[	count(v in R_VERTEX where GNA[v]!={})(fix_GDV[v] != v /\ fix(x_color[fix_GDV[v]]) = fix(x_color[v])),
		count(v in R_VERTEX where GNA[v]!={})(fix_GDV[v] != v),
		card({v | v in R_VERTEX where GNA[v]!={}}),
		card(R_VERTEX)
	];

function int: fixGDV(R_VERTEX: v, set of R_VERTEX: U) =
	let {
	array[int] of R_VERTEX: GNAv = sort_by_desc_weight(U) ++ [v];
	array[index_set(GNAv)] of bool: x = [exists(w in NA[GNAv[i]] diff ({v} union NA[v]))(fix(x_color[w]) = fix(x_color[GNAv[i]])) | i in index_set(GNAv)];
	} in GNAv[arg_min(i in index_set(GNAv))(x[i])];

	
%%%%%%%%%%%%
% Rule SR2 (Static Greatest Dominating Color)
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

% for output only: measures application rate of rule SGDC in a solution
function array[int] of int: count_SGDC() =
	let {
	array[R_VERTEX] of 0..card(R_VERTEX): d = array1d(R_VERTEX, [card(neighbours[v]) | v in R_VERTEX]);
	} in 
	[	%count(v in R_VERTEX where d[v]<max(COLOR))(fix(x_color[v]) <= d[v] + 1),
		card({v | v in R_VERTEX where d[v]<max(COLOR)}),
		card(R_VERTEX)
	];


%%%%%%%%%%%%
% Rule DR2 (Dynamic Greatest Dominating Color)
constraint if (M_DR2 in WVCP_M) then DGDC() endif;

predicate DGDC() =
	let {
	% the s-GDC of each vertex
	array[R_VERTEX] of var COLOR: x_gdc = array1d(R_VERTEX, [GDC(v) | v in R_VERTEX]);
	} in
	%% every vertex is colored by its s-GDC
	forall(v in R_VERTEX) (
		(x_color[v] = x_gdc[v])
	);

% Returns s-GDC of vertex v
function var COLOR: GDC(R_VERTEX: v) =
	let {
	% the neighbours of each vertex sorted in descending order of weight (>_{w})
	array[int] of R_VERTEX: SN = sort_by_desc_weight(neighbours[v]);
	% candidate colors for GDC of v
	set of COLOR: C = 1..min(max(COLOR),card(index_set(SN))+1);
	% number of neighbours of v in each color of C
	array[C] of var 0..card(index_set(SN)): x = global_cardinality([x_color[SN[i]] | i in index_set(SN)], set2array(C));
	}
	% return greatest color c that includes no neighbours of v (x[c]=0)
	in arg_min(c in C)(x[c]);


% for output only: measures application rate of rule DGDC in a solution
function array[int] of int: count_DGDC() =
	let {
	array[R_VERTEX] of COLOR: x_gdc = array1d(R_VERTEX, [fix_GDC(v) | v in R_VERTEX]);
	} in 
	[	count(v in R_VERTEX)(fix(x_color[v]) = x_gdc[v]),
		card(R_VERTEX)
	];
	
function COLOR: fix_GDC(R_VERTEX: v) =
	let {
	array[int] of R_VERTEX: SN = sort_by_desc_weight(neighbours[v]);
	set of COLOR: C = 1..min(max(COLOR),card(index_set(SN))+1);
	}
	in arg_min(c in C)(exists(i in index_set(SN))(fix(x_color[SN[i]]) = c));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE FUNCTION AND BOUND CONSTRAINTS

% the score is equal to the sum of the weights of the colors since unused colors have weight 0
constraint
x_score = sum(x_weight);

% input upper bound on the number of colors
constraint
if (UB_COLORS in WVCP_B /\ ub_colors<card(COLOR))
% empties ub_colors+1-th color (restricts it to its virtual vertex) and successive colors due to symmetry breaking constraint
then card(x_vertices[ub_colors+1]) == 1
endif;

% input upper bound on score
constraint
if (UB_SCORE in WVCP_B)
then (x_score <= ub_score)
endif;

% heaviest clique provides lower bound on score
constraint
if (M_CLIQUES in WVCP_M /\ CLIQUE!={})
then
x_score >= max(k in CLIQUE)(sum([weight[u] | u in clique[k]]))
endif;

% % upper bound on score derived on the number of colors from the score
% % TODO review
% var R_VERTEX: x_ub_used;
% constraint
% x_nr_used <= x_ub_used
% /\
% x_score > sum(i in R_VERTEX)(bool2int(i<x_ub_used)*(weight[max(R_VERTEX)-i+1]))
% /\
% x_score <= sum(i in R_VERTEX)(bool2int(i<=x_ub_used)*(weight[max(R_VERTEX)-i+1]))
% ;
