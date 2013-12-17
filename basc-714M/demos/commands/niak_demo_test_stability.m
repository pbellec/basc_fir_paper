%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_TEST_STABILITY
%
% This is a script to demonstrate how to test the significance of
% individual (2-)stability coefficients of a clustering procedure against a
% null hypothesis of temporal independence between units.
%
% SYNTAX:
% Just type in NIAK_DEMO_TEST_STABILITY
%
% _________________________________________________________________________
% OUTPUT
%
% The script will use NIAK_DEMO_DATA to generate an example dataset, and
% will run NIAK_TEST_STABILITY on his dataset.
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
opt_stab.clustering.type_clust = 'kmeans';
opt_stab.clustering.opt_clust.nb_iter = 5;
opt_stab.clustering.opt_clust.nb_classes = 10;
opt_stab.clustering.opt_clust.flag_verbose = 0;
opt_stab.clustering.opt_clust.type_init = 'random_point';
opt_stab.clustering.opt_clust.type_death = 'singleton';

%% Bootstrap options
opt_stab.bootstrap.dgp = 'CBB';
opt_stab.bootstrap.block_length = 10;

%% Sampling option
opt_stab.nb_samps_stab = 100;
opt_stab.nb_samps_cdf = 1000;
opt_stab.side = 'right-sided';

tests = niak_test_stability(tseries,opt_stab);

%% Visualization
opt_visu.limits = [0 1];
opt_visu.color_map = 'jet';
hf = figure;
niak_visu_matrix(niak_vec2mat(tests.plugin),opt_visu);
set(hf,'name','stability matrix');

opt_visu.limits = [0 5];
hf2 = figure;
niak_visu_matrix(-log(niak_vec2mat(tests.pce)),opt_visu);
set(hf2,'name','-log(pce)');

opt_visu.limits = [0 1];
R = niak_build_correlation(tseries);
hf3 = figure;
niak_visu_matrix(abs(R),opt_visu);
set(hf3,'name','correlation matrix');
