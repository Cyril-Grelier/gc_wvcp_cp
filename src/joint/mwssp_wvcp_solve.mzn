include "mwssp_wvcp.mzn";
include "mwssp_wvcp_heuristics.mzn";
include "mwssp_wvcp_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

solve :: mwssp_wvcp_search() :: mwssp_wvcp_restart()
%   seq_search([
%    int_search(x_color,first_fail,indomain_split),
%    int_search(y_arc,input_order,indomain_max)
%   ])
  minimize(x_score);
%  maximize(y_score);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

output
			show_instance()
	++  SNL 
% 	++ ["**************************"] ++ SNL
% 	++	
% 			show_flags()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_wvcp_rules()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_mwssp_wvcp_heuristics()
% 	++  SNL
% 	++	
% 			show_wvcp_heuristics()
% 	++  SNL
% 	++	
% 			show_mwssp_heuristics()
% 	++  SNL ++ ["**************************"] ++ SNL
% 	++	
% 			show_wvcp_solution()
% 	++  SNL
% 	++	
% 			show_mwssp_solution()
% 	++  SNL ++ ["**************************"] ++ SNL
	++	
			show_wvcp_score()
	++  SNL
	++	
			show_mwssp_score()
;
