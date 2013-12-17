%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_STABILITY
%
% This is a script to demonstrate how to study the 2-stability of a
% clustering on group (stratified) time series via multi-level bootstrap
% using NIAK_BUILD_STABILITY
%
% SYNTAX:
% Just type in NIAK_DEMO_STABILITY 
%
% _________________________________________________________________________
% OUTPUT
%
% The script will use NIAK_DEMO_DATA to generate an example dataset, and
% will generate a 2-stability bootstrap analysis of the clusters in DATA.
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

load /home/pbellec/database/demo_niak/minc2/fmri_preprocess/subject1/resample_vol/hom_roi_tseries_func_motor_subject1_mc_a_f_s_res.mat
data.tseries = tseries;
data.subject = 'subject1';

%% Clustering options
opt_stab.type_clustering = 'kmeans';
opt_stab.clustering.nb_classes = 10;
opt_stab.clustering.nb_iter = 5;
opt_stab.clustering.flag_verbose = 0;
opt_stab.clustering.type_init = 'random_point';
opt_stab.clustering.type_death = 'singleton';

%% Bootstrap options
opt_stab.scheme.group.feature = 'subject';
opt_stab.scheme.group.strata = {};
opt_stab.scheme.time_series.dgp = 'CBB';
opt_stab.scheme.time_series.block_length = 10;

%% Form option 
opt_stab.nb_samps = 25;
opt_visu.limits = [0 1];
opt_visu.color_map = 'jet';

%% Build actual stabs
stab = niak_build_stability(data,opt_stab);

figure
niak_visu_matrix(niak_vec2mat(stab),opt_visu);
mean(stab)

% %% Build stabs under the null hypothesis
% opt_stab.scheme.time_series.independence = 1;
% data_boot = niak_bootstrap_data(data,opt_stab.scheme); % resample the data under a null hypothesis of inconsistent spatial structure across subjects
% opt_stab.scheme.time_series = rmfield(opt_stab.scheme.time_series,'independence');
% stab2 = niak_build_stability(data_boot,opt_stab);
% 
% figure
% niak_visu_matrix(niak_vec2mat(stab2),opt_visu);
% mean(stab2)