%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMAND
%
% minizinc --solver or-tools --time-limit 300000 --parallel 1 --compiler-statistics --solver-statistics --intermediate \
% -D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" -D "WVCP_SEARCH_RESTART=RESTART_NONE" \
% -D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_SPLIT" \
% -D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" \
% -D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" -D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" \
% -D "WVCP_B={UB_COLORS,UB_SCORE}" -D "WVCP_M={M_SR1,M_DR2}" \
% -m ./primal/primal_solve.mzn \
% -d core/default_ub_colors.dzn -d core/default_ub_score.dzn -d core/no_cliques.dzn -d ../original_wvcp_dzn/p06.dzn


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILE INCLUSION

include "../core/data.mzn";
include "../primal/primal_data.mzn";
include "../primal/primal_variables.mzn";
include "../primal/primal_constraints.mzn";
include "../primal/primal_rules.mzn";
include "../primal/primal_rule_R1.mzn";
include "../primal/primal_rule_R2.mzn";
include "../primal/primal_objective.mzn";
include "primal_heuristics.mzn";
include "primal_output.mzn";


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
