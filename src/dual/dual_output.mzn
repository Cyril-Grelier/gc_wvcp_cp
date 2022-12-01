%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

include "../core/instance_output.mzn";

%%
function array[int] of string: show_mwssp_heuristics() =
			["MWSSP heurist."]
	++		STAB
	++	["MWSSP_SEARCH_STRATEGY\t\t=" ++ show(MWSSP_SEARCH_STRATEGY) ++ "\t+\t" ++ "MWSSP_SEARCH_RESTART\t\t=" ++ show(MWSSP_SEARCH_RESTART)]
	++		SNL
	++		STAB	++	STAB	++			["MWSSP_SEARCH_VARIABLES_ARCS\t=" ++ show(MWSSP_SEARCH_VARIABLES_ARCS) ++ "\t+\t" ++ "MWSSP_SEARCH_DOMAIN_ARCS\t=" ++ show(MWSSP_SEARCH_DOMAIN_ARCS)];

%%
function array[int] of string: show_mwssp_solution() =
			["MWSSP sol."]
	++		STAB
	++  ["Stars\t\t"] ++ [if fix(y_arc[e])=1 then "(" ++ show(tail[e]) ++ "," ++ show(head[e]) ++ ") " else "" endif | e in ARC]
	++		SNL
	++		STAB	++	STAB	++  ["(" ++ show(tail[e]) ++ "," ++ show(head[e]) ++ ") " | e in sort_arcs(set2array(index_set(ARC)))];

%%
function array[int] of string: show_mwssp_score() =
			["MWSSP score + WVCP score = Sum(weights)"]
	++		STAB
	++		[show(y_score) ++  " + " ++  show(sum(weight) - y_score) ++  " = " ++  show(sum(weight))];
