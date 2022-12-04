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
% 	++  STAB
% 	++  ["virtuals=" ++ show(V_VERTEX)]
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
