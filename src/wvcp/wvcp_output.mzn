%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

include "../instance_output.mzn";


%%
function array[int] of string: show_wvcp_heuristics() =
			["WVCP heuristics"]
	++		STAB
	++		["WVCP_SEARCH_STRATEGY\t\t=" ++ show(WVCP_SEARCH_STRATEGY) ++ "\t+\t" ++ "WVCP_SEARCH_RESTART\t\t=" ++ show(WVCP_SEARCH_RESTART)]
	++		SNL
	++		STAB	++	STAB	++	["WVCP_SEARCH_VARIABLES_VERTICES\t=" ++ show(WVCP_SEARCH_VARIABLES_VERTICES) ++ "\t+\t" ++ "WVCP_SEARCH_DOMAIN_VERTICES\t=" ++ show(WVCP_SEARCH_DOMAIN_VERTICES)]
	++		SNL
	++		STAB	++	STAB	++	["WVCP_SEARCH_VARIABLES_WEIGHTS\t=" ++ show(WVCP_SEARCH_VARIABLES_WEIGHTS) ++ "\t+\t" ++ "WVCP_SEARCH_DOMAIN_WEIGHTS\t=" ++ show(WVCP_SEARCH_DOMAIN_WEIGHTS)]
	++		SNL
	++		STAB	++	STAB	++	["WVCP_SEARCH_VARIABLES_COLORS\t=" ++ show(WVCP_SEARCH_VARIABLES_COLORS) ++ "\t+\t" ++ "WVCP_SEARCH_DOMAIN_COLORS\t=" ++ show(WVCP_SEARCH_DOMAIN_COLORS)];

%%
function array[int] of string: show_wvcp_solution() =
			["WVCP solution"]
	++		STAB
	++		["Coloring\t"] ++ [show(v) ++ "=" ++ show(x_color[v]) ++ " " | v in R_VERTEX]
	++		SNL
	++		STAB	++	STAB
	++  ["Partitioning\t"] ++ [show(c) ++ "=" ++ show(x_vertices[c]) ++ " " | c in COLOR where fix(x_used[c])]
	++  SNL
	++		STAB	++	STAB
	++  ["Weighting\t"] ++ [show(c) ++ "=" ++ show(x_weight[c]) ++ " " | c in COLOR where fix(x_used[c])];

%%
function array[int] of string: show_wvcp_score() =
			["WVCP scores"]
	++		STAB
	++		[show(x_score) ++ " <= " ++ show(ub_score) ++ " <= " ++ show(sum(weight))]
	++  SNL
	++		STAB	++	STAB
	++		["Colors\t"] ++ [show(x_nr_used) ++ " <= " ++ show(card(R_VERTEX))];

%%
function array[int] of string: show_wvcp_rules() =
			["WVCP rules"]
	++		STAB
	++		["S-GDV="] ++ [show(count_SGDV())]
	++		STAB
	++  ["D-GDV="] ++ [show(count_DGDV())]
	++		STAB
	++  ["S-HDC="] ++ [show(count_SGDC())]
	++		STAB
	++  ["D-HDC="] ++ [show(count_DGDC())];