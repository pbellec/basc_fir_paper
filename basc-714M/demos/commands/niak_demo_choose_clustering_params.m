%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_CHOOSE_CLUSTERING_PARAMS
%
% This is a script to demonstrate how to choose the optimal clustering
% parameters that minimize the total marginal log likelihood of the
% stability properties uner the null, using NIAK_CHOOSE_CLUSTERING_PARAMS
%
% SYNTAX:
% Just type in NIAK_DEMO_CHOOSE_CLUSTERING_PARAMS
%
% _________________________________________________________________________
% OUTPUT
%
% The script will use NIAK_DEMO_DATA to generate an example dataset, and
% will run NIAK_CHOOSE_CLUSTERING_PARAMS on his dataset.
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : 

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

clear

niak_demo_data

tseries = data(1).tseries;
clear data

%% Clustering options
clustering.type_clust = 'kmeans';
clustering.opt_clust.nb_iter = 5;
clustering.opt_clust.flag_verbose = 0;
clustering.opt_clust.type_init = 'random_point';
clustering.opt_clust.type_death = 'singleton';

list_nb_classes = [2  4  6 8 10 12 15];
for num_c = 1:length(list_nb_classes)
    opt_stab.clustering(num_c) = clustering;
    opt_stab.clustering(num_c).opt_clust.nb_classes = list_nb_classes(num_c);
end

%% Bootstrap options
opt_stab.bootstrap.dgp = 'CBB';
opt_stab.bootstrap.block_length = 10;

%% Sampling option
opt_stab.nb_samps_stab = 50;
opt_stab.nb_samps_cdf = 1000;

[num_opt,log_lh,tests] = niak_choose_clustering_params(tseries,opt_stab);