%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERIC SEARCH STRATEGY ANNOTATIONS

%include "chuffed.mzn"; % for random_order heuristic on variables
%include "gecode.mzn"; % for random heuristic on variables


% RESTART ANNOTATIONS

enum SEARCH_RESTART = {
  RESTART_NONE,
  RESTART_CONSTANT,
  RESTART_LINEAR,
  RESTART_GEOMETRIC,
  RESTART_LUBY
};


function ann: restart(SEARCH_RESTART: flag, int: scale, float: base) =
  if     flag=RESTART_NONE
  then   restart_none
  elseif flag=RESTART_CONSTANT
  then   restart_constant(scale)
  elseif flag=RESTART_LINEAR
  then   restart_linear(scale)
  elseif flag=RESTART_GEOMETRIC
  then   restart_geometric(base,scale)
  elseif flag=RESTART_LUBY
  then   restart_luby(scale)
  else   restart_none
  endif;
  

% VARIABLE CHOICE ANNOTATIONS

enum SEARCH_VARIABLES = {
  ANTI_FIRST_FAIL,
  DOM_W_DEG,
  FIRST_FAIL,
  IMPACT,
  INPUT_ORDER,
  LARGEST,
  MAX_REGRET,
  MOST_CONSTRAINED,
  OCCURRENCE,
%   RANDOM,% for GECODE
%   RANDOM_ORDER,% for Chuffed
  SMALLEST
};


% https://www.minizinc.org/doc-2.6.2/en/lib-stdlib-annotations.html#search-annotations
% variables: anti_first_fail | dom_w_deg | first_fail | impact | input_order | largest | max_regret | most_constrained | occurrence | random (gecode) | random_order (chuffed) | smallest
function ann: heuristic_variables(SEARCH_VARIABLES: flag) =
  if      flag=ANTI_FIRST_FAIL
  then    anti_first_fail
  elseif  flag=DOM_W_DEG
  then    dom_w_deg
  elseif  flag=FIRST_FAIL
  then    first_fail
  elseif  flag=IMPACT
  then    impact
  elseif  flag=INPUT_ORDER
  then    input_order
  elseif  flag=LARGEST
  then    largest
  elseif  flag=MAX_REGRET
  then    max_regret
  elseif  flag=MOST_CONSTRAINED
  then    most_constrained
  elseif  flag=OCCURRENCE
  then    occurrence
%   elseif  flag=RANDOM
%   then    random% !! for GECODE
%   elseif  flag=RANDOM_ORDER
%   then    random_order % !! for Chuffed
  elseif  flag=SMALLEST
  then    smallest
  else    input_order
  endif;


% VALUE CHOICE ANNOTATIONS

enum SEARCH_DOMAIN = {
  INDOMAIN,
  INDOMAIN_INTERVAL,
  INDOMAIN_MAX,
  INDOMAIN_MEDIAN,
  INDOMAIN_MIDDLE,
  INDOMAIN_MIN,
  INDOMAIN_RANDOM,
  INDOMAIN_REVERSE_SPLIT,
  INDOMAIN_SPLIT,
  INDOMAIN_SPLIT_RANDOM,
  OUTDOMAIN_MAX,
  OUTDOMAIN_MEDIAN,
  OUTDOMAIN_MIN,
  OUTDOMAIN_RANDOM
};


% https://www.minizinc.org/doc-2.6.2/en/lib-stdlib-annotations.html#search-annotations
% values:    indomain | indomain_interval | indomain_max | indomain_median | indomain_middle | indomain_min | indomain_random | indomain_reverse_split | indomain_split | indomain_split_random | outdomain_max | outdomain_median | outdomain_min | outdomain_random
function ann: heuristic_domain(SEARCH_DOMAIN: flag) =
  if      flag=INDOMAIN
  then    indomain
  elseif  flag=INDOMAIN_INTERVAL
  then    indomain_interval
  elseif  flag=INDOMAIN_MAX
  then    indomain_max
  elseif  flag=INDOMAIN_MEDIAN
  then    indomain_median
  elseif  flag=INDOMAIN_MIDDLE
  then    indomain_middle
  elseif  flag=INDOMAIN_MIN
  then    indomain_min
  elseif  flag=INDOMAIN_RANDOM
  then    indomain_random
  elseif  flag=INDOMAIN_REVERSE_SPLIT
  then    indomain_reverse_split
  elseif  flag=INDOMAIN_SPLIT
  then    indomain_split
  elseif  flag=INDOMAIN_SPLIT_RANDOM
  then    indomain_split_random
  elseif  flag=OUTDOMAIN_MAX
  then    outdomain_max
  elseif  flag=OUTDOMAIN_MEDIAN
  then    outdomain_median
  elseif  flag=OUTDOMAIN_MIN
  then    outdomain_min
  elseif  flag=OUTDOMAIN_RANDOM
  then    outdomain_random
  else    indomain
  endif;
