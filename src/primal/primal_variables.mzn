%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% the color of each vertex
%% every color includes a single virtual vertex which is fixed by a one-to-one map
array[VERTEX] of var COLOR: x_color;

% the vertices of each color
%% every unused color includes exactly one vertex which is its virtual vertex
array[COLOR] of var set of VERTEX: x_vertices;

% the weight of each color
%% the weight of a color is the maximum weight of its vertices
%% the weight of an unused color is 0 since all virtual vertices have weight 0
array[COLOR] of var WEIGHT: x_weight;

% whether a color is used or not
array[COLOR] of var bool: x_used = [card(x_vertices[c])!=1 | c in COLOR];

% the number of used colors
var COLOR: x_nr_used = sum(x_used);

% the score
%% the score is the sum of the weights of the used colors
var SCORE: x_score;
