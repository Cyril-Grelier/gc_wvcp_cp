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

constraint
global_cardinality([greatest(x_vertices[c]) | c in COLOR], R_VERTEX,[1 - y_dominated[i] | i in R_VERTEX]);

% backward and forward incompatible vertices are necessarily dominant
constraint
forall(i in R_VERTEX where ins[i]={} /\ outs[i]={})( 
  y_dominated[i] = 0
); 

% backward incompatible vertices are necessarily dominant (this constraint may be merged with above constraint)
constraint
forall(i in R_VERTEX where ins[i]={} /\ outs[i]!={})( 
  y_dominated[i] = 0
); 

% forward incompatible vertices are dominated iff backward dominated
constraint
forall(i in R_VERTEX where ins[i]!={} /\ outs[i]={})(
  y_dominated[i] = sum(hi in ins[i])(y_arc[hi]) % check if sum=0 when ins[i]={}
); 

% backward and forward compatible vertices
constraint
forall(i in R_VERTEX where ins[i]!={} /\ outs[i]!={})( 
	(		1 - y_dominated[i] >= max(ij in outs[i])(y_arc[ij]) % check if max=1 when outs[i]={}
  	/\		y_dominated[i] >= sum(hi in ins[i])(y_arc[hi])
  	)
);

% backward and forward compatible vertices are assumed dominant if not grouped
constraint
forall(i in R_VERTEX where ins[i]!={} /\ outs[i]!={})(
	1 - y_dominated[i] >= (1 - max(ij in outs[i])(y_arc[ij])) * (1 - sum(hi in ins[i])(y_arc[hi]))
);

% 
constraint
forall(ij in ARC)( 
  y_arc[ij] <= bool2int(x_color[head[ij]] == x_color[tail[ij]])
); 


% 
constraint
x_score + y_score = sum(weight);