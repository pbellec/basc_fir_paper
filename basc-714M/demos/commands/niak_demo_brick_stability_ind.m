%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_BRICK_STABILITY_IND
%
% This is a script to demonstrate how to estimate (2-)stability
% coefficients of a clustering procedure on time series using
% NIAK_BRICK_STABILITY_IND.
%
% SYNTAX:
% Just type in NIAK_DEMO_BRICK_STABILITY_IND
%
% _________________________________________________________________________
% OUTPUT
%
% The script will load time series in the folder FOLDER_BASC/data_demo/ and
% will generate a 2-stability coefficients for a kmeans clustering using 
% NIAK_BRICK_STABILITY.
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

niak_gb_basc

%% Building input file names
list_num_subject = 1:6;
list_num_run = 1:2;

for num_s = list_num_subject
    for num_r = list_num_run
        
        files_in{num_s,num_r} = [gb_basc_demo_path 'tseries_subj' num2str(num_s) '_run' num2str(num_r) '.mat'];
        
    end
end

%% Clustering options
clustering.type_clust = 'kmeans';
clustering.opt_clust.nb_iter = 5;
clustering.opt_clust.flag_verbose = 0;
clustering.opt_clust.type_init = 'random_point';
clustering.opt_clust.type_death = 'singleton';

list_nb_classes = [3 6 10 13];
for num_c = 1:length(list_nb_classes)
    opt_stab.clustering(num_c) = clustering;
    opt_stab.clustering(num_c).opt_clust.nb_classes = list_nb_classes(num_c);
end

%% Bootstrap options
opt_stab.bootstrap.dgp = 'CBB';
opt_stab.bootstrap.block_length = 10;
opt_stab.bootstrap.independence = false;

%% Sampling option
opt_stab.nb_samps_stab = [100 100];
opt_stab.nb_samps_cdf = 1000;

%% Normalization option
opt_stab.correction_ind.type = 'mean_var';
opt_stab.correction_group.type = 'mean_var';

%% Build actual stabs
for num_s = list_num_subject
        fprintf('Subject %i \n',num_s)
        name_job = ['stability_subj' num2str(num_s)];
        files_out.stability = [gb_basc_demo_path 'stability' filesep 'stability_subj' num2str(num_s) '.mat'];
        files_out.nb_classes = [gb_basc_demo_path 'stability' filesep 'nb_classes_subj' num2str(num_s) '.mat'];
        pipeline.(name_job).command = 'rand(''twister'',sum(100*clock)),randn(''state'',sum(100*clock)),niak_brick_stability_ind(files_in,files_out,opt)';
        pipeline.(name_job).files_in = files_in(num_s,:);
        pipeline.(name_job).files_out = files_out;
        pipeline.(name_job).opt = opt_stab;        
end

opt_pipe.path_logs = [gb_basc_demo_path 'stability' filesep 'logs' filesep];
opt_pipe.mode_pipeline_manager = 'session';
opt_pipe.mode = 'batch';
opt_pipe.max_queued = 2;

psom_run_pipeline(pipeline,opt_pipe);