include "../primal/primal.mzn";
include "../dual/dual.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% 
array[R_VERTEX] of var 0..1: y_dominated;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS


%TODO review
% constraint
% forall(u in R_VERTEX)( 
%   y_dominated[u] = bool2int(u != greatest(x_vertices[x_color[u]]))
% );


%%%%%%%%%%%
% PRIMAL/DUAL CHANNELING CONSTRAINTS

%
include "global_cardinality.mzn";
constraint
global_cardinality([greatest(x_vertices[c]) | c in COLOR], R_VERTEX,[1 - y_dominated[i] | i in R_VERTEX]);

% 
constraint
forall(ij in ARC)( 
  y_arc[ij] <= bool2int(x_color[head[ij]] == x_color[tail[ij]])
); 

% objectives
constraint
x_score = yx_score;


%%%%%%%%%%%
% JOINT-DUAL CONSTRAINTS

% disconnected vertices are dominant
constraint
forall(i in R_VERTEX where ins[i]={} /\ outs[i]={})( 
  y_dominated[i] = 0
); 

% backward vertices are dominant (this constraint may be merged with above constraint)
constraint
forall(i in R_VERTEX where ins[i]={} /\ outs[i]!={})( 
  y_dominated[i] = 0
); 

% forward vertices are dominated iff backward dominated
constraint
forall(i in R_VERTEX where ins[i]!={} /\ outs[i]={})(
  y_dominated[i] = sum(hi in ins[i])(y_arc[hi])
); 

% backward and forward vertices
constraint
forall(i in R_VERTEX where ins[i]!={} /\ outs[i]!={})( 
	(		1 - y_dominated[i] >= max(ij in outs[i])(y_arc[ij])
  	/\		y_dominated[i] >= sum(hi in ins[i])(y_arc[hi])
  	)
);

% backward and forward vertices are assumed dominant if not grouped
constraint
forall(i in R_VERTEX where ins[i]!={} /\ outs[i]!={})(
	1 - y_dominated[i] >= (1 - max(ij in outs[i])(y_arc[ij])) * (1 - sum(hi in ins[i])(y_arc[hi]))
);
