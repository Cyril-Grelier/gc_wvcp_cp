include "dual.mzn";
include "dual_heuristics.mzn";
include "dual_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

solve :: mwssp_search() :: mwssp_restart()
%   maximize(y_score);
	minimize sum(weight) - y_score;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

output
% 			show_instance()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_flags()
% 	++	SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_mwssp_heuristics()
% 	++  SNL
% 	++	
% 			show_mwssp_solution()
% 	++  SNL
% 	++
			show_mwssp_score()
;
