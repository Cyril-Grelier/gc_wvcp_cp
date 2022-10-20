include "wvcp.mzn";
include "wvcp_heuristics.mzn";
include "wvcp_output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

%TODO restart annotation raises error/warning '% Error in search annotation: Unknown search annotation. Ignore search annotation!'
solve :: wvcp_search() :: wvcp_restart()
  minimize(x_score);
%  satisfy;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE

output
			SNL
	++
			show_instance()
	++  SNL ++ ["**************************"] ++ SNL
	++
			show_flags()
	++	SNL ++ ["**************************"] ++ SNL
	++	
			show_wvcp_heuristics()
	++  SNL
	++	
			show_wvcp_solution()
	++  SNL
	++	
			show_wvcp_score()
	++  SNL
	++	
			show_wvcp_rules()
;

%date; minizinc --solver or-tools --time-limit 3600000 --random-seed 1 --parallel 1 --compiler-statistics --solver-statistics --intermediate -D WVCP_SEARCH_STRATEGY=VERTICES_GENERIC -D WVCP_SEARCH_RESTART=RESTART_NONE -D "WVCP_SEARCH_VARIABLES_COLORS=WVCPSV(INPUT_ORDER)" -D WVCP_SEARCH_DOMAIN_COLORS=INDOMAIN_MIN -D "WVCP_SEARCH_VARIABLES_WEIGHTS=WVCPSV(INPUT_ORDER)" -D WVCP_SEARCH_DOMAIN_WEIGHTS=INDOMAIN_SPLIT -D "WVCP_SEARCH_VARIABLES_VERTICES=WVCPSV(FIRST_FAIL)" -D WVCP_SEARCH_DOMAIN_VERTICES=INDOMAIN_SPLIT wvcp_solve.mzn no_cliques.dzn no_ub_colors.dzn no_ub_score.dzn -D "WVCP_B={}" -D "WVCP_M={M_SORT}" ../original_wvcp_dzn/p40.dzn; beep;

