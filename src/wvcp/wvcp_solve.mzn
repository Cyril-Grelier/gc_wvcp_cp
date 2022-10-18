include "wvcp_heuristics.mzn";
include "../instance_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

%TODO restart annotation raises error/warning '% Error in search annotation: Unknown search annotation. Ignore search annotation!'
solve :: wvcp_search() :: wvcp_restart()
  minimize(x_score);
%  satisfy;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

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

function array[int] of string: show_wvcp_solution() =
			["WVCP solution"]
	++		STAB
	++		["Coloring\t\t"] ++ [show(v) ++ "=" ++ show(x_color[v]) ++ " " | v in R_VERTEX]
	++		SNL
	++		STAB	++	STAB
	++  ["Partitioning\t\t"] ++ [show(c) ++ "=" ++ show(x_vertices[c]) ++ " " | c in COLOR where fix(x_used[c])]
	++  SNL
	++		STAB	++	STAB
	++  ["Weighting\t\t"] ++ [show(c) ++ "=" ++ show(x_weight[c]) ++ " " | c in COLOR where fix(x_used[c])];

function array[int] of string: show_wvcp_score() =
			["WVCP scores"]
	++		STAB
	++		["Score\t" ++ show(x_score) ++ " <= " ++ show(ub_score) ++ " <= " ++ show(sum(weight))]
	++  SNL
	++		STAB	++	STAB
	++		["Colors\t"] ++ [show(x_nr_used) ++ " <= " ++ show(card(R_VERTEX))];

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

output
			SNL
% 	++		show_instance()
% 	++  SNL
% 	++  ["**************************"]
% 	++  SNL
% 	++		show_flags()
% 	++		SNL
% 	++  ["**************************"]
% 	++  SNL
% 	++		show_wvcp_heuristics()
% 	++  SNL
% 	++		show_wvcp_solution()
% 	++  SNL
	++		show_wvcp_score()
% 	++  SNL
% 	++		show_wvcp_rules()
;

%date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate -D WVCP_SEARCH_STRATEGY=VERTICES_GENERIC -D WVCP_SEARCH_RESTART=RESTART_NONE -D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" -D WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_MIN -D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" -D WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT -D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" -D WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT wvcp_solve.mzn no_cliques.dzn no_ub_colors.dzn no_ub_score.dzn -D "WVCP_B={}" -D "WVCP_M={M_SORT}" ../original_wvcp_dzn/p40.dzn; beep;

