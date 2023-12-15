%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Lesaint (david.lesaint@univ-angers.fr)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FILE INCLUSION

include "../core/core.mzn";
include "../dual/dual.mzn";
include "../primal/primal.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% JOINT CONSTRAINTS

%% (J1) an arc in the dual solution suffices to color its nodes identically in the primal solution
constraint
	forall(ij in ARC)( 
		y_A[ij] <= (x_U[tail[ij]] == x_U[head[ij]]) :: domain
	); 

%% (J2) matching color dominants of primal and dual solutions
include "global_cardinality.mzn";
constraint
	global_cardinality([x_D[k] | k in K], V, [z_V[i] | i in V]) :: domain;

%% (J3) matching scores of primal and dual solutions
constraint
	x_o = yx_o :: bounds;

%% (J4) -> placed in primal.mzn using left_shift.mzn. Switched on by M_LS


%%% ADDITIONAL CONSTRAINTS

% (J5) redundant constraint matching numbers of opened colors (omitted in IJCAI model)
constraint
	if (M_AUX in WVCP_M)
	then	y_KOS = x_KOS :: bounds
	endif;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% JOINT SEARCH


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SEARCH STRATEGIES

enum JOINT_SEARCH = {
  DUAL,
  PRIMAL
};


JOINT_SEARCH: JOINT_STRATEGY;


function ann: mwssp_wvcp_search() =
  if      JOINT_STRATEGY=DUAL
  then    mwssp_search()
  else    wvcp_search()
  endif;


function ann: mwssp_wvcp_restart() =
  if      JOINT_STRATEGY=DUAL
  then    mwssp_restart()
  else    wvcp_restart()
  endif;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY

%%
function array[int] of string: show_mwssp_wvcp_heuristics() =
			["Joint strategy"]
	++		STAB
	++		[show(JOINT_STRATEGY)];
