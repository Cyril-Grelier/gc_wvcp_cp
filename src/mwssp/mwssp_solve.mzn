include "mwssp_heuristics.mzn";
include "../instance_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

solve :: mwssp_search() :: mwssp_restart()
  maximize(y_score);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

function array[int] of string: show_mwssp_heuristics() =
			["MWSSP heurist."]
	++		STAB
	++	["MWSSP_SEARCH_STRATEGY\t\t=" ++ show(MWSSP_SEARCH_STRATEGY) ++ "\t+\t" ++ "MWSSP_SEARCH_RESTART\t\t=" ++ show(MWSSP_SEARCH_RESTART)]
	++		SNL
	++		STAB	++	STAB	++			["MWSSP_SEARCH_VARIABLES_ARCS\t=" ++ show(MWSSP_SEARCH_VARIABLES_ARCS) ++ "\t+\t" ++ "MWSSP_SEARCH_DOMAIN_ARCS\t=" ++ show(MWSSP_SEARCH_DOMAIN_ARCS)];

function array[int] of string: show_mwssp_solution() =
			["MWSSP sol."]
	++		STAB
	++  ["Stars\t\t"] ++ [if fix(y_arc[e])=1 then "(" ++ show(tail[e]) ++ "," ++ show(head[e]) ++ ") " else "" endif | e in ARC]
	++		SNL
	++		STAB	++	STAB	++  ["(" ++ show(tail[e]) ++ "," ++ show(head[e]) ++ ") " | e in sort_arcs(set2array(index_set(ARC)))];

function array[int] of string: show_mwssp_score() =
			["MWSSP scores"]
	++		STAB
	++		["Score\t" ++ show(y_score) ++  " <= " ++  show(ub_score) ++  " <= " ++  show(sum(weight))];

output
% 			show_instance()
% 	++  SNL
% 	++  ["**************************"]
% 	++  SNL
% 	++		show_flags()
% 	++		SNL
% 	++  ["**************************"]
% 	++  SNL
% 	++	show_mwssp_heuristics()
% 	++  SNL
% 	++		show_mwssp_solution()
% 	++  SNL
			show_mwssp_score()
;
