include "primal.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

solve :: wvcp_search() :: wvcp_restart()
  minimize(x_score);
%  satisfy;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

output
			SNL
	++
			show_instance()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++
% 			show_flags()
% 	++	SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_wvcp_heuristics()
% 	++  SNL
% 	++	
% 			show_wvcp_solution()
	++  SNL
	++	
			show_wvcp_score()
	++  SNL
	++	
			show_wvcp_rules()
;
