%% Command
%
% minizinc --solver or-tools --time-limit 3600000 --parallel 1 --compiler-statistics --solver-statistics --intermediate \
% -D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" -D "MWSSP_SEARCH_RESTART=RESTART_NONE" \
% -D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" -D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" \
% -D "WVCP_M={M_SR2, M_DR2_v2}" \
% -m dual/dual_solve.mzn \
% -d core/default_lb_colors.dzn -d core/default_ub_colors.dzn -d core/default_lb_score.dzn -d core/default_ub_score.dzn -d core/no_cliques.dzn -d ../original_wvcp_dzn/p40.dzn


include "dual.mzn";
include "dual_heuristics.mzn";
include "dual_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

solve :: mwssp_search() :: mwssp_restart()
  minimize(yx_score);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

output
% 			show_instance()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_flags()
% 	++	SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_mwssp_heuristics()
% 	++  SNL
% 	++	
% 			show_mwssp_solution()
% 	++  SNL
% 	++
			show_mwssp_score()
;
