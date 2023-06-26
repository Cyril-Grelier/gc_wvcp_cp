%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Lesaint (david.lesaint@univ-angers.fr)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN FILE TO RUN DUAL MODEL


include "../dual/dual.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAMPLE COMMAND TO RUN DUAL

% minizinc --solver or-tools --time-limit 600000 --parallel 1 --compiler-statistics --solver-statistics --intermediate \
% -D "DUAL_STRATEGY=ARCS_SPECIFIC"	-D "DUAL_RESTART=RESTART_NONE" \
% -D "DUAL_H_VAR_ARCS=DESC_WEIGHT_TAIL"		-D "DUAL_H_VAL_ARCS=INDOMAIN_MAX" \
% -D "WVCP_M={M_DG}" \
% -m dual/dual_solve.mzn \
% -d core/default_lb_colors.dzn -d core/default_ub_colors.dzn -d core/default_lb_score.dzn -d core/default_ub_score.dzn -d core/no_cliques.dzn \
% -d ../reduced_wvcp_dzn/p40.dzn



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SEARCH

solve
	:: mwssp_search()
	:: mwssp_restart()
  maximize y_o
%  maximize(if M_GCP in WVCP_M then card(K)-y_KOS else y_o endif)
	;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DISPLAY

output
			SNL ++ ["**************************"] ++ SNL
	++		show_instance()
	++		SNL
	++		show_flags()
	++		SNL
 	++		show_mwssp_strategy()
	++		SNL
 	++		show_mwssp_heuristics()
% 	++  SNL
% 			show_mwssp_solution()
 	++		SNL
 	++		show_mwssp_score()
;
