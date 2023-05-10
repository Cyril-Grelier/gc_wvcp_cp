%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WVCP HEURISTICS


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEARCH STRATEGIES

enum WVCP_SEARCH = {
  VERTICES_GENERIC,
  VERTICES_SPECIFIC,
  VERTICES_BY_WEIGHT,
  WEIGHTS,
  COLORS,
  COLORS_VERTICES,
  WEIGHTS_VERTICES,
  ARCS,
  NEIGHBOURS
};


WVCP_SEARCH: WVCP_SEARCH_STRATEGY;


function ann: wvcp_search() =
  if      WVCP_SEARCH_STRATEGY=VERTICES_GENERIC
  then    int_search(x_color,wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_VERTICES),heuristic_domain(WVCP_SEARCH_DOMAIN_VERTICES))
  elseif  WVCP_SEARCH_STRATEGY=VERTICES_SPECIFIC
  then    int_search(sort_vertex_variables(),input_order,heuristic_domain(WVCP_SEARCH_DOMAIN_VERTICES))
  elseif  WVCP_SEARCH_STRATEGY=VERTICES_BY_WEIGHT
  then    seq_search(split_vertices_by_weight(weight_vertices))
  elseif  WVCP_SEARCH_STRATEGY=WEIGHTS
  then    int_search(x_weight,wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_WEIGHTS),heuristic_domain(WVCP_SEARCH_DOMAIN_WEIGHTS))
  elseif  WVCP_SEARCH_STRATEGY=COLORS
  then    int_search([x_opened_colors],wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_COLORS),heuristic_domain(WVCP_SEARCH_DOMAIN_COLORS))
  elseif  WVCP_SEARCH_STRATEGY=COLORS_VERTICES
  then    seq_search(
            [int_search([x_opened_colors],wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_COLORS),heuristic_domain(WVCP_SEARCH_DOMAIN_COLORS)),
            int_search(x_color,wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_VERTICES),heuristic_domain(WVCP_SEARCH_DOMAIN_VERTICES))])
% TODO uncomment if x_weight_colors made global
%   elseif  WVCP_SEARCH_STRATEGY=WEIGHTS_VERTICES
%   then    seq_search(
%             [
% %             int_search([x_opened_colors],wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_COLORS),heuristic_domain(WVCP_SEARCH_DOMAIN_COLORS)),
%             int_search(x_weight_colors,wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_WEIGHTS),heuristic_domain(WVCP_SEARCH_DOMAIN_WEIGHTS))]
%             ++ split_vertices_by_weight(weight_vertices))
% TODO uncomment if x_arc made global
%   elseif  WVCP_SEARCH_STRATEGY=ARCS
%   then    seq_search(
%             [
%             % !! TODO change to WVCP_SEARCH_VARIABLES_ARCS
%             int_search(sort_primal_arc_variables(), input_order, heuristic_domain(WVCP_SEARCH_DOMAIN_WEIGHTS))]
%             ++ split_vertices_by_weight(weight_vertices))
  elseif  WVCP_SEARCH_STRATEGY=NEIGHBOURS
  then    int_search([x_color[u] | u in flattened_neighbours], input_order, heuristic_domain(WVCP_SEARCH_DOMAIN_VERTICES))
  else    int_search(x_color,input_order,indomain)
  endif;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLE CHOICE STRATEGIES

enum WVCP_SEARCH_VARIABLES = WVCPSV(SEARCH_VARIABLES) ++ {DESC_DEGREE, DESC_WEIGHT, DESC_WEIGHT_DEGREE, ASC_WEIGHT_DIFF};


WVCP_SEARCH_VARIABLES: WVCP_SEARCH_VARIABLES_VERTICES;
WVCP_SEARCH_VARIABLES: WVCP_SEARCH_VARIABLES_WEIGHTS;
WVCP_SEARCH_VARIABLES: WVCP_SEARCH_VARIABLES_COLORS;
% WVCP_SEARCH_VARIABLES: WVCP_SEARCH_VARIABLES_ARCS; % TODO


function array[int] of ann: split_vertices_by_weight(array[int] of set of VERTEX: wv) =
  if card(index_set(wv))=1
  then
  			[int_search([x_color[i] | i in wv[min(index_set(wv))]],wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_VERTICES),heuristic_domain(WVCP_SEARCH_DOMAIN_VERTICES))]
  	else
  			[int_search([x_color[i] | i in wv[min(index_set(wv))]],wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_VERTICES),heuristic_domain(WVCP_SEARCH_DOMAIN_VERTICES))]
			++
			split_vertices_by_weight(wv[min(index_set(wv))+1..max(index_set(wv))])
  endif;


