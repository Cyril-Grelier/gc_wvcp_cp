%% Command
%
% minizinc --solver or-tools --time-limit 300000 --parallel 8 --compiler-statistics --solver-statistics --intermediate \
% -D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" -D "WVCP_SEARCH_RESTART=RESTART_NONE" \
% -D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_SPLIT" \
% -D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" \
% -D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" -D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" \
% -D "WVCP_B={UB_COLORS,UB_SCORE}" -D "WVCP_M={M_SR1,M_DR2}" \
% -d core/default_ub_colors.dzn -d core/default_ub_score.dzn -d core/no_cliques.dzn -d ../original_wvcp_dzn/p06.dzn \
% -m ./primal/primal_solve.mzn


include "primal.mzn";
include "primal_heuristics.mzn";
include "primal_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

solve :: wvcp_search() :: wvcp_restart()
  minimize(x_score);
%  satisfy;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

output
			SNL
	++
			show_instance()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++
% 			show_flags()
% 	++	SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_wvcp_heuristics()
% 	++  SNL
% 	++	
% 			show_wvcp_solution()
	++  SNL
	++	
			show_wvcp_score()
	++  SNL
	++	
			show_wvcp_rules()
;
