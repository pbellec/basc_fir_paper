function dist = niak_stability_glm_distance(data);
% l2-norm of the difference between effect maps in a connectome
%
% SYNTAX:
% DIST = NIAK_STABILITY_GLM_DISTANCE(DATA)
%
% _________________________________________________________________________
% INPUTS:
%
% DATA
%    (structure) with the following fields:
%
%    X
%        (array N*P) N observations, K predicting variables
%
%    Y
%        (array N*S) N observations, S features. The N features correspond to
%        a vectorized (symmetric) connectivity matrix. 
%
%    C 
%        (vector P*1) a contrast vector. It has to have exactly
%        one 1 and otherwise 0s. Contrast with multiple covariates
%        are not supported.
%
% _________________________________________________________________________
% OUTPUTS:
%
% DIST
%    (vector) a vectorized version of the l2-norm difference between 
%    effect maps. 
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_STABILITY_GLM_NULL, NIAK_BRICK_STABILITY_CORES
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec
% Département d'informatique et de recherche opérationnelle
% Centre de recherche de l'institut de Gériatrie de Montréal
% Université de Montréal, 2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : statistics, correlation

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

[N,K] = size(data.x);
beta = niak_lse(data.y,data.x);
eff = niak_vec2mat(beta'*data.c,0);
dist = niak_build_distance(eff);
dist = niak_mat2vec(dist);