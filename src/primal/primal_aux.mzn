%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Lesaint (david.lesaint@univ-angers.fr)


%%% OPTIONAL REDUNDANT CONSTRAINTS

%% (P14) lower/upper bounds on colors/score based on fully connected/disconnected vertices
constraint
	if M_AUX in WVCP_M
	then
		%% (P14a) the number of fully-connected nodes lower-bounds the number of colors
			x_KOS >= length(cliqued)
		/\
		%% (P14b) the number of disconnected nodes provides an upper-bound on the number of colors
			x_KOS <= max(K) - length(disconnected) + 1
		/\
		%% (P14c) lower-bound on score based on fully-connected nodes
			if length(cliqued) != 0
			then
				x_o >= sum(i in index_set(cliqued))(w[cliqued[i]])
			endif
		/\	
		%% (P14d) upper-bound on score based on disconnected nodes
			if length(disconnected) != 0
			then
				let {
					V: u = dominant_U(array2set(disconnected));
				} in
					x_o <= sum(w) - sum(i in index_set(disconnected))(w[disconnected[i]]) + w[u]
			endif
endif;

%% (P15) global cardinality constraint expressing score function using weight count variables
include "global_cardinality_closed_fn.mzn";
constraint
	if M_AUX in WVCP_M
	then
		let {
			% x_WK[i] = count of colors taking weight W[i]
			array[range(W_U)] of var omega(K): x_WK :: is_defined_var;
		} in
				x_WK = global_cardinality_closed(x_KW, W_U) :: bounds % !! close counting with gcc_closed
		/\		x_o = sum(i in index_set(x_WK))(W_U[i] * x_WK[i]) :: bounds
	endif;

%% (P16) Dominance order on color weights. Entailed by (P10).
include "decreasing.mzn";
constraint
	if D_SORTED /\ (M_AUX in WVCP_M)
	then
		decreasing(x_KW) :: bounds
	endif;
