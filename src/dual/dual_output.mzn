%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

include "../core/instance_output.mzn";

%%
function array[int] of string: show_mwssp_heuristics() =
	["MWSSP heurist."]
	++		STAB
	++	["MWSSP_SEARCH_STRATEGY\t\t=" ++ show(MWSSP_SEARCH_STRATEGY) ++ "\t+\t" ++ "MWSSP_SEARCH_RESTART\t\t=" ++ show(MWSSP_SEARCH_RESTART)]
	++		SNL
	++		STAB	++	STAB	++			["MWSSP_SEARCH_VARIABLES_ARCS\t=" ++ show(MWSSP_SEARCH_VARIABLES_ARCS) ++ "\t+\t" ++ "MWSSP_SEARCH_DOMAIN_ARCS\t=" ++ show(MWSSP_SEARCH_DOMAIN_ARCS)]
	;

%%
function array[int] of string: show_mwssp_solution() =
% 	["D - I - L - C"]
% 	++		STAB
% 	++ [show(fix(sum(x_d)))] ++ [" / "] ++ [show(fix(sum(x_ci)))] ++ [" / "] ++ [show(fix(sum(x_cal)))] ++ [" / "] ++ [show(fix(sum(x_cac)))]
% 	++		SNL
	["Stars\t\t"] ++ [if fix(y_arc[e])=1 then "(" ++ show(tail[e]) ++ "," ++ show(head[e]) ++ ") " else "" endif | e in ARC]
% 	++		SNL
% 	++		STAB	++	STAB	++  ["(" ++ show(tail[e]) ++ "," ++ show(head[e]) ++ ") " | e in sort_arcs(set2array(index_set(ARC)))]
	;

%%
function array[int] of string: show_mwssp_score() =
			["MWSSP->WVCP scores"]
	++		STAB
	++		[show(lb_score) ++ " <= " ++ show(yx_score) ++ " (" ++ show(y_score) ++ ") <= " ++ show(ub_score) ++ " <= " ++ show(sum(r_weight))]
	++  SNL
	++		STAB	++	STAB
	++		["colors\t"] ++ [show(lb_colors) ++ " <= " ++ show(yx_opened_colors) ++ " <= " ++ show(ub_colors) ++ " <= " ++ show(card(R_VERTEX))]
	;
