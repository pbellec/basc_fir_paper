function data_boot = niak_stability_glm_null(data,opt);
% GLM-based resampling under the null hypothesis of no interaction with a trait 
%
% SYNTAX:
% DATA_BOOT = NIAK_STABILITY_GLM_NULL(DATA)
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
%        (array N*S) N observatons, S features
%
%    C 
%        (vector P*1) a contrast vector. It has to have exactly
%        one 1 and otherwise 0s. Contrast with multiple covariates
%        are not supported.
%
% _________________________________________________________________________
% OUTPUTS:
%
% DATA_BOOT
%    (structure) same as DATA after resampling under the null.
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_BRICK_GLM_CONNECTOME, NIAK_STABILITY_GLM_DISTANCE
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

ind = find(data.c);
if length(ind)~=1
    error('The contrast vector should have exactly one 1')
end

[beta,E] = niak_lse(data.y,data.x(:,~data.c));
data_boot.y = data.x(:,~data.c)*beta + E(randperm(size(E,1)),:);
data_boot.x = data.x;
data_boot.c = data.c;