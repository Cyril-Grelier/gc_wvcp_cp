%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

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
	++		STAB	++	STAB	++	["WVCP_SEARCH_VARIABLES_COLORS\t=" ++ show(WVCP_SEARCH_VARIABLES_COLORS) ++ "\t+\t" ++ "WVCP_SEARCH_DOMAIN_COLORS\t=" ++ show(WVCP_SEARCH_DOMAIN_COLORS)]
	;

%%
function array[int] of string: show_wvcp_solution() =
			["WVCP solution"]
	++		STAB
	++		["Coloring\t"] ++ [show(v) ++ "=" ++ show(x_color[v]) ++ " " | v in R_VERTEX]
	++		SNL
	++		STAB	++	STAB
	++  ["Partitioning\t"] ++ [show(c) ++ "=" ++ show(x_vertices[c]) ++ " " | c in COLOR where fix(x_opened[c])]
	++  SNL
	++		STAB	++	STAB
	++  ["Weighting\t"] ++ [show(c) ++ "=" ++ show(x_weight[c]) ++ " " | c in COLOR where fix(x_opened[c])]
	;

%%
function array[int] of string: show_wvcp_score() =
			["WVCP scores"]
	++		STAB
	++		[show(lb_score) ++ " <= " ++ show(x_score) ++ " <= " ++ show(ub_score) ++ " <= " ++ show(sum(r_weight))]
	++  SNL
	++		STAB	++	STAB
	++		["colors\t"] ++ [show(lb_colors) ++ " <= " ++ show(x_opened_colors) ++ " <= " ++ show(ub_colors) ++ " <= " ++ show(card(R_VERTEX))]
	;

%%
function array[int] of string: show_wvcp_rules() =
			["WVCP rules"]
	++		STAB
	++		["S-GDV (SR1)="] ++ [show(count_SGDV())]
	++		STAB
	++  ["D-GDV (DR1)="] ++ [show(count_DGDV())]
	++		STAB
	++  [if(M_SR2 in WVCP_M) then show(M_SR2) else "S-GDC" endif ++ "="] ++ [show(count_SGDC())]
	++		STAB
	++  [if(M_DR2_v1 in WVCP_M) then show(M_DR2_v1) elseif(M_DR2_v2 in WVCP_M) then show(M_DR2_v2) elseif(M_DR2_v3 in WVCP_M) then show(M_DR2_v3) elseif(M_DR2_v4 in WVCP_M) then show(M_DR2_v4) else "D-GDC" endif ++ "="] ++ [show(count_DGDC())]
	;