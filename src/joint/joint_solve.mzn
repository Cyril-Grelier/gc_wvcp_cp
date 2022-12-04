%% Command
%
% minizinc --solver or-tools --time-limit 3600000 --parallel 1 --compiler-statistics --solver-statistics --intermediate \
% -D "MWSSP_WVCP_SEARCH_STRATEGY=MWSSP" -D "WVCP_SEARCH_STRATEGY=VERTICES_GENERIC" -D "WVCP_SEARCH_RESTART=RESTART_NONE" \
% -D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_MIN" \
% -D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" -D "WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT" \
% -D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" -D "WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT" \
% -D "MWSSP_SEARCH_STRATEGY=ARCS_SPECIFIC" -D "MWSSP_SEARCH_RESTART=RESTART_NONE" \
% -D "MWSSP_SEARCH_VARIABLES_ARCS=DESC_WEIGHT_TAIL" -D "MWSSP_SEARCH_DOMAIN_ARCS=INDOMAIN_MAX" \
% -D "WVCP_B={UB_COLORS,UB_SCORE}" -D "WVCP_M={}" \
% -m joint/joint_solve.mzn \
% -d core/default_ub_colors.dzn -d core/default_ub_score.dzn -d core/no_cliques.dzn -d ../original_wvcp_dzn/p40.dzn


include "joint.mzn";
include "joint_heuristics.mzn";
include "joint_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

solve :: mwssp_wvcp_search() :: mwssp_wvcp_restart()
%   seq_search([
%    int_search(x_color,first_fail,indomain_split),
%    int_search(y_arc,input_order,indomain_max)
%   ])
  minimize(x_score);
%  maximize(y_score);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

output
			show_instance()
	++  SNL 
% 	++ ["**************************"] ++ SNL
% 	++	
% 			show_flags()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_wvcp_rules()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_mwssp_wvcp_heuristics()
% 	++  SNL
% 	++	
% 			show_wvcp_heuristics()
% 	++  SNL
% 	++	
% 			show_mwssp_heuristics()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_wvcp_solution()
% 	++  SNL
% 	++	
% 			show_mwssp_solution()
% 	++  SNL ++ ["**************************"] ++ SNL
	++	
			show_wvcp_score()
	++  SNL
	++	
			show_mwssp_score()
;
