include "../instance_output.mzn";
include "../wvcp/wvcp_output.mzn";
include "../mwssp/mwssp_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

%%
function array[int] of string: show_mwssp_wvcp_heuristics() =
%			["MWSSP_WVCP heu."]
			STAB
	++	STAB
	++	["MWSSP_WVCP_SEARCH_STRATEGY\t=" ++ show(MWSSP_WVCP_SEARCH_STRATEGY)];
