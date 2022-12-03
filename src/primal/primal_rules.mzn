%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRY BREAKING RULES

include "lex_chain_greater.mzn";
include "strictly_increasing.mzn";


%%%%%%%%%%%%
% lexicographic ordering constraint that sorts colors using >>_{c}

% (a) generic constraint formulation that assumes no existing ordering of vertices - uses global constraint lex_chain_greater
constraint
if not(I_SORT)
then
	lex_chain_greater(array2d(1..2, COLOR, x_weight ++ [max(VERTEX) - greatest(x_vertices[c]) | c in COLOR]))
	% alternative custom formulation
	% include "strictly_decreasing.mzn";
	% strictly_decreasing([max(VERTEX)*x_weight[c] - greatest(x_vertices[c] | c in COLOR]);
endif;

% (b) optimized constraint formulation when vertices are sorted in descending order of weights using >>_{w} (check speedup factor against generic formulation on R100_1g.dzn!)
constraint
if I_SORT
then
	strictly_increasing([greatest(x_vertices[c]) | c in COLOR])
endif;
