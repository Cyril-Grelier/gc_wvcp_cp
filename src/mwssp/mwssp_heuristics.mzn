%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MWSSP HEURISTICS

include "../heuristics.mzn";
include "mwssp.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEARCH STRATEGIES

enum MWSSP_SEARCH = {
  ARCS_GENERIC,
  ARCS_SPECIFIC
};


MWSSP_SEARCH: MWSSP_SEARCH_STRATEGY;


function ann: mwssp_search() =
  if      MWSSP_SEARCH_STRATEGY=ARCS_GENERIC
  then    int_search(y_arc,mwssp_heuristic_variables(MWSSP_SEARCH_VARIABLES_ARCS),heuristic_domain(MWSSP_SEARCH_DOMAIN_ARCS))
  elseif  MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC
  then    int_search(sort_arc_variables(),input_order,heuristic_domain(MWSSP_SEARCH_DOMAIN_ARCS))
  else    int_search(y_arc,input_order,indomain)
  endif;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLE CHOICE STRATEGIES

enum MWSSP_SEARCH_VARIABLES = MWSSPSV(SEARCH_VARIABLES) ++ {
  DESC_DEGREE_TAIL,  % arcs sorted by decreasing degrees of tails
  DESC_TAIL,         % arcs sorted by decreasing weights of tails with tie-breaking based on decreasing degrees of tails (in original graph)
  DESC_WEIGHT_TAIL,  % arcs sorted by decreasing weights of tails
  ASC_WEIGHT_GAP    % arcs sorted by increasing gaps between weights of their two nodes
};


MWSSP_SEARCH_VARIABLES: MWSSP_SEARCH_VARIABLES_ARCS;


function ann: mwssp_heuristic_variables(MWSSP_SEARCH_VARIABLES: flag) =
  heuristic_variables(MWSSPSV^-1(flag));


function array[int] of var 0..1: sort_arc_variables() = 
  let {
  array[index_set(y_arc)] of index_set(y_arc): permutation = array1d(index_set(y_arc),sort_arcs(set2array(index_set(y_arc))));
  } in
  [y_arc[permutation[i]] | i in index_set(permutation)];


function array[int] of int: sort_arcs(array[int] of int: A) = 
  if      MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL
  then    sort_by(A,[-weight[tail[A[i]]] | i in index_set(A)])
  elseif  MWSSP_SEARCH_VARIABLES_ARCS=DESC_DEGREE_TAIL
  then    sort_by(A,[-card(neighbours[tail[A[i]]]) | i in index_set(A)])
  elseif  MWSSP_SEARCH_VARIABLES_ARCS=DESC_TAIL
  then    sort_by(A,[-card(NODE)*weight[tail[A[i]]] - card(neighbours[tail[A[i]]]) | i in index_set(A)])
  elseif  MWSSP_SEARCH_VARIABLES_ARCS=ASC_WEIGHT_GAP
  then    sort_by(A,[(weight[tail[A[i]]] - weight[head[A[i]]]) | i in index_set(A)])
  else    A
  endif;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VALUE CHOICE STRATEGIES

SEARCH_DOMAIN: MWSSP_SEARCH_DOMAIN_ARCS;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESTART STRATEGY

SEARCH_RESTART: MWSSP_SEARCH_RESTART;


function ann: mwssp_restart() =
  let {
    par int: scale = card(ARC); %TODO review
    float: base = 1.5;
  } in
  restart(MWSSP_SEARCH_RESTART,scale,base);
