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

niak_demo_data_1scale

list_nb_clust = 2:2:35;
%list_nb_clust = [4 10];
list_nb_clust_thresh = 2:2:35;
N = ceil(sqrt(length(list_nb_clust)));
M = ceil(length(list_nb_clust)/N);

%sil = zeros([length(list_nb_clust) length(list_nb_clust_thresh)]);
sil = zeros([length(list_nb_clust) 1]);

%% Sampling option
opt_stab.nb_samps = 40;

for num_c = 1:length(list_nb_clust)

    subplot(M,N,num_c);
    
    %% Clustering options
    opt_stab.clustering.type_clust = 'kmeans';
    opt_stab.clustering.opt_clust.nb_classes = list_nb_clust(num_c);
    opt_stab.clustering.opt_clust.nb_iter = 1;
    opt_stab.clustering.opt_clust.flag_verbose = 0;
    opt_stab.clustering.opt_clust.type_init = 'random_point';
    opt_stab.clustering.opt_clust.type_death = 'singleton';
    
    %% Bootstrap options
    opt_stab.bootstrap.dgp = 'CBB';
    opt_stab.bootstrap.block_length = 5:20;
    opt_stab.bootstrap.independence = false;     
    
    %% Build actual stabs
    stab = niak_build_stability_ind(tseries,opt_stab);
    
    mat = niak_vec2mat(stab);
    hier = niak_hierarchical_clustering(mat);
    %     for num_d = 1:length(list_nb_clust_thresh)
    %         opt_thresh.type = 'nb_classes';
    %         opt_thresh.thresh = list_nb_clust_thresh(num_d);
    %         part = niak_threshold_hierarchy(hier,opt_thresh);
    %         sil(num_c,num_d) = mean(niak_build_silhouette(mat,part,false));
    %     end
    
    opt_thresh.type = 'nb_classes';
    opt_thresh.thresh = list_nb_clust(num_c);
    part = niak_threshold_hierarchy(hier,opt_thresh);
    %sil(num_c,num_d) = mean(niak_build_silhouette(mat,part,false));
    sil(num_c) = mean(niak_build_silhouette(mat,part,false));
    
    %% Visualization
    opt_visu.limits = [0 1];
    opt_visu.color_map = 'jet';
    niak_visu_matrix(niak_vec2mat(stab),opt_visu);
    title(sprintf('K=%i',list_nb_clust(num_c)));
    
end

R = niak_build_correlation(tseries);
hf2 = figure;
niak_visu_matrix(abs(R),opt_visu);
set(hf2,'name','correlation matrix');

% %% Build stabs under the null hypothesis
% opt_stab.scheme.time_series.independence = 1;
% data_boot = niak_bootstrap_data(data,opt_stab.scheme); % resample the data under a null hypothesis of inconsistent spatial structure across subjects
% opt_stab.scheme.time_series = rmfield(opt_stab.scheme.time_series,'independence');
% stab2 = niak_build_stability(data_boot,opt_stab);
% 
% figure
% niak_visu_matrix(niak_vec2mat(stab2),opt_visu);
% mean(stab2)