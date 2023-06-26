%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Lesaint (david.lesaint@univ-angers.fr)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN FILE TO RUN JOINT MODEL


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAMPLE COMMAND TO RUN JOINT MODEL

% minizinc --solver or-tools --time-limit 600000 --parallel 1 --compiler-statistics --solver-statistics --intermediate \
% -D "JOINT_STRATEGY=PRIMAL" \
% -D "PRIMAL_STRATEGY=VERTICES_BY_WEIGHT"				-D "PRIMAL_RESTART=RESTART_NONE" \
% -D "PRIMAL_H_VAR_VERTICES=WVCPSV(FIRST_FAIL)"	-D "PRIMAL_H_VAL_VERTICES=INDOMAIN_SPLIT" \
% -D "PRIMAL_H_VAR_COLORS=INPUT_ORDER"						-D "PRIMAL_H_VAL_COLORS=INDOMAIN_MIN" \
% -D "PRIMAL_H_VAR_WEIGHTS=INPUT_ORDER"					-D "PRIMAL_H_VAL_WEIGHTS=INDOMAIN_SPLIT" \
% -D "DUAL_STRATEGY=ARCS_SPECIFIC"							-D "DUAL_RESTART=RESTART_NONE" \
% -D "DUAL_H_VAR_ARCS=DESC_WEIGHT_TAIL"					-D "DUAL_H_VAL_ARCS=INDOMAIN_MAX" \
% -D "WVCP_M={M_DG,M_MLS}" \
% -m joint/joint_solve.mzn \
% -d core/default_lb_colors.dzn -d core/default_ub_colors.dzn -d core/default_lb_score.dzn -d core/default_ub_score.dzn -d core/no_cliques.dzn \
% -d ../reduced_wvcp_dzn/p40.dzn


include "joint.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SEARCH

solve
	:: mwssp_wvcp_search()
	:: mwssp_wvcp_restart()
	minimize x_o
% 	minimize(if M_GCP in WVCP_M then x_KOS else x_o endif) % slows down
	;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DISPLAY

output
			SNL ++ ["**************************"] ++ SNL
	++		show_instance()
	++		SNL
	++		show_flags()
	++		SNL
	++		show_mwssp_wvcp_heuristics()
	++		SNL
	++		show_wvcp_strategy()
	++		SNL
	++		show_mwssp_strategy()
	++		SNL
	++		show_wvcp_heuristics()
%	++  SNL
% 	++		show_wvcp_solution()
	++  SNL
 	++		show_mwssp_heuristics()
% 	++  SNL
% 			show_mwssp_solution()
% 	++		SNL
% 	++		show_mwssp_score()
	++  SNL
	++		show_wvcp_score()
	++  SNL
	++		show_wvcp_metrics()
;
