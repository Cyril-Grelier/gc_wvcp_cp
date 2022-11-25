%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

array[int] of string: SNL = ["\n"];
array[int] of string: STAB = ["\t"];
array[int] of string: SEP = ["**************************"];

function array[int] of string: show_size() =
			["Instance"]
	++  STAB
	++		["colors=" ++ show(card(COLOR))]
	++  STAB
	++  ["vertices=" ++ show(card(R_VERTEX))]
	++  STAB
	++		["density=" ++ show(round(100*density)) ++ "%"]
	++		STAB
	++		["weights=" ++ "[" ++ show(min(WEIGHT_SCALE)) ++ "..." ++ show(max(WEIGHT_SCALE)) ++ "]" ++ " #weights=" ++ show(card(WEIGHT_SCALE)) ++ " mean=" ++ show(round(sum(weight)/card(R_VERTEX)))];

function array[int] of string: show_weights() =
	["Weights\t\t"] ++ [show(v) ++ "-" ++ show(weight[v]) ++ " " | v in R_VERTEX];

function array[int] of string: show_neighbours() =
	["Neighbours\t\t"] ++ [show(v) ++ "-" ++ show(neighbours[v]) ++ " " | v in R_VERTEX];
	
function array[int] of string: show_cliques() =
	if(M_CLIQUES in WVCP_MODEL)
	then	["Cliques\t\t" ++ show(clique)]
	else [""]
	endif;

function array[int] of string: show_flags() =
			["Flags\t\t"]
	++		["I_SORT=" ++ show(I_SORT)]
	++  STAB
	++		["WVCP_BOUNDS=" ++ show(WVCP_B)]
	++  STAB
	++		["WVCP_MODEL=" ++ show(WVCP_M)];

function array[int] of string: show_instance() =
			show_size()
% 	++  SNL
% 	++		show_weights()
% 	++  SNL
% 	++		show_neighbours()
% 	++  SNL
% 	++		show_cliques()
;

%date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate -D WVCP_SEARCH_STRATEGY=VERTICES_GENERIC -D WVCP_SEARCH_RESTART=RESTART_NONE -D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" -D WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_MIN -D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" -D WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT -D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" -D WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT wvcp_solve.mzn no_cliques.dzn no_ub_colors.dzn no_ub_score.dzn -D "WB={}" -D "WM={S_R2}" ../original_wvcp_dzn/p40.dzn; beep;

