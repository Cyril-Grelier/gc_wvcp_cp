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
  WEIGHTS_VERTICES
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
  elseif  WVCP_SEARCH_STRATEGY=WEIGHTS_VERTICES
  then    seq_search(
            [
%             int_search([x_opened_colors],wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_COLORS),heuristic_domain(WVCP_SEARCH_DOMAIN_COLORS)),
            int_search(x_weight_colors,wvcp_heuristic_variables(WVCP_SEARCH_VARIABLES_WEIGHTS),heuristic_domain(WVCP_SEARCH_DOMAIN_WEIGHTS))]
            ++ split_vertices_by_weight(weight_vertices))
  else    int_search(x_color,input_order,indomain)
  endif;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLE CHOICE STRATEGIES

enum WVCP_SEARCH_VARIABLES = WVCPSV(SEARCH_VARIABLES) ++ {DESC_DEGREE, DESC_WEIGHT, DESC_WEIGHT_DEGREE};


WVCP_SEARCH_VARIABLES: WVCP_SEARCH_VARIABLES_VERTICES;
WVCP_SEARCH_VARIABLES: WVCP_SEARCH_VARIABLES_WEIGHTS;
WVCP_SEARCH_VARIABLES: WVCP_SEARCH_VARIABLES_COLORS;


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VALUE CHOICE STRATEGIES

SEARCH_DOMAIN: WVCP_SEARCH_DOMAIN_VERTICES;
SEARCH_DOMAIN: WVCP_SEARCH_DOMAIN_WEIGHTS;
SEARCH_DOMAIN: WVCP_SEARCH_DOMAIN_COLORS;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESTART STRATEGY

SEARCH_RESTART: WVCP_SEARCH_RESTART;


function ann: wvcp_restart() =
  let {
    par int: scale = card(R_VERTEX); %TODO review
    float: base = 1.5;
  } in
  restart(WVCP_SEARCH_RESTART,scale,base);
