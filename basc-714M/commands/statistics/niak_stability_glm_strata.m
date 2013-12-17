function mask = niak_stability_glm_strata(model,labels,strata,mask);
% Create strata using the distribution of covariates in a linear model
%
% SYNTAX:
% MASK = NIAK_STABILITY_GLM_STRATA(MODEL,LABELS,STRATA)
%
% _________________________________________________________________________
% INPUTS:
%
% MODEL
%    (array N*P) N observations, K predicting variables
%
% LABELS
%    (cell of strings) LABELS{K} is the name of the Kth predicting variable.
%
% STRATA
%    (structure, optional) with multiple entries, each one with the
%    following fields :
%
%    LABEL
%       (string) the name of a covariate.
%
%    NB_STRATA
%       (integer) the subjects will be partitioned into close-to-even
%       strata based on the distribution of the covariate OPT.LABEL.
%
% _________________________________________________________________________
% OUTPUTS:
%
% MASK
%    (vector N*1) MASK(N) is the number of the strata of observation N.
%
% _________________________________________________________________________
% COMMENTS:
% Observations are stratified iteratively, taking the entries of STRATA in 
% ascending order.
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

% Recursively build a strata from multiple covariates
nb_strata = length(strata);

if (nb_strata == 0)||~isfield(strata,'label')
    mask = ones([1 size(model,1)]);
    return
end
if nargin < 4
    mask = ones([1 size(model,1)]);
end
nb_strata_new = 0;
mask_new = zeros(size(mask));
for num_s = 1:max(mask)    
    mask_tmp = sub_build_strata(model(mask==num_s,:),labels,strata(1));
    mask_new(mask==num_s) = mask_tmp + nb_strata_new;    
    nb_strata_new = nb_strata_new + max(mask_tmp);
end
if nb_strata >= 2
    mask_new = niak_stability_glm_strata(model,labels,strata(2:end),mask_new);
end
mask = mask_new;

function mask = sub_build_strata(model,labels,strata)
% build one strata from one covariate
ind = find(ismember(labels,strata.label));
if isempty(ind)
    error(fprintf('label %s was not found in the model, I can''t define the strata.',strata.label));
end
[val,order] = sort(model(:,ind));
if length(unique(val))<strata.nb_strata
    error(fprintf('There user specified too much strata for the covariate %s : there are not enough values\n',strata.label));
end
if strata.nb_strata>1
    limits = ceil(length(order)*(1:(strata.nb_strata - 1))/(strata.nb_strata));
else
    limits = [];
end
limits = [1 limits size(model,1)];
if length(unique(limits))~=length(limits)
    error(fprintf('There user specified too much strata for the covariate %s : there are not enough subjects\n',strata.label));
end
mask = zeros([1 length(order)]);
for num_s = 1:strata.nb_strata
    if num_s == 1
        mask(order(limits(num_s):limits(num_s+1))) = num_s;
    else
        mask(order(limits(num_s)+1:limits(num_s+1))) = num_s;
    end
end 