function ann: wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES: flag) =
  heuristic_variables(WVCPSV^-1(flag));


function array[int] of var COLOR: sort_vertex_variables() = 
  let {
  		array[index_set(x_color)] of index_set(x_color): permutation = array1d(index_set(x_color),sort_vertices(set2array(index_set(x_color))));
  } in
  		[x_color[permutation[i]] | i in index_set(permutation)];


function array[int] of int: sort_vertices(array[int] of int: V) = 
  if      WVCP_SEARCH_VARIABLES_VERTICES=DESC_WEIGHT
  then    sort_by(V,[-weight[V[i]] | i in index_set(V)])
  elseif  WVCP_SEARCH_VARIABLES_VERTICES=DESC_DEGREE
  then    sort_by(V,[-card(neighbours[V[i]]) | i in index_set(V)])
  elseif  WVCP_SEARCH_VARIABLES_VERTICES=DESC_WEIGHT_DEGREE
  then    sort_by(V,[-card(VERTEX)*weight[V[i]] - card(neighbours[V[i]]) | i in index_set(V)])
  else    V
  endif;

% TODO uncomment if x_arc made global
% function array[int] of var 0..1: sort_primal_arc_variables() = 
%   let {
% 		% number of arcs
% 		int: nr_primal_arcs = sum(r_degree) div 2;
% 		% set of arcs
% 		set of int: P_ARC = 1..nr_primal_arcs;
% 		% successors of nodes by orientating each arc by decreasing weights
% 		array[R_VERTEX] of set of R_VERTEX: p_successors = [{v | v in neighbours[u] where greater(u,v)} | u in R_VERTEX];
% 		% arc tails and heads
% 		array[P_ARC] of R_VERTEX: p_tail = [u | u in R_VERTEX, v in p_successors[u]];
% 		array[P_ARC] of R_VERTEX: p_head = [v | u in R_VERTEX, v in p_successors[u]];

%   		array[int] of var 0..1: x = [x_arc[u,i] | u in R_VERTEX, i in STRICT_R_DEGREE where i<=r_degree[u] /\ greater(u,lookup_neighbour(u,i))];  		
%   		array[index_set(x)] of index_set(x): permutation = array1d(index_set(x),sort_primal_arcs(set2array(index_set(x)), p_tail, p_head));
%   } in
%   		[x[permutation[i]] | i in index_set(permutation)]
%   	;


% !! TODO change to WVCP_SEARCH_VARIABLES_ARCS
function array[int] of int: sort_primal_arcs(array[int] of int: A, array[int] of int: p_tail, array[int] of int: p_head) = 
%   if      WVCP_SEARCH_VARIABLES_WEIGHTS=DESC_WEIGHT_TAIL
%   then    sort_by(A,[-weight[p_tail[A[i]]] | i in index_set(A)])
%   elseif  WVCP_SEARCH_VARIABLES_WEIGHTS=DESC_DEGREE_TAIL
%   then    sort_by(A,[-card(neighbours[p_tail[A[i]]]) | i in index_set(A)])
%   elseif  WVCP_SEARCH_VARIABLES_WEIGHTS=DESC_TAIL
%   then    sort_by(A,[-card(NODE)*weight[p_tail[A[i]]] - card(neighbours[p_tail[A[i]]]) | i in index_set(A)])
%   elseif
  if  WVCP_SEARCH_VARIABLES_WEIGHTS=ASC_WEIGHT_DIFF
  then    sort_by(A, [(weight[p_tail[A[i]]] - weight[p_head[A[i]]]) | i in index_set(A)])
  else    A
  endif;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VALUE CHOICE STRATEGIES

SEARCH_DOMAIN: WVCP_SEARCH_DOMAIN_VERTICES;
SEARCH_DOMAIN: WVCP_SEARCH_DOMAIN_WEIGHTS;
SEARCH_DOMAIN: WVCP_SEARCH_DOMAIN_COLORS;
% SEARCH_DOMAIN: WVCP_SEARCH_DOMAIN_ARCS; % TODO


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESTART STRATEGY

SEARCH_RESTART: WVCP_SEARCH_RESTART;


function ann: wvcp_restart() =
  let {
    par int: scale = card(R_VERTEX); %TODO review
    float: base = 1.5;
  } in
  	restart(WVCP_SEARCH_RESTART,scale,base);
