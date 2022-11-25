include "../core/instance_output.mzn";
include "../primal/primal_output.mzn";
include "../dual/dual_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

%%
function array[int] of string: show_mwssp_wvcp_heuristics() =
%			["MWSSP_WVCP heu."]
			STAB
	++	STAB
	++	["MWSSP_WVCP_SEARCH_STRATEGY\t=" ++ show(MWSSP_WVCP_SEARCH_STRATEGY)];
