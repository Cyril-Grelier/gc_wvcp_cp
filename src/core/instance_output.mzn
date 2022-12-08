%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

array[int] of string: SNL = ["\n"];
array[int] of string: STAB = ["\t"];
array[int] of string: SEP = ["**************************"];

function array[int] of string: show_size() =
			["Instance"]
	++  STAB
	++  ["vertices=" ++ show(card(R_VERTEX))]
	++  STAB
	++		["density=" ++ show(round(100*density)) ++ "%" ++ "disconnected/cliqued=" ++ show(length(disconnected)) ++ "/" ++ show(length(cliqued))]
	++		STAB
	++		["colors=" ++ show(lb_colors..ub_colors)]
	++  STAB
	++		[%"weights in " ++ show(WEIGHT_SCALE)) ++ 
			"weight scale=" ++ show(card(R_WEIGHT_SCALE)) ++ " (" ++ show(min(r_weight)) ++ "," ++ show(round(sum(r_weight)/card(R_VERTEX))) ++ "," ++ show(max(r_weight)) ++ ")"]
	;

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
